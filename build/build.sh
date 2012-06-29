coffee coffeescript-concat.coffee -I ../classes  \
	../classes/commands.coffee \
	../classes/connection.coffee \
	../classes/key_frame.coffee \
	../classes/mix_engine.coffee \
	../classes/presentation_mode.coffee \
	../classes/timeline_keyframes.coffee \
	../classes/video_player.coffee \
	../classes/video_setting.coffee \
	./main.coffee \
	> ./application.coffee
coffee --output ../public/js --compile application.coffee
echo 'build complete'
