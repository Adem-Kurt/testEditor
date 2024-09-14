-- cursor.lua
-- Module for handling cursor behavior in the editor

local config = require("config")

local cursor = {
    x = 1,             -- Horizontal position of the cursor
    y = 1,             -- Vertical position of the cursor
    blink_timer = 0,   -- Timer for cursor blink effect
    visible = true     -- Visibility state of the cursor
}

-- Update the cursor blink effect
function cursor.updateBlink(dt)
    cursor.blink_timer = cursor.blink_timer + dt
    if cursor.blink_timer >= config.blink_speed then
        cursor.visible = not cursor.visible
        cursor.blink_timer = 0
    end
end

-- Calculate the X position of the cursor
function cursor.getCursorXPos(line, scrollX, x)
    local font = love.graphics.getFont()
    local textBeforeCursor = line:sub(1, cursor.x - 1)
    local cursorXPos = font:getWidth(textBeforeCursor)
    return x + config.lineNumberBackgroundWidth + 5 + cursorXPos - scrollX
end

-- Draw the cursor on the screen
function cursor.drawCursor(lines, scrollY, scrollX, x, y)
    if cursor.visible then
        local line = lines[cursor.y]
        if line then
            local cursorXPos = cursor.getCursorXPos(line, scrollX, x)
            local cursorYPos = y + (config.fontSize + 5) * (cursor.y - 1) - scrollY
            love.graphics.setColor(1, 1, 1) -- Set color to white
            love.graphics.rectangle("fill", cursorXPos, cursorYPos, 2, config.fontSize) -- Draw the cursor
        end
    end
end

-- Move the cursor up in the text
function cursor.moveUp(lines)
    if cursor.y > 1 then
        cursor.y = cursor.y - 1
        cursor.x = math.min(cursor.x, #lines[cursor.y] + 1)
    end
end

-- Move the cursor down in the text
function cursor.moveDown(lines)
    if cursor.y < #lines then
        cursor.y = cursor.y + 1
        cursor.x = math.min(cursor.x, #lines[cursor.y] + 1)
    end
end

-- Move the cursor left in the text
function cursor.moveLeft(lines)
    if cursor.x > 1 then
        cursor.x = cursor.x - 1
    elseif cursor.y > 1 then
        cursor.y = cursor.y - 1
        cursor.x = #lines[cursor.y] + 1
    end
end

-- Move the cursor right in the text
function cursor.moveRight(lines)
    if cursor.x <= #lines[cursor.y] then
        cursor.x = cursor.x + 1
    elseif cursor.y < #lines then
        cursor.y = cursor.y + 1
        cursor.x = 1
    end
end

return cursor
