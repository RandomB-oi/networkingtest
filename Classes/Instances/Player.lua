local module = {}
module.__index = module
module.__type = "Player"
module.Derives = "Classes/Instances/Entity"
module.UniqueReplication = true

module.new = function(self)
    local DefaultToolColor = Color.new(1,1,1,1)
    self.Position = Vector.new(0, 0)
    self.Size = Vector.new(100, 100)
    self.Tools = {Instance.new("Flashlight", self.Scene), Instance.new("Tool", self.Scene)}
    self.EquippedToolId = nil

    self.EquippedToolChanged = Instance.new("Signal")
    self.Maid:GiveTask(self.EquippedToolChanged)

    self.Maid.DrawTool = self.Scene.Draw:Connect(function()
        local equippedTool = self:GetEquippedTool()
        if equippedTool then
            DefaultToolColor:Apply()
            love.graphics.cleanDrawImage(love.graphics.newImage(equippedTool.Image), self.Position+(self.Size-equippedTool.Size)/2, equippedTool.Size)
        end
    end)

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
    
        if NetworkClient then
            local equippedTool = self:GetEquippedTool()
            local compressedEquippedTool = equippedTool and {
                className = equippedTool.__type,
                id = equippedTool.ID,
            }

            NetworkClient:Send("plrData", {
                pos = {self.Position.X, self.Position.Y},
                size = {self.Size.X, self.Size.Y},
                id = self.ID,
                equippedTool = compressedEquippedTool,
            })
        end
    end)
end

function module:EquipTool(toolIndex)
    local tool = toolIndex and self.Tools[toolIndex]

    local equippedTool = self:GetEquippedTool()
    if tool == equippedTool then
        tool = nil
    end
    if equippedTool then
        equippedTool.Unequipped:Fire()
    end
    if tool then
        self.EquippedToolId = tool.ID
        tool.Equipped:Fire()
    else
        self.EquippedToolId = nil
    end
    self.EquippedToolChanged:Fire(tool and toolIndex)
end

function module:GetEquippedTool()
    for index, tool in ipairs(self.Tools) do
        if tool.ID == self.EquippedToolId then
            return tool, index
        end
    end
end

module.Init = function()
    Instance.AddClass(module.__type, module)
end

module.Start = function()
    NetworkClient.DataRecived:Connect(function(jobName, newData)
        if jobName == "plrData" then
            if not (localPlayer and localPlayer.Scene) then print("cant make player, ours doesnt exist") return end
            
            local playerId = newData.id
            local player = module.Get(playerId)
            if not player then
                player = Instance.new("Player", localPlayer.Scene, nil, playerId)
                print("create it boiiiii")
            end

            player.Position.X = newData.pos[1]
            player.Position.Y = newData.pos[2]
            player.Size.X = newData.size[1]
            player.Size.Y = newData.size[2]

            local toolData = newData.equippedTool
            local newToolID = toolData and toolData.id
            local oldToolID = player.Tools[1] and player.Tools[1].ID

            if newToolID ~= oldToolID then
                if oldToolID then
                    player.Tools[1]:Destroy()
                    player.Tools[1] = nil
                    player.EquippedToolId = nil
                end
                if toolData then
                    local newTool = Instance.new(toolData.className, localPlayer.Scene, toolData.id)
                    player.Tools[1] = newTool
                    player.EquippedToolId = newTool.ID
                end
            end
        end
    end)
end

return module