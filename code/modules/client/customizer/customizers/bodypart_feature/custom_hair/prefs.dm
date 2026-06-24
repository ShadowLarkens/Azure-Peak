/datum/preferences
	var/tmp/list/hairprev_cache = list()
	var/tmp/list/hair_uis = list()

/datum/preferences/proc/clear_hair_cache(customizer_type)
	if(!hairprev_cache)
		return
	var/prefix = "[customizer_type]|"
	var/prefix_end = length(prefix) + 1
	var/list/clear_keys = list()
	for(var/cache_key in hairprev_cache)
		if(cache_key == "[customizer_type]" || findtext("[cache_key]", prefix, 1, prefix_end) == 1)
			clear_keys += cache_key
	for(var/cache_key in clear_keys)
		hairprev_cache -= cache_key

/datum/preferences/proc/hair_cache(datum/customizer_entry/hair/hair_entry, cache_key, reuse_cache)
	var/list/cache = reuse_cache ? hairprev_cache[cache_key] : null
	if(hair_band_cache(cache, SOUTH) && hair_band_cache(cache, WEST) && hair_band_cache(cache, NORTH) && hair_band_cache(cache, EAST))
		return cache
	hair_entry_prepare(hair_entry)
	cache = hair_bands(hair_entry)
	if(!cache)
		return null
	hairprev_cache[cache_key] = cache
	return cache

/datum/preferences/proc/open_hair_editor(mob/user, customizer_type)
	if(!user?.client)
		return
	if(!hair_uis)
		hair_uis = list()
	var/key = "[customizer_type]"
	var/datum/custom_hair_ui/ui = hair_uis[key]
	if(QDELETED(ui))
		hair_uis -= key
		ui = null
	if(!ui)
		ui = new(src, customizer_type)
		hair_uis[key] = ui
	ui.ui_interact(user)

/datum/preferences/proc/refresh_hair_windows(mob/user, current_tab)
	character_preview_view.update_body()
	user?.client?.prefs?.ShowChoices(user)

/datum/customizer_entry/hair
	var/list/colormasks
	var/custom_mask_version = 0
	var/list/addmasks
	var/list/rmmasks
	var/maskjson
	var/addjson
	var/rmjson