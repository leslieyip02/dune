Class = require 'lib/class'
Event = require 'lib/knife.event'
push = require 'lib/push'
Timer = require 'lib/knife.timer'
Easing = require 'lib/easing'

require 'src/Constants'
require 'src/StateMachine'
require 'src/Util'
require 'src/Animation'

require 'src/states/BaseState'
require 'src/states/StateStack'

require 'src/states/game/StartState'
require 'src/states/game/PlayState'
require 'src/states/game/FadeInState'
require 'src/states/game/FadeOutState'
require 'src/states/game/MapState'
require 'src/states/game/VictoryState'

require 'src/states/entity/EntityIdleState'
require 'src/states/entity/EntityWalkState'
require 'src/states/entity/EntityAttackState'
require 'src/states/entity/EntityDeathState'
require 'src/states/entity/PlayerIdleState'
require 'src/states/entity/PlayerWalkState'
require 'src/states/entity/PlayerRollState'
require 'src/states/entity/PlayerAttackState'

require 'src/map/Map'
require 'src/map/Room'
require 'src/map/Tile'
require 'src/map/tile_defs'

require 'src/entities/Entity'
require 'src/entities/Player'
require 'src/entities/Hitbox'
require 'src/entities/entity_defs'

gTextures = {
    ['tiles'] = love.graphics.newImage('graphics/tilesheet.png'),
    ['player'] = love.graphics.newImage('graphics/player.png'),
    ['player-attack'] = love.graphics.newImage('graphics/player_attack.png'),
    ['objects'] = love.graphics.newImage('graphics/objects.png'),
    ['enemies'] = love.graphics.newImage('graphics/enemies.png'),
    ['death-small'] = love.graphics.newImage('graphics/death.png'),
    ['hourglass'] = love.graphics.newImage('graphics/hourglass.png'),
    ['title'] = love.graphics.newImage('graphics/title.png'),
}

gFrames = {
    ['tiles'] = GenerateQuads(gTextures['tiles'], TILE_SIZE, TILE_SIZE),
    ['player'] = GenerateQuads(gTextures['player'], ENTITY_DEFS['player'].width, ENTITY_DEFS['player'].height),
    ['player-attack'] = GenerateQuads(gTextures['player-attack'], ATTACK_SPRITE_SIZE, ATTACK_SPRITE_SIZE),
    ['objects'] = GenerateQuads(gTextures['objects'], OBJECT_SIZE, OBJECT_SIZE),
    ['enemies'] = GenerateQuads(gTextures['enemies'], ENEMY_SIZE, ENEMY_SIZE),
    ['death-small'] = GenerateQuads(gTextures['death-small'], DEATH_SMALL_SIZE, DEATH_SMALL_SIZE),
    ['hourglass'] = GenerateQuads(gTextures['hourglass'], HOURGLASS_WIDTH, HOURGLASS_HEIGHT)
}

gFonts = {
    -- ['small'] = love.graphics.newFont('fonts/font.ttf', 8)
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
}

gSounds = {
    ['start'] = love.audio.newSource('sounds/start.wav', 'static'),
    ['win'] = love.audio.newSource('sounds/win.wav', 'static'),
    ['dune'] = love.audio.newSource('sounds/dune.wav', 'static'),
    ['map'] = love.audio.newSource('sounds/map.wav', 'static'),
    ['box-break'] = love.audio.newSource('sounds/box_break.wav', 'static'),
    ['chest'] = love.audio.newSource('sounds/chest.wav', 'static'),
    ['gold-chest'] = love.audio.newSource('sounds/gold_chest.wav', 'static'),
    ['gold'] = love.audio.newSource('sounds/gold.wav', 'static'),
    ['heart'] = love.audio.newSource('sounds/heart.wav', 'static'),
    ['roll'] = love.audio.newSource('sounds/roll.wav', 'static'),
    ['whip'] = love.audio.newSource('sounds/whip.wav', 'static'),
    ['player-hurt'] = love.audio.newSource('sounds/player_hurt.wav', 'static'),
    ['player-death'] = love.audio.newSource('sounds/player_death.wav', 'static'),
    ['snake-hurt'] = love.audio.newSource('sounds/snake_hurt.wav', 'static'),
    ['snake-death'] = love.audio.newSource('sounds/snake_death.wav', 'static'),
}