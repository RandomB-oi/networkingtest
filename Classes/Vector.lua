local module = {}
module.__index = module
module.__type = "Vector"

module.new = function(x, y)
    return setmetatable({
        X = x or 0,
        Y = y or 0,
    }, module)
end

function module:__add(other)
    return module.new(self.X + other.X, self.Y + other.Y)
end
function module:__sub(other)
    return module.new(self.X - other.X, self.Y - other.Y)
end

function module:__mul(other)
    if type(other) == "number" then
        return module.new(self.X * other, self.Y * other)
    end
    return module.new(self.X * other.Z, self.Y * other.Y)
end
function module:__div(other)
    if type(other) == "number" then
        return module.new(self.X / other, self.Y / other)
    end
    return module.new(self.X / other.Z, self.Y / other.Y)
end

function module:__tostring()
    return tostring(self.X)..", "..tostring(self.Y)
end

return module