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

    active_npcs = spawn_all_npcs()
    active_player = spawn_player(21, 12)

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
    return player:new({agent = p})
end

function spawn_all_npcs()
    local npcs
    for k,v in pairs(spawn_agents(shade, npc_controller)) do table.insert(npcs, v) end
    for k,v in pairs(spawn_agents(skeleton, npc_controller)) do table.insert(npcs, v) end
    for k,v in pairs(spawn_agents(knight, npc_controller)) do table.insert(npcs, v) end
    for k,v in pairs(spawn_agents(giant_bat, npc_controller)) do table.insert(npcs, v) end
    for k,v in pairs(spawn_agents(skulltula, npc_controller)) do table.insert(npcs, v) end
    for k,v in pairs(spawn_agents(golem, npc_controller)) do table.insert(npcs, v) end
    return npcs
end

function spawn_agents(base_agent, base_controller)
    local k_controllers = {}
    for y = 0, 127 do
        for x = 0, 127 do
            if (mget(x, y) == base_agent.sprite) then
                local agent_instance = base_agent:new({
                    x = x + 0.5,
                    y = y + 0.5
                })
                -- todo: create npc subtypes
                local controller_instance = base_controller:new({
                    agent = agent_instance
                })
                add(k_controllers, controller_instance)
                mset(x, y, 96)
            end
        end
    end
    return k_controllers
end