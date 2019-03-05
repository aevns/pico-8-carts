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
        (active_miniboss[1] == nil) and "victory, for now.\nbut debris seems to\nbe blocking your path..."
        or "you died."
    ) or ""

    local death_greeting = (frame_count > 120) and (
        (active_miniboss[1] == nil) and "\nthanks for playing!"
        or (rnd(1) > 0.5) and "\noh, by the way,"
        or (rnd(1) > 0.5) and "\nyou know what..."
        or (rnd(1) > 0.75) and "\nuhh..."
        or "hmm."
    ) or ""

    local death_tip = (frame_count > 160) and (
        (active_miniboss[1] == nil) and "\n♥"
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