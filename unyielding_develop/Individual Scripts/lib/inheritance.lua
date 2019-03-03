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