/datum/preferences/proc/ui_act_game_settings(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/mob/user = ui.user

	switch(action)
		if("be_special")
			var/be_special_type = params["be_special_type"]
			if(be_special_type in be_special)
				be_special -= be_special_type
			else
				if(be_special_type in GLOB.special_roles_rogue)
					be_special += be_special_type
			return TRUE
		if("tgui_theme")
			setTguiStyle(user)
			return TRUE
		if("parchment_skin")
			cycle_parchment_skin()
			return TRUE
		if("statbrowser_theme")
			cycle_statbrowser_theme()
			user.client?.apply_statbrowser_theme()
			return TRUE
		if("tgui_input")
			tgui_pref = !tgui_pref
			return TRUE
		if("tgui_lock")
			tgui_lock = !tgui_lock
			return TRUE
		if("ambientocclusion")
			ambientocclusion = !ambientocclusion
			if(parent && parent.screen && parent.screen.len)
				var/atom/movable/screen/plane_master/game_world/PM = locate(/atom/movable/screen/plane_master/game_world) in parent.screen
				PM.backdrop(parent.mob)
				PM = locate(/atom/movable/screen/plane_master/game_world_fov_hidden) in parent.screen
				PM.backdrop(parent.mob)
				PM = locate(/atom/movable/screen/plane_master/game_world_above) in parent.screen
				PM.backdrop(parent.mob)
			return TRUE
		if("windowflashing")
			windowflashing = !windowflashing
			return TRUE
		if("clientfps")
			var/desiredfps = tgui_input_number(user, "Choose your desired fps. (0 = synced with server tick rate (currently: [world.fps]))", "Client FPS", clientfps)
			if(!isnull(desiredfps))
				clientfps = desiredfps
				parent.fps = desiredfps
			return TRUE
		if("auto_fit_viewport")
			auto_fit_viewport = !auto_fit_viewport
			if(auto_fit_viewport && parent)
				parent.fit_viewport()
			return TRUE
		if("schizo_voice")
			toggles ^= SCHIZO_VOICE
			if(toggles & SCHIZO_VOICE)
				to_chat(user, span_warning("You are now a voice.\n\
								As a voice, you will receive meditations from players asking about game mechanics!\n\
								Good voices will be rewarded with PQ for answering meditations, while bad ones are punished at the discretion of The Management."))
			else
				to_chat(user, span_warning("You are no longer a voice."))
			return TRUE
		if("no_storyteller_events")
			no_storyteller_events = !no_storyteller_events
			return TRUE