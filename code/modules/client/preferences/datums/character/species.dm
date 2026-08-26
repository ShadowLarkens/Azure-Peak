/datum/preference/species
	savefile_key = "species"
	savefile_identifier = PREFERENCE_CHARACTER
	zod_schema = "z.object({ base_species: z.string(), sub_species: z.string() })"
	zod_schema_constant = "z.object({ species: z.array(z.object({ name: z.string(), base_name: z.string(), sub_name: z.string(), id: z.string(), type: typepath, is_subrace: z.coerce.boolean(), desc: z.string(), desc_title: z.string(), bonus_stats: z.string().optional(), bonus_traits: z.string().optional(), mechanics: z.string().optional(), languages: z.string().optional(), })), })"

	var/datum/species/default_species = /datum/species/human/northern

/datum/preference/species/deserialize(datum/species/input, datum/preferences/preferences)
	if(!istype(input))
		var/type = GLOB.species_list[input]
		if(!type)
			return null
		input = new type()

	// This is the easiest way to implement this,
	// because we already need a datum/species instance.
	if(!is_valid(input, preferences))
		// No qdel, we're the only reference holder
		return null

	return input

/datum/preference/species/is_valid(datum/species/pref_species, datum/preferences/preferences)
	if(!istype(pref_species))
		return FALSE
	if(!(pref_species.name in get_selectable_species()))
		return FALSE
	if(!pref_species.check_roundstart_eligible())
		return FALSE
	return TRUE

/// Only ever called after is_valid passes
/datum/preference/species/serialize(datum/species/pref_species)
	return pref_species.name

/datum/preference/species/create_default_value()
	return new default_species()

/datum/preference/species/get_ui_data(datum/species/pref_species)
	return list("base_species" = pref_species.base_name, "sub_species" = pref_species.sub_name)

/datum/preference/species/get_constant_ui_data()
	var/list/data = list(
		"species" = null,
	)

	var/list/species_data = list()
	for(var/species_name in get_selectable_species())
		var/datum/species/species = GLOB.species_list[species_name]
		// TODO: fix this one day...
		species = new species()
		UNTYPED_LIST_ADD(species_data, species.constant_ui_data())
		// No qdel, we're the only reference holder
	data["species"] = species_data

	return data
