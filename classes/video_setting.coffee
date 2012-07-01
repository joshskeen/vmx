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
		