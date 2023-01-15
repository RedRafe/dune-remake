--- Defining my Globals
function globals()

	if global.dune_worm_check == nil then
		global.dune_worm_check = true
	end
	if global.dune_worm_check_count == nil then
		global.dune_worm_check_count = 0
	end
	if global.attack_counter == nil then
		global.attack_counter = 0		
	end	
	if global.emperor_message_1_sent == nil then
		global.emperor_message_1_sent = false		
	end	
	if global.last_mission == nil then
		global.last_mission = false		
	end	
	if global.time_left == nil then
		global.time_left = 0		
	end	
	if global.attack_increase == nil then
		global.attack_increase = 0		
	end	
	if global.level_started_at == nil then
		global.level_started_at = 0		
	end
	if global.dune_crash_site_init == nil then
		global.dune_crash_site_init = true
	end
	if global.accumulated == nil then
		global.accumulated = {}
	end
	if global.required == nil then
		global.required = {}
	end
	if global.labels == nil then
		global.labels = {}
	end
	if global.story == nil then
		global.story = {}
	end
	if global.chests == nil then
		global.chests = {}
	end
	if global.level == nil then
		global.level = 0
	end
	if global.level == nil then
		global.points = 0
	end
end
	