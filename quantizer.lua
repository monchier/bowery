--- quantizer
-- sam wolk 2019.10.15
-- updated by whimsicalraps 2021
-- in1: clock
-- in2: voltage to quantize
-- out1: in2 quantized to scale1 on clock pulses
-- out2: in2 quantized to scale2 on clock pulses
-- out3: in2 quantized to scale3 continuously
-- out4: trigger pulses when out3 changes

snum = {'octave','chroma','major','harMin','dorian','dorianflat5', 'majTri','dom7th','wholet'}

interval = 0

scales =
{ octave = {0}
, chroma = {} -- this is a shortcut
, major  = {0,2,4,5,7,9,11}
, harMin = {0,2,3,5,7,8,10}
, dorian = {0,2,3,5,7,9,10}
, dorianflat5 = {0,2,3,5,6,9,10}
, majTri = {0,4,7}
, dom7th = {0,4,7,10}
, wholet = {0,2,4,6,8,10}
, none = "none"
}

progression = {'dorian', 'dorianflat5', 'chroma', 'chroma', 'none', 'none'}
currentProgression = 1

ii.crow[1].event = function(e, value)
  if e.name == 'output' and e.device == 1 then
    if e.arg == 1 then
      print('event1', e.name, e.device, value)
      --for k,v in pairs(e) do
      --  print(k.." = "..v)
      --end
      interval = value
    elseif e.arg == 2 then
      --print('event2', e.name, e.device, value)
      --for k,v in pairs(e) do
      --  print(k.." = "..v)
      --end
      currentProgression = math.fmod(math.tointeger(math.floor(value * 12 + 0.05)), #progression) + 1
      print('rescaling', currentProgression, progression[currentProgression])
      output[1].scale(scales[progression[currentProgression]])
    end
  end
end

-- ii.crow[1].call2 = function(cmd, arg)
--   print('debug', cmd, arg)
--   if e.cmd == 0 then
--     print('debug..', cmd, arg)
--     -- interval = arg
--   end
-- end

-- update clocked outputs
input[1].change = function(state)
  print('interval: ', interval)
  ii.crow[1].get('output', 1)
  ii.crow[1].get('output', 2)
  output[1].volts = input[2].volts + interval
end

function init()
  input[1].mode('change',1,0.1,'rising')
  output[1].scale(scales[progression[currentProgression]])
  ii.crow[1].get('output', 1)
  ii.crow[1].get('output', 2)
end

