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
    for npc in all(active_controllers) do
        npc.agent:draw_aura()
    end
    
    pal()
    palt(0, false)
    palt(15, true)
    for npc in all(active_controllers) do
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

-- lighting init --

light_aura_addr = 0x4400 -- current size: 0x1000 (0x4400 - 0x53ff)?
light_grad_addr = 0x5400 -- current size: 0x400 (0x5400 - 0x57ff)?
bfr_addr = 0x6000 -- permanent size: 0x2000 (0x6000 - 0x7fff)

-- sets up the radii and noise level for light auras
function pp_aura_init(radii, noise, seed)

    srand(seed)
    for k = 0, 7 do
        for n = 0, 63 do
            local old_x = 0
            for i = 0, 3 do
                local radius = radii[i + 1] + rnd_nrml(noise)
                local x = flr(0.5 + sqrt(max(radius * radius - n * n, 0))/2)
                x = max(min(x, 31), old_x)
                poke(light_aura_addr + shl(k, 9) + shl(63 - n, 3) + 6 - i*2, 31 - x)
                poke(light_aura_addr + shl(k, 9) + shl(63 - n, 3) + 7 - i*2, 32 - x)
                old_x = x
            end
        end
    end
end

-- sets up the palate for the lighting gradient
function pp_lighting_init(x, y)

    for light_level = 0, 3 do
        for j = 0, 15 do
            for i = 0, 15 do
                local a = sget(8 * x + 4 * flr(i/8) + light_level, 8 * y + i%8)
                local b = sget(8 * x + 4 * flr(j/8) + light_level, 8 * y + j%8)
                memset(
                    light_grad_addr + shl(light_level, 8) + shl(j, 4) + i,
                    a + shl(b, 4),
                    1
                )
            end
        end
    end
end

-- lighting update --

function pp_light_aura(offset)
    pp_light_aura_quadrant(0, 0, offset)
    pp_light_aura_quadrant(63, 0, 1 + offset)
    pp_light_aura_quadrant(0, 127, 5 + offset)
    pp_light_aura_quadrant(63, 127, 4 + offset)
end

function pp_light_aura_quadrant(flip_x, flip_y, frame_offset)
    local frame_aura_addr = light_aura_addr + shl(flr(frame_offset)%8, 9)
    --[[ note:
        for performance reasons, no arithmetic or
        variable assignment should happen within this loop.
        it's binary operations from here on out.
    --]]
    for row = 0, 63 do

        for col = 0,
            peek(bor(bor(frame_aura_addr, shl(row, 3)), 0))
        do
            poke(
                bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)),
                0
            )
        end
        
        for col = peek(bor(bor(frame_aura_addr, shl(row, 3)), 1)),
            peek(bor(bor(frame_aura_addr, shl(row, 3)), 2))
        do
            poke(
                bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)),
                peek(bor(bor(light_grad_addr, 0x300), peek(bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)))))
            )
        end

        for col = peek(bor(bor(frame_aura_addr, shl(row, 3)), 3)),
            peek(bor(bor(frame_aura_addr, shl(row, 3)), 4))
        do
            poke(
                bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)),
                peek(bor(bor(light_grad_addr, 0x200), peek(bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)))))
            )
        end

        for col = peek(bor(bor(frame_aura_addr, shl(row, 3)), 5)),
            peek(bor(bor(frame_aura_addr, shl(row, 3)), 6))
        do
            poke(
                bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)),
                peek(bor(bor(light_grad_addr, 0x100), peek(bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)))))
            )
        end

        for col = peek(bor(bor(frame_aura_addr, shl(row, 3)), 7)),
            31
        do
            poke(
                bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)),
                peek(bor(light_grad_addr, peek(bor(bor(bfr_addr, shl(bxor(row, flip_y), 6)), bxor(col, flip_x)))))
            )
        end
    end
end

-- hud elements --

function draw_hp_bar()
    local sx0 = active_view.x * 8 - 8 * 4
    local sy0 = active_view.y * 8 - 8 * 8

    spr(3, sx0, sy0)
    for i = 1, 6 do
        if active_player.agent.hp / i >= 1 then
            spr(8, sx0 + 8 * i, sy0)
        elseif active_player.agent.hp / (i - 1) >= 1 then
            spr(4 + 4 * active_player.agent.hp%1, sx0 + 8 * i, sy0)
        else
            spr(4, sx0 + 8 * i, sy0)
        end
    end
    spr(9, sx0 + 8 * 7, sy0)
end

function draw_main_menu()
    if frame_count == 10 then
        poke(0x4300, peek(0x4300) + 1)
    end
    srand(active_view.x)

    local death_status = (frame_count > 60) and (
        (active_bosses == nil) and "victory, for now.\nbut debris seems to\nbe blocking your path..."
        or "you died."
    ) or ""

    local death_greeting = (frame_count > 120) and (
        (#active_bosses == 0) and "\nthanks for playing!"
        or (rnd(1) > 0.5) and "\noh, by the way,"
        or (rnd(1) > 0.5) and "\nyou know what..."
        or (rnd(1) > 0.75) and "\nuhh..."
        or "hmm."
    ) or ""

    local death_tip = (frame_count > 160) and (
        (#active_bosses == 0) and "\n♥"
        or (peek(0x4300) == 1) and "\ntry blocking by\nreleasing 🅾️ while\nholding down ❎."
        or (peek(0x4300) == 2) and "\nhold 🅾️ to perform\na dash attack."
        or (peek(0x4300) == 3) and "\nrelease ❎ while\nholding 🅾️ to\nperform a bash."
        or (peek(0x4300) == 4) and "\nperform power moves\nby holding ❎ or 🅾️\n longer before release."
        or (peek(0x4300) >= 5) and "\npsst. some enemies\n are vulnerable\n to powerful attacks."
        or (peek(0x4300) >= 8) and "\nlike, the boss.\nuse power attacks\n on the boss."
        or "\nuse power attacks\n on the boss."
    ) or ""
    
    local play_again = ((frame_count > 200) and "\n\npress ❎ and try again." or "") ..
    ((frame_count > 600) and "\nor don't." or "") ..
    ((frame_count > 700) and "\nup to you, really." or "") ..
    ((frame_count > 1400) and "\n♥" or "")

    local death_message = death_status .. death_greeting .. death_tip .. play_again

    print(death_message, -40 + active_view.x * 8 + 1, -20 + active_view.y * 8, 8)
    print(death_message, -40 + active_view.x * 8, -20 + active_view.y * 8 + 1, 0)
    print(death_message, -40 + active_view.x * 8, -20 + active_view.y * 8, 10)
end

function draw_system_info()
    if not stat_counter or costatus(stat_counter) == 'dead' then
        stat_counter = cocreate(
            function ()
                memstat =
                    stat(7) .. ' fps' .. '\n' ..
                    'mem usage: ' .. flr(stat(0)/20.48 + 0.5) .. '%' .. '\n' ..
                    'cpu usage: ' .. flr(stat(1)*100 + 0.5) .. '%'
                for t = 1, 30 do
                    yield()
                end
            end
        )
    end
    coresume(stat_counter)
    
    print(memstat, active_view.x * 8 - 59, active_view.y * 8 + 63 - 18, 4)
    print(memstat, active_view.x * 8 - 60, active_view.y * 8 + 63 - 17, 0)
    print(memstat, active_view.x * 8 - 60, active_view.y * 8 + 63 - 18, 10)
end