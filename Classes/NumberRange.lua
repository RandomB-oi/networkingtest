local module = {}
module.__index = module
module.__type = "numberRange"

module.new = function(min, max, resolution)
	return setmetatable({
        Min = min or 0,
        Max = max or 1,
        Resolution = resolution or 10,
	}, module)
end

function module:GetValue()
    return math.random(self.Min * self.Resolution, self.Max * self.Resolution) / self.Resolution
end

return module