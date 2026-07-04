--- JF retuner script
-- matteo 2025.05.08
-- Use a fixed scale to retune JF
--
-- in1: transpose cv to be quantized v/8
-- in2: additional param
-- out1: transpose interval
-- out2: clock out
-- out3:
-- out4:

-- 1, 3, 5, 7, 9, 11
-- maybe use pairs
scales =
{ 
{{1,1}, {6,5}, {3,2}, {9,5}, {9,4}, {8,3}},
{{1,1}, {6,5}, {45,32}, {9,5}, {9,4}, {8,3}},
-- {{1,1}, {5,4}, {3,2}, {15,8}, {9,4}, {8,3}},
}

interval = 0
currentScale=1

input[1].scale = function(s)
  if interval ~= s.volts then
  	interval = s.volts
  	output[1].volts = s.volts
    -- ii.crow[1].call2(0, interval)
    ii.jf.transpose(interval)
  	print('transposing interval:', interval * 12)
	end
end

function retune(j)
  print('scale:', scales[j])
	for i=1,#scales[j] do
	    for k=1,#scales[j][i] do
	    	 print(scales[j][i][k])
			end
	end
  for i=1,6 do
	  if scales[j][i] then
    	ii.jf.retune(i, scales[j][i][1], scales[j][i][2])
		end
	end
end

input[2].scale = function(s)
  print('volts:', s.volts)
	i = math.fmod(math.tointeger(math.floor(s.volts * 12 + 0.05)), #scales) + 1
	print('i:', i)
	if i ~= currentScale then
	  currentScale = i
  	output[2].volts = s.volts
  	retune(currentScale)
  	print('retuned to:', currentScale)
	end
end

function init()
  input[1].mode('scale', {})
  input[2].mode('scale', {})
  -- ii.crow[1].call2(0, interval)
  ii.jf.transpose(interval)
  retune(currentScale)
end

