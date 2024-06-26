local module = {}
module.__type = "GameScript"

module.Scene = Instance.new("Scene", "MainGame")
module.Init = function()
    module.Scene:Disable()
    module.Scene:Pause()

    localPlayer = Instance.new("Player", module.Scene, "Player_Name")
    localPlayer.GiveControls = true

    mainToolbar = Instance.new("Toolbar", module.Scene, localPlayer)

    local emitter = Instance.new("ParticleEmitter", module.Scene)
    emitter.Rate = 50
    emitter.Enabled = false

    emitter.ParticleSize = NumberSequence.new({{0,0}, {0.1,25}, {0.25, 20}, {.5,15}, {1,0}})
    emitter.Color = ColorSequence.new({
        -- {0, Color.new(1, 0, 0, 1)},
        -- {1, Color.new(1, 1, .4, 1)},
        
        {0, Color.new(0, 1, 1, 1)},
        {1, Color.new(0, 0, .6, 1)},
    })

    emitter.LifeTime = NumberRange.new(1, 3)
    emitter.Speed = NumberRange.new(20, 50)
    emitter.EmissionAngleRange = NumberRange.new(0, 0)

    emitter.Size = Vector.new(25, 25)
    emitter.Position = Vector.new(200, 200)

    localPlayer.Tools[1].Activated:Connect(function()
        emitter:Replicate("Emit", 50)
        emitter:Emit(50)
    end)
    
    module.Scene.Update:Connect(function()
        emitter.Position = love.mouse.getVector()
        emitter:Replicate("Position")
        emitter:Replicate("Rate")
        emitter:Replicate("Enabled")
        emitter:Replicate("ParticleSize")
        emitter:Replicate("Color")
        emitter:Replicate("LifeTime")
        emitter:Replicate("Speed")
        emitter:Replicate("EmissionAngleRange")
        emitter:Replicate("Size")
    end)
    -- local lastEmit = -math.huge
    -- module.Scene.Update:Connect(function()
    --     local t = os.clock()

    --     if t - lastEmit > 1 then
    --         lastEmit = t
    --         emitter:Emit(50)
    --     end
    -- end)
end

module.Start = function()
    
end

return module