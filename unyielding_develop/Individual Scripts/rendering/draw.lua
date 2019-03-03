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