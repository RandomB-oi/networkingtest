local module = {}
module.__index = module
module.__type = "Flashlight"
module.Derives = "Classes/Instances/Tool"

local ReplicatedFlashlightPoints = {}

module.new = function(self)
	self.Name = "Flashlight"
    self.Image = "Assets/Flashlight.png"
    self.Size = Vector.new(75, 75)

    self.Activated:Connect(function()
    end)
    self.Equipped:Connect(function()
        self.Maid.Replication = self.Scene.Update:Connect(function()
            local pos = {localPlayer.Position.X + localPlayer.Size.X/2, localPlayer.Position.Y + localPlayer.Size.Y/2}
            ReplicatedFlashlightPoints[self.ID] = Vector.new(pos[1], pos[2])
            NetworkDataSend:Fire("flashlightPoint", {
                pos = pos,
                id = self.ID,
            })
        end)
    end)
    self.Unequipped:Connect(function()
        self.Maid.Replication = nil
        ReplicatedFlashlightPoints[self.ID] = nil
        NetworkDataSend:Fire("flashlightPoint", {
            pos = nil,
            id = self.ID,
        })
    end)

    self.LightColor = Color.new(1,1,1,0.025)
    self.Maid.Draw = self.Scene.Draw:Connect(function(dt)
        self.LightColor:Apply()
        local point = ReplicatedFlashlightPoints[self.ID]
        if point then
            local rings = 25
            for i = 1, rings do
                love.graphics.circle("fill", point.X, point.Y, math.lerp(5, 200, i/rings))
            end
        end
    end)

	return self
end

module.Init = function()
    Instance.AddClass(module.__type, module)
end

module.Start = function(args)
    NetworkDataRecieved:Connect(function(jobName, newData)
        if jobName == "flashlightPoint" then
            ReplicatedFlashlightPoints[newData.id] = newData.pos and Vector.new(newData.pos[1], newData.pos[2])
        end
    end)

    Draw:Connect(function(args)
        
    end)
end

return module