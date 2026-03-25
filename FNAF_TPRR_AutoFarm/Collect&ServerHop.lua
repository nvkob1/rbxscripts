task.wait(2)

local player = game.Players.LocalPlayer or game.Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local spawnRemote = replicatedStorage:WaitForChild("Spawn", 10)

local playerGui = player:WaitForChild("PlayerGui")
local loadingGui = playerGui:FindFirstChild("TPRR_Loading")
if loadingGui then
    repeat task.wait(0.1) until not playerGui:FindFirstChild("TPRR_Loading")
end

local function serverHop()
     loadstring(game:HttpGet('https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/FNAF_TPRR_AutoFarm/ServerHopper.lua'))()
end

-- Force hop after 16 seconds
task.delay(16, function()
    serverHop()
end)

local lastSpawn = 0

local function ensureSpawned()
    while not workspace:FindFirstChild(player.Name) do
        local now = tick()
        if now - lastSpawn >= 2 then
            if spawnRemote then
                pcall(function() spawnRemote:InvokeServer() end)
            end
            lastSpawn = now
        end
        task.wait(0.1)
    end
    task.wait(1)
end

local function waitForGround()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local timeout = tick() + 10
    while humanoid.FloorMaterial == Enum.Material.Air do
        if tick() > timeout then break end
        task.wait(0.1)
    end
end

local hopping = false

local function getTapes()
    local tapes = {}
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name == "Tape" then
            table.insert(tapes, obj)
        end
    end
    return tapes
end

local function teleportTapes()
    if hopping then return end

    ensureSpawned()
    waitForGround()

    local tapes = getTapes()

    if #tapes == 0 then
        hopping = true
        serverHop()
        return
    end

    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        for _, tape in pairs(tapes) do
            tape.Position = rootPart.Position + Vector3.new(0, 2, 0)
        end
        hopping = true
        task.wait(1)
        serverHop()
    end
end

runService.Heartbeat:Connect(teleportTapes)
