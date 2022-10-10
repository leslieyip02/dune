PlayerRollState = Class{__includes = EntityWalkState}

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

function PlayerRollState:init(player)
    self.entity = player
end

function PlayerRollState:enter(params)
    self.directions = { self.entity.direction }
    self.entity:goInvulnerable(0.4)

    gSounds['roll']:play()

    self.entity:changeAnimation('roll-' .. self.entity.direction)
    self.entity.currentAnimation:refresh()
end

function PlayerRollState:update(dt)
    if self.entity.currentAnimation.timesPlayed > 0 then                
        self.entity:changeState('idle')
    end

    for key, dir in pairs(wasd) do
        local dx, dy = v[dir][1], v[dir][2]
        if love.keyboard.isDown(key) or love.keyboard.isDown(dir) then
            self.entity.dx = self.entity.dx + dx * (self.entity.speed * 1.8)
            self.entity.dy = self.entity.dy + dy * (self.entity.speed * 1.8)

            local added = false
            for i = 1, #self.directions do
                if self.directions[i] == dir then added = true end
            end
            if not added then table.insert(self.directions, dir) end
        elseif #self.directions ~= 1 then
            for i = #self.directions, 1, -1 do
                if self.directions[i] == dir then table.remove(self.directions, i) end
            end
        end
    end

    self.entity.direction = self.directions[#self.directions]

    EntityWalkState.update(self, dt)
end