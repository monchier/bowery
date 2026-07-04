function init()
  -- Set up an LFO on output 1 using a dynamic variable for time
  output[1].action = loop { lfo() }
  
  -- Use a fast input stream on input 1 to read the CV
  input[1].stream = 0.01 -- Stream input value every 0.01 seconds
end

-- Define the LFO action. The time argument is now a dynamic variable.
function lfo(time_scale)
  -- The dyn keyword marks 'time' as a dynamic variable.
  -- It is initialized to 'time_scale', and can be updated later.
  local time = dyn { time_scale or 1 } 

  return loop {
    to(0, 0),
    to(0, time/2),
    to(5, 0.01),
    to(5, time/2),
  }
end

-- This function runs every time input 1 is streamed (every 0.01 seconds).
input[1].stream = function(volts)
  -- Map the 0-10V input to a range of LFO rates.
  -- The formula 2^(10-volts) creates an exponential change,
  -- where higher CV results in a faster LFO.
  -- A 0V input gives a 1024-second cycle, and 10V gives a 1-second cycle.
  local new_time = 2^(10 - volts)

  -- Update the dynamic variable inside the running LFO action.
  -- This changes the frequency without restarting the LFO.
  output[1].action.time:set(new_time)
end
