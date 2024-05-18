local module = {}
module.__index = module

local socket = require("socket")
local NetworkSignalClass = require("NetworkingClient.NetworkSignal")

module.new = function(address, port)
    local self = setmetatable({}, module)
    print("Playing multiplayer")
    print("Joining ip "..tostring(address).." on port "..tostring(port))

    self.IP = address
    self.Port = port

    self.NetworkTPS = 1/10
    self.LastNetworkTick = -math.huge

    self.UDP = socket.udp()
    self.UDP:settimeout(0)
    self.UDP:setpeername(address, port)

    self.DataRecived = NetworkSignalClass.new()

    self.DataToSend = {}

    self:Send("newClient")

    return self
end

function module:Send(message, parameters)
    table.insert(self.DataToSend, {job = message, data = parameters})
end

function module:Tick()
    local t = os.clock()
    if t - lastNetworkTick < self.NetworkTPS then return end
    lastNetworkTick = t

    for i = #self.DataToSend, 1, -1 do
        local message = "return "..getStr(self.DataToSend[i], nil, nil, true)
        local compressedMessage = "cmp"..lualzw.compress(message)
        self.UDP:send(compressedMessage)
    end
    self.DataToSend = {}

    local data = self.UDP:receive()
    if data then
        if data:sub(1,3) == "cmp" then
            data = lualzw.decompress(data:sub(4,-1))
        end
        if data == "connected" then
            print("CONNECTED TO SERVER WWWWWW")
            return
        elseif data == "gotData" then
            -- print("the server got our data")
            return
        end

        if data:sub(1, 6) ~= "return" then
            data = "return "..data
        end
        local dataToSend = getValue(data)
        self.DataRecived:Fire(dataToSend.job, dataToSend.data)
    end
end