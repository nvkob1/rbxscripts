local function createMobileToggleButton()
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui") or game:GetService("CoreGui")

-- Check if device is mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Remove existing button if it exists
local existingGui = playerGui:FindFirstChild("FluentToggleButton")
if existingGui then
 existingGui:Destroy()
end

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "FluentToggleButton"
ToggleGui.ResetOnSpawn = false
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.DisplayOrder = 999999

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(0.05, 0, 0.05, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
ToggleButton.Text = "UI"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.AutoButtonColor = true
ToggleButton.ZIndex = 9999
ToggleButton.Parent = ToggleGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.5, 0)
UICorner.Parent = ToggleButton

local dragging = false
local dragStart
local startPos

local function updateInput(input)
   local delta = input.Position - dragStart
   ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

ToggleButton.InputBegan:Connect(function(input)
   if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
       dragging = true
       dragStart = input.Position
       startPos = ToggleButton.Position
   end
end)

ToggleButton.InputEnded:Connect(function(input)
   if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
       dragging = false
   end
end)

UserInputService.InputChanged:Connect(function(input)
   if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
       updateInput(input)
   end
end)

ToggleButton.MouseButton1Click:Connect(function()
    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    task.delay(0.1, function()
        ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end)
    
    if isMobile then
        -- Mobile method - use getconnections
        local downEvent = { KeyCode = Enum.KeyCode.LeftControl, UserInputType = Enum.UserInputType.Keyboard, UserInputState = Enum.UserInputState.Begin }
        local upEvent = { KeyCode = Enum.KeyCode.LeftControl, UserInputType = Enum.UserInputType.Keyboard, UserInputState = Enum.UserInputState.End }
        
        for _, con in pairs(getconnections(UserInputService.InputBegan)) do 
            pcall(function() con.Function(downEvent) end)
        end
        
        task.delay(0.1, function()
            for _, con in pairs(getconnections(UserInputService.InputEnded)) do 
                pcall(function() con.Function(upEvent) end)
            end
        end)
    else
        -- PC method - direct key simulation
        keypress(0x11) -- Left Control key
        task.delay(0.1, function()
            keyrelease(0x11)
        end)
    end
end)

ToggleGui.Parent = playerGui
return ToggleGui
end

task.spawn(createMobileToggleButton)
