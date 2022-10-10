EntityIdleState = Class{__includes = BaseState}

function EntityIdleState:init(entity, ai)
    self.entity = entity
    self.entity:changeAnimation('idle-' .. self.entity.direction)

    self.ai = ai
end

function EntityIdleState:enter(params)
    self.entity:changeAnimation('idle-' .. self.entity.direction)
end

function EntityIdleState:update(dt, player)
    if self.ai then self.ai(player) end
end

function EntityIdleState:render()
    local animation = self.entity.currentAnimation
    love.graphics.draw(gTextures[animation.texture], gFrames[animation.texture][animation:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.ox), math.floor(self.entity.y - self.entity.oy))
end