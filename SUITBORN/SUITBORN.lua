local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")

local Device;
function checkDevice()
if LocalPlayer then
   if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
       Device = UDim2.fromOffset(480, 360)
   else
       Device = UDim2.fromOffset(580, 460)
   end
end
end
checkDevice()

if not isfolder("SUITBORN") then makefolder("SUITBORN") end
if not isfile("SUITBORN/options.json") then
 writefile("SUITBORN/options.json", '{"MenuKeybind":"LeftControl","Transparency":false,"Theme":"Darker","Acrylic":true}')
end

local Window = Fluent:CreateWindow({
Title = "SUITBORN [ALPHA]",
SubTitle = "by nvkob1",
TabWidth = 160,
Size = Device,
Acrylic = true,
Theme = "Amethyst",
})

local Tabs = {
ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
Visual = Window:AddTab({ Title = "Visual", Icon = "image" }),
Gameplay = Window:AddTab({ Title = "Gameplay", Icon = "gamepad-2" }),
Movement = Window:AddTab({ Title = "Movement", Icon = "move" }),
Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local espEnabled = false
local espConnections = {}
local posterEspEnabled = false
local posterEspConnections = {}
local fullBrightEnabled = false
local noFogEnabled = false
local originalLighting = {}
local originalFogSettings = {}
local instantProximityEnabled = false
local PromptButtonHoldBegan = nil
local anxietyDisabled = false

-- Fly variables
local FLYING = false
local iyflyspeed = 1
local flyKeyDown = nil
local flyKeyUp = nil
local IsOnMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, UserInputService:GetPlatform())

-- Mobile fly cleanup function
local unmobilefly = nil

-- Noclip variables
local noclipEnabled = false
local noclipConnection = nil

local function getRoot(character)
 return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

local function randomString()
 local chars = {}
 for i = 1, 20 do
     chars[i] = string.char(math.random(65, 90))
 end
 return table.concat(chars)
end

local function initializeOriginalLighting()
local lighting = game:GetService("Lighting")
local player = game:GetService("Players").LocalPlayer

originalLighting.Brightness = lighting.Brightness
originalLighting.Ambient = lighting.Ambient
originalLighting.ColorShift_Bottom = lighting.ColorShift_Bottom
originalLighting.ColorShift_Top = lighting.ColorShift_Top
originalLighting.FogEnd = lighting.FogEnd
originalLighting.FogStart = lighting.FogStart

local vignetteGui = player.PlayerGui:FindFirstChild("FlashLightGui")
if vignetteGui and vignetteGui:FindFirstChild("Frame") and vignetteGui.Frame:FindFirstChild("Vignette") then
originalLighting.VignetteVisible = vignetteGui.Frame.Vignette.Visible
end
end

local function initializeFogSettings()
   local lighting = game:GetService("Lighting")
   originalFogSettings.FogEnd = lighting.FogEnd
   originalFogSettings.FogStart = lighting.FogStart
   originalFogSettings.Atmosphere = {}
   
   for i, v in pairs(lighting:GetDescendants()) do
       if v:IsA("Atmosphere") then
           originalFogSettings.Atmosphere[i] = v:Clone()
       end
   end
end

initializeOriginalLighting()
initializeFogSettings()

local function createESP(model)
if not model:FindFirstChild("HumanoidRootPart") then return end

local highlight = Instance.new("Highlight")
highlight.Parent = model
highlight.FillColor = Color3.fromRGB(255, 0, 0)
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.FillTransparency = 0.7
highlight.OutlineTransparency = 0

return highlight
end

local function createPosterESP(part)
if not part:IsA("BasePart") then return end

local highlight = Instance.new("Highlight")
highlight.Parent = part
highlight.FillColor = Color3.fromRGB(0, 255, 0)
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.FillTransparency = 0.7
highlight.OutlineTransparency = 0

return highlight
end

local function enableESP()
if not workspace:FindFirstChild("kit") then return end

for _, model in pairs(workspace.kit:GetChildren()) do
  if model:IsA("Model") then
      createESP(model)
  end
end

espConnections.added = workspace.kit.ChildAdded:Connect(function(child)
  if child:IsA("Model") and espEnabled then
      createESP(child)
  end
end)
end

local function disableESP()
if not workspace:FindFirstChild("kit") then return end

for _, model in pairs(workspace.kit:GetChildren()) do
  if model:IsA("Model") then
      local highlight = model:FindFirstChild("Highlight")
      if highlight then
          highlight:Destroy()
      end
  end
end

for _, connection in pairs(espConnections) do
  connection:Disconnect()
end
espConnections = {}
end

local function enablePosterESP()
-- ESP for Map.Posters
if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Posters") then
  for _, part in pairs(workspace.Map.Posters:GetChildren()) do
      if part:IsA("BasePart") then
          createPosterESP(part)
      end
  end
  
  posterEspConnections.postersAdded = workspace.Map.Posters.ChildAdded:Connect(function(child)
      if child:IsA("BasePart") and posterEspEnabled then
          createPosterESP(child)
      end
  end)
end

-- ESP for Map.Building.Office.Poster
if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Building") and workspace.Map.Building:FindFirstChild("Office") and workspace.Map.Building.Office:FindFirstChild("Poster") then
  createPosterESP(workspace.Map.Building.Office.Poster)
end
end

local function disablePosterESP()
-- Remove ESP from Map.Posters
if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Posters") then
  for _, part in pairs(workspace.Map.Posters:GetChildren()) do
      if part:IsA("BasePart") then
          local highlight = part:FindFirstChild("Highlight")
          if highlight then
              highlight:Destroy()
          end
      end
  end
end

-- Remove ESP from Map.Building.Office.Poster
if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Building") and workspace.Map.Building:FindFirstChild("Office") and workspace.Map.Building.Office:FindFirstChild("Poster") then
  local highlight = workspace.Map.Building.Office.Poster:FindFirstChild("Highlight")
  if highlight then
      highlight:Destroy()
  end
end

for _, connection in pairs(posterEspConnections) do
  connection:Disconnect()
end
posterEspConnections = {}
end

local function enableFullBright()
local lighting = game:GetService("Lighting")
local player = game:GetService("Players").LocalPlayer

originalLighting.Brightness = lighting.Brightness
originalLighting.Ambient = lighting.Ambient
originalLighting.ColorShift_Bottom = lighting.ColorShift_Bottom
originalLighting.ColorShift_Top = lighting.ColorShift_Top
originalLighting.FogEnd = lighting.FogEnd
originalLighting.FogStart = lighting.FogStart

local vignetteGui = player.PlayerGui:FindFirstChild("FlashLightGui")
if vignetteGui and vignetteGui:FindFirstChild("Frame") and vignetteGui.Frame:FindFirstChild("Vignette") then
originalLighting.VignetteVisible = vignetteGui.Frame.Vignette.Visible
vignetteGui.Frame.Vignette.Visible = false
end

lighting.Brightness = 2
lighting.Ambient = Color3.fromRGB(255, 255, 255)
lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
lighting.FogEnd = 100000
lighting.FogStart = 100000
end

local function disableFullBright()
local lighting = game:GetService("Lighting")
local player = game:GetService("Players").LocalPlayer

if originalLighting.Brightness then
lighting.Brightness = originalLighting.Brightness
end
if originalLighting.Ambient then
lighting.Ambient = originalLighting.Ambient
end
if originalLighting.ColorShift_Bottom then
lighting.ColorShift_Bottom = originalLighting.ColorShift_Bottom
end
if originalLighting.ColorShift_Top then
lighting.ColorShift_Top = originalLighting.ColorShift_Top
end
if originalLighting.FogEnd then
lighting.FogEnd = originalLighting.FogEnd
end
if originalLighting.FogStart then
lighting.FogStart = originalLighting.FogStart
end

local vignetteGui = player.PlayerGui:FindFirstChild("FlashLightGui")
if vignetteGui and vignetteGui:FindFirstChild("Frame") and vignetteGui.Frame:FindFirstChild("Vignette") then
vignetteGui.Frame.Vignette.Visible = originalLighting.VignetteVisible or true
end
end

local function enableNoFog()
   local lighting = game:GetService("Lighting")
   lighting.FogEnd = 100000
   for i, v in pairs(lighting:GetDescendants()) do
       if v:IsA("Atmosphere") then
           v:Destroy()
       end
   end
end

local function disableNoFog()
   local lighting = game:GetService("Lighting")
   if originalFogSettings.FogEnd then
       lighting.FogEnd = originalFogSettings.FogEnd
   end
   if originalFogSettings.FogStart then
       lighting.FogStart = originalFogSettings.FogStart
   end
   
   for i, atmosphere in pairs(originalFogSettings.Atmosphere) do
       if atmosphere then
           atmosphere:Clone().Parent = lighting
       end
   end
end

local function disableAnxiety()
local anxietyScript = LocalPlayer.PlayerGui:FindFirstChild("FlashLightGui")
if anxietyScript then
anxietyScript = anxietyScript:FindFirstChild("AnxietyHandler")
if anxietyScript then
  anxietyScript.Disabled = true
end
end
end

local function enableAnxiety()
local anxietyScript = LocalPlayer.PlayerGui:FindFirstChild("FlashLightGui")
if anxietyScript then
anxietyScript = anxietyScript:FindFirstChild("AnxietyHandler")
if anxietyScript then
  anxietyScript.Disabled = false
end
end
end

local function enableInstantProximity()
if fireproximityprompt then
  if PromptButtonHoldBegan then
      PromptButtonHoldBegan:Disconnect()
  end
  PromptButtonHoldBegan = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
      fireproximityprompt(prompt)
  end)
end
end

local function disableInstantProximity()
if PromptButtonHoldBegan then
  PromptButtonHoldBegan:Disconnect()
  PromptButtonHoldBegan = nil
end
end

-- Fly functions
local function sFLY()
 repeat wait() until Players.LocalPlayer and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

 local T = getRoot(Players.LocalPlayer.Character)
 local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
 local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
 local SPEED = 0

 local function FLY()
     FLYING = true
     local BG = Instance.new('BodyGyro')
     local BV = Instance.new('BodyVelocity')
     BG.P = 9e4
     BG.Parent = T
     BV.Parent = T
     BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
     BG.cframe = T.CFrame
     BV.velocity = Vector3.new(0, 0, 0)
     BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
     task.spawn(function()
         repeat wait()
             if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                 Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
             end
             if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                 SPEED = 50
             elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
                 SPEED = 0
             end
             if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                 BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                 lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
             elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                 BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
             else
                 BV.velocity = Vector3.new(0, 0, 0)
             end
             BG.cframe = workspace.CurrentCamera.CoordinateFrame
         until not FLYING
         CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
         lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
         SPEED = 0
         BG:Destroy()
         BV:Destroy()
         if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
             Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
         end
     end)
 end

 if flyKeyDown then flyKeyDown:Disconnect() end
 if flyKeyUp then flyKeyUp:Disconnect() end

 flyKeyDown = UserInputService.InputBegan:Connect(function(input, gameProcessed)
     if gameProcessed then return end
     local key = input.KeyCode.Name:lower()
     if key == 'w' then
         CONTROL.F = iyflyspeed
     elseif key == 's' then
         CONTROL.B = -iyflyspeed
     elseif key == 'a' then
         CONTROL.L = -iyflyspeed
     elseif key == 'd' then 
         CONTROL.R = iyflyspeed
     elseif key == 'e' then
         CONTROL.Q = iyflyspeed * 2
     elseif key == 'q' then
         CONTROL.E = -iyflyspeed * 2
     end
 end)

 flyKeyUp = UserInputService.InputEnded:Connect(function(input, gameProcessed)
     if gameProcessed then return end
     local key = input.KeyCode.Name:lower()
     if key == 'w' then
         CONTROL.F = 0
     elseif key == 's' then
         CONTROL.B = 0
     elseif key == 'a' then
         CONTROL.L = 0
     elseif key == 'd' then
         CONTROL.R = 0
     elseif key == 'e' then
         CONTROL.Q = 0
     elseif key == 'q' then
         CONTROL.E = 0
     end
 end)
 FLY()
end

local function mobilefly()
 local velocityHandlerName = randomString()
 local gyroHandlerName = randomString()
 local mfly1, mfly2

 unmobilefly = function()
     pcall(function()
         FLYING = false
         local root = getRoot(Players.LocalPlayer.Character)
         local vh = root:FindFirstChild(velocityHandlerName)
         local gh = root:FindFirstChild(gyroHandlerName)
         if vh then vh:Destroy() end
         if gh then gh:Destroy() end
         Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
         if mfly1 then mfly1:Disconnect() end
         if mfly2 then mfly2:Disconnect() end
     end)
 end

 unmobilefly()
 FLYING = true

 local root = getRoot(Players.LocalPlayer.Character)
 local camera = workspace.CurrentCamera
 local v3none = Vector3.new()
 local v3zero = Vector3.new(0, 0, 0)
 local v3inf = Vector3.new(9e9, 9e9, 9e9)

 local controlModule = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
 local bv = Instance.new("BodyVelocity")
 bv.Name = velocityHandlerName
 bv.Parent = root
 bv.MaxForce = v3zero
 bv.Velocity = v3zero

 local bg = Instance.new("BodyGyro")
 bg.Name = gyroHandlerName
 bg.Parent = root
 bg.MaxTorque = v3inf
 bg.P = 1000
 bg.D = 50

 mfly2 = RunService.RenderStepped:Connect(function()
     root = getRoot(Players.LocalPlayer.Character)
     camera = workspace.CurrentCamera
     if Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
         local humanoid = Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
         local VelocityHandler = root:FindFirstChild(velocityHandlerName)
         local GyroHandler = root:FindFirstChild(gyroHandlerName)

         VelocityHandler.MaxForce = v3inf
         GyroHandler.MaxTorque = v3inf
         humanoid.PlatformStand = true
         GyroHandler.CFrame = camera.CoordinateFrame
         VelocityHandler.Velocity = v3none

         local direction = controlModule:GetMoveVector()
         if direction.X > 0 then
             VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * (iyflyspeed * 50))
         end
         if direction.X < 0 then
             VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * (iyflyspeed * 50))
         end
         if direction.Z > 0 then
             VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * (iyflyspeed * 50))
         end
         if direction.Z < 0 then
             VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * (iyflyspeed * 50))
         end
     end
 end)
end

local function NOFLY()
 FLYING = false
 if flyKeyDown then flyKeyDown:Disconnect() end
 if flyKeyUp then flyKeyUp:Disconnect() end
 if unmobilefly then unmobilefly() end
 if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
     Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
 end
end

-- Noclip functions
local function enableNoclip()
 noclipEnabled = true
 noclipConnection = RunService.Stepped:Connect(function()
     if noclipEnabled and Players.LocalPlayer.Character then
         for _, part in pairs(Players.LocalPlayer.Character:GetDescendants()) do
             if part:IsA("BasePart") and part.CanCollide then
                 part.CanCollide = false
             end
         end
     end
 end)
end

local function disableNoclip()
 noclipEnabled = false
 if noclipConnection then
     noclipConnection:Disconnect()
     noclipConnection = nil
 end
 if Players.LocalPlayer.Character then
     for _, part in pairs(Players.LocalPlayer.Character:GetDescendants()) do
         if part:IsA("BasePart") then
             part.CanCollide = true
         end
     end
 end
end

-- ESP Tab
local Toggle = Tabs.ESP:AddToggle("AIEsp", {
Title = "Monster ESP", 
Default = false
})

Toggle:OnChanged(function()
espEnabled = Options.AIEsp.Value
if espEnabled then
  enableESP()
else
  disableESP()
end
end)

local PosterToggle = Tabs.ESP:AddToggle("PosterEsp", {
Title = "Poster ESP", 
Default = false
})

PosterToggle:OnChanged(function()
posterEspEnabled = Options.PosterEsp.Value
if posterEspEnabled then
  enablePosterESP()
else
  disablePosterESP()
end
end)

-- Visual Tab
local FullBrightToggle = Tabs.Visual:AddToggle("FullBright", {
Title = "Full Bright", 
Default = false
})

FullBrightToggle:OnChanged(function()
fullBrightEnabled = Options.FullBright.Value
if fullBrightEnabled then
  enableFullBright()
else
  disableFullBright()
end
end)

local NoFogToggle = Tabs.Visual:AddToggle("NoFog", {
Title = "No Fog", 
Default = false
})

NoFogToggle:OnChanged(function()
noFogEnabled = Options.NoFog.Value
if noFogEnabled then
  enableNoFog()
else
  disableNoFog()
end
end)

local AnxietyToggle = Tabs.Visual:AddToggle("DisableAnxiety", {
Title = "Disable Anxiety", 
Default = false
})

AnxietyToggle:OnChanged(function()
anxietyDisabled = Options.DisableAnxiety.Value
if anxietyDisabled then
  disableAnxiety()
else
  enableAnxiety()
end
end)

-- Gameplay Tab
local InstantProximityToggle = Tabs.Gameplay:AddToggle("InstantProximity", {
Title = "Instant Interact", 
Default = false
})

InstantProximityToggle:OnChanged(function()
instantProximityEnabled = Options.InstantProximity.Value
if instantProximityEnabled then
  enableInstantProximity()
else
  disableInstantProximity()
end
end)

-- Movement Tab
local FlyToggle = Tabs.Movement:AddToggle("Fly", {
Title = "Fly", 
Default = false
})

FlyToggle:OnChanged(function()
if Options.Fly.Value then
  if IsOnMobile then
      mobilefly()
  else
      sFLY()
  end
else
  NOFLY()
end
end)

local NoclipToggle = Tabs.Movement:AddToggle("Noclip", {
Title = "Noclip", 
Default = false
})

NoclipToggle:OnChanged(function()
if Options.Noclip.Value then
  enableNoclip()
else
  disableNoclip()
end
end)

-- Keybinds for Fly and Noclip
local FlyKeybind = Tabs.Movement:AddKeybind("FlyKeybind", {
Title = "Fly Keybind",
Mode = "Toggle",
Default = "X",
Callback = function(Value)
  Options.Fly:SetValue(Value)
end
})

local NoclipKeybind = Tabs.Movement:AddKeybind("NoclipKeybind", {
Title = "Noclip Keybind", 
Mode = "Toggle",
Default = "C",
Callback = function(Value)
  Options.Noclip:SetValue(Value)
end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("SUITBORN")
SaveManager:SetFolder("SUITBORN")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

local function createMobileToggleButton()
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui") or game:GetService("CoreGui")

-- Remove existing button if it exists
local existingGui = playerGui:FindFirstChild("FluentToggleButton")
if existingGui then
  existingGui:Destroy()
end

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "FluentToggleButton"
ToggleGui.ResetOnSpawn = false
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.DisplayOrder = 999999

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(0.05, 0, 0.05, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
ToggleButton.Text = "UI"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.AutoButtonColor = true
ToggleButton.ZIndex = 9999
ToggleButton.Parent = ToggleGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.5, 0)
UICorner.Parent = ToggleButton

local dragging = false
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
    end
end)

ToggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        updateInput(input)
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
     ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
     task.delay(0.1, function()
         ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
     end)
     
     local downEvent = { KeyCode = Enum.KeyCode.LeftControl, UserInputType = Enum.UserInputType.Keyboard, UserInputState = Enum.UserInputState.Begin }
     local upEvent = { KeyCode = Enum.KeyCode.LeftControl, UserInputType = Enum.UserInputType.Keyboard, UserInputState = Enum.UserInputState.End }
     
     for _, con in pairs(getconnections(UserInputService.InputBegan)) do 
         pcall(function() con.Function(downEvent) end)
     end
     
     pcall(function()
         UserInputService:FireInputBegan(downEvent)
     end)
     
     task.delay(0.1, function()
         for _, con in pairs(getconnections(UserInputService.InputEnded)) do 
             pcall(function() con.Function(upEvent) end)
         end
         
         pcall(function()
             UserInputService:FireInputEnded(upEvent)
         end)
     end)
 end)

 ToggleGui.Parent = playerGui
 return ToggleGui
end

task.spawn(createMobileToggleButton)

Fluent:Notify({
Title = "SUITBORN [ALPHA]",
Content = "Script loaded successfully!",
Duration = 5
})

SaveManager:LoadAutoloadConfig()
