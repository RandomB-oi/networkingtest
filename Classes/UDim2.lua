local module = {}
module.__index = module
module.__type = "UDim2"

module.new = function(xscale, xoffset, yscale, yoffset)
	return setmetatable({
		X = UDim.new(xscale, xoffset),
		Y = UDim.new(yscale, yoffset),
	}, module)
end

module.FromScale = function(x,y)
	return module.new(x, 0, y, 0)
end
module.FromOffset = function(x,y)
	return module.new(0, x, 0, y)
end

function module:Calculate(size)
	return Vector.new(
		size.X * self.X.Scale + self.X.Offset, 
		size.Y * self.Y.Scale + self.Y.Offset
	)
end

return module