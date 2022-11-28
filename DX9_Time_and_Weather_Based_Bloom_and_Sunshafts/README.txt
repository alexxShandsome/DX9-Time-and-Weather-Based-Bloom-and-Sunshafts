This addon has two types of bloom implementation:
	* Static
		- The early, older, unmaintained, and outdated bloom implementation of this addon
		- The bloom is consistent and doesn't dynamically change depending on the time
		- The bloom starts at 6AM and ends at 20PM
	* Dynamic
		- 24 hour bloom implementation (0AM - 23PM)
		- The bloom dynamically changes depending on the time

I recommend it to be used alongside with:
	* TheMrDemonized's "Michikos Weather Revamp Revised"
		- I based this addon to this weather presets
	* TheMrDemonized's "Dynamic Time-based Tonemap Extended"

This addon modifies these values in your user.ltx, so BACK-UP your user.ltx before using
this addon
	* r2_ls_bloom_fast
	* r2_ls_bloom_kernel_g
	* r2_ls_bloom_threshold
	* r2_ls_bloom_kernel_scale
	* r2_sunshafts_mode

I recommend to change the value of these settings inside the user.ltx or through the
console
	* r2_sunshafts_min 0.3
	* r2_sunshafts_quality st_opt_low
	* r2_sunshafts_value 0.8
	* r2_ss_sunshafts_length 1.5
	* r2_ss_sunshafts_radius 0.5
	* r2_gloss_factor 1.5
	* r2_gloss_min 0.1
	* r2_tonemap on (if you are planning to use Dynamic Time-based Tonemap Extended)
	* r__color_grading 1,1,0 (for yellowish atmosphere)

How to configure the Dynamic Bloom to your liking (sorry no MCM support yet)
- if anyone can make a MCM support for this addon, I will gladly accept it.
- open the script "dx9_dynamic_bloom_and_sunshaft.script" and find these variables near
  the beginning of the script, each of them has an initial values already as defaults.
	> Time Section:
		MIN_MORNING_TIME_HOUR
			- The time when the bloom will start to generate, 0 is default so that the bloom
			  will simulate as the existence of the sun
		PEAK_TIME_HOUR
			- The time when the bloom will reach it's max intensity or a weather's
			  corresponding LS_BLOOM_KERNEL_SCALE
		MAX_EVENING_TIME_HOUR
			- The time when will the bloom will end 23 by default in order to simulate the
			  earth's revolution around the sun
		CLOUDY_BLOOM_TIME_START
			- The time when will the bloom will start for cloudy weathers to have a good
			  bloom for sunset
		CLOUDY_BLOOM_TIME_PEAK
			- The time when will the cloudy weather bloom will reach its max intensity
			  or the CLOUDY_WEATHER_LS_BLOOM_KERNEL_SCALE
		CLOUDY_BLOOM_TIME_END
			- The time when will the bloom for cloudy weather will end

	> Bloom Section:
		MIN_LS_BLOOM_KERNEL_SCALE
			- The minimum amount the bloom will go the lowest is 0.05
		BRIGHT_WEATHER_LS_BLOOM_KERNEL_SCALE
			- The maximum bloom the bright weathers can go when time reached the value of
			  PEAK_TIME_HOUR
		SLIGHTLY_BRIGHT_WEATHER_LS_BLOOM_KERNEL_SCALE
			- The maximum bloom for the slightly bright weathers can go when time reached the
			  value of PEAK_TIME_HOUR
		CLOUDY_WEATHER_LS_BLOOM_KERNEL_SCALE
			- The maximum bloom for the cloudy weathers can go when time reached the value
			  of CLOUDY_BLOOM_TIME_PEAK
		BLOWOUT_LS_BLOOM_KERNEL_SCALE
			- The constant bloom when blowout and psi storm is going to happen and is
			  currently happening
