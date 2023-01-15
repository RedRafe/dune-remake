if mods["aai-programmable-vehicles"] then
  data.raw["bool-setting"]["vehicle-mining-requires-movement"].default_value = false
else
  data.raw["bool-setting"]["vehicle-mining-requires-movement"].hidden = true
  data.raw["bool-setting"]["vehicle-mining-requires-movement"].forced_value = false
end