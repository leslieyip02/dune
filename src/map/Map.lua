Map = Class{}

-- relative grid offset of adjacent room from current room
local offset = {
    up = { 0, -1 },
    down = { 0, 1 },
    left = { -1, 0 },
    right = { 1, 0 }
}

local inverseDirs = {
    up = 'down',
    down = 'up',
    left = 'right',
    right = 'left'
}

local crystalColors = { 34, 35, 36, 37, 38, 39, 40 }
local powerups = { 41, 43, 44 }

function Map:init(def)
    self.w = def.w
    self.h = def.h
    self.numRooms = 0
    self.mapSize = def.w * def.h
    self.map = {}

    self.numCrystals = 0
end

function Map:emptyGrid(w, h)
    local grid = {}

    for j = 1, h do
        local row = {}
        for i = 1, w do
            local room = Room({ mapX = i, mapY = j })
            table.insert(row, room)
        end
        table.insert(grid, row)
    end

    return grid
end 

function Map:mazeRunner(currentRoom, grid)
    local function placeMarker(possibleMarkers)
        local randMarker = possibleMarkers[math.random(#possibleMarkers)]
        for i = #possibleMarkers, 1, -1 do
            if possibleMarkers[i] == randMarker then table.remove(possibleMarkers, i) end
        end
        
        currentRoom.marker = randMarker
    end

    currentRoom.traced = true
    currentRoom.timesTraced = currentRoom.timesTraced + 1
    self.numRooms = self.numRooms + 1

    -- random chance to stop tracing and start backtracking
    if self.numRooms / self.mapSize > 0.5 and math.random() < 0.5 then
        -- chance to place powerup
        if math.random() < 0.3 then placeMarker(powerups) end
        return grid
    end

    local validRooms = {}
    local validDirs = {}
    local count = 0

    -- look for valid rooms to trace into
    for dir, adj_room in pairs(currentRoom.adj_rooms) do
        if not adj_room then
            local ox, oy = offset[dir][1], offset[dir][2]
            local row = grid[currentRoom.mapY + oy]
            if row then
                local room = row[currentRoom.mapX + ox]
                if room and not room.traced then
                    table.insert(validRooms, room)
                    table.insert(validDirs, dir)
                    count = count + 1
                end
            end
        end
    end

    -- backtrack if there are no valid rooms to trace to
    if count == 0 then
        if not currentRoom.marker then
            -- mark dead ends
            if #crystalColors == 7 or (currentRoom.timesTraced == 1 and math.random() < 0.6) or math.random() < 0.4 then
                -- place crystal
                if math.random() > 0.5 and #crystalColors > 1 then
                    placeMarker(crystalColors)
                    self.numCrystals = self.numCrystals + 1

                -- place powerup
                else
                    placeMarker(powerups)
                end
            end
        end
        return grid
    end

    -- pick a random room to trace into
    local randIndex = math.random(count)
    local nextRoom = validRooms[randIndex]
    local nextDir = validDirs[randIndex]
    local inverseDir = inverseDirs[nextDir]

    currentRoom.adj_rooms[nextDir] = nextRoom
    nextRoom.adj_rooms[inverseDir] = currentRoom

    -- -- random chance to create a door
    -- if math.random() > 0.8 then
    --     currentRoom.doors[nextDir] = true
    --     nextRoom.doors[inverseDir] = true
    --     if math.random() > 0.8 then
    --         nextRoom.marker = 'X'
    --     end
    -- end

    -- recursively trace through all rooms
    self:mazeRunner(nextRoom, grid)
    return self:mazeRunner(currentRoom, grid)
end

function Map:generate(startX, startY)
    self.numRooms = 0
    self.numCrystals = 0

    crystalColors = { 34, 35, 36, 37, 38, 39, 40 }
    powerups = { 41, 43, 44 }

    self.map = self:emptyGrid(self.w, self.h)

    -- pick random room to start
    startCell = self.map[startY][startX]
    startCell.marker = 'S'

    self.map = self:mazeRunner(startCell, self.map)
    
    -- set rooms to empty if they aren't connected
    for j = 1, self.h do
        for i = 1, self.w do
            if not self.map[j][i].traced then
                self.map[j][i] = false
            end
        end
    end

    if self.numCrystals <= 1 then
        return self:generate(startX, startY)
    end

    self.numCrystals = self.numCrystals - 1

    return self.map
end