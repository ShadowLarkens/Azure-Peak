/datum/preferences/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/json/preferences)

// Used to generate the preferences.json containing metadata for the UI
/datum/asset/json/preferences
	name = "preferences"
	early = TRUE

/datum/asset/json/preferences/generate()
	var/list/data = list()

	data["MAX_VICES"] = MAX_VICES
	data["MINIMUM_FLAVOR_TEXT"] = MINIMUM_FLAVOR_TEXT
	data["MINIMUM_OOC_NOTES"] = MINIMUM_OOC_NOTES
	data["tgui_themes"] = get_tgui_themes()

	// Force SSjob to load occupations
	SSjob.GetJob()

	var/list/classes_data = list()
	for(var/datum/job/job as anything in SSjob.occupations)
		// note: this transmits info about all existing jobs with 0 respect for any secrecy
		classes_data["[job.title]"] = job.constant_ui_data()
	data["classes"] = classes_data

	var/list/virtues_data = list()
	for(var/virtue_path as anything in GLOB.virtues)
		var/datum/virtue/V = GLOB.virtues[virtue_path]
		virtues_data["[V.name]"] = V.constant_ui_data()
	data["virtues"] = virtues_data

	return data

/* INSTRUCTIONS FOR DOWNSTREAM:
Add a new override in your modular folder that looks like this:
/datum/asset/json/preferences/generate()
	var/list/data = ..()

	data[...] = ...

	return data
*/
