-- default lighting --

light_level_1 = {[0]=0,0,0,0,0,0,1,5,2,1,4,1,1,0,0,1}
light_level_2 = {[0]=0,0,0,1,1,0,5,13,8,5,9,3,13,1,0,5}
light_level_3 = {[0]=0,0,1,1,5,1,13,6,8,4,10,11,12,5,1,4}
light_level_4 = {[0]=0,1,2,3,4,5,6,7,8,9,10,11,12,13,1,15}

light_palates = {light_level_1, light_level_2, light_level_3, light_level_4}

-- custom lighting --
alt_palate = ({
    [0] = 0, 129, 130, 131,
    4, 5, 6, 7,
    8, 9, 10, 11,
    12, 132, 137, 134
    })

light_level_6 = {[0] = 0,13,15,11, 6, 6, 7, 7, 8,10,10,11, 7,13,15, 7}
light_level_5 = {[0] = 0, 2, 5, 3,15,15, 7, 7, 8,10,10,11, 6,12, 4, 6}
light_level_4 = {[0] = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15}
light_level_3 = {[0] = 0, 1, 2, 5,14, 2,15, 6, 4, 4, 9, 3,13,13, 2, 5}
light_level_2 = {[0] = 0, 0, 1, 2, 2, 2, 5,15,14, 4, 4, 3,13, 1, 2, 2}
light_level_1 = {[0] = 0, 0, 0, 1, 2, 1, 2, 5, 2, 4, 5, 5, 2, 1, 0, 2}
light_level_0 = {[0] = 0, 0, 0, 0, 0, 1, 2, 0, 2, 2, 2, 0, 1, 1, 0, 1}

light_palates = ({
    [0] = light_level_0,
    light_level_1, light_level_2,
    light_level_3, light_level_4,
    light_level_5, light_level_6
})

-- functions --

function fastsqrt(x)
    local y = -720.81166413 / (x + 23.21520395) + 31.12730778
    y = (y + x / y) / 2
    return (y + x / y) / 2
end

function aura_intercept(y, r)
	local rs = r * r
    local ys = y - 63.5
	ys = ys * ys
	
	if ys > rs then
		return nil
    end
	return fastsqrt(rs - ys)
end

function aura_spread(y, r)
	local rs = r * r
    local ys = y - 63.5
	ys = ys * ys
    
	if ys > rs then
		return 1
    end
	return r / fastsqrt(rs - ys)
end

function draw_aura(radius)
    for row = 0, 127 do
        local dx = aura_intercept(row, radius)
        if dx then
            local s = aura_spread(row, radius)
            x1 = (63.5 - dx + rnd(s * 16)) --\ 1
            x2 = (63.5 + dx - rnd(s * 16)) --\ 1
            if x1 < x2 then
                per = 1 / (1 + row / 800)
                tline(
                    x1, row,
                    x2, row,
                    cam_pos.x + (x1 / 8 - 8) * per,
                    cam_pos.y + (row / 8 - 8) * per,
                    per / 8
                )
            end
        end
    end
end

function lighting(seed)
    if seed then
        srand(seed)
    end
    for ll = 0, 6 do
        pal(light_palates[6 - ll])
        draw_aura(63 * (1 - ll / 7))
    end
end