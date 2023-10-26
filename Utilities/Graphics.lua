love.graphics.cleanDrawText = function(textObject, renderPosition, renderSize, stretch, xAlign, yAlign)
	local textSize = Vector.new(textObject:getDimensions())
	local scale = renderSize / textSize
	local textRenderSize = renderSize
	if not stretch then
		local smallest = math.min(scale.X, scale.Y)
		local biggest = math.max(scale.X, scale.Y)
		scale.X, scale.Y = smallest, smallest
	end
	local textOffset = renderSize - textSize * scale
	if xAlign == "left" then
		textOffset.X = 0
	elseif xAlign == "center" then
		textOffset.X = textOffset.X/2
	elseif xAlign == "right" then
	end
	
	if yAlign == "top" then
		textOffset.Y = 0
	elseif yAlign == "center" then
		textOffset.Y = textOffset.Y/2
	elseif xAlign == "bottom" then
	end
	
	local pos = renderPosition + textOffset
	love.graphics.draw(textObject, pos.X, pos.Y, 0, scale.X, scale.Y)
end


love.graphics.cleanDrawImage = function(imageObject, renderPosition, renderSize)
	local imageSize = Vector.new(imageObject:getDimensions())
	local scale = renderSize / imageSize
	love.graphics.draw(imageObject, renderPosition.X, renderPosition.Y, 0, scale.X, scale.Y)
end

local originalNewImage = love.graphics.newImage
local cachedImages = {}
love.graphics.newImage = function(path)
	if cachedImages[path] then
		return cachedImages[path]
	end
	
	local image = originalNewImage(path)
	cachedImages[path] = image
	return image
end





local letterWidth, letterHeight = 6, 14
local spacing = 6
local line = love.graphics.line
local letters = {
	A = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		line(x - lw/2, y + lh/2, x, y - lh/2)
		line(x + lw/2, y + lh/2, x, y - lh/2)
		line(x-lw/4,y, x+lw/4,y)
	end,
	B = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
		line(x+lw/2, y+lh/2, x+lw/2, y+d)
		line(x+lw/2, y-lh/2, x+lw/2, y-d)
		line(x+lw/2-d, y, x+lw/2, y+d)
		line(x+lw/2-d, y, x+lw/2, y-d)
		line(x-lw/2, y, x+lw/2-d, y)
	end,
	C = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
	end,
	D = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2-d, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2-d, y+lh/2)
		line(x+lw/2, y+lh/2-d, x+lw/2, y-lh/2+d)
		line(x+lw/2-d, y-lh/2, x+lw/2, y-lh/2+d)
		line(x+lw/2-d, y+lh/2, x+lw/2, y+lh/2-d)
	end,
	E = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
		line(x-lw/2, y, x+lw/2-d, y)
	end,
	F = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y, x+lw/2-d, y)
	end,
	G = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
		line(x+lw/2, y+lh/2, x+lw/2, y+d)
		line(x, y+d, x+lw/2, y+d)
	end,
	H = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x-lw/2, y, x+lw/2, y)
		line(x+lw/2, y-lh/2, x+lw/2, y+lh/2)
	end,
	I = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
		line(x, y-lh/2, x, y+lh/2)
	end,
	J = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x, y+lh/2)
		line(x, y-lh/2, x, y+lh/2)
		line(x-lw/2, y+lh/2, x-lw/2, y+lh/2-d)
	end,
	K = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x-lw/2, y, x+lw/2, y-lh/2)
		line(x-lw/2, y, x+lw/2, y+lh/2)
	end,
	L = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
	end,
	M = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x+lw/2, y-lh/2, x+lw/2, y+lh/2)
		line(x, y-lh/2, x, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
	end,
	N = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x+lw/2, y-lh/2, x+lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y+lh/2)
	end,
	O = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x+lw/2, y-lh/2, x+lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
	end,
	P = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y, x+lw/2, y)
		line(x+lw/2, y-lh/2, x+lw/2, y)
	end,
	Q = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x+lw/2, y-lh/2, x+lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
		line(x, y+lh/2 - d, x+d, y+lh/2+d)
	end,
	R = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y, x+lw/2, y)
		line(x+lw/2, y-lh/2, x+lw/2, y)
		line(x-lw/2, y, x+lw/2, y+lh/2)
	end,
	S = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y)
		line(x+lw/2, y+lh/2, x+lw/2, y)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
		line(x-lw/2, y, x+lw/2, y)
	end,
	T = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x, y-lh/2, x, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
	end,
	U = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x+lw/2, y-lh/2, x+lw/2, y+lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
	end,
	V = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x, y+lh/2)
		line(x+lw/2, y-lh/2, x, y+lh/2)
	end,
	W = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x+lw/2, y-lh/2, x+lw/2, y+lh/2)
		line(x, y-lh/2, x, y+lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
	end,
	X = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x+lw/2, y+lh/2)
		line(x+lw/2, y-lh/2, x-lw/2, y+lh/2)
	end,
	Y = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x, y)
		line(x+lw/2, y-lh/2, x, y)
		line(x, y, x, y+lh/2)
	end,
	Z = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y-lh/2)
	end,
	["1"] = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x, y-lh/2, x-lw/2, y-lh/2+d)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
		line(x, y-lh/2, x, y+lh/2)
	end,
	["2"] = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-d, x-lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x+lw/2, y-lh/2, x+lw/2, y)
	end,
	["3"] = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
		line(x+lw/2, y+lh/2, x+lw/2, y+d)
		line(x+lw/2, y-lh/2, x+lw/2, y-d)
		line(x+lw/2-d, y, x+lw/2, y+d)
		line(x+lw/2-d, y, x+lw/2, y-d)
		line(x-lw/2+d, y, x+lw/2-d, y)
	end,
	["4"] = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x+lw/2, y-lh/2, x+lw/2, y+lh/2)
		--line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y, x+lw/2, y)
		line(x-lw/2, y-lh/2, x-lw/2, y)
	end,
	["5"] = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y-d)
		line(x+lw/2, y+lh/2, x+lw/2, y-d)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
		line(x-lw/2, y-d, x+lw/2, y-d)
	end,
	["6"] = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y)
		line(x+lw/2, y+lh/2, x+lw/2, y)
		line(x-lw/2, y+lh/2, x-lw/2, y)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
		line(x-lw/2, y, x+lw/2, y)
	end,
	["7"] = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x+lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
	end,
	["8"] = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		--line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
		line(x+lw/2, y+lh/2, x+lw/2, y+d)
		line(x+lw/2, y-lh/2, x+lw/2, y-d)
		line(x-lw/2, y+lh/2, x-lw/2, y+d)
		line(x-lw/2, y-lh/2, x-lw/2, y-d)
		line(x+lw/2-d, y, x+lw/2, y+d)
		line(x+lw/2-d, y, x+lw/2, y-d)
		line(x-lw/2+d, y, x-lw/2, y+d)
		line(x-lw/2+d, y, x-lw/2, y-d)
		line(x-lw/2+d, y, x+lw/2-d, y)
	end,
	["9"] = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x+lw/2, y-lh/2, x+lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y, x+lw/2, y)
		line(x-lw/2, y-lh/2, x-lw/2, y)
	end,
	["0"] = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y-lh/2, x-lw/2, y+lh/2)
		line(x+lw/2, y-lh/2, x+lw/2, y+lh/2)
		line(x-lw/2, y-lh/2, x+lw/2, y-lh/2)
		line(x-lw/2, y+lh/2, x+lw/2, y+lh/2)
		line(x, y-d, x, y+d)
	end,
	[" "] = function(x,y,s)

	end,
	["/"] = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-lw/2, y+lh/2, x+lw/2, y-lh/2)
	end,
	["-"] = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-d, y, x+d, y)
	end,
	[":"] = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = love.graphics.getLineWidth() * s * 3
		love.graphics.circle("fill", x,y - lh / 2 + d, d/2)
		love.graphics.circle("fill", x,y + lh / 2 - d, d/2)
	end,
	["+"] = function(x,y,s)
		local lh,lw = letterHeight * s, letterWidth * s
		local d = 3 * s
		line(x-d, y, x+d, y)
		line(x, y-d, x, y+d)
	end,
}

love.graphics.drawCustomLetter = function(char,x,y,scale)
	if letters[char:upper()] then
		letters[char:upper()](x,y,scale)
	end
end

love.graphics.drawCustomText = function(text, x,y,scale, allignment)
	text = tostring(text)
	local X
	local textWidth = ((text:len()+1) * letterWidth * scale)*2
	if not allignment or allignment == "center" then
		X = x-textWidth/2
	elseif allignment == "right" then
		X = x-textWidth
	elseif allignment == "left" then
		X = x
	end
	
	for i = 1, text:len() do
		local v = text:sub(i,i)
		love.graphics.drawCustomLetter(v, X + i * (letterWidth+spacing) * scale, y, scale)
	end
end



return {}