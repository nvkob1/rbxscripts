local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local backpackUI = playerGui:WaitForChild("Backpack")
local scrollingFrame = backpackUI:WaitForChild("ScrollingFrame")
local thirst = player:WaitForChild("Thirst")
local hunger = player:WaitForChild("Hunger")
local baseplate = workspace:FindFirstChild("Baseplate")
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

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

-- Connect the noclip function to the RunService
RunService.Stepped:Connect(noclip)

-- Function to count the number of items in the backpack by counting "preset" frames
local function getBackpackItemCount()
    local presets = scrollingFrame:GetChildren()
    local count = 0
    for _, frame in pairs(presets) do
        if frame.Name == "preset" then
            count = count + 1
        end
    end
    return count
end

-- Function to fire ProximityPrompt and adjust camera to look at the item
local function fireproximityprompt(ProximityPrompt, Amount, Skip, part)
    assert(ProximityPrompt, "Argument #1 Missing or nil")
    assert(typeof(ProximityPrompt) == "Instance" and ProximityPrompt:IsA("ProximityPrompt"), "Attempted to fire a Value that is not a ProximityPrompt")

    local HoldDuration = ProximityPrompt.HoldDuration
    if Skip then
        ProximityPrompt.HoldDuration = 0
    end

    for i = 1, Amount or 1 do
        -- Make the camera look at the item
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

-- Function to teleport to a random part
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

            -- Fire all ProximityPrompts in the part and make the camera look at the item
            for _, prompt in pairs(targetPart:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    fireproximityprompt(prompt, 1, true, targetPart) -- Fire the ProximityPrompt and look at the item
                end
            end
        end
    else
        warn(partName .. " not found or is not a BasePart")
    end
end

-- Function to check and collect food until there are 5 Beans and 5 Bloxy Cola
local function collectFood()
    if getBackpackItemCount() >= 10 then
        return -- Exit the function if the backpack is full
    end

    local beansCount, bloxyColaCount = 0, 0

    for _, frame in pairs(scrollingFrame:GetChildren()) do
        if frame.Name == "preset" then
            if frame:FindFirstChild("ItemName").Text == "Beans" then
                beansCount = beansCount + 1
            elseif frame:FindFirstChild("ItemName").Text == "Bloxy Cola" then
                bloxyColaCount = bloxyColaCount + 1
            end
        end
    end

    -- Collect Beans until 5
    while beansCount < 5 do
        teleportToRandomPart("Beans")
        beansCount = beansCount + 1
    end

    -- Collect Bloxy Cola until 5
    while bloxyColaCount < 5 do
        teleportToRandomPart("Bloxy Cola")
        bloxyColaCount = bloxyColaCount + 1
    end
end

-- Function to use food when thirst or hunger is below 70, and eat only one item
local function manageNeeds()
    if thirst.Value < 70 then
        for _, frame in pairs(scrollingFrame:GetChildren()) do
            if frame.Name == "preset" and frame:FindFirstChild("ItemName").Text == "Bloxy Cola" then
                player.Character.Humanoid:EquipTool(player.Backpack:FindFirstChild("Bloxy Cola"))
                player.Backpack["Bloxy Cola"]:Activate() -- Click on screen to use the item once
                break
            end
        end
    end

    if hunger.Value < 70 then
        for _, frame in pairs(scrollingFrame:GetChildren()) do
            if frame.Name == "preset" and frame:FindFirstChild("ItemName").Text == "Beans" then
                player.Character.Humanoid:EquipTool(player.Backpack:FindFirstChild("Beans"))
                player.Backpack["Beans"]:Activate() -- Click on screen to use the item once
                break
            end
        end
    end
end

-- Function to freeze player and set baseplate transparency
local function freezeAndSetBaseplate()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(-42, -43, 74) -- Teleport to specific position
        baseplate.Transparency = 0.5 -- Set baseplate transparency
        character.HumanoidRootPart.Anchored = true -- Freeze the player
    end
end

-- Main loop
while true do
    collectFood()
    manageNeeds()

    -- If backpack is full and not picking up food, freeze the player
    if getBackpackItemCount() == 10 then
        freezeAndSetBaseplate()
    end

    wait(0) -- No delay for item pickup
end
