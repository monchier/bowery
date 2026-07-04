-- metro[1].event = function(c) output[1].dyn.time=math.random(5) end
-- metro[1].time  = .5
-- metro[1]:start()
-- 
-- 
-- output[1].slew = .1
-- output[1].shape = 'linear'
-- -- output[1].action = loop{
-- --   to(5, dyn{time=.1}:mul(1.1)/2),
-- --   to(-5, dyn{time=1}/2)
-- -- }
-- output[1].action = loop{ to(5, dyn{time=1}), to(-5, .01) }
-- output[1].done = function()
--   output[1].dyn.time=math.random(5) 
-- end
-- output[1]()


coro_id = nil

function init()
	input[1].mode( 'stream')
	output[2].action = pulse(0.01, 5, 1)
  clock.run(forever) -- start a clock which will run the forever function

	output[3].action = lfo(dyn{time = 1}, 5, 'sine')
	output[4].action = lfo(dyn{time = 10}, 5, 'sine')
	-- output[3].dyn.time = 2
	-- output[4].dyn.time = 10
  delay(function() output[3]() end, math.random())
  delay(function() output[4]() end, math.random() * 10)
end

function forever()
  local mult = 5
	local cursor = -5 * mult
  while true do -- this will loop forever
		cursor = cursor + 1 / input[1].volts * 5
		if cursor > 5 * mult then
			cursor = -5 * mult
      output[2]()
		end
    -- output[1].volts = math.random() * 5 - 2.5
		output[1].volts = cursor / mult
		period = math.min(1, math.abs(1 / input[1].volts))
    clock.sleep(period) -- waits for 100ms before the next loop
  end
end
