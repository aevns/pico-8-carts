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
    late_update_input()
end

function menu_update()
    if btn(4) and frame_count > 120 then
        reload()
        gameplay_init()
    end
end

function gameplay_update()
    -- update
    active_player:update()
    for instance in all(active_npcs) do
        instance:update()
    end
end