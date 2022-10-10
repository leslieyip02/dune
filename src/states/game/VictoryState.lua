VictoryState = Class{__includes = BaseState}

function VictoryState:init(time)
    self.scoreText = '- SCORE: ' .. math.ceil(time * 100) .. ' -'
end

function VictoryState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['start']:play()
        
        -- fade to black
        gStateStack:push(FadeInState({
            r = 0, g = 0, b = 0
        }, 2,
        function()
            -- remove start state
            gStateStack:pop()
            gStateStack:push(StartState())
            -- fade to play state
            gStateStack:push(FadeOutState({
                r = 0, g = 0, b = 0
            }, 3,
            function() end))
        end))
    end
end

function VictoryState:render()
    love.graphics.clear(0, 0, 0, 1)

    love.graphics.setColor(234 / 255, 191 / 255, 125 / 255)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    love.graphics.setFont(gFonts['large'])
    love.graphics.setColor(88 / 255, 59 / 255, 29 / 255)
    love.graphics.printf(self.scoreText, 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(190 / 255, 134 / 255, 72 / 255)
    love.graphics.printf('PRESS ENTER', 0, math.ceil(VIRTUAL_HEIGHT / 7 * 3), VIRTUAL_WIDTH, 'center')
    
    love.graphics.setColor(1, 1, 1, 1)
end