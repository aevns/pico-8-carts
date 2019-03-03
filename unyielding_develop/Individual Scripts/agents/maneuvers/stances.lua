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