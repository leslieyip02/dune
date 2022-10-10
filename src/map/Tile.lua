Tile = Class{}

function Tile:init(def)
    self.gridX = def.gridX
    self.gridY = def.gridY

    self.x = (self.gridX - 1) * TILE_SIZE 
    self.y = (self.gridY - 1) * TILE_SIZE
    self.width = TILE_SIZE
    self.height = TILE_SIZE
    
    -- weighted tile id possibilities 
    self.possibleIds = {
        1, 1, 1, 1, 1, 1, 1, 1, 
        2, 2, 2, 2, 2, 2, 2, 2,
        3, 3, 3, 3, 3, 3, 
        4, 4, 4, 4, 4, 4, 
        5, 5,
        6, 6,
        7, 7,
        8, 8,  
        9, 9, 9,
        10, 10, 10,
        11, 11, 11,
        12, 12, 12,
        13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
        14, 14, 14, 14, 14, 14, 14, 14, 14, 14
    }

    self.defId = nil
    self.spriteId = nil

    self.flooded = false
end

function Tile:updatePossibilities(ids)
    -- only keep possibiliites that are valid
    local newPossibilities = {}
    for i = #self.possibleIds, 1, -1 do
        for j = 1, #ids do
            if self.possibleIds[i] == ids[j] then
                table.insert(newPossibilities, ids[j])
            end 
        end
    end
    self.possibleIds = newPossibilities
end

function Tile:render()
    love.graphics.draw(gTextures['tiles'], gFrames['tiles'][self.spriteId], self.x, self.y)
end