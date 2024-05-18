local module = {}
module.__index = module

local ENet = require("enet")
local NetworkSignalClass = require("NetworkingClient.NetworkSignal")
local lualzw = require("NetworkingClient.lualzw")

local Transformer = require("NetworkingClient.DataTransformer")

module.new = function()
    local self = setmetatable({}, module)

    self.IP = nil
    self.Port = nil
    self.ServerIdentity = nil
    self.DataSeparator = "/-/"

    self.Host = ENet.host_create()

    self.NetworkTPS = -1--1/10
    self.LastNetworkTick = -math.huge

    self.DataRecived = NetworkSignalClass.new()

    return self
end

function module:Join(address, port)
    print("Playing multiplayer")
    print("Joining ip "..tostring(address).." on port "..tostring(port))

    self.IP = address
    self.Port = port
    self.ServerIdentity = tostring(self.IP)..":"..tostring(self.Port)
    self.Server = self.Host:connect(self.ServerIdentity)
    self:Send("newClient")
end

function module:Send(jobName, jobData)
    local data = {n=jobName, d=jobData}
    local message = Transformer.Save(data)
    local compressed = "cmp"..lualzw.compress(message)

    self.Host:service(100)
	self.Server:send(compressed)
end

function module:SendMessage(message)
    self.Host:service(100)
	self.Server:send(message)
end

function module:Tick()
    if not self.Server then return end
    local t = os.clock()
    if t - self.LastNetworkTick < self.NetworkTPS then return end
    self.LastNetworkTick = t

    local event = self.Host:service(100)
    while event do
        if event.type == "receive" then
            local message = event.data
            if message:sub(1,3) == "cmp" then
                message = message:sub(4,-1)
                message = lualzw.decompress(message)
                message = Transformer.Load(message)
                self.DataRecived:Fire(message.n, message.d)
            else
                self.DataRecived:Fire("unknown", message)
            end

        elseif event.type == "connect" then
            print(event.peer, "connected.")
        elseif event.type == "disconnect" then
            print(event.peer, "disconnected.")
            love.event.quit()
        end
        event = self.Host:service()
    end
end

return module