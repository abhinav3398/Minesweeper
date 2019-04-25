--[[
    TitleState Class
]]

TitleState = Class{__includes = BaseState}

function TitleState:init( ... )
    -- body
end

function TitleState:update( dt )
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play')
    end
end

function TitleState:render( ... )
    love.graphics.printf('Minesweeper', 0, VIRTUAL_HEIGHT/2 - 8, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('press enter to play', 0, VIRTUAL_HEIGHT/2 + 16, VIRTUAL_WIDTH, 'center')
end