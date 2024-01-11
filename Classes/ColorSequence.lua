local module = {}
module.__index = module
module.__type = "ColorSequence"

module.new = function(colors)
    if not colors then
        local colorWhite = Color.new(1,1,1,1)
        colors = {{0,colorWhite}, {1,colorWhite}}
    end
	return setmetatable({
        Colors = colors
	}, module)
end

function module:GetValue(x)
    for i = 1, #self.Colors-1 do
        local v1, v2 = self.Colors[i], self.Colors[i+1]

        if x >= v1[1] and x <= v2[1] then
            local diff = v2[1]-v1[1]
            local alpha = (x-v1[1])/diff
            return v1[2]:Lerp(v2[2], alpha)
        end
    end
end

-- module.Start = function()
--     local sequence = module.new({
--         {0, Color.new(0,0,0,1)},
--         {0.333, Color.new(1,0,0,1)},
--         {0.666, Color.new(0,1,0,1)},
--         {1, Color.new(0,0,1,1)},
--     })

--     local point = sequence:GetValue(0.5)

--     print(point.R, point.G, point.B, point.A)
-- end

return module