local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local ItemFolder = workspace:WaitForChild("Server"):WaitForChild("SpawnedItems")

local ESPs = {}

local function CreateESP(model)
	if not model:IsA("Model") or model:FindFirstChildOfClass("BillboardGui") then return end

	local Billboard = Instance.new("BillboardGui")
	Billboard.Adornee = model:FindFirstChildWhichIsA("BasePart")
	Billboard.Size = UDim2.new(0, 200, 0, 50)
	Billboard.StudsOffset = Vector3.new(0, 2, 0)
	Billboard.AlwaysOnTop = true
	Billboard.Name = "ItemESP"

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextStrokeTransparency = 0
	Label.Text = model.Name
	Label.TextScaled = true
	Label.Font = Enum.Font.GothamBold
	Label.Parent = Billboard

	Billboard.Parent = model
	ESPs[model] = Billboard
end

local function RemoveESP(model)
	if ESPs[model] then
		ESPs[model]:Destroy()
		ESPs[model] = nil
	end
end

for _, model in ipairs(ItemFolder:GetChildren()) do
	if model:IsA("Model") and not model.Name:lower():find("zeni") then
		CreateESP(model)
	end
end

ItemFolder.ChildAdded:Connect(function(model)
	if model:IsA("Model") and not model.Name:lower():find("zeni") then
		CreateESP(model)
	end
end)

ItemFolder.ChildRemoved:Connect(RemoveESP)
