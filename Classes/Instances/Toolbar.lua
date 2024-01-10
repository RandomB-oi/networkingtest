local module = {}
module.__index = module
module.__type = "Toolbar"

module.new = function(scene, player)
	local self = setmetatable({}, module)
	self.Maid = Instance.new("Maid")
    self.ToolFrames = {}
    self.Player = player
    
	self.Scene = scene
    self.ToolbarFrame = Instance.new("Frame", self.Scene)
    self.ToolbarFrame.AnchorPoint = Vector.new(0.5, 1)
    self.ToolbarFrame.Size = UDim2.new(1, 0, 0, 75)
    self.ToolbarFrame.Position = UDim2.new(0.5, 0, 1, -5)
    self.ToolbarFrame.Color = Color.new(1,1,1,0)

    self.Maid:GiveTask(self.Scene.InputBegan:Connect(function(key, isMouse)
        if not isMouse then
            local keyNum = tonumber(key)
            if keyNum and self.Player.Tools[keyNum] then
                self.Player:EquipTool(keyNum)
            end
        end
    end))
    
    self:UpdateFrames()
    self.Maid:GiveTask(self.Player.EquippedToolChanged:Connect(function()
        self:UpdateFrames()
    end))
	
    return self
end

function module:UpdateFrames()
    for index = #self.ToolFrames, 1, -1 do
        local toolFrame = self.ToolFrames[i]
        if toolFrame and not self.Player.Tools[i] then
            toolFrame:Destroy()
        end
    end

    local frameSize = 75

    for i, tool in ipairs(self.Player.Tools) do
        if not self.ToolFrames[i] then
            local newFrame = Instance.new("ImageLabel", self.Scene)
            newFrame.Name = "ToolFrame"..tostring(i)
            newFrame.AnchorPoint = Vector.new(.5, 1)
            newFrame.Size = UDim2.new(0, frameSize, 0, frameSize)
            newFrame.Color = Color.new(1,1,1,1)
            newFrame:SetImage("Assets/ToolSlot.png")
            newFrame.Parent = self.ToolbarFrame

            local toolIconFrame = Instance.new("ImageLabel", self.Scene)
            toolIconFrame.AnchorPoint = Vector.new(0.5, 0.5)
            toolIconFrame.Position = UDim2.FromScale(0.5, 0.5)
            toolIconFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
            toolIconFrame.Color = Color.new(1,1,1,1)
            toolIconFrame.Name = "ToolIcon"
            toolIconFrame.Parent = newFrame
            toolIconFrame:UpdateParent()

            local toolNameFrame = Instance.new("TextLabel", self.Scene)
            toolNameFrame.AnchorPoint = Vector.new(0.5, 0)
            toolNameFrame.Position = UDim2.FromScale(0.5, 0.1)
            toolNameFrame.Size = UDim2.new(0.8, 0, 0.25, 0)
            toolNameFrame.Color = Color.new(1,1,1,1)
            toolNameFrame.Name = "ToolName"
            toolNameFrame.Parent = newFrame
            toolNameFrame:UpdateParent()

            newFrame.Clicked:Connect(function()
                self.Player:EquipTool(i)
            end)

            self.ToolFrames[i] = newFrame
        end

        local toolFrame = self.ToolFrames[i]
        local iconFrame = toolFrame:FindFirstChild("ToolIcon")
        local toolNameFrame = toolFrame:FindFirstChild("ToolName")
        iconFrame:SetImage(tool.Image)
        toolNameFrame:SetText(tool.Name)

        if tool.ID == self.Player.EquippedToolId then
            toolFrame.Color.A = 1
        else
            toolFrame.Color.A = 0.5
        end
    end

    -- position calculating
    local padding = 5
    local totalFrameCount = #self.Player.Tools

    local totalSize = (totalFrameCount-1)*(frameSize+padding)

    for i, toolFrame in ipairs(self.ToolFrames) do
        local size = (i-1) * (frameSize + padding)
        local pos = UDim2.new(0.5, size-totalSize/2, 1, 0)
        toolFrame.Position = pos
    end
end

function module:Destroy()
	self.Maid:Destroy()
end

module.Init = function()
    Instance.AddClass(module.__type, module)
end

return module