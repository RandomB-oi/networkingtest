local module = {}
module.__index = module
module.__type = "Object"

local GenerateGUID = function()
    math.randomseed(os.clock() + os.time())
    local length = 8
    local id = tostring(math.random(0, 10^8))
    return id .. string.rep("0", length - id:len())
end

module.All = {}

module.new = function()
    local self = setmetatable({}, module)
    self.Maid = Instance.new("Maid")

    self.ID = GenerateGUID()
    module.All[self.ID] = self
    self.Maid:GiveTask(function()
        module.All[self.ID] = nil
    end)

    return self
end

function module:__tostring()
    return module.__type.." "..self.ID
end

module.Init = function()
    Instance.AddClass(module.__type, module)
end

return module