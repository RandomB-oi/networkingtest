local module = {}

module.Basic__index = function(module, self, i, functions)
	local modHas = rawget(module, i)
	if modHas then return modHas end
	
	local selfHas = rawget(self, i)
	if selfHas then return modHas end

	if functions[i] then
		return functions[i](self)
	end
end

module.LoadModule = function(modToLoad)
	local derivesName = rawget(modToLoad, "Derives")
	local derives = derivesName and require(derivesName)
	if derives then
		rawset(modToLoad, "Derives", derives)
		setmetatable(modToLoad, derives)
	else
		rawset(modToLoad, "Derives", nil)
	end
end

module.RecurseRequire = function(directory, requireOrder)
	local tbl = {}
	local requireOrder = requireOrder or {}

	local directories = {}
	local files = {}
	
	for i, fileName in pairs(love.filesystem.getDirectoryItems(directory)) do
		local isDirectory do
			if love.filesystem.getInfo then
				isDirectory = love.filesystem.getInfo(directory.."/"..fileName).type == "directory"
			else
				isDirectory = love.filesystem.isDirectory(directory.."/"..fileName)
			end
		end

		if isDirectory then
			table.insert(directories, {name = fileName, directory = directory.."/"..fileName})
		elseif fileName:find(".lua") then
			local objectName = string.split(fileName, ".")[1]
			local fileDir = directory.."/"..objectName
			table.insert(requireOrder, fileDir)

			local required = require(fileDir)
			rawset(required,"_fileName", objectName)
			tbl[objectName] = required
			module.LoadModule(required)
		end
	end

	for _ , info in ipairs(directories) do
		tbl[info.name] = module.RecurseRequire(info.directory, requireOrder)
	end
	
	return tbl, requireOrder
end

module.RecurseInit = function(tbl, order)
	if order then
		for _, dir in ipairs(order) do
			local module = require(dir)
			local init = module and rawget(module, "Init")
			if init then
				init()
			end
		end
		return
	end
	for i, v in pairs(tbl) do
		if type(v) == "table" then
			local init = rawget(v, "Init")
			if init then
				init()
			end
			module.recurseInit(v)
		end
	end
end

module.RecurseStart = function(tbl, order)
	if order then
		for _, dir in ipairs(order) do
			local module = require(dir)
			local start = module and rawget(module, "Start")
			if start then
				xpcall(coroutine.wrap(start), print)
			end
		end
		return
	end
	for i, v in pairs(tbl) do
		if type(v) == "table" then
			local start = rawget(v, "Start")
			if start then
				pcall(coroutine.wrap(start))
			end
			module.recurseStart(v)
		end
	end
end

module.new = function(class, ...)
	local order = {class}
	local parentClass = class
	while true do
		local derives = parentClass and rawget(parentClass, "Derives")
		if type(derives) == "string" then
			derives = require(derives)
		end
		if derives and type(derives) == "table" then
			parentClass = derives
			table.insert(order, parentClass)
		else
			table.remove(order, #order) -- because this is parentClass
			break
		end
	end
	local object = parentClass.new(...)
	for i = #order, 1, -1 do
		local subClass = order[i]
		setmetatable(object, subClass)
		local newMethod = rawget(subClass, "new")
		if newMethod then
			object = newMethod(object) or object
		end
	end
	return object
end

return module