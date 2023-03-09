---@diagnostic disable: lowercase-global
local CreateTimeEvent = demonized_time_events.CreateTimeEvent
local RemoveTimeEvent = demonized_time_events.RemoveTimeEvent

function on_game_start()
	RegisterScriptCallback("on_option_change", load_settings)
	RegisterScriptCallback("actor_on_first_update", load_settings)

	RegisterScriptCallback("actor_on_first_update", actor_on_first_update)
	RegisterScriptCallback("actor_on_sleep", actor_on_sleep)
end

local FIRST_LEVEL_WEATHER = ""
local DEBUG_MODE

-- determine debug mode option
function load_settings()
	if not ui_mcm then
		return
	end

	DEBUG_MODE = ui_mcm.get("saturation/DEBUG_MODE")
end

-- put a value for FIRST_LEVEL_WEATHER
function actor_on_first_update()
	if is_fx_weather() or DEBUG_MODE then
		FIRST_LEVEL_WEATHER = ""
	else
		FIRST_LEVEL_WEATHER = get_current_weather()
	end
	RemoveTimeEvent("mcm_dynamic_bloom_and_sunshaft", "mcm_dynamic_bloom_and_sunshaft")
end

-- reset first level weather
function actor_on_sleep()
	CreateTimeEvent("mcm_dynamic_bloom_and_sunshaft", "mcm_dynamic_bloom_and_sunshaft", 3, actor_on_first_update)
end

function on_mcm_load()
	local current_weather = FIRST_LEVEL_WEATHER
	if is_fx_weather() then
		current_weather = get_current_weather()
	end

	op = {
		id = "dynamic_bloom_and_sunshaft",
		sh = true,
		gr = {
			{id = "title", type = "slide", link = "ui_options_slider_player", text = "ui_mcm_dynamic_bloom_and_sunshaft_title", size = {512, 50}, spacing = 20 },

			{id = "visual_weather",
				type = "desc",
				text = "Visual Weather: " .. current_weather
			},
			{id = "engine_weather",
				type = "desc",
				text = "Engine Weather: " .. get_current_weather()
			},

			{id = "DEBUG_MODE", type = "check", val = 1, def = false},

			{id = "MIN_BLOOM",
				type = "track",
				val = 2,
				def = 0.4,
				min = 0.05,
				max = 2,
				step = 0.01
			},
			{id = "BRIGHT_WEATHER_BLOOM",
				type = "track",
				val = 2,
				def = 0.8,
				min = 0.05,
				max = 2,
				step = 0.01
			},
			{id = "SLIGHTLY_BRIGHT_WEATHER_BLOOM",
				type = "track",
				val = 2,
				def = 0.7,
				min = 0.05,
				max = 2,
				step = 0.01
			},
			{id = "DARK_WEATHER_BLOOM",
				type = "track",
				val = 2,
				def = 0.65,
				min = 0.05,
				max = 2,
				step = 0.01
			},
			{id = "FX_WEATHER_BLOOM",
				type = "track",
				val = 2,
				def = 0.7,
				min = 0.05,
				max = 2,
				step = 0.01
			},
			-- {id = "",
			-- 	type = "track",
			-- 	val = 2,
			-- 	def = 0.8,
			-- 	min = 0.05,
			-- 	max = 2,
			-- 	step = 0.01
			-- },
		}
	}
	return op
end

function get_current_weather()
	return level.get_weather()
end

-- determine if weather is psi storm or emission
function is_fx_weather()
	local weather = get_current_weather()
	local weather_set = {
		fx_blowout_day = true,
		fx_blowout_night = true,
		fx_psi_storm_day = true,
		fx_psi_storm_night = true
	}

	if weather_set[weather] then
		return true
	end
	return false
end
