local function findEmptyPad()
    local stages = workspace.Map.Stages:GetChildren()
    for _, stage in ipairs(stages) do
        if stage:FindFirstChild("Pads") then
            local pads = stage.Pads:GetChildren()
            for _, pad in ipairs(pads) do
                local playersNearby = false
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (pad.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if distance < 10 then -- Adjust distance threshold as needed
                            playersNearby = true
                            break
                        end
                    end
                end
                if not playersNearby then
                    return pad -- Returns the first empty pad found
                end
            end
        end
    end
    return nil -- No empty pad found
end

local function fireProximityPrompts()
    wait(0.1)
    for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            fireproximityprompt(v)
        end
    end
end

local function waitForSongSelector()
    local songSelector = workspace:FindFirstChild("SongSelector")
    while not songSelector do
        fireProximityPrompts()
        wait(1)
        songSelector = workspace:FindFirstChild("SongSelector")
    end
end

local function selectSong()
    local args = {
        [1] = {
            [1] = "Server",
            [2] = "StageManager",
            [3] = "Select"
        },
        [2] = {
            [1] = "VSCamellia_Ghost",
            [2] = "Mania"
        }
    }
    game:GetService("ReplicatedStorage").RE:FireServer(unpack(args))
end

local function waitForSolo()
    local inactiveGradient = workspace:FindFirstChild("InactiveGradient")
    while inactiveGradient and inactiveGradient.Enabled do
        wait(1)
    end
    
    local activeGradient = workspace:FindFirstChild("ActiveGradient")
    while not activeGradient or not activeGradient.Enabled do
        wait(1)
    end
end

local function playSolo()
    local args = {
        [1] = {
            [1] = "Server",
            [2] = "StageManager",
            [3] = "PlaySolo"
        },
        [2] = {}
    }
    game:GetService("ReplicatedStorage").RE:FireServer(unpack(args))
end

local player = game.Players.LocalPlayer
local emptyPad = findEmptyPad()
if emptyPad and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
    player.Character.HumanoidRootPart.CFrame = emptyPad.CFrame
    print("Teleported to empty pad at:", emptyPad.Position)
    fireProximityPrompts()
    print("Fired all proximity prompts after delay.")
    waitForSongSelector()
    selectSong()
    waitForSolo()
    playSolo()
else
    print("No empty pad found or unable to teleport.")
end
