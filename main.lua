-- main.lua
-- Main entry point for the Love2D application

local splitter = require("gui.splitter")
local editor = require("gui.editor")
local filetree = require("gui.filetree")

-- Initialize the application
function love.load()
    splitter.load()
    editor.load()
    filetree.load()
end

-- Update the application state
function love.update(dt)
    print("sa")
    editor.update(dt)
end

-- Draw the application contents
function love.draw()
    splitter.draw()
end

-- Handle key press events
function love.keypressed(key)
    editor.keypressed(key)
end

-- Handle text input events
function love.textinput(text)
    editor.textinput(text)
end

-- Handle mouse press events
function love.mousepressed(x, y, button)
    splitter.mousepressed(x, y, button)
end

-- Handle mouse movement events
function love.mousemoved(x, y, dx, dy)
    splitter.mousemoved(x, y, dx, dy)
end

-- Handle mouse release events
function love.mousereleased(x, y, button)
    splitter.mousereleased(x, y, button)
end

-- Handle mouse wheel movement events
function love.wheelmoved(x, y)
    splitter.wheelmoved(x, y)
end
