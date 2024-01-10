local module = {}
module.__type = "GameScript"

module.Scene = Instance.new("Scene", "Console")
module.Init = function()
    local maxOutputMessages = 20
    local outputMessages = {}
    local outputSerial = 0

    module.Scene:Disable()
    module.Scene:Unpause()
    local frame = Instance.new("Frame", module.Scene)
    frame.Size = UDim2.new(1, -12, 1, -12)
    frame.Position = UDim2.FromScale(0.5, 0.5)
    frame.AnchorPoint = Vector.new(0.5, 0.5)
    frame.Color = Color.From255(0, 0, 0, 100)

    local list = Instance.new("Frame", module.Scene)
    list.Parent = frame
    list.Size = UDim2.new(1, 0, 1, -25)
    list.Position = UDim2.FromScale(0.5, 1)
    list.AnchorPoint = Vector.new(0.5, 1)
    list.Color = Color.From255(0, 0, 0, 0)

    local clearOutput = Instance.new("Frame", module.Scene)
    clearOutput.Parent = frame
    clearOutput.Size = UDim2.FromOffset(50, 25)
    clearOutput.Position = UDim2.FromScale(1, 0)
    clearOutput.AnchorPoint = Vector.new(1, 0)
    clearOutput.Color = Color.From255(255, 0, 0)
    
    local clearTextLabel = Instance.new("TextLabel", module.Scene)
    clearTextLabel.Parent = clearOutput
    clearTextLabel.Size = UDim2.new(1, -4, 1, -4)
    clearTextLabel.Position = UDim2.FromScale(0.5, 0.5)
    clearTextLabel.AnchorPoint = Vector.new(0.5, 0.5)
    clearTextLabel:SetText("Clear")

    local function resetOutput()
        outputSerial = 0
        for i,v in ipairs(outputMessages) do
            v:SetText("")
        end
    end

    clearOutput.Clicked:Connect(resetOutput)

    for i = 1, maxOutputMessages do
        local newLabel = Instance.new("TextLabel", module.Scene)
        newLabel.Parent = list
        newLabel.Size = UDim2.new(1, 0, 1/maxOutputMessages, 0)
        newLabel.Position = UDim2.FromScale(0.5, (i-1)/maxOutputMessages)
        newLabel.AnchorPoint = Vector.new(0.5, 0)
        newLabel.XAlign = "left"
        newLabel:SetText("")
        table.insert(outputMessages, newLabel)
    end
    resetOutput()

    module.Scene.Maid:GiveTask(module.Scene.InputBegan:Connect(function(input)
        if input == "f9" or input == "f1" then
            module.Scene.Enabled = not module.Scene.Enabled
        end
    end))

    module.Scene.Maid:GiveTask(OutputMessage:Connect(function(outputType, ...)
        local textColor
        if outputType == "e" then
            textColor = Color.From255(255, 25, 25)
        elseif outputType == "w" then
            textColor = Color.From255(255, 170, 0)
        elseif outputType == "p" then
            textColor = Color.From255(220, 220, 220)
        else
            textColor = Color.From255(100, 100, 100)
        end
        outputSerial = outputSerial + 1
        if outputSerial > maxOutputMessages then
            resetOutput()
            outputSerial = 1
        end

        local newStr = table.concat({...}, " ")
        local messages = string.split(newStr, "\n")

        if #messages > 1 then
            for i,v in ipairs(messages) do
                outputMessage:Fire(outputType, v)
            end
            return
        end
        
        local label = outputMessages[outputSerial]
        label:SetText(newStr)
        label.Color = textColor
    end))
end

module.Start = function()
    
end

return module