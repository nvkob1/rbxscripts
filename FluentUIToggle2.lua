-- UI Toggle with custom logo and larger, tap-friendly design
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
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

-- Increased size for easier mobile usage
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

-- Fetch and apply the requested logo
task.spawn(function()
    local success, response = pcall(function()
        return request({
            Url = "https://scriptblox.com/images/photo/62a46c5b3203c751aec2e7fe-1694938703252.png",
            Method = "GET"
        })
    end)
    
    if success and response and response.StatusCode == 200 then
        writefile("WaveLogo.png", response.Body)
        ToggleButton.Image = getcustomasset("WaveLogo.png")
    end
end)

local dragging, dragStart, startPos

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        
        -- Shrink slightly for visual feedback
        TweenService:Create(ToggleButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 60, 0, 60)}):Play()
    end
end)

ToggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        
        -- Restore size
        TweenService:Create(ToggleButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 65, 0, 65)}):Play()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        TweenService:Create(ToggleButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    if getgenv().Fluent and getgenv().Fluent.Window then
        getgenv().Fluent.Window:Minimize()
    end
end)
