local vanilla_floor_tile_names = { 
	["refined-hazard-concrete-right"] = "wall-interface", 
	["refined-hazard-concrete-left"]  = "wall-interface", 
	["refined-concrete"]              = "wall-interface", 
	["hazard-concrete-right"]         = "wall-interface", 
	["hazard-concrete-left"]          = "wall-interface", 
	["concrete"]                      = "wall-interface",
	["stone-path"]                    = "wall-interface"
}

local isKey = function(tile)
  if vanilla_floor_tile_names[tile] ~= nil then return true end
  return false
end

local function on_built(event)
  local tile_name     = event.tile.name
  local tile_surface  = game.surfaces[event.surface_index]

  if isKey(tile_name) then
    for _, t in pairs(event.tiles) do
      local interface = tile_surface.create_entity
      { 
        name     = "wall-interface",
        position = { t.position.x, t.position.y }
      }
      interface.destructible = false
    end
  end
end

local function on_destroy(event)
  local tile_surface  = game.surfaces[event.surface_index]

  for _, tile in pairs(event.tiles) do
    local tile_name = tile.old_tile.name
    local position  = tile.position
    if isKey(tile_name) then
      center = position
      for _, entity in pairs(tile_surface.find_entities_filtered{
        area = {{center.x-0.4, center.y-0.4}, {center.x+0.4, center.y+0.4}},
        name = "wall-interface"}) do
          if entity ~= nil then
            entity.destroy()
          end
      end
    end
  end
end

-- build events
script.on_event(defines.events.on_player_built_tile, on_built)
script.on_event(defines.events.on_robot_built_tile,  on_built)
-- destroy events
script.on_event(defines.events.on_player_mined_tile, on_destroy)
script.on_event(defines.events.on_robot_mined_tile,  on_destroy)
