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