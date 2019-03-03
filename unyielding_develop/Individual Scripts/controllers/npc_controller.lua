-- npc controller --
npc_controller = class:new({
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
    discretion = 5,
    -- controls likelyhood of evade
    agility = 6
})
setmetatable(npc_controller.foes, { __mode = 'v' })

function update_npcs()
    for instance in all(active_npcs) do
        instance:update()
    end
end

function npc:update()
    -- replace this part; gotta use better scoping
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
            rnd(60) <= self.liveliness
        )
    self.agent.attack_ready = act and rnd(60) <= self.tenacity
    self.agent.attack = act and rnd(60) <= self.aggression
    self.agent.evade_ready = act and rnd(60) <= self.discretion
    self.agent.evade = act and rnd(60) <= self.agility
end