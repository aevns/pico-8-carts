pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- utility --
-- one of the closest, fastest approximations possible using rnd[x]
function rnd_nrml(std)
    local x = -3*std
    for i = 1, 3 do
        x += rnd(std*2)
    end
    return x
end
-->8
-- init --

function _init()
    frame_count = 0
    view_pos = {15,5}
    pp_lighting_init(15, 7)
    pp_aura_init(
        {22, 32, 42, 52},
        4,
        4
    )
end
-->8
-- update --

function _update60()
                frame_count += 1
end

function _draw()
    cls()
    camera(view_pos[1], view_pos[2])

    if frame_count%480 < 1240 then
        map(0,0,0,0,128,128,0)
    end

    -- post processing
    if frame_count%240 < 1120 then
        pp_light_aura(time())
    end

    -- ui elements
    draw_system_info()
end
-->8
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
-->8
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
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
344444344444553454555455d4555d56d556661dd556dd16d5ddd5dd666665660000000005d615d66d516d5005d61dd55d5166d0500000000000000500000000
44434444554444444354534415664541d1dd6555d4ddd44504d0d4006ddd61dd5dd555050d6615d66d5166d00015051dd15166d000155505dd555100051dd150
443445445545545355535554440155d505050565040505d5ddd4ddd5d5555055d66d6d1d0d660015510066d005d60055d5006d50015d6d1d66ddd51005d6d610
544444444445544454343454d54456646661dd616dd1ddd1d04940d5101110116666665605d6156666516d500566101110016d5005d5665666665d500d666d50
44444344554554555553555446655104dd650005ddd44005ddd4ddd56566666611011101056615d66d51665005d5666665665d5005d610011101665001d666d0
43444434344454554354534440546455050566550505dd5504d0d405d1d6d66d5505555d05d615d66d516d50015ddd66d1d6d51005d6005d55006d500566dd50
434344544454444454555455654d6d4d61ddd616d1dddd1dd1ddd1dd50555dd5dd16ddd6001505d66d505100001555dd505551000d66151dd1505100015d5510
444444435534555454444453d54504556500005dd4400056d50005d4000000006656666605d61d6666d16d5050000000000000050d6615d55dd16d5000000000
00011eee0000011e0000000155050050544444450000000000001ee0000010000000000010110000ffffffff6d516d5115d615d60156665666656510ffffffff
eee1e001ee1010001100000045045050544450550005400010000001100000000000100000000350ffffffff5100dd0550dd15d610dddd1dddd1dd01ffffffff
0101000000010000000000004404504000000000000550000ee01000010000000000010050000003ffffffff6d5151dddd1515d65d055505555050d5ffffffff
0011eee00001eee0000011105404004055444445000000011001010000ee0540054000ee00030000ffffffff6d5005d66d5000156d510101111015d6ffffffff
0111001e000100010001000004045040000000000000eee000000000000005500550000003503501ffffffff6d510111101015d6510005d66d5005d6ffffffff
eee0e000ee1010001e00000054044040544444501010000100054000010000000000010010000000ffffffff5d050555505550d56d5151dddd1515d6ffffffff
00011e00000001000000000054045040505544550e00100000055000e01000000000e01000350100ffffffff10dd1dddd1dddd016d51dd0550dd0015ffffffff
00001110000001000000000005055050000000001001010000000000000010000000000111000011ffffffff01565666656665106d516d5115d615d6ffffffff
545dd545ffffffff00000000ffffffff0000000a90000000ffffffffffbfffffcfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
44566544ffffffff00010000ffffffff000a9009900a9000fffff8ff7ffbffff7cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
5565d655ffffffff00000000ffffffff000299a99a992000ff5fff8f67ffbfff67cfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
d6544d6dffffffff00000000ffffffff0a202922229202a04477777866ffbbff66cfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
d614456dffffffff00000010ffffffff0299920000299920f566668f56ffbbff56cfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
55611655ffffffff01000000ffffffff0029200000029200fffff8ff55ffbfff55cfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
44566544ffffffff00000000ffffffff00a2000000002900ffffffff5ffbffff5cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
545dd545ffffffff00000000ffffffffa992000a9000299affffffffffbfffffcfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0000001d61000000d541546d646ddd462292000220009222fffafaffff9afaff9affffff0000000000000000ffffffff0000888200008820ffffffff00008882
000000550100000015660414d1600011002900000000a200fffff9af7ff9afff79afffff0000000000000000ffffffff1000942010009440ffffffff10009420
0000156456100000005d06604400510000229000000a2200ff5fff9a67ffafff679affff0770770007707700ffffffff2100a9422100a942ffffffff2100a942
0001dd6146551000001d06d056dd50000992290000a229904477777966ff9aaf669affff78e78e7070270270ffffffff3510b3313510b331ffffffff3510b331
0005000556d56100000155d01600100002202999aa920220f566669a56ff9aaf569affff78888e7070000270ffffffff4510ccd14520ccd1ffffffff4510ccd1
0015664450046500000001d0405100000002922222292000fffff9af55ffafff559affff0788e70007002700ffffffff5100d5105500dd10ffffffff5100d510
11ddd6164145665100000014550000000002200220022000fffafaff5ff9afff59afffff007e700000727000ffffffff6d5111006d51e882ffffffff6d511100
6400004dd645005d00000016d10000000000000220000000ffffffffff9afaff9affffff0007000000070000ffffffff76d5f64576d5f645ffffffff76d5f645
05050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505
05050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505
05050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505
05050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505
05050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505
05050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000
__map__
51524b4747474c45454b4747474c510052000000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000454644444545444543444545505151520000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0050454f43434444434444434f44595052000000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0051724544434f44444f43434373510050520000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0052505052627243447352595400520000005200000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0052516262000062526262525458005652510000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0062620000625162620000575453535351520052510052000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0052626262625156520062525952545550515252525200520000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00625159535454535262524f70434040714f5052515250515200000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0062625254535354525156434344434041404343715052510000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0062626253535453535353414043404143434041437151005200000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0062625255625455515970434140414344434341414359525152000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0062626262515451527044444341434445444443404050525200000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00626262525754585243444444434d4e46444443414051520052000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006262626262544d4848484e45444b4c45454d4848484e520000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00626262625954490000004a464544464644490000004a000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000052525054490000005b484e43454d485c0000004a520000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005152544900000000005b48485c00000000004a000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000544900000000000000000000000000004a000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050505050505050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
