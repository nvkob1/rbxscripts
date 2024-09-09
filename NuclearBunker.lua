local player = game.Players.LocalPlayer
local backpackGui = player.PlayerGui.Backpack.ScrollingFrame
local backpack = player.Backpack
local thirst = player.Thirst
local hunger = player.Hunger
local loadingFrame = player.PlayerGui.Loading.Frame
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local isEating = false

-- Noclip function
RunService.Stepped:Connect(function()
    local char = player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Fire ProximityPrompt and look at item
local function firePrompt(prompt, part)
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.new(camera.CFrame.Position, part.Position)
    prompt:InputHoldBegin()
    prompt:InputHoldEnd()
    camera.CameraType = Enum.CameraType.Custom
end

-- Get item count from Backpack GUI
local function getBackpackCount()
    local count = 0
    for _, frame in pairs(backpackGui:GetChildren()) do
        if frame.Name == "Preset" then count += 1 end
    end
    return count
end

-- Unequip items and count Beans and Bloxy Cola
local function getItems()
    player.Character.Humanoid:UnequipTools()
    local beans, bloxy = 0, 0
    for _, item in pairs(backpack:GetChildren()) do
        if item.Name == "Beans" then beans += 1 end
        if item.Name == "Bloxy Cola" then bloxy += 1 end
    end
    return beans, bloxy
end

-- Teleport to part and pick up item
local function teleportAndPickup(partName)
    if getBackpackCount() >= 10 then return end
    local part = workspace.Food:FindFirstChild(partName)
    if part then
        player.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0)
        player.Character.HumanoidRootPart.Anchored = false
        for _, prompt in pairs(part:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then firePrompt(prompt, part) end
        end
    end
end

-- Collect 5 Beans and 5 Bloxy Cola
local function collectFood()
    local beans, bloxy = getItems()
    while beans < 5 do teleportAndPickup("Beans") beans += 1 end
    while bloxy < 5 do teleportAndPickup("Bloxy Cola") bloxy += 1 end
end

-- Eat or drink if hunger/thirst < 70
local function manageNeeds()
    local char = player.Character
    if thirst.Value < 70 and backpack:FindFirstChild("Bloxy Cola") then
        local bloxyCola = backpack["Bloxy Cola"]
        player.Character.Humanoid:EquipTool(bloxyCola)
        isEating = true
        char.HumanoidRootPart.CFrame = CFrame.new(-125, 675, -70)
        wait(0.1)
        char.HumanoidRootPart.Anchored = true
        bloxyCola:Activate()
        wait(5) -- Drinking duration
        isEating = false
    elseif hunger.Value < 70 and backpack:FindFirstChild("Beans") then
        local beans = backpack["Beans"]
        player.Character.Humanoid:EquipTool(beans)
        isEating = true
        char.HumanoidRootPart.CFrame = CFrame.new(-125, 675, -70)
        wait(0.1)
        char.HumanoidRootPart.Anchored = true
        beans:Activate()
        wait(11) -- Eating duration
        isEating = false
    end
    player.Character.Humanoid:UnequipTools()
end

-- Freeze and teleport
local function freezePlayer()
    local char = player.Character
    char.HumanoidRootPart.CFrame = CFrame.new(-125, 675, -70)
    wait(0.1)
    char.HumanoidRootPart.Anchored = true
end

-- Main loop
while true do
    if loadingFrame.BackgroundTransparency == 1 then
        collectFood()
        manageNeeds()
        if isEating or getBackpackCount() == 10 then
            freezePlayer()
        else
            player.Character.HumanoidRootPart.Anchored = false
        end
    end
    wait(0)
end
