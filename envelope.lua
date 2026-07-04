input[1].change = function()
	output[1].action = ar(.01, 1, 7, 'exponential')
	output[1]()
end



function init()
	input[1].mode( 'change', 2.5, 1, 'both')
end
