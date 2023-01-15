data:extend(
{
	-- A
   {
      name = "Remove_Vanilla_Spawners",
      type = "bool-setting",
      setting_type = "startup",
      default_value = true,
      order = "a[modifier]-a[Remove_Vanilla_Spawners]",
      per_user = true,
   },
	-- B
   {
      name = "Double_Player_Reach",
      type = "bool-setting",
      setting_type = "startup",
      default_value = true,
      order = "b[modifier]-b[Double_Player_Reach]",
      per_user = true,
   },
   -- C
   {
      name = "Time_Multiplier",
      type = "double-setting",
      setting_type = "runtime-global",
      order = "c[modifier]-c[Time_Multiplier]",
      default_value = 1,
      minimum_value = 0.2,
      maximum_value = 10,
      localised_name = "Time multiplier",
      localised_decription = "Multiplies time available for each level. Default value 2. Recommended value 1. Min 0.5, max 10."
   },
   -- D
   {
      name = "Award_Multiplier",
      type = "double-setting",
      setting_type = "runtime-global",
      order = "d[modifier]-d[Award_Multiplier]",
      default_value = 1,
      minimum_value = 0.2,
      maximum_value = 10,
      localised_name = "Award multiplier",
      localised_decription = "Multiplies the amount of each resources awarded for each level succesfully completed. Default value 5. Recommended value 1. Min 1, max 10."
   },
   -- E
   {
      name = "dune-remake-difficulty",
      type = "string-setting",
      setting_type = "runtime-global",
      order = "a[base]-a[dune-remake-difficulty]",
      default_value = "Normal",
      allowed_values = {"Piece of cake", "Easy", "Normal", "Hard", "Nightmare"},
      localised_name = "Game difficulty",
      localised_decription = "Select the difficulty of Dune mod"
   },
})
