local module = {}
module.__index = module
module.__type = "ParticleEmitter"

module.All = {}

module.new = function(scene, id)
	local self = setmetatable({}, module)
	self.Maid = Instance.new("Maid")
	self.Scene = scene

    self.Enabled = true
    self.Rate = 20

    -- particle properties 
    ---------------------------------------   
    self.ParticleSize = NumberSequence.new({{0,10}, {1,10}})
    self.Color = ColorSequence.new()

    self.LifeTime = NumberRange.new(1, 3)
    self.Speed = NumberRange.new(20, 100)
    self.EmissionAngleRange = NumberRange.new(0, 0)

    self.Size = Vector.new(100, 100)
    self.Position = Vector.new(0, 0)
    ---------------------------------------
    
    self.Particles = {}
    self.LastEmit = -math.huge

	self.ID = id or GenerateGUID()
    module.All[self.ID] = self
    self.Maid:GiveTask(function()
        module.All[self.ID] = nil
    end)
	
	self.Maid:GiveTask(scene.Update:Connect(function(dt)
		self:StepParticles(dt)
	end))
	self.Maid:GiveTask(scene.Draw:Connect(function()
		self:Draw()
	end))
	
	return self
end

function module:Emit(amount)
    local sizeRange = self.Size/2
    for i = 1, (amount or 1) do
        local newParticle = {
            Position = self.Position + Vector.new(math.random(-sizeRange.X, sizeRange.X), math.random(-sizeRange.Y, sizeRange.Y)),
            ExpectedLifeTime = self.LifeTime:GetValue(),
            Speed = self.Speed:GetValue(),
            EmissionDirection = Vector.FromAngle(math.rad(self.EmissionAngleRange:GetValue()));
            LifeTime = 0,
        }
        table.insert(self.Particles, newParticle)
    end
end

function module:StepParticles(dt)
    local t = os.clock()
    if self.Enabled and t - self.LastEmit > 1/self.Rate then
        self.LastEmit = t
        self:Emit()
    end
    for i = #self.Particles, 1, -1 do
        local particle = self.Particles[i]

        particle.LifeTime = particle.LifeTime + dt
        if particle.LifeTime >= particle.ExpectedLifeTime then
            table.remove(self.Particles, i)
        else
            particle.Position = particle.Position + particle.EmissionDirection*particle.Speed*dt
        end
    end
end

function module:Draw()
    for i, particle in ipairs(self.Particles) do
        local lifeTimeAlpha = particle.LifeTime/particle.ExpectedLifeTime

        local size = self.ParticleSize:GetValue(lifeTimeAlpha)
        local color = self.Color:GetValue(lifeTimeAlpha)
        color:Apply()

        love.graphics.rectangle("fill", particle.Position.X-size/2, particle.Position.Y-size/2, size, size)
    end
end

function module:Destroy()
	self.Destroying:Fire()
	self.Maid:Destroy()
end

function module.Get(id)
	return module.All[id]
end

function module:__tostring()
    return self.__type.." "..self.ID
end

module.Init = function()
	Instance.AddClass(module.__type, module)
end

return module