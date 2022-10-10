Entity = Class{}

function Entity:init(def)
    -- positioning
    self.x = def.x
    self.y = def.y
    -- offset for padded sprites
    self.ox = def.ox or 0
    self.oy = def.oy or 0
    
    -- dimensions
    self.width = def.width
    self.height = def.height
    
    -- velocity
    self.dx = 0
    self.dy = 0
    self.direction = def.direction or 'down'

    -- animations
    self.animations = self:createAnimations(def.animations)

    -- iframes
    self.invulnerable = false
    self.iTimer = 0
    self.flashTimer = 0

    -- combat
    self.health = def.health or 1
    self.maxHealth = def.health or 1
    self.combatant = false
    self.destructible = true
    self.dying = false
    self.dead = false

    self.speed = def.speed
    self.attack = def.attack

    self.chestCollectible = false

    -- room and other entities
    self.room = def.room

    self.stateMachine = nil

    self.onCollide = function() end
    self.onHit = function() end
    self.onDeath = function() end
end

function Entity:distanceTo(target)
    return math.sqrt(
        math.pow((self.x + self.width) / 2 - (target.x + target.width) / 2, 2) +
        math.pow((self.y + self.height) / 2 - (target.y + target.height) / 2, 2)
    )
end

function Entity:angleTo(target)
    return math.atan2(
        (target.y + target.height) / 2 - (self.y + self.height) / 2,
        (target.x + target.width) / 2 - (self.x + self.width) / 2
    )
end

function Entity:collides(target)
    return not (self.x + self.width <= target.x or self.x >= target.x + target.width or
                self.y + self.height <= target.y or self.y >= target.y + target.height)
end

function Entity:knockbacked(source, multiplier)
    local a = self:angleTo(source)
    self.dx = -KNOCKBACK * math.cos(a) * (multiplier or 1)
    self.dy = -KNOCKBACK * math.sin(a) * (multiplier or 1)
end

function Entity:changeState(state, params)
    self.stateMachine:change(state, params)
end

function Entity:createAnimations(animations)
    local animationsReturned = {}

    for k, animationDef in pairs(animations) do
        animationsReturned[k] = Animation {
            frames = animationDef.frames,
            interval = animationDef.interval,
            looping = animationDef.looping,
            texture = animationDef.texture or 'entities',
        }
    end

    return animationsReturned
end

function Entity:changeAnimation(name)
    self.currentAnimation = self.animations[name]
end

function Entity:goInvulnerable(duration)
    self.invulnerable = true
    self.iTimer = duration
end

function Entity:update(dt, player)
    if self.health <= 0 then
        self:changeState('death')
    end

    if self.invulnerable then
        self.flashTimer = self.flashTimer + dt
        self.iTimer = self.iTimer - dt

        if self.iTimer < 0 then
            self.invulnerable = false
            self.iTimer = 0
            self.flashTimer = 0
            self:changeState('idle')
        end
    end

    self.stateMachine:update(dt, player)
    self.currentAnimation:update(dt)
end

function Entity:render()
    if self.flashTimer > 0.24 then
        self.flashTimer = 0
    elseif self.flashTimer > 0.12 then 
        love.graphics.setColor(1, 1, 1, 0.5)
    end

    -- love.graphics.setColor(1, 0, 0, 1)
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(1, 1, 1, 1)

    self.stateMachine:render()
    love.graphics.setColor(1, 1, 1, 1)
end