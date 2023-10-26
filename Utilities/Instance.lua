local instanceList = {}
local module = {}

function module.new(classname, ...)
	local class = module.GetClass(classname)
	if class then
		return ClassUtil.new(class, ...)
	end
	print(classname, "does not exist", debug.traceback())
end

function module.AddClass(name, class)
	class.ClassName = name
	instanceList[name] = class
end

function module.GetClass(name)
	return instanceList[name]
end

return module