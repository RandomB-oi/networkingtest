local module = {}
module.__index = module
module.__type = "InstanceBase"

local function removeFromChildren(parent, self)
	table.remove(self._oldParent.children, table.find(self._oldParent.children, self))
end

local GenerateGUID = function()
	math.randomseed(os.clock() + os.time())
	local length = 8
	local id = tostring(math.random(0, 10^8))
	return id .. string.rep("0", length - id:len())
end

module.All = {}

module.new = function(scene, name)
	local self = setmetatable({}, module)
	self.Maid = Instance.new("Maid")
	
	self.Destroying = Instance.new("Signal")
	self.Maid:GiveTask(self.Destroying)
	
	self.Active = true
	
	self.Scene = scene
	self.Name = name or "Instance"
	
	self.ID = GenerateGUID()
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
end


function module:__tostring()
    return self.__type.." "..self.ID
end

module.Init = function()
	Instance.AddClass(module.__type, module)
end

return module