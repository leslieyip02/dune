TextState = Class{__includes = BaseState}

function TextState:init(def)
    self.text = def.text
end

function TextState:update(dt)
    if love.keyboard.wasPressed('space') then
        gStateStack:pop()
    end
end

function TextState:render()
    -- text panel
    love.graphics.setColor(1, 1, 1, 1)
    
end