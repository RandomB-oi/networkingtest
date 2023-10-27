local module = {}
module.__index = module
module.__type = "Player"
module.Derives = "Classes.Instances.Entity"

module.new = function(self)
    self.Position = Vector.new(0, 0)
    self.Size = Vector.new(100, 100)
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
                player = Instance.new("Player")
                player.ID = playerId
            end

            player.Position.X = newData.pos.x
            player.Position.Y = newData.pos.y
            player.Size.X = newData.size.x
            player.Size.Y = newData.size.y
        end
    end)
end

return module