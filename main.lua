RegularPrint = print

typeof = function(value)
	local t = type(value)
	if t == "table" then
		return value.__type or t
	end
	return t
end

local socket = require("socket")
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

NetworkDataRecieved = Instance.new("Signal")
NetworkDataSend = Instance.new("Signal")
local isHosting
local ip, port

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

ClassUtil.RecurseStart(Utilities, _utilitiesOrder)
ClassUtil.RecurseStart(Classes, _classOrder)

GameModeSelected = Instance.new("Signal")
MultiplayerModeSelected = Instance.new("Signal")

love.load = function()
    ServerCreated = Instance.new("Signal")
	local networkDataToSend, UDP
	ServerCreated:Connect(function(multiplayer, hosting, port, address)
		if multiplayer then
			print("Playing multiplayer")
			UDP = socket.udp()
			
			if hosting then
				isHosting = true
				print("Hosting on port "..tostring(port))
				UDP:setsockname("localhost", port)
			else
				print("Joining ip "..tostring(address).." on port "..tostring(port))
				UDP:setpeername(address, port)
			end
			UDP:settimeout(0)
		else
			print("Playing singleplayer")
		end
	end)

	NetworkDataSend:Connect(function(jobName, newData)
		if not networkDataToSend then
			networkDataToSend = {}
		end
		table.insert(networkDataToSend, {jobName = jobName, data = newData})
	end)


	ServerCreated:Connect(function()
		Instance.new("Scene", "Menu"):Destroy() -- .new on scene returns the scene if one exists with that name
		local mainGameScene = Instance.new("Scene", "MainGame")
		mainGameScene:Enable()
		mainGameScene:Unpause()
	end)
	-- self.Maid:GiveTask(LoveUpdate:Connect(function(dt)
	-- 	if self.Enabled and not self.IsPaused then
	-- 		self.Update:Fire(dt)
	-- 	end
	-- end))
	-- self.Maid:GiveTask(LoveDraw:Connect(function()
	-- 	if self.Enabled then
	-- 		self.Draw:Fire()
	-- 	end
	-- end))
	local networkTPS = 1/200
	local lastNetworkTick = -math.huge
	local function DoNetworking()
		local t = os.clock()
		if t - lastNetworkTick < networkTPS then return end
		lastNetworkTick = t

		if UDP then
			if isHosting then
				local data, msgOrIp, portOrNil = UDP:receivefrom()
				if data then
					local dataToSend = getValue(data)
					for i,v in ipairs(dataToSend) do
						NetworkDataRecieved:Fire(v.jobName, v.data)
					end

					if networkDataToSend then
						UDP:sendto("return "..getStr(networkDataToSend, nil, nil, true), msgOrIp, portOrNil)
					end
				end
			else
				if networkDataToSend then
					UDP:send("return "..getStr(networkDataToSend, nil, nil, true))
				end

				local data = UDP:receive()
				if data then
					local dataToSend = getValue(data)
					for i,v in ipairs(dataToSend) do
						NetworkDataRecieved:Fire(v.jobName, v.data)
					end
				end
			end
			networkDataToSend = nil
		end
	end

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
		
		DoNetworking()
	end

	love.draw = function()
		LoveDraw:Fire()

		ForEachScene(function(scene)
			if scene.Enabled then
				scene.GuiDraw:Fire()
			end
		end)
		ForEachScene(function(scene)
			if scene.Enabled then
				scene.Draw:Fire()
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