/datum/preferences/proc/ui_act_character_sheet_classes(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/mob/user = ui.user

	switch(action)
		if("select_joblessrole")
			switch(joblessrole)
				if(RETURNTOLOBBY)
					joblessrole = BERANDOMJOB
				if(BERANDOMJOB)
					joblessrole = RETURNTOLOBBY
			return CHARACTER_ACT_DATA_UPDATE
		if("set_job_preference")
			var/title = params["job"]
			var/level = params["level"]

			if(level != null && level != JP_LOW && level != JP_MEDIUM && level != JP_HIGH)
				return CHARACTER_ACT_DATA_UPDATE

			if(!istext(title))
				return CHARACTER_ACT_DATA_UPDATE

			var/datum/job/job = SSjob.GetJob(title)
			if(!job)
				return CHARACTER_ACT_DATA_UPDATE

			SetJobPreferenceLevel(job, level)
			return CHARACTER_ACT_DATA_UPDATE // note: change this if we ever readd job clothing preview
		if("explainjob")
			var/title = params["job"]
			if(!istext(title))
				return CHARACTER_ACT_DATA_UPDATE

			var/datum/job/job = SSjob.GetJob(title)
			if(!job)
				return CHARACTER_ACT_DATA_UPDATE

			job.show_explain(user)
			return CHARACTER_ACT_DATA_UPDATE