local module = {}
module.__index = module
module.__type = "InstanceBase"

local function removeFromChildren(parent, self)
	local foundIndex = table.find(self._oldParent.children, self)
	if foundIndex then
		table.remove(self._oldParent.children, foundIndex)
	end
end

module.All = {}

module.new = function(scene, name, id)
	local self = setmetatable({}, module)
	self.Maid = Instance.new("Maid")
	
	self.Destroying = Instance.new("Signal")
	self.Maid:GiveTask(self.Destroying)
	
	self.Active = true
	
	self.Scene = scene
	self.Name = name or "Instance"
	
	self.ID = id or GenerateGUID()
    module.All[self.ID] = self
    self.Maid:GiveTask(function()
        module.All[self.ID] = nil
    end)

	self.Parent = nil
	self.Children = {}
	self.Maid:GiveTask(scene.Update:Connect(function()
		self:UpdateParent()
	end))
	
	return self
end

function module:FindFirstChild(name)
	for _, child in pairs(self.Children) do
		if child.Name == name then
			return child
		end
	end
end

function module:UpdateParent()
	if self.Parent ~= self._oldParent then
		if self._oldParent then
			self.Maid.ParentDestroy = nil
			self.Maid.SelfDestroy = nil
			removeFromChildren(self._oldParent, self)
		end
		local newParent = self.Parent
		self._oldParent = newParent
		if newParent then
			table.insert(newParent.Children, self)
			self.Maid.ParentDestroy = newParent.Destroying:Connect(function()
				self:Destroy()
			end)
			self.Maid.SelfDestroy = self.Destroying:Connect(function()
				removeFromChildren(newParent, self)
			end)
		end
	end
end

function module:IsActive()
	local parent = self
	while true do
		if not parent then break end
		if not parent.Active then return false end
		parent = parent.Parent
	end
	return true
end

function module:Destroy()
	self.Destroying:Fire()
	self.Maid:Destroy()

	for _, child in pairs(self.Children) do
		child:Destroy()
	end
end

function module.Get(id)
	return module.All[id]
end

function module:__tostring()
    return self.__type.." "..self.ID
end


function module:Replicate(prop, ...)
	if not NetworkClient then return end
	local propValue, isFunction
	if type(self[prop]) == "function" then
		local values = {...}
		propValue = {}
		for i, arg in pairs(values) do
			propValue[i] = Serializer.Encode(arg)
		end
	else
		propValue = Serializer.Encode(self[prop])
	end

    NetworkClient:Send("updIns", {
		cn = self.__type,
        id = self.ID,
        sn = self.Scene.Name,

        p = prop,
        -- serialize all the args too
        v = propValue,
        F = isFunction,
    })
end


module.Init = function()
	Instance.AddClass(module.__type, module)
end

module.Start = function()
	NetworkClient.DataRecived:Connect(function(job, info)
        if job == "updIns" then
            local emitter = module.Get(info.id) or module.new(Instance.new("Scene", info.sn), info.id)

            if info.f then
                local deserializedParams = {}
                for i, v in pairs(info.v) do
                    deserializedParams[i] = Serializer.Decode(v)
                end
                emitter[info.p](emitter, unpack(deserializedParams))
            else
                emitter[info.p] = Serializer.Decode(info.val)
            end
        end
    end)
end

return module