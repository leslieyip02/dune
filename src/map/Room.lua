Room = Class{}

local offset = {
    NE = { -1, -1 },
    N = { 0, -1 },
    NW = { 1, -1 },
    E = { -1, 0 },
    W = { 1, 0 },
    SE = { -1, 1 },
    S = { 0, 1 },
    SW = { 1, 1 },
    NN = { 0, -2 },
    SS = { 0, 2 },
    EE = { -2, 0 },
    WW = { 2, 0 }
}

local walls = {
    up = { 1, 1, ROOM_WIDTH, 1 },
    down = { 1, ROOM_HEIGHT, ROOM_WIDTH, ROOM_HEIGHT },
    left = { 1, 1, 1, ROOM_HEIGHT },
    right = { ROOM_WIDTH, 1, ROOM_WIDTH, ROOM_HEIGHT }
}

local hallways = {
    up = { (ROOM_WIDTH - PATH_WIDTH) / 2 + 1, 1, (ROOM_WIDTH - PATH_WIDTH) / 2 + PATH_WIDTH, 2 },
    down = { (ROOM_WIDTH - PATH_WIDTH) / 2 + 1, ROOM_HEIGHT - 1, (ROOM_WIDTH - PATH_WIDTH) / 2 + PATH_WIDTH, ROOM_HEIGHT },
    left = { 1, (ROOM_HEIGHT - PATH_WIDTH) / 2 + 1, 2, (ROOM_HEIGHT - PATH_WIDTH) / 2 + PATH_WIDTH },
    right = { ROOM_WIDTH - 1, (ROOM_HEIGHT - PATH_WIDTH) / 2 + 1, ROOM_WIDTH, (ROOM_HEIGHT - PATH_WIDTH) / 2 + PATH_WIDTH }
}

function Room:init(def)
    self.mapX = def.mapX
    self.mapY = def.mapY

    self.adj_rooms = {
        up = false,
        down = false,
        left = false,
        right = false
    }

    -- self.doors = {
    --     up = false,
    --     down = false,
    --     left = false,
    --     right = false
    -- }

    self.traced = false
    self.timesTraced = 0

    self.marker = false
    self.marked = false
    self.collected = false

    self.tiles = nil
    self.solidTiles = nil

    self.decorations = {}
    self.entities = {}
end

function Room:emptyTiles()
    local grid = {}

    for j = 1, ROOM_HEIGHT do
        local row = {}
        for i = 1, ROOM_WIDTH do
            local tile = Tile({ gridX = i, gridY = j })
            table.insert(row, tile)
        end
        table.insert(grid, row)
    end

    return grid
end

function Room:setTile(tile, defId)
    -- takes a defId and converts into a spriteId
    local randomSpriteId = TILE_DEFS[defId].ids[math.random(#TILE_DEFS[defId].ids)]
    tile.defId = defId
    tile.spriteId = randomSpriteId

    -- update the possibile tiles for adjacent tiles
    for dir, validTiles in pairs(TILE_DEFS[defId].valid) do
        local ox, oy = offset[dir][1], offset[dir][2]
        local row = self.tiles[tile.gridY + oy]
        if row then
            local target = row[tile.gridX + ox]
            if target then
                target:updatePossibilities(validTiles)
            end
        end
    end
end

function Room:generateHallways()
    for dir, coords in pairs(hallways) do
        -- if there is an adjacent room, make a hallway
        if self.adj_rooms[dir] then
            local x1, y1, x2, y2 = coords[1], coords[2], coords[3], coords[4]
            -- make edges
            if dir == 'up' or dir == 'down' then
                for j = y1, y2 do
                    local leftEdge = self.tiles[j][x1]
                    local rightEdge = self.tiles[j][x2]
                    self:setTile(leftEdge, 4)
                    self:setTile(rightEdge, 3)
                end
            elseif dir == 'left' or dir == 'right' then
                for i = x1, x2 do
                    local topEdge = self.tiles[y1][i]
                    local bottomEdge = self.tiles[y2][i]
                    self:setTile(topEdge, 2)
                    self:setTile(bottomEdge, 1)
                end
            end
            -- make air space
            for j = y1, y2 do
                for i = x1, x2 do
                    local tile = self.tiles[j][i]
                    if not tile.spriteId then self:setTile(tile, 14) end
                end
            end
        end
    end
end

function Room:generateWalls()
    -- if there are no rooms connected in a particular direction, fill tiles in that direction
    for dir, coords in pairs(walls) do
        local x1, y1, x2, y2 = coords[1], coords[2], coords[3], coords[4]
        for j = y1, y2 do
            for i = x1, x2 do
                local tile = self.tiles[j][i]
                if not tile.spriteId then self:setTile(tile, 13) end
            end
        end
    end
end

function Room:air()
    -- create air spaces to influence room generation
    for i = 1, 60 do
        local randX = math.random(ROOM_WIDTH)
        local randY = math.random(ROOM_HEIGHT)
        local tile = self.tiles[randY][randX]
        if not tile.spriteId and tile.possibleIds[#tile.possibleIds] == 14 then
            self:setTile(tile, 14)
        end
    end
end

function Room:bore(current, endX, endY)
    -- carve path between hallways
    local offset = {
        up = { 0, -1 },
        down = { 0, 1 },
        left = { -1, 0 },
        right = { 1, 0 }
    }

    local validTiles = {}

    -- randomly choose direction to go
    for dir, o in pairs(offset) do
        local ox, oy = o[1], o[2]
        local row = self.tiles[current.gridY + oy]
        if row then 
            local tile = row[current.gridX + ox]
            if tile then
                if (not tile.spriteId and tile.possibleIds[#tile.possibleIds] == 14)
                    or (tile.defId == 14) then
                    table.insert(validTiles, tile)
                end
            end
        end
    end

    if #validTiles == 0 then return false end
    local randomTile = validTiles[math.random(#validTiles)]
    self:setTile(randomTile, 15)
    
    if endX and randomTile.gridX == endX then return true end
    if endY and randomTile.gridY == endY then return true end

    if self:bore(randomTile, endX, endY) then
        return true
    else
        return self:bore(current, endX, endY)
    end
end

function Room:tunnel()    
    local startTiles = {
        up = { ROOM_WIDTH / 2, 2 },
        down = { ROOM_WIDTH / 2, ROOM_HEIGHT - 1 },
        left = { 2, ROOM_HEIGHT / 2 },
        right = { ROOM_WIDTH - 1, ROOM_HEIGHT / 2 }
    }

    local endTiles = {
        up = { false, 2 },
        down = { false, ROOM_HEIGHT - 1 },
        left = { 2, false },
        right = { ROOM_WIDTH - 1, false }
    }

    -- ensure there is a path between each hallway
    local hallwayDirs = {}

    for dir, adj_room in pairs(self.adj_rooms) do
        if adj_room then 
            table.insert(hallwayDirs, dir)
        end
    end

    if #hallwayDirs == 0 then return end
    -- create air spaces in the room to give more space to the room
    if #hallwayDirs == 1 then return self:air() end

    local startDir = hallwayDirs[math.random(#hallwayDirs)]
    local startX, startY = startTiles[startDir][1], startTiles[startDir][2]
    local startTile = self.tiles[startY][startX]

    local previousTiles = self.tiles

    for i, dir in ipairs(hallwayDirs) do
        local endX, endY = endTiles[dir][1], endTiles[dir][2]

        local connected = false
        while not connected do
            -- reset pathing tiles
            for j = 1, ROOM_HEIGHT do
                for i = 1, ROOM_WIDTH do
                    local tile = self.tiles[j][i]
                    if tile.defId == 15 then
                        self:setTile(tile, 14)
                    end
                end
            end

            connected = self:bore(startTile, endX, endY)
        end
    end
    -- convert pathing tiles to air tiles
    for j = 1, ROOM_HEIGHT do
        for i = 1, ROOM_WIDTH do
            local tile = self.tiles[j][i]
            if tile.defId == 15 then
                self:setTile(tile, 14)
            end
        end
    end
end

function Room:clean()
    -- adjust the room generation
    for j = 1, ROOM_HEIGHT do
        for i = 1, ROOM_WIDTH do
            local tile = self.tiles[j][i]

            -- if air block, check if it is completely surrounded
            if tile.defId == 14 then
                local function fillNeighbours(target)
                    -- fill 3 x 3 area around the tile
                    self:setTile(target, 13)
                    for dir, o in pairs(offset) do
                        if dir ~= 'NN' and dir ~= 'SS' and dir ~= 'EE' and dir ~= 'WW' then
                            local ox, oy = o[1], o[2]
                            local row = self.tiles[target.gridY + oy]
                            if row then
                                local neighbour = row[target.gridX + ox]
                                if neighbour then self:setTile(neighbour, 13) end
                            end
                        end
                    end
                end

                local function checkNeighbours(target)
                    local offset = {
                        up = { 0, -1 },
                        down = { 0, 1 },
                        left = { -1, 0 },
                        right = { 1, 0 }
                    }

                    -- check air blocks adjacent to the current tile
                    local neighbours = {}

                    for dir, o in pairs(offset) do
                        local ox, oy = o[1], o[2]
                        local row = self.tiles[target.gridY + oy]
                        if row then
                            local neighbour = row[target.gridX + ox]
                            if neighbour and neighbour.defId == 14 then table.insert(neighbours, neighbour) end
                        end
                    end

                    return neighbours
                end

                local airNeighbours = checkNeighbours(tile)

                -- fill enclosed 1 wide corridors
                if #airNeighbours == 1 then
                    local neighboursOfNeighbour = checkNeighbours(airNeighbours[1])
                    
                    if #neighboursOfNeighbour == 2 then
                        -- store tiles that are in a row
                        local corridor = { tile, airNeighbours[1] }
                        local current = nil
                        
                        repeat
                            for i, neighbour in pairs(neighboursOfNeighbour) do
                                for j, corridorTile in pairs(corridor) do
                                    if neighbour.gridX == corridorTile.gridX and neighbour.gridY == corridorTile.gridY then
                                        goto continue
                                    end
                                end

                                current = neighbour
                                table.insert(corridor, current)

                                ::continue::
                            end

                            neighboursOfNeighbour = checkNeighbours(current)
                        until #neighboursOfNeighbour ~= 2

                        if #neighboursOfNeighbour == 1 then
                            for i, corridorTile in pairs(corridor) do
                                fillNeighbours(corridorTile)
                            end
                        end
                    end
                end

                -- fill 1 x 1 holes
                if #airNeighbours == 0 then
                    fillNeighbours(tile)

                -- fill tile if its neighbours only has 1 neighbour
                else
                    -- track number of neighbouring tiles with only 1 air tile neighbour
                    local singleNeighbour = 0
                    for i, neighbour in pairs(airNeighbours) do
                        local neighboursOfNeighbour = checkNeighbours(airNeighbours[i])
                        if #neighboursOfNeighbour == 1 then singleNeighbour = singleNeighbour + 1 end
                    end

                    if singleNeighbour == #airNeighbours then
                        fillNeighbours(tile)
                        for i, neighbour in pairs(airNeighbours) do
                            fillNeighbours(neighbour)
                        end
                    end
                end

            -- carve paths between thin walls to reduce the number of inaccessible areas
            elseif tile.defId == 1 then
                if self.tiles[tile.gridY + 1][tile.gridX].defId == 2 
                    and self.tiles[tile.gridY][tile.gridX - 1].defId ~= 5
                    and self.tiles[tile.gridY][tile.gridX + 1].defId ~= 6
                    and self.tiles[tile.gridY + 1][tile.gridX - 1].defId ~= 7
                    and self.tiles[tile.gridY + 1][tile.gridX + 1].defId ~= 8
                    and math.random() > 0.5 then
                    
                    self:setTile(tile, 14)
                    self:setTile(self.tiles[tile.gridY + 1][tile.gridX], 14)
                    
                    -- check left
                    if self.tiles[tile.gridY][tile.gridX - 1].defId == 1 then
                        self:setTile(self.tiles[tile.gridY][tile.gridX - 1], 6)
                    else
                        self:setTile(self.tiles[tile.gridY][tile.gridX - 1], 4)
                    end

                    if self.tiles[tile.gridY + 1][tile.gridX - 1].defId == 2 then
                        self:setTile(self.tiles[tile.gridY + 1][tile.gridX - 1], 8)
                    else
                        self:setTile(self.tiles[tile.gridY + 1][tile.gridX - 1], 4)
                    end

                    -- check right
                    if self.tiles[tile.gridY][tile.gridX + 1].defId == 1 then
                        self:setTile(self.tiles[tile.gridY][tile.gridX + 1], 5)
                    else
                        self:setTile(self.tiles[tile.gridY][tile.gridX + 1], 3)
                    end

                    if self.tiles[tile.gridY + 1][tile.gridX + 1].defId == 2 then
                        self:setTile(self.tiles[tile.gridY + 1][tile.gridX + 1], 7)
                    else
                        self:setTile(self.tiles[tile.gridY + 1][tile.gridX + 1], 3)
                    end
                end

            elseif tile.defId == 3 then 
                if self.tiles[tile.gridY][tile.gridX + 1].defId == 4
                    and self.tiles[tile.gridY - 1][tile.gridX].defId ~= 5
                    and self.tiles[tile.gridY + 1][tile.gridX].defId ~= 7
                    and self.tiles[tile.gridY - 1][tile.gridX + 1].defId ~= 6
                    and self.tiles[tile.gridY + 1][tile.gridX + 1].defId ~= 8 then

                    self:setTile(tile, 14)
                    self:setTile(self.tiles[tile.gridY][tile.gridX + 1], 14)

                    -- check up
                    if self.tiles[tile.gridY - 1][tile.gridX].defId == 3 then
                        self:setTile(self.tiles[tile.gridY - 1][tile.gridX], 7)
                    else
                        self:setTile(self.tiles[tile.gridY - 1][tile.gridX], 2)
                    end

                    if self.tiles[tile.gridY - 1][tile.gridX + 1].defId == 4 then
                        self:setTile(self.tiles[tile.gridY - 1][tile.gridX + 1], 8)
                    else
                        self:setTile(self.tiles[tile.gridY - 1][tile.gridX + 1], 2)
                    end

                    -- check down
                    if self.tiles[tile.gridY + 1][tile.gridX].defId == 3 then
                        self:setTile(self.tiles[tile.gridY + 1][tile.gridX], 5)
                    else
                        self:setTile(self.tiles[tile.gridY + 1][tile.gridX], 1)
                    end

                    if self.tiles[tile.gridY + 1][tile.gridX + 1].defId == 4 then
                        self:setTile(self.tiles[tile.gridY + 1][tile.gridX + 1], 6)
                    else
                        self:setTile(self.tiles[tile.gridY + 1][tile.gridX + 1], 1)
                    end
                
                elseif self.tiles[tile.gridY][tile.gridX + 2]
                    and self.tiles[tile.gridY][tile.gridX + 2].defId == 4
                    and self.tiles[tile.gridY - 1][tile.gridX].defId ~= 5
                    and self.tiles[tile.gridY + 1][tile.gridX].defId ~= 7
                    and self.tiles[tile.gridY - 1][tile.gridX + 2].defId ~= 6
                    and self.tiles[tile.gridY + 1][tile.gridX + 2].defId ~= 8 then

                    self:setTile(tile, 14)
                    self:setTile(self.tiles[tile.gridY][tile.gridX + 2], 14)
                    self:setTile(self.tiles[tile.gridY - 1][tile.gridX + 1], 2)
                    self:setTile(self.tiles[tile.gridY][tile.gridX + 1], 14)
                    self:setTile(self.tiles[tile.gridY + 1][tile.gridX + 1], 1)

                    -- check up
                    if self.tiles[tile.gridY - 1][tile.gridX].defId == 3 then
                        self:setTile(self.tiles[tile.gridY - 1][tile.gridX], 7)
                    else
                        self:setTile(self.tiles[tile.gridY - 1][tile.gridX], 2)
                    end

                    if self.tiles[tile.gridY - 1][tile.gridX + 2].defId == 4 then
                        self:setTile(self.tiles[tile.gridY - 1][tile.gridX + 2], 8)
                    else
                        self:setTile(self.tiles[tile.gridY - 1][tile.gridX + 2], 2)
                    end

                    -- check down
                    if self.tiles[tile.gridY + 1][tile.gridX].defId == 3 then
                        self:setTile(self.tiles[tile.gridY + 1][tile.gridX], 5)
                    else
                        self:setTile(self.tiles[tile.gridY + 1][tile.gridX], 1)
                    end

                    if self.tiles[tile.gridY + 1][tile.gridX + 2].defId == 4 then
                        self:setTile(self.tiles[tile.gridY + 1][tile.gridX + 2], 6)
                    else
                        self:setTile(self.tiles[tile.gridY + 1][tile.gridX + 2], 1)
                    end
                end
            end
        end
    end
end

function Room:lowestEntropy()
    local tiles = {}
    local smallest = 20

    -- look for uncollapsed tiles with the least possible number of valid tile states
    for j = 1, ROOM_HEIGHT do
        for i = 1, ROOM_WIDTH do
            local tile = self.tiles[j][i]
            if not tile.spriteId then
                if #tile.possibleIds ~= 0 and #tile.possibleIds < smallest then
                    tiles = { tile }
                    smallest = #tile.possibleIds
                elseif #tile.possibleIds == smallest then
                    table.insert(tiles, tile)
                end
            end
        end
    end

    return tiles
end

function Room:fullyTiled()
    -- check if all tiles have been collapsed
    for j = 1, ROOM_HEIGHT do
        for i = 1, ROOM_WIDTH do
            local tile = self.tiles[j][i]
            if not tile.spriteId then return false end
        end
    end

    return true
end

function Room:collapse()
    -- wave collapse function algorithm to procedurally generate rooms
    -- keep collapsing tiles until all tiles are set
    while not self:fullyTiled() do
        local validTiles = self:lowestEntropy()
        local tile = validTiles[math.random(#validTiles)]

        -- if there are no valid tiles, then restart
        if not tile then 
            self:renovate()
        else
            -- collapse tile and choose a random state for the tile
            local randomTileId = tile.possibleIds[math.random(#tile.possibleIds)]
            self:setTile(tile, randomTileId)
        end 
    end
end

function Room:flood(current)
    local offset = {
        up = { 0, -1 },
        down = { 0, 1 },
        left = { -1, 0 },
        right = { 1, 0 }
    }

    current.flooded = true
    
    -- floor in 4 cardinal directions
    for dir, o in pairs(offset) do
        local ox, oy = o[1], o[2]
        local row = self.tiles[current.gridY + oy]
        if row then 
            local tile = row[current.gridX + ox]
            if tile and tile.defId == 14 and not tile.flooded then
                self:flood(tile)
            end
        end
    end
end

function Room:flooded()
    for j = 1, ROOM_HEIGHT do
        for i = 1, ROOM_WIDTH do
            local tile = self.tiles[j][i]
            if tile.defId == 14 then
                self:flood(tile)
                goto check
            end
        end
    end

    :: check ::
    -- check if all air tiles have been flooded
    for j = 1, ROOM_HEIGHT do
        for i = 1, ROOM_WIDTH do
            local tile = self.tiles[j][i]
            if tile.defId == 14 and not tile.flooded then
                return false 
            end
        end
    end

    return true
end

function Room:solidifiedTiles()
    -- returns the solid tiles that need collision checking
    local tiles = {}

    for j = 1, ROOM_HEIGHT do
        for i = 1, ROOM_WIDTH do
            local tile = self.tiles[j][i]
            -- don't need to check collision for fill, air or inner corner tiles
            if tile.defId ~= 9 and tile.defId ~= 10 and
                tile.defId ~= 11 and tile.defId ~= 12 and
                tile.defId ~= 13 and tile.defId ~= 14 then 
            
                table.insert(tiles, tile) 
            end
        end
    end

    return tiles
end

function Room:decorate()
    -- add in boxes and other decorative entities
    local decorations = {}

    local function placeDestructible(tile, decoType, ox, oy)
        local destructible = Entity{
            x = tile.x + ox,
            y = tile.y + oy,
            width = ENTITY_DEFS[decoType].width,
            height = ENTITY_DEFS[decoType].height,
            ox = ENTITY_DEFS[decoType].ox,
            oy = ENTITY_DEFS[decoType].oy,

            animations = ENTITY_DEFS[decoType].animations
        }
        destructible.stateMachine = StateMachine {
            ['idle'] = function() return EntityIdleState(destructible) end,
            ['death'] = function() return EntityDeathState(destructible) end
        }
        destructible:changeState('idle')

        destructible.oxOnDeath = (DEATH_SMALL_SIZE - destructible.width) / 2 + destructible.ox
        destructible.oyOnDeath = (DEATH_SMALL_SIZE - destructible.height) / 2 + destructible.oy

        destructible.onDeath = function()
            gSounds['box-break']:play()

            if math.random() < 0.2 then
                local goldType = 'gold-' .. math.random(4)

                local gold = Entity{
                    x = destructible.x + 2,
                    y = destructible.y + 2,
                    width = ENTITY_DEFS[goldType].width,
                    height = ENTITY_DEFS[goldType].height,
                    ox = ENTITY_DEFS[goldType].ox,
                    oy = ENTITY_DEFS[goldType].oy,
        
                    animations = ENTITY_DEFS[goldType].animations
                }

                gold.destructible = false

                gold.stateMachine = StateMachine {
                    ['idle'] = function() return EntityIdleState(gold) end,
                    ['death'] = function() return EntityDeathState(gold) end
                }
                gold:changeState('idle')

                gold.timeValue = 2
                gold.oxOnDeath = (COIN_DEATH_SIZE - ENTITY_DEFS[goldType].width) / 2
                gold.oyOnDeath = (COIN_DEATH_SIZE - ENTITY_DEFS[goldType].height) / 2
        
                gold.onCollide = function()
                    gold.dying = true

                    gSounds['gold']:play()
                    gold:changeState('death')
                end

                table.insert(self.entities, gold)
            elseif math.random() < 0.2 then
                local heart = Entity{
                    x = destructible.x + 2,
                    y = destructible.y + 2,
                    width = ENTITY_DEFS['heart'].width,
                    height = ENTITY_DEFS['heart'].height,
                    ox = ENTITY_DEFS['heart'].ox,
                    oy = ENTITY_DEFS['heart'].oy,
        
                    animations = ENTITY_DEFS['heart'].animations
                }
                
                heart.destructible = false

                heart.stateMachine = StateMachine {
                    ['idle'] = function() return EntityIdleState(heart) end,
                    ['death'] = function() return EntityDeathState(heart) end
                }
                heart:changeState('idle')
        
                heart.onCollide = function()
                    self.player.health = math.min(self.player.health + 1, self.player.maxHealth)
                    heart.dying = true

                    gSounds['heart']:play()
                    heart:changeState('death')
                end

                table.insert(self.entities, heart)
            end
        end

        local collided = false
        for i, deco in pairs(decorations) do
            if deco:collides(destructible) or destructible:collides(deco) then 
                collided = true 
                break
            end
        end

        if not collided then table.insert(decorations, destructible) end
    end

    -- recursively place a cluster of boxes
    local function placeBox(previous, count)
        local offset = {
            up = { 0, -1 },
            down = { 0, 1 },
            left = { -1, 0 },
            right = { 1, 0 }
        }

        local validDirs = { 'up', 'down', 'left', 'right' }
        local nextDir = validDirs[math.random(#validDirs)]
        
        local ox, oy = offset[nextDir][1], offset[nextDir][2]
        local box = Entity{
            x = previous.x + ox * ENTITY_DEFS['box-single'].width,
            y = previous.y + oy * ENTITY_DEFS['box-single'].width,
            width = ENTITY_DEFS['box-single'].width,
            height = ENTITY_DEFS['box-single'].height,
            ox = ENTITY_DEFS['box-single'].ox,
            oy = ENTITY_DEFS['box-single'].oy,

            animations = ENTITY_DEFS['box-single'].animations
        }

        if box.x < TILE_SIZE * 2 or box.x > WINDOW_WIDTH - TILE_SIZE * 2
            or box.y < TILE_SIZE * 2 or box.y > WINDOW_HEIGHT - TILE_SIZE * 2 then return end

        box.stateMachine = StateMachine {
            ['idle'] = function() return EntityIdleState(box) end,
            ['death'] = function() return EntityDeathState(box) end
        }
        box:changeState('idle')

        box.oxOnDeath = (DEATH_SMALL_SIZE - box.width) / 2 + box.ox
        box.oyOnDeath = (DEATH_SMALL_SIZE - box.height) / 2 + box.oy

        box.onDeath = function()
            gSounds['box-break']:play()

            if math.random() < 0.2 then
                local goldType = 'gold-' .. math.random(4)

                local gold = Entity{
                    x = box.x + 2,
                    y = box.y + 2,
                    width = ENTITY_DEFS[goldType].width,
                    height = ENTITY_DEFS[goldType].height,
                    ox = ENTITY_DEFS[goldType].ox,
                    oy = ENTITY_DEFS[goldType].oy,
        
                    animations = ENTITY_DEFS[goldType].animations
                }

                gold.destructible = false

                gold.stateMachine = StateMachine {
                    ['idle'] = function() return EntityIdleState(gold) end,
                    ['death'] = function() return EntityDeathState(gold) end
                }
                gold:changeState('idle')

                gold.timeValue = 2
                gold.oxOnDeath = (COIN_DEATH_SIZE - ENTITY_DEFS[goldType].width) / 2
                gold.oyOnDeath = (COIN_DEATH_SIZE - ENTITY_DEFS[goldType].height) / 2
        
                gold.onCollide = function()
                    gold.dying = true

                    gSounds['gold']:play()
                    gold:changeState('death')
                end

                table.insert(self.entities, gold)
            elseif math.random() < 0.1 then
                local heart = Entity{
                    x = box.x + 2,
                    y = box.y + 2,
                    width = ENTITY_DEFS['heart'].width,
                    height = ENTITY_DEFS['heart'].height,
                    ox = ENTITY_DEFS['heart'].ox,
                    oy = ENTITY_DEFS['heart'].oy,
        
                    animations = ENTITY_DEFS['heart'].animations
                }
                
                heart.destructible = false

                heart.stateMachine = StateMachine {
                    ['idle'] = function() return EntityIdleState(heart) end,
                    ['death'] = function() return EntityDeathState(heart) end
                }
                heart:changeState('idle')
        
                heart.onCollide = function()
                    self.player.health = math.min(self.player.health + 1, self.player.maxHealth)
                    heart.dying = true

                    gSounds['heart']:play()
                    heart:changeState('death')
                end

                table.insert(self.entities, heart)
            end
        end

        -- check if the box can be placed without collision
        local collided = false
        for i, solidTile in pairs(self.solidTiles) do
            if box:collides(solidTile) then 
                collided = true 
                break
            end
        end
        if collided then return end

        for i, deco in pairs(decorations) do
            if not (box.x + box.ox + box.width <= deco.x
                or box.x + box.ox >= deco.x + deco.width
                or box.y + box.oy + box.width <= deco.y 
                or box.y + box.oy >= deco.y + deco.width) then 
                    
                collided = true
                break
            end
        end
        if collided then return end

        table.insert(decorations, box)

        count = count - 1
        if count == 0 then return end

        return placeBox(box, count)
    end

    -- place chests
    local function placeChest(tile, chestType, collectibleId, timeValue)
        local chest = Entity{
            x = tile.x,
            y = tile.y,
            width = ENTITY_DEFS[chestType].width,
            height = ENTITY_DEFS[chestType].height,
            ox = ENTITY_DEFS[chestType].ox,
            oy = ENTITY_DEFS[chestType].oy,

            animations = ENTITY_DEFS[chestType].animations
        }

        chest.destructible = false

        chest.onHit = function()
            if not chest.open then
                gSounds['chest']:play()

                if chestType == 'gold-chest' then
                    gSounds['gold-chest']:play()
                end

                chest:changeAnimation('open')
                chest.open = true

                local collectible = Entity{
                    x = chest.x + 8,
                    y = chest.y - 8,
                    width = 0,
                    height = 0,
                    ox = 0,
                    oy = 0,
                    animations = {
                        ['death'] = {
                            frames = { collectibleId, collectibleId },
                            interval = 0.6,
                            looping = false,
                            texture = 'objects'
                        }
                    }
                }

                collectible.chestCollectible = true

                collectible.stateMachine = StateMachine {
                    ['death'] = function() return EntityDeathState(collectible) end
                }
                collectible:changeState('death')

                if timeValue then collectible.timeValue = timeValue end

                Timer.tween(0.1, {[collectible] = { y = chest.y - 16 }  })

                table.insert(self.entities, collectible)

                Timer.after(0.5, function()
                    self.collected = true
                end)
            end
        end

        chest.stateMachine = StateMachine {
            ['idle'] = function() return EntityIdleState(chest) end
        }
        chest:changeState('idle')

        table.insert(decorations, chest)

        self.marked = true
    end

    -- generate crystals and powerups if room is marked
    if self.marker and type(self.marker) == 'number' and self.marker < 45 then
       self.marked = false
        while not self.marked do
            local randX = math.random(3, ROOM_WIDTH - 2)
            local randY = math.random(3, ROOM_HEIGHT - 2)
            local tile = self.tiles[randY][randX]

            local chestType = 'chest'
            if self.marker < 41 then chestType = 'gold-chest' end

            if tile.defId == 14 then placeChest(tile, chestType, self.marker) end
        end
    end

    -- add decorations
    for j = 3, ROOM_HEIGHT - 2 do
        for i = 3, ROOM_WIDTH - 2 do
            local tile = self.tiles[j][i]
            if tile.defId == 14 then
                -- place box / box cluster
                if math.random() < 0.05 then
                    placeBox(tile, math.random(3, 8))

                -- place box variants
                elseif math.random() < 0.03 then 
                    local boxTypes = { 'box-with-shovel', 'box-stack' }
                    local boxType = boxTypes[math.random(#boxTypes)]
                    placeDestructible(tile, boxType, 0, 0)
                
                -- place other decorations
                elseif math.random() < 0.05 then
                    local decoTypes = { 'pot-1', 'pot-2', 'pot-3', 'dead-bush', 'dead-tree', 'cactus-1', 'cactus-2' }
                    local decoOffset = { { 0, 0 }, { 0, 4 }, { 4, 0 }, { 0, 8 }, { 8, 0 } }
                    local decoType = decoTypes[math.random(#decoTypes)]
                    placeDestructible(tile, decoType, decoOffset[math.random(#decoOffset)][1], decoOffset[math.random(#decoOffset)][2])
                
                -- place chests that add to the timer
                elseif not self.marker then
                    local numAdjRooms = 0
                    for i, adj_room in pairs(self.adj_rooms) do
                        if adj_room then numAdjRooms = numAdjRooms + 1 end
                    end

                    if math.random() * numAdjRooms < 0.006 then placeChest(tile, 'chest', 45, 10) end
                end
            end
        end
    end

    local sortedDecorations = {}
    for i, deco in ipairs(decorations) do
        for j, current in ipairs(sortedDecorations) do
            if deco.y <= current.y then
                table.insert(sortedDecorations, j, deco)
                goto continue
            end
        end
        table.insert(sortedDecorations, deco) 
        :: continue ::
    end
    self.decorations = sortedDecorations
end

function Room:invest()
    -- place gold
    for j = 3, ROOM_HEIGHT - 2 do
        for i = 3, ROOM_WIDTH - 2 do
            local tile = self.tiles[j][i]
            if tile.defId == 14 then
                if math.random() < 0.025 then
                    local goldOffset = { { 0, 0 }, { 0, 4 }, { 4, 0 }, { 0, 8 }, { 8, 0 } }
                    local goldType = 'gold-' .. math.random(4)

                    local gold = Entity{
                        x = tile.x + goldOffset[math.random(#goldOffset)][1],
                        y = tile.y + goldOffset[math.random(#goldOffset)][2],
                        width = ENTITY_DEFS[goldType].width,
                        height = ENTITY_DEFS[goldType].height,
                        ox = ENTITY_DEFS[goldType].ox,
                        oy = ENTITY_DEFS[goldType].oy,
            
                        animations = ENTITY_DEFS[goldType].animations
                    }

                    gold.destructible = false

                    gold.stateMachine = StateMachine {
                        ['idle'] = function() return EntityIdleState(gold) end,
                        ['death'] = function() return EntityDeathState(gold) end
                    }
                    gold:changeState('idle')

                    gold.timeValue = 2
                    gold.oxOnDeath = (COIN_DEATH_SIZE - ENTITY_DEFS[goldType].width) / 2
                    gold.oyOnDeath = (COIN_DEATH_SIZE - ENTITY_DEFS[goldType].height) / 2
            
                    gold.onCollide = function()
                        gold.dying = true

                        gSounds['gold']:play()
                        gold:changeState('death')
                    end

                    local collided = false
                    for i, deco in pairs(self.decorations) do
                        if deco:collides(gold) or gold:collides(deco) then 
                            collided = true 
                            break
                        end
                    end
            
                    if not collided then table.insert(self.entities, gold) end
                end 
            end
        end
    end
end

function Room:populate()
    for j = 3, ROOM_HEIGHT - 2 do
        for i = 3, ROOM_WIDTH - 2 do
            local tile = self.tiles[j][i]
            if tile.defId == 14 and math.random() < 0.01 then
                local snake = Entity{
                    x = tile.x,
                    y = tile.y,
                    width = ENTITY_DEFS['snake'].width,
                    height = ENTITY_DEFS['snake'].height,
                    ox = ENTITY_DEFS['snake'].ox,
                    oy = ENTITY_DEFS['snake'].oy,
                    health = ENTITY_DEFS['snake'].health,
                    speed = ENTITY_DEFS['snake'].speed,
                    attack = ENTITY_DEFS['snake'].attack,
            
                    animations = ENTITY_DEFS['snake'].animations,
            
                    room = self
                }
            
                snake.combatant = true
                snake.canTrack = true
                snake.oxOnDeath = (snake.width - DEATH_SMALL_SIZE) / 2 + snake.ox
                snake.oyOnDeath = (DEATH_SMALL_SIZE - snake.height) / 2 + snake.oy
            
                local idleAi = function(player)
                    -- activate when in range of player
                    if snake.canTrack and player and snake:distanceTo(player) < 128 then
                        snake.direction = (snake.x > player.x) and 'left' or 'right'
                        snake:changeState('walk')
                    end
                end
            
                local walkAi = function(player)
                    if snake.canTrack and player then
                        snake.direction = (snake.x > player.x) and 'left' or 'right'
                        snake:changeAnimation('walk-' .. snake.direction)
                        local a = snake:angleTo(player)
                        snake.dx = snake.dx + snake.speed * math.cos(a)
                        snake.dy = snake.dy + snake.speed * math.sin(a)
                    end
                end
            
                snake.stateMachine = StateMachine {
                    ['idle'] = function() return EntityIdleState(snake, idleAi) end,
                    ['walk'] = function() return EntityWalkState(snake, walkAi) end,
                    ['death'] = function() return EntityDeathState(snake) end
                }
                snake:changeState('idle')
            
                snake.onHit = function()
                    gSounds['snake-hurt']:play()
                    snake.health = snake.health - self.player.attack
                    snake:goInvulnerable(1.2)
            
                    snake.canTrack = false
                    Timer.after(1.2, function()
                        snake.canTrack = true
                    end)
            
                    snake:changeState('idle')
                end
            
                snake.onDeath = function()
                    gSounds['snake-death']:play()

                    if math.random() < 0.5 then
                        local goldType = 'gold-' .. math.random(4)

                        local gold = Entity{
                            x = snake.x + 2,
                            y = snake.y + 2,
                            width = ENTITY_DEFS[goldType].width,
                            height = ENTITY_DEFS[goldType].height,
                            ox = ENTITY_DEFS[goldType].ox,
                            oy = ENTITY_DEFS[goldType].oy,
                
                            animations = ENTITY_DEFS[goldType].animations
                        }

                        gold.destructible = false

                        gold.stateMachine = StateMachine {
                            ['idle'] = function() return EntityIdleState(gold) end,
                            ['death'] = function() return EntityDeathState(gold) end
                        }
                        gold:changeState('idle')

                        gold.timeValue = 2
                        gold.oxOnDeath = (COIN_DEATH_SIZE - ENTITY_DEFS[goldType].width) / 2
                        gold.oyOnDeath = (COIN_DEATH_SIZE - ENTITY_DEFS[goldType].height) / 2
                
                        gold.onCollide = function()
                            gold.dying = true

                            gSounds['gold']:play()
                            gold:changeState('death')
                        end

                        table.insert(self.entities, gold)
                    else
                        local heart = Entity{
                            x = snake.x + 2,
                            y = snake.y + 2,
                            width = ENTITY_DEFS['heart'].width,
                            height = ENTITY_DEFS['heart'].height,
                            ox = ENTITY_DEFS['heart'].ox,
                            oy = ENTITY_DEFS['heart'].oy,
                
                            animations = ENTITY_DEFS['heart'].animations
                        }
                        
                        heart.destructible = false

                        heart.stateMachine = StateMachine {
                            ['idle'] = function() return EntityIdleState(heart) end,
                            ['death'] = function() return EntityDeathState(heart) end
                        }
                        heart:changeState('idle')
                
                        heart.onCollide = function()
                            self.player.health = math.min(self.player.health + 1, self.player.maxHealth)
                            heart.dying = true

                            gSounds['heart']:play()
                            heart:changeState('death')
                        end

                        table.insert(self.entities, heart)
                    end
                end

                table.insert(self.entities, snake)
            end
        end
    end
end

function Room:renovate()
    repeat
        self.tiles = self:emptyTiles()

        self:generateHallways()
        self:generateWalls()
        self:tunnel()
        self:collapse()
        self:clean()
    until self:flooded()
    
    self.solidTiles = self:solidifiedTiles()
    
    self:decorate()
    self:invest()
    self:populate()
end

-- for starter room
function Room:emptyRoom()
    self.tiles = self:emptyTiles()

    for dir, coords in pairs(hallways) do
        -- if there is an adjacent room, make a hallway
        if self.adj_rooms[dir] then
            local x1, y1, x2, y2 = coords[1], coords[2], coords[3], coords[4]
            -- make edges and corners
            if dir == 'up' then
                local leftEdge = self.tiles[y1][x1]
                local rightEdge = self.tiles[y1][x2]
                local leftCorner = self.tiles[y2][x1]
                local rightCorner = self.tiles[y2][x2]

                self:setTile(leftEdge, 4)
                self:setTile(rightEdge, 3)
                self:setTile(leftCorner, 8)
                self:setTile(rightCorner, 7)
            elseif dir == 'down' then
                local leftEdge = self.tiles[y2][x1]
                local rightEdge = self.tiles[y2][x2]
                local leftCorner = self.tiles[y1][x1]
                local rightCorner = self.tiles[y1][x2]

                self:setTile(leftEdge, 4)
                self:setTile(rightEdge, 3)
                self:setTile(leftCorner, 6)
                self:setTile(rightCorner, 5)
            elseif dir == 'left' then
                local topEdge = self.tiles[y1][x1]
                local bottomEdge = self.tiles[y2][x1]
                local topCorner = self.tiles[y1][x2]
                local bottomCorner = self.tiles[y2][x2]

                self:setTile(topEdge, 2)
                self:setTile(bottomEdge, 1)
                self:setTile(topCorner, 8)
                self:setTile(bottomCorner, 6)
            elseif dir == 'right' then
                local topEdge = self.tiles[y1][x2]
                local bottomEdge = self.tiles[y2][x2]
                local topCorner = self.tiles[y1][x1]
                local bottomCorner = self.tiles[y2][x1]

                self:setTile(topEdge, 2)
                self:setTile(bottomEdge, 1)
                self:setTile(topCorner, 7)
                self:setTile(bottomCorner, 5)
            end
            -- make air space
            for j = y1, y2 do
                for i = x1, x2 do
                    local tile = self.tiles[j][i]
                    if not tile.spriteId then self:setTile(tile, 14) end
                end
            end
        end
    end

    self:generateWalls()

    -- fill air space in middle
    for j = 3, ROOM_HEIGHT - 2 do
        for i = 3, ROOM_WIDTH - 2 do
            local tile = self.tiles[j][i]
            self:setTile(tile, 14)
        end
    end

    -- collapse the rest of the room
    self:collapse()

    self.solidTiles = self:solidifiedTiles()
end

function Room:render()
    if self.tiles then
        for j = 1, ROOM_HEIGHT do
            if self.tiles[j] then
                for i = 1, ROOM_WIDTH do
                    local tile = self.tiles[j][i]
                    if tile then tile:render() end
                end    
            end
        end 
    end
end