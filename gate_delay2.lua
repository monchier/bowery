input[1].change = function(state)
	if state == true then
		output[1].volts = 10
    metro[1].time  = 1.0
    metro[1].count  = -1
	  metro[1].event = function(c) 
			if c >= 5 and input[1].volts < 2 then
				output[1].volts = 0
				metro[1]:stop()
			end
		end
		metro[1]:start()
	end
end

input[2].change = function(state)
	output[2].dyn.time = input[2].volts
	output[3].dyn.time = input[2].volts * 2
	output[4].dyn.time = input[2].volts * 4
end

function init()
	input[1].mode( 'change', 2.5, 1, 'both')
	input[2].mode( 'change')
	output[2].action = lfo(dyn{time = 1}, 5, 'sine')
	output[3].action = lfo(dyn{time = 5}, 5, 'sine')
	output[4].action = lfo(dyn{time = 10}, 5, 'sine')
  delay(function() output[2]() end, math.random())
  delay(function() output[3]() end, math.random())
  delay(function() output[4]() end, math.random() * 10)

end
