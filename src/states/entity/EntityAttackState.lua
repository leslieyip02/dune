EntityAttackState = Class{__includes = BaseState}

function EntityAttackState:init(entity)
    self.entity = entity
end

function EntityAttackState:enter(params)
    self.entity:changeAnimation('attack-' .. self.entity.direction)

    self.hitbox = params.hitbox
end

function EntityAttackState:update(dt, player)
    -- for i, entity in pairs(self.entity.room.entities) do
    --     if entity:collides(self.hitbox) then
    --         -- do stuff
    --         -- entity.onHit()
    --     end
    -- end

    if self.entity.currentAnimation.timesPlayed > 0 then
        self.entity.currentAnimation.timesPlayed = 0
        
        self.entity.ox = 0
        self.entity.oy = 0
        self.entity:changeState('idle')
    end
end

function EntityAttackState:render()
    local animation = self.entity.currentAnimation
    love.graphics.draw(gTextures[animation.texture], gFrames[animation.texture][animation:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.ox), math.floor(self.entity.y - self.entity.oy))

    -- love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.rectangle('fill', self.hitbox.x, self.hitbox.y, self.hitbox.width, self.hitbox.height)
end