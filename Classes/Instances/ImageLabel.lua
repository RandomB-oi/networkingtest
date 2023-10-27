local module = {}
module.__index = module
module.__type = "ImageLabel"
module.Derives = "Classes/Instances/Frame"

module.new = function(self)
	self:SetImage("")
	self.Maid.Draw = self.Scene.GuiDraw:Connect(function()
		if not self.ImageObject then return end
		if not self:IsActive() then return end
		if self.Parent then
			self.Parent._drawn:Wait()
		end
		self.Color:Apply()
		love.graphics.cleanDrawImage(self.ImageObject, self.RenderPosition, self.RenderSize)
		self._drawn:Fire()
	end)
	
	return self
end

function module:SetImage(newImage)
	if newImage == "" then
		self.ImageObject = nil
		return
	end
	self.ImageObject = love.graphics.newImage(newImage)
end

module.Init = function()
	Instance.AddClass(module.__type, module)
end

return module