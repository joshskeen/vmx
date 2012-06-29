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
	
	

