local module = {}
module.__type = "GameScript"

module.Scene = Instance.new("Scene", "MainGame")
module.Init = function()
    module.Scene:Disable()
    module.Scene:Pause()

    localPlayer = Instance.new("Player", module.Scene, "Player_Name")
    localPlayer.GiveControls = true
end

module.Start = function()
    
end

return module