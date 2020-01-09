-- utility --

-- inheritance system --
class = {}

function class:new(instance)
    local instance = instance or {}
    local instance_mt = {}
    instance_mt.__index = self
    return setmetatable(instance, instance_mt)
end

function class:set(values)
    for k, v in pairs(values) do
        self[k] = v
    end
end

function class:is_child_of(instance)
    local ancestor = self
    while getmetatable(ancestor) do
        if getmetatable(ancestor).__index == instance then
            return true
        end
        ancestor = getmetatable(ancestor).__index
    end
    return false
end

-- input --
input = {0,0,0,0,0,0}

function btnd(i)
    return btn(i) and not input[i + 1]
end

function btnu(i)
    return not btn(i) and input[i + 1]
end

function input_update()
    for i=0, 6 do
        input[i + 1] = btn(i)
    end
end

-- table checks --
function contains(table, item)
    for i in all(table) do
        if i == item then
            return true
        end
    end
    return false
end

-- entity overlap detection --
function overlapping(a, b)
    local a_size = a.size or 1
    local b_size = b.size or 1
    return (
        a.x < b.x + b_size and
        a.x + a_size > b.x and
        a.y < b.y + b_size and
        a.y + a_size > b.y
    )
end

-- supercover raycasting --
function ray_test(a, b, flags)
    flags = flags or 1
    
    local err = nil
    if b.x == a.x then
        err = function(x, y)
            return abs(a.x - x)
        end
    else
        err = function(x, y)
            return abs(a.y + (x - a.x) * (b.y - a.y) / (b.x - a.x) - y)
        end
    end

    local x = flr(a.x) + 0.5
    local y = flr(a.y) + 0.5
    local sx = b.x > a.x and 1 or -1
    local sy = b.y > a.y and 1 or -1

    while abs(b.x - x) > 0.5 or abs(b.y - y) > 0.5 do
        if fget(mget(x, y), flags) then
            return false
        end
        if (err(x, y + sy) < err(x + sx, y)) then
            y += sy
        else
            x += sx
        end
    end
    if fget(mget(x, y), flags) then
        return false
    end
    return true
end

-- approximate normal sample with mean 0
function rnd_nrml(std)
    local x = -3*std
    for i = 1, 3 do
        x += rnd(std*2)
    end
    return x
end