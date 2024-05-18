local module = {}

function module.Encode(value)
	local t = typeof(value)
	local serialized = {
		t = t,
		v = nil
	}
	xpcall(function()
		if t == "Vector" then
			serialized.v = {value.X, value.Y}
		elseif t == "Color" then
			serialized.v = {value.R, value.G, value.B, value.A}
		elseif t == "UDim2" then
			serialized.v = {value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset}
		elseif t == "UDim" then
			serialized.v = {value.Scale, value.Offset}
		elseif t == "NumberRange" then
			serialized.v = {value.Min, value.Max, value.Resolution}
		elseif t == "NumberSequence" then
			serialized.v = value.Numbers
		elseif t == "ColorSequence" then
			serialized.v = {}
			for index, colorValue in pairs(value.Colors) do
				serialized.v[index] = {colorValue[1], module.Encode(colorValue[2])}
			end
		else
			serialized.v = value
		end
	end, warn)
	return serialized
end

function module.Decode(value)
	local t = value.t
	local serialized = value.v

	if t == "Vector" then
		return Vector.new(serialized[1], serialized[2])
	elseif t == "Color" then
		return Color.new(serialized[1], serialized[2], serialized[3], serialized[4])
	elseif t == "UDim2" then
		return UDim2.new(serialized[1], serialized[2], serialized[3], serialized[4])
	elseif t == "UDim" then
		return UDim.new(serialized[1], serialized[2])
	elseif t == "NumberRange" then
		return NumberRange.new(serialized[1], serialized[2], serialized[3])
	elseif t == "NumberSequence" then
		return NumberSequence.new(serialized)
	elseif t == "ColorSequence" then
		local colors = {}
		for i, v in pairs(serialized) do
			colors[i] = {v[1], module.Decode(v[2])}
		end
		return ColorSequence.new(colors)
	else
		return serialized
	end
end

return module