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

LoveUpdate = Instance.new("Signal")
LoveDraw = Instance.new("Signal")
NetworkDataRecieved = Instance.new("Signal")
NetworkDataSend = Instance.new("Signal")


ClassUtil.RecurseStart(Utilities, _utilitiesOrder)

ClassUtil.RecurseStart(Classes, _classOrder)

local networkDataToSend do -- the magic man of magic
	local function askQuestion(question)
		RegularPrint(question)
		return io.read() or ""
	end

	if askQuestion("[M]ultiplayer or [S]ingleplayer"):lower() == "m" then
		UDP = socket.udp()
		UDP:settimeout(0)

		if askQuestion("Are you hosting? [y/n]"):lower() == "y" then
			local port = askQuestion("On what port?")
			UDP:setsockname("*", port)
		else
			local address = askQuestion("What's the ip?")
			local port = askQuestion("What's the port?")
			RegularPrint(address, port)
			UDP:setpeername(address, port)
		end
	end

	NetworkDataSend:Connect(function(jobName, newData)
		if networkDataToSend then
			networkDataToSend = {}
		end
		table.insert(networkDataToSend, getStr({jobName = jobName, data = newData}))
	end)
end

love.update = function(dt)
	LoveUpdate:Fire(dt)

	if networkDataToSend and UDP then
		local data, msgOrIp, portOrNil = UDP:recievefrom()
		if data then
			local dataToSend = getValue(data)
			for i,v in ipairs(dataToSend) do
				NetworkDataRecieved:Fire(v.jobName, v.data)
			end

			UDP:sendto(getStr(networkDataToSend))
		end
		networkDataToSend = nil
	end
end

love.draw = function()
	LoveDraw:Fire()
end

local localPlayer = Instance.new("Player")

LoveUpdate:Connect(function(dt)
	local leftPressed = love.keyboard.isDown("a") and 1 or 0
	local rightPressed = love.keyboard.isDown("d") and 1 or 0
	local upPressed = love.keyboard.isDown("w") and 1 or 0
	local downPressed = love.keyboard.isDown("s") and 1 or 0

	local xDir = (rightPressed - leftPressed) * 100 * dt
	local yDir = (downPressed - upPressed) * 100 * dt

	localPlayer.Position.X = localPlayer.Position.X + xDir
	localPlayer.Position.Y = localPlayer.Position.Y + yDir

	NetworkDataSend:Fire("plrData", {
		pos = {localPlayer.Position.X, localPlayer.Position.Y},
		size = {localPlayer.Size.X, localPlayer.Size.Y},
		id = localPlayer.ID,
	})
end)