-- menu items --
menuitem( 1, "toggle music",
    function()
        music_state:toggle();
        if music_state:get() then
            music(0, 1000, 3)
        else
            music(-1, 0, 3)
        end
    end
)