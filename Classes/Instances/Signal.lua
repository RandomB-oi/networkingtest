local module = {}
module.__index = module
module.__type = "signal"
	
module.new = function()
	return setmetatable({}, module)
end

function module:Connect(callback, order)
	local connection = {
		Order = order or 10,
		_callback = callback,
		Disconnect = function(connection)
---@diagnostic disable-next-line: undefined-field
			table.remove(self, table.find(self, connection))
		end,
	}
	table.insert(self, connection)
	return connection
end

function module:Once(callback)
	local connection connection = self:Connect(function(...)
		connection:Disconnect()
			
		coroutine.wrap(callback)(...)
	end)
end

function module:Wait()
	local thread = coroutine.running()
	self:Once(function(...)
		coroutine.resume(thread, ...)
	end)
	return coroutine.yield()

	-- local returned
	-- self:once(function(...)
	-- 	returned = {...}
	-- end)
	-- while not returned do end
	-- return unpack(returned)
end

local unknownOrder = 25
local doOrderedSignals = true

function module:Fire(...)
	local args = {...}
	if doOrderedSignals then
		local s,e = pcall(function()
			local orderedConnections = {}
			for _, connection in pairs(self) do
				if type(connection) == "table" then
					local order = connection.Order or unknownOrder
					if not orderedConnections[order] then
						orderedConnections[order] = {}
					end
					table.insert(orderedConnections[order], connection)
				end
			end
			local orderList = {}
			for order in pairs(orderedConnections) do
				table.insert(orderList, order)
			end
			table.sort(orderList, function(a,b)
				return a < b
			end)
			-- for i = #orderList, 1, -1 do
			--	local v = orderList[i]
			for i,v in ipairs(orderList) do
				local list = orderedConnections[v]
				for connectionIndex, connection in ipairs(list) do
					coroutine.wrap(connection._callback)(unpack(args))
				end
			end
		end)
	else
		for _, connection in pairs(self) do
			if type(connection) == "table" then
				coroutine.wrap(connection._callback)(...)
			end
		end
	end
end

function module:destroy()
	local index, task = next(self)
	while index and task ~= nil do
		task:disconnect()
		index, task = next(self)
	end
end

module.Init = function()
    Instance.AddClass("Signal", module)
end

return module