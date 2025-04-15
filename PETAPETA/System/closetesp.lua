local closetESP = {}

local RunService = game:GetService("RunService")
local enabled = false
local espFolder = Instance.new("Folder", game.CoreGui)
espFolder.Name = "ClosetESP"

local function createESPPart(model)
	local adorn = Instance.new("BoxHandleAdornment")
	adorn.Name = "ESPBox"
	adorn.Size = model:GetExtentsSize()
	adorn.Adornee = model
	adorn.AlwaysOnTop = true
	adorn.ZIndex = 10
	adorn.Color3 = Color3.fromRGB(255, 0, 0)
	adorn.Transparency = 0.5
	adorn.Parent = espFolder
end

function closetESP:Enable()
	enabled = true
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model.Name == "HideTansu" then
			createESPPart(model)
		end
	end
end

function closetESP:Disable()
	enabled = false
	espFolder:ClearAllChildren()
end

return closetESP
