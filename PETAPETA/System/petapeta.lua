local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local EnemyFolder = workspace:WaitForChild("Client"):WaitForChild("Enemy")

local module = {}
local ESPs = {}
local conns = {}
local enabled = false

local function CreateESP(part)
    local Billboard = Instance.new("BillboardGui")
    Billboard.Adornee = part
    Billboard.Size = UDim2.new(0, 150, 0, 40)
    Billboard.StudsOffset = Vector3.new(0, 3, 0)
    Billboard.AlwaysOnTop = true

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = 18
    TextLabel.Text = "ENEMY"
    TextLabel.Parent = Billboard

    ESPs[part] = {Billboard, TextLabel}
    Billboard.Parent = part

    local updateConn = RunService.RenderStepped:Connect(function()
        if part and part.Parent then
            local dist = (Camera.CFrame.Position - part.Position).Magnitude
            TextLabel.Text = string.format("ENEMY | %.1f studs", dist)
        end
    end)
    table.insert(conns, updateConn)

    StarterGui:SetCore("SendNotification", {
        Title = "⚠️ Enemy Spotted",
        Text = "PETAPETA spawned!",
        Duration = 5
    })
end

local function RemoveESP(part)
    if ESPs[part] then
        ESPs[part][1]:Destroy()
        ESPs[part] = nil

        StarterGui:SetCore("SendNotification", {
            Title = "✅ Enemy Vanished",
            Text = "PETAPETA despawned!",
            Duration = 5
        })
    end
end

local function addHighlight(model)
    task.wait(0.5)
    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(128, 0, 128)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.Parent = model
end

local function monitorEnemyFolder()
    for _, part in ipairs(EnemyFolder:GetChildren()) do
        if part:IsA("Part") and part.Size == Vector3.new(2, 2, 2) then
            CreateESP(part)
        end
    end

    local addedConn = EnemyFolder.ChildAdded:Connect(function(part)
        if not enabled then return end
        if part:IsA("Part") and part.Size == Vector3.new(2, 2, 2) then
            CreateESP(part)
        end
    end)
    table.insert(conns, addedConn)

    local removedConn = EnemyFolder.ChildRemoved:Connect(RemoveESP)
    table.insert(conns, removedConn)
end

local function monitorHighlights()
    local client = workspace:FindFirstChild("Client")
    if not client then return end
    local enemy = client:FindFirstChild("Enemy")
    if not enemy then return end

    local function watchPart(part)
        if part:IsA("Part") and part.Name == "ClientEnemy" then
            part.ChildAdded:Connect(function(model)
                if model:IsA("Model") and model.Name == "EnemyModel" then
                    addHighlight(model)
                end
            end)

            local existing = part:FindFirstChild("EnemyModel")
            if existing and existing:IsA("Model") then
                addHighlight(existing)
            end
        end
    end

    for _, p in ipairs(enemy:GetChildren()) do
        watchPart(p)
    end

    local addedEnemyConn = enemy.ChildAdded:Connect(watchPart)
    table.insert(conns, addedEnemyConn)
end

function module:Enable()
    if enabled then return end
    enabled = true
    monitorEnemyFolder()
    monitorHighlights()
end

function module:Disable()
    enabled = false
    for _, gui in pairs(ESPs) do
        gui[1]:Destroy()
    end
    ESPs = {}

    for _, c in pairs(conns) do
        c:Disconnect()
    end
    conns = {}
end

return module
