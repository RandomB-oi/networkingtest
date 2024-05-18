love.graphics.setDefaultFilter("nearest", "nearest")

RegularPrint = print

typeof = function(value)
	local t = type(value)
	if t == "table" then
		return value.__type or t
	end
	return t
end

lualzw = require("Utilities.lualzw")
local NetworkClientClass = require("NetworkingClient.Client")

ClassUtil = require("Utilities.ClassUtil")
string = require("Utilities.String")
math = require("Utilities.Math")
table = require("Utilities.Table")
Instance = require("Utilities.Instance")
Utilities, _utilitiesOrder = ClassUtil.RecurseRequire("Utilities")
ClassUtil.RecurseInit(Utilities, _utilitiesOrder)

Classes, _classOrder = ClassUtil.RecurseRequire("Classes")
ClassUtil.RecurseInit(Classes, _classOrder)

Signal = Classes.signal
Maid = Classes.maid
Vector = Classes.Vector
Color = Classes.Color
UDim = Classes.UDim
UDim2 = Classes.UDim2
NumberRange = Classes.NumberRange
ColorSequence = Classes.ColorSequence
NumberSequence = Classes.NumberSequence

LoveUpdate = Instance.new("Signal")
LoveDraw = Instance.new("Signal")

GuiInputBegan = Instance.new("Signal")
GuiInputEnded = Instance.new("Signal")
InputBegan = Instance.new("Signal")
InputEnded = Instance.new("Signal")

OutputMessage = Instance.new("Signal")

do
	local function cleanArgs(...)
		local args = {...}
		for i, v in pairs(args) do
			if type(v) ~= "string" then
				args[i] = tostring(v)
			end
		end
		return unpack(args)
	end
	function print(...)
		OutputMessage:Fire("p", cleanArgs(...))
	end
	function warn(...)
		OutputMessage:Fire("w", cleanArgs(...))
	end
	function error(...)
		local traceback = debug.traceback()
		OutputMessage:Fire("e", cleanArgs(..., traceback))
	end
end

function Serialize(value)
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
				serialized.v[index] = {colorValue[1], Serialize(colorValue[2])}
			end
		else
			serialized.v = value
		end
	end, warn)
	return serialized
end

function Deserialize(value)
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
			colors[i] = {v[1], Deserialize(v[2])}
		end
		return ColorSequence.new(colors)
	else
		return serialized
	end
end

ClassUtil.RecurseStart(Utilities, _utilitiesOrder)
ClassUtil.RecurseStart(Classes, _classOrder)

love.load = function()
	love.window.setMode(800, 600, {resizable = true})

    ServerCreated = Instance.new("Signal")
	ServerCreated:Connect(function(multiplayer, port, address)
		if multiplayer then
			NetworkClient = NetworkClientClass.new(address, port)
		else
			print("Playing singleplayer")
		end
	end)




	ServerCreated:Connect(function()
		Instance.new("Scene", "Menu"):Destroy()
		
		-- .new on scene returns the scene if one exists with that name
		local mainGameScene = Instance.new("Scene", "MainGame")
		mainGameScene:Enable()
		mainGameScene:Unpause()
	end)


	local function ForEachScene(callback)
		for _, scene in pairs(Instance.GetClass("Scene").All) do
			callback(scene)
		end
	end

	love.update = function(dt)
		LoveUpdate:Fire(dt)

		ForEachScene(function(scene)
			if scene.Enabled and not scene.IsPaused then
				scene.Update:Fire(dt)
			end
		end)
		
		if NetworkClient then
			NetworkClient:Tick()
		end
	end

	local mainShader = love.graphics.newShader("Shaders/TestShader/Pixel.glsl", "Shaders/TestShader/Vertex.glsl")

	love.draw = function()
		-- love.graphics.setShader(mainShader)
		-- mainShader:send("millis", love.timer.getTime())
		-- mainShader:send("screenSize", {love.graphics.getDimensions()})
		-- mainShader:send("saturation", 1)
		LoveDraw:Fire()

		ForEachScene(function(scene)
			if scene.Enabled then
				scene.Draw:Fire()
			end
		end)
		
		-- love.graphics.setShader(nil) -- should shaders be applied to the gui?

		ForEachScene(function(scene)
			if scene.Enabled then
				scene.GuiDraw:Fire()
			end
		end)
	end

	love.mouse.getVector = function()
		return Vector.new(love.mouse.getPosition())
	end

	love.keypressed = function(key)
		GuiInputBegan:Fire(key, false)
		InputBegan:Fire(key, false, _gameProcessedGobal)
		_gameProcessedGobal = false
	end
	love.keyreleased = function(key)
		GuiInputEnded:Fire(key, false)
		InputEnded:Fire(key, false, _gameProcessedGobal)
	end
	love.mousepressed = function(_,_,button)
		GuiInputBegan:Fire(button, true)
		InputBegan:Fire(button, true, _gameProcessedGobal)
		_gameProcessedGobal = false
	end
	love.mousereleased = function(_,_,button)
		GuiInputEnded:Fire(button, true)
		InputEnded:Fire(button, true, _gameProcessedGobal)
	end


	GameScripts, _gameScriptOrder = ClassUtil.RecurseRequire("GameScripts")
	ClassUtil.RecurseInit(GameScripts, _gameScriptOrder)
	ClassUtil.RecurseStart(GameScripts, _gameScriptOrder)
end