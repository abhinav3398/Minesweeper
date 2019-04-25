--[[
    GameGrid Class
]]

GameGrid = Class{}

local xPos, yPos

function GameGrid:init( width, height )
    self.width = width
    self.height = height
    self.left0ffset = (VIRTUAL_WIDTH - (GRID_WIDTH * TILE_SIZE)) / 2
    self.top0ffset = (VIRTUAL_HEIGHT - (GRID_HEIGHT * TILE_SIZE)) / 2

    self.grid = {}
    self.score = 0

    self.isHighLighting = false

    self.highlightingTile = {x = 0, y = 0}

    for y=1,self.height do
        table.insert( self.grid, {} )

        for x=1,self.width do
            local isBomb = math.random( 10 ) == 1 and true or false
            local gridTile = GridTile(isBomb)
            
            table.insert( self.grid[y], gridTile )
            
            -- local isHidden = math.random( 2 ) == 1 and true or false
            local isHidden = true
            gridTile.isHidden = isHidden
        end
    end

    self:calculateNumbers()
    --? for debugging
    -- self:revealAll()
end

function GameGrid:revealAll( ... )
    for y=1,self.height do
        for x=1,self.width do
            self.grid[y][x].isHidden = false
        end
    end
end

function GameGrid:isVictory( ... )
    local won = true
    
    for y=1,self.height do
        for x=1,self.width do
            if self.grid[y][x].isHidden and not self.grid[y][x].isBomb then
                won = false
            end
        end
    end

    return won
end

function GameGrid:calculateNumbers( ... )    
    for y=1,self.height do
        for x=1,self.width do
            --* store all bombs we see around tile,
            --* checking all neighbours
            local numBombNeighbours = 0

            --* check top left
            if x > 1 and y > 1 then
                if self.grid[x-1][y-1].isBomb then
                    numBombNeighbours = numBombNeighbours + 1
                end
            end

            --* check top
            if y > 1 then
                if self.grid[x][y-1].isBomb then
                    numBombNeighbours = numBombNeighbours + 1
                end
            end

            --* check top right
            if x < self.width and y > 1 then
                if self.grid[x+1][y-1].isBomb then
                    numBombNeighbours = numBombNeighbours + 1
                end
            end

            --* check left
            if x > 1 then
                if self.grid[x-1][y].isBomb then
                    numBombNeighbours = numBombNeighbours + 1
                end
            end

            --* check right
            if x < self.width then
                if self.grid[x+1][y].isBomb then
                    numBombNeighbours = numBombNeighbours + 1
                end
            end

            --* check bottom left
            if x > 1 and y < self.height then
                if self.grid[x-1][y+1].isBomb then
                    numBombNeighbours = numBombNeighbours + 1
                end
            end
            --* check bottom
            if y < self.height then
                if self.grid[x][y+1].isBomb then
                    numBombNeighbours = numBombNeighbours + 1
                end
            end

            --* check bottom right
            if x < self.width and y < self.height then
                if self.grid[x+1][y+1].isBomb then
                    numBombNeighbours = numBombNeighbours + 1
                end
            end

            -- store number at that tile
            self.grid[x][y].numBombNeighbours = numBombNeighbours
        end
    end
end

function GameGrid:update( dt )    
    xPos, yPos = push:toGame(love.mouse.getPosition())

    local highLightingSomething = false

    for y=1,self.width do
        for x=1,self.height do
            local tile = self.grid[x][y]

            if xPos >= self.left0ffset + (x - 1) * TILE_SIZE and 
            xPos <= self.left0ffset + (x - 1) * TILE_SIZE + TILE_SIZE then                
                if yPos >= self.top0ffset + (y - 1) * TILE_SIZE and
                yPos <= self.top0ffset + (y - 1) * TILE_SIZE + TILE_SIZE then
                    if self.grid[y][x].isHidden then
                        self.isHighLighting = true
                    else
                        self.isHighLighting = false
                    end
                    self.highlightingTile = {x = x, y = y}

                    if love.mouse.wasPressed(1) and not self.grid[y][x].isFlagged then

                        if self.grid[y][x].isBomb then                            
                            self.grid[y][x].isHidden = false
                            self:revealAll()
                            gStateMachine:change('game-over', {
                                gameGrid = self
                            })
                        else
                            self:revealTile(x, y)

                            if self:isVictory() then                            
                                gStateMachine:change('victory', {
                                    gameGrid = self
                                })
                            end
                        end                                                  

                        elseif love.mouse.wasPressed(2) and self.grid[y][x].isHidden then
                            self.grid[y][x].isFlagged = not self.grid[y][x].isFlagged
                    end

                    highLightingSomething = true
                end
            end
        end
    end

    if not highLightingSomething then
        self.isHighLighting = false
    end
end

function GameGrid:revealTile( x, y )    
    local  tile = self.grid[y][x]

    --* immediately exit if bomb; no recursion no reveal
    if tile.isBomb or not tile.isHidden then return end

    tile.isHidden = false
    tile.isFlagged = false
    self.score = self.score + 5

    --* don't recurse if this is a number tile or bomb
    if tile.numBombNeighbours == 0 then

        --* top tile
        if y > 1 then
            self:revealTile(x, y - 1)
        end        

        --* bottom tile
        if y < GRID_HEIGHT then
            self:revealTile(x, y + 1)
        end        

        --* left tile
        if x > 1 then
            self:revealTile(x - 1, y)
        end        

        --* right tile
        if x < GRID_WIDTH then
            self:revealTile(x + 1, y)
        end        
    end
end

function GameGrid:render(  )
    for y = 1, self.height do
        for x = 1, self.width do
            self.grid[y][x]:render(self.left0ffset + (x - 1) * TILE_SIZE, 
                                    self.top0ffset + (y - 1) * TILE_SIZE)            
        end
    end

    if self.isHighLighting then
        love.graphics.setColor(1, 1, 1, 0.4)
        love.graphics.rectangle('fill', self.left0ffset + (self.highlightingTile.x - 1) * TILE_SIZE, 
                                    self.top0ffset + (self.highlightingTile.y - 1) * TILE_SIZE, 
                                TILE_SIZE, TILE_SIZE)
        love.graphics.setColor(1, 1, 1, 1)
    end

    --? for debugging
    -- love.graphics.setFont(gFonts['start-small'])
    -- love.graphics.print('X: ' .. tostring(xPos) .. ', Y: ' .. tostring(yPos), 0, VIRTUAL_HEIGHT - 48)
    -- love.graphics.print('Highlighting tile: ' .. tostring(self.isHighLighting), 0, VIRTUAL_HEIGHT - 36)
    -- love.graphics.print('Highlighting x: ' .. tostring(self.highlightingTile.x) .. 
    --                     ' Highlighting y: ' .. tostring(self.highlightingTile.y), 0, VIRTUAL_HEIGHT - 24)
    -- love.graphics.setFont(gFonts['start'])
end