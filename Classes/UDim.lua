local module = {}
module.__index = module
module.type = "udim"

module.new = function(scale, offset)
	return setmetatable({
		Scale = scale or 0, 
		Offset = offset or 0
	}, module)
end

return module