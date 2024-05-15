local module = {}
module.__type = "GameScript"

module.Scene = Instance.new("Scene", "Menu")
module.Init = function()
    module.Scene:Enable()
    module.Scene:Unpause()

    function module.CreateMenu(buttonsToCreate, deleteAfterClick)
        local buttonParent = Instance.new("Frame", module.Scene)
        buttonParent.Size = UDim2.new(.5, -12, 1, -12)
        buttonParent.Position = UDim2.FromScale(0.5, 0.5)
        buttonParent.AnchorPoint = Vector.new(0.5, 0.5)
        buttonParent.Color = Color.new(1,1,1,0.5)

        local buttons = {}
        local buttonAmount = 0
        for _ in pairs(buttonsToCreate) do
            buttonAmount = buttonAmount + 1
        end

        local buttonSize = 1/buttonAmount
        local index = 0
        for buttonName, callback in pairs(buttonsToCreate) do
            local newButton = Instance.new("Frame", module.Scene)
            newButton.Size = UDim2.new(1, -12, buttonSize, -6)
            newButton.Position = UDim2.new(0, 6, index * buttonSize, 6)
            newButton.AnchorPoint = Vector.new(0, 0)
            newButton.Color = Color.new(1, 1, 1)
            newButton.Parent = buttonParent
            
            newButton.Clicked:Connect(function()
                xpcall(callback, warn)
                if deleteAfterClick then
                    buttonParent:Destroy()
                end
            end)
            
            local textLabel = Instance.new("TextLabel", module.Scene)
            textLabel:SetText(buttonName)
            textLabel.Color = Color.new(0, 0, 0)
            textLabel.Size = UDim2.new(1, -12, 1, -12)
            textLabel.Parent = newButton
            
            index = index + 1
            if index == buttonAmount then
                newButton.Size.Y.Offset = -12
            end
        end

        return buttonParent, buttons
    end
end

local function newCheckbox(text)
    local frame = Instance.new("Frame", module.Scene)
    frame.Size = UDim2.new(1, -12, 0, 50)
    frame.Color = Color.new(0,0,0,0)

    local multiplayerCheckbox = Instance.new("Checkbox", module.Scene)
    multiplayerCheckbox.Size = UDim2.new(0, 38, 0, 38)
    multiplayerCheckbox.Position = UDim2.new(0, 6, 0, 6)
    multiplayerCheckbox.Parent = frame
    local multiplayerLabel = Instance.new("TextLabel", module.Scene)
    multiplayerLabel.Size = UDim2.new(1, -42, 1, -12)
    multiplayerLabel.Position = UDim2.new(0, 42, 0, 6)
    multiplayerLabel.Parent = frame
    multiplayerLabel:SetText(text)

    return frame, multiplayerCheckbox
end

local function newInputBox(text)
    local frame = Instance.new("Frame", module.Scene)
    frame.Size = UDim2.new(1, -12, 0, 50)
    frame.Color = Color.new(0,0,0,0)

    local backdrop = Instance.new("Frame", module.Scene)
    backdrop.Size = UDim2.new(0.75, -6, 1, -12)
    backdrop.Position = UDim2.new(0.25, 6, 0, 6)
    backdrop.Color = Color.new(0,0,0,0.5)
    backdrop.Parent = frame
    backdrop.ZIndex = 0
    local inputBox = Instance.new("TextBox", module.Scene)
    inputBox.Size = UDim2.new(0.75, -6, 1, -12)
    inputBox.Position = UDim2.new(0.25, 6, 0, 6)
    inputBox:SetText("")
    inputBox.Parent = frame
    inputBox.ZIndex = 2
    local multiplayerLabel = Instance.new("TextLabel", module.Scene)
    multiplayerLabel.Size = UDim2.new(0.25, -6, 0, 38)
    multiplayerLabel.Position = UDim2.new(0, 6, 0, 6)
    multiplayerLabel.Parent = frame
    multiplayerLabel:SetText(text)

    return frame, inputBox
end

module.Start = function()

    local menu = Instance.new("Frame", module.Scene)
    menu.Size = UDim2.new(.5, -12, 1, -12)
    menu.Position = UDim2.FromScale(0.5, 0.5)
    menu.AnchorPoint = Vector.new(0.5, 0.5)
    menu.Color = Color.new(1,1,1,0.5)

    local multiplayerCheckboxFrame, multiplayerCheckbox = newCheckbox("Multiplayer")
    multiplayerCheckboxFrame.Position = UDim2.new(0, 0, 0, 0)
    multiplayerCheckboxFrame.Parent = menu

    local portFrame, portBox = newInputBox("Port")
    portFrame.Position = UDim2.new(0, 0, 0, 50)
    portFrame.Active = false
    portFrame.Parent = menu

    local addressFrame, addressBox = newInputBox("Address")
    addressFrame.Position = UDim2.new(0, 0, 0, 100)
    addressFrame.Active = false
    addressFrame.Parent = menu

    multiplayerCheckbox.ValueChanged:Connect(function(newValue)
        portFrame.Active = newValue
        addressFrame.Active = newValue
    end)

    local playButton = Instance.new("TextFrame", module.Scene)
    playButton.Position = UDim2.new(0, 6, 1, -6)
    playButton.Size = UDim2.new(1, -12, 0.25, -6)
    playButton.AnchorPoint = Vector.new(0, 1)
    playButton.BackgroundColor = Color.new(1,1,1, 1)
    playButton:SetText("PLAY")
    playButton.Parent = menu

    playButton.Clicked:Connect(function()
        menu:Destroy()
        -- ServerCreated:Fire(multiplayerCheckbox.Value, portBox.CurrentText, addressBox.CurrentText)
        
        ServerCreated:Fire(multiplayerCheckbox.Value, "8080", "localhost")
    end)
end

return module