local module = {}
module.__index = module
module.__type = "Scene"

module.All = {}

module.new = function(name)
	if module.All[name] then
		return module.All[name]
	end

	local self = setmetatable({}, module)
	self.Name = name
	
	self.IsPaused = false
	self.Enabled = true
	
	self.Update = Instance.new("Signal")
	self.Draw = Instance.new("Signal")
	self.GuiDraw = Instance.new("Signal")
	
	self.GuiInputBegan = Instance.new("Signal")
	self.GuiInputEnded = Instance.new("Signal")
	self.InputBegan = Instance.new("Signal")
	self.InputEnded = Instance.new("Signal")
	
	self.Maid = Instance.new("Maid")
	
	self.Maid:GiveTask(self.Update)
	self.Maid:GiveTask(self.Draw)
	self.Maid:GiveTask(self.GuiDraw)
	self.Maid:GiveTask(self.GuiInputBegan)
	self.Maid:GiveTask(self.GuiInputEnded)
	self.Maid:GiveTask(self.InputBegan)
	self.Maid:GiveTask(self.InputEnded)

	module.All[name] = self
	self.Maid:GiveTask(function()
		module.All[name] = nil
	end)

	self.Maid.GuiInputBegan = GuiInputBegan:Connect(function(...)
		self.GuiInputBegan:Fire(...)
	end)
	self.Maid.GuiInputEnded = GuiInputEnded:Connect(function(...)
		self.GuiInputEnded:Fire(...)
	end)
	self.Maid.InputBegan = InputBegan:Connect(function(...)
		self.InputBegan:Fire(...)
	end)
	self.Maid.InputEnded = InputEnded:Connect(function(...)
		self.InputEnded:Fire(...)
	end)

	-- self.Camera = Instance.new("camera", self)
	-- self.Maid:GiveTask(self.camera)

	return self
end

function module:Pause()
	self.IsPaused = true
end
function module:Unpause()
	self.IsPaused = false
end
function module:Enable()
	self.Enabled = true
end
function module:Disable()
	self.Enabled = false
end

function module:Destroy()
	self.Maid:Destroy()
end

module.Init = function()
    Instance.AddClass(module.__type, module)
end

return module