-- gui/splitter.lua
-- Splitter module for handling the interaction between the file tree and editor

local config = require("config")
local editor = require("gui.editor")
local filetree = require("gui.filetree")

local splitter = {}
local dragging = false -- Indicates if the splitter is being dragged

-- Initialize the splitter's position
function splitter.load()
    -- Set the initial position of the splitter based on the screen width and config
    splitter.position = love.graphics.getWidth() * config.splitterPosition
end

-- Draw the splitter, file tree, and editor
function splitter.draw()
    -- Draw the file tree on the left
    filetree.draw(0, 0, splitter.position, love.graphics.getHeight())

    -- Calculate dimensions for the editor area
    local editorX = splitter.position + 4 -- Add 4 px space after the splitter line
    local editorWidth = love.graphics.getWidth() - editorX -- Remaining width for the editor

    -- Draw the editor
    editor.draw(editorX, 0, editorWidth, love.graphics.getHeight())

    -- Draw the splitter line
    love.graphics.setColor(0.5, 0.5, 0.5) -- Gray color for the splitter
    love.graphics.rectangle("fill", splitter.position, 0, 4, love.graphics.getHeight()) -- Splitter line
end

-- Handle mouse press events
function splitter.mousepressed(x, y, button)
    if button == 1 and x > splitter.position - 5 and x < splitter.position + 5 then
        dragging = true
    else
        -- Forward mouse press events to the editor if clicking on the editor area
        local editorX = splitter.position + 4
        local editorWidth = love.graphics.getWidth() - editorX
        editor.mousepressed(x, y, button, editorX, 0, editorWidth, love.graphics.getHeight())
    end
end

-- Handle mouse movement events
function splitter.mousemoved(x, y, dx, dy)
    if dragging then
        -- Adjust splitter position within screen bounds
        splitter.position = math.max(100, math.min(x, love.graphics.getWidth() - 100))
    else
        -- Forward mouse movement events to the editor if moving over the editor area
        local editorX = splitter.position + 4
        local editorWidth = love.graphics.getWidth() - editorX
        editor.mousemoved(x, y, dx, dy, editorWidth, love.graphics.getHeight())
    end
end

-- Handle mouse release events
function splitter.mousereleased(x, y, button)
    if button == 1 then
        dragging = false
    end

    -- Forward mouse release events to the editor
    editor.mousereleased(x, y, button)
end

-- Handle mouse wheel scrolling
function splitter.wheelmoved(x, y)
    editor.wheelmoved(x, y)
end

return splitter
