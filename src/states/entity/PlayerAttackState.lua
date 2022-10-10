PlayerAttackState = Class{__includes = EntityAttackState}

local animationOffset = {
    up = { 0, 8 },
    down = { 0, 0 },
    left = { 24, 0 },
    right = { 0, 0 }
}

local v = {
    up = { 0, -1 },
    down = { 0, 1 },
    left = { -1, 0 },
    right = { 1, 0 }
}

function PlayerAttackState:init(player)
    self.entity = player
end

function PlayerAttackState:enter(params)
    self.entity:changeAnimation('attack-' .. self.entity.direction)
    
    gSounds['whip']:stop()
    gSounds['whip']:play()

    -- update offset of the sprite if necessary
    self.entity.ox = animationOffset[self.entity.direction][1]
    self.entity.oy = animationOffset[self.entity.direction][2]

    local hitboxDefs = {
        up = {
            x = self.entity.x - 2,
            y = self.entity.y - 16,
            width = 28,
            height = 20
        },
        down = {
            x = self.entity.x - 2,
            y = self.entity.y + self.entity.height - 4,
            width = 28,
            height = 20
        },
        left = {
            x = self.entity.x - 16,
            y = self.entity.y - 2,
            width = 20,
            height = 28
        },
        right = {
            x = self.entity.x + self.entity.width - 4,
            y = self.entity.y - 2,
            width = 20,
            height = 28
        }
    }

    self.hitbox = Hitbox{
        x = hitboxDefs[self.entity.direction].x,
        y = hitboxDefs[self.entity.direction].y,
        width = hitboxDefs[self.entity.direction].width,
        height = hitboxDefs[self.entity.direction].height
    }
end

function PlayerAttackState:update(dt)
    for i, entity in pairs(self.entity.room.entities) do
        if entity.combatant and entity:collides(self.hitbox) then
            -- damage entity
            if not entity.invulnerable then
                entity:onHit()
                entity:knockbacked(self.entity)
                entity:changeState('walk')
                entity:changeAnimation('idle-' .. entity.direction)
            end
        end
    end

    -- destroy decorations (e.g. boxes)
    for i, deco in pairs(self.entity.room.decorations) do
        if deco:collides(self.hitbox) then 
            deco:onHit()
            if deco.destructible then
                deco:changeState('death')
            end
        end
    end

    if self.entity.currentAnimation.timesPlayed > 0 then
        self.entity.currentAnimation.timesPlayed = 0
        
        self.entity.ox = 0
        self.entity.oy = 0
        self.entity:changeState('idle')
    end

    if love.keyboard.wasPressed('space') then
        self.entity:changeState('attack')
    end
end

function PlayerAttackState:render()
    -- love.graphics.setColor(1, 0, 0, 0.8)
    -- love.graphics.rectangle('fill', self.hitbox.x, self.hitbox.y, self.hitbox.width, self.hitbox.height)
    -- love.graphics.setColor(1, 1, 1, 1)

    local animation = self.entity.currentAnimation
    love.graphics.draw(gTextures[animation.texture], gFrames[animation.texture][animation:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.ox), math.floor(self.entity.y - self.entity.oy))
end