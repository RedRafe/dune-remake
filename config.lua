difficulty_mode = 
{
  ["Piece of cake"] = {
    ["time_modifier"]    = 3,
    ["time_per_level"]   = 600,
    ["award_multiplier"] = 5,
    ["evo_increase"]     = 0.015,
    ["worker_interval"]  = 1,
    ["attack_interval"]  = 2,
    ["attack_increase"]  = 5,
    ["additional_count"] = 1,
    ["alternative_atk"]  = 1,
    ["patches_worms"]    = 1,
    ["point_multiplier"] = 0.25
  },
  ["Easy"] = {
    ["time_modifier"]    = 2,
    ["time_per_level"]   = 600,
    ["award_multiplier"] = 2,
    ["evo_increase"]     = 0.020,
    ["worker_interval"]  = 1,
    ["attack_interval"]  = 2,
    ["attack_increase"]  = 10,
    ["additional_count"] = 1,
    ["alternative_atk"]  = 1,
    ["patches_worms"]    = 1,
    ["point_multiplier"] = 0.5
  },
  ["Normal"] = {
    ["time_modifier"]    = 1,
    ["time_per_level"]   = 600,
    ["award_multiplier"] = 1,
    ["evo_increase"]     = 0.025,
    ["worker_interval"]  = 2,
    ["attack_interval"]  = 2,
    ["attack_increase"]  = 15,
    ["additional_count"] = 1,
    ["alternative_atk"]  = 1,
    ["patches_worms"]    = 1,
    ["point_multiplier"] = 1
  },
  ["Hard"] = {
    ["time_modifier"]    = 0.95,
    ["time_per_level"]   = 600,
    ["award_multiplier"] = 1,
    ["evo_increase"]     = 0.035,
    ["worker_interval"]  = 2,
    ["attack_interval"]  = 2,
    ["attack_increase"]  = 20,
    ["additional_count"] = 2,
    ["alternative_atk"]  = 1.5,
    ["patches_worms"]    = 2,
    ["point_multiplier"] = 2
  },
  ["Nightmare"] = {
    ["time_modifier"]    = 0.9,
    ["time_per_level"]   = 600,
    ["award_multiplier"] = 1,
    ["evo_increase"]     = 0.050,
    ["worker_interval"]  = 2,
    ["attack_interval"]  = 1,
    ["attack_increase"]  = 25,
    ["additional_count"] = 4,
    ["alternative_atk"]  = 2,
    ["patches_worms"]    = 2,
    ["point_multiplier"] = 5
  }
}

selected_difficulty = settings.global["dune-remake-difficulty"].value
difficulty = difficulty_mode[selected_difficulty]

time_modifier 	        = difficulty["time_modifier"] * settings.global["Time_Multiplier"].value
award_multiplier        = difficulty["award_multiplier"] * settings.global["Award_Multiplier"].value
evo_increase_per_level 	= difficulty["evo_increase"]
time_per_level 				 	= difficulty["time_per_level"]
worker_spawn_time 		 	= difficulty["worker_interval"]
attack_interval 			 	= difficulty["attack_interval"]

-- Not used
points_per_second_start 				 = 5   * difficulty["point_multiplier"]
points_per_second_level_subtract = 0.2 * difficulty["point_multiplier"]


levels =
{
  -- 1
  {
    requirements = {{ name = "melange", count = 100 }},
    time = time_per_level / 2 -- 5 Min  
  },
  -- 2
  {
    requirements = {{ name = "melange", count = 1000 }},
    time = time_per_level / 2 -- 5 Min 
  },
  -- 3
  {
    requirements = {{ name = "melange", count = 1500 }},
    time = time_per_level / 2 -- 5 Min 
  },
  -- 4
  {
    requirements = {{ name = "melange", count = 2500 }},
    time = time_per_level / 2 -- 5 Min  -- 20 min of game time up.
  },
  -- 5
  {
    requirements = {{ name = "melange", count = 4000 }},
    time = time_per_level -- 10 Min  
  },
  -- 6
  {
    requirements = {{ name = "melange", count = 6500 }},
    time = time_per_level -- 10 Min 
  },
  -- 7
  {
    requirements = {{ name = "melange", count = 10000 }},
    time = time_per_level -- 10 Min  -- 50 min in. Need to produce at 1,000 per min
  },
  -- 8
  {
    requirements = {{ name = "melange", count = 12000 }},
    time = time_per_level -- 10 Min 
  },
  -- 9
  {
    requirements = {{ name = "melange", count = 14000 }},
    time = time_per_level -- 10 Min 
  },
  -- 10
  {
    requirements = {{ name = "melange", count = 16000 }},
    time = time_per_level -- 10 Min 
  },
  -- 11
  {
    requirements = {{ name = "melange", count = 20000 }},
    time = time_per_level -- 10 Min Produce 2K/min
  },
  -- 12
  {
    requirements = {{ name = "melange", count = 30000 }},
    time = time_per_level * 1.5 -- 15min
  },
  -- 13
  {
    requirements = {{ name = "melange", count = 37500 }},
    time = time_per_level * 1.5 -- 15min
  },
  -- 14
  {
    requirements = {{ name = "melange", count = 45000 }},
    time = time_per_level * 1.5 -- 15min Produce 3K/min
  },
  -- 15
  {
    requirements = {{ name = "melange", count = 52500 }},
    time = time_per_level * 1.5 -- 15min
  },
  -- 16
  {
    requirements = {{	name = "melange", count = 60000 }},
    time = time_per_level * 1.5 -- 15min 4K/min
  },
  -- 17
  {
    requirements = {{	name = "melange", count = 63750 }},
    time = time_per_level * 1.5 -- 15min
  },
  -- 18
  {
    requirements = {{	name = "melange", count = 67500 }},
    time = time_per_level * 1.5 -- 15min
  },
  -- 19
  {
    requirements = {{ name = "melange", count = 71250 }},
    time = time_per_level * 1.5 -- 15min
  },
  -- 20
  {
    requirements = {{ name = "melange", count = 75000 }},
    time = time_per_level * 1.5 -- 15min - 5K /min
  },
  -- 21 - FINAL Level
  {
    requirements = {{ name = "melange", count = 300000 }},
    time = time_per_level * 3 -- 30min 10K/Min
  }
}