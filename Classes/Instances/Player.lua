local module = {}
module.__index = module
module.__type = "Player"
module.Derives = "Classes/Instances/Entity"

module.new = function(self)
    self.Position = Vector.new(0, 0)
    self.Size = Vector.new(100, 100)

    self.Maid.Movement = self.Scene.Update:Connect(function(dt)
        if not self.GiveControls then
            return
        end
        local leftPressed = love.keyboard.isDown("a") and 1 or 0
        local rightPressed = love.keyboard.isDown("d") and 1 or 0
        local upPressed = love.keyboard.isDown("w") and 1 or 0
        local downPressed = love.keyboard.isDown("s") and 1 or 0
    
        local xDir = (rightPressed - leftPressed) * 100 * dt
        local yDir = (downPressed - upPressed) * 100 * dt
    
        self.Position.X = self.Position.X + xDir
        self.Position.Y = self.Position.Y + yDir
    
        NetworkDataSend:Fire("plrData", {
            pos = {self.Position.X, self.Position.Y},
            size = {self.Size.X, self.Size.Y},
            id = self.ID,
        })
    end)
end

module.Init = function()
    Instance.AddClass(module.__type, module)
end

module.Start = function()
    NetworkDataRecieved:Connect(function(jobName, newData)
        if jobName == "plrData" then
            local playerId = newData.id
            local player = module.Get(playerId)
            if not player then
                player = Instance.new("Player", localPlayer.Scene, nil, playerId)
            end

            player.Position.X = newData.pos[1]
            player.Position.Y = newData.pos[2]
            player.Size.X = newData.size[1]
            player.Size.Y = newData.size[2]
        end
    end)
end

return module