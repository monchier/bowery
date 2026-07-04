--- matteo's script
-- matteo 2025.05.08
-- Use a fixed scale (set of scales), generate -11 chords for jf, 
-- output qunatized outputs related in some way, maybe intervals - would be
-- cool making these intervals evolving)
--
-- in1: trigger input to transition to next phase (transposition/scale)
-- in2: cv to be quantized v/8
-- out1: quantized output
-- out2: quantized output
-- out3: quantized output
-- out4: root note output

snum = {'octave','chroma','major','harMin','dorian','majTri','dom7th','wholet'}


scales =
{ octave = {0}
, chroma = {} -- this is a shortcut
, major  = {0,2,4,5,7,9,11}
, harMin = {0,2,3,5,7,8,10}
, dorian = {0,2,3,5,7,9,10}
, majTri = {0,4,7}
, dom7th = {0,4,7,10}
, wholet = {0,2,4,6,8,10}
}

counter = 0

function transposeScale(s, c)
  local n = {}  
  for i = 1, #s do
    n[i] = s[i] + c
  end
  return n
end

public.add('currentScale','dorian',snum
  , function(s) input[2].mode('scale',scales[s]) end)

-- update continuous quantizer
input[2].scale = function(s)
  output[1].volts = s.volts
  output[2].volts = s.volts + scales[public.currentScale][3] / 12
  output[3].volts = s.volts + scales[public.currentScale][5] / 12
end

-- update scale
input[1].change = function(state)
	input[2].mode('scale', transposeScale(scales[public.currentScale], counter))
  ii.jf.transpose(counter/12)
  output[4].volts = counter/12
  counter = (counter + 2) % 4
end


function init()
  counter = 0
  input[1].mode('change', 1, 0.1, 'rising')
  input[2].mode('scale', scales[public.currentScale])

  ii.jf.retune( 0, 0, 0 )
  ii.jf.transpose(0)
  ii.jf.retune( 1, 1, 1)
  ii.jf.retune( 2, 6, 5 )
  ii.jf.retune( 3, 3, 2 )
  ii.jf.retune( 4, 9, 5 )
  ii.jf.retune( 5, 9, 4 )
  ii.jf.retune( 6, 8, 3 )
  --ii.jf.retune( 1, 12 + scales[public.currentScale][1], 12 )
  --ii.jf.retune( 2, 12 + scales[public.currentScale][3], 12 )
  --ii.jf.retune( 3, 12 + scales[public.currentScale][5], 12 )
  --ii.jf.retune( 4, 12 + scales[public.currentScale][7], 12 )
  --ii.jf.retune( 5, 24 + scales[public.currentScale][2], 12 )
  --ii.jf.retune( 6, 24 + scales[public.currentScale][4], 12 )
end

