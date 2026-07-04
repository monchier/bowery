
period = 1
input[1].stream = function(volts)
  period = math.min(1, math.abs(1 / input[1].volts))
end

input[2].change = function(volts)
  output[1]()
end

function init()
	input[1].mode( 'stream')
	input[2].mode( 'change')
	output[1].action = pulse(0.01, 5, 1)

  clock.run(function()
      while true do
        output[1]()
        clock.sleep(period)
      end
    end) -- start a clock which will run the forever function
  end

