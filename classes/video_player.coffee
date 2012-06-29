class VideoPlayer
	@video = null
	@container = null
	@keyframes = null
	@loop = true
	@midiAssignment = null
	@startPoint = false
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
