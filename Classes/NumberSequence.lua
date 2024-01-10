local module = {}
module.__index = module
module.__type = "numberSequence"

module.new = function(numbers)
	return setmetatable({
        Numbers = numbers or {{0,0}, {1,1}}
	}, module)
end

function module:GetValue(x)
    for i = 1, #self.Numbers-1 do
        local v1, v2 = self.Numbers[i], self.Numbers[i+1]

        if x >= v1[1] and x <= v2[1] then
            local diff = v2[1]-v1[1]
            local alpha = (x-v1[1])/diff
            return math.lerp(v1[2], v2[2], alpha)
        end
    end
end

return module