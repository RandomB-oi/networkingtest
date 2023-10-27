local module = {}
module.__index = module
module.__type = "Scene"

module.new = function(name)
	local self = setmetatable({}, module)
	self.Name = name
	
	self.IsPaused = false
	self.Enabled = true
	
	self.Update = Signal.new()
	self.Draw = Signal.new()
	self.GuiDraw = Signal.new()

	self.GuiInputBegan = Signal.new()
	self.GuiInputEnded = Signal.new()
	self.InputBegan = Signal.new()
	self.InputEnded = Signal.new()
	
	self.Maid = Instance.new("Maid")

	self.Maid:GiveTask(self.Update)
	self.Maid:GiveTask(self.Draw)
	self.Maid:GiveTask(self.GuiDraw)
	self.Maid:GiveTask(self.GuiInputBegan)
	self.Maid:GiveTask(self.GuiInputEnded)
	self.Maid:GiveTask(self.InputBegan)
	self.Maid:GiveTask(self.InputEnded)
	
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

return module