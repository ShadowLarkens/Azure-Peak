/// Get the currently used voicepack accounting for species and prefs
/datum/preferences/proc/get_effective_voicepack()
	if(voice_pack != "Default")
		var/datum/voicepack/VP = GLOB.voice_packs[GLOB.voice_packs_list[voice_pack]]
		return VP

	var/datum/voicepack/VP
	if(gender == FEMALE && pref_species.soundpack_f)
		VP = pref_species.soundpack_f
	else if(pref_species.soundpack_m)
		VP = pref_species.soundpack_m
	if(voice_type)
		switch(voice_type)
			if(VOICE_TYPE_MASC)
				VP = pref_species.soundpack_m
			else
				if(pref_species.soundpack_f)
					VP = pref_species.soundpack_f
				else
					VP = pref_species.soundpack_m

	if(!VP)
		VP = GLOB.voice_packs[/datum/voicepack/male]

	return VP

/// This closes all of the possible subwindows we might have opened
/datum/preferences/proc/close_subwindows(mob/user)
	if(!user?.client)
		return

	user << browse(null, "window=mob_occupation")
	user << browse(null, "window=familiar_prefs")
	user << browse(null, "window=culinary_customization")
	user << browse(null, "window=playerquality")
	user << browse(null, "window=triumph_leaderboard")
	user << browse(null, "window=classhelp")
	user << browse(null, "window=capturekeypress")

	for(var/datum/tgui/ui in user.tgui_open_uis)
		if(istype(ui.src_object, /datum/loadout_menu))
			ui.close()

	migrant.hide_ui()
	SStriumphs.remove_triumph_buy_menu(user.client)

// TODO: this should be done in sanitizing prefs and when the prefs are changed, not in the damn UI data creation
/datum/preferences/proc/clean_virtues()
	if(!virtue)
		virtue = GLOB.virtues[/datum/virtue/none]
	if(!virtuetwo)
		virtuetwo = GLOB.virtues[/datum/virtue/none]

	if(LAZYLEN(pref_species.restricted_virtues))
		if(virtue.type in pref_species.restricted_virtues)
			virtue = GLOB.virtues[/datum/virtue/none]
		if(virtuetwo.type in pref_species.restricted_virtues)
			virtuetwo = GLOB.virtues[/datum/virtue/none]

	if(istype(virtue, virtuetwo) && !virtue.stackable)
		virtuetwo = GLOB.virtues[/datum/virtue/none]
	if(virtue.virtuous_only && !statpack.virtuous)
		virtue = GLOB.virtues[/datum/virtue/none]