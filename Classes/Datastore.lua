-- usage
--[[
local playerData = Datastore:GetDatastore("BobData")

local key = "Bob"
local val = playerData:IncrementAsync(key)

print(val)
]]

function getStr(value, alreadyDoneTables, tabs, oneLine)
	tabs = tabs or 0
	if type(value) == "string" then
		return "\""..value.."\""
	elseif type(value) == "table" then
		alreadyDoneTables = alreadyDoneTables or {}
		if alreadyDoneTables[value] then
			return "** cyclic table reference **"
		end
		alreadyDoneTables[value] = true
		
		return tableToString(value, alreadyDoneTables, tabs+1, oneLine)
	else
		return tostring(value)
	end
end

function tableToString(tbl, alreadyDoneTables, tabs, oneLine)
	local alreadyDoneTables = alreadyDoneTables or {}
	if not next(tbl) then
		return "{}"
	end
	local str = "{\n"
	for index, value in pairs(tbl) do
		local indexString = string.rep("    ", tabs).."["..getStr(index, alreadyDoneTables, nil, oneLine).."]"
		local valueString = getStr(value, alreadyDoneTables, tabs, oneLine)
		
		str = str..indexString.." = "..valueString..",\n"
	end
	str = str..string.rep("    ", tabs-1).."}"
	if oneLine then
str = str:gsub([[

]], "")
		
		str = str:gsub("    ", "")
	end
	return str
end

function getValue(str)
	return loadstring(str)()
end

--- Check if a file or directory exists in this path
local function exists(file)
	local ok, err, code = os.rename(file, file)
	if not ok then
		if code == 13 then
			-- Permission denied, but it exists
			return true
		end
	end
	return ok, err
end

--- Check if a directory exists in this path
local function isdir(path)
   -- "/" works on both Unix and Windows
   return exists(path.."/")
end

local Datastore = {}
Datastore.__index = Datastore
Datastore.__type = "Datastore"

Datastore.Enabled = true

local datastoreCache = {}

function Datastore:GetDatastore(name)
	if datastoreCache[name] then
		return datastoreCache[name]
	end
	local self = setmetatable({}, Datastore)
	self.name = name
	self.path = "storedData\\"..name
	
	xpcall(function()
		if not isdir(self.path) then
			os.execute("mkdir "..self.path)
			love.filesystem.createDirectory(self.path)
		end
	end, warn)

	datastoreCache[name] = self
	
	return self
end

function Datastore:SetAsync(key, data)
	if not Datastore.Enabled then return end
	
	local str = "return "..getStr(data, {})
	local directory = self.path.."/"..key..".lua"
	local file = io.open(directory, "w")
	if file then
		file:write("", str)
		file:close()
	end
end

function Datastore:GetAsync(key)
	if not Datastore.Enabled then return end
	
	local directory = self.path.."/"..key..".lua"
	local file = io.open(directory, "r")
	if file then
   		local t = file:read("*all")
	    file:close()
	
		return getValue(t)
	end
end

function Datastore:IncrementAsync(key, amount)
	if not Datastore.Enabled then return end
	
	local amount = amount or 1
	local hasVal = self:GetAsync(key)
	if type(hasVal) ~= "number" then
		hasVal = 0
	end
	local val = (hasVal or 0) + amount
	self:SetAsync(key, val)
	
	return val
end

return Datastore