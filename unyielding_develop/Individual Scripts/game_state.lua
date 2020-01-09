-- game state --

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

active_input = input:new()

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
    spawn_all_npcs()

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
    if music_state:get() then
    	music(9, 2000, 12)
  	else
  		music(-1, 0, 0)
	end
end

function spawn_player(x, y)
    local p = agent:new({x = x, y = y})
    return player_controller:new({agent = p})
end

function spawn_all_npcs()
    spawn_agents(shade, npc_controller)
    spawn_agents(skeleton, npc_controller)
    spawn_agents(knight, npc_controller)
    spawn_agents(giant_bat, npc_controller)
    spawn_agents(skulltula, npc_controller)
    spawn_agents(golem, npc_controller)
end

function spawn_agents(base_agent, base_controller)
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
                -- replace the spawn point sprite
                mset(x, y, 96)
            end
        end
    end
end

-- menu items --
menuitem( 1, "toggle music",
    function()
        music_state:toggle()
        if music_state:get() then
            music(0, 1000, 3)
        else
            music(-1, 0, 3)
        end
    end
)