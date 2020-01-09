-- maneuvers --

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

-- stances --
stance = class:new({
    aura = nil,
    move_speed = nil,
    duration = 1,

    attack_ready = nil,
    attack = nil,
    hold = nil,
    evade_ready = nil,
    evade = nil
})

-- stances --
default_stance = stance:new()
attack_stance = stance:new()
attack_stance_2 = stance:new()
guard_stance = stance:new()
guard_stance_2 = stance:new()
evade_stance = stance:new()
evade_stance_2 = stance:new()

-- stance definitions --
default_stance:set({
    aura = 0,
    attack_ready = attack_stance,
    evade_ready = evade_stance
})

attack_stance:set({
    aura = 2,
    move_speed = 0,
    duration = 30,

    attack = strike,
    hold = attack_stance_2,
    evade_ready = guard_stance
})

attack_stance_2:set({
    aura = 8,
    move_speed = 0,
    duration = 60,

    attack = strike_2,
    hold = strike_2,
    evade_ready = guard_stance
})

guard_stance:set({
    aura = 3,
    move_speed = 0,
    duration = 30,

    attack = bash,
    hold = guard_stance_2,
    evade = block
})

guard_stance_2:set({
    aura = 11,
    move_speed = 0,
    duration = 60,

    attack = bash_2,
    hold = block_2,
    evade = block
})

evade_stance:set({
    aura = 1,
    move_speed = 0,
    duration = 30,

    attack_ready = guard_stance,
    hold = evade_stance_2,
    evade = dash
})

evade_stance_2:set({
    aura = 12,
    move_speed = 0,
    duration = 60,

    attack_ready = guard_stance,
    hold = dash_strike_2,
    evade = dash_strike
})

-- enemy stances --
skeleton_stance = stance:new()
skeleton_attack = stance:new()

knight_stance = stance:new()
knight_attack = stance:new()

giant_bat_stance = stance:new()
giant_bat_attack = stance:new()

skulltula_stance = stance:new()
skulltula_attack = stance:new()

golem_stance = stance:new()
golem_attack = stance:new()

-- enemy stance definitions --
skeleton_stance:set({
    aura = 0,
    attack_ready = skeleton_attack,
    evade_ready = skeleton_attack
})

skeleton_attack:set({
    aura = 8,
    duration = 30,
    attack = strike,
    evade = dash_strike,
    hold = dash
})

knight_stance:set({
    aura = 0,
    attack_ready = knight_attack,
    evade_ready = knight_attack,
})

knight_attack:set({
    aura = 8,
    duration = 30,
    attack = strike,
    evade = block,
    hold = bash
})

giant_bat_stance:set({
    aura = 0,
    attack_ready = giant_bat_attack,
    evade_ready = giant_bat_attack
})

giant_bat_attack:set({
    aura = 8,
    duration = 30,
    attack = dash_strike,
    evade = dash
})

skulltula_stance:set({
    aura = 0,
    attack_ready = skulltula_attack,
    evade_ready = skulltula_attack
})

skulltula_attack:set({
    aura = 8,
    duration = 30,
    attack = bash,
    evade = dash,
    hold = bash
})

golem_stance:set({
    aura = 0,
    attack_ready = golem_attack,
    evade_ready = golem_attack,
})

golem_attack:set({
    aura = 8,
    duration = 30,
    attack = strike_2,
    evade = bash,
    hold = bash_2
})