local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ESPs = {}

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
    TextLabel.TextScaled = false
    TextLabel.TextSize = 18
    TextLabel.Parent = Billboard

    ESPs[part] = {Billboard, TextLabel}

    local function UpdateESP()
        if part and part.Parent then
            local distance = (Workspace.CurrentCamera.CFrame.Position - part.Position).Magnitude
            TextLabel.Text = string.format("Item: %s | Dist: %.1f", part.Name, distance)
        else
            ESPs[part] = nil
        end
    end

    RunService.RenderStepped:Connect(UpdateESP)
    Billboard.Parent = part
end

local function RemoveESP(part)
    if ESPs[part] then
        ESPs[part][1]:Destroy()
        ESPs[part] = nil
    end
end

local function AddItemESPs()
    for _, item in pairs(workspace.Server.SpawnedItems:GetChildren()) do
        if not string.find(item.Name, "Zeni") then
            CreateESP(item)
        end
    end
end

workspace.Server.SpawnedItems.ChildAdded:Connect(function(child)
    if child:IsA("Model") and not string.find(child.Name, "Zeni") then
        CreateESP(child)
    end
end)

workspace.Server.SpawnedItems.ChildRemoved:Connect(RemoveESP)

-- Initialize item ESP for existing items
AddItemESPs()
