Hitbox = Class{}

function Hitbox:init(def)
    self.x = def.x
    self.y = def.y

    self.width = def.width
    self.height = def.height
    
    self.dx = def.dx or 0
    self.dy = def.dy or 0
end

function Hitbox:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end