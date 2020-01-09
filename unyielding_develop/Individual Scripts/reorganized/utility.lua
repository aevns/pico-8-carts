-- utility --

-- basic inheritance system --
class = {}

function class:on_new()
end

function class:new(instance)
    local instance = instance or {}
    local instance_mt = {}
    instance_mt.__index = self
    setmetatable(instance, instance_mt)
	instance:on_new()
	return instance
end

function class:set(values)
    for k, v in pairs(values) do
        self[k] = v
    end
end

function class:parent()
    return getmetatable(self).__index
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

-- persistent state handling --
persistent_state = class:new({
    state_addr = nil;
})

function persistent_state:set(state)
    state = state or 1
    poke(state_addr, state)
end

function persistent_state:toggle()
    poke(state_addr, 1 - peek(state_addr))
end

function persistent_state:get()
    peek(state_addr)
end

-- input --
input = class:new({
    state = {0,0,0,0,0,0}
})

function input:btnd(i)
    return btn(i) and not self.state[i + 1]
end

function input:btnu(i)
    return not btn(i) and self.state[i + 1]
end

function input:update()
    for i=0, 6 do
        self.state[i + 1] = btn(i)
    end
end

-- camera definition --
view = class:new({
    target = nil,
    x = 0,
    y = 0,
    x_buffer = {},
    y_buffer = {},
    smoothness = 10,
    delay = 25,
    frame_index = 0
})

function view:update()
    self.frame_index += 1
    local frame = 1 + self.frame_index%self.delay
    local old_frame = 1 + (self.frame_index - self.smoothness)%self.delay

    self.x -= (self.x_buffer[old_frame] or 0) / self.smoothness
    self.x_buffer[old_frame] = self.target.x
    self.x += (self.x_buffer[frame] or 0) / self.smoothness

    self.y -= (self.y_buffer[old_frame] or 0) / self.smoothness
    self.y_buffer[old_frame] = self.target.y
    self.y += (self.y_buffer[frame] or 0) / self.smoothness
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
-- returns true if square a and square b overlap
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
    local x = -3 * std
    for i = 1, 3 do
        x += rnd(std * 2)
    end
    return x
end