local module = {}
module.__index = module
module.__type = "Frame"
module.Derives = "Classes/Instances/InstanceBase"

module.new = function(self)
	self._updated = Instance.new("Signal")
	self.Maid:GiveTask(self._updated)
	self._drawn = Instance.new("Signal")
	self.Maid:GiveTask(self._drawn)
	
	self.AnchorPoint = Vector.new(0, 0)
	self.Position = UDim2.new(0, 0, 0, 0)
	self.Size = UDim2.new(0, 100, 0, 100)
	self.Color = Color.From255(255, 255, 255, 255)
	self.ZIndex = 1
	
	self.RenderPosition = Vector.new(0, 0)
	self.RenderSize = Vector.new(0, 0)


	self.Clicked = Instance.new("Signal")
	self.Maid:GiveTask(self.Scene.GuiInputBegan:Connect(function(key, isMouse)
		if not self:IsActive() then return end
		if isMouse and self:IsHovering() then
			_gameProcessedGobal = true
			self.Clicked:Fire(key)
		end
	end))
	
	self.Maid:GiveTask(self.Scene.Update:Connect(function(dt)
		if not self:IsActive() then return end
		
		local relativeSize
		local relativePosition
		if self.Parent then
			self.Parent._updated:Wait()
			relativeSize = self.Parent.RenderSize
			relativePosition = self.Parent.RenderPosition
		else
			relativeSize = Vector.new(love.graphics.getDimensions())
			relativePosition = Vector.new(0,0)
		end

		if self.Maid.Draw then
			self.Maid.Draw.Order = self.ZIndex
		end
		
		self.RenderSize = self.Size:Calculate(relativeSize)
		self.RenderPosition = relativePosition + self.Position:Calculate(relativeSize) - self.RenderSize * self.AnchorPoint
		
		self._updated:Fire()
	end))
	self.Maid.Draw = self.Scene.GuiDraw:Connect(function()
		if not self:IsActive() then return end
		if self.Parent then
			self.Parent._drawn:Wait()
		end
		self.Color:Apply()
		love.graphics.rectangle("fill", self.RenderPosition.X, self.RenderPosition.Y, self.RenderSize.X, self.RenderSize.Y)
	
		self._drawn:Fire()
	end)
	
	return self
end

function module:IsHovering()
	local mousePos = Vector.new(love.mouse.getPosition())
	local min = self.RenderPosition
	local max = min + self.RenderSize

	return mousePos > min and mousePos < max
end

module.Init = function()
	Instance.AddClass(module.__type, module)
end

return module