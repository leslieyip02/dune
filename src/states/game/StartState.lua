StartState = Class{__includes = BaseState}

function StartState:init()
    
end

function StartState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['start']:play()

        -- https://tinyurl.com/2qm34x3k
        gSounds['dune']:stop()
        gSounds['dune']:setVolume(0.5)
        gSounds['dune']:setLooping(true)
        gSounds['dune']:play()

        -- fade to black
        gStateStack:push(FadeInState({
            r = 0, g = 0, b = 0
        }, 2,
        function()
            -- remove start state
            gStateStack:pop()
            gStateStack:push(PlayState({}))
            -- fade to play state
            gStateStack:push(FadeOutState({
                r = 0, g = 0, b = 0
            }, 3,
            function() end))
        end))
    end
end

function StartState:render()
    love.graphics.clear(0, 0, 0, 1)

    love.graphics.setColor(234 / 255, 191 / 255, 125 / 255)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gTextures['title'], 172, VIRTUAL_HEIGHT / 4)

    love.graphics.setFont(gFonts['large'])
    
    love.graphics.setColor(190 / 255, 134 / 255, 72 / 255)
    love.graphics.printf('PRESS ENTER', 0, VIRTUAL_HEIGHT / 3 * 2, VIRTUAL_WIDTH, 'center')
    
    love.graphics.setColor(1, 1, 1, 1)
end