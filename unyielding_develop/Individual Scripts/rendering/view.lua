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