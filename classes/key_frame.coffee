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