// gender_override forces gender to stay the same
// new_character indicates whether or not to treat this like a new_character and select
// a new species/wipe flavortext/etc
/datum/preferences/proc/random_character(gender_override, randomize_setting = RANDOMIZE_MINIMAL)
	// because we're about to change a bunch of state in unpredictable ways
	close_subwindows()

	var/gender
	if(gender_override)
		// TODO: just don't write?
		gender = gender_override
	else
		gender = pick(MALE, FEMALE)
		// make em cis by default
		// TODO: real randomization support
		write_preference(/datum/preference/choiced/pronouns, gender == MALE ? HE_HIM : SHE_HER)
		titles_pref = gender == MALE ? TITLES_M : TITLES_F
		clothes_pref = gender == MALE ? CLOTHES_M : CLOTHES_F
		voice_type = gender == MALE ? VOICE_TYPE_MASC : VOICE_TYPE_FEM
		voice_pack = pick(GLOB.voice_packs_list)

	write_preference(/datum/preference/choiced/body_type, gender)
	var/datum/species/pref_species = read_preference(/datum/preference/species)

	// each randomize setting adds more passes
	// the previous pass is always active
	switch(randomize_setting)
		if(RANDOMIZE_MINIMAL)
			randomize_minimal(pref_species)
		if(RANDOMIZE_NORMAL)
			// minimal before normal for taur type
			randomize_minimal(pref_species)
			randomize_normal(pref_species)
		if(RANDOMIZE_NEW_CHARACTER)
			// new_character first for species
			randomize_new_character(pref_species)
			// minimal before normal for taur type
			randomize_minimal(pref_species)
			randomize_normal(pref_species)

// This is just for set_new_race to make things stable again, NOTHING else
/datum/preferences/proc/randomize_minimal(datum/species/pref_species)
	// Reset gameplay options that can be species locked
	write_preference(/datum/preference/choiced_dynamic/race_bonus, null)
	virtue = new /datum/virtue/none
	virtuetwo = new /datum/virtue/none
	virtue_origin = new pref_species.origin_default
	charflaws = list(/datum/charflaw/noflaw)

	// Randomize features & markings!
	taur_type = null
	skin_tone = pick_assoc(pref_species.get_skin_list())
	features = pref_species.get_random_features()
	body_markings = pref_species.get_random_body_markings(features)
	reset_all_customizer_accessory_colors()
	randomize_all_customizer_accessories()

// This is for when the user presses the randomize button
/datum/preferences/proc/randomize_normal(datum/species/pref_species)
	// Random name!
	// TODO: use identity, not body type
	var/new_name = pref_species.random_name(read_preference(/datum/preference/choiced/body_type), TRUE)
	write_preference(/datum/preference/name/real_name, new_name)
	write_preference(/datum/preference/name/nickname, new_name)
	highlight_color = "#[random_color()]"
	voice_color = "#[random_color()]"

	// Pick a new taur type!
	taur_type = pick(pref_species.get_taur_list() + list(null))
	taur_color = "#[random_color()]"

	// Random gameplay stuff!
	extra_language = pick(list("None") + GLOB.languages_character_selection)
	selected_patron = pick_assoc(GLOB.preference_patrons)
	domhand = pick(1, 2)

	// Random sounds!
	bark_id = pick(GLOB.bark_list)
	var/datum/bark/B = GLOB.bark_list[bark_id]
	bark_speed = rand(B::minspeed * 100, B::maxspeed * 100) / 100
	bark_pitch = rand(B::minpitch * 100, B::maxpitch * 100) / 100
	bark_variance = rand(B::minvariance * 100, B::maxvariance * 100) / 100
	voice_pitch = rand(MIN_VOICE_PITCH * 100, MAX_VOICE_PITCH * 100) / 100

	// Default a bunch of stuff
	reset_descriptors()
	age = initial(age)
	statpack = new /datum/statpack/wildcard/fated
	dnr_pref = initial(dnr_pref)
	qsr_pref = initial(qsr_pref)
	favorite_cuisine = initial(favorite_cuisine)
	favorite_dish = initial(favorite_dish)
	favorite_drink = initial(favorite_drink)
	averse_chosen_faction = initial(averse_chosen_faction)

// Only run this for "new character" style randomization
// new characters get all texts merked and a random species assigned
/datum/preferences/proc/randomize_new_character(datum/species/pref_species)
	// assign new species
	var/random_species_type = GLOB.species_list[pick(get_selectable_species())]
	set_new_race(new random_species_type, skip_random = TRUE)

	// merk custom texts
	flavortext = null
	flavortext_cached = null
	ooc_notes = null
	ooc_notes_cached = null
	nsfwflavortext = null
	nsfwflavortext_cached = null
	erpprefs = null
	erpprefs_cached = null
	rumour = null
	rumour_cached = null
	noble_gossip = null
	noble_gossip_cached = null

	headshot_link = null
	ooc_extra = null
	song_artist = null
	song_title = null
	img_gallery = list()
	nsfw_img_gallery = list()
	examine_theme = null

	// antag too
	vampire_skin = null
	vampire_eyes = null
	vampire_hair = null
	vampire_ears = null
	lich_headshot_link = null
	vampire_headshot_link = null
	werewolf_headshot_link = null
	preset_bounty_enabled = FALSE
	preset_bounty_poster_key = null
	preset_bounty_severity_key = null
	preset_bounty_severity_b_key = null
	preset_bounty_severity_v_key = null
	preset_bounty_crime = null

	// reset familiar prefs
	QDEL_NULL(familiar_prefs)
	familiar_prefs = new /datum/familiar_prefs(src)

	// reset gameplay stuff
	job_subprefs = list()
	gear_list = list()
