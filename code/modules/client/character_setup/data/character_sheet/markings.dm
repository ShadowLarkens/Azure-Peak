/datum/preferences/proc/ui_data_character_sheet_markings(mob/user)
	var/list/data = list()

	var/list/marking_zones = list()
	for(var/zone in GLOB.marking_zones)
		var/named_zone = " "
		switch(zone)
			if(BODY_ZONE_R_ARM)
				named_zone = "Right Arm"
			if(BODY_ZONE_L_ARM)
				named_zone = "Left Arm"
			if(BODY_ZONE_HEAD)
				named_zone = "Head"
			if(BODY_ZONE_CHEST)
				named_zone = "Chest"
			if(BODY_ZONE_R_LEG)
				named_zone = "Right Leg"
			if(BODY_ZONE_L_LEG)
				named_zone = "Left Leg"
			if(BODY_ZONE_PRECISE_R_HAND)
				named_zone = "Right Hand"
			if(BODY_ZONE_PRECISE_L_HAND)
				named_zone = "Left Hand"

		var/list/markings_data = list(
			"zone" = zone,
			"name" = named_zone,
			"may_add" = !(body_markings[zone]) || body_markings[zone].len < MAXIMUM_MARKINGS_PER_LIMB,
			"keys" = null,
		)

		if(body_markings[zone])
			var/list/active_keys = list()
			for(var/key in body_markings[zone])
				var/current_index = LAZYFIND(body_markings[zone], key)
				var/color = body_markings[zone][key]

				UNTYPED_LIST_ADD(active_keys, list(
					"key" = key,
					"color" = "#[color]",
					"can_move_up" = current_index > 1,
					"can_move_down" = current_index < length(body_markings[zone]),
				))
			markings_data["keys"] = active_keys

		UNTYPED_LIST_ADD(marking_zones, markings_data)
	data["markings"] = marking_zones

	return data