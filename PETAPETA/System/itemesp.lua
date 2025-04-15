local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local ServerFolder = workspace:WaitForChild("Server"):WaitForChild("SpawnedItems")

local ESPs = {}

-- Function to create the ESP for items
local function CreateItemESP(item)
    local Billboard = Instance.new("BillboardGui")
    Billboard.Adornee = item
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

    ESPs[item] = {Billboard, TextLabel}

    -- Function to update the ESP label with the item name and distance
    local function UpdateESP()
        if item and item.Parent then
            local distance = (Camera.CFrame.Position - item.Position).Magnitude
            TextLabel.Text = string.format("Item: %s | Dist: %.1f", item.Name, distance)
        else
            ESPs[item] = nil
        end
    end

    -- Connect to RenderStepped to update ESP continuously
    RunService.RenderStepped:Connect(UpdateESP)

    Billboard.Parent = item
end

-- Function to remove the ESP for an item
local function RemoveItemESP(item)
    if ESPs[item] then
        ESPs[item][1]:Destroy()
        ESPs[item] = nil
    end
end

-- Main function to monitor the SpawnedItems folder and create ESP for new items
local function MonitorSpawnedItems()
    for _, item in pairs(ServerFolder:GetChildren()) do
        if item:IsA("Model") and not item.Name:match("Zeni") then
            CreateItemESP(item)
        end
    end

    -- Watch for new items being added to the folder
    ServerFolder.ChildAdded:Connect(function(item)
        if item:IsA("Model") and not item.Name:match("Zeni") then
            CreateItemESP(item)
        end
    end)

    -- Watch for items being removed
    ServerFolder.ChildRemoved:Connect(function(item)
        RemoveItemESP(item)
    end)
end

-- Start monitoring the SpawnedItems folder
MonitorSpawnedItems()
