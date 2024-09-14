-- Dependencies
local cursor = require("cursor")
local config = require("config")

-- Editor module initialization
local editor = {}
local lines = {} -- Text lines
local scrollY = 0 -- Vertical scroll position
local scrollX = 0 -- Horizontal scroll position
local scrollSpeed = 20 -- Smooth scroll speed
local scrollBarWidth = 10 -- Scroll bar width
local cursorVisible = true -- Cursor visibility

-- State variables for mouse and scrolling
local isScrollingY = false
local isScrollingX = false
local isMouseDown = false -- Is the mouse button pressed?
local scrollClickOffsetY = 0
local scrollClickOffsetX = 0

-- Load initial text into the editor
function editor.load()
    local text = "Bu bir editördür.\nBuraya yazı yazabilirsiniz."
    for line in text:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
end

-- Update editor state each frame
function editor.update(dt)
    cursor.updateBlink(dt)

    -- Smooth scrolling based on keyboard input
    if love.keyboard.isDown("up") then
        scrollY = math.max(0, scrollY - scrollSpeed * dt)
    elseif love.keyboard.isDown("down") then
        scrollY = math.min(editor.getMaxScrollY(), scrollY + scrollSpeed * dt)
    end
    
    if love.keyboard.isDown("left") then
        scrollX = math.max(0, scrollX - scrollSpeed * dt)
    elseif love.keyboard.isDown("right") then
        scrollX = math.min(editor.getMaxScrollX(), scrollX + scrollSpeed * dt)
    end
end

-- Draw the editor content and scroll bars
function editor.draw(x, y, width, height)
    love.graphics.push()
    love.graphics.translate(x - scrollX, y - scrollY) -- Apply scrolling

    for i, line in ipairs(lines) do
        editor.drawLine(line, i, 0, (config.fontSize + 5) * (i - 1))
    end

    love.graphics.pop()

    -- Draw scroll bars and cursor
    editor.drawScrollBars(x, y, width, height)
    cursor.drawCursor(lines, scrollY, scrollX, x, y)
end

-- Draw a single line of text with line numbers
function editor.drawLine(line, lineNumber, x, y)
    local numberOffset = 5
    -- Background for line numbers
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x, y, config.lineNumberBackgroundWidth, config.fontSize + 5)

    -- Line numbers
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print(string.format("%3d", lineNumber), x + numberOffset, y)

    -- Line text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(line, x + config.lineNumberBackgroundWidth + numberOffset, y)
end

-- Draw the vertical and horizontal scroll bars
function editor.drawScrollBars(x, y, width, height)
    -- Vertical scroll bar
    local contentHeight = #lines * (config.fontSize + 5)
    if contentHeight > height then
        local barHeight = height / contentHeight * height
        local scrollYPos = scrollY / contentHeight * height
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", x + width - scrollBarWidth, y + scrollYPos, scrollBarWidth, barHeight)
    end

    -- Horizontal scroll bar
    local maxLineWidth = editor.getMaxLineWidth()
    if maxLineWidth > width then
        local barWidth = width / maxLineWidth * width
        local scrollXPos = scrollX / maxLineWidth * width
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", x + scrollXPos, y + height - scrollBarWidth, barWidth, scrollBarWidth)
    end
end

-- Calculate the maximum width of all lines
function editor.getMaxLineWidth()
    local maxWidth = 0
    for _, line in ipairs(lines) do
        -- Use the font to calculate text width accurately
        maxWidth = math.max(maxWidth, love.graphics.getFont():getWidth(line))
    end
    return maxWidth
end

-- Calculate maximum vertical scroll value
function editor.getMaxScrollY()
    local contentHeight = #lines * (config.fontSize + 5)
    return math.max(0, contentHeight - love.graphics.getHeight())
end

-- Calculate maximum horizontal scroll value
function editor.getMaxScrollX()
    local maxLineWidth = editor.getMaxLineWidth()
    return math.max(0, maxLineWidth - love.graphics.getWidth())
end

-- Handle keyboard inputs
function editor.keypressed(key)
    if key == "backspace" then
        editor.deleteCharacter()
    elseif key == "return" then
        editor.insertNewLine()
    elseif key == "left" then
        cursor.moveLeft(lines)
    elseif key == "right" then
        cursor.moveRight(lines)
    elseif key == "up" then
        cursor.moveUp(lines)
    elseif key == "down" then
        cursor.moveDown(lines)
    end
end

-- Handle text input (character insertion)
function editor.textinput(text)
    editor.insertCharacter(text)
end

-- Insert a character at the cursor position
function editor.insertCharacter(char)
    local line = lines[cursor.y]
    if line then
        local before = line:sub(1, cursor.x - 1)
        local after = line:sub(cursor.x)
        lines[cursor.y] = before .. char .. after
        cursor.moveRight(lines) -- Move cursor to the next character
    end
end

-- Delete a character at the cursor position
function editor.deleteCharacter()
    local line = lines[cursor.y]
    if cursor.x > 1 then
        local before = line:sub(1, cursor.x - 2)
        local after = line:sub(cursor.x)
        lines[cursor.y] = before .. after
        cursor.moveLeft(lines) -- Move cursor back
    elseif cursor.y > 1 then
        -- If at the start of the line, merge with the previous line
        local previousLine = lines[cursor.y - 1]
        cursor.x = #previousLine + 1
        lines[cursor.y - 1] = previousLine .. line
        table.remove(lines, cursor.y)
        cursor.moveUp(lines)
    end
end

-- Insert a new line at the cursor position
function editor.insertNewLine()
    local line = lines[cursor.y]
    local before = line:sub(1, cursor.x - 1)
    local after = line:sub(cursor.x)
    lines[cursor.y] = before
    table.insert(lines, cursor.y + 1, after)
    cursor.y = cursor.y + 1
    cursor.x = 1
end

-- Handle mouse wheel scrolling
function editor.wheelmoved(x, y)
    if y > 0 then
        scrollY = math.max(0, scrollY - scrollSpeed)
    elseif y < 0 then
        scrollY = math.min(editor.getMaxScrollY(), scrollY + scrollSpeed)
    end
end

-- Handle mouse pressed event for scrolling
function editor.mousepressed(x, y, button, editorX, editorY, editorWidth, editorHeight)
    if button == 1 then
        isMouseDown = true -- Mouse is held down

        -- Vertical scroll bar interaction
        local contentHeight = #lines * (config.fontSize + 5)
        if contentHeight > editorHeight then
            local barHeight = editorHeight / contentHeight * editorHeight
            local scrollYPos = scrollY / contentHeight * editorHeight
            if x > editorX + editorWidth - scrollBarWidth and y > editorY + scrollYPos and y < editorY + scrollYPos + barHeight then
                isScrollingY = true
                scrollClickOffsetY = y - scrollYPos
            end
        end

        -- Horizontal scroll bar interaction
        local maxLineWidth = editor.getMaxLineWidth()
        if maxLineWidth > editorWidth then
            local barWidth = editorWidth / maxLineWidth * editorWidth
            local scrollXPos = scrollX / maxLineWidth * editorWidth
            if x > editorX + scrollXPos and y > editorY + editorHeight - scrollBarWidth and y < editorY + editorHeight then
                isScrollingX = true
                scrollClickOffsetX = x - scrollXPos
            end
        end
    end
end

-- Handle mouse movement while scrolling
function editor.mousemoved(x, y, dx, dy, editorWidth, editorHeight)
    if isMouseDown then
        -- Vertical scrolling
        if isScrollingY then
            local contentHeight = #lines * (config.fontSize + 5)
            local maxScrollY = editor.getMaxScrollY()
            local scrollYPos = y - scrollClickOffsetY
            scrollY = math.max(0, math.min(maxScrollY, scrollYPos / editorHeight * contentHeight))
        end

        -- Horizontal scrolling
        if isScrollingX then
            local maxLineWidth = editor.getMaxLineWidth()
            local maxScrollX = editor.getMaxScrollX()
            local scrollXPos = x - scrollClickOffsetX
            scrollX = math.max(0, math.min(maxScrollX, scrollXPos / editorWidth * maxLineWidth))
        end
    end
end

-- Handle mouse release after scrolling
function editor.mousereleased(x, y, button)
    if button == 1 then
        isScrollingY = false
        isScrollingX = false
        isMouseDown = false -- Mouse is released
        scrollClickOffsetY = 0
        scrollClickOffsetX = 0
    end
end

return editor
