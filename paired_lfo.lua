--- paired_lfo
-- two sine LFOs: slower output has exactly twice the period of the faster one
-- in1: CV sets base rate (higher voltage -> shorter period / higher frequency)
-- out1: period T
-- out2: period 2*T
-- on each script load, both LFOs start with a random phase (uniform within one cycle)

local AMP = 5
local SHAPE = 'sine'

-- stream poll interval (seconds)
local STREAM_DT = 0.01

-- map in1 volts (crow range roughly -5..10 V) to fast-LFO period T in seconds
local T_MIN = 0.15
local T_MAX = 24.0

local function base_period(volts)
  volts = math.max(-5, math.min(10, volts))
  local u = (volts + 5) / 15
  -- u=0 -> slow (T_MAX), u=1 -> fast (T_MIN)
  return T_MAX * (T_MIN / T_MAX) ^ u
end

function update_from_input(v)
  local T = base_period(v)
  output[1].dyn.time = T
  output[2].dyn.time = 2 * T
end

function init()
  input[1].mode('stream', STREAM_DT)
  input[1].stream = update_from_input

  local T0 = base_period(input[1].volts)
  output[1].action = lfo(dyn{time = T0}, AMP, SHAPE)
  output[2].action = lfo(dyn{time = 2 * T0}, AMP, SHAPE)

  -- random phase: defer start by a random fraction of one full cycle each
  delay(function() output[1]() end, math.random() * T0)
  delay(function() output[2]() end, math.random() * 2 * T0)
end
