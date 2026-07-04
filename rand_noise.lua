--- rand_noise
-- in1: CV sets how often out1 & out2 pick new random voltages (higher CV -> faster)
-- in2: CV sets lowpass cutoff applied to the pink noise on out4 (higher CV -> brighter)
-- out1, out2: independent random voltages in [-5, 5] V, updated together at the in1 rate
-- out3: white noise (~full-rate steps)
-- out4: approximate pink noise (Kellet filter) + one-pole smoothing at in2 cutoff

local AMP = 5

-- noise output sample rate (Hz); crow metronome limit ~1 ms typical
local NOISE_FS = 1000
local NOISE_DT = 1 / NOISE_FS

-- random-hold period bounds (seconds)
local RAND_P_MIN = 0.01
local RAND_P_MAX = 4.0

-- pink noise LP cutoff range (Hz) from in2
local FC_MIN = 0.4
local FC_MAX = 600

local rand_period = 0.25
local fc_hz = 40

-- Paul Kellet "economical" pink filter state
local pk = { b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0 }
local pink_lp = 0

local function lp_alpha(fc, fs)
  fc = math.max(FC_MIN * 0.25, math.min(fc, fs * 0.45))
  return 1 - math.exp(-(2 * math.pi * fc) / fs)
end

local function pink_sample()
  local white = math.random() * 2 - 1
  pk.b0 = 0.99886 * pk.b0 + white * 0.0555179
  pk.b1 = 0.99332 * pk.b1 + white * 0.0750759
  pk.b2 = 0.96900 * pk.b2 + white * 0.1538520
  pk.b3 = 0.86650 * pk.b3 + white * 0.3104856
  pk.b4 = 0.55000 * pk.b4 + white * 0.5329522
  pk.b5 = -0.7616 * pk.b5 - white * 0.0168980
  local sum = pk.b0 + pk.b1 + pk.b2 + pk.b3 + pk.b4 + pk.b5 + pk.b6 + white * 0.5362
  pk.b6 = white * 0.115926
  return sum * 0.11
end

local function noise_tick()
  output[3].volts = (math.random() * 2 - 1) * AMP
  local raw = pink_sample() * AMP
  local a = lp_alpha(fc_hz, NOISE_FS)
  pink_lp = pink_lp + a * (raw - pink_lp)
  output[4].volts = pink_lp
end

local function period_from_cv(volts)
  volts = math.max(-5, math.min(10, volts))
  local u = (volts + 5) / 15
  return RAND_P_MAX * (RAND_P_MIN / RAND_P_MAX) ^ u
end

local function cutoff_from_cv(volts)
  volts = math.max(-5, math.min(10, volts))
  local u = (volts + 5) / 15
  return FC_MIN * (FC_MAX / FC_MIN) ^ u
end

local function random_hold_loop()
  while true do
    local p = rand_period
    output[1].volts = (math.random() * 2 - 1) * AMP
    output[2].volts = (math.random() * 2 - 1) * AMP
    clock.sleep(p)
  end
end

function init()
  for n = 1, 4 do
    output[n].slew = 0
  end

  rand_period = period_from_cv(input[1].volts)
  fc_hz = cutoff_from_cv(input[2].volts)

  input[1].mode('stream', 0.01)
  input[1].stream = function(v)
    rand_period = period_from_cv(v)
  end

  input[2].mode('stream', 0.01)
  input[2].stream = function(v)
    fc_hz = cutoff_from_cv(v)
  end

  metro[1].event = noise_tick
  metro[1].time = NOISE_DT
  metro[1]:start()

  clock.run(random_hold_loop)
end
