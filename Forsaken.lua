local player = game.Players.LocalPlayer

-- Wait until character is fully loaded
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local playerGui = player:FindFirstChild("PlayerGui")
local killersFolder = workspace.Players.Killers
local spectatingFolder = workspace.Players.Spectating

-- 🌍 Function to find Map
local function getMap()
    return workspace:FindFirstChild("Map") 
        and workspace.Map:FindFirstChild("Ingame") 
        and workspace.Map.Ingame:FindFirstChild("Map")
end

-- ⚙️ Get all valid generators
local function getGenerators()
    local map = getMap()
    if not map then return {} end

    local generators = {}
    for _, obj in ipairs(map:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "Generator" then
            local mainPart = obj:FindFirstChild("Main")
            if mainPart and mainPart:FindFirstChild("Prompt") and mainPart.Prompt:IsA("ProximityPrompt") then
                table.insert(generators, obj)
            end
        end
    end
    return generators
end

-- 📌 Get nearest generator
local function getNearestGenerator()
    local generators = getGenerators()
    local nearestGenerator, nearestDistance = nil, math.huge

    for _, generator in ipairs(generators) do
        local center = generator.Positions.Center.Position
        local dist = (rootPart.Position - center).Magnitude
        if dist < nearestDistance then
            nearestDistance = dist
            nearestGenerator = generator
        end
    end
    return nearestGenerator
end

-- 🔥 Check if a killer is nearby (within 5 studs)
local function isKillerNearby()
    for _, killer in ipairs(killersFolder:GetChildren()) do
        if killer:IsA("Model") and killer:FindFirstChild("HumanoidRootPart") then
            local dist = (rootPart.Position - killer.HumanoidRootPart.Position).Magnitude
            if dist <= 5 then
                return true
            end
        end
    end
    return false
end

-- 🔄 Fire RF to generator
local function fireRF()
    local nearestGenerator = getNearestGenerator()
    if not nearestGenerator then return end

    local remotes = nearestGenerator:FindFirstChild("Remotes")
    if remotes then
        local rf = remotes:FindFirstChild("RF")
        if rf and rf:IsA("RemoteFunction") then
            rf:InvokeServer()
            print("Fired RF at generator:", nearestGenerator.Name)
        end
    end
end

-- 🚀 Teleport to the best generator (least crowded)
local function teleportToBestGenerator()
    local generators = getGenerators()
    if #generators == 0 then return end

    local bestGenerator, minPlayersNearby = nil, math.huge

    for _, generator in ipairs(generators) do
        local playersNearby = 0
        local center = generator.Positions.Center.Position

        for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local otherRootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                if otherRootPart then
                    local dist = (center - otherRootPart.Position).Magnitude
                    if dist < 20 then
                        playersNearby = playersNearby + 1
                    end
                end
            end
        end

        if playersNearby == 0 then
            bestGenerator = generator
            break
        elseif playersNearby < minPlayersNearby then
            minPlayersNearby = playersNearby
            bestGenerator = generator
        end
    end

    if bestGenerator then
        rootPart.CFrame = bestGenerator.Positions.Center.CFrame
    end
end

-- 🏆 Fire ProximityPrompt until PuzzleUI appears
local function fireProximityPromptUntilPuzzleUI()
    local nearestPrompt, nearestDistance = nil, math.huge

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local promptPos = v.Parent and v.Parent:IsA("BasePart") and v.Parent.Position
            if promptPos then
                local dist = (rootPart.Position - promptPos).Magnitude
                if dist < nearestDistance then
                    nearestDistance = dist
                    nearestPrompt = v
                end
            end
        end
    end

    if nearestPrompt then
        while not playerGui:FindFirstChild("PuzzleUI") do
            fireproximityprompt(nearestPrompt)
            task.wait(0.5)
        end
    end
end

-- 🔄 Fire RE to generator
local function fireRE()
    if not playerGui:FindFirstChild("PuzzleUI") then
        return false
    end

    local generators = getGenerators()
    if #generators == 0 then
        return false
    end

    for _, generator in ipairs(generators) do
        local remotes = generator:FindFirstChild("Remotes")
        if remotes then
            local re = remotes:FindFirstChild("RE")
            if re and re:IsA("RemoteEvent") then
                re:FireServer()
                print("Fired RE at generator:", generator.Name)
                task.wait(3)
                return true
            end
        end
    end
    return false
end

-- 🔄 Reset round data
local function resetRoundData()
    print("Resetting round data...")
    task.wait(2) -- Ensure all objects reset
end

-- 🎮 Main Loop
while true do
    -- 🔄 Reset round data ONLY if the player is spectating (new round)
    if spectatingFolder:FindFirstChild(player.Name) then
        resetRoundData()
    end

    -- 🌍 Wait for player to enter game (not in Spectating)
    repeat task.wait(1) until not spectatingFolder:FindFirstChild(player.Name)
    task.wait(4) -- Wait 4 seconds after entering

    -- 📌 Wait for generators to spawn
    local generators = getGenerators()
    while #generators == 0 do
        print("No generators available. Waiting...")
        task.wait(1)
        generators = getGenerators()
    end

    -- 🚀 Check for killers and teleport if necessary
    if isKillerNearby() then
        fireRF()
        teleportToBestGenerator()
        task.wait(1)
        continue
    end

    -- 🎯 Teleport to the best generator
    teleportToBestGenerator()

    -- 🔥 Fire ProximityPrompt until PuzzleUI appears
    fireProximityPromptUntilPuzzleUI()

    -- 🔄 Fire RE until it can no longer be fired
    while fireRE() do
        task.wait(0.5)
    end

    -- ⏳ Wait only 0.5s before moving to the next generator
    print("Finished processing all generators. Checking again...")
    task.wait(0.5)
end
