pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
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
    poke(0x4301, 1) -- is music active
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

				if peek(0x4301) == 1 then
  				  music(0,1000,3)
  		else
  				  music(-1,1000,0)
				end
				
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
    if peek(0x4301) == 1 then
    				music(9,2000,12)
  		else
  				  music(-1,1000,0)
				end
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

-- menu items --
menuitem( 1, "toggle music",
				function()
								poke(0x4301,1 - peek(0x4301))
								if peek(0x4301) == 1 then
  								  music(0,1000,3)
  						else
  								  music(-1,0,0)
								end
				end
)
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
        (active_miniboss[1] == nil) and "\n♥"
        or (peek(0x4300) == 1) and "\ntry blocking by\nreleasing 🅾️ while\nholding down ❎."
        or (peek(0x4300) == 2) and "\nhold 🅾️ to perform\na dash attack."
        or (peek(0x4300) == 3) and "\nrelease ❎ while\nholding 🅾️ to\nperform a bash."
        or (peek(0x4300) == 4) and "\nperform power moves\nby holding ❎ or 🅾️\n longer before release."
        or (peek(0x4300) >= 5) and "\npsst. some enemies\n are vulnerable\n to powerful attacks."
        or (peek(0x4300) >= 8) and "\nlike, the boss.\nuse power attacks\n on the boss."
        or "\nuse power attacks\n on the boss."
    ) or ""
    
    local play_again = ((frame_count > 200) and "\n\npress ❎ and try again." or "") ..
    ((frame_count > 600) and "\nor don't." or "") ..
    ((frame_count > 700) and "\nup to you, really." or "") ..
    ((frame_count > 1400) and "\n♥" or "")

    local death_message = death_status .. death_greeting .. death_tip .. play_again

    print(death_message, -40 + active_player.x * 8 + 1, -20 + active_player.y * 8, 8)
    print(death_message, -40 + active_player.x * 8, -20 + active_player.y * 8 + 1, 0)
    print(death_message, -40 + active_player.x * 8, -20 + active_player.y * 8, 10)
end
__gfx__
7000000812ffff21123ff321ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8888ffffaa77ffffffff1115ffffffffffff1155ffffff
080000702ffffff22ffffff2ffff51f55555555555555555555555555555555555555555f15ffffff88ff88ffa88887ffffff111555ffffffffff115555fffff
00700800ffffffff3ffffff3fff51f5511111115e8011115eee80115eeeee805eeeeeee55f15ffff88ffff88a88ff887fffff101505ffffffffff115555fffff
00087000ffffffffffffffffff528555000000058800000588880005888888058888888555285fff8ffffff8a8ffff8afffff101505ffffffffff100005fffff
00078000ffffffffffffffffff122111000000018800000188880001888888018888888111221fff8ffffff898ffff8afffff101505fffffff1ff115555ff5ff
00800700ffffffff3ffffff3fff15f1100000001220000012222000122222201222222211f51ffff88ffff88988ff88aff5f10015005f5fff15f10100505f55f
070000802ffffff22ffffff2ffff15f11111111111111111111111111111111111111111f51ffffff88ff88ff98888aff15011000055015f1150110000550555
8000000712ffff21123ff321ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8888ffff9999fff15011111555055f1550111555550155
fff667fffff667fffff667fffff667fffff667ffff1000ffff1000ffff1000ffff1000ffff1000ffffbbbbffffaa77fff11501115550115ff05501555550150f
fff600fffff600fffff600fffff600fffff600ffff1707ffff1707ffff1707ffff1707ffff1707fffbbffbbffabbbb7fff50f011550f01fff505f111555f105f
fff556fffff556fffff556fffff556fffff556fffff000fffff000fffff000fffff000fffff000ffbbffffbbabbffbb7f10fff0000fff05f155fff0000fff155
ff76747fff7074ffff76747ff6767470ff76747fff001fffff001ffffff01fffff101ffffff01fffbffffffbabffffbaf11f50111505f15f100ff015550ff005
f656476fff6647fff656476ff056476ff656476fff0001fff0f0011fff100fffff1000ffff0001ffbffffffb9bffffbaf10f11000015f01f055f15011055f150
f054660fff5466ffff0466ffff5466ffff0466ffff0011fffff10ffffff01fffff101ffffff10fffbbffffbb9bbffbbaff1f115ff115f1ff15ff155ff155ff15
ff6757ffff67f57ffff67ffffff677fffff67ffffff01ffffff1f0ffffff01fffff0f1ffffff10fffbbffbbff9bbbbafffff00ffff00ffffffff00ffff00ffff
ff5656ffff5656ffff556ffffff556ffff566ffffff01fffff1ff0fffff01fffff0ff1fffff10fffffbbbbffff9999ffffff15ffff15fffffff0150ff0150fff
fff155fffff155fffff155fffff155fffff155ffffffffffffffffffffffffffffffffffffffffffffccccffffaa77ffffffffffffffffffffffffffffffffff
fff100fffff100fffff100fffff100fffff100fffffffffffffffffffffffffffffffffff6777ffffccffccffacccc7fffffffffffffffffffffffff1fff1fff
fff115fffff115fffff115fffff115fffff115ffff6777ffff6777fffffffffff6777fff66878d6fccffffccaccffcc7ffff000ffffffffffff000011fff01ff
ff55505fff5050ffff55505ff5555050ff55505fff6070fffd6878dff6777ffff6878fffdf7d7ffdcffffffcacffffcafff00000ffffffffff00000001f001ff
f515051fff5505fff515051ff015051ff515051ffff7f7fff6f7f7f666878d6fdf7f7dfffff6f6ffcffffffc9cffffcafff000800fffffffff0008000000001f
f010550fff1055ffff0055ffff1055ffff0055fffffffffffdfdfdfddf7f7fdf6fdfdf6ffffdfdffccffffcc9ccffccafff808000000ffffff8080100000001f
ff1515ffff15f15ffff15ffffff155fffff15fffffffffffffffffffffdfdfffdfffffdffffffffffccffccff9ccccaffff0001001f001ffff00001000110001
ff0101ffff0101ffff001ffffff001ffff011fffffffffffffffffffffffffffffffffffffffffffffccccffff9999ffffff01f000ff000ffff001f001ff1001
ff6777ffff6777ffff6777ffff6777ffff6777ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff01001ff00ffff11ff001f1ff00
ff6070ffff6070ffff6070ffff6070ffff6070fffff0f0fffff0f0f1ffffffff1f0f0ffffffffffffffffffffffffffffffff010001ff010ff015f100010f100
fff7f7fffff7f7fffff7f7fffff7f7fffff7f7fffff000fffff00010fff0f0ff01000fffff0f0fffff6777ffff9aa7ffffff0100000ff00ff015f0000001f000
ff766fffff766ffffff76fffff677ffffff76fffff16061f1116061011f0001f01606111f1000f11ff6070ffff90a0fffff0f0010001f0f0015ff0010001f000
ff7776fff7f7766fff677fffff6777ffff7776ffff10001f00100010001606110100010011606100fff7f7fffff9fafffff0f001f001ff0f158ff001f0001808
ff7766fffff67ffffff76ffffff76ffffff67fffff00000f0000000ff0100010f00000000100010ffffffffffffffffffffff001ff001fff58fff0001f000ff8
fff76ffffff6f7ffffff76fffff7f6ffffff67fffff101ffffff0fffff000000fff0ffff000000ffffffffffffffffffffff000fff000fff8fff0000ff0000ff
fff76fffff6ff7fffff76fffff7ff6fffff67fffffffffffffffffffffff0ff0ffffffff0ff0fffffffffffffffffffffff01010f01010ff8ff01001f01001ff
344444344444553454555455d4555d56d556665dd556dd16d5ddd5dd100110101000110101050000000011d0011001000110011000000000ffffffff00000000
44434444554444444354534415664541d1dd6515d4ddd44504dad40061776177671d7617161d00000000507116757617d76167610dd6dd60ffffffff00000000
443445445545545355535554440155d551515161040505d5ddd4ddd51015101001011001170500000000506117010101100110710d6dd6d0ffffffff00000100
544444444445544454343454d54456646665d6616dd1ddd1da4a4ad566d0d761105d501506100000000001100615105d15d0515006dd6d60ffffffff00000000
44444344554554555553555446655104dd615155ddd44005ddd4ddd515001100000000000110000000000160011000000000107006766670ffffffff00000000
43444434344454554354534440546455515166110505dd5504dad405d06d05d6000000001605000000005071160d00000000016105155d50ffffffff00000000
434344544454444454555455654d6d4d61ddd616d1dddd1dd1ddd1dd1000d10500000000170500000000d161170500000000501001511510ffffffff00000000
444444435534555454444453d54504556515151dd4400056d50005d401101011000000000d110000000050100d1100000000d17001015050ffffffff00000000
00011eee0000011e000001000000000015055150555515500000000000001ee000001000000000001011000000000000000001d5ffffffffffffffffffffffff
eee1e001ee101000010000000001000004105055544444550005400010000001100000000000100000000350055d55d00d500000ffffffffffffffffffffffff
010100000001000000010000000000001504514501010101000550000ee0100001000000000001005000000305d55d5001501d00ffffffffffffffffffffffff
0011eee00001eee000000100000000000414504155155555000000011001010000ee0540054000ee000300000d55d5d000005505ffffffffffffffffffffffff
0111001e00010001000000010000001014045145045444050000eee0000000000000055005500000035035010d6ddd605000000dffffffffffffffffffffffff
eee0e000ee10100001e01000010000000415104510101010101000010005400001000000000001001000000001011d1000d50d00ffffffffffffffffffffffff
00011e0000000100000001000000000015045145554445450e00100000055000e01000000000e010003501000010010000510500ffffffffffffffffffffffff
00001110000001000000000000000000051050550101010110010100000000000000100000000001110000110000101050000001ffffffffffffffffffffffff
54555d5601010110ffffffffffffffff0000000940000000ffffffffffbfffffcfffffffffffffffffffffff0000001d61000000d541546d646ddd46ffffffff
1566454100000000ffffffffffffffff0009400440094000fffff8ff7ffbffff7cffffffffffffffffffffff000000550100000015660414d1600011ffffffff
44014455f4fff40fffffffffffffffff0002449449442000ff5fff8f67ffbfff67cfffffffffffffffffffff0000156456100000005d066044005100ffffffff
d444566400000000ffffffffffffffff09202422224202904477777866ffbbff66cfffffff5566ffff99aaff0001dd6146551000001d06d056dd5000ffffffff
455441044f504ff5ffffffffffffffff0244420000244420f566668f56ffbbff56cfffffff5446ffff9a9aff0005000556d56100000155d016001000ffffffff
4054545500000000ffffffffffffffff0024200000024200fffff8ff55ffbfff55cfffffff5446ffff9a9aff0015664450046500000001d040510000ffffffff
6546544610150155ffffffffffffffff0092000000002400ffffffff5ffbffff5cfffffffff56ffffff9afff11ddd616414566510000001455000000ffffffff
d545045500000000ffffffffffffffff9442000940002449ffffffffffbfffffcfffffffffffffffffffffff6400004dd645005d00000016d1000000ffffffff
04500150011000f000100000ffffffff2242000220004222fffafaffff9afaff9affffff55551550444455345545511001154545000100000005100000008882
0f0000100500050000000010ffffffff0024000000009200fffff9af7ff9afff79afffff5400005555000044444451000001444510005d100151050110009451
040001500500004011001005ffffffff0022400000092200ff5fff9a67ffafff679affff00677701506777035451100005d015441100dd500dd05d012100aa94
0f100150001005f000000000ffffffff04422400009224404477777966ff9aaf669affff506171054061710444100001105001455510001505d000153110bb31
0f500100051001f010550551ffffffff0220244499420220f566669a56ff9aaf569affff040707055507570551000d505100015554100501100001444510ccd1
040000500510004000000000ffffffff0002422222242000fffff9af55ffafff559affff101010103440505510d50dd005dd001144510d50000115455100d510
00500050010000f015551501ffffffff0002200220022000fffafaff5ff9afff59afffff55444545445444441050151001d5000154441000001544446d51d100
0f0001100510054000000000ffffffff0000000220000000ffffffffff9afaff9affffff01010101553455540001500000001000545451100115545576d54451
00000000000000c5b5c7443434343444341414343414b5b5b5c53414343444b4848484c4444434344444544444444454443434444454445444b484848484c454
54543515a544c5b5c534e6b484c4155545454545e63555a515940000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000c5b5b5c5b5c734341404143444b7c50000b5c73444445494000000a43444d43444b484848484848484c434d444d444d43494000000000084
84848484848484c51555a59400a4b65434b4c43525a5551404940000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000b5b5b5c5b5c73434b7c5b5c50000c5b58484848400000000a454445444549400000000000000a44444443444343494000000000000
00a4747474747474a555259400a452444494a4c63515543452940000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000b5c5c5b5b5b5b5c500000000c500000000000000000084848484840000000000000000008484848484848400000000000000
00a4c6a53525b6443454449400a454e63594a43445455444039400000000b5b50000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b5b5c754454554341434449400a45535a5747454b484c4544474747474b5b5b50000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b5b534a5b484848484840000a455250515a5557494a455a535251515a5b5f40000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a4341435747474747474747474544534a734551474745595f435f425f4f4f40000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a4d634445445454554341424344435d644544553e6255525a5f425f4f425f40000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a425d644e625f435d644343444e6a5051525f4a5353555150525f4f4f4f4f40000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008484848484848484c434b48484848484848484c4f455f4b48484848484840000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000a414940000000000000000a4855595940000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000a452072727279400000000a4255515940000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000a47474747404070404a79400000000a4355525940000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000a47474747474747474749400000000000000000000
000000000000a41525b63414161614169400000000a4a55535940000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000a40000000000000000009400000000000000000000
000000000000a435f4341424145114049400000000a4855595940000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000a40000000000000000009400000000000000000000
000000000000a4a5b634140414041414940000000000c455b4000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000a40000000000000000009400000000000000000000
00000000000084848484848484848484000000000000a45494000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000a40035000000003500359400000000000000000000
00000000000000000000000000000000000000000000a44494000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000a40035253500253525009400000000000000000000
00c5b500000000000000000000000000000000000000a44494000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000a425b4c41535b4c435259400c500c5a474d474d474
b5b5c5b574b574b574d47494a4b57474749400a47474743474747494000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000a4747474747474747474057474051574741515940000b5b5b5e714141414
b7b5c5a4e714521404a75294a4e734a7049400a40414341434141494000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000a44444445454445454544434141434141414147474b5c5b574143404b504
d7c5b5c50434143404340494a414b4c4147474741434345454142494000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000a44444445454444454443434341414141414141434c5b5c5a71414141414
14d7b5b5a714c0141404a7b5a40494a4341414041454546454541494000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000a4444454544444444444441414343414341434b48484b5b5c414b5043404
d404b5a404340434143404d7b50494c5848484c40414345434340494000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000a444444444445454444454b4c45454b4c454549400c5b500b5c7141414a7
14b7c5b5c714141404a714143414c5b5000000a4a714041434141494000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000008484848484848484c415747415157474150594000000c50084d484b584
d484000084b584d484b584848484b500000000008484848484848400000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000a41535150515351535359400000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000a40025350035253525009400000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000a40035000035000000359400000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000a40000000000000000009400000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000a40000000000000000009400000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008484848484848484840000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000051055555555555555555555555555555555555555555555555550150000000000000000000000000000000000000
0000000000000000000000000000000000051055eeeeeee5eeeeeee5eeeeeee5eeeeeee5eeeeeee5eeeeeee55015000000000000000000000000000000000000
00000000000000000000000000000000005285558888888588888885888888858888888588888885888888855528500000000000000000000000000000000000
00000000000000000000000000000000001221118888888188888881888888818888888188888881888888811122100000000000000000000000000000000000
00000000000000000000000000000000000150112222222122222221222222212222222122222221222222211051000000000000000000000000000000000000
00000000000000000000000000000000000015011111111111111111111111111111111111111111111111110510000000000000000000000000000000000000
00000000000000000000000000000000000000001000000000001555000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000010000010010100000000001001010010000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000100000000101100010001000100000000000100000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000001055105510551055105550dd50dd0001005001151150010000000000000010551055105510000000000000000000000000
00000000000000000000000000000000000000000000000000000000000010010000100100000001000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000005101100051011101d500100101001001010000000000100100011000510110005000000000000000000000000
0000000000000000000000000000000000000000000000000000000000015111d005d51150000000010151115000000000000000000000000000000000000000
0000000000000000000000000000100001001000010010015d50d5015d0000050000000100001001000000010010510001001000010000000000000000000000
00000000000000000000000000000000000000000000005001000050010000000000000000000000000000000000001000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000015555511050000000100000001000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000010510510001001000000000000000000000000000000000000000
00000000000000001000000000000000000000000000000000000000000011015011011111050510500101001001010010010000000000000000000000000000
00000000000000001000000000000000000000000000000000000000000000011005155501010100100101001001010000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000050100510501005101000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000001000000011555151010500100001001000010000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000010010110000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000011110110000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000015555511000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000
00000000000000001000000000000000000000000000000000000000000000000055155555000000000000000000000000000000000000000000000000000000
00000000000000001000100010000000000000000000000000000000100000000004544405000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000010000000000000000000000000000010101010000000000000000000000000000000000000000000000000000000
00000000000000001000000000000000000000000000000000000000000000000011555151000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000001010101000000000000000000000000000000000000000000000000000000
00000000000000001000000000000000000000000000000000000000000000010055551550045001500010000000000000000000000000000000000000000000
00000000000000000000000010000100500000000000000000000100000100000054444455040000100000000000000000000000000000000000000000000000
00000000000000000000000100001001100000000000000000000000000001000001010101040001100000000100000000000000000000000000000000000000
00000000000000001000000000051151500000000000000000000000000000010055155555041001500000000000000000000000000000000000000000000000
00000000000000001000100010015155d00000000000000000000000100000000104544405045001001055011000000000000000000000000000000000000000
000000000000000000000001000000010000000000000000000100000001d0100010101010040000500000000000000000000000000000000000000000000000
00000000000000001000000000000000000000000000000000000000000000010055444551001000100111010001000000005ddd000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000010101010400011000000000000000000050d0000000000000000000000000
0000000000000000000000000000000000d000000000000000000000000000100055551550045001505511011011111111010d0d050000000000000000000000
0000000000000000000001001000000100000000000000000000000000100000005444445504000010155555115551555500d550100000000000000000000000
00000000000011100100100100055015001d0000000000000000000000010000000101010104000150010100005515515550ddd5000010010000000000000000
000000000000000000000000100010000015551000000000000000000000dd05405515555504100150551555111555555550dd55000000000000000000000000
00000001100100011000101150000000551d51d00000000010000000000000000004544405045001000454440155551111100d50010010000001000000000000
00000000000000000000000100000001511005d10000000000000000000100066700101010040000501010100051555511100d50000000000000000000000000
00000000000000000000000000000055555051dd100000000000000000d010060005444545005000501155515151515515501001010000000010000000000000
00000000000000000000000000000001115d51001500000000000000000000055601010101040001100101010144555551511001000011000000000000000000
00000000000000000000000000115511150101515015055150150551501500767470551550045001505555151001011010010100001100000000000000000000
00000000000000000000010010001111110510505504105055041050550406564760444455040000101555551105001011010000001100000000000000000000
00000000000000000000100100115115110105105101055145150451451500546600010101040001500101010115010010000100101100000000000000000000
00000000000000000000000000115115550505105004145041041450410410675705155555041001505515555504050010010100100111110000000000000000
000000000000100010015111d0115115110505104514045145140451451400565604544405045001000515550105050010010100100000000000000000000000
00000000000000000000000100155515110501004504151045041510450415000010101010040000501010100001000010010000000000000000000000000000
00000000000000000000000000111555550105104515045145150451451504514555444545005000505544454501050010000100101111110000000000000000
00000000000000000000000000001511150100101101005055051050550510505501010101040001100101010101001011010000001111000000000000000000
0000000000000000000000000011000156646ddd4600000000101100005555155055551550010101100101010000000000000000000000000000000000000000
000000000000000000000000100055515050d0000000010000000003505444445554444455000000000000000000000000011111000000000000000000000000
00000000000000000000100100110000101100100000000000500000030101010101010101444444044544450445445105000000005111100110000000000000
00000000000000000000001010101105510555500000000000000300005515555555155555000000000000000000000000110000000000000000000000000000
00000000000000000000100010155000050d00000000000010035035010454440504544405445044454450444554105441010100000100011001000000000000
000000000000000000000001001001d5115010000001000000100000001010101010101010000000000000000000000000000000000000000000000000000000
00000000000000000000000000501151111100000000000000003501005544454555444545101501110001001100000000001110100000000000000000000000
00000000000000000000000000105105115000000000000000110000110101010101010101000000000000000000000000000000000000000000000000000000
000000000000000000000000000000001000000000000001000000011d5555155015055150150110100101101001011010111101000000000000000000000000
00000000000000000000000000011111000000000000000000dd1010005444445504105055041050550500101105001011011111000000000000000000000000
00000000000000000000000100000000000000000000010000000100000101010115045145150451451505105101050010000000000001000000000000000000
000000000000000000000000000000000000000000000001000001ddd05515555504145041040510500505105005010010000000000000000000000000000000
00000000000000000000000011010111000000000000000001000100010454440514045145140451451404001001010010010000000000000000000000000000
00000000000000000000000000000000000000000000100000110010001010101004150051050100510501005105010051000000000000000000000000000000
00000000000000000000001111001110100000000000000000000000001155514515045145150451450105001000010010001110000000000000000000000000
00000000000000000000000100000000000000000000000000000001000101010105105055050010110100101101001011000000000000000000000000000000
0000000000000000000000000000000000000000100000000000000000000000000000011d000000000000000000000000000000000000000000000000000000
000000000000000000000000000111110001001011000000000001000000054000dd101000000150000000000000000000151111000000000000000000000000
00000000000000000000000000000000000001001000000000000000000001100000010000000510000000000000000000000000000000000000000000000000
0000000000000000000000000000000000010100500150001100000000000000010001ddd0000000000000000000000000000000000000000000000000000000
0000000000000000000000000000011100010100100010000000000000000011d000010000000011100000000000000000000000000000000000000000000000
000000000000000000000000100000000001000010000000000000000000000001dd101000101000000000000000000000000000000000000000000000000000
00000000000000000000000000001110100001001000000000000000000d00100000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000055151111500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000005510101050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011101105510511000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000011000010500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000010001000100000000000000000000000100000000d0000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000001001000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000510051150005000000000000000000000000000000000000000000000000000000000000
00000000000000000000000110100000000000000000000000000011500100101015000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000151115005105000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000011000000000000001000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001115050000000000001100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000100000000000000001000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000111000000000000000000000000000000000000001010000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001000001110000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001000151111000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000100000000010100001000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000100010000000000000100000000000000000000010000000000000000000000010001000100000000000000000000000000000001010101010101020202020202020004040404040101040404040402020000000102000004040000000000010101010002020200040400000001010101010100
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000005b5b0000000a0b00000000005300000053005300000000000000006465000000000000000000000053524b4848000000000000000000000000000000000000004a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000005b000000001a1b000000535700005300575200000000004a474764657547474900707272715300515700474770727272490000000000000000000000000000004a005300000053000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000005b006b436c0053005253005454545454545152530000004a546474757500434900705435714f4f4f54794543705554544900004a7272727147474747474900004a000056530056000056000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000005b5b45444300005152006b4445515255565b7c430000494a55557500006b43494a61615561575a5256554544705530554900004a5455547125444341434900004a520052515200530051005800000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000005b5b5352536b44444543436e5153545b5b7e6e0000004a547954545c7c7b494a4f545454544f5451554b48484c55614900004a54545571554f6d43444900004a4443414d4341404d6c510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000484c6c4b48484848484c524d00535c5b6e5300004900485b5c5b5b5c5b004a58554f5256535650554747474755414900004a6161556155594f44444900004a444443434445434543530053000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004a474747444747474747494a5a446c52525300000053474747475b5b5c5b4747470051574f4f574f5a554543444355434900004a79545454554f5253434900004a445544444546454341525800000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004a43444444434043447b494a514d6e5870727272714f00005300585554545454545454545454555354554343434443444900004a555445555550514f6d4900004a545454454545444443510053000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000048484c444b48484c5b5b4a6c00515a70433055715b0052005300550000000000000055524f5554545a4b48484c43444747474755434344456c4f5352474747475543444d4143434d6e515200005300000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000005b4a474743475b494a5b4747444d525170545455715b5b000053525570727272727271554f4f525156534747474755444d55444d5544444444545445514d555a4d55505152535a515200005800000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000005b5b5c4a404143405c494a7e43434341535861615561615b7e6c5300585570554030414371554f53534f585545435454555454545454554f6d446e5a53445454545154554f4f515352535300530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000475c4747414345437d475b7c414344435454545455525b5b415454545455705554544041715551535253535443414344555444304f525153574f534f6b446c51524f534f534f4f5353005300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000005b5c5b7e43434546455b5b5c5b4445444551555351555a005b436e535a555561616155616161555a5152515a454b48484c54444d6e534d5454545454454443414d6c4f4d515252510000535300530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000005c485b4c434345437d5b4c5b7c444444585559575553577e5553525155545454545554545455535a5253536d7072727144444b48484c5153555a536d4441404b48484c504f00535352000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000005b5c5b7c41434143494a5c4b4c444d0053005454545454555459535651565300555a515855594f4f4f525a7054557145444900004a6c52555352536d43354900004a005152000053000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000484c434b48004a5b494a43005300005652515540436e005353530052575557005a53524f535a53537054545445434900004a435855595251536d444900004a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004a47474744474747477e494a554d52530000535a55434500526b5b6c530054545452534f4f4f4f534f4f4b48484c43415b00004a44535552446c4f4f4449000000005300005300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004a434444444445434143494a7959515353005358556d4400537b5b7c51005600555a4f534f53525a525347475c5b437b495c004a35525551434452536d49000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000048484c444b48484848004a5a4d525300525351505a5a51536d7e6e525300535153524f5a5251525352447d5b5b5b5c5b5b004a795554555454545a5349000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005b474747474747474744474747474747475357525300005352515253005200520000005300525251525150505a5a6b43417d5c5b5b5c5b000048484c54524f4b484800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005b5b5b7e4544555554545454545454545454545454515253530053525300000053000053525300556b4343414240414344434344435b5c495c000000004a544f5949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5b5b5b7e4143444555555559525256515500565a5a5156535300000000000000535200530052515a6b43414041404040404143434143437b5b5b00000000004a55535249004a47494a47474747474747490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5353525152515351565a565152510053555253515100535300000053005300525100535152536b4341414041407b5b7c4140414141417b5c5b0000000000004a554f5347474720474745434443434140490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
53000051520052515a520053520000005559000052535a530053005353530053525a005a516b4543414343437b5b5b5c5b7c4040437b5c5b000000000000004a554f574f555454545444444444444543490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000535253005353000052576b435152530000525751535257510053536b44434143434341437b5b5b5b5c00005c5b5b5b5b5b5c00000000000000004a55545454554f53564f43444443444420490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000053000000005254545a54546e53530053005354555454545253515c434b484848484848485b5c00000000000000000000000000000000000000000048484c45434b48484c41434041434445490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000005300525056555900005251525356555a5056535c5b5c414900000000000000000000000000000000000000000000000000000000000000004a444b00000000484848484c4444490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000530053525151525553525150505a0000545451525b5b5c7e4349004a474747474749000000000000004a4747474747474749000000000000000000480000000000000000004a4344490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000053005300535200556b44446c5a6b456c5552535b5c7e43444449004a444143444549000000000000004a44454445444443490000000000000000000000000000000000005b5b414349004a474747474747490000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000053520053005352536b44434045444443434343415b7e4345444b4800004a44434d4444474747474747474747444d454d444d4449000000004a47474747474747475b5c4747475b7e434447474740354f4f574f474747474747474700000000000000000000000000000000000000000000000000000000000000
00000000005c5c5a53525152516b444341434443414341414040414143444447474747474544434445434345444444434445434444454343454747474747474545455a524f447d5c5b5c3552536d42436e4f53437a4354544f4f5152535051005300000000000000000000000000000000000000000000000000000000000000
000000005b005b5b5c506b44454441444342434041407b5b5c7c43414143444445444444444544444444444444444444444444454545454445454545454545454645545454457b5b5b7e4351505a52554f53524543455556524b4848484848484800000000000000000000000000000000000000000000000000000000000000
__sfx__
000c000025630116310563105611016010d6010160101601000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00001c63428655176410662103611036110360101601000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001e6442c65517661106210d6210b6210a61109601006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000800000b6340a631066210161501605000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300003f6543f5313f5213f5113f5113f5013f5113f5013f5113f5013f5013f5013f50133501355013550135501355010050500505005050050500505005050050500505005050050500505005050050500505
000400000363103741036510375103641027410263102731026310172101621017210161101711016110171101701006010170101601006010060200602006020060200602006020060200602006020060200602
0003000003324033012e340033001b3500330012350043000e3310f3110f301033010130101301013010530101301053010130105301003010030100301003010030100301003010030100301003010030100301
00070000015240756111561135210b511055110550100501015000150001500015000150001500005000050000501005010050100501005010050100501005010050100501005010050100501005010050100501
001e00000866101641016110161101611016010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000911209112101121011209112091121011210112151121511209112101121011208112101121011215112151121c1121c11215112151121c1121c1122111221112151121c1121c112141121c1121c112
012000001573515735157351573515735157351573517732187351873217735177321573515732177351773218735187351873515735157351573518735157321073510732107351773217735107321773514732
012000000954509545095450954505545055450554505545005450054500545005450454504545045450454505545055450554505545065450654506545065450954509545095450954508545085450854508545
0120000015535155051550514535155351550515505155351053518505175050e535105351550515535175051153518505185050e5350c53515505185050e5350c53510505105050e53514535105051053514505
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 4a0c7f40
00 0d0c4040
00 0d0c4c40
00 0b0c4c40
00 0b0c4c40
00 0a0c4c40
00 0a0b4a4d
00 0b0d4c4d
02 0b0d4a40
03 0a0b0c0d
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000

