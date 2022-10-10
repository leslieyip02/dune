PlayerIdleState = Class{__includes = EntityIdleState}

local wasd = {
    w = 'up',
    a = 'left',
    s = 'down',
    d = 'right'
}

function PlayerIdleState:update(dt)
    for key, dir in pairs(wasd) do
        if love.keyboard.isDown(key) or love.keyboard.isDown(dir) then
            self.entity.direction = dir
            self.entity:changeState('walk')
        end
    end

    if love.keyboard.wasPressed('space') then
        self.entity:changeState('attack')
    end
end