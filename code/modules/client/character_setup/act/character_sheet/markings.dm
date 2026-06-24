/datum/preferences/proc/ui_act_character_sheet_markings(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/mob/user = ui.user

	switch(action)
		if("marking_use_preset")
			var/confirm = alert(usr, "Are you sure you want to use a preset (This will clear your existing markings)?", "Markings Preset", "Yes", "No")
			if(confirm && confirm == "Yes")
				var/list/candidates = marking_sets_for_species(pref_species)
				if(length(candidates) == 0)
					return CHARACTER_ACT_DATA_UPDATE
				var/desired_set = tgui_input_list(user, "Choose your new body markings:", "Character Preference", candidates)
				if(desired_set)
					var/datum/body_marking_set/BMS = GLOB.body_marking_sets[desired_set]
					body_markings = assemble_body_markings_from_set(BMS, features, pref_species)
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("marking_reset_color")
			var/zone = params["key"]
			var/name = params["name"]
			if(!body_markings[zone] || !body_markings[zone][name])
				return CHARACTER_ACT_DATA_UPDATE
			var/datum/body_marking/BM = GLOB.body_markings[name]
			body_markings[zone][name] = BM.get_default_color(features, pref_species)
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("marking_change_color")
			var/zone = params["key"]
			var/name = params["name"]
			if(!body_markings[zone] || !body_markings[zone][name])
				return CHARACTER_ACT_DATA_UPDATE
			var/color = body_markings[zone][name]
			var/new_color = color_pick_sanitized(user, "Choose your markings color:", "Character Preference","#[color]")
			if(new_color)
				if(!body_markings[zone] || !body_markings[zone][name])
					return CHARACTER_ACT_DATA_UPDATE
				body_markings[zone][name] = sanitize_hexcolor(new_color, 6)
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("marking_move_up")
			var/zone = params["key"]
			var/name = params["name"]
			var/list/marking_list = LAZYACCESS(body_markings, zone)
			var/current_index = LAZYFIND(marking_list, name)
			if(!current_index || --current_index < 1)
				return CHARACTER_ACT_DATA_UPDATE
			var/marking_content = marking_list[name]
			marking_list -= name
			marking_list.Insert(current_index, name)
			marking_list[name] = marking_content
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("marking_move_down")
			var/zone = params["key"]
			var/name = params["name"]
			var/list/marking_list = LAZYACCESS(body_markings, zone)
			var/current_index = LAZYFIND(marking_list, name)
			if(!current_index || ++current_index > length(marking_list))
				return CHARACTER_ACT_DATA_UPDATE
			var/marking_content = marking_list[name]
			marking_list -= name
			marking_list.Insert(current_index, name)
			marking_list[name] = marking_content
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("add_marking")
			var/zone = params["key"]
			if(!GLOB.body_markings_per_limb[zone])
				return CHARACTER_ACT_DATA_UPDATE
			var/list/possible_candidates = marking_list_of_zone_for_species(zone, pref_species)
			if(body_markings[zone])
				//To prevent exploiting hrefs to bypass the marking limit
				if(body_markings[zone].len >= MAXIMUM_MARKINGS_PER_LIMB)
					return CHARACTER_ACT_DATA_UPDATE
				//Remove already used markings from the candidates
				for(var/keyed_name in body_markings[zone])
					possible_candidates -= keyed_name
			if(possible_candidates.len == 0)
				return CHARACTER_ACT_DATA_UPDATE
			var/desired_marking = tgui_input_list(user, "Choose your new marking to add:", "Character Preference", possible_candidates)
			if(desired_marking)
				var/datum/body_marking/BD = GLOB.body_markings[desired_marking]
				if(!body_markings[zone])
					body_markings[zone] = list()
				body_markings[zone][BD.name] = BD.get_default_color(features, pref_species)
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("remove_marking")
			var/zone = params["key"]
			var/name = params["name"]
			if(!body_markings[zone] || !body_markings[zone][name])
				return CHARACTER_ACT_DATA_UPDATE
			body_markings[zone] -= name
			if(body_markings[zone].len == 0)
				body_markings -= zone
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("change_marking")
			var/zone = params["key"]
			var/changing_name = params["name"]
			var/list/possible_candidates = marking_list_of_zone_for_species(zone, pref_species)
			if(body_markings[zone])
				//Remove already used markings from the candidates
				for(var/keyed_name in body_markings[zone])
					possible_candidates -= keyed_name
			if(possible_candidates.len == 0)
				return CHARACTER_ACT_DATA_UPDATE
			var/desired_marking = tgui_input_list(user, "Choose a marking to change the current one to:", "Character Preference", possible_candidates)
			if(desired_marking)
				if(!body_markings[zone] || !body_markings[zone][changing_name])
					return CHARACTER_ACT_DATA_UPDATE
				var/held_index = LAZYFIND(body_markings[zone], changing_name)
				var/datum/body_marking/BD = GLOB.body_markings[desired_marking]
				var/marking_content
				marking_content = BD.get_default_color(features, pref_species)
				body_markings[zone] -= changing_name
				body_markings[zone].Insert(held_index, desired_marking)
				body_markings[zone][desired_marking] = marking_content
			return CHARACTER_ACT_PREVIEW_UPDATE
		if("marking_reset_all_colors")
			reset_body_marking_colors()
			return CHARACTER_ACT_PREVIEW_UPDATE
