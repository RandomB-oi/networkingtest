local module = {}
module.__index = module
module.__type = "TextFrame"
module.Derives = "Classes/Instances/TextLabel"

defaultFont = love.graphics.newFont(64,"normal")

module.new = function(self)
	self:SetText("Hi mom")
	self.Stretch = false
	self.IsCustomFont = false

	self.XAlign = "center"
	self.YAlign = "center"
	self.TextScale = 4

    self.BackgroundColor = Color.new(1, 1, 1)
    self.Color = Color.new(0, 0, 0)
	
	self.Maid.Draw = self.Scene.GuiDraw:Connect(function()
		if not self:IsActive() then return end
		if self.Parent then
			self.Parent._drawn:Wait()
		end

		self.BackgroundColor:Apply()
		love.graphics.rectangle("fill", self.RenderPosition.X, self.RenderPosition.Y, self.RenderSize.X, self.RenderSize.Y)

		self.Color:Apply()
		if self.IsCustomFont then
			local sizePercent = Vector.new(self.XAlign == "left" and 0 or self.XAlign == "right" and 1 or 0.5, 0.5)
			local renderPosition = self.RenderPosition + self.RenderSize * sizePercent
			love.graphics.drawCustomText(self.CurrentText, renderPosition.X, renderPosition.Y, self.TextScale, self.XAlign)
		else
			love.graphics.cleanDrawText(self.TextObject, self.RenderPosition, self.RenderSize, self.Stretch, self.XAlign, self.YAlign)
		end
		self._drawn:Fire()
	end)
	
	return self
end

module.Init = function()
	Instance.AddClass(module.__type, module)
end

return module