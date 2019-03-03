-- agent type definitions --

shade = agent:new({
    sprite = 21,
})

skeleton = agent:new({
    sprite = 48,
    hp = 2,
    base_stance = skeleton_stance
})

knight = agent:new({
    sprite = 32,
    hp = 3,
    base_stance = knight_stance
})

skulltula = agent:new({
    sprite = 37,
    sprite_offset = 0,
    hp = 1,
    base_speed = 1/8,
    base_stance = skulltula_stance
})

giant_bat = agent:new({
    sprite = 53,
    sprite_offset = 0,
    hp = 1,
    base_speed = 3/32,
    pathable = 5,
    base_stance = giant_bat_stance
})

golem = agent:new({
    size = 2,
    collider_size = 1.5,
    sprite = 12,
    sprite_offset = -1/2,
    hp = 3,
    defense = 1,
    base_speed = 1/32,
    base_stance = golem_stance,
})

-- agent function overrides --