EntityWalkState = Class{__includes = BaseState}

function EntityWalkState:init(entity, ai)
    self.entity = entity

    self.ai = ai
end

function EntityWalkState:enter(params)
    self.entity:changeAnimation('walk-' .. self.entity.direction)
end

function EntityWalkState:update(dt, player)    
    if self.ai then self.ai(player) end

    self.entity.x = self.entity.x + self.entity.dx * dt
    self.entity.y = self.entity.y + self.entity.dy * dt

    local function resetUp(target) self.entity.y = target.y - self.entity.height end
    local function resetDown(target) self.entity.y = target.y + target.height end
    local function resetLeft(target) self.entity.x = target.x - self.entity.width end
    local function resetRight(target) self.entity.x = target.x + target.width end

    -- check all collidable tiles
    for i, tile in pairs(self.entity.room.solidTiles) do
        if self.entity:collides(tile) then
            -- handle tile collisions based on the type of tile
            if tile.defId == 1 then resetUp(tile) end
            if tile.defId == 2 then resetDown(tile) end
            if tile.defId == 3 then resetLeft(tile) end
            if tile.defId == 4 then resetRight(tile) end

            -- direction of entity relative to tile
            local up = self.entity.y - self.entity.dy * dt < tile.y
            local down = self.entity.y + self.entity.height - self.entity.dy * dt > tile.y + tile.height
            local left = self.entity.x - self.entity.dx * dt < tile.x
            local right = self.entity.x + self.entity.width - self.entity.dx * dt > tile.x + tile.width

            if tile.defId == 5 then
                if up and not left then
                    resetUp(tile)
                elseif left and not up then
                    resetLeft(tile)
                elseif self.entity.x + self.entity.width - self.entity.dx * dt > tile.x then
                    resetUp(tile)
                else
                    resetLeft(tile)
                end
            end
            if tile.defId == 6 then
                if up and not right then
                    resetUp(tile)
                elseif right and not up then
                    resetRight(tile)
                elseif self.entity.x - self.entity.dx * dt < tile.x + tile.width then
                    resetUp(tile)
                else
                    resetRight(tile)
                end
            end
            if tile.defId == 7 then
                if down and not left then
                    resetDown(tile)
                elseif left and not down then
                    resetLeft(tile)
                elseif self.entity.x + self.entity.width - self.entity.dx * dt > tile.x then
                    resetDown(tile)
                else
                    resetLeft(tile)
                end
            end
            if tile.defId == 8 then
                if down and not right then
                    resetDown(tile)
                elseif right and not down then
                    resetRight(tile)
                elseif self.entity.x - self.entity.dx * dt < tile.x + tile.width then
                    resetDown(tile)
                else
                    resetRight(tile)
                end
            end
        end
    end

    -- check collision with decorative entities
    for i, deco in pairs(self.entity.room.decorations) do 
        if not deco.dead and not deco.dying and self.entity:collides(deco) then
            
            local up = self.entity.y - self.entity.dy * dt < deco.y
            local down = self.entity.y + self.entity.height - self.entity.dy * dt > deco.y + deco.height
            local left = self.entity.x - self.entity.dx * dt < deco.x
            local right = self.entity.x + self.entity.width - self.entity.dx * dt > deco.x + deco.width

            if up then
                if left and right then
                    resetUp(deco)
                elseif left then
                    if self.entity.x + self.entity.width - self.entity.dx * dt > deco.x then
                        resetUp(deco)
                    else
                        resetLeft(deco)
                    end
                elseif right then
                    if self.entity.x - self.entity.dx * dt < deco.x + deco.width then
                        resetUp(deco)
                    else
                        resetRight(deco)
                    end
                else
                    resetUp(deco)
                end
            elseif down then 
                if left and right then
                    resetDown(deco)
                elseif left then
                    if self.entity.x + self.entity.width - self.entity.dx * dt > deco.x then
                        resetDown(deco)
                    else
                        resetLeft(deco)
                    end
                elseif right then
                    if self.entity.x - self.entity.dx * dt < deco.x + deco.width then
                        resetDown(deco)
                    else
                        resetRight(deco)
                    end
                else
                    resetDown(deco)
                end
            elseif left then
                resetLeft(deco)
            elseif right then
                resetRight(deco)
            end
        end
    end

    self.entity.dx = self.entity.dx * FRICTION
    self.entity.dy = self.entity.dy * FRICTION
end

function EntityWalkState:render()
    local animation = self.entity.currentAnimation
    love.graphics.draw(gTextures[animation.texture], gFrames[animation.texture][animation:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.ox), math.floor(self.entity.y - self.entity.oy))
end