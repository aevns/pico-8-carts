-- player controller--
player_controller = class:new({
    agent = nil
})

function player_controller:update()
    if not self.agent.state then
        self.agent.state = cocreate(
            function()
                self.agent:execute()
            end
        )
    end

    self.agent.attack_ready = btn(4)
    self.agent.attack = btnu(4)
    self.agent.evade_ready = btn(5)
    self.agent.evade = btnu(5)

    local x = (btn(1) and 1 or 0) - (btn(0) and 1 or 0)
    local y = (btn(3) and 1 or 0) - (btn(2) and 1 or 0)
    self.agent:direct(x, y)

    coresume(self.agent.state)
end