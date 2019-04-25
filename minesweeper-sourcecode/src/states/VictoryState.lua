--[[
    VictoryState Class
]]

VictoryState = Class{__includes = BaseState}

function VictoryState:init( ... )
    --? to do (timer reset)
    -- Timer.clear()
end

function VictoryState:update ( dt )
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play')
    end
end

function VictoryState:enter( params )
    self.gameGrid = params.gameGrid
end

function VictoryState:render( ... )
    love.graphics.clear(0, 0.3, 0, 1)
    self.gameGrid:render()
    love.graphics.printf('You Won!', 0, 16, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('press enter to play again.', 0, VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH, 'center')
end