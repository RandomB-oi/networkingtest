local module = {}

module.split = function(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

for i,v in pairs(string) do
	if not module[i] then
		module[i] = v
	end
end

return module