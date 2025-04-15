local fb = {}

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local fullbrightEnabled = false
local connection
local dynamicLight

local originalSettings = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	FogEnd = Lighting.FogEnd,
	GlobalShadows = Lighting.GlobalShadows,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	Ambient = Lighting.Ambient,
}

local function setupFullbright()
	Lighting.Brightness = 1
	Lighting.ClockTime = 14
	Lighting.FogEnd = 100000
	Lighting.GlobalShadows = false
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	Lighting.Ambient = Color3.fromRGB(128, 128, 128)
end

local function restoreOriginalSettings()
	for k, v in pairs(originalSettings) do
		Lighting[k] = v
	end
end

local function disablePostProcessingEffects()
	for _, effect in pairs(Lighting:GetChildren()) do
		if effect:IsA("PostEffect") then
			effect.Enabled = false
		end
	end
end

local function enablePostProcessingEffects()
	for _, effect in pairs(Lighting:GetChildren()) do
		if effect:IsA("PostEffect") then
			effect.Enabled = true
		end
	end
end

local function createDynamicLight(player)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	dynamicLight = Instance.new("PointLight")
	dynamicLight.Name = "DynamicFullbright"
	dynamicLight.Brightness = 0.5
	dynamicLight.Range = 20
	dynamicLight.Color = Color3.fromRGB(255, 255, 255)
	dynamicLight.Parent = humanoidRootPart
	return dynamicLight
end

function fb:Enable()
	fullbrightEnabled = true
	local player = Players.LocalPlayer
	setupFullbright()
	disablePostProcessingEffects()
	dynamicLight = createDynamicLight(player)

	if connection then
		connection:Disconnect()
	end

	connection = RunService.RenderStepped:Connect(function()
		if fullbrightEnabled then
			setupFullbright()
			disablePostProcessingEffects()
			if player.Character then
				local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
				if humanoidRootPart and dynamicLight then
					dynamicLight.Parent = humanoidRootPart
				end
			end
		end
	end)

	player.CharacterAdded:Connect(function()
		if fullbrightEnabled then
			dynamicLight = createDynamicLight(player)
		end
	end)
end

function fb:Disable()
	fullbrightEnabled = false
	if connection then
		connection:Disconnect()
		connection = nil
	end
	restoreOriginalSettings()
	enablePostProcessingEffects()
	if dynamicLight then
		dynamicLight:Destroy()
		dynamicLight = nil
	end
end

return fb
