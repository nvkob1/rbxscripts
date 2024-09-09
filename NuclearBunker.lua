local player = game.Players.LocalPlayer
local backpackGui = player:WaitForChild("PlayerGui"):WaitForChild("Backpack"):WaitForChild("ScrollingFrame")
local backpack = player:WaitForChild("Backpack")
local thirst = player:WaitForChild("Thirst")
local hunger = player:WaitForChild("Hunger")
local baseplate = workspace:FindFirstChild("Baseplate")
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local isEating = false -- To track if the player is currently eating

-- Create Debug GUI
local function createDebugGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local debugFrame = Instance.new("Frame")
    debugFrame.Size = UDim2.new(0, 300, 0, 150)
    debugFrame.Position = UDim2.new(0, 10, 0, 10)
    debugFrame.BackgroundTransparency = 0.5
    debugFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    debugFrame.Parent = screenGui

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 1, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextSize = 16
    infoLabel.Text = "Debug Info"
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.Parent = debugFrame

    return infoLabel
end

local debugInfoLabel = createDebugGUI()

-- Update Debug GUI
local function updateDebugGUI(action)
    local beansCount, bloxyColaCount = getBackpackItems()
    local backpackItemCount = getBackpackItemCount()

    debugInfoLabel.Text = string.format(
        "Backpack Items: %d\nBeans: %d\nBloxy Cola: %d\nThirst: %d\nHunger: %d\nCurrent Action: %s",
        backpackItemCount, beansCount, bloxyColaCount, thirst.Value, hunger.Value, action
    )
end

-- Enable noclip
local function noclip()
    local character = player.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end

RunService.Stepped:Connect(noclip)

-- Fire ProximityPrompt and look at item
local function fireproximityprompt(ProximityPrompt, Amount, Skip, part)
    assert(ProximityPrompt, "Argument #1 Missing or nil")
    assert(typeof(ProximityPrompt) == "Instance" and ProximityPrompt:IsA("ProximityPrompt"), "Attempted to fire a Value that is not a ProximityPrompt")

    local HoldDuration = ProximityPrompt.HoldDuration
    if Skip then
        ProximityPrompt.HoldDuration = 0
    end

    for i = 1, Amount or 1 do
        if part and part:IsA("BasePart") then
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = CFrame.new(camera.CFrame.Position, part.Position)
        end

        ProximityPrompt:InputHoldBegin()
        ProximityPrompt:InputHoldEnd()
    end

    ProximityPrompt.HoldDuration = HoldDuration
    camera.CameraType = Enum.CameraType.Custom -- Reset the camera
end

-- Count items in Backpack ScrollingFrame
local function getBackpackItemCount()
    local itemCount = 0
    for _, frame in pairs(backpackGui:GetChildren()) do
        if frame.Name == "Preset" then
            itemCount = itemCount + 1
        end
    end
    return itemCount
end

-- Teleport to a random part
local function teleportToRandomPart(partName)
    if getBackpackItemCount() >= 10 then
        return -- Do not pick up if backpack is full
    end

    local foodFolder = workspace:FindFirstChild("Food")
    if not foodFolder then
        warn("workspace.Food not found")
        return
    end

    local targetPart = foodFolder:FindFirstChild(partName)

    if targetPart and targetPart:IsA("BasePart") then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0) -- Teleport above the part

            for _, prompt in pairs(targetPart:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    fireproximityprompt(prompt, 1, true, targetPart) -- Fire the ProximityPrompt
                end
            end
        end
    else
        warn(partName .. " not found or is not a BasePart")
    end
end

-- Unequip everything and count items in backpack
local function getBackpackItems()
    local beansCount, bloxyColaCount = 0, 0
    player.Character.Humanoid:UnequipTools()

    for _, item in pairs(backpack:GetChildren()) do
        if item.Name == "Beans" then
            beansCount = beansCount + 1
        elseif item.Name == "Bloxy Cola" then
            bloxyColaCount = bloxyColaCount + 1
        end
    end

    return beansCount, bloxyColaCount
end

-- Collect food until there are 5 Beans and 5 Bloxy Cola
local function collectFood()
    if getBackpackItemCount() >= 10 then
        return -- Exit if backpack is full
    end

    local beansCount, bloxyColaCount = getBackpackItems()

    while beansCount < 5 do
        teleportToRandomPart("Beans")
        beansCount = beansCount + 1
        updateDebugGUI("Collecting Beans")
    end

    while bloxyColaCount < 5 do
        teleportToRandomPart("Bloxy Cola")
        bloxyColaCount = bloxyColaCount + 1
        updateDebugGUI("Collecting Bloxy Cola")
    end
end

-- Manage Hunger and Thirst
local function manageNeeds()
    if thirst.Value < 70 then
        local bloxyCola = backpack:FindFirstChild("Bloxy Cola")
        if bloxyCola then
            player.Character.Humanoid:EquipTool(bloxyCola)
            isEating = true
            updateDebugGUI("Drinking Bloxy Cola")
            bloxyCola:Activate()
            wait(5) -- Wait for drinking
            isEating = false
        end
    end

    if hunger.Value < 70 then
        local beans = backpack:FindFirstChild("Beans")
        if beans then
            player.Character.Humanoid:EquipTool(beans)
            isEating = true
            updateDebugGUI("Eating Beans")
            beans:Activate()
            wait(11) -- Wait for eating
            isEating = false
        end
    end
end

-- Freeze player and teleport
local function freezeAndSetBaseplate()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(-42, -43, 74)
        baseplate.Transparency = 0.5
        character.HumanoidRootPart.Anchored = true
        updateDebugGUI("Frozen")
    end
end

-- Main loop
while true do
    collectFood()
    manageNeeds()

    if isEating or getBackpackItemCount() == 10 then
        freezeAndSetBaseplate()
    end

    wait(0) -- No delay
end
