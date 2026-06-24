/datum/preferences
	/// A preview of the current character
	var/atom/movable/screen/map_view/char_preview/character_preview_view

/datum/preferences/proc/create_character_preview_view(mob/user)
	character_preview_view = new(null, src)
	character_preview_view.generate_view("character_preview_[REF(character_preview_view)]")
	character_preview_view.update_body()
	return character_preview_view

/datum/preferences/proc/render_new_preview_appearance(mob/living/carbon/human/dummy/mannequin)
	copy_to(mannequin, 1, TRUE, TRUE)
	return mannequin.appearance

/datum/preferences/proc/update_preview(mob/user)
	character_preview_view?.update_body()
	SStgui.try_update_ui(user, src)


/// A preview of a character for use in the preferences menu
/atom/movable/screen/map_view/char_preview
	name = "character_preview"

	/// The body that is displayed
	var/mob/living/carbon/human/dummy/body
	/// The preferences this refers to
	var/datum/preferences/preferences

	var/atom/movable/screen/background/preview_background

/atom/movable/screen/map_view/char_preview/Initialize(mapload, datum/preferences/preferences)
	. = ..()
	src.preferences = preferences

/atom/movable/screen/map_view/char_preview/generate_view(map_key)
	. = ..()
	preview_background = new
	preview_background.del_on_map_removal = FALSE
	preview_background.assigned_map = assigned_map
	preview_background.icon_state = "scanline3"

/atom/movable/screen/map_view/char_preview/display_to_client(client/show_to)
	show_to.register_map_obj(preview_background)
	. = ..()

/atom/movable/screen/map_view/char_preview/Destroy()
	QDEL_NULL(body)
	QDEL_NULL(preview_background)
	preferences?.character_preview_view = null
	preferences = null
	return ..()

/// Updates the currently displayed body
/atom/movable/screen/map_view/char_preview/proc/update_body()
	if(isnull(body))
		create_body()
	else
		body.wipe_state()

	appearance = preferences.render_new_preview_appearance(body)

	var/body_size = ROUND_UP(body.dna.current_body_size - 0.1) // arbitrarily chosen wiggle room 
	preview_background.fill_rect(1, 1, body_size, body_size)
	set_position((body_size + 1) / 2, 1)

/atom/movable/screen/map_view/char_preview/proc/create_body()
	QDEL_NULL(body)
	body = new
