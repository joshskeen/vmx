class MixEngine
	@activeVideo = null
	@midiClip = null

	#@socket  = io.connect('http://localhost:8080')
	constructor: ->
		@videoSources = ['./vids/enya.webm',
		'./vids/korg.webm',
		'./vids/sitar.webm',
		'./vids/rocket_countdown.webm',
		 './vids/pentap.webm',
		'./vids/mulan.webm']
		@action = null
		@presentationMode = new PresentationMode(@)
		@videos = []
		@connections = []
		@raphael = Raphael("container", "100%", "100%")
		@uiOverlay = $("<div class='ui_overlay'></div>").hide()
		@uiOverlay.appendTo('body')
		@uiOverlayVisible = false
	setVideoSources: (videosources)-> 
		@videoSources = []
		for vidsource in videosources
			@videoSources.push('./vids/' + vidsource);
	setFilter:(filterCode) -> 
		console.log filterCode
		if @activeVideo?
			@activeVideo.videoFilter = filterCode
	toggleLoop: -> 
		if @activeVideo?
			if @activeVideo.loop == false
				@activeVideo.loop = true
			else 
				@activeVideo.loop = false
			console.log("set loop to " + @activeVideo.loop)
	handleMidi:(midiMessage)->
		#midiMessage  = [signal, note, velocity]
		#assign any midi messages to clips if needed
		if @midiClip?
			console.log midiMessage
			@midiClip.midiAssignment = midiMessage
			@midiClip = null
		for video in @videos
			if video.midiAssignment?
				if video.midiAssignment[1] == midiMessage[1]
					console.log "match - message = " + midiMessage
					if midiMessage[0] == 128 #midi OFF message
						#video.pause()
						console.log "pause.."
					if midiMessage[0] == 144 #midi ON message
						console.log "play"
						video.reset()
						video.play()

	assignMidi: -> 
		@midiClip = @activeVideo
		console.log "midiclip = " + @midiClip
	showPresentation: -> 
		if @presentationMode.canvas.is(":visible")
			@presentationMode.hidePresentation()
		else
			@presentationMode.displayPresentation()
	toggleEditor: -> 
		@container = $("#container")
		if @container.is(":visible")
			@container.css("display", "none")
		else 
			@container.css("display", "block")
	showUiOverlay: -> 
		@uiOverlay.show()
		@uiOverlayVisible = true
	showVideoUi: -> 
		_self = @
		selectList = ""
		for vidsrc in @videoSources
			selectList += "<option value='"+vidsrc+"'>"+vidsrc+"</option>"
		dialogbox = $("<div class='dialogbox'><select>"+selectList+"</select></div>").dialog({
				title: "add video", 
				buttons: [{
						text: "add"
						click: -> 
							vidpath = $(dialogbox).find("select").val()
							vidToAdd = new VideoPlayer(50, 40, _self, vidpath)
							_self.addVideo(vidToAdd)
							dialogbox.dialog("destroy")
						},
						{
						text: "cancel"
						click: -> 
							dialogbox.dialog("destroy")
						}
				]
			})
		
	toggleUiOverlay: ->
		if @uiOverlayVisible
			@uiOverlay.hide()
			@uiOverlayVisible = false
		else
			@uiOverlay.show()
			@uiOverlayVisible = true
			#setup the keyframe window
	selectConnection: (@raphconn)->
		if @selectedConnection?
			@selectedConnection.line.attr("stroke", "#777777")
		@selectedConnection = @raphconn
		@selectedConnection.line.attr("stroke", "#ff0000")	
	addVideo: (@video)-> 
		@videos.push(@video)
	duplicateVideo: ->
		if @activeVideo?
			#clone him
			clonedVid = new VideoPlayer( @activeVideo.container.position().top,  @activeVideo.container.position().left + 10, @, @activeVideo.video_el.src)
			clonedVid.keyframes = []
			for kf in @activeVideo.keyframes
				clonedVid.keyframes.push(new KeyFrame(kf.start, kf.end, kf.maxlen, clonedVid))
			@.addVideo(clonedVid)
	hasFromOrToConnections: (@video)->
		if @.hasFromConnection(@video) || @.hasToConnection(@video)
			return true
		return false

	hasFromConnection: (@video)->
		if @connections?
			for connection in @connections
				if connection.from == @video
					return true
		return false
	
	hasToConnection: (@video)->
		if @connections?
			for connection in @connections
				if connection.to == @video
					return true
		return false

	getFromConnectionsForVideo: (@video)->
		_connections = []				
		if @connections?
			for connection in @connections
				if connection.from == @video
					_connections.push(connection)
		return _connections

	getToConnectionsForVideo: (@video)->
		_connections = []				
		if @connections?
			for connection in @connections
				if connection.to == @video
					_connections.push(connection)
		return _connections

	fromToConnection: (@connection)->
		if @fromConnection?
			if @fromConnection != @connection
				#add a new connection to 'connections'
				conn = new Connection(@fromConnection, @connection)
				@.connections.push(conn)
				@.drawConnections()
				@connection = null
				@fromConnection = null
		else
			@fromConnection = @connection

	drawConnections: ->
		_self = @
		for connection in @connections
			if connection.r_last? 
				connection.r_last.from.remove()
				connection.r_last.to.remove()
				connection.r_last.line.remove()
				#line, #from, #to
			raphconn = @raphael.connection(connection.from, connection.to, "#777777")
			raphconn.line.click(()->
				for conn in _self.connections
					if conn.r_last?
						if conn.r_last.line == this
							_self.selectConnection(conn.r_last)
			)
			connection.r_last = raphconn
	removeActiveConnection: -> 
		_self = @
		if @.selectedConnection?
			for connection in _self.connections
				if connection?
					if connection.r_last?
						if connection.r_last.from == _self.selectedConnection.from && connection.r_last.to == _self.selectedConnection.to
							_self.connections.splice(_self.connections.indexOf(connection), 1)
							console.log _self.connections.length
							connection.r_last.line.remove()
							_self.selectedConnection = null
	toggleKeyFrameControl: ->
		@.toggleUiOverlay()
		@.drawKeyFrames()

	refreshUiWindow: ->
		_self = @
		if @action? 
			if @uiOverlay.is(":visible")
				commands = new Commands
				if @action == commands.COMMAND_VIDSETTINGS
					_self.drawVideoSettings()
				else if @action == commands.COMMAND_KEYFRAME
					_self.drawKeyFrames()

	toggleTimeLine: ->
		@.toggleUiOverlay()	
		@.drawTimeLine()
	drawTimeLine: ->
		_self = @
		for video in @videos
			do(video) ->
				_self.uiOverlay.append(video)
	drawKeyFrames: ->
		@uiOverlay.empty()
		_self = @
		for slider in @activeVideo.keyframes
			do(slider) ->
				_self.uiOverlay.append(slider.drawSlider())
#		@keyframeWindow.append(sliders @.activeVideo.keyframes[0].drawSlider())
	drawVideoSettings: -> 
		@uiOverlay.empty()
		for slider in @activeVideo.vidSettings.drawSettingsSliders()
			@uiOverlay.append(slider)

	removeKeyFrame: -> 
		if @activeVideo.keyframes.length > 1
			if @activeVideo.currentFrame == @activeVideo.keyframes.length - 1
			   @activeVideo.currentFrame--
			   keyFrame = @activeVideo.keyframes[@activeVideo.currentFrame]
			   @activeVideo.video_el.currentTime = keyFrame.start
			@activeVideo.keyframes.pop()
			@.drawKeyFrames()
	addKeyFrame: ->
		console.log @activeVideo
		#copy previous keyframe
		prevKeyFrame = @activeVideo.keyframes[@activeVideo.keyframes.length - 1]
		console.log prevKeyFrame.start
		console.log prevKeyFrame.end
		newKeyFrame = new KeyFrame(prevKeyFrame.start, prevKeyFrame.end, @activeVideo.video_el.duration, @activeVideo)
		@activeVideo.keyframes.push(newKeyFrame)
		@.drawKeyFrames()
