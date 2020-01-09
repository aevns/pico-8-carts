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

            del(active_agents, self)
            del(active_bosses, self)
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