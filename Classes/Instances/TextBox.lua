local module = {}
module.__index = module
module.__type = "TextBox"
module.Derives = "Classes/Instances/TextLabel"

defaultFont = love.graphics.newFont(64,"normal")

local upperReplace = {
    ["1"] = "!",
    ["2"] = "@",
    ["3"] = "#",
    ["4"] = "$",
    ["5"] = "%",
    ["6"] = "^",
    ["7"] = "&",
    ["8"] = "*",
    ["9"] = "(",
    ["0"] = ")",
    ["["] = "{",
    ["]"] = "}",
    [";"] = ":",
    ["'"] = '"',
    [","] = "<",
    ["."] = ">",
    ["/"] = "?",
    ["-"] = "_",
    ["="] = "+",
    ["`"] = "~",
}

module.new = function(self)
	self.Clicked:Connect(function()
        self.Scene.Maid.TextboxInputBegan = self.Scene.GuiInputBegan:Connect(function(key, isMouse)
            if isMouse and key == 1 and not self:IsHovering() then
                print("release datt focus")
                self:ReleaseFocus()
                return
            end
            if isMouse then return end

            if key == "return" then
                self:ReleaseFocus()
                return
            elseif key == "backspace" then
                self:SetText(self.CurrentText:sub(1, self.CurrentText:len()-1))
            elseif key == "lctrl" or key == "rctrl" or key == "lshift" or key == "rshift" then

            else
                if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
                    key = upperReplace[key] or key:upper()
                end
                self:SetText(self.CurrentText..key)
            end
            return
        end, 1)
    end, 2)
	
	return self
end

function module:ReleaseFocus()
    self.Scene.Maid.TextboxInputBegan = nil
end

module.Init = function()
	Instance.AddClass(module.__type, module)
end

module.Start = function()
    newFocus = Instance.new("Signal")
end

return module