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