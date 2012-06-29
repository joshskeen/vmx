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
													settings = vid.vidSettings
													ctx = _self.canvas_el.getContext('2d')
													ctx.globalAlpha = settings.overlayAlpha
													ctx.drawImage(vid.video_el, settings.offsetX, settings.offsetY, settings.overlay_width, settings.overlay_height)
			, 33)
	hidePresentation: -> 
		@canvas.css('display', 'none')