PlayState = Class{__includes = BaseState}

local offset = {
    up = { 0, -1 },
    down = { 0, 1 },
    left = { -1, 0 },
    right = { 1, 0 }
}

function PlayState:init(def)
    -- generate maze
    local mapMaxW = 10 + math.random(4)
    local mapMaxH = 6 + math.random(4)
    local mapper = Map({ w = mapMaxW, h = mapMaxH })
    local startX = math.random(mapMaxW)
    local startY = math.random(mapMaxH)
    self.map = mapper:generate(startX, startY)
    
    local startRoom = self.map[startY][startX]
    startRoom:emptyRoom()

    self.currentX = startX
    self.currentY = startY
    self.currentRoom = startRoom
    
    self.player = Player{
        x = TILE_SIZE * ROOM_WIDTH / 2 - (ENTITY_DEFS['player'].width / 2),
        y = TILE_SIZE * ROOM_HEIGHT / 2 - (ENTITY_DEFS['player'].height / 2),
        width = ENTITY_DEFS['player'].width,
        height = ENTITY_DEFS['player'].height,
        health = ENTITY_DEFS['player'].health,
        speed = ENTITY_DEFS['player'].speed,
        attack = ENTITY_DEFS['player'].attack,

        animations = ENTITY_DEFS['player'].animations,

        room = startRoom
    }

    self.currentRoom.player = player

    self.crystals = {}
    for i = 1, mapper.numCrystals do
        table.insert(self.crystals, 33)
    end

    -- transitions
    self.transitionRoom = nil
    self.transitionX = 0
    self.transitionY = 0
    self.transitionCurrentX = 0
    self.transitionCurrentY = 0

    -- timing
    self.timer = START_TIME
    self.timerFlashTimer = 0
end

function PlayState:enterRoom(dir, playerX, playerY)
    local ox, oy = offset[dir][1], offset[dir][2]
    if self.map[self.currentY + oy] then 
        local room = self.map[self.currentY + oy][self.currentX + ox]
        if room then
            if not room.tiles then room:renovate() end

            self.transitionRoom = room
            self.transitionX = TILE_SIZE * ROOM_WIDTH * ox
            self.transitionY = TILE_SIZE * ROOM_HEIGHT * oy

            self.player.canUpdate = false

            Timer.tween(0.5, {
                [self] = {
                    transitionX = 0,
                    transitionY = 0,
                    transitionCurrentX = TILE_SIZE * ROOM_WIDTH * -ox,
                    transitionCurrentY = TILE_SIZE * ROOM_HEIGHT * -oy
                },
                [self.player] = { x = playerX, y = playerY }
            }):finish(function() 
                self.currentX = self.currentX + ox
                self.currentY = self.currentY + oy
                self.currentRoom = room
                self.currentRoom.player = self.player

                self.player.room = room
                self.player.canUpdate = true

                self.transitionRoom = nil
                self.transitionCurrentX = 0
                self.transitionCurrentY = 0
            end)
        end
    end
end

function PlayState:update(dt)
    -- check if all crystals have been collected
    for _, c in pairs(self.crystals) do
        if c == 33 then
            goto update
        end
    end

    :: win ::
    
    gSounds['dune']:stop()
    gSounds['win']:play()

    -- fade ot black
    gStateStack:push(FadeInState({
            r = 0, g = 0, b = 0
        }, 2,
        function()
            -- remove play state
            gStateStack:pop()
            gStateStack:push(VictoryState(self.timer))
            -- fade to game over
            gStateStack:push(FadeOutState({
                r = 0, g = 0, b = 0
            }, 3,
            function() end))
    end))

    :: update ::
    if love.keyboard.wasPressed('m') then
        gSounds['map']:play()
        gStateStack:push(MapState({ map = self.map, currentRoom = self.currentRoom }))
    -- elseif love.keyboard.wasPressed('t') then
    --     -- local snake = Entity{
    --     --     x = 100,
        --     y = 100,
        --     width = ENTITY_DEFS['snake'].width,
        --     height = ENTITY_DEFS['snake'].height,
        --     ox = ENTITY_DEFS['snake'].ox,
        --     oy = ENTITY_DEFS['snake'].oy,
        --     health = ENTITY_DEFS['snake'].health,
        --     speed = ENTITY_DEFS['snake'].speed,
        --     attack = ENTITY_DEFS['snake'].attack,

        --     animations = ENTITY_DEFS['snake'].animations,

        --     room = self.currentRoom
        -- }

        -- snake.combatant = true
        -- snake.canTrack = true
        -- snake.oxOnDeath = (snake.width - DEATH_SMALL_SIZE) / 2 + snake.ox
        -- snake.oyOnDeath = (DEATH_SMALL_SIZE - snake.height) / 2 + snake.oy

        -- local idleAi = function(player)
        --     -- activate when in range of player
        --     if snake.canTrack and player and snake:distanceTo(player) < 128 then
        --         snake.direction = (snake.x > player.x) and 'left' or 'right'
        --         snake:changeState('walk')
        --     end
        -- end

        -- local walkAi = function(player)
        --     if snake.canTrack and player then
        --         snake.direction = (snake.x > player.x) and 'left' or 'right'
        --         snake:changeAnimation('walk-' .. snake.direction)
        --         local a = snake:angleTo(player)
        --         snake.dx = snake.dx + snake.speed * math.cos(a)
        --         snake.dy = snake.dy + snake.speed * math.sin(a)
        --     end
        -- end

        -- snake.stateMachine = StateMachine {
        --     ['idle'] = function() return EntityIdleState(snake, idleAi) end,
        --     ['walk'] = function() return EntityWalkState(snake, walkAi) end,
        --     ['death'] = function() return EntityDeathState(snake) end
        -- }
        -- snake:changeState('idle')

        -- snake.onHit = function()
        --     snake.health = snake.health - 1
        --     snake:goInvulnerable(1.2)

        --     snake.canTrack = false
        --     Timer.after(1.2, function()
        --         snake.canTrack = true
        --     end)

        --     snake:changeState('idle')
        -- end

        -- table.insert(self.currentRoom.entities, snake)

        -- local skeleton = Entity{
        --     x = 100,
        --     y = 100,
        --     width = ENTITY_DEFS['skeleton'].width,
        --     height = ENTITY_DEFS['skeleton'].height,
        --     ox = ENTITY_DEFS['skeleton'].ox,
        --     oy = ENTITY_DEFS['skeleton'].oy,
        --     health = ENTITY_DEFS['skeleton'].health,
        --     speed = ENTITY_DEFS['skeleton'].speed,
        --     attack = ENTITY_DEFS['skeleton'].attack,

        --     animations = ENTITY_DEFS['skeleton'].animations,

        --     room = self.currentRoom
        -- }

        -- skeleton.stateMachine = StateMachine {
        --     ['idle'] = function() return EntityIdleState(skeleton) end
        -- }
        -- skeleton:changeState('idle')

        -- table.insert(self.currentRoom.entities, skeleton)
    end

    self.timer = math.max(self.timer - dt, 0)
    if self.timer <= 31 then
        self.timerFlashTimer = self.timerFlashTimer + dt
        if self.timerFlashTimer > 0.5 then
            self.timerFlashTimer = 0
        end
    end

    if self.timer <= 0 then
        self.player.health = 0
    end

    for i, entity in pairs(self.currentRoom.entities) do
        if not entity.dead then entity:update(dt, self.player) end
        if entity.dying and entity.timeValue then
            self.timer = math.min(self.timer + entity.timeValue, START_TIME)
            entity.timeValue = nil
        end
    end

    if self.player.dead then
        gSounds['player-death']:play()
        gSounds['dune']:stop()
        -- fade ot black
        gStateStack:push(FadeInState({
            r = 0, g = 0, b = 0
        }, 4,
        function()
            -- remove play state
            gStateStack:pop()
            gStateStack:push(StartState({}))
            -- fade to game over
            gStateStack:push(FadeOutState({
                r = 0, g = 0, b = 0
            }, 3,
            function() end))
        end))
    end

    if not self.player.dead then
        self.player:update(dt)
    end

    for i, deco in pairs(self.currentRoom.decorations) do
        if not deco.dead then deco:update(dt) end
    end

    if self.currentRoom.collected and type(self.currentRoom.marker) == 'number' then
        if self.currentRoom.marker < 41 then
            for i = 1, #self.crystals do
                if self.crystals[i] == 33 then
                    self.crystals[i] = self.currentRoom.marker
                    break
                end
            end
        elseif self.currentRoom.marker == 41 then
            self.player.markedMap = true
        elseif self.currentRoom.marker == 43 then
            self.player.speed = self.player.speed + 8
        elseif self.currentRoom.marker == 44 then
            self.player.attack = self.player.attack + 5
        end

        self.currentRoom.collected = false
    end

    -- check room transitions
    if self.player.y < 0 then
        self:enterRoom('up', self.player.x, TILE_SIZE * (ROOM_HEIGHT - 1))
    elseif self.player.y + self.player.height > TILE_SIZE * ROOM_HEIGHT then
        self:enterRoom('down', self.player.x, TILE_SIZE - ENTITY_DEFS['player'].height)
    elseif self.player.x < 0 then
        self:enterRoom('left', TILE_SIZE * (ROOM_WIDTH - 1), self.player.y)
    elseif self.player.x + self.player.width > TILE_SIZE * ROOM_WIDTH then
        self:enterRoom('right', TILE_SIZE - ENTITY_DEFS['player'].width, self.player.y)
    end
end

function PlayState:render()
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.push()

        -- current room
        love.graphics.push()
            love.graphics.translate(self.transitionCurrentX, self.transitionCurrentY)
            self.currentRoom:render()
        love.graphics.pop()

        -- transition to next room
        if self.transitionRoom then
            love.graphics.push()
                love.graphics.translate(self.transitionX, self.transitionY)
                self.transitionRoom:render()
            love.graphics.pop()
        end

        love.graphics.setStencilTest('less', 1)
        
        -- entities (snakes)
        if not self.transitionRoom then
            for i, entity in pairs(self.currentRoom.entities) do
                if not entity.dead and not entity.chestCollectible then entity:render() end
            end
        end

        -- player
        self.player:render()
        
        -- decorations
        if not self.transitionRoom then
            for i, deco in pairs(self.currentRoom.decorations) do
                if not deco.dead then deco:render() end
            end
        end

        -- chest collectibles
        if not self.transitionRoom then
            for i, entity in pairs(self.currentRoom.entities) do
                if not entity.dead and entity.chestCollectible then entity:render() end
            end
        end

        love.graphics.setStencilTest()

    love.graphics.pop()

    -- crystals
    love.graphics.push()

        love.graphics.translate(CRYSTAL_GAP_SIZE, CRYSTAL_GAP_SIZE)
        love.graphics.setColor(1, 1, 1, 1)

        for i = 1, #self.crystals do
            love.graphics.draw(gTextures['objects'], gFrames['objects'][self.crystals[i]],
                (i - 1) * (CRYSTAL_WIDTH + CRYSTAL_GAP_SIZE), 0)
        end
        
    love.graphics.pop()

    -- sidebar
    love.graphics.push()

        love.graphics.translate(TILE_SIZE * ROOM_WIDTH, 0)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle('fill', 0, 0, SIDEBAR_WIDTH, VIRTUAL_HEIGHT)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(gFonts['medium'])
        
        local minutes = math.floor(self.timer / 60)
        local seconds = math.floor(self.timer % 60)
        local timerText = minutes .. ':' .. (seconds < 10 and '0' .. seconds or seconds)
        local timerTextWidth = gFonts['medium']:getWidth(timerText)
        
        if self.timer <= 31 then
            if self.timerFlashTimer >= 0.25 then 
                love.graphics.setColor(0, 0, 0, 0)
            else
                love.graphics.setColor(200 / 255, 55 / 255, 45 / 255, 1) 
            end
        end
        love.graphics.printf(timerText, math.ceil((SIDEBAR_WIDTH - timerTextWidth) / 2 + 1), HOURGLASS_HEIGHT + 24, timerTextWidth, 'center')
        love.graphics.setColor(1, 1, 1, 1)

        -- hourglass sand
        local sandLeft = -math.ceil(28 * self.timer / START_TIME)
        local sandPile = -(28 + sandLeft)

        love.graphics.setColor(231 / 255, 181 / 255, 106 / 255, 1)
        love.graphics.rectangle('fill', math.ceil((SIDEBAR_WIDTH - HOURGLASS_WIDTH) / 2), 60, HOURGLASS_WIDTH, sandLeft)
        love.graphics.rectangle('fill', math.ceil((SIDEBAR_WIDTH - HOURGLASS_WIDTH) / 2), HOURGLASS_HEIGHT, HOURGLASS_WIDTH, sandPile)
        
        -- hourglass
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(gTextures['hourglass'], gFrames['hourglass'][1],
            math.ceil((SIDEBAR_WIDTH - HOURGLASS_WIDTH) / 2), 16)

        -- healthbar
        local healthHeight = -120 * math.max(self.player.health, 0) / self.player.maxHealth
        love.graphics.setColor(200 / 255, 55 / 255, 45 / 255, 1)
        love.graphics.rectangle('fill', math.ceil((SIDEBAR_WIDTH - HEALTHBAR_WIDTH) / 2), 216 + HEALTHBAR_HEIGHT, HEALTHBAR_WIDTH, healthHeight)
        love.graphics.setLineWidth(8)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle('line', math.ceil((SIDEBAR_WIDTH - HEALTHBAR_WIDTH) / 2), 216, HEALTHBAR_WIDTH, HEALTHBAR_HEIGHT)

        local healthText = 'HP: ' .. math.max(self.player.health, 0) .. '/' .. self.player.maxHealth
        local healthTextWidth = gFonts['medium']:getWidth(healthText)
        love.graphics.printf(healthText, math.ceil((SIDEBAR_WIDTH - healthTextWidth) / 2 + 1), VIRTUAL_HEIGHT - 32, healthTextWidth, 'center')

    love.graphics.pop()

    love.graphics.setColor(1, 1, 1, 1)
end