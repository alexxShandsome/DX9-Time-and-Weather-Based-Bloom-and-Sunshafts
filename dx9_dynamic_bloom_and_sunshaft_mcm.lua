function on_mcm_load()
	op = {
		id = "dynamic_bloom_and_sunshaft",
		sh = true,
		gr = {
			{id = "title", type = "slide", link = "ui_options_slider_player", text = "ui_mcm_dynamic_bloom_and_sunshaft_title", size = {512, 50}, spacing = 20 },
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
