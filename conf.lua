function love.conf(t)
    t.window.title = "Test Editor" -- Title of the window
    t.window.width = 800            -- Width of the window in pixels
    t.window.height = 600           -- Height of the window in pixels
    t.window.fullscreen = false     -- Set to true for fullscreen mode, false for windowed mode
    t.window.vsync = 1              -- Vertical synchronization (VSync): 1 for enabled, 0 for disabled
    t.console = true               -- Enable console (useful for debugging on Windows)
    t.window.resizable = true       -- Make the window resizable by the user
end
