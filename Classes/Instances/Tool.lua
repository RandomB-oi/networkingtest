local module = {}
module.__index = module
module.__type = "Tool"

module.new = function(scene, id)
	local self = setmetatable({}, module)
	self.Maid = Instance.new("Maid")
	self.Name = "Tool"
    self.Image = "Assets/DefaultTool.png"
    self.Size = Vector.new(75, 75)
    self.ID = id or GenerateGUID()
    self.IsEquipped = false
    self.Scene = scene
    print(self.ID)

    self.Activated = Instance.new("Signal")
    self.Equipped = Instance.new("Signal")
    self.Unequipped = Instance.new("Signal")

    self.Maid:GiveTask(self.Activated)
    self.Maid:GiveTask(self.Equipped)
    self.Maid:GiveTask(self.Unequipped)

    self.Activated:Connect(function()
        print("Activated")
    end)
    self.Equipped:Connect(function()
        self.IsEquipped = true
        print("Equipped")
    end)
    self.Unequipped:Connect(function()
        self.IsEquipped = false
        print("Unequipped")
    end)

    self.Maid.MainInput = self.Scene.InputBegan:Connect(function(key, isMouse)
        if isMouse and self.IsEquipped then
            if key == 1 then
                self.Activated:Fire()
            end
        end
    end)

	return self
end

function module:Destroy()
	self.Maid:Destroy()
end

module.Init = function()
    Instance.AddClass(module.__type, module)
end

return module