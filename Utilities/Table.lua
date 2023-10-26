local module = {}

module.find = function(tbl, value)
	for i, v in pairs(tbl) do
		if v == value then
			return i
		end
	end
end

for i,v in pairs(table) do
	if not module[i] then
		module[i] = v
	end
end

return module