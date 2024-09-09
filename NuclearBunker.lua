local player = game.Players.LocalPlayer
local backpackGui = player:WaitForChild("PlayerGui"):WaitForChild("Backpack"):WaitForChild("ScrollingFrame")
local backpack = player:WaitForChild("Backpack")
local thirst = player:WaitForChild("Thirst")
local hunger = player:WaitForChild("Hunger")
local baseplate = workspace:FindFirstChild("Baseplate")
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local isEating = false -- To track if the player is currently eating

-- Anti-Afk
if not _G.AntiAfk then
    _G.AntiAfk = true
    game.StarterGui:SetCore("SendNotification", {Title = "Notification", Text = "Anti-Afk Enabled!", Duration = 5})
    game.Players.LocalPlayer.Idled:connect(function()
        game:GetService('VirtualUser'):CaptureController()
        game:GetService('VirtualUser'):ClickButton2(Vector2.new())
    end)
else
    game.StarterGui:SetCore("SendNotification", {Title = "Notification", Text = "You Already Executed!", Duration = 5})
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

-- Connect the noclip function to the RunService
RunService.Stepped:Connect(noclip)

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

-- Function to count how many "Preset" frames are in the Backpack ScrollingFrame
local function getBackpackItemCount()
    local itemCount = 0
    for _, frame in pairs(backpackGui:GetChildren()) do
        if frame.Name == "Preset" then
            itemCount = itemCount + 1
        end
    end
    return itemCount
end

-- Function to teleport to a random part and unfrozen
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
            -- Unfreeze character
            character.HumanoidRootPart.Anchored = false

            -- Teleport above the part
            character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)

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

-- Function to unequip all items and count Beans and Bloxy Cola in the backpack
local function getBackpackItems()
    local beansCount, bloxyColaCount = 0, 0

    -- Unequip everything
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

-- Function to check and collect food until there are 5 Beans and 5 Bloxy Cola
local function collectFood()
    if getBackpackItemCount() >= 10 then
        return -- Exit the function if the backpack is full
    end

    local beansCount, bloxyColaCount = getBackpackItems()

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

-- Function to use food when thirst or hunger is below 70, and eat only one item with specific durations
local function manageNeeds()
    if thirst.Value < 70 then
        local bloxyCola = backpack:FindFirstChild("Bloxy Cola")
        if bloxyCola then
            player.Character.Humanoid:EquipTool(bloxyCola)
            isEating = true -- Mark as eating
            bloxyCola:Activate() -- Click on screen to use the item once
            wait(5) -- Wait 5 seconds for drinking Bloxy Cola
            player.Character.Humanoid:UnequipTools() -- Unequip after drinking
            isEating = false -- Mark as done eating
        end
    end

    if hunger.Value < 70 then
        local beans = backpack:FindFirstChild("Beans")
        if beans then
            player.Character.Humanoid:EquipTool(beans)
            isEating = true -- Mark as eating
            beans:Activate() -- Click on screen to use the item once
            wait(11) -- Wait 11 seconds for eating Beans
            player.Character.Humanoid:UnequipTools() -- Unequip after eating
            isEating = false -- Mark as done eating
        end
    end
end

-- Function to freeze player and set baseplate transparency after teleporting
local function freezeAndSetBaseplate()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        -- Teleport to the specific position
        character.HumanoidRootPart.CFrame = CFrame.new(-42, -43, 74)

        -- Wait for 0.1 seconds before freezing
        wait(0.1)

        baseplate.Transparency = 0.5 -- Set baseplate transparency
        character.HumanoidRootPart.Anchored = true -- Freeze the player
    end
end

-- Main loop
while true do
    collectFood()
    manageNeeds()

    -- If eating or not picking up food, freeze the player and teleport
    if isEating or getBackpackItemCount() == 10 then
        freezeAndSetBaseplate()
    end

    wait(0) -- No delay for item pickup
end
