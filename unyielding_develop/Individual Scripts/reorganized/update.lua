-- update --
function _update60()
    -- early update
    frame_count += 1
    active_effects = {}

    -- standard update
    if game_state:get() == 0 then
        gameplay_update()
    else
        menu_update()
    end

    -- late update
    active_input:update()
end

function menu_update()
    if btn(4) and frame_count > 120 then
        reload()
        gameplay_init()
    end
end

function gameplay_update()
    -- update the active player first (make sure active_controllers is ordered correctly)
    -- then update all other agents
    for instance in all(controller.active_controllers) do
        instance:update()
    end
    
    if active_player.hp <= 0 or #(agent.active_bosses) <= 0 then
        game_state:set(0)
        init_menu()
    end
end