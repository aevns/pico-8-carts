-- draw --
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
    if game_state:get(1) then
        draw_hp_bar()
    else
        draw_main_menu()
    end
end

-- basic draw functions --
function set_view()
    camera(
        active_view.x * 8 - 64,
        active_view.y * 8 - 64
    )
end

function draw_agents()
    pal()
    palt(0, false)
    palt(15, true)
    for npc in all(active_npcs) do
        npc.agent:draw_aura()
    end
    
    pal()
    palt(0, false)
    palt(15, true)
    for npc in all(active_npcs) do
        npc.agent:draw()
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