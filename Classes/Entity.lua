local module = {}
module.__index = module
module.__type = "Entity"
module.Derives = "Classes.Object"

module.new = function(self)
    self.Position = Vector.new(0, 0)
    self.Size = Vector.new(25, 25)

    self.Maid.Draw = LoveDraw:Connect(function()
        love.graphics.setColor(1,1,1,1)
        love.graphics.rectangle("line", self.Position.X, self.Position.Y, self.Size.X, self.Size.Y)
    end)
end

module.Init = function()
    Instance.AddClass(module.__type, module)
end

return module