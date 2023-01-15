
local util = require ("__core__/lualib/util")
local mod_gui = require ("__core__/lualib/mod-gui")
local story = require ("__core__/lualib/story")
--require ("worm-collision")
--require ("test_spawn")
require ("globals")
require ("config")

local sound_low_time      = "dune-silo-alarm"
local sound_sufficient    = "utility/achievement_unlocked"
local sound_insufficient  = "utility/game_lost"
local play_low_time_alarm = true

--------------------------------------------------------------------------

local function On_Init()
	--test_spawn()
	globals()
	validate_prototypes()
	global.story = story_init(story_table)
	make_brick_circle()
	force = game.forces.player
	
	local chest = game.surfaces[1].create_entity{name = "dune-palace", position = {1, 1}, force = force}
	
	-- Starting Materials
	for k, chest in pairs (game.surfaces[1].find_entities_filtered{name = "dune-palace"}) do
		chest.minable = false
		chest.insert({name = "stone-brick", 		 count = 1000})
		chest.insert({name = "dune-worker", 		 count = 5})
		chest.insert({name = "firearm-magazine", count = 50})
		chest.insert({name = "gun-turret", 			 count = 2})
		chest.insert({name = "vehicle-miner",		 count = 2})
		chest.insert({name = "iron-plate", 			 count = 10})
		global.chests[chest.unit_number] = chest
	end
	
	global.level = 1
	global.points = 0
end

local function On_Config_Change()
	globals()
	validate_prototypes()
	--story_update(global.story)
	--global.story = story_init(story_table)
end

local function On_Load()
end

local function On_Death(event)
	local entity = event.created_entity or event.entity
	--- Palace been destroyed	- YOU LOSE
	if entity.valid and entity.name == "dune-palace" then
		game.set_game_state{game_finished=true, player_won=false}
	end
end

--------------------------------------------------------------------

local completed_label_color = {g = 0.6}
local low_time_left_label_color = {r = 1}

function update_info()
  local level = levels[global.level]
  local accumulated = global.accumulated
  for k, player in pairs (game.players) do
    local frame = mod_gui.get_frame_flow(player).frame
    local table = frame.table
    for index, item in pairs(level.requirements) do
      local accumulated = accumulated[item.name]
      local label = table[item.name]
      label.caption = accumulated .. "/" .. item.count
      if accumulated == item.count then
				--game.play_sound{path = sound_sufficient}
        label.style.font_color = completed_label_color
      end
    end
  end
end

function get_time_left()	
  return global.level_started_at + time_modifier * levels[global.level].time * 60 - game.tick
end

function update_time_left(tick)
  --If given not given a tick, we update regardless
  if tick and tick % 60 ~= 0 then return end
  time_left = get_time_left()

  if time_left < 0 then
    time_left = 0
  end

  local caption = {"time-left", util.formattime(time_left)}
  local low_time_left = time_left < 60 * 30

	if time_left > 60 * 30 and not play_low_time_alarm then play_low_time_alarm = true end
	if time_left <= 60 * 30 and time_left > 60 * 10 and play_low_time_alarm then
		game.play_sound{path = sound_low_time}
		play_low_time_alarm = false
	end
  for k, player in pairs (game.players) do
    local label = mod_gui.get_frame_flow(player).frame.time_left
    label.caption = caption
    if low_time_left then
      label.style.font_color = low_time_left_label_color
    end
  end
end

script.on_event(defines.events.on_tick, function(event)

	story_update(global.story, event, "")

	-- Clear Worms in starting area
	if global.dune_crash_site_init then
		remove_crash_site()
	end
	
	if game.tick % (2) == 0 then
		remove_worms()
	end
  
	-- Create a Worker 
	if game.tick % (60 * 60 * worker_spawn_time) == 0 then -- 3600 = one min
		local time_left = get_time_left()
		if time_left >=0 then
			local PositionValid = game.surfaces[1].find_non_colliding_position("dune-worker", {-4, 5}, 5, 1)
			if PositionValid then
				spawn_worker = game.surfaces[1].create_entity({name = "dune-worker", position = PositionValid, force = game.forces.player})
			else	
				game.print("No Spawn Position found for worker. Make sure nothing is around Palace")
			end	
		end	
	end
		
	--- Attack every 20 min
	if game.tick % (60 * 60 * 10 * worker_spawn_time) == 0 then
		create_attack_group(global.level)
	end
	
	--- Final Attach Waves every 10 min
	if game.tick % (60 * 60 * 10) == 0 and global.last_mission then
		create_enemy_forces()
		create_attack_group_alt(50)
	end
	
end)

story_table =
{
  {
    {
      action = function()
        if not game.is_multiplayer() then
					game.show_message_dialog{text = {"dune_welcome"}}
					game.show_message_dialog{text = {"dune_rules_1"}}
					game.show_message_dialog{text = {"dune_rules_2"}}
					game.show_message_dialog{text = {"dune_rules_3"}}
					game.show_message_dialog{text = {"dune_rules_6"}}
					game.show_message_dialog{text = {"dune_tips_1"}}
					game.show_message_dialog{text = {"dune_tips_2"}}
					game.show_message_dialog{text = {"dune_tips_3"}}
        end
      end
    },
    {},
    {
      name = "level-start",
      init = function(event)
        global.accumulated = {}
        global.required = {}
        global.labels = {}
        local level = levels[global.level]
        for k, player in pairs (game.players) do
          make_frame(player)
        end
        for index, item in pairs(levels[global.level].requirements) do
          global.accumulated[item.name] = 0
          global.required[item.name] = item.count
        end
        if global.level < #levels then
          for k, player in pairs (game.players) do
            update_frame(player, levels[global.level + 1])
          end
          local item_prototypes = game.item_prototypes
          for index, item in pairs(levels[global.level + 1].requirements) do
            local diff
            if global.required[item.name] ~= nil then
              diff = item.count - global.required[item.name]
            else
              diff = item.count
            end
            for k, player in pairs (game.players) do
              update_table(player, diff, item)
            end
          end
        end
        global.level_started_at = event.tick
        update_info()
        update_time_left()
      end
    },
    {
      name = "level-progress",
      update = function(event)
        update_time_left(event.tick)
        local update_info_needed = false
        local level = levels[global.level]
        for index, chest in pairs(global.chests) do
          if chest.valid then
            local inventory = chest.get_inventory(defines.inventory.chest)
            local contents = inventory.get_contents()
            for itemname, count in pairs(contents) do
              if global.accumulated[itemname] then
                local counttoconsume = global.required[itemname] - global.accumulated[itemname]
                if counttoconsume > count then
                  counttoconsume = count
                end
                if counttoconsume ~= 0 then
                  inventory.remove{name = itemname, count = counttoconsume}
                  global.accumulated[itemname] = global.accumulated[itemname] + counttoconsume
                  update_info_needed = true
                end
              end
            end
          end
        end
        if update_info_needed then
          update_info()
        end
      end,
      condition = function(event)
        local level = levels[global.level]
        local time_left = get_time_left()
        if event.name == defines.events.on_gui_click and event.element.name == "next_level" then --- !! Clicking this button does not work!
          local seconds_left = math.floor(time_left / 60)
          local points_addition = math.floor(seconds_left * (points_per_second_start - global.level * points_per_second_level_subtract))
					
          global.points = global.points + points_addition		  
					
          for k, player in pairs (game.players) do
            if mod_gui.get_button_flow(player).next_level ~= nil then
              mod_gui.get_button_flow(player).next_level.destroy()
            end
          end
          return true
        end

        local result = true
        for index, item in pairs(level.requirements) do
          local accumulated = global.accumulated[item.name]
          if accumulated < item.count then
            result = false
          end
        end

        if result then
          for k, player in pairs (game.players) do
            if mod_gui.get_button_flow(player).next_level == nil then
              mod_gui.get_button_flow(player).add{type = "button", name = "next_level", caption={"next-level"}, style = mod_gui.button_style}
            end
          end
        end

        if time_left <= 0 then
          if result == false then
            for k, player in pairs (game.players) do
              --player.set_ending_screen_data({"points-achieved", util.format_number(global.points)})
							player.set_ending_screen_data({"what_happened"})
            end
						--- If you miss your shipment goal
						if not global.emperor_message_1_sent and global.level ~= (#levels) then
							game.print("The Emperor is not happy that you did not make the monthly shipment!")
							game.print("Expect other houses to take advantage of this...")
							global.emperor_message_1_sent = true
							game.play_sound{path = sound_insufficient}
						end
						--- Create Enemy Forces that attack you when you don't finish your goal in time.
						create_enemy_forces()
            return false
          else
            return true
          end
        end
        return false
      end,

      action = function(event, story)
        for k, player in pairs (game.players) do
          if mod_gui.get_button_flow(player).next_level ~= nil then
            mod_gui.get_button_flow(player).next_level.destroy()
          end
        end
				
				--- Level Goal Achieved
        global.level = global.level + 1
        local points_addition = (global.level - 1) * 10
				game.print("Shipment "..(global.level - 1).." received. Goal Achieved!")
				game.play_sound{path = sound_sufficient}
				global.attack_increase = 0
        global.points = global.points + points_addition
				global.emperor_message_1_sent = false
				---- Increase Evolution factor by 2.5%
				game.forces.enemy.evolution_factor = game.forces.enemy.evolution_factor + evo_increase_per_level
				
				--- Create Enemy Forces that attack you and send them out.
				create_enemy_forces()
				create_attack_group_alt(global.level)

				for k, chest in pairs (game.surfaces[1].find_entities_filtered{name = "dune-palace"}) do
					--- Insert Rewards
					local rewards_table = get_rewards_to_add()
					local rewards_name = rewards_table.spawn	
					local rewards_count = rewards_table.count
					chest.insert({name = rewards_name, count = rewards_count * award_multiplier})
				end	
				--- FINAL MISSION Settings
				if global.level == (#levels) then
					global.last_mission = true
					create_enemy_forces()
					create_attack_group_alt(50)
					if not game.is_multiplayer() then
						game.show_message_dialog{text = {"dune_last_mission"}}
						game.show_message_dialog{text = {"dune_last_mission2"}}
					end
				end
				
        if global.level < #levels + 1 then
          for k, player in pairs (game.players) do
            mod_gui.get_frame_flow(player).frame.destroy()
          end
          story_jump_to(story, "level-start")
        end
      end
    },
    {
      action = function()
        for k, player in pairs (game.players) do
          --player.set_ending_screen_data({"points-achieved", util.format_number(global.points)})
					player.set_ending_screen_data({"dune_finish"})
        end
      end
    }
  }
}

story_init_helpers(story_table)

function plant_trees(event)
	--- Place Palm trees around Water 
	local look_for_water = game.surfaces[1].find_entities_filtered{area = event.area, name = "ground-water"}    
	
	for i = 1, #look_for_water do
		local tree_name
		if game.active_mods["alien-biomes"] then 
			tree_name = "tree-palm-a"
		else 
			tree_name = "tree-05"
		end
		
		
		local number_of_trees = math.floor(math.random(5))
		local radius = 1
		local pos = look_for_water[i].position
		local area = {{pos.x - radius, pos.y - radius}, {pos.x + radius, pos.y + radius}}		
		
		for i = 1, number_of_trees do
		
			local x_offset = math.random(-5, 5)
			local y_offset = math.random(-5, 5)
			local position_c = {pos.x + x_offset, pos.y + y_offset}
			local PositionValid = game.surfaces[1].find_non_colliding_position(tree_name, position_c, 2 , 0.5)
			
			if PositionValid then 			
				spawn_tree = game.surfaces[1].create_entity({name = tree_name, position = PositionValid})
			end
			
		end
		
	end
	
end

--- Spawn worms on Melange
function spawn_worms_on_melange(event)
	local look_for_melange = game.surfaces[1].find_entities_filtered{area = event.area, name = "melange"} 
	for i = 1, #look_for_melange do
		local worm_name
		if game.forces.enemy.evolution_factor <= 0.15 then
			worm_name = "small-worm-turret"
		elseif game.forces.enemy.evolution_factor <= 0.30 then
			worm_name = "medium-worm-turret"
		elseif game.forces.enemy.evolution_factor <= 0.50 then
			worm_name = "big-worm-turret"
		else
			worm_name = "behemoth-worm-turret"
		end
		
		local radius = 2.5
		local pos = look_for_melange[i].position
		local area = {{pos.x - radius, pos.y - radius}, {pos.x + radius, pos.y + radius}}			
		local PositionValid = game.surfaces[1].find_non_colliding_position(worm_name, look_for_melange[i].position, 2, 0.5)
		local look_for_worms = game.surfaces[1].find_entities_filtered{area = area, name = worm_name} 

		if PositionValid then 
			if #look_for_worms >= 1 then
				-- nothing
			else
				spawn_worm = game.surfaces[1].create_entity({name = worm_name, position = PositionValid , force = game.forces.enemy})
			end
		end
  end
end

--- Spawn worms on Melange
function spawn_random_worms(event)
	local lt = event.area.left_top
	local rb = event.area.right_bottom
	local tx = lt.x
	local ty = lt.y
	local rx = rb.x
	local ry = rb.y
	local x_center = 0
	local y_center = 0		

	if tx <= 0 and rx <= 0 then x_center = (tx+rx)/2 end
	if tx >= 0 and rx >= 0 then x_center = (tx+rx)/2 end
	if tx < 0 and rx > 0 then x_center = (tx-rx+1)/2 end
	
	if ty <= 0 and ry <= 0 then y_center = (ty+ry)/2 end
	if ty >= 0 and ry >= 0 then y_center = (ty+ry)/2 end
	if ty < 0 and ry > 0 then y_center = (ty-ry+1)/2 end	

	local worms = {"small-worm-turret", "medium-worm-turret", "big-worm-turret", "behemoth-worm-turret", "unit-small-worm-turret", "unit-medium-worm-turret", "unit-big-worm-turret", "unit-behemoth-worm-turret"}
	local number_of_worms_found = 0
	for _, word in pairs(worms) do
		local radius = 14
		local radius2 = 25
		local area = {{x_center - radius, y_center - radius}, {x_center + radius, y_center + radius}}	
		local area2 = {{x_center - radius2, y_center - radius2}, {x_center + radius2, y_center + radius2}}	
		local look_for_worms = game.surfaces[1].find_entities_filtered{area = area2, name = word} 

		if #look_for_worms >= 0  then	
			number_of_worms_found = number_of_worms_found + #look_for_worms
		end
	end

	local look_for_palace = game.surfaces[1].find_entities_filtered{area = event.area, name = "dune-palace"}	
	if number_of_worms_found <= 0 and #look_for_palace <= 0 then
		local number_of_worms = math.floor((math.floor(game.forces.enemy.evolution_factor * 10) + 1) / 2)
		if number_of_worms < 1 then number_of_worms = 1 end
		local worm_name
		if game.forces.enemy.evolution_factor <= 0.20 then
			worm_name = "unit-small-worm-turret"
		elseif game.forces.enemy.evolution_factor <= 0.40 then
			worm_name = "unit-medium-worm-turret"
		elseif game.forces.enemy.evolution_factor <= 0.65 then
			worm_name = "unit-big-worm-turret"
		else
			worm_name = "unit-behemoth-worm-turret"
		end				

		for i = 1, (number_of_worms * difficulty["patches_worms"]) do
			-- Find the center of the generated Chunk
			local x_center_r = math.random(x_center-14, x_center+14)
			local y_center_r = math.random(y_center-14, y_center+14)
			
			local position_c_r = {x_center_r, y_center_r}

			local PositionValid = game.surfaces[1].find_non_colliding_position(worm_name, position_c_r, 2 , 0.5)
			if PositionValid then 
				spawn_worm = game.surfaces[1].create_entity({name = worm_name, position = PositionValid , force = game.forces.enemy})
			end					
		end
	end
end

script.on_event(defines.events.on_chunk_generated, function(event)
	--- Spawn worms on Melange
	spawn_worms_on_melange(event)
	--- Spawn some random worms
	spawn_random_worms(event)	
	--- Place Palm trees around Water 
	plant_trees(event)
end)

script.on_event(defines.events.on_player_joined_game, function(event)
	on_joined(event)
end)

function on_joined(event)
	local player = game.players[event.player_index]
	on_player_joined(player)
	make_frame(player)

  if global.level < #levels then
    update_frame(player, levels[global.level + 1])
    for index, item in pairs(levels[global.level + 1].requirements) do
      local diff
      if global.required[item.name] ~= nil then
        diff = item.count - global.required[item.name]
      else
        diff = item.count
      end
      update_table(player, diff, item)
    end
  end

  if event.name ~= defines.events.on_player_created then return end
  player.insert{name = "iron-plate", count = 20}
  player.insert{name = "firearm-magazine", count = 20}
end

function make_frame(player)
  local flow = mod_gui.get_frame_flow(player)
  if flow.frame then
    flow.frame.destroy()
  end
  local frame = flow.add{type = "frame", name = "frame", direction = "vertical", caption = {"level", global.level}}
  frame.add{type = "label", name = "time_left", caption = {"time-left", "-"}}
  --frame.add{type = "label", caption = {"points-per-second", points_per_second_start - global.level * points_per_second_level_subtract}}
  --frame.add{type = "label", caption = {"points", util.format_number(math.floor(global.points))}}
  frame.add{type = "label", caption = {"required-items"}, style = "caption_label"}
  local table = frame.add{type = "table", name = "table", column_count = 2}
  table.style.column_alignments[2] = "right"
  for index, item in pairs(levels[global.level].requirements) do
    table.add{type = "label", caption = {"", game.item_prototypes[item.name].localised_name, {"colon"}}}
    table.add{type = "label", caption = "0/" .. item.count, name=item.name}
  end
  return frame
end

function update_frame(player, next_level)
  local frame = mod_gui.get_frame_flow(player).frame
  if not frame then
    frame = make_frame(player)
  end
  frame.add{type= "label", caption={"next-level"}, style = "caption_label"}
  local next_level_table = frame.add{type = "table", column_count=2, name = "next_level_table"}
  next_level_table.style.column_alignments[2] = "right"
end

function update_table(player, diff, item)
  local table = mod_gui.get_frame_flow(player).frame.next_level_table
  if not table then game.print("No table for update_table function") return end
  if diff ~= 0 then
    table.add{type = "label", caption = {"", game.item_prototypes[item.name].localised_name, {"colon"}}}
  end
  if diff > 0 then
    table.add{type = "label", caption = "+" .. diff}
    return
  end
  if diff < 0 then
    table.add{type = "label", caption = diff}
    return
  end
end

function validate_prototypes()
  local items = game.item_prototypes
  local is_error = false
  local bad_items = {}
  for k, level in pairs (levels) do
    for k, item in pairs (level.requirements) do
      if not items[item.name] or item.count <= 0 then
        is_error = true
        bad_items[item.name] = item.count
      end
    end
  end
  if is_error then
    error("Bad prototypes in supply challenge:\n"..serpent.block(bad_items))
  end
end

-- Remove worms from starting area
function remove_worms()
	if global.dune_worm_check then
	global.dune_worm_check_count = global.dune_worm_check_count + 1
		
		if global.dune_worm_check_count >= 4 then
			global.dune_worm_check = false
		end
		
		local worms = {"small-worm-turret", "medium-worm-turret", "big-worm-turret", "behemoth-worm-turret", "unit-small-worm-turret", "unit-medium-worm-turret", "unit-big-worm-turret", "unit-behemoth-worm-turret"}
		for _, word in pairs(worms) do
			local radius = 200	
			local area = {{0 - radius, 0 - radius}, {0 + radius, 0 + radius}}	
			local look_for_worms = game.surfaces[1].find_entities_filtered{area = area, name = word} 
			
			if (#look_for_worms > 0)  then	
				for i = 1, #look_for_worms do
					local look_for_worms = look_for_worms[i]
					look_for_worms.destroy()
				end
			end			
		end
	end
end

-- remove crash site
function remove_crash_site()
	if global.dune_crash_site_init then
		local crash_site_entities = {
			"crash-site-chest-1",
			"crash-site-chest-2",
			"crash-site-spaceship",
			"crash-site-spaceship-wreck-big-1",
			"crash-site-spaceship-wreck-big-2",
			"crash-site-spaceship-wreck-medium-1",
			"crash-site-spaceship-wreck-medium-2",
			"crash-site-spaceship-wreck-medium-3",
			"crash-site-spaceship-wreck-small-1",
			"crash-site-spaceship-wreck-small-2",
			"crash-site-spaceship-wreck-small-3",
			"crash-site-spaceship-wreck-small-4",
			"crash-site-spaceship-wreck-small-5",
			"crash-site-spaceship-wreck-small-6",
		}
		local radius = 200
		local area = {{0 - radius, 0 - radius}, {0 + radius, 0 + radius}}
		for _, entity_name in pairs(crash_site_entities) do
			local look_for_entity = game.surfaces[1].find_entities_filtered{area = area, name = entity_name}
			if (#look_for_entity > 0)  then	
				for i = 1, #look_for_entity do
					local found_entity = look_for_entity[i]
					found_entity.destroy()
				end
				global.dune_crash_site_init = false
			end	
		end
	end
end

-- Make Brick Circle in Starting area
function make_brick_circle()
	local changed_tiles = {}
	-- fill changed_tiles with tiles that are within a radius of the 0,0 position
	-- and designate them to be 'stone-path's
	local radius = 15
	--local pos = {1,1}
	local area = {{0 - radius, 0 - radius}, {0 + radius, 0 + radius}}	

	for x = -radius, radius do
		for y = -radius, radius  do
	if math.sqrt(x*x + y*y) < radius then
		table.insert(changed_tiles, {name="stone-path", position={x, y}})
	end
		end
	end
	
	-- apply the stone path tiles
	if #changed_tiles > 0 then
		game.surfaces[1].set_tiles(changed_tiles)
	end
  
  --- Remove stuff around starting area.
  local stuff_list = {"tree", "simple-entity"}
	for _, stuff in pairs(stuff_list) do

		local radius = 25
		local area = {{0 - radius, 0 - radius}, {0 + radius, 0 + radius}}
		local look_for_stuff = game.surfaces[1].find_entities_filtered{area = area, type = stuff} 

		if (#look_for_stuff > 0)  then	
			for i = 1, #look_for_stuff do
				local look_for_stuff = look_for_stuff[i]
				look_for_stuff.destroy()
			end
		end	
	end
end	

-- Select rewards to Spawn												
function get_rewards_to_add()
	local factor = global.level * 10 -- 10 - 210
	local reward_options = 
	{
		{spawn = "dune-worker", 	weight = 80,  count = 2},
		{spawn = "dune-worker", 	weight = 30,  count = 4},
		{spawn = "dune-worker", 	weight = 5, 	count = 6},
		{spawn = "vehicle-miner", weight = 1, 	count = 1},
		{spawn = "radar", 				weight = 3, 	count = 1},
		{spawn = "stone", 				weight = 10,  count = 400},
		{spawn = "stone-brick", 	weight = 30,  count = 100},
		{spawn = "gun-turret", 		weight = 6, 	count = 1},
	}

	local calculate_odds = {}
	for k, spawn in ipairs(reward_options) do
		for i=1, spawn.weight do
			calculate_odds[#calculate_odds+1] = k
		end
	end

	local random_num = #calculate_odds
	return reward_options[calculate_odds[math.random(random_num)]]
end

-- Select the Enemy to Spawn												
function get_enemy_to_spawn()
	local enemy_options = {}
	local factor = math.floor(game.forces.enemy.evolution_factor * 1000)
	local enemy_options_tier1 = 
	{
		{spawn = "unit-small-worm-turret",	weight = 500}, 							 --  500
		{spawn = "smg-guy", 								weight = 2100 - (factor*2)}, -- 2100 - 100
		{spawn = "rocket-guy" , 						weight = 1150 - (factor)}, 	 -- 1150 - 150
		{spawn = "blaster-bot", 						weight = 1200 - (factor)}, 	 -- 1100 - 100
		{spawn = "tazer-bot", 							weight = 400  - (factor/4)}, --  400 - 150
	}

	local enemy_options_tier2 = 
	{
		{spawn = "unit-medium-worm-turret", weight = 500}, 							 --  500
		{spawn = "smg-guy", 								weight = 2100 - (factor*2)}, -- 2100 - 100
		{spawn = "rocket-guy",  						weight = 1150 - (factor)}, 	 -- 1150 - 150
		{spawn = "scout-car",  							weight = 300  + (factor/4)}, --  300 - 550
		{spawn = "blaster-bot",							weight = 1200 - (factor)}, 	 -- 1100 - 100
		{spawn = "tazer-bot",  							weight = 400  - (factor/4)}, --  400 - 150
		{spawn = "laser-bot",   						weight = 50   + (factor/4)}, --   50 - 300
	}

	local enemy_options_tier3 = 
	{
		{spawn = "unit-big-worm-turret", 			weight = 500}, 							 --  500		 
		{spawn = "unit-behemoth-worm-turret", weight = 10}, 							 --   10		 
		{spawn = "rocket-guy", 								weight = 1150 - (factor)},   -- 1150 -  150
		{spawn = "scout-car", 								weight = 300  + (factor/4)}, -- 300  -  550
		{spawn = "shell-tank", 								weight = 1 		+ (factor)}, 	 --   1  - 1000
		{spawn = "tazer-bot", 								weight = 400 	- (factor/4)}, -- 400  -  150
		{spawn = "laser-bot", 								weight = 50 	+ (factor/4)}, --  50  -  300
		{spawn = "plasma-bot", 								weight = 5 		+ (factor)},   --   5  - 1005
	}

	local enemy_options_tier4 = 
	{
		{spawn = "scout-car",  weight = 100}, -- 100 
		{spawn = "shell-tank", weight =  50}, --  15
		{spawn = "laser-bot",  weight = 100}, -- 100
		{spawn = "plasma-bot", weight =  50}, --  50
	}
	
	if global.last_mission == true then 
		enemy_options = enemy_options_tier4
	elseif global.level <= 5 then 
		enemy_options = enemy_options_tier1
	elseif global.level <= 10 then 
		enemy_options = enemy_options_tier2
	else 
		enemy_options = enemy_options_tier3
	end
		
	local calculate_odds = {}
	for k, spawn in ipairs(enemy_options) do
		for i=1, spawn.weight do
			calculate_odds[#calculate_odds+1] = k
		end
	end

	local random_num = #calculate_odds
	return enemy_options[calculate_odds[math.random(random_num)]]
end

function create_enemy_forces()
	global.attack_counter = global.attack_counter + 1

	if global.attack_counter >= ((attack_interval * 60 * 60) - (global.level * 180) - global.attack_increase) then
		
		if global.last_mission then 
			additional_count = 10 * difficulty["additional_count"]
		else
			additional_count = 1 * difficulty["additional_count"]
		end

		local time_left = get_time_left()
		global.attack_increase = global.attack_increase + difficulty["attack_increase"] -- This will increse the attack frequency over time.

		if time_left <= 0 then
			for i = 1, (global.level + additional_count) do
				local position = {}
				local enemy_table = get_enemy_to_spawn()
				local enemy_name = enemy_table.spawn
				local radius = 2.5
				local spawn_radius = (400 + (global.level * 20))
				local x_offset = math.random(-spawn_radius, spawn_radius) 
				local y_offset = math.random(-spawn_radius, spawn_radius) 
				local save_zone = 100 - (global.attack_increase / 15)
				if x_offset >= 0 and x_offset < save_zone then x_offset = x_offset + save_zone elseif x_offset >= (save_zone*-1) then x_offset = x_offset - save_zone end
				if y_offset >= 0 and y_offset < save_zone then y_offset = y_offset + save_zone elseif y_offset >= (save_zone*-1) then y_offset = y_offset - save_zone end
				local position = {x_offset, y_offset}
				local area = {{x_offset - radius, y_offset - radius}, {x_offset + radius, y_offset + radius}}			
			
				for _, force in pairs(game.forces) do
					if force.name == "enemy" then
						force.chart(game.surfaces[1], area)					
					end
				end
			
				local PositionValid = game.surfaces[1].find_non_colliding_position(enemy_name, position, 2, 0.5)
				if PositionValid then
					spawn_enemy_unit = game.surfaces[1].create_entity({name = enemy_name, position = PositionValid , force = game.forces.palyer})
				end
			end
		end
	--- Send the units to attack
	create_attack_group(global.level)
	global.attack_counter = 0
	end	
end

local function shuffle(tbl)
	local size = #tbl
		for i = size, 1, -1 do
			local rand = math.random(size)
			tbl[i], tbl[rand] = tbl[rand], tbl[i]
		end
	return tbl
end

function create_attack_group(level)
	local radius = (50 + (level * 5))
	local surface = game.surfaces[1]
	local harvesters = {"vehicle-miner", "vehicle-miner-mk2", "vehicle-miner-mk3", "vehicle-miner-mk4", "vehicle-miner-mk5", "electric-mining-drill", "dune-palace"}
	local palace = surface.find_entities_filtered({name = "dune-palace"})
	local target_harvester = {}	
	local unit_groups = {}
	
	for _, word in pairs(harvesters) do			
		local units = surface.find_entities_filtered({name = word})
		if #units > 0 then	
			for i = 1, #units do
				table.insert(target_harvester, {entity = units[i], x = units[i].position.x, y = units[i].position.x})
			end
		end
	end
	
	if #target_harvester > 0 then	
		target_harvester = shuffle(target_harvester)
		for i = 1, #target_harvester do
			unit_groups[i] = surface.create_unit_group({position = target_harvester[i].entity.position})
			local enemy_units = surface.find_enemy_units(target_harvester[i].entity.position, radius, "player")
			for _, enemy_unit in pairs(enemy_units) do
				unit_groups[i].add_member(enemy_unit)
				unit_groups[i].set_command({
					type = defines.command.compound,
					structure_type = defines.compound_command.logical_and,
					commands =
					{
						{
							type = defines.command.attack_area,
							destination = {target_harvester[1].x, target_harvester[1].y},
							radius = 32,
							distraction = defines.distraction.by_anything
						},						
						{
							type = defines.command.attack_area,
							destination = palace[1].position,
							radius = 32,
							distraction = defines.distraction.by_anything
						},
						{
							type = defines.command.attack,
							target = palace[1],
							distraction = defines.distraction.by_enemy
						}					
					}
				})
				unit_groups[i].start_moving()
			end
		end		
	end
end	

function create_attack_group_alt(level)
	
	local surface = game.surfaces[1]
	local radius = (25 + (level * 15))
	local units = surface.find_entities_filtered({type = "unit"})
	units = shuffle(units)
	local unit_groups = {}
	
	for i = 1, 2, 1 do
		if not units[i] then break end
		if not units[i].valid then break end
		unit_groups[i] = surface.create_unit_group({position = {x = units[i].position.x, y = units[i].position.y}})
		local biters = surface.find_enemy_units(units[i].position, radius, "player")
		for _, biter in pairs(biters) do
			unit_groups[i].add_member(biter)
		end
	end
	
	--	Targets
	local harvesters = {"vehicle-miner", "vehicle-miner-mk2", "vehicle-miner-mk3", "vehicle-miner-mk4", "vehicle-miner-mk5", "electric-mining-drill", "dune-palace"}
	local target_harvester = {}	

	for _, word in pairs(harvesters) do			
		local units = surface.find_entities_filtered({name = word})
		
		if #units > 0 then	
			for i = 1, #units do
				table.insert(target_harvester, {x = units[i].position.x, y = units[i].position.x})
			end
		end
	end

	local palace = surface.find_entities_filtered({name = "dune-palace"})
	target_harvester = shuffle(target_harvester)
	
	if #unit_groups > 0 then
		for i = 1, #unit_groups, 1 do
		if unit_groups[i].valid then
			if #unit_groups[i].members > 0 then
				unit_groups[i].set_command({
					type = defines.command.compound,
					structure_type = defines.compound_command.logical_and,
					commands = 
					{
						{
							type = defines.command.attack_area,
							destination = {target_harvester[1].x, target_harvester[1].y},
							radius = 32,
							distraction = defines.distraction.by_anything
						},						
						{
							type = defines.command.attack_area,
							destination = palace[1].position,
							radius = 32,
							distraction = defines.distraction.by_anything
						},
						
						{
							type = defines.command.attack,
							target = palace[1],
							distraction = defines.distraction.by_enemy
						}					
					}
				})
					
				unit_groups[i].start_moving()
				else
					unit_groups[i].destroy()
				end
			end
		end
	end
end

---------------------------------------------------------------------------------

script.on_init(On_Init)
script.on_configuration_changed(On_Config_Change)

local death_events = {defines.events.on_entity_died, defines.events.script_raised_destroy}
script.on_event(death_events, On_Death)
