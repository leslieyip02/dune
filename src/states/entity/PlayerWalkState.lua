PlayerWalkState = Class{__includes = EntityWalkState}

local wasd = {
    w = 'up',
    a = 'left',
    s = 'down',
    d = 'right'
}

local v = {
    up = { 0, -1 },
    down = { 0, 1 },
    left = { -1, 0 },
    right = { 1, 0 }
}

function PlayerWalkState:init(player)
    self.entity = player
end

function PlayerWalkState:enter(params)
    -- store a table of directions being pressed, and animate the latest one
    self.directions = { self.entity.direction }
end

function PlayerWalkState:update(dt)
    if love.keyboard.wasPressed('r') then
        self.entity:changeState('roll')
    else
        for key, dir in pairs(wasd) do
            local dx, dy = v[dir][1], v[dir][2]
            if love.keyboard.isDown(key) or love.keyboard.isDown(dir) then
                self.entity.dx = self.entity.dx + dx * self.entity.speed
                self.entity.dy = self.entity.dy + dy * self.entity.speed
    
                -- check if player is already going in that direction
                local added = false
                for i = 1, #self.directions do
                    if self.directions[i] == dir then added = true end
                end
                -- update table to include latest direction player is heading in
                if not added then table.insert(self.directions, dir) end
            else
                -- remove direction from table if player not longer heading that way
                for i = #self.directions, 1, -1 do
                    if self.directions[i] == dir then table.remove(self.directions, i) end
                end
            end
        end

        -- exit walk state once no directions left in the table
        if #self.directions == 0 and not self.entity.invulnerable then
            self.entity.dx = 0
            self.entity.dy = 0
            self.entity:changeState('idle')
        else
            -- set direction to the latest direction added to the table
            if #self.directions > 0 then
                self.entity.direction = self.directions[#self.directions]
                self.entity:changeAnimation('walk-' .. self.directions[#self.directions])
            end
        end
    
        if love.keyboard.wasPressed('space') then
            self.entity:changeState('attack')
        end
    
        EntityWalkState.update(self, dt)
    end
end