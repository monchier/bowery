input[1].change = function(channel, state)
	output[1].volts = 5
	delay(function()
		output[1].volts = 0
	end, 10)
end

function init()
	input[1].mode( 'change', 2.5, 1, 'rising')
end
