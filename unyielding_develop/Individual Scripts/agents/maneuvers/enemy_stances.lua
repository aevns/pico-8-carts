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