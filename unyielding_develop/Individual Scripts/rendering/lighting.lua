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