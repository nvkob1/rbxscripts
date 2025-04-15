local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local EnemyFolder = workspace:WaitForChild("Client"):WaitForChild("Enemy")
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
	TextLabel.TextSize = 18
	TextLabel.Parent = Billboard

	ESPs[part] = {Billboard, TextLabel}

	local function UpdateESP()
		if part and part.Parent then
			local distance = (Camera.CFrame.Position - part.Position).Magnitude
			TextLabel.Text = string.format("Name: ENEMY | Studs: %.1f", distance)
		else
			ESPs[part] = nil
		end
	end

	RunService.RenderStepped:Connect(UpdateESP)
	Billboard.Parent = part

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

EnemyFolder.ChildAdded:Connect(function(part)
	if part:IsA("Part") and part.Size == Vector3.new(2, 2, 2) then
		CreateESP(part)
	end
end)

EnemyFolder.ChildRemoved:Connect(RemoveESP)

workspace.ChildAdded:Connect(function(child)
	if child:IsA("Folder") and child.Name == "Client" then
		child.ChildAdded:Connect(function(subChild)
			if subChild:IsA("Folder") and subChild.Name == "Enemy" then
				subChild.ChildAdded:Connect(function(part)
					if part:IsA("Part") and part.Size == Vector3.new(2, 2, 2) then
						CreateESP(part)
					end
				end)
				subChild.ChildRemoved:Connect(RemoveESP)
			end
		end)
	end
end)
