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

LoveUpdate = Instance.new("Signal")
LoveDraw = Instance.new("Signal")

GuiInputBegan = Instance.new("Signal")
GuiInputEnded = Instance.new("Signal")
InputBegan = Instance.new("Signal")
InputEnded = Instance.new("Signal")

NetworkDataRecieved = Instance.new("Signal")
NetworkDataSend = Instance.new("Signal")
local isHosting
local ip, port

ClassUtil.RecurseStart(Utilities, _utilitiesOrder)
ClassUtil.RecurseStart(Classes, _classOrder)

GameModeSelected = Instance.new("Signal")
MultiplayerModeSelected = Instance.new("Signal")

love.load = function()
    ServerCreated = Instance.new("Signal")
	local networkDataToSend, UDP
	ServerCreated:Connect(function(multiplayer, hosting, port, address)
		if multiplayer then
			UDP = socket.udp()
			UDP:settimeout(0)
			
			if hosting then
				isHosting = true
				UDP:setsockname("localhost", port)
			else
				UDP:setpeername(address, port)
			end
		end
	end)

	NetworkDataSend:Connect(function(jobName, newData)
		if not networkDataToSend then
			networkDataToSend = {}
		end
		table.insert(networkDataToSend, getStr({jobName = jobName, data = newData}))
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

		if networkDataToSend and UDP then
			if isHosting then
				local data, msgOrIp, portOrNil = UDP:recievefrom()
				if data then
					local dataToSend = getValue(data)
					for i,v in ipairs(dataToSend) do
						NetworkDataRecieved:Fire(v.jobName, v.data)
					end

					UDP:sendto(getStr(networkDataToSend))
				end
			else
				UDP:send(getStr(networkDataToSend))

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