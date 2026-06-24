GLOBAL_LIST_EMPTY(preferences_datums)

GLOBAL_LIST_EMPTY(chosen_names)

/datum/preferences
	var/client/parent
	//doohickeys for savefiles
	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/max_save_slots = 60
	var/loaded_slot = 1

	//non-preference stuff
	var/muted = 0

	//game-preferences
	var/favorited_slots = list()
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/asaycolor = "#ff4500"			//This won't change the color for current admins, only incoming ones.
	// Commend variable on prefs instead of client to prevent reconnect abuse (is persistant on prefs, opposed to not on client)
	var/commendedsomeone = FALSE

	//Antag preferences
	var/list/be_special = list()		//Special role selection

	var/showrolls = TRUE

	// Custom Keybindings
	var/list/key_bindings = list()

	var/tgui_lock = TRUE
	var/tgui_theme = "azure_default"
	var/parchment_skin = "leatherbound"
	var/statbrowser_theme = "dark"
	var/windowflashing = TRUE

	var/toggles = TOGGLES_DEFAULT
	var/ghost_toggles
	var/combat_toggles = TOGGLES_TEXT_DEFAULT
	var/admin_chat_toggles = TOGGLES_DEFAULT_CHAT_ADMIN
	var/db_flags
	var/chat_toggles = TOGGLES_DEFAULT_CHAT

	var/topjob = null

	//character preferences
	var/real_name						//our character's name
	var/gender = MALE					//gender of character (well duh) (LETHALSTONE EDIT: this no longer references anything but whether the masculine or feminine model is used)
	var/pronouns = HE_HIM				// LETHALSTONE EDIT: character's pronouns (well duh)
	var/titles_pref = TITLES_M
	var/clothes_pref = CLOTHES_M
	var/voice_pack = "Default"
	var/voice_type = VOICE_TYPE_MASC	// LETHALSTONE EDIT: the type of soundpack the mob should use
	var/datum/statpack/statpack	= new /datum/statpack/wildcard/fated // LETHALSTONE EDIT: the statpack we're giving our char instead of racial bonuses
	var/datum/virtue/virtue = new /datum/virtue/none // LETHALSTONE EDIT: the virtue we get for not picking a statpack
	var/datum/virtue/virtuetwo = new /datum/virtue/none
	var/datum/virtue/virtue_origin = new /datum/virtue/none
	var/age = AGE_ADULT						//age of character
	var/origin = "Default"
	var/skin_tone = "caucasian1"		//Skin color
	var/vampire_skin = null
	var/vampire_eyes = null
	var/vampire_hair = null
	var/vampire_ears = null
	var/extra_language = "None" // Extra language
	var/voice_color = "a0a0a0"
	var/voice_pitch = 1
	var/datum/species/pref_species = new /datum/species/human/northern()	//Mutant race
	var/static/datum/species/default_species = new /datum/species/human/northern()
	var/datum/patron/selected_patron
	var/static/datum/patron/default_patron = /datum/patron/divine/undivided
	var/list/features = MANDATORY_FEATURE_LIST
	var/list/friendlyGenders = list("male" = "masculine", "female" = "feminine")
	var/shake = TRUE
	var/sexable = FALSE
	var/compliance_notifs = TRUE

	//Job preferences 2.0 - indexed by job title , no key or value implies never
	var/list/job_preferences = list()

		// Want randomjob if preferences already filled - Donkie
	var/joblessrole = RETURNTOLOBBY  //defaults to 1 for fewer assistants

	var/clientfps = 100//0 is sync

	var/ambientocclusion = TRUE
	var/auto_fit_viewport = FALSE

	var/musicvol = 50
	var/lobbymusicvol = 50
	var/ambiencevol = 50
	var/mastervol = 50
	var/stopdroning = FALSE

	var/anonymize = TRUE
	var/masked_examine = FALSE
	var/full_examine = FALSE
	var/mute_animal_emotes = FALSE
	var/autoconsume = FALSE
	var/no_examine_blocks = FALSE
	var/no_autopunctuate = FALSE
	var/no_language_fonts = FALSE
	var/no_language_icon = FALSE
	var/no_redflash = FALSE
	var/no_storyteller_events = FALSE
	var/top_examine = FALSE

	var/list/exp = list()
	var/list/menuoptions

	var/datum/migrant_pref/migrant

	var/domhand = 2
	var/nickname = "Please Change Me"
	var/highlight_color = "#FF0000"
	var/list/charflaws = list()

	var/static/default_cmusic_type = /datum/combat_music/default
	var/datum/combat_music/combat_music
	var/combat_music_helptext_shown = FALSE

	var/crt = FALSE
	var/grain = TRUE
	var/dnr_pref = FALSE
	var/qsr_pref = FALSE

	var/list/customizer_entries = list()
	var/list/list/body_markings = list()

	var/headshot_link
	var/lich_headshot_link
	var/vampire_headshot_link
	var/werewolf_headshot_link //not used but setting up for the future
	var/chatheadshot = FALSE
	var/ooc_extra
	var/song_artist
	var/song_title
	var/list/descriptor_entries = list()
	var/list/custom_descriptors = list()

	var/list/gear_list = list()	// Assoc list: item_name = list("color"=..., "custom_name"=..., "custom_desc"=...)

	var/flavortext
	var/flavortext_cached

	var/ooc_notes
	var/ooc_notes_cached

	var/nsfwflavortext
	var/nsfwflavortext_cached

	var/erpprefs
	var/erpprefs_cached

	var/list/img_gallery = list()
	var/list/nsfw_img_gallery = list()

	var/datum/familiar_prefs/familiar_prefs

	var/taur_type = null
	var/taur_color = "ffffff"

	/// Assoc list of culinary preferences, where the key is the type of the culinary preference, and value is food/drink typepath
	var/list/culinary_preferences = list()


	var/tgui_pref = TRUE

	var/race_bonus

	var/preset_bounty_enabled = FALSE
	var/preset_bounty_poster_key
	var/preset_bounty_severity_key
	var/preset_bounty_severity_b_key
	var/preset_bounty_severity_v_key
	var/preset_bounty_crime

	var/rumour
	var/noble_gossip

	var/averse_chosen_faction = "Inquisition"

	var/attack_blip_frequency = ATTACK_BLIP_PREF_DEFAULT

	/// Per-character theme override for examine panel viewers
	var/examine_theme

	// Vocal bark prefs
	var/bark_id = "mutedc3"
	var/bark_speed = 4
	var/bark_pitch = 1
	var/bark_variance = 0.2
	COOLDOWN_DECLARE(bark_previewing)
	var/mute_barks = FALSE

/datum/preferences/New(client/C)
	parent = C
	migrant  = new /datum/migrant_pref(src)
	familiar_prefs = new /datum/familiar_prefs(src)

	if(istype(C))
		if(!IsGuestKey(C.key))
			load_path(C.ckey)
			if(C.IsByondMember())
				max_save_slots = 100
	var/loaded_preferences_successfully = load_preferences()
	if(loaded_preferences_successfully)
		if(load_character())
			return

	//Set the race to properly run race setter logic
	set_new_race(pref_species, null)
	virtue_origin = new pref_species.origin_default

	// Charflaws
	if(!charflaws.len)
		var/list/cf_choices = list()
		for(var/i = 1 to MAX_VICES)
			cf_choices.Add(i)
		var/num_vices = pick(cf_choices)
		var/list/available = GLOB.character_flaws.Copy()

		for(var/key in available)
			if(available[key] == /datum/charflaw/noflaw)
				available.Remove(key)
				break
		for(var/j = 1 to num_vices)
			if(!available.len)
				break
			var/sel = pick(available)
			var/flaw_type = available[sel]
			available.Remove(sel)
			var/datum/charflaw/cf = new flaw_type()
			charflaws.Add(cf)

		if(!charflaws.len)
			var/datum/charflaw/no_flaw = new /datum/charflaw/noflaw()
			charflaws.Add(no_flaw)
	if(!selected_patron)
		selected_patron = GLOB.patronlist[default_patron]
	if(!combat_music)
		combat_music = GLOB.cmode_tracks_by_type[default_cmusic_type]
	key_bindings = deepCopyList(GLOB.hotkey_keybinding_list_by_key) // give them default keybinds and update their movement keys
	C.update_movement_keys()
	if(!loaded_preferences_successfully)
		save_preferences()
	save_character()		//let's save this new random character so it doesn't keep generating new ones.
	menuoptions = list()
	return

/datum/preferences/proc/set_new_race(datum/species/new_race, user)
	pref_species = new_race
	real_name = pref_species.random_name(gender,1)
	ResetJobs()
	if(user)
		if(pref_species.desc)
			var/langs = length(pref_species.languages)
			var/bonus_languages = langs > 1 ? span_info("<br>Racial Language[langs > 2 ? "s" : ""]: [pref_species.get_string_languages()]") : null
			var/bonus_stats = span_racialstatinfo(pref_species.get_string_bonus_stats())
			var/traits_list = pref_species.get_string_bonus_traits()
			var/bonus_traits = traits_list && length(traits_list) ? "<br>" + span_smallracialstatinfo(traits_list) : null
			var/mechanics = pref_species.mechanics_explanations ? span_info(pref_species.get_string_mechanics_explanations()) : null
			var/description2print  = fieldset_block(span_big("<b>[span_bignotice(pref_species.desc_title)]</b>"), "[pref_species.desc]<br><hr>[bonus_stats][bonus_languages][bonus_traits][mechanics]", "speciesdesc_block")
			to_chat(user, description2print)
		to_chat(user, span_red("Classes reset."))
	random_character(gender, FALSE, FALSE)

	customizer_entries = list()
	validate_customizer_entries()
	reset_all_customizer_accessory_colors()
	randomize_all_customizer_accessories()
	reset_descriptors()
	virtue_origin = new pref_species.origin_default
	taur_type = null
	var/datum/charflaw/no_flaw = new /datum/charflaw/noflaw()
	charflaws = list(no_flaw)

//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override, antag_override = FALSE, ft_reset = TRUE)
	if(!pref_species)
		random_species()
	real_name = pref_species.random_name(gender,1)
	if(gender_override)
		gender = gender_override
	else
		gender = pick(MALE,FEMALE)
	age = AGE_ADULT
	var/list/skins = pref_species.get_skin_list()
	skin_tone = skins[pick(skins)]
	if(ft_reset)
		flavortext = null
		nsfwflavortext = null
		erpprefs = null
		ooc_notes = null
		ooc_extra = null
		song_title = null
		song_artist = null
		headshot_link = null
		img_gallery = null
		nsfw_img_gallery = null
	features = pref_species.get_random_features()
	body_markings = pref_species.get_random_body_markings(features)
	reset_all_customizer_accessory_colors()
	randomize_all_customizer_accessories()

/datum/preferences/proc/random_species()
	var/random_species_type = GLOB.species_list[pick(get_selectable_species())]
	pref_species = new random_species_type
	set_new_race(new random_species_type)

/datum/preferences/proc/spec_check(mob/user)
	if(!istype(pref_species))
		return FALSE
	if(!(pref_species.name in get_selectable_species()))
		return FALSE
	if(!pref_species.check_roundstart_eligible())
		return FALSE
	if(user && (pref_species.patreon_req > user.client?.patreonlevel()))
		return FALSE
	return TRUE

/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(href_list["preference"] == "keybindings_set")
		KeybindingSet(
			user,
			href_list["keybinding"],
			text2num(href_list["clear_key"]),
			href_list["old_key"],
			href_list["key"],
			text2num(href_list["alt"]),
			text2num(href_list["ctrl"]),
			text2num(href_list["shift"]),
			text2num(href_list["numpad"])
		)
		return TRUE

	if(href_list["task"] == "change_culinary_preferences")
		handle_culinary_topic(user, href_list)
		show_culinary_ui(user)
		return

/// Does the actual reset
/datum/preferences/proc/force_reset_keybindings_direct()
	var/list/oldkeys = key_bindings
	key_bindings = deepCopyList(GLOB.hotkey_keybinding_list_by_key)

	for(var/key in oldkeys)
		if(!key_bindings[key])
			key_bindings[key] = oldkeys[key]
	parent?.ensure_keys_set(src)

/datum/preferences/proc/is_active_migrant()
	if(!migrant)
		return FALSE
	if(!migrant.queued_wave)
		return FALSE
	return TRUE
