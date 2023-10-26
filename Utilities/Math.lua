local module = {}

module.round = function(x)
	return math.floor(x+0.5)
end

module.clamp = function(x, min, max)
	if x > max then return max end
	if x < min then return min end
	return x
end

module.lerp = function(a,b,x)
	return (b-a)*x + a
end

module.sign = function(x)
	return x < 0 and -1 or x > 0 and 1 or 0
end

for i,v in pairs(math) do
	if not module[i] then
		module[i] = v
	end
end

return module