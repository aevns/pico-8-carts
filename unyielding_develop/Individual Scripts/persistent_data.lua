-- persistent data handling --
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

-- persistent states --
game_state = persistent_state:new({
    state_addr = 0x4300
})

run_number = persistent_state:new({
    state_addr = 0x4301
})

music_state = persistent_state:new({
    state_addr = 0x4302
})