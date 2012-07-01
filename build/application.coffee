#object to hold VideoPlayer setting attributes
class VideoSetting
	constructor: (@speed, @volume)->
		@overlay_width = 320
		@overlay_height = 240
		@midinote = null
		@offsetX = 0
		@offsetY = 0
		@overlayAlpha = 1
	configureSettings: (@video_el) ->
		@video_el.playbackRate = @speed
		@video_el.volume = @volume
	drawSettingsSliders: ->  
			_self = @

			controls = []

			speedCtrlLabel = "<div class='labeltext speedlabel'>speed: "+ _self.speed + "</div>"
			speedCtrl = $("<div class='label'></div>").slider({
			min: .5,
			max: 3,
			value: _self.speed
			range: false, 
			step: .1,
			slide: (event, ui)->
				_self.speed = ui.value
				$(this).siblings(".speedlabel").text("speed: " + _self.speed)
			})
			controls.push(speedCtrlLabel)
			controls.push(speedCtrl)

			volumeCtrlLabel = "<div class='labeltext volumelabel'>volume: "+ _self.volume + "</div>"
			volumeCtrl = $("<div class='label'></div>").slider({
			min: 0,
			max: 1,
			value: _self.volume
			range: false, 
			step: .1,
			slide: (event, ui)->
				_self.volume = ui.value
				$(this).siblings(".volumelabel").text("volume: " + _self.volume)
			})
			controls.push(volumeCtrlLabel)
			controls.push(volumeCtrl)

			overlaywidthCtrlLabel = "<div class='labeltext overlaywidth'>canvas width: "+ _self.overlay_width + "</div>"
			overlaywidthCtrl = $("<div class='label'></div>").slider({
			min: 0,
			max: 2000,
			value: _self.overlay_width
			range: false, 
			step: 1,
			slide: (event, ui)->
				_self.overlay_width = ui.value
				$(this).siblings(".overlaywidth").text("canvas width: " + _self.overlay_width)
			})
			controls.push(overlaywidthCtrlLabel)
			controls.push(overlaywidthCtrl)

			overlayheightCtrlLabel = "<div class='labeltext overlayheight'>canvas height: "+ _self.overlay_height + "</div>"
			overlayheightCtrl = $("<div class='label'></div>").slider({
			min: 0,
			max: 2000,
			value: _self.overlay_height
			range: false, 
			step: 1,
			slide: (event, ui)->
				_self.overlay_height = ui.value
				$(this).siblings(".overlayheight").text("canvas height: " + _self.overlay_height)
			})
			controls.push(overlayheightCtrlLabel)
			controls.push(overlayheightCtrl)

			overlayAlphaLabel = "<div class='labeltext overlayAlpha'>overlayAlpha: "+ _self.overlayAlpha + "</div>"
			overlayAlphaCtrl = $("<div class='label'></div>").slider({
			min: 0,
			max: 1,
			value: _self.overlayAlpha
			range: false, 
			step: .1,
			slide: (event, ui)->
				_self.overlayAlpha = ui.value
				$(this).siblings(".overlayAlpha").text("overlayAlpha: " + _self.overlayAlpha)
			})
			controls.push(overlayAlphaLabel)
			controls.push(overlayAlphaCtrl)


			offsetXlabel = "<div class='labeltext offsetX'>offsetX: "+ _self.offsetX + "</div>"
			offsetXCtrl = $("<div class='label'></div>").slider({
			min: 0,
			max: 2000,
			value: _self.offsetX
			range: false, 
			step: .1,
			slide: (event, ui)->
				_self.offsetX = ui.value
				$(this).siblings(".offsetX").text("offsetX: " + _self.offsetX)
			})
			controls.push(offsetXlabel)
			controls.push(offsetXCtrl)

			offsetYlabel = "<div class='labeltext offsetX'>offsetY: "+ _self.offsetY + "</div>"
			offsetYCtrl = $("<div class='label'></div>").slider({
			min: 0,
			max: 2000,
			value: _self.offsetY
			range: false, 
			step: .1,
			slide: (event, ui)->
				_self.offsetY = ui.value
				$(this).siblings(".offsetY").text("offsetY: " + _self.offsetY)
			})
			controls.push(offsetYlabel)
			controls.push(offsetYCtrl)

			return controls
#			return [speedCtrlLabel, speedCtrl, volumeCtrlLabel, volumeCtrl, overlaywidthCtrlLabel, overlaywidthCtrl, overlayheightCtrlLabel, overlayheightCtrl]
		
class VideoPlayer
	@video = null
	@container = null
	@keyframes = null
	@loop = true
	@midiAssignment = null
	@startPoint = false
	@videoFilter = null;
	constructor:  (@top, @left, @engine, @filename)-> 
		_self = @
		@keyframes = []
		@currentFrame = 0
		@video = $('<video></video>').appendTo('#container').wrap('<div class="video_element"/>')
		#@canvas = $('<canvas height="640" width="480" style="border:1px solid green"></canvas>').appendTo('body')
		@video_el = @video.get(0)
		@video_el.width = 200
		@vidSettings = new VideoSetting(1, 1)
		@video_el.src = @filename
		@video_el.addEventListener 'loadedmetadata', ->
			_self.vidSettings.configureSettings(_self.video_el)
			if _self.keyframes.length == 0
				_self.keyframes.push new KeyFrame(0, _self.video_el.duration, _self.video_el.duration, @)

		@video_el.addEventListener 'timeupdate', ->
			vidTime = _self.video_el.currentTime
			vidLength = _self.video_el.duration
			keyFrame = _self.keyframes[_self.currentFrame]
			_self.vidSettings.configureSettings(_self.video_el)
			if vidTime < keyFrame.start
				_self.video_el.currentTime = keyFrame.start
			
			if vidTime >= keyFrame.end

				_self.currentFrame++
				if _self.currentFrame > _self.keyframes.length - 1
					_self.currentFrame = 0
					if _self.loop == false
						console.log("_self.loop = false")
						_self.video_el.pause()
					#Handle the connections between video clips here
					if _self.engine.connections?
						#get connections from this video to other videos..
						fromConnections = _self.engine.getFromConnectionsForVideo(_self)
						toConnections = _self.engine.getToConnectionsForVideo(_self)

						if _self.engine.hasFromOrToConnections(_self)
							_self.video_el.pause()
						if fromConnections.length > 0
								_self.video_el.pause()
							#console.log "fromconnections length = " + fromConnections.length
							for connection in fromConnections
								connection.to.play()
						if toConnections.length > 0 && fromConnections.length == 0
							console.log "to connections = " + toConnections.length
						
				keyFrame = _self.keyframes[_self.currentFrame]
				_self.video_el.currentTime = keyFrame.start
				if _self.video_el.paused && !_self.engine.hasFromOrToConnections(_self)
					_self.video_el.play()
					if _self.loop == false
						console.log("_self.loop = false")
						_self.video_el.pause()

			if _self.engine.activeVideo == _self
				$('.slider').removeClass('active')
				activeSlider = $('.slider')[_self.currentFrame]
				$(activeSlider).addClass('active')	
		@container = @video.parent()
		@container.append("<div class='filename'>"+@filename+"</div>")
		@container.css('position', 'absolute')
		@container.css('left', @left )
		@container.css('top', @top)
		@container.draggable()
		@container.resizable()
		@video.resizable()

		@container.bind 'drag', -> 
			#update connections
			_self.engine.drawConnections()
		@container.bind 'resize', -> 
			_self.video_el.width = $(@).width()
			_self.video_el.height = $(@).height()
		@video.bind 'click', ->
			_self.engine.activeVideo = _self
			_self.engine.refreshUiWindow()
		@video.bind 'dblclick', ->
			_self.engine.fromToConnection(_self)
	play: -> 
		@startPoint = true
		@video_el.play()
	reset: -> 
		@currentFrame = 0
		keyFrame = @keyframes[@currentFrame]
		console.log(keyFrame)
		@video_el.currentTime = keyFrame.start
	pause: -> 
		if @video_el.paused
			console.log "playing!"
			@video_el.play()
		else
			@video_el.pause()

class TimelineKeyFrame
	constructor: (@start, @end, @video, @action) ->

class PresentationMode
	constructor: (@engine)-> 
		@canvas = $("<canvas id='presentation_mode'></canvas>")
		$("body").append(@canvas)
		@canvas_el = @canvas.get(0)
		@.hidePresentation()
	displayPresentation: -> 
		@canvas.css('display', 'block')
		@.render()
	render: -> 
		_self = @
		rendervids = _self.renderVideos
		renderTimer = setInterval( ()->
										if _self.canvas.is(":visible")
											for vid in _self.engine.videos
												if !vid.video_el.paused#
													console.log "presentationMode, vidfilter = " + vid.videoFilter
													settings = vid.vidSettings
													ctx = _self.canvas_el.getContext('2d')
													ctx.globalAlpha = settings.overlayAlpha

													ctx.drawImage(vid.video_el, 0, 0, settings.overlay_width, settings.overlay_height)

##@COMMAND_FILTER_EDGEDETECTION = 50 filter_to_bw_outline
		##@COMMAND_FILTER_INVERT = 51 filter_invert
		##@COMMAND_BW = 52 filter_matrix
													if vid.videoFilter?
														if vid.videoFilter != 49
															cPA = ctx.getImageData(0, 0, settings.overlay_width, settings.overlay_height)
															
															if vid.videoFilter == 50
																cPA = filter_to_bw_outline(cPA, cPA,settings.overlay_width, settings.overlay_height)
															else if vid.videoFilter == 51
																cPA = filter_invert(cPA, cPA,settings.overlay_width, settings.overlay_height)
															else if vid.videoFilter == 52
																cPA = filter_matrix(cPA, cPA,settings.overlay_width, settings.overlay_height)
															ctx.putImageData(cPA, 0, 0)


			, 33)
	hidePresentation: -> 
		@canvas.css('display', 'none')
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

class KeyFrame
	constructor: (@start, @end, @maxlen, @video) ->
	drawSlider: ->  
			_self = @
			console.log _self.start
			console.log _self.end
			$("<div class='slider'></div>").slider({
			min: 0,
			max: _self.maxlen,
			values: [_self.start, _self.end],
			range: true, 
			step: .1,
			slide: (event, ui)->
				console.log(_self)
				_self.start = ui.values[0] #(_self.maxlen * (ui.values[0]* .01))
				_self.end = ui.values[1]#(_self.maxlen * (ui.values[1]* .01))
				console.log _self.start
				console.log _self.end
			})
class Connection
	constructor: (@from, @to) ->

class Commands
	constructor: ->
		@COMMAND_ADD = 118 # v - add video dialog
		@COMMAND_PLAY = 112 #p - play
		@COMMAND_KEYFRAME = 107 #k - keyframe
		@COMMAND_TOGGLE_EDITOR = 101 #k - keyframe
		@COMMAND_STOP = 115#s - stop
		@COMMAND_RESET = 114#r - reset
		@COMMAND_TIMELINE = 116 #t - timeline
		@COMMAND_REMOVE_CONNECTION = 120  # x - remove
		@COMMAND_ASSIGN_MIDI = 109 #m - assign midi
		@COMMAND_LOOP = 108 #l - loop clip
		@COMMAND_TOGGLE_PRESENTATION_MODE = 80 # shft + P
		@COMMAND_REMOVE_VIDEO = 88#shft + X = remove selected video
		@COMMAND_DUPLICATE = 68 # shft + d - duplicate
		@COMMAND_VIDSETTINGS = 99 # c - configure vidsettings
		
		#filters
		@COMMAND_FILTER_NONE = 49
		@COMMAND_FILTER_EDGEDETECTION = 50
		@COMMAND_FILTER_INVERT = 51
		@COMMAND_BW = 52

		@parentCommands = [@COMMAND_KEYFRAME, @COMMAND_TIMELINE, @COMMAND_VIDSETTINGS]
#=require <./classes/commands.coffee>
#=require <./classes/connection.coffee>
#=require <./classes/key_frame.coffee>
#=require <./classes/mix_engine.coffee>
#=require <./classes/presentation_mode.coffee>
#=require <./classes/timeline_keyframes.coffee>
#=require <./classes/video_player.coffee>
#=require <./classes/video_setting.coffee>

$ ->
	#alert('ready to rock')	
	engine = new MixEngine
	commands = new Commands
	if io?
		socket  = io.connect('http://localhost:8080')
		socket.on('message', (msg)->
				engine.handleMidi msg
		)
		socket.on('videos', (files)->
			#set files in "vids" directory on engine
			engine.setVideoSources files
		)

	$('body').keypress (event)->
#		console.log(engine.activeVideo.keyframes)
		console.log event.charCode
		if($.inArray(event.charCode, commands.parentCommands) != -1)
			engine.action = event.charCode
		if event.charCode == commands.COMMAND_ADD
			engine.showVideoUi()
		if event.charCode == commands.COMMAND_PLAY #p - play
			engine.activeVideo.play()
		else if event.charCode == commands.COMMAND_ASSIGN_MIDI
			engine.assignMidi()
		else if event.charCode == commands.COMMAND_KEYFRAME #k - keyframes
			engine.toggleKeyFrameControl()
		else if event.charCode == commands.COMMAND_STOP#s - stop
			engine.activeVideo.pause()
		else if event.charCode == commands.COMMAND_TOGGLE_PRESENTATION_MODE
			engine.showPresentation()
		else if event.charCode == commands.COMMAND_LOOP
			engine.toggleLoop()
		else if event.charCode == commands.COMMAND_TOGGLE_EDITOR
			engine.toggleEditor()
		else if event.charCode == commands.COMMAND_DUPLICATE
			engine.duplicateVideo()
		else if event.charCode == commands.COMMAND_FILTER_NONE || event.charCode == commands.COMMAND_FILTER_EDGEDETECTION || event.charCode == commands.COMMAND_FILTER_INVERT || event.charCode == commands.COMMAND_BW
			engine.setFilter(event.charCode)
		else if event.charCode == commands.COMMAND_VIDSETTINGS
			engine.toggleUiOverlay()
			if engine.uiOverlay.is(":visible")	
				engine.drawVideoSettings()
		else if event.charCode == commands.COMMAND_REMOVE_CONNECTION
			engine.removeActiveConnection()
		else if event.charCode == commands.COMMAND_RESET#r - reset
			engine.activeVideo.reset()
		else if event.charCode == commands.COMMAND_TIMELINE #t - timeline sequencer
			console.log "timeline"
			engine.toggleTimeLine()
		#handle ui overlay commands
		if engine.uiOverlay.is(":visible")	
			console.log("visible!")
			console.log(engine.action)
			if engine.action == commands.COMMAND_KEYFRAME #timeline
				if event.charCode == 97 #a - add keyframe
					engine.addKeyFrame()
				if event.charCode == 100 #d - delete keyframe
					engine.removeKeyFrame()
			else if engine.action == commands.COMMAND_TIMELINE
				if event.charCode == 97 #a - add keyframe
					console.log "ADD!"
#	videos = []
#	for vid in videos
#		engine.addVideo(vid)
	
	



