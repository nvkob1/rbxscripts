local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local hiddenUI = gethui and gethui() or CoreGui
local existingGui = hiddenUI:FindFirstChild("FluentToggleButton")
if existingGui then 
    existingGui:Destroy() 
end

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "FluentToggleButton"
ToggleGui.ResetOnSpawn = false
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.DisplayOrder = 999999
ToggleGui.Parent = hiddenUI

local ToggleButton = Instance.new("ImageButton")
ToggleButton.Size = UDim2.new(0, 65, 0, 65) 
ToggleButton.Position = UDim2.new(0.05, 0, 0.05, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.AutoButtonColor = false
ToggleButton.ScaleType = Enum.ScaleType.Fit
ToggleButton.Parent = ToggleGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.5, 0)
UICorner.Parent = ToggleButton

task.spawn(function()
    local success, response = pcall(function()
        return request({
            Url = "https://scriptblox.com/images/photo/62a46c5b3203c751aec2e7fe-1694938703252.png",
            Method = "GET"
        })
    end)
    
    if success and response and response.StatusCode == 200 then
        writefile("nvkob1.png", response.Body)
        ToggleButton.Image = getcustomasset("nvkob1.png")
    end
end)

local dragging = false
local dragInput, dragStart, startPos
local hasDragged = false

local function update(input)
    local delta = input.Position - dragStart
    if delta.Magnitude > 5 then
        hasDragged = true
    end
    ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        hasDragged = false
        dragStart = input.Position
        startPos = ToggleButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

ToggleButton.Activated:Connect(function()
    if not hasDragged then
        if getgenv().Fluent and getgenv().Fluent.Window then
            getgenv().Fluent.Window:Minimize()
        end
    end
end)
