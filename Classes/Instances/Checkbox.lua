local module = {}
module.__index = module
module.__type = "Checkbox"
module.Derives = "Classes/Instances/Frame"

module.new = function(self)
    self.Size = UDim2.FromOffset(50, 50)
    self.Color = Color.new(1, 1, 1)

    local checkMark = Instance.new("TextLabel", self.Scene)
    checkMark.Size = UDim2.FromScale(1,1)
    checkMark.Parent = self
    checkMark.Color = Color.new(0, 0, 0)
    checkMark:SetText("X")
    checkMark.Active = false

    self.ValueChanged = Instance.new("Signal")
    self.Maid:GiveTask(self.ValueChanged)
    self.Value = false

    self.ValueChanged:Connect(function(newValue)
        newValue = not not newValue
        self.Value = newValue
        checkMark.Active = newValue
    end)

    self.Clicked:Connect(function()
        self.ValueChanged:Fire(not self.Value)
    end)
	
	return self
end

module.Init = function()
	Instance.AddClass(module.__type, module)
end

return module