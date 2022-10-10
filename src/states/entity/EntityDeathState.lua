EntityDeathState = Class{__includes = BaseState}

function EntityDeathState:init(entity)
    self.entity = entity
end

function EntityDeathState:enter(params)
    if not self.entity.dying then
        self.entity.onDeath()
    end

    self.entity.dying = true
    self.entity:changeAnimation('death')

    self.entity.ox = self.entity.oxOnDeath or self.entity.ox
    self.entity.oy = self.entity.oyOnDeath or self.entity.oy

    self.entity.invulnerable = false
    self.entity.flashTimer = 0
end

function EntityDeathState:update(dt)
    if self.entity.currentAnimation.timesPlayed > 0 then
        self.entity.dead = true
    end
end

function EntityDeathState:render()
    local animation = self.entity.currentAnimation
    local function drawDeath()
        local mask_shader = love.graphics.newShader[[
            vec4 effect(vec4 colour, Image texture, vec2 texpos, vec2 scrpos)
            {
                vec4 pixel = Texel(texture, texpos) * colour;
                if (pixel.a < 0.5) discard;
                return pixel;
            }
        ]]
        
        love.graphics.setShader(mask_shader)
        love.graphics.draw(gTextures[animation.texture], gFrames[animation.texture][animation:getCurrentFrame()],
            math.floor(self.entity.x - self.entity.ox), math.floor(self.entity.y - self.entity.oy))
        love.graphics.setShader()
    end

    drawDeath()
    love.graphics.stencil(drawDeath, 'replace', 1)
end