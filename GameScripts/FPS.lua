local module = {}
module.__type = "GameScript"

module.Scene = Instance.new("Scene", "FPSMenu")
module.Init = function()
    module.ShowFPS = true
    local goodFPS = Color.From255(0, 255, 0, 255)
	local okFPS = Color.From255(255, 255, 0, 255)
	local stinkyFPS = Color.From255(255, 0, 0, 255)
    
    local lastDeltaTime = 1/60
    local frames = {}
    
    local function DrawFrameCount(dt, x,y, s)
        local fps = math.floor(1/lastDeltaTime+0.5)
        if fps < 15 then
            stinkyFPS:Apply()
        elseif fps < 30 then
            okFPS:Apply()
        else
            goodFPS:Apply()
        end
        love.graphics.drawCustomText(tostring(fps), x,y,s)
    end

    module.Scene.Update:Connect(function(dt)
        local t = os.clock()
        for i = #frames, 1, -1 do
            if t - frames[i][1] > 1 then
                table.remove(frames, i)
            end
        end

        table.insert(frames, {t, dt})
    end)
    module.Scene.Draw:Connect(function()
        if module.ShowFPS then
            local lowestFrame = math.huge
            local highestFrame = -math.huge
            local currentFrame = frames[#frames]
            
            for i, v in ipairs(frames) do
                lowestFrame = math.min(lowestFrame, v[2])
                highestFrame = math.max(highestFrame, v[2])
            end

            DrawFrameCount(currentFrame, 20, 20, 1)
            DrawFrameCount(highestFrame, 20, 40, 1)
            DrawFrameCount(lowestFrame, 20, 60, 1)
		end
    end)
end

module.Start = function()
    
end

return module