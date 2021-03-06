--[[
    minesweeper

    author: abhinav
    akshu3398@gmail.com
]]

require("src/dependencies")

function love.load()
    math.randomseed(os.time())
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT)
    love.window.setTitle('Minesweeper')

    -- grid = {}    

    -- for y=1,10 do
    --     table.insert( grid, {} )

    --     for x=1,10 do
    --         table.insert( grid[y], math.random(2))
    --     end
    -- end

    love.graphics.setFont(gFonts['start'])

    gStateMachine = StateMachine{
        ['title'] = function() return TitleState() end,
        ['play'] = function() return PlayState() end,
        ['victory'] = function() return VictoryState() end,
        ['game-over'] = function() return GameOverState() end
    }

    gStateMachine:change('title')

    love.mouse.buttonsPressed = {}
    love.keyboard.keysPressed = {}
end

function love.mousepressed( x, y, button, istouch, presses )
    love.mouse.buttonsPressed[button] = true
end

function love.mouse.wasPressed( button )
    return love.mouse.buttonsPressed[button]
end

function love.keyboard.wasPressed( key )
    return love.keyboard.keysPressed[key]
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

function love.update(dt)
    Timer.update(dt)
    gStateMachine:update(dt)

    love.mouse.buttonsPressed = {}
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    

    gStateMachine:render()

    push:finish()
end