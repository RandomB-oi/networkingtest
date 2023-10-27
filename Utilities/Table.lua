local module = {}

module.find = function(tbl, value)
	if not tbl then return end
	for i, v in pairs(tbl) do
		if v == value then
			return i
		end
	end
end

-- local regRemove = table.remove
-- module.remove = function(tbl, index)
-- 	if tbl then
-- 		regRemove(tbl, index)
-- 	end
-- end

for i,v in pairs(table) do
	if not module[i] then
		module[i] = v
	end
end

return module