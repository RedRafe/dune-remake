local _layers = {
  {
    filename = "__dune-remake__/graphics/transparent.png",
    priority = "extra-high",
    width = 32,
    height = 42,
    shift = util.by_pixel(0.078125, -0.3),
  }
}

data:extend({
  {
    type = "simple-entity",
    name = "wall-interface",
    icon = "__base__/graphics/icons/wall.png",
    icon_size = 64,
    flags =
    {
      "not-on-map",
      "placeable-off-grid",
      "not-in-kill-statistics"
    },
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    selection_box = {{0, 0}, {0, 0}},
    hidden = true,
    pictures = 
    {
      layers = _layers
    }
  }
})
