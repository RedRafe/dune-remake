--require ("util")

--- Thanks to Darkfrei for this code!
-- https://mods.factorio.com/mod/MovingWorms

local worms = {}
local distraction_cooldown = 300
local vision_distance = 30
local min_pursue_time = 10 * 60
local max_pursue_distance = 50


local worm_stats = {
  ['small-worm-turret']    = { cooldown = 1, movement_speed = 0.185, range_bonus = 1.2, pollution_to_join_attack = 4   },
  ['medium-worm-turret']   = { cooldown = 1, movement_speed = 0.165, range_bonus = 1.4, pollution_to_join_attack = 12  },
  ['big-worm-turret']      = { cooldown = 1, movement_speed = 0.150, range_bonus = 1.6, pollution_to_join_attack = 30  },
  ['behemoth-worm-turret'] = { cooldown = 1, movement_speed = 0.150, range_bonus = 1.8, pollution_to_join_attack = 200 },
  ['default']              = { cooldown = 1, movement_speed = 0.185, range_bonus = 1.2, pollution_to_join_attack = 4   }
}

local function get_worm_stats(worm_name)
  if worm_stats[worm_name] == nil then 
    return worm_stats['default']
  end
  return worm_stats[worm_name]
end

for worm_name, worm_turret in pairs (data.raw.turret) do
  if string.match(worm_name, "worm") then
    local worm = table.deepcopy(worm_turret)
    --data.raw.turret[worm_name].autoplace = nil
    worm.type = 'unit'
    worm.name = 'unit-' .. worm_name
    worm.localised_name = { 'entity-name.' .. worm_name }
    worm.distraction_cooldown = 300
    worm.vision_distance = 30
    worm.min_pursue_time = 10 * 60
    worm.max_pursue_distance = 50
    worm.distance_per_frame = 0.04
    worm.move_while_shooting = true
    worm.rotation_speed = 0.8 -- 1
    worm.healing_per_tick = 0.01
    worm.run_animation = worm.prepared_animation
    worm.attack_parameters.animation = worm.starting_attack_animation
    -- v.1.3
    worm.pollution_to_join_attack = get_worm_stats(worm_name).pollution_to_join_attack
    worm.movement_speed = 0.5 * get_worm_stats(worm_name).movement_speed
    worm.attack_parameters.cooldown = 2.5 * 60 --worm.attack_parameters.cooldown * get_worm_stats(worm_name).cooldown --4 * 60
    worm.attack_parameters.range = worm.attack_parameters.range * get_worm_stats(worm_name).range_bonus
    worm.attack_parameters.lead_target_for_projectile_speed = 0.5 * worm_turret.attack_parameters.lead_target_for_projectile_speed
    --worm.collision_mask = {"player-layer", "train-layer", "not-colliding-with-itself"}

    table.insert(worms, worm)
  end
end

data:extend(worms)

--[[
local attack_parameters = {
  ["small-worm-turret"] =
  {
    type = "turret",
    name = "small-worm-turret",
    icon = "__base__/graphics/icons/small-worm.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-enemy", "placeable-off-grid", "not-repairable", "breaths-air"},
    order="b-c-a",
    max_health = 200,
    subgroup="enemies",
    resistances = {},
    healing_per_tick = 0.01,
    collision_box = {{-0.9, -0.8 }, {0.9, 0.8}},
    map_generator_bounding_box = {{-1.9, -1.8}, {1.9, 1.8}},
    selection_box = {{-0.9, -0.8 }, {0.9, 0.8}},
    damaged_trigger_effect = hit_effects.biter(),
    shooting_cursor_size = 3,
    corpse = "small-worm-corpse",
    dying_explosion = "small-worm-die",
    dying_sound = sounds.worm_dying_small(0.57),
    folded_speed = 0.01,
    folded_speed_secondary = 0.024,
    folded_animation = worm_folded_animation(scale_worm_small, tint_worm_small),
    preparing_speed = 0.024,
    preparing_animation = worm_preparing_animation(scale_worm_small, tint_worm_small, "forward"),
    preparing_sound = sounds.worm_standup_small(1),
    prepared_speed = 0.024,
    prepared_speed_secondary = 0.012,
    prepared_sound = sounds.worm_breath(0.6),
    prepared_animation = worm_prepared_animation(scale_worm_small, tint_worm_small),
    prepared_alternative_speed = 0.024,
    prepared_alternative_speed_secondary = 0.018,
    prepared_alternative_chance = 0.2,
    prepared_alternative_animation = worm_prepared_alternative_animation(scale_worm_small, tint_worm_small),
    prepared_alternative_sound = sounds.worm_roar_alternative(0.64),
    starting_attack_speed = 0.034,
    starting_attack_animation = worm_start_attack_animation(scale_worm_small, tint_worm_small),
    starting_attack_sound = sounds.worm_roars(0.62),
    ending_attack_speed = 0.016,
    ending_attack_animation = worm_end_attack_animation(scale_worm_small, tint_worm_small),
    folding_speed = 0.015,
    folding_animation =  worm_preparing_animation(scale_worm_small, tint_worm_small, "backward"),
    folding_sound = sounds.worm_fold(1),
    secondary_animation = true,
    random_animation_offset = true,
    attack_from_start_frame = true,

    integration = worm_integration(scale_worm_small),
    prepare_range = range_worm_small + prepare_range_worm_small,
    allow_turning_when_starting_attack = true,
    attack_parameters =
    {
      type = "stream",
      cooldown = 4,
      range = range_worm_small,--defined in spitter-projectiles.lua
      damage_modifier = damage_modifier_worm_small,--defined in spitter-projectiles.lua
      min_range = 0,
      projectile_creation_parameters = worm_shoot_shiftings(scale_worm_small, scale_worm_small * scale_worm_stream),
      use_shooter_direction = true,

      lead_target_for_projectile_speed = 0.2* 0.75 * 1.5 *1.5, -- this is same as particle horizontal speed of flamethrower fire stream

      ammo_type =
      {
        category = "biological",
        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "stream",
            stream = "acid-stream-worm-small",
            source_offset = {0.15, -0.5}
          }
        }
      },

      cyclic_sound =
      {
        begin_sound =
        {
          {
            filename = "__base__/sound/creatures/worm-spit-start.ogg",
            volume = 0.0
          },
          {
            filename = "__base__/sound/creatures/worm-spit-start-2.ogg",
            volume = 0.0
          },
          {
            filename = "__base__/sound/creatures/worm-spit-start-3.ogg",
            volume = 0.0
          }
        },
        --middle_sound =
      -- {
          --{
          -- filename = "__base__/sound/fight/flamethrower-mid.ogg",
            --volume = 0.7
          --}
        --},
        end_sound =
        {
          {
            filename = "__base__/sound/creatures/worm-spit-end.ogg",
            volume = 0.0
          }
        }
      }
    },
    --{
    --  type = "stream",
    --  ammo_category = "bullet",
    --  cooldown = 15,
    --  range = 21,
    --  projectile_creation_parameters = worm_shoot_shiftings(scale_worm_small),
    --  use_shooter_direction = true,
    --  damage_modifier = 2.5,
    --  ammo_type =
    --  {
    --    category = "biological",
    --    action =
    --    {
    --      type = "direct",
    --      action_delivery =
    --      {
    --        type = "stream",
    --        stream = "acid-stream-small",
    --        starting_speed = 0.5,
    --        max_range = 50,
    --      }
    --    }
    --  }
    --},
    autoplace = enemy_autoplace.enemy_worm_autoplace(0),
    call_for_help_radius = 40,
    spawn_decorations_on_expansion = true,
    spawn_decoration =
    {
      {
        decorative = "worms-decal",
        spawn_min = 0,
        spawn_max = 2,
        spawn_min_radius = 1,
        spawn_max_radius = 2
      },
      {
        decorative = "shroom-decal",
        spawn_min = 1,
        spawn_max = 1,
        spawn_min_radius = 1,
        spawn_max_radius = 2
      },
      {
        decorative = "enemy-decal",
        spawn_min = 1,
        spawn_max = 2,
        spawn_min_radius = 0,
        spawn_max_radius = 1
      },
      {
        decorative = "enemy-decal-transparent",
        spawn_min = 2,
        spawn_max = 4,
        spawn_min_radius = 1,
        spawn_max_radius = 2
      }
    }
  },
  ["medium-worm-turret"] = 
  {
    type = "turret",
    name = "medium-worm-turret",
    icon = "__base__/graphics/icons/medium-worm.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-player", "placeable-enemy", "placeable-off-grid", "not-repairable", "breaths-air"},
    order="b-c-b",
    subgroup="enemies",
    max_health = 400,
    resistances =
    {
      {
        type = "physical",
        decrease = 5
      },
      {
        type = "explosion",
        decrease = 5,
        percent = 15
      },
      {
        type = "fire",
        decrease = 2,
        percent = 50
      }
    },
    healing_per_tick = 0.015,
    collision_box = {{-1.1, -1.0}, {1.1, 1.0}},
    map_generator_bounding_box = {{-2.1, -2.0}, {2.1, 2.0}},
    selection_box = {{-1.1, -1.0}, {1.1, 1.0}},
    damaged_trigger_effect = hit_effects.biter(),
    shooting_cursor_size = 3.5,
    rotation_speed = 1,
    corpse = "medium-worm-corpse",
    dying_explosion = "medium-worm-die",
    dying_sound = sounds.worm_dying_small(0.65),
    folded_speed = 0.01,
    folded_speed_secondary = 0.024,
    folded_animation = worm_folded_animation(scale_worm_medium, tint_worm_medium),
    preparing_speed = 0.024,
    prepared_speed = 0.024,
    prepared_speed_secondary = 0.012,
    preparing_animation = worm_preparing_animation(scale_worm_medium, tint_worm_medium, "forward"),
    preparing_sound = sounds.worm_standup(1),
    prepared_sound = sounds.worm_breath(0.8),
    prepared_alternative_speed = 0.014,
    prepared_alternative_speed_secondary = 0.010,
    prepared_alternative_chance = 0.2,
    prepared_alternative_animation = worm_prepared_alternative_animation(scale_worm_medium, tint_worm_medium),
    prepared_alternative_sound = sounds.worm_roar_alternative(0.68),
    prepared_animation = worm_prepared_animation(scale_worm_medium, tint_worm_medium),
    starting_attack_speed = 0.034,
    starting_attack_animation = worm_start_attack_animation(scale_worm_medium, tint_worm_medium),
    starting_attack_sound = sounds.worm_roars(0.68),
    ending_attack_speed = 0.016,
    ending_attack_animation = worm_end_attack_animation(scale_worm_medium, tint_worm_medium),
    folding_speed = 0.015,
    folding_animation =  worm_preparing_animation(scale_worm_medium, tint_worm_medium, "backward"),
    folding_sound = sounds.worm_fold(1),
    secondary_animation = true,
    random_animation_offset = true,
    attack_from_start_frame = true,

    integration = worm_integration(scale_worm_medium),
    prepare_range = range_worm_medium + prepare_range_worm_medium,
    allow_turning_when_starting_attack = true,

    attack_parameters =
    {
      type = "stream",
      cooldown = 4,
      range = range_worm_medium,--defined in spitter-projectiles.lua
      damage_modifier = damage_modifier_worm_medium,--defined in spitter-projectiles.lua
      min_range = 0,
      projectile_creation_parameters = worm_shoot_shiftings(scale_worm_medium, scale_worm_medium * scale_worm_stream),

      use_shooter_direction = true,

      lead_target_for_projectile_speed = 0.2* 0.75 * 1.5 *1.5, -- this is same as particle horizontal speed of flamethrower fire stream

      ammo_type =
      {
        category = "biological",
        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "stream",
            stream = "acid-stream-worm-medium",
            source_offset = {0.15, -0.5}
          }
        }
      }
    },
    build_base_evolution_requirement = 0.3,
    autoplace = enemy_autoplace.enemy_worm_autoplace(2),
    call_for_help_radius = 40,
    spawn_decorations_on_expansion = true,
    spawn_decoration =
    {
      {
        decorative = "worms-decal",
        spawn_min = 1,
        spawn_max = 2,
        spawn_min_radius = 1,
        spawn_max_radius = 3
      },
      {
        decorative = "shroom-decal",
        spawn_min = 1,
        spawn_max = 2,
        spawn_min_radius = 1,
        spawn_max_radius = 2
      },
      {
        decorative = "enemy-decal",
        spawn_min = 1,
        spawn_max = 3,
        spawn_min_radius = 0,
        spawn_max_radius = 3
      },
      {
        decorative = "enemy-decal-transparent",
        spawn_min = 2,
        spawn_max = 4,
        spawn_min_radius = 1,
        spawn_max_radius = 3
      }
    }
  },
  ["big-worm-turret"] =
  {
    type = "turret",
    name = "big-worm-turret",
    icon = "__base__/graphics/icons/big-worm.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-player", "placeable-enemy", "placeable-off-grid", "not-repairable", "breaths-air"},
    max_health = 750,
    order="b-c-c",
    subgroup="enemies",
    resistances =
    {
      {
        type = "physical",
        decrease = 10
      },
      {
        type = "explosion",
        decrease = 10,
        percent = 30
      },
      {
        type = "fire",
        decrease = 3,
        percent = 70
      }
    },
    healing_per_tick = 0.02,
    collision_box = {{-1.4, -1.2}, {1.4, 1.2}},
    map_generator_bounding_box = {{-2.4, -2.2}, {2.4, 2.2}},
    selection_box = {{-1.4, -1.2}, {1.4, 1.2}},
    damaged_trigger_effect = hit_effects.biter(),
    shooting_cursor_size = 4,
    rotation_speed = 1,
    corpse = "big-worm-corpse",
    dying_explosion = "big-worm-die",
    dying_sound = sounds.worm_dying(0.7),
    folded_speed = 0.01,
    folded_speed_secondary = 0.024,
    folded_animation = worm_folded_animation(scale_worm_big, tint_worm_big),
    preparing_speed = 0.024,
    preparing_animation = worm_preparing_animation(scale_worm_big, tint_worm_big, "forward"),
    preparing_sound = sounds.worm_standup(1),
    prepared_speed = 0.024,
    prepared_speed_secondary = 0.012,
    prepared_animation = worm_prepared_animation(scale_worm_big, tint_worm_big),
    prepared_sound = sounds.worm_breath_big(1),
    prepared_alternative_speed = 0.014,
    prepared_alternative_speed_secondary = 0.010,
    prepared_alternative_chance = 0.2,
    prepared_alternative_animation = worm_prepared_alternative_animation(scale_worm_big, tint_worm_big),
    prepared_alternative_sound = sounds.worm_roar_alternative_big(0.72),
    starting_attack_speed = 0.034,
    starting_attack_animation = worm_start_attack_animation(scale_worm_big, tint_worm_big),
    starting_attack_sound = sounds.worm_roars_big(0.67),
    ending_attack_speed = 0.016,
    ending_attack_animation = worm_end_attack_animation(scale_worm_big, tint_worm_big),
    folding_speed = 0.015,
    folding_animation =  worm_preparing_animation(scale_worm_big, tint_worm_big, "backward"),
    folding_sound = sounds.worm_fold(1),
    integration = worm_integration(scale_worm_big),
    secondary_animation = true,
    random_animation_offset = true,
    attack_from_start_frame = true,

    prepare_range = range_worm_big + prepare_range_worm_big,
    allow_turning_when_starting_attack = true,
    attack_parameters =
    {
      type = "stream",
      damage_modifier = damage_modifier_worm_big,--defined in spitter-projectiles.lua
      cooldown = 4,
      range = range_worm_big,--defined in spitter-projectiles.lua
      min_range = 0,
      projectile_creation_parameters = worm_shoot_shiftings(scale_worm_big, scale_worm_big * scale_worm_stream),

      use_shooter_direction = true,

      lead_target_for_projectile_speed = 0.2* 0.75 * 1.5 * 1.5, -- this is same as particle horizontal speed of flamethrower fire stream

      ammo_type =
      {
        category = "biological",
        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "stream",
            stream = "acid-stream-worm-big",
            source_offset = {0.15, -0.5}
          }
        }
      }
    },
    build_base_evolution_requirement = 0.5,
    autoplace = enemy_autoplace.enemy_worm_autoplace(5),
    call_for_help_radius = 40,
    spawn_decorations_on_expansion = true,
    spawn_decoration =
    {
      {
        decorative = "worms-decal",
        spawn_min = 1,
        spawn_max = 2,
        spawn_min_radius = 1,
        spawn_max_radius = 4
      },
      {
        decorative = "shroom-decal",
        spawn_min = 1,
        spawn_max = 2,
        spawn_min_radius = 1,
        spawn_max_radius = 2
      },
      {
        decorative = "enemy-decal",
        spawn_min = 1,
        spawn_max = 4,
        spawn_min_radius = 1,
        spawn_max_radius = 3
      },
      {
        decorative = "enemy-decal-transparent",
        spawn_min = 3,
        spawn_max = 5,
        spawn_min_radius = 1,
        spawn_max_radius = 4
      }
    }
  },
  ["behemoth-worm-turret"] =
  {
    type = "turret",
    name = "behemoth-worm-turret",
    icon = "__base__/graphics/icons/behemoth-worm.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-player", "placeable-enemy", "placeable-off-grid", "not-repairable", "breaths-air"},
    max_health = 750,
    order="b-c-d",
    subgroup="enemies",
    resistances =
    {
      {
        type = "physical",
        decrease = 10
      },
      {
        type = "explosion",
        decrease = 10,
        percent = 30
      },
      {
        type = "fire",
        decrease = 3,
        percent = 70
      }
    },
    healing_per_tick = 0.02,
    collision_box = {{-1.4, -1.2}, {1.4, 1.2}},
    map_generator_bounding_box = {{-2.4, -2.2}, {2.4, 2.2}},
    selection_box = {{-1.4, -1.2}, {1.4, 1.2}},
    damaged_trigger_effect = hit_effects.biter(),
    shooting_cursor_size = 4,
    rotation_speed = 1,
    corpse = "behemoth-worm-corpse",
    dying_explosion = "behemoth-worm-die",
    dying_sound = sounds.worm_dying_big(0.72),
    folded_speed = 0.01,
    folded_speed_secondary = 0.024,
    folded_animation = worm_folded_animation(scale_worm_behemoth, tint_worm_behemoth),
    preparing_speed = 0.024,
    preparing_animation = worm_preparing_animation(scale_worm_behemoth, tint_worm_behemoth, "forward"),
    preparing_sound = sounds.worm_standup(1),
    prepared_speed = 0.024,
    prepared_speed_secondary = 0.012,
    prepared_animation = worm_prepared_animation(scale_worm_behemoth, tint_worm_behemoth),
    prepared_sound = sounds.worm_breath_big(1),
    prepared_alternative_speed = 0.014,
    prepared_alternative_speed_secondary = 0.010,
    prepared_alternative_chance = 0.2,
    prepared_alternative_animation = worm_prepared_alternative_animation(scale_worm_behemoth, tint_worm_behemoth),
    prepared_alternative_sound = sounds.worm_roar_alternative_big(0.87),
    starting_attack_speed = 0.034,
    starting_attack_animation = worm_start_attack_animation(scale_worm_behemoth, tint_worm_behemoth),
    starting_attack_sound = sounds.worm_roars_big(0.81),
    ending_attack_speed = 0.016,
    ending_attack_animation = worm_end_attack_animation(scale_worm_behemoth, tint_worm_behemoth),
    folding_speed = 0.015,
    folding_animation =  worm_preparing_animation(scale_worm_behemoth, tint_worm_behemoth, "backward"),
    folding_sound = sounds.worm_fold(1),
    integration = worm_integration(scale_worm_behemoth),
    secondary_animation = true,
    random_animation_offset = true,
    attack_from_start_frame = true,

    prepare_range = range_worm_behemoth + prepare_range_worm_behemoth,
    allow_turning_when_starting_attack = true,
    attack_parameters =
    {
      type = "stream",
      ammo_category = "biological",
      damage_modifier = damage_modifier_worm_behemoth,--defined in spitter-projectiles.lua
      cooldown = 4,
      range = range_worm_behemoth,--defined in spitter-projectiles.lua
      min_range = 0,
      projectile_creation_parameters = worm_shoot_shiftings(scale_worm_behemoth, scale_worm_behemoth * scale_worm_stream),
      use_shooter_direction = true,

      lead_target_for_projectile_speed = 0.2* 0.75 * 1.5 * 1.5, -- this is same as particle horizontal speed of flamethrower fire stream

      ammo_type =
      {
        category = "biological",
        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "stream",
            stream = "acid-stream-worm-behemoth",
            source_offset = {0.15, -0.5}
          }
        }
      }
    },
    build_base_evolution_requirement = 0.9,
    autoplace = enemy_autoplace.enemy_worm_autoplace(8),
    call_for_help_radius = 80,
    spawn_decorations_on_expansion = true,
    spawn_decoration =
    {
      {
        decorative = "worms-decal",
        spawn_min = 1,
        spawn_max = 3,
        spawn_min_radius = 1,
        spawn_max_radius = 5
      },
      {
        decorative = "shroom-decal",
        spawn_min = 1,
        spawn_max = 2,
        spawn_min_radius = 1,
        spawn_max_radius = 2
      },
      {
        decorative = "enemy-decal",
        spawn_min = 1,
        spawn_max = 4,
        spawn_min_radius = 1,
        spawn_max_radius = 4
      },
      {
        decorative = "enemy-decal-transparent",
        spawn_min = 3,
        spawn_max = 5,
        spawn_min_radius = 1,
        spawn_max_radius = 4
      }
    }
  },
}
]]