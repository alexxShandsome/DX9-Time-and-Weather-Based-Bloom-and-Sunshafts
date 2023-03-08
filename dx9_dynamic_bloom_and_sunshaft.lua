---@diagnostic disable: lowercase-global
-- latest changes:
-- Added a DEBUG_MODE option

local CreateTimeEvent = demonized_time_events.CreateTimeEvent
local RemoveTimeEvent = demonized_time_events.RemoveTimeEvent

-- change the value to "true" if you are using the debug mode especially the weather
-- editor
local DEBUG_MODE

-- safety variables
local LS_BLOOM_FAST_OFF = "r2_ls_bloom_fast off"
local DEFAULT_LS_BLOOM_KERNEL_G = "r2_ls_bloom_kernel_g 7"

-- switches to enable or disable sunshafts
local SUNSHAFTS_OFF = "r2_sunshafts_mode off"
local SUNSHAFTS_SCREEN_SPACE = "r2_sunshafts_mode screen_space"

-- switches to enable or disable bloom
local TURN_OFF_LS_BLOOM_THRESHOLD = "r2_ls_bloom_threshold 1"
local TURN_ON_LS_BLOOM_THRESHOLD = "r2_ls_bloom_threshold 0"

-- kernel scales, bloom kernel scale presets depending on the weather category
-- r2_ls_bloom_kernel_scale scale is [0.05 - 2]
-- weather kernel scale presets should not be less than MIN_LS_BLOOM_KERNEL_SCALE
local MIN_LS_BLOOM_KERNEL_SCALE = 0.4								-- 0.4 by default

local SLIGHTLY_BRIGHT_WEATHER_LS_BLOOM_KERNEL_SCALE = 0.7	-- 0.7 by default
local SLIGHTLY_BRIGHT_WEATHER = {
	w_foggy1 = true,
	w_foggy2 = true,
	w_partly1 = true,
	w_rain3 = true
}

local BRIGHT_WEATHER_LS_BLOOM_KERNEL_SCALE = 0.8				-- 0.8 by default
local BRIGHT_WEATHER = {
	["[default]"] = true,
	w_clear1 = true,
	w_clear2 = true,
	w_partly2 = true,
}

local DARK_WEATHER_LS_BLOOM_KERNEL_SCALE = 0.65				-- 0.65 by default
local DARK_WEATHER = {
	w_rain1 = true,
	w_rain2 = true,
	w_cloudy1 = true,
	w_cloudy2_dark = true,
	w_storm1 = true,
	w_storm2 = true,
}

local FX_WEATHER_LS_BLOOM_KERNEL_SCALE = 0.7							-- 0.7 by default
local FX_WEATHER = {
	fx_blowout_day = true,
	fx_blowout_night = true,
	fx_psi_storm_day = true,
	fx_psi_storm_night = true,
}

--- time stuff ---
local FRACTIONAL_TIME = 0

-- trying to simulate bloom to the existence of the sun
-- time when the bloom will start to generate
local MIN_MORNING_TIME_HOUR = 0
-- time when the bloom will reach its max intensity
local PEAK_TIME_HOUR = 12
-- time when the bloom will stop to generate
local MAX_EVENING_TIME_HOUR = 23

-- time when the bloom will start for cloudy weather
-- local CLOUDY_BLOOM_TIME_START = 15
-- time when the bloom will peak for cloudy weather (kinda perfect for sunset)
-- local CLOUDY_BLOOM_TIME_PEAK = 19
-- time when the bloom will end for cloudy weather
-- local CLOUDY_BLOOM_TIME_END = 23
--- time stuff ---

function on_game_start()
	-- MCM stuff
	RegisterScriptCallback("on_option_change", load_settings)
	RegisterScriptCallback("actor_on_first_update", load_settings)
	-- MCM stuff

	RegisterScriptCallback("actor_on_first_update", actor_on_first_update)
	RegisterScriptCallback("actor_on_update", actor_on_update)
	RegisterScriptCallback("actor_on_sleep", actor_on_sleep)
	RegisterScriptCallback("on_key_release", on_key_release)
end

function load_settings()
	if ui_mcm then
		MIN_LS_BLOOM_KERNEL_SCALE = ui_mcm.get("dynamic_bloom_and_sunshaft/MIN_BLOOM")
		BRIGHT_WEATHER_LS_BLOOM_KERNEL_SCALE = ui_mcm.get("dynamic_bloom_and_sunshaft/BRIGHT_WEATHER_BLOOM")
		SLIGHTLY_BRIGHT_WEATHER_LS_BLOOM_KERNEL_SCALE = ui_mcm.get("dynamic_bloom_and_sunshaft/SLIGHTLY_BRIGHT_WEATHER_BLOOM")
		DARK_WEATHER_LS_BLOOM_KERNEL_SCALE = ui_mcm.get("dynamic_bloom_and_sunshaft/DARK_WEATHER_BLOOM")
		FX_WEATHER_LS_BLOOM_KERNEL_SCALE = ui_mcm.get("dynamic_bloom_and_sunshaft/FX_WEATHER_BLOOM")
		DEBUG_MODE = ui_mcm.get("dynamic_bloom_and_sunshaft/DEBUG_MODE")
	end
end

local FIRST_LEVEL_WEATHER = nil
function actor_on_first_update()
	if is_fx_weather() or DEBUG_MODE then
		FIRST_LEVEL_WEATHER = nil
	else
		FIRST_LEVEL_WEATHER = get_current_weather_file()
	end
	RemoveTimeEvent("reset_bloom_first_weather", "reset_bloom_first_weather")
end

function actor_on_update()
	-- Initial Values
	get_console():execute(LS_BLOOM_FAST_OFF)
	get_console():execute(DEFAULT_LS_BLOOM_KERNEL_G)
	get_console():execute(SUNSHAFTS_OFF)
	get_console():execute(TURN_OFF_LS_BLOOM_THRESHOLD)
	get_console():execute("r2_ls_bloom_kernel_scale " .. SLIGHTLY_BRIGHT_WEATHER_LS_BLOOM_KERNEL_SCALE)

	-- Emission and Psi Storm preset
	if is_fx_weather() then
		get_console():execute(SUNSHAFTS_OFF)
		get_console():execute(TURN_ON_LS_BLOOM_THRESHOLD)
		get_console():execute("r2_ls_bloom_kernel_scale " .. FX_WEATHER_LS_BLOOM_KERNEL_SCALE)
	end

	FRACTIONAL_TIME = get_fractional_time()

	-- the sun will start at 6 and will stop at 21
	if FRACTIONAL_TIME >= 6 and FRACTIONAL_TIME < 21 then
		generate_sunshafts()
	end

	-- generate bloom within MIN_MORNING_TIME_HOUR and MAX_EVENING_TIME_HOUR
	if FRACTIONAL_TIME >= MIN_MORNING_TIME_HOUR and
		FRACTIONAL_TIME <= MAX_EVENING_TIME_HOUR then
		generate_bloom()
	end
end

function generate_bloom()
	if is_fx_weather() then
		return
	end

	local current_weather = FIRST_LEVEL_WEATHER or get_current_weather_file()

	-- get bloom multiplier depending on the time
	-- local bloom_multiplier = get_bloom_multiplier()
	local bloom_threshold = TURN_OFF_LS_BLOOM_THRESHOLD
	local bloom_kernel_scale = SLIGHTLY_BRIGHT_WEATHER_LS_BLOOM_KERNEL_SCALE

	-- to exclude underground levels
	if BRIGHT_WEATHER[current_weather] or SLIGHTLY_BRIGHT_WEATHER[current_weather] or
		DARK_WEATHER[current_weather] then
		bloom_threshold = TURN_ON_LS_BLOOM_THRESHOLD
	end

	get_console():execute(bloom_threshold)

	bloom_kernel_scale = get_bloom_kernel_scale()
	get_console():execute("r2_ls_bloom_kernel_scale " .. bloom_kernel_scale)
end

function get_bloom_kernel_scale()
	local timeset_normalize = 0
	local current_weather = FIRST_LEVEL_WEATHER or get_current_weather_file()

	-- generate morning bloom kernel scale
	if FRACTIONAL_TIME >= MIN_MORNING_TIME_HOUR and
		FRACTIONAL_TIME <= PEAK_TIME_HOUR then
		timeset_normalize = normalize(FRACTIONAL_TIME, MIN_MORNING_TIME_HOUR, PEAK_TIME_HOUR)
		if BRIGHT_WEATHER[current_weather] then
			return denormalize(timeset_normalize, MIN_LS_BLOOM_KERNEL_SCALE, BRIGHT_WEATHER_LS_BLOOM_KERNEL_SCALE)
		end
		if SLIGHTLY_BRIGHT_WEATHER[current_weather] then
			return denormalize(timeset_normalize, MIN_LS_BLOOM_KERNEL_SCALE, SLIGHTLY_BRIGHT_WEATHER_LS_BLOOM_KERNEL_SCALE)
		end
		if DARK_WEATHER[current_weather] then
			return denormalize(timeset_normalize, MIN_LS_BLOOM_KERNEL_SCALE, DARK_WEATHER_LS_BLOOM_KERNEL_SCALE)
		end
	end

	-- generate afternoon bloom kernel scale
	if FRACTIONAL_TIME > PEAK_TIME_HOUR and
		FRACTIONAL_TIME <= MAX_EVENING_TIME_HOUR then
		timeset_normalize = normalize(FRACTIONAL_TIME, PEAK_TIME_HOUR, MAX_EVENING_TIME_HOUR)
		if BRIGHT_WEATHER[current_weather] then
			return denormalize(timeset_normalize, BRIGHT_WEATHER_LS_BLOOM_KERNEL_SCALE, MIN_LS_BLOOM_KERNEL_SCALE)
		end
		if SLIGHTLY_BRIGHT_WEATHER[current_weather] then
			return denormalize(timeset_normalize, SLIGHTLY_BRIGHT_WEATHER_LS_BLOOM_KERNEL_SCALE, MIN_LS_BLOOM_KERNEL_SCALE)
		end
		if DARK_WEATHER[current_weather] then
			return denormalize(timeset_normalize, DARK_WEATHER_LS_BLOOM_KERNEL_SCALE, MIN_LS_BLOOM_KERNEL_SCALE)
		end
	end

	-- to avoid crashing when going to sleep
	return MIN_LS_BLOOM_KERNEL_SCALE
end

function generate_sunshafts()
	if is_fx_weather() then
		return
	end

	local current_weather = FIRST_LEVEL_WEATHER or get_current_weather_file()

	if BRIGHT_WEATHER[current_weather] or SLIGHTLY_BRIGHT_WEATHER[current_weather] then
		get_console():execute(SUNSHAFTS_SCREEN_SPACE)
	end
end

function is_fx_weather()
	local weather = get_current_weather_file()

	if FX_WEATHER[weather] then
		return true
	end
	return false
end

-- converts time to decimal equivalent
function get_fractional_time()
	return level.get_time_hours() + normalize(level.get_time_minutes(), 0, 59)
end

function get_current_weather_file()
	return level.get_weather()
end

-- determine the percentage of a value within two points
function normalize(val, min, max)
	return (val - min) / (max - min)
end

function denormalize(val, min, max)
	return val * (max - min) + min
end

-- I don't know how it's not working sometimes
function actor_on_sleep()
	-- reset_first_weather()
	CreateTimeEvent("reset_bloom_first_weather", "reset_bloom_first_weather", 3, actor_on_first_update)
end

-- for debugging purposes press 9
function on_key_release(key)
	if key == DIK_keys["DIK_9"] then
		utils_data.debug_write("----- dx9_dynamic_bloom_and_sunshaft.script debug section -----")
		utils_data.debug_write("get_current_weather_file() " .. get_current_weather_file())
		printf("FIRST_LEVEL_WEATHER %s", FIRST_LEVEL_WEATHER)
		utils_data.debug_write("FRACTIONAL_TIME " .. FRACTIONAL_TIME)
		utils_data.debug_write("Bloom Kernel Scale " .. get_bloom_kernel_scale())

		local weather = FIRST_LEVEL_WEATHER or get_current_weather_file()

		if BRIGHT_WEATHER[weather] then
			utils_data.debug_write("BRIGHT_WEATHER is TRUE")
		else
			utils_data.debug_write("BRIGHT_WEATHER is FALSE")
		end

		if SLIGHTLY_BRIGHT_WEATHER[weather] then
			utils_data.debug_write("SLIGHTLY_BRIGHT_WEATHER is TRUE")
		else
			utils_data.debug_write("SLIGHTLY_BRIGHT_WEATHER is FALSE")
		end

		if DARK_WEATHER[weather] then
			utils_data.debug_write("DARK_WEATHER is TRUE")
		else
			utils_data.debug_write("DARK_WEATHER is TRUE")
		end

		if is_fx_weather() then
			utils_data.debug_write("is_fx_weather() is TRUE")
		else
			utils_data.debug_write("is_fx_weather() is FALSE")
		end
	end
end
