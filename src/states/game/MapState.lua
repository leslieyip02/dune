MapState = Class{__includes = BaseState}

function MapState:init(def)
    self.map = def.map
    self.mapEdges = self:edges(self.map)
    self.currentRoom = def.currentRoom
    
    self.ox = (VIRTUAL_WIDTH - (self.mapEdges.right - self.mapEdges.left + 1) * MAP_GRID_WIDTH) / 2 + MAP_WALL_WIDTH / 2
    self.oy = (VIRTUAL_HEIGHT - (self.mapEdges.down - self.mapEdges.up + 1) * MAP_GRID_WIDTH) / 2 + MAP_WALL_WIDTH / 2
end

function MapState:edges(map)
    local edges = {
        up = #map,
        down = 1,
        left = #map[1],
        right = 1
    }

    -- find edges of map excluding empty rooms
    for j = 1, #map do
        for i = 1, #map[1] do
            if map[j][i] then
                edges.up = math.min(edges.up, j)
                edges.down = math.max(edges.down, j)
                edges.left = math.min(edges.left, i)
                edges.right = math.max(edges.right, i)
            end
        end
    end

    return edges
end

function MapState:update(dt)
    if love.keyboard.wasPressed('m') then
        gStateStack:pop()
    end
end

function MapState:render()
    local function roomColor() love.graphics.setColor(0.5, 0.5, 0.5, 1) end
    local function wallColor() love.graphics.setColor(1, 1, 1, 1) end
    local function doorColor() love.graphics.setColor(0, 0, 1, 1) end
    local function currentRoomColor() love.graphics.setColor(0, 0, 1, 1) end

    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    love.graphics.push()
    love.graphics.translate(self.ox, self.oy)

    for j = 1, self.mapEdges.down - self.mapEdges.up + 1 do
        for i = 1, self.mapEdges.right - self.mapEdges.left + 1 do
            local mapX = i + self.mapEdges.left - 1
            local mapY = j + self.mapEdges.up - 1
            
            local room = self.map[mapY][mapX]
            if room then
                if room.adj_rooms['up'] or room.adj_rooms['down']
                    or room.adj_rooms['left'] or room.adj_rooms['right'] then
                        
                    roomColor()
                    if type(room.marker) == 'number' and room.marker < 45 and
                        self.currentRoom.player and self.currentRoom.player.markedMap then 
                        love.graphics.setColor(245 / 255, 183 / 255, 25 / 255, 1) 
                    end
                    if room.marker == 'S' then love.graphics.setColor(0, 1, 0, 1) end
                    -- marker for the current room
                    if mapX == self.currentRoom.mapX and mapY == self.currentRoom.mapY then currentRoomColor() end

                    love.graphics.rectangle('fill', (i - 1) * MAP_GRID_WIDTH, (j - 1) * MAP_GRID_WIDTH, MAP_ROOM_WIDTH, MAP_ROOM_WIDTH)
                
                    if not room.adj_rooms['up'] then
                        wallColor()
                        love.graphics.rectangle('fill', (i - 1) * MAP_GRID_WIDTH - MAP_WALL_WIDTH, (j - 1) * MAP_GRID_WIDTH - MAP_WALL_WIDTH, MAP_GRID_WIDTH, MAP_WALL_WIDTH)
                    else
                        roomColor()
                        -- if room.doors['up'] then doorColor() else roomColor() end
                        love.graphics.rectangle('fill', (i - 1) * MAP_GRID_WIDTH, (j - 1) * MAP_GRID_WIDTH - MAP_WALL_WIDTH, MAP_ROOM_WIDTH, MAP_WALL_WIDTH)
                    end

                    if not room.adj_rooms['down'] then
                        wallColor()
                        love.graphics.rectangle('fill', (i - 1) * MAP_GRID_WIDTH, (j - 1) * MAP_GRID_WIDTH + MAP_ROOM_WIDTH, MAP_GRID_WIDTH, MAP_WALL_WIDTH)
                    else
                        roomColor()
                        -- if room.doors['down'] then doorColor() else roomColor() end
                        love.graphics.rectangle('fill', (i - 1) * MAP_GRID_WIDTH, (j - 1) * MAP_GRID_WIDTH + MAP_ROOM_WIDTH, MAP_ROOM_WIDTH, MAP_WALL_WIDTH)
                    end
        
                    if not room.adj_rooms['left'] then
                        wallColor()
                        love.graphics.rectangle('fill', (i - 1) * MAP_GRID_WIDTH - MAP_WALL_WIDTH, (j - 1) * MAP_GRID_WIDTH, MAP_WALL_WIDTH, MAP_GRID_WIDTH)
                    else
                        roomColor()
                        -- if room.doors['left'] then doorColor() else roomColor() end
                        love.graphics.rectangle('fill', (i - 1) * MAP_GRID_WIDTH - MAP_WALL_WIDTH, (j - 1) * MAP_GRID_WIDTH, MAP_WALL_WIDTH, MAP_ROOM_WIDTH)
                    end

                    if not room.adj_rooms['right'] then
                        wallColor()
                        love.graphics.rectangle('fill', (i - 1) * MAP_GRID_WIDTH + MAP_ROOM_WIDTH, (j - 1) * MAP_GRID_WIDTH - MAP_WALL_WIDTH, MAP_WALL_WIDTH, MAP_GRID_WIDTH)
                    else
                        roomColor()
                        -- if room.doors['right'] then doorColor() else roomColor() end
                        love.graphics.rectangle('fill', (i - 1) * MAP_GRID_WIDTH + MAP_ROOM_WIDTH, (j - 1) * MAP_GRID_WIDTH, MAP_WALL_WIDTH, MAP_ROOM_WIDTH)
                    end
                end 
            end
        end
    end

    love.graphics.pop()
end