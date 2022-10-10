Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)

    self.player = true
    self.canUpdate = true
    self.markedMap = false
    self.stateMachine = StateMachine {
        ['idle'] = function() return PlayerIdleState(self) end,
        ['walk'] = function() return PlayerWalkState(self) end,
        ['roll'] = function() return PlayerRollState(self) end,
        ['attack'] = function() return PlayerAttackState(self) end,
        ['death'] = function() return EntityDeathState(self) end
    }

    self:changeState('idle')
end

function Player:update(dt)
    if self.canUpdate then
        -- check collision with entities
        if self.room then
            for i, entity in pairs(self.room.entities) do 
                if not entity.dead and not entity.dying and self:collides(entity) then
                    entity:onCollide()
                    -- take damage
                    if entity.combatant and not self.invulnerable then
                        gSounds['player-hurt']:play()
                        self.health = self.health - entity.attack
                        
                        self:goInvulnerable(1.2)
                        self:knockbacked(entity, 4)
                        self:changeState('walk')
                        self:changeAnimation('idle-' .. self.direction)
                    end
                end
            end
        end

        Entity.update(self, dt)
    end
end

function Player:render()
    Entity.render(self)
end