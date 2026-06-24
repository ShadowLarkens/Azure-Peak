/datum/custom_hair_ui
	/// Preferences owner that resolves the active entry and preview cache.
	var/datum/preferences/prefs
	/// Customizer identifier used to fetch the current hair entry.
	var/customizer_type
	/// Direction currently shown and edited by the UI.
	var/active_dir = SOUTH
	/// Tracks whether the editor changed data that needs saving when closed.
	var/dirty = FALSE
	/// Cached edit bounds per direction, keyed by preview dir.
	var/list/edit_bands = list()
	/// Whether mask normalization and legacy add-mask folding already ran this session tick.
	var/masks_ready = FALSE
	/// Whether pix_color has already been snapped to the current palette.
	var/pix_ready = FALSE
	/// Cached palette entries for the current palette key.
	var/list/pal_entries
	/// Cached flat list of palette colours derived from pal_entries.
	var/list/pal_colours
	/// Palette fingerprint used to invalidate cached palette-derived state.
	var/pal_key
	/// Cached UI state for the edited/not-edited directional buttons.
	var/list/dir_states
	/// Direction that active_masks currently represents.
	var/masks_dir
	/// Cached active direction payload sent to TGUI for painting.
	var/list/active_masks

/datum/custom_hair_ui/New(datum/preferences/prefdata, kind)
	prefs = prefdata
	customizer_type = kind

/datum/custom_hair_ui/Destroy(force)
	if(prefs?.hair_uis)
		prefs.hair_uis -= "[customizer_type]"
	prefs = null
	customizer_type = null
	edit_bands = null
	pal_entries = null
	pal_colours = null
	dir_states = null
	active_masks = null
	return ..()

// TGUI
/datum/custom_hair_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HairEditor", "Custom Hair")
		ui.open()

/datum/custom_hair_ui/ui_state(mob/user)
	return GLOB.tgui_always_state

/datum/custom_hair_ui/ui_static_data(mob/user)
	var/datum/customizer_entry/hair/hair_entry = prepare_entry(TRUE)
	if(!hair_entry || !hair_entry.accessory_type)
		return list("ready" = FALSE)
	var/list/base_icons = get_icons()
	if(!base_icons)
		return list("ready" = FALSE)
	var/list/direction_icons = list()
	for(var/preview_dir in hair_preview_dirs())
		var/list/edit_band = get_edit_band(preview_dir, base_icons)
		if(!edit_band)
			return list("ready" = FALSE)
		direction_icons += list(list(
			"dir" = preview_dir,
			"label" = hair_dir_label(preview_dir),
			"icon" = (preview_dir == active_dir) ? get_guide_icon(preview_dir, base_icons, user) : null,
			"editMinX" = edit_band["minX"],
			"editMaxX" = edit_band["maxX"],
			"editMinY" = edit_band["minY"],
			"editMaxY" = edit_band["maxY"],
		))
	return list(
		"ready" = TRUE,
		"baseColor" = hair_entry.hair_color,
		"directionIcons" = direction_icons,
	)

/datum/custom_hair_ui/ui_data(mob/user)
	var/datum/customizer_entry/hair/hair_entry = prepare_entry(TRUE)
	if(!hair_entry || !hair_entry.accessory_type)
		return list("ready" = FALSE)
	return list(
		"ready" = TRUE,
		"activeDir" = active_dir,
		"activeLabel" = hair_dir_label(active_dir),
		"baseColor" = hair_entry.hair_color,
		"palette" = get_palette_entries(),
		"paintColor" = hair_entry.pix_color,
		"activeGuideIcon" = get_guide_icon(active_dir, user = user),
		"activeColorMasks" = get_color_masks(active_dir),
		"directions" = get_direction_states(),
	)

/datum/custom_hair_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE
	var/datum/customizer_entry/hair/hair_entry = prepare_entry(TRUE)
	if(!hair_entry)
		return TRUE
	var/dir = text2num(params["dir"])
	if(!hair_dir_valid(dir))
		dir = active_dir
	switch(action)
		if("set_dir")
			active_dir = dir
			return TRUE
		if("set_color")
			hair_entry.pix_color = nearest_palette_colour(params["color"])
			pix_ready = TRUE
			return TRUE
		if("clear")
			hair_clear(hair_entry)
			invalidate_entry_caches()
			prepare_entry(TRUE)
			dirty = TRUE
			return TRUE
		if("plot_commit")
			var/list/base_icons = get_icons()
			if(!base_icons)
				return TRUE
			var/list/edit_band = get_edit_band(dir, base_icons)
			if(!edit_band)
				return TRUE
			var/list/dir_layers = list()
			var/list/color_masks = params["colorMasks"]
			if(islist(color_masks))
				for(var/list/layer in color_masks)
					if(!islist(layer))
						continue
					var/color = nearest_palette_colour(layer["color"])
					var/mask = hairmask_crop_y(layer["mask"], edit_band["minY"], edit_band["maxY"])
					if(!color || !mask)
						continue
					dir_layers += list(list(
						"color" = color,
						"mask" = mask,
					))
			active_dir = dir
			var/list/next_colormasks = hairmask_dir_replace(hair_entry.colormasks, dir, dir_layers)
			if(next_colormasks != hair_entry.colormasks)
				hair_entry.custom_mask_version++
			hair_entry.colormasks = next_colormasks
			hair_entry.rmmasks = null
			invalidate_entry_caches()
			prepare_entry(TRUE)
			dirty = TRUE
			return TRUE
		if("close")
			if(ui)
				ui.close()
			else
				qdel(src)
			return TRUE
	return FALSE

/datum/custom_hair_ui/ui_close(mob/user)
	. = ..()
	if(!prefs || !dirty || !user?.client)
		QDEL_IN(src, 1)
		return
	INVOKE_ASYNC(prefs, TYPE_PROC_REF(/datum/preferences, update_preview), user)
	QDEL_IN(src, 1)

// Helpers
/datum/custom_hair_ui/proc/get_entry()
	if(!prefs)
		return null
	return prefs.get_customizer_entry_for_customizer_type(customizer_type)

/datum/custom_hair_ui/proc/invalidate_entry_caches()
	masks_ready = FALSE
	pix_ready = FALSE
	pal_entries = null
	pal_colours = null
	pal_key = null
	dir_states = null
	masks_dir = null
	active_masks = null

/datum/custom_hair_ui/proc/prepare_entry_masks()
	var/datum/customizer_entry/hair/hair_entry = get_entry()
	if(!hair_entry)
		return null
	if(masks_ready)
		return hair_entry
	hair_entry.colormasks = hair_entry_masks(hair_entry)
	hair_entry.addmasks = null
	hair_entry.rmmasks = null
	masks_ready = TRUE
	return hair_entry

/datum/custom_hair_ui/proc/get_palette_entries()
	var/datum/customizer_entry/hair/hair_entry = get_entry()
	if(!hair_entry)
		return list(list("label" = "Hair", "color" = "#FFFFFF"))
	var/local_key = hair_palette_key(hair_entry)
	if(local_key != pal_key)
		pal_key = local_key
		pal_entries = hair_palette_entries(hair_entry)
		pal_colours = null
		pix_ready = FALSE
	return pal_entries

/datum/custom_hair_ui/proc/get_palette_colours()
	if(!islist(pal_colours))
		var/list/entries = get_palette_entries()
		pal_colours = list()
		for(var/list/entry in entries)
			var/colour = sanitize_hexcolor(entry["color"], 6, TRUE)
			if(colour && !(colour in pal_colours))
				pal_colours += colour
		if(!pal_colours.len)
			pal_colours += "#FFFFFF"
	return pal_colours

/datum/custom_hair_ui/proc/get_direction_states()
	if(islist(dir_states))
		return dir_states
	var/datum/customizer_entry/hair/hair_entry = prepare_entry()
	if(!hair_entry)
		return list()
	dir_states = list()
	for(var/preview_dir in hair_preview_dirs())
		var/edited = !!hairmask_dir_any(hair_entry.colormasks, preview_dir)
		dir_states += list(list(
			"dir" = preview_dir,
			"label" = hair_dir_label(preview_dir),
			"edited" = edited,
		))
	return dir_states

/datum/custom_hair_ui/proc/get_color_masks(preview_dir)
	if(masks_dir == preview_dir && islist(active_masks))
		return active_masks
	var/datum/customizer_entry/hair/hair_entry = prepare_entry()
	if(!hair_entry)
		return list()
	masks_dir = preview_dir
	active_masks = hairmask_dir_data(hair_entry.colormasks, preview_dir) || list()
	return active_masks

/datum/custom_hair_ui/proc/prepare_entry(norm_color = FALSE)
	var/datum/customizer_entry/hair/hair_entry = prepare_entry_masks()
	if(!hair_entry)
		return null
	if(norm_color && !pix_ready)
		hair_entry.pix_color = nearest_palette_colour(hair_entry.pix_color)
		pix_ready = TRUE
	return hair_entry

/datum/custom_hair_ui/proc/nearest_palette_colour(colour)
	var/list/palette = get_palette_colours()
	return hair_nearest_colour(colour, palette)

/datum/custom_hair_ui/proc/get_icons(reuse_cache = TRUE)
	var/datum/customizer_entry/hair/hair_entry = prepare_entry()
	if(!hair_entry || !hair_entry.accessory_type)
		return null
	var/cache_key = hair_cache_key(hair_entry, customizer_type)
	if(!cache_key)
		return null
	return prefs.hair_cache(hair_entry, cache_key, reuse_cache)

/datum/custom_hair_ui/proc/get_guide_icon(preview_dir, list/base_icons = null, mob/user = null)
	if(!hair_dir_valid(preview_dir))
		return null
	if(!base_icons)
		base_icons = get_icons()
	if(!base_icons)
		return null
	var/key = hair_dir_key(preview_dir)
	if(!key)
		return null
	var/url_key = "[key]_url"
	var/asset_key = "[key]_asset"
	if(base_icons[asset_key])
		if(base_icons[url_key])
			if(user?.client)
				SSassets.transport.send_assets(user, base_icons[asset_key])
			return base_icons[url_key]
		var/asset_url = hair_asset_url(base_icons[asset_key], user)
		if(!asset_url)
			return null
		base_icons[url_key] = asset_url
		return asset_url
	queue_guide_icon(preview_dir, base_icons)
	return null

/datum/custom_hair_ui/proc/queue_guide_icon(preview_dir, list/base_icons = null)
	if(!hair_dir_valid(preview_dir))
		return
	if(!base_icons)
		base_icons = get_icons()
	if(!base_icons)
		return
	var/key = hair_dir_key(preview_dir)
	if(!key)
		return
	var/pending_key = "[key]_pending"
	if(base_icons["[key]_asset"] || base_icons[pending_key])
		return
	base_icons[pending_key] = TRUE
	INVOKE_ASYNC(src, PROC_REF(build_guide_icon), preview_dir)

/datum/custom_hair_ui/proc/build_guide_icon(preview_dir)
	var/key = hair_dir_key(preview_dir)
	var/list/base_icons = (hair_dir_valid(preview_dir) && prefs) ? get_icons() : null
	if(!key || !base_icons)
		return
	var/pending_key = "[key]_pending"
	var/asset_key = "[key]_asset"
	var/url_key = "[key]_url"
	if(base_icons[asset_key])
		base_icons -= pending_key
		SStgui.update_uis(src)
		return
	var/datum/customizer_entry/hair/hair_entry = prepare_entry()
	if(!hair_entry)
		base_icons -= pending_key
		return
	hair_entry_prepare(hair_entry)
	var/list/saved_colormasks = hair_entry.colormasks
	var/list/saved_remove = hair_entry.rmmasks
	hair_entry.colormasks = null
	hair_entry.rmmasks = null
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	var/icon/cached_icon
	if(mannequin)
		prefs.copy_to(mannequin, 1, TRUE, TRUE)
		cached_icon = hair_preview_icon(mannequin, preview_dir)
		unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	hair_entry.colormasks = saved_colormasks
	hair_entry.rmmasks = saved_remove
	if(cached_icon)
		base_icons[asset_key] = hair_asset(cached_icon)
		base_icons[url_key] = hair_asset_url(base_icons[asset_key])
	base_icons -= pending_key
	SStgui.update_uis(src)

/datum/custom_hair_ui/proc/get_edit_band(preview_dir, list/base_icons = null)
	if(!hair_dir_valid(preview_dir))
		return null
	var/key = "[preview_dir]"
	var/list/edit_band = edit_bands?[key]
	if(edit_band)
		return edit_band
	if(!base_icons)
		base_icons = get_icons()
	if(!base_icons)
		return null
	edit_band = hair_edit_band(hair_band_cache(base_icons, preview_dir))
	if(!edit_bands)
		edit_bands = list()
	edit_bands[key] = edit_band
	return edit_band
