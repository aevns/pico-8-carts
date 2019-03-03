-- actions --

action = class:new({
    sprite = nil,
    move_speed = 0,
    timing = {0, 0, 0, 0},

    damage = 0,
    force = 0,
    stability = 0
})

-- base actions --
stunned = action:new()
strike = action:new()
strike_2 = action:new()
dash = action:new()
dash_strike = action:new()
dash_strike_2 = action:new()
block = action:new()
block_2 = action:new()
bash = action:new()
bash_2 = action:new()

-- base action definitions --
stunned:set({
    sound = 5,
    timing = {0, 15, 0, 0},

    damage = 0,
    force = 0,
    stability = 2
})

strike:set({
    sprite = 10,
    sound = 0,
    move_speed = 1/32,
    timing = {35, 5, 10, 20},

    damage = 1,
    force = 2,
    stability = 3
})

strike_2:set({
    sprite = 11,
    sound = 1,
    move_speed = 1/16,
    timing = {65, 5, 10, 20},

    damage = 2,
    force = 3,
    stability = 4
})

dash:set({
    sound = 3,
    move_speed = 1/2,
    timing = {5, 0, 5, 30}
})

dash_strike:set({
    sprite = 10,
    sound = 0,
    move_speed = 1/2,
    timing = {35, 5, 5, 30},

    stability = 0,
    damage = 1,
    force = 2
})

dash_strike_2:set({
    sprite = 11,
    sound = 1,
    move_speed = 1/2,
    timing = {65, 5, 5, 30},

    stability = 0,
    damage = 2,
    force = 3
})

block:set({
    sprite = 42,
    sound = 1,
    move_speed = 1/64,
    timing = {5, 0, 15, 15},

    force = 1,
    stability = 5
})

block_2:set({
    sprite = 43,
    sound = 2,
    move_speed = 1/32,
    timing = {60, 0, 15, 15},

    force = 4,
    stability = 8
})

bash:set({
    sprite = 26,
    sound = 1,
    move_speed = 1/8,
    timing = {35, 10, 10, 15},

    force = 7,
    stability = 2
})

bash_2:set({
    sprite = 27,
    sound = 2,
    move_speed = 1/4,
    timing = {65, 10, 10, 15},

    damage = 1,
    force = 7,
    stability = 2
})