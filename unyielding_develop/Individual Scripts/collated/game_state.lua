-- game state --

-- persistent data handling --
persistent_state = class:new({
    state_addr = nil;
})

function persistent_state:set(state)
    state = state or 1
    poke(state_addr, state)
end

function persistent_state:toggle()
    poke(state_addr, 1 - peek(state_addr))
end

function persistent_state:get()
    peek(state_addr)
end

-- persistent states --
-- 0 indicates active game state
-- 1 indicates menu state
game_state = persistent_state:new({
    state_addr = 0x4300
})

-- the number of attempted runs thus far
run_number = persistent_state:new({
    state_addr = 0x4301
})

-- 0 indicates music off
-- 1 indicates music on
music_state = persistent_state:new({
    state_addr = 0x4302
})

-- camera definition --
view = class:new({
    target = nil,
    x = 0,
    y = 0,
    x_buffer = {},
    y_buffer = {},
    smoothness = 10,
    delay = 25,
    frame_index = 0
})

function view:update()
    self.frame_index += 1
    local frame = 1 + self.frame_index%self.delay
    local old_frame = 1 + (self.frame_index - self.smoothness)%self.delay

    self.x -= (self.x_buffer[old_frame] or 0) / self.smoothness
    self.x_buffer[old_frame] = self.target.x
    self.x += (self.x_buffer[frame] or 0) / self.smoothness

    self.y -= (self.y_buffer[old_frame] or 0) / self.smoothness
    self.y_buffer[old_frame] = self.target.y
    self.y += (self.y_buffer[frame] or 0) / self.smoothness
end

-- initialization --

function _init()
    if run_number:get() == 0 then
        music_state:set(1)
    end
    gameplay_init()
end

function gameplay_init()
    frame_count = 0
    game_state:set(1)

    active_player = spawn_player(21, 12)
    active_bosses = spawn_all_bosses()
    local active_npcs = spawn_all_npcs()
    
    active_controllers = {active_player}
    active_agents = {active_player.agent}
    for _,v in pairs(active_bosses) do
        add(active_controllers, v)
        add(active_agents, v.agent)
    end
    for _,v in pairs(active_npcs) do
        add(active_controllers, v)
        add(active_agents, v.agent)
    end

    active_view = view:new({
        target = active_player.agent
    })

    active_effects = {}

    if music_state:get() then
        music(0, 2000, 3)
    else
        music(-1, 0, 0)
    end

    -- draw call init --
    pp_lighting_init(15, 7)
    pp_aura_init(
        {24, 34, 44, 54},
        3.5,
        4
    )
end

function menu_init()
    frame_count = 0
    game_state:set(0)
    if music_state:get() == 1 then
    	music(9, 2000, 12)
  	else
  		music(-1, 0, 0)
	end
end

function spawn_player(x, y)
    local p = agent:new({x = x, y = y})
    return player_controller:new({agent = p})
end

function spawn_all_bosses()
    local bosses
    for _,v in pairs(spawn_agents(golem, npc_controller)) do add(bosses, v) end
    return bosses
end

function spawn_all_npcs()
    local npcs
    -- spawn all agents of the given types, with default npc controllers
    for _,v in pairs(spawn_agents(shade, npc_controller)) do add(npcs, v) end
    for _,v in pairs(spawn_agents(skeleton, npc_controller)) do add(npcs, v) end
    for _,v in pairs(spawn_agents(knight, npc_controller)) do add(npcs, v) end
    for _,v in pairs(spawn_agents(giant_bat, npc_controller)) do add(npcs, v) end
    for _,v in pairs(spawn_agents(skulltula, npc_controller)) do add(npcs, v) end
    return npcs
end

function spawn_agents(base_agent, base_controller)
    local k_controllers = {}
    for y = 0, 127 do
        for x = 0, 127 do
            if (mget(x, y) == base_agent.sprite) then
                -- add a new agent at spawn point
                local agent_instance = base_agent:new({
                    x = x + 0.5,
                    y = y + 0.5
                })
                -- create a controller for the agent
                local controller_instance = base_controller:new({
                    agent = agent_instance
                })
                add(k_controllers, controller_instance)
                -- replace the spawn point sprite
                mset(x, y, 96)
            end
        end
    end
    return k_controllers
end

-- menu items --
menuitem( 1, "toggle music",
    function()
        music_state:toggle();
        if music_state:get() then
            music(0, 1000, 3)
        else
            music(-1, 0, 3)
        end
    end
)