-- unyielding
-- by ae

-- utilities --

-- inheritance system --
class = {}

function class:new(instance)
    local instance = instance or {}
    local instance_mt = {}
    instance_mt.__index = self
    return setmetatable(instance, instance_mt)
end

function class:set(values)
    for k, v in pairs(values) do
        self[k] = v
    end
end

function class:is_child_of(instance)
    local ancestor = self
    while getmetatable(ancestor) do
        if getmetatable(ancestor).__index == instance then
            return true
        end
        ancestor = getmetatable(ancestor).__index
    end
    return false
end

-- table checks --
function contains(table, item)
    for i in all(table) do
        if i == item then
            return true
        end
    end
    return false
end

-- input --
input = {0,0,0,0,0,0}

function btnd(i)
    return btn(i) and not input[i + 1]
end

function btnu(i)
    return not btn(i) and input[i + 1]
end

function late_update_input()
    for i=0, 6 do
        input[i + 1] = btn(i)
    end
end

-- more yield options, (currently unused) --
function yield_for_time(wait_time)
    local start_time = time()
    while time() <= start_time + wait_time do
        yield()
    end
end

-- sprite overlap detection --
-- measuring distances using map units
function overlapping(a, b)
    local a_size = a.size or 1
    local b_size = b.size or 1
    return (
        a.x < b.x + b_size and
        a.x + a_size > b.x and
        a.y < b.y + b_size and
        a.y + a_size > b.y
    )
end

-- supercover raycasting --

function ray_test(a, b, flags)
    flags = flags or 1
    
    local err = nil
    if b.x == a.x then
        err = function(x, y)
            return abs(a.x - x)
        end
    else
        err = function(x, y)
            return abs(a.y + (x - a.x) * (b.y - a.y) / (b.x - a.x) - y)
        end
    end

    local x = flr(a.x) + 0.5
    local y = flr(a.y) + 0.5
    local sx = b.x > a.x and 1 or -1
    local sy = b.y > a.y and 1 or -1

    while abs(b.x - x) > 0.5 or abs(b.y - y) > 0.5 do
        if fget(mget(x, y), flags) then
            return false
        end
        if (err(x, y + sy) < err(x + sx, y)) then
            y += sy
        else
            x += sx
        end
    end
    if fget(mget(x, y), flags) then
        return false
    end
    return true
end

-- one of the closest, fastest approximations possible using rnd[x]
function rnd_nrml(std)
    local x = -3*std
    for i = 1, 3 do
        x += rnd(std*2)
    end
    return x
end
-->8
-- maneuvers --
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

action = class:new({
    sprite = nil,
    move_speed = 0,
    timing = {0, 0, 0, 0},

    damage = 0,
    force = 0,
    stability = 0
})

-- base stances --
default_stance = stance:new()
attack_stance = stance:new()
attack_stance_2 = stance:new()
guard_stance = stance:new()
guard_stance_2 = stance:new()
evade_stance = stance:new()
evade_stance_2 = stance:new()

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

-- base stance definitions --
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

foureyes_stance_1 = stance:new()
foureyes_stance_2 = stance:new()

-- enemy actions --

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
-- enemy action definitions --
-->8
-- agents --
agent = class:new({
    sprite = 16,
    size = 1,
    sprite_offset = -1/4,
    collider_size = 1/2,

    x = 0,
    y = 0,
    
    moving = false,
    ax = 0,
    ay = 0,

    hp = 6,
    defense = 0,
    base_stability = 1,
    base_speed = 1/16,

    pathable = 1,

    base_stance = default_stance,
    state = nil,
    act_time = 0
})

function agent:execute(maneuver)
    if not maneuver or maneuver == self.base_stance then
        self.act_time = 0
        return self:stance(self.base_stance)
    elseif maneuver:is_child_of(action) then
        return self:action(maneuver)
    elseif maneuver:is_child_of(stance) then
        return self:stance(maneuver)
    end
end

function agent:stance(maneuver)
    self.aura = maneuver.aura
    self.speed = maneuver.move_speed or self.base_speed
    self.stability = self.base_stability

    while self.act_time < maneuver.duration do
        if self.attack_ready and maneuver.attack_ready then
            return self:execute(maneuver.attack_ready)
        elseif self.evade_ready and maneuver.evade_ready then
            return self:execute(maneuver.evade_ready)
        elseif self.attack and maneuver.attack then
            return self:execute(maneuver.attack)
        elseif self.evade and maneuver.evade then
            return self:execute(maneuver.evade)
        end
        self:move_collide()
        self.act_time += 1
        yield()
    end
    if maneuver.hold then
        return self:execute(maneuver.hold)
    end
    return self:execute()
end

function agent:action(maneuver)
    
    -- readying time
    local immune = {self}
    local effect = {}
    effect.sprite = maneuver.sprite
    
    for i = self.act_time + 1, maneuver.timing[1] do
        self.act_time += 1
        yield()
    end

    -- startup start
    self.aura = 7
    self.stability = maneuver.stability or self.base_stability
    self.speed = 0
    self.noturn = true
    
    for t = 1, maneuver.timing[2] do
        self.act_time += 1
        yield()
    end

    -- active start
    self.speed = maneuver.move_speed
    if (maneuver.sound) sfx(maneuver.sound)
    for t = 1, maneuver.timing[3] do
        self:move_collide()
        if maneuver.force > 0 then
            effect.x = self.x + self.ax * (1 + self.size) / 2
            effect.y = self.y + self.ay * (1 + self.size) / 2
            add(active_effects, effect)
            for ag in all(active_agents) do
                if overlapping(effect, ag) and not contains(immune, ag) then
                    ag:take_hit(maneuver.damage, maneuver.force, maneuver.timing[3] - t)
                    add(immune, ag)
                end
            end
        end
        self.act_time += 1
        yield()
    end

    -- recovery start
    self.stability = self.base_stability
    self.speed = 0
    self.noturn = false
    for t = 1, maneuver.timing[4] do
        self.act_time += 1
        yield()
    end

    return self:execute()
end

function agent:direct(x, y)
    if not self.noturn then
        self.ax = x
        self.ay = y
    end
end

function agent:move_collide()
    self.moving = false
    -- ignore all collision if not moving; stationary actors have priority (steadfast)
    if self.ax == 0 and self.ay == 0 then
        return
    end

    oldx = self.x
    oldy = self.y
    self.x += self.speed * self.ax
    self.y += self.speed * self.ay

    -- inter-agent soft collisions
    for instance in all(active_agents) do
        if abs(instance.x - self.x) < (instance.collider_size + self.collider_size) / 2 and
            abs(instance.y - self.y) < (instance.collider_size + self.collider_size) / 2 and
            instance ~= self
        then
            self.x += 1/32 * ((self.x > instance.x) and 1 or -1)
            self.y += 1/32 * ((self.y > instance.y) and 1 or -1)
        end
    end
    
    -- environement hard collisions
    for i = flr(self.x - self.collider_size / 2), flr(self.x + self.collider_size / 2)  do
        for j = flr(self.y - self.collider_size / 2), flr(self.y + self.collider_size / 2)  do
            colx, coly = self:collision_test(i, j)
            -- if no push direction is available in the new space, no movement occurs
            -- this is obviously non-ideal, but the effect is barely noticeable
            self.x = colx or oldx
            self.y = coly or oldy
        end
    end

    self.moving = (self.x ~= oldx or self.y ~= oldy)
end

function agent:draw_aura()
    local frame_sprite = (self.moving and self.size == 1) and self.sprite + 1 + (4*time())%4 or self.sprite
    local flip = (self.ax < 0) and true or false

    if self.aura then
        for i = 0, 15 do
            pal(i, self.aura)
        end
        draw_entity(frame_sprite, self.x, self.y + self.sprite_offset, self.size, -1, 0, flip)
        draw_entity(frame_sprite, self.x, self.y + self.sprite_offset, self.size, 1, 0, flip)
        draw_entity(frame_sprite, self.x, self.y + self.sprite_offset, self.size, 0, -1, flip)
        draw_entity(frame_sprite, self.x, self.y + self.sprite_offset, self.size, 0, 1, flip)
    end
end

function agent:draw()
    local frame_sprite = (self.moving and self.size == 1) and self.sprite + 1 + (4*time())%4 or self.sprite
    local flip = (self.ax < 0) and true or false
    
    draw_entity(frame_sprite, self.x, self.y + self.sprite_offset, self.size, 0, 0, flip)
end

function agent:collision_test(x, y)
    -- check if the map cell is pathable, do nothing if so
    -- other 2 checks just double-check overlap; probably superfluous
    if (
        abs(self.x - x - 0.5) > (1 + self.collider_size) / 2 or
        abs(self.y - y - 0.5) > (1 + self.collider_size) / 2 or
        band(fget(mget(x, y)), self.pathable) ~= 0
    ) then
        return self.x, self.y
    end
    -- return ideal nearby location if space is not free
    -- chooses the nearest free space that isn't forward
    -- there's probably a more efficient way
    goodness = 0
    goodx = nil
    goody = nil
    for i= -1, 1 do
        for j= -1, 1 do
            if (
                i * j == 0 and
                self.ax * i <= 0 and
                self.ay * j <= 0 and
                (self.x - x - 0.5) * i + (self.y - y - 0.5)*j >= goodness and
                band(fget(mget(x + i, y + j)), self.pathable) ~= 0
            ) then
                goodness = (self.x - x - 0.5)*i + (self.y - y - 0.5) * j
                goodx = (i ~= 0) and x + 0.5 + i * (0.5 + self.collider_size / 2) or self.x
                goody = (j ~= 0) and y + 0.5 + j * (0.5 + self.collider_size / 2) or self.y
            end
        end
    end
    return goodx, goody
end

-- might want to add momentum and knockback
-- this would require taking a moment of inertia vector
-- as well as handling momentum in movement evades
function agent:take_hit(damage, force, atk_frames)
    if force >= self.stability then
        if damage - self.defense > 0 then
            self.hp -= damage - self.defense
        end
        if self.hp <= 0 then

            del(active_npcs, instance)
            del(active_agents, self)
            self.state = nil
            if self == active_player then
                init_menu()
            end
        elseif force > self.stability then
            self.act_time = 0
            self.state = cocreate(
                function()
                    self:execute(
                        stunned:new({
                            timing = {0, atk_frames + (force - self.stability) * 5, 0, 0}
                        })
                    )
                end
            )
        end
        return true
    else
        sfx(4)
        return false
    end
end

-- agent type definitions --

player = agent:new()

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
    base_stance = golem_stance
})
-->8
-- controllers --

-- player controller--

function update_player()
    if not active_player.state then
        active_player.state = cocreate(
            function()
                active_player:execute()
            end
        )
    end

    active_player.attack_ready = btn(4)
    active_player.attack = btnu(4)
    active_player.evade_ready = btn(5)
    active_player.evade = btnu(5)

    local x = (btn(1) and 1 or 0) - (btn(0) and 1 or 0)
    local y = (btn(3) and 1 or 0) - (btn(2) and 1 or 0)
    active_player:direct(x, y)

    coresume(active_player.state)
end

-- npc controller --
npc = class:new({
    agent = nil,
    foes = {},
    target = nil,
    active_target = nil,

    range =  6,
    attack_range = 3,
    
    -- controls likelyhood of acting
    liveliness = 9,
    -- controls likelyhood of readying attack
    tenacity = 5,
    -- controls likelyhood of attack
    aggression = 5,
    -- controls likelyhood of readying evade
    discretion = 5, -- discipline?
    -- controls likelyhood of evade
    agility = 6
})

function update_npcs()
    for instance in all(active_npcs) do
        instance:update()
    end
end

function update_npc(instance)

    if not instance.agent.state then
        instance.agent.state = cocreate(
        function()
            instance.agent:execute()
        end
        )
    end
    
    instance:seek_foes()
    instance:choose_maneuver()
    instance:choose_movement()

    coresume(instance.agent.state)
end

function npc:update()
    if not contains(active_agents, self.agent) then
        del(active_npcs, self)
    end

    if not self.agent.state then
        self.agent.state = cocreate(
        function()
            self.agent:execute()
        end
        )
    end
    
    self:seek_foes()
    self:choose_movement()
    self:choose_maneuver()

    coresume(self.agent.state)
end

function npc:seek_foes()
    local nearest = self.range
    self.active_target = nil

    for foe in all(self.foes) do
        if max(abs(foe.x - self.agent.x), abs(foe.y - self.agent.y)) < nearest and ray_test(self.agent, foe) then
            self.active_target = foe
            self.target = {x = foe.x, y = foe.y}
            nearest = dist
        end
    end
end

function npc:choose_movement()
    self.agent.ax = 0
    self.agent.ay = 0
    if self.target and
        max(abs(self.target.x - self.agent.x), abs(self.target.y - self.agent.y)) > self.agent.size/2
    then
            self.agent.ax = (mid(-1, self.target.x - self.agent.x, 1))
            self.agent.ay = (mid(-1, self.target.y - self.agent.y, 1))
    end
end 

function npc:choose_maneuver()
    local act = self.active_target and
        rnd(60) <= self.liveliness and (
            min(
                abs(self.target.x - self.agent.x),
                abs(self.target.y - self.agent.y)
            ) < self.attack_range or
            rnd(100) <= self.aggression
        )
    self.agent.attack_ready = act and rnd(20) <= self.tenacity
    self.agent.attack = act and rnd(20) <= self.aggression
    self.agent.evade_ready = act and rnd(20) <= self.discretion
    self.agent.evade = act and rnd(20) <= self.agility
end

shade_ai = npc:new()
-->8
-- initialization --

function _init()
    poke(0x4300, 0) --temporary solution, wanted a working death menu
    init_run()
end

function init_run()
        -- update call init --
    game_state = "running"
    frame_count = 0

    active_agents = {}
    active_effects = {}

    active_player = nil
    spawn_player()

    active_npcs = {}
    spawn_all_npcs()

    music(0,1000,3)

    -- draw call init --
    pp_lighting_init(15, 7)
    pp_aura_init(
        {24, 34, 44, 54},
        3.5,
        4
    )
end

function init_menu()
    frame_count = 0
    game_state = "main_menu"
    music(9,2000,12)
end

function spawn_player()
    active_player = player:new({x = 21, y = 12})
    add(active_agents, active_player)
end

function spawn_all_npcs()
    spawn_npcs(shade)
    spawn_npcs(skeleton)
    spawn_npcs(knight)
    spawn_npcs(giant_bat)
    spawn_npcs(skulltula)
    active_miniboss = spawn_npcs(golem)
    setmetatable(active_miniboss, { __mode = 'v' })
end

function spawn_npcs(base_agent)
    local k_agents = {}
    for y = 0, 127 do
        for x = 0, 127 do
            if (mget(x, y) == base_agent.sprite) then
                local agent_instance = base_agent:new({
                    x = x + 0.5,
                    y = y + 0.5
                })
                -- todo: create npc subtypes
                local npc_instance = npc:new({
                    foes = {active_player},
                    agent = agent_instance
                })
                add(k_agents, agent_instance)
                add(active_agents, agent_instance)
                add(active_npcs, npc_instance)
                mset(x, y, 96)
            end
        end
    end
    return k_agents
end
-->8
-- update --
function _update60()
    frame_count += 1
    if game_state == "main_menu" then
        update_menu()
    else
        update_run()
    end
    -- late update
    late_update_input()
end

function update_menu()
    if btn(4) and frame_count > 120 then
        reload()
        init_run()
    end
end

function update_run()
    -- early update
    active_effects = {}
    -- update
    update_player()
    update_npcs()
    if active_miniboss[1] == nil then
        game_state = "main_menu"
        init_menu()
    end
end

function update_npcs()
    for instance in all(active_npcs) do
        instance:update()
    end
end
-->8
-- draw --
frame_count = 0
function _draw()
    cls()

    pal()
    set_view()
    map(0, 0, 0, 0, 127, 127, 0)

    draw_agents()
    draw_effects()

    -- post processing
    pp_light_aura(rnd(4) + frame_count)

    -- ui elements
    if game_state == "main_menu" then
        draw_main_menu()
    else
        draw_hp_bar()
    end
end

-- basic draw functions --
function set_view()
    camera(
        active_player.x * 8 - 64,
        active_player.y * 8 - 64
    )
end

function draw_agents()
    pal()
    palt(0, false)
    palt(15, true)
    for ag in all(active_agents) do
        ag:draw_aura()
    end
    pal()
    palt(0, false)
    palt(15, true)
    for ag in all(active_agents) do
        ag:draw()
    end
end

function draw_effects()
    pal()
    palt(0, false)
    palt(15, true)
    for e in all(active_effects) do
        draw_entity(e.sprite, e.x, e.y, e.size)
    end
end

-- spr wrapper for map coordinate system --
function draw_entity(sprite, mx, my, size, dsx, dsy, flip)
    size = size or 1
    dsx = dsx or 0
    dsy = dsy or 0
    spr(
        sprite,
        (mx - size/2) * 8 + dsx,
        (my - size/2) * 8 + dsy,
        size,
        size,
        flip
    )
end

-- lighting init --

light_aura_addr = 0x4400 -- current size: 0x1000 (0x4400 - 0x53ff)?
light_grad_addr = 0x5400 -- current size: 0x400 (0x5400 - 0x57ff)?
bfr_addr = 0x6000 -- permanent size: 0x2000 (0x6000 - 0x7fff)

-- sets up the radii and noise level for light auras
function pp_aura_init(radii, noise, seed)

    srand(seed)
    for k = 0, 7 do
        for n = 0, 63 do
            local old_x = 0
            for i = 0, 3 do
                local radius = radii[i + 1] + rnd_nrml(noise)
                local x = flr(0.5 + sqrt(max(radius * radius - n * n, 0))/2)
                x = max(min(x, 31), old_x)
                poke(light_aura_addr + shl(k, 9) + shl(63 - n, 3) + 6 - i*2, 31 - x)
                poke(light_aura_addr + shl(k, 9) + shl(63 - n, 3) + 7 - i*2, 32 - x)
                old_x = x
            end
        end
    end
end

-- sets up the palate for the lighting gradient
function pp_lighting_init(x, y)

    for light_level = 0, 3 do
        for j = 0, 15 do
            for i = 0, 15 do
                local a = sget(8 * x + 4 * flr(i/8) + light_level, 8 * y + i%8)
                local b = sget(8 * x + 4 * flr(j/8) + light_level, 8 * y + j%8)
                memset(
                    light_grad_addr + shl(light_level, 8) + shl(j, 4) + i,
                    a + shl(b, 4),
                    1
                )
            end
        end
    end
end

-- lighting update --

function pp_light_aura(offset)
    pp_light_aura_quadrant(0, 0, offset)
    pp_light_aura_quadrant(63, 0, 1 + offset)
    pp_light_aura_quadrant(0, 127, 5 + offset)
    pp_light_aura_quadrant(63, 127, 4 + offset)
end

function pp_light_aura_quadrant(flip_x, flip_y, frame_offset)
    local frame_aura_addr = light_aura_addr + shl(flr(frame_offset)%8, 9)
    --[[ note:
        for performance reasons, no arithmetic or
        variable assignment should happen within this loop.
        it's binary operations from here on out.
    --]]
    for row = 0, 63 do

        for col = 0,
            peek(bor(bor(frame_aura_addr, shl(row, 3)), 0))
        do
            poke(
                bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)),
                0
            )
        end
        
        for col = peek(bor(bor(frame_aura_addr, shl(row, 3)), 1)),
            peek(bor(bor(frame_aura_addr, shl(row, 3)), 2))
        do
            poke(
                bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)),
                peek(bor(bor(light_grad_addr, 0x300), peek(bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)))))
            )
        end

        for col = peek(bor(bor(frame_aura_addr, shl(row, 3)), 3)),
            peek(bor(bor(frame_aura_addr, shl(row, 3)), 4))
        do
            poke(
                bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)),
                peek(bor(bor(light_grad_addr, 0x200), peek(bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)))))
            )
        end

        for col = peek(bor(bor(frame_aura_addr, shl(row, 3)), 5)),
            peek(bor(bor(frame_aura_addr, shl(row, 3)), 6))
        do
            poke(
                bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)),
                peek(bor(bor(light_grad_addr, 0x100), peek(bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)))))
            )
        end

        for col = peek(bor(bor(frame_aura_addr, shl(row, 3)), 7)),
            31
        do
            poke(
                bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)),
                peek(bor(light_grad_addr, peek(bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)))))
            )
        end
    end
end

-- hud elements --
function draw_hp_bar()
    local sx0 = active_player.x * 8 - 8 * 4
    local sy0 = active_player.y * 8 - 8 * 8

    spr(3, sx0, sy0)
    for i = 1, 6 do
        if active_player.hp / i >= 1 then
            spr(8, sx0 + 8 * i, sy0)
        elseif active_player.hp / (i - 1) >= 1 then
            spr(4 + 4 * active_player.hp%1, sx0 + 8 * i, sy0)
        else
            spr(4, sx0 + 8 * i, sy0)
        end
    end
    spr(9, sx0 + 8 * 7, sy0)
end

function draw_system_info()
    if not stat_counter or costatus(stat_counter) == 'dead' then
        stat_counter = cocreate(
            function ()
                memstat =
                    stat(7) .. ' fps' .. '\n' ..
                    'mem usage: ' .. flr(stat(0)/20.48 + 0.5) .. '%' .. '\n' ..
                    'cpu usage: ' .. flr(stat(1)*100 + 0.5) .. '%'
                for t = 1, 30 do
                    yield()
                end
            end
        )
    end
    coresume(stat_counter)
    
    print(memstat, active_player.x * 8 - 59, active_player.y * 8 + 63 - 18, 4)
    print(memstat, active_player.x * 8 - 60, active_player.y * 8 + 63 - 17, 0)
    print(memstat, active_player.x * 8 - 60, active_player.y * 8 + 63 - 18, 10)
end

function draw_main_menu()
    if frame_count == 10 then
        poke(0x4300, peek(0x4300) + 1)
    end
    srand(active_player.x)

    local death_status = (frame_count > 60) and (
        (active_miniboss[1] == nil) and "victory, for now.\nbut debris seems to\nbe blocking your path..."
        or "you died."
    ) or ""

    local death_greeting = (frame_count > 120) and (
        (active_miniboss[1] == nil) and "\nthanks for playing!"
        or (rnd(1) > 0.5) and "\noh, by the way,"
        or (rnd(1) > 0.5) and "\nyou know what..."
        or (rnd(1) > 0.75) and "\nuhh..."
        or "hmm."
    ) or ""

    local death_tip = (frame_count > 160) and (
        (active_miniboss[1] == nil) and "\n�"
        or (peek(0x4300) == 1) and "\ntry blocking by\nreleasing � while\nholding down �."
        or (peek(0x4300) == 2) and "\nhold � to perform\na dash attack."
        or (peek(0x4300) == 3) and "\nrelease � while\nholding � to\nperform a bash."
        or (peek(0x4300) == 4) and "\nperform power moves\nby holding � or �\n longer before release."
        or (peek(0x4300) >= 5) and "\npsst. some enemies\n are vulnerable\n to powerful attacks."
        or (peek(0x4300) >= 8) and "\nlike, the boss.\nuse power attacks\n on the boss."
        or "\nuse power attacks\n on the boss."
    ) or ""
    
    local play_again = ((frame_count > 200) and "\n\npress � and try again." or "") ..
    ((frame_count > 600) and "\nor don't." or "") ..
    ((frame_count > 700) and "\nup to you, really." or "") ..
    ((frame_count > 1400) and "\n�" or "")

    local death_message = death_status .. death_greeting .. death_tip .. play_again

    print(death_message, -40 + active_player.x * 8 + 1, -20 + active_player.y * 8, 8)
    print(death_message, -40 + active_player.x * 8, -20 + active_player.y * 8 + 1, 0)
    print(death_message, -40 + active_player.x * 8, -20 + active_player.y * 8, 10)
end
