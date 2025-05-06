local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

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

local Window = Fluent:CreateWindow({
    Title = "PETAPETA",
    SubTitle = "Made by Kob",
    TabWidth = 160,
    Size =  Device,
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    PETAPETA = Window:AddTab({ Title = "PETAPETA", Icon = "alert-triangle" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- FullBright Feature
local fbEnabled = false
local dynamicLight
local fbConnection

-- Store original lighting settings
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Ambient = Lighting.Ambient
}

-- Store original PostEffect states
local originalEffectStates = {}

local function setupFullBright()
    Lighting.Brightness = 0.8
    Lighting.ClockTime = 14
    Lighting.FogEnd = 1e6
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.new(0.4, 0.4, 0.4)
    Lighting.Ambient = Color3.new(0.4, 0.4, 0.4)
    
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            if originalEffectStates[effect] == nil then
                originalEffectStates[effect] = effect.Enabled
            end
            effect.Enabled = false
        end
    end
end

local function restoreOriginalLighting()
    Lighting.Brightness = originalLighting.Brightness
    Lighting.ClockTime = originalLighting.ClockTime
    Lighting.FogEnd = originalLighting.FogEnd
    Lighting.GlobalShadows = originalLighting.GlobalShadows
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    Lighting.Ambient = originalLighting.Ambient
    
    for effect, state in pairs(originalEffectStates) do
        if effect and effect:IsA("PostEffect") then
            effect.Enabled = state
        end
    end
end

local function createDynamicLight()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    dynamicLight = Instance.new("PointLight", hrp)
    dynamicLight.Brightness = 0.3
    dynamicLight.Range = 20
end

Tabs.Main:AddToggle("FullBright", { Title = "FullBright", Default = false }):OnChanged(function(value)
    fbEnabled = value
    if value then
        setupFullBright()
        createDynamicLight()
        
        if fbConnection then fbConnection:Disconnect() end
        fbConnection = RunService.RenderStepped:Connect(function()
            if fbEnabled then
                setupFullBright()
                if dynamicLight and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    dynamicLight.Parent = LocalPlayer.Character.HumanoidRootPart
                end
            end
        end)
    else
        if fbConnection then fbConnection:Disconnect() end
        if dynamicLight then dynamicLight:Destroy() end
        restoreOriginalLighting()
    end
end)

-- Fixed Walkspeed Feature
local walkspeedValue = 16
local walkspeedEnabled = false
local walkspeedConnection

local function setupWalkspeedLoop()
    if walkspeedConnection then walkspeedConnection:Disconnect() end
    
    walkspeedConnection = RunService.Heartbeat:Connect(function()
        if walkspeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if LocalPlayer.Character.Humanoid.WalkSpeed ~= walkspeedValue then
                LocalPlayer.Character.Humanoid.WalkSpeed = walkspeedValue
            end
        end
    end)
end

Tabs.Main:AddToggle("WalkspeedToggle", { 
    Title = "Enable Walkspeed", 
    Default = false 
}):OnChanged(function(value)
    walkspeedEnabled = value
    if value then
        setupWalkspeedLoop()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = walkspeedValue
        end
    else
        if walkspeedConnection then walkspeedConnection:Disconnect() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16 -- Reset to default
        end
    end
end)

Tabs.Main:AddSlider("Walkspeed", {
    Title = "Walkspeed",
    Description = "Change your walking speed",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        walkspeedValue = Value
        if walkspeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

-- Noclip Feature
local noclipEnabled = false
local noclipConnection

local function setupNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if noclipEnabled then
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end

Tabs.Main:AddToggle("Noclip", { Title = "Noclip", Default = false }):OnChanged(function(value)
    noclipEnabled = value
    if value then
        setupNoclip()
    else
        if noclipConnection then 
            noclipConnection:Disconnect() 
            
            -- Re-enable collisions
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end)

-- Auto Hide Feature
local autoHideEnabled = false
local isHiding = false
local currentHideCloset = nil

-- Update the getClosestEmptyHideTansu function to properly check if player is hiding
local function getClosestEmptyHideTansu()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestDistance = math.huge
    local closestHideTansu = nil
    
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model.Name == "HideTansu" then
            local hidingPlayer = model:FindFirstChild("HidingPlayer")
            local hidePoint = model:FindFirstChild("HidePoint")
            
            if hidePoint and hidingPlayer then
                -- Check if this closet is available (no player or the current player)
                if hidingPlayer.Value == nil or (hidingPlayer.Value and hidingPlayer.Value == LocalPlayer) then
                    local distance = (hidePoint.Position - hrp.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestHideTansu = model
                    end
                end
            end
        end
    end
    
    return closestHideTansu
end

local function isPlayerHiding()
    -- Check if player is already hiding in any closet
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model.Name == "HideTansu" then
            local hidingPlayer = model:FindFirstChild("HidingPlayer")
            if hidingPlayer and hidingPlayer.Value == LocalPlayer then
                return true, model -- Return true and the hiding closet
            end
        end
    end
    return false, nil
end

local function fireAllProximityPrompts(model)
    for _, prompt in pairs(model:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            fireproximityprompt(prompt)
            return true
        end
    end
    return false
end

local function tweenToHideTansu(hideTansu)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not hideTansu or not hideTansu:FindFirstChild("HidePoint") then 
        return false 
    end
    
    local hrp = character.HumanoidRootPart
    local hidePoint = hideTansu.HidePoint
    
    -- Create and start tween
    local tweenInfo = TweenInfo.new(
        (hrp.Position - hidePoint.Position).Magnitude / 20, -- Duration based on distance
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(hrp, tweenInfo, {
        CFrame = CFrame.new(hidePoint.Position)
    })
    
    tween:Play()
    
    -- Wait for tween to complete
    tween.Completed:Wait()
    
    -- Fire proximity prompt
    task.wait(0.2) -- Small delay to ensure proximity prompt detection
    return fireAllProximityPrompts(hideTansu)
end

local function hideInCloset()
    -- Prevent multiple simultaneous hide attempts
    if isAttemptingHide then return end
    
    -- Check if already hiding
    local alreadyHiding, _ = isPlayerHiding()
    if alreadyHiding then return end
    
    -- Set flag to prevent multiple attempts
    isAttemptingHide = true
    
    -- Get the closest hiding spot
    local hideTansu = getClosestEmptyHideTansu()
    if hideTansu then
        -- Try to hide once
        local success = tweenToHideTansu(hideTansu)
        
        -- Wait a moment before allowing another hide attempt
        task.delay(5, function()
            isAttemptingHide = false
        end)
    else
        -- If no hiding spot found, reset flag after a short delay
        task.delay(2, function()
            isAttemptingHide = false
        end)
    end
end

-- PETAPETA Detection and Auto Hide
do
    local notifyEnabled = false
    local espEnabled = false
    local ESPs = {}
    local petapetaDetected = false
    local autoHideEnabled = false
    local EnemyFolder = workspace:WaitForChild("Client"):WaitForChild("Enemy")
    local isAttemptingHide = false
    local lastPetapetaNotifyTime = 0
    
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
                local distance = (Camera.CFrame.Position - part.Position).Magnitude
                TextLabel.Text = string.format("Name: ENEMY | Studs: %.1f", distance)
            else
                ESPs[part] = nil
            end
        end
    
        RunService.RenderStepped:Connect(UpdateESP)
        Billboard.Parent = part
    
        -- Notify user (with cooldown to prevent spam)
        if notifyEnabled then
            local currentTime = tick()
            if currentTime - lastPetapetaNotifyTime > 5 then
                petapetaDetected = true
                lastPetapetaNotifyTime = currentTime
                
                Fluent:Notify({
                    Title = "⚠️ PETAPETA",
                    Content = "PETAPETA has appeared.",
                    Duration = 4
                })
                
                -- Auto hide when PETAPETA appears
                if autoHideEnabled and not isPlayerHiding() and not isAttemptingHide then
                    task.spawn(hideInCloset)
                end
            end
        end
        
        warn("Enemy ESP Added: " .. part.Name)
    end

    local function RemoveESP(part)
        if ESPs[part] then
            -- For billboard GUI based ESPs
            if ESPs[part][1] and ESPs[part][1]:IsA("BillboardGui") then
                ESPs[part][1]:Destroy() 
            end
            
            -- Notify that PETAPETA vanished
            if notifyEnabled then
                Fluent:Notify({
                    Title = "✅ PETAPETA",
                    Content = "PETAPETA has vanished.",
                    Duration = 4
                })
            end
            
            ESPs[part] = nil
            
            -- Check if there are any ESPs left
            local hasActiveESPs = false
            for _, _ in pairs(ESPs) do
                hasActiveESPs = true
                break
            end
            
            if not hasActiveESPs then
                petapetaDetected = false
                -- Reset hiding status (only if we're out of danger)
                isHiding = false
                currentHideCloset = nil
            end
            
            warn("Enemy ESP Removed: " .. part.Name)
        end
    end

    local function addHighlightWithDelay(model)
        task.wait(0.5) 
        local newHighlight = Instance.new("Highlight")
        newHighlight.FillColor = Color3.fromRGB(128, 0, 128) -- Purple like in Enemy.lua
        newHighlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- White outline
        newHighlight.FillTransparency = 0.5
        newHighlight.OutlineTransparency = 0
        newHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- This makes it visible through walls and other highlights
        newHighlight.Parent = model
        
        -- Store reference to the highlight for later removal
        if not ESPs[model] then
            ESPs[model] = {}
        end
        table.insert(ESPs[model], newHighlight)
        
        -- Notify with cooldown
        if notifyEnabled then
            local currentTime = tick()
            if currentTime - lastPetapetaNotifyTime > 5 then
                petapetaDetected = true
                lastPetapetaNotifyTime = currentTime
                
                Fluent:Notify({
                    Title = "⚠️ PETAPETA",
                    Content = "PETAPETA has appeared.",
                    Duration = 4
                })
                
                if autoHideEnabled and not isPlayerHiding() and not isAttemptingHide then
                    task.spawn(hideInCloset)
                end
            end
        end
    end

    local function checkAndAddHighlight()
        local clientFolder = workspace:FindFirstChild("Client")
        if clientFolder then
            local enemyFolder = clientFolder:FindFirstChild("Enemy")
            if enemyFolder then
                local clientEnemyPart = enemyFolder:FindFirstChild("ClientEnemy")
                if clientEnemyPart and clientEnemyPart:IsA("Part") then
                    local enemyModel = clientEnemyPart:FindFirstChild("EnemyModel")
                    if enemyModel and enemyModel:IsA("Model") and espEnabled then
                        -- Check if highlight already exists before adding
                        local hasHighlight = false
                        for _, child in pairs(enemyModel:GetChildren()) do
                            if child:IsA("Highlight") then
                                hasHighlight = true
                                -- Update existing highlight properties
                                child.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                break
                            end
                        end
                        
                        if not hasHighlight then
                            addHighlightWithDelay(enemyModel)
                        end
                    end
                    
                    clientEnemyPart.ChildAdded:Connect(function(model)
                        if model:IsA("Model") and model.Name == "EnemyModel" and espEnabled then
                            addHighlightWithDelay(model)
                        end
                    end)
                end
                
                enemyFolder.ChildAdded:Connect(function(part)
                    if part:IsA("Part") and part.Name == "ClientEnemy" then
                        part.ChildAdded:Connect(function(model)
                            if model:IsA("Model") and model.Name == "EnemyModel" and espEnabled then
                                addHighlightWithDelay(model)
                            end
                        end)
                        if part:FindFirstChild("EnemyModel") then
                            local existingModel = part:FindFirstChild("EnemyModel")
                            if existingModel:IsA("Model") and espEnabled then
                                addHighlightWithDelay(existingModel)
                            end
                        end
                    end
                end)
            end
        end
    end
    
    -- Setup main ESP logic for 2x2x2 parts
    EnemyFolder.ChildAdded:Connect(function(part)
        if part:IsA("Part") and part.Size == Vector3.new(2, 2, 2) and espEnabled then
            CreateESP(part)
        end
    end)

    EnemyFolder.ChildRemoved:Connect(RemoveESP)
    
    Tabs.PETAPETA:AddToggle("NotifyToggle", {
        Title = "PETAPETA Notify",
        Default = false,
        Callback = function(value)
            notifyEnabled = value
        end
    })
    
    Tabs.PETAPETA:AddToggle("PETAPETAESP", {
        Title = "PETAPETA ESP",
        Default = false,
        Callback = function(value)
            espEnabled = value
            if value then
                -- Check for existing enemies
                for _, part in pairs(EnemyFolder:GetChildren()) do
                    if part:IsA("Part") and part.Size == Vector3.new(2, 2, 2) then
                        CreateESP(part)
                    end
                    
                    -- Check for any ClientEnemy with EnemyModel
                    if part:IsA("Part") and part.Name == "ClientEnemy" then
                        local enemyModel = part:FindFirstChild("EnemyModel")
                        if enemyModel and enemyModel:IsA("Model") then
                            addHighlightWithDelay(enemyModel)
                        end
                    end
                end
                
                -- Check for model-based enemies using the highlight system
                checkAndAddHighlight()
            else
                -- Remove all ESPs
                for part, data in pairs(ESPs) do
                    if type(data) == "table" then
                        for _, item in ipairs(data) do
                            if item and typeof(item) == "Instance" then
                                item:Destroy()
                            end
                        end
                    end
                end
                table.clear(ESPs)
                petapetaDetected = false
            end
        end
    })

    local petapetaCheckConnection
    Tabs.PETAPETA:AddToggle("AutoHideToggle", {
        Title = "Auto Hide When PETAPETA Spawns",
        Default = false,
        Callback = function(value)
            autoHideEnabled = value
            
            -- Clean up existing connection
            if petapetaCheckConnection then
                petapetaCheckConnection:Disconnect()
                petapetaCheckConnection = nil
            end
            
            -- No continuous checking - we'll rely on the PETAPETA detection events
            -- If PETAPETA is already detected when enabling, try hiding once
            if value and petapetaDetected and not isPlayerHiding() and not isAttemptingHide then
                task.spawn(hideInCloset)
            end
        end
    })
        
    -- Setup monitoring for workspace/Client structure changes
    workspace.ChildAdded:Connect(function(child)
        if child:IsA("Folder") and child.Name == "Client" then
            child.ChildAdded:Connect(function(subChild)
                if subChild:IsA("Folder") and subChild.Name == "Enemy" then
                    subChild.ChildAdded:Connect(function(part)
                        if part:IsA("Part") and part.Name == "ClientEnemy" then
                            part.ChildAdded:Connect(function(model)
                                if model:IsA("Model") and model.Name == "EnemyModel" and espEnabled then
                                    addHighlightWithDelay(model)
                                end
                            end)
                            if part:FindFirstChild("EnemyModel") then
                                local existingModel = part:FindFirstChild("EnemyModel")
                                if existingModel:IsA("Model") and espEnabled then
                                    addHighlightWithDelay(existingModel)
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end)
    
    -- Run initial checks
    checkAndAddHighlight()
end

-- ESP Closet Feature
do
    local closetHighlights = {}
    local closetESPEnabled = false
    
    local function createClosetESP(model)
        if not closetESPEnabled then return end
        
        -- Check if this closet already has a highlight
        for _, highlight in pairs(closetHighlights) do
            if highlight.Adornee == model then return end
        end
        
        local highlight = Instance.new("Highlight", model)
        highlight.FillColor = Color3.fromRGB(255, 255, 0)
        table.insert(closetHighlights, highlight)
    end
    
    local function monitorClosets()
        -- Check existing closets
        for _, model in pairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model.Name == "HideTansu" then
                createClosetESP(model)
            end
        end
        
        -- Watch for new closets
        workspace.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("Model") and descendant.Name == "HideTansu" then
                createClosetESP(descendant)
            end
        end)
    end
    
    Tabs.ESP:AddToggle("ESP Closet", { Title = "ESP Closet", Default = false }):OnChanged(function(value)
        closetESPEnabled = value
        
        for _, highlight in pairs(closetHighlights) do highlight:Destroy() end
        table.clear(closetHighlights)
        
        if value then
            monitorClosets()
        end
    end)
end

-- ESP Items Feature
do
    local itemHighlights = {}
    local itemESPEnabled = false
    
    local function createItemESP(model)
        if not itemESPEnabled then return end
        
        -- Check if this item already has a highlight
        for _, highlight in pairs(itemHighlights) do
            if highlight.Adornee == model then return end
        end
        
        local highlight = Instance.new("Highlight", model)
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        table.insert(itemHighlights, highlight)
        
        local billboard = Instance.new("BillboardGui", model)
        billboard.Adornee = model:FindFirstChildWhichIsA("BasePart")
        billboard.Size = UDim2.new(0, 100, 0, 20)
        billboard.AlwaysOnTop = true
        
        local textLabel = Instance.new("TextLabel", billboard)
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Text = model.Name
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        table.insert(itemHighlights, billboard)
    end
    
    local function monitorItems()
        -- Look for the item folder
        local serverFolder = workspace:FindFirstChild("Server")
        if serverFolder then
            local itemFolder = serverFolder:FindFirstChild("SpawnedItems")
            if itemFolder then
                -- Check existing items
                for _, model in pairs(itemFolder:GetChildren()) do
                    if model:IsA("Model") and not model.Name:lower():find("zeni") then
                        createItemESP(model)
                    end
                end
                
                -- Watch for new items
                itemFolder.ChildAdded:Connect(function(model)
                    if model:IsA("Model") and not model.Name:lower():find("zeni") then
                        createItemESP(model)
                    end
                end)
            end
            
            -- Watch for SpawnedItems folder to be created
            serverFolder.ChildAdded:Connect(function(child)
                if child:IsA("Folder") and child.Name == "SpawnedItems" then
                    -- Check existing items
                    for _, model in pairs(child:GetChildren()) do
                        if model:IsA("Model") and not model.Name:lower():find("zeni") then
                            createItemESP(model)
                        end
                    end
                    
                    -- Watch for new items
                    child.ChildAdded:Connect(function(model)
                        if model:IsA("Model") and not model.Name:lower():find("zeni") then
                            createItemESP(model)
                        end
                    end)
                end
            end)
        end
        
        -- Watch for Server folder to be created
        workspace.ChildAdded:Connect(function(child)
            if child:IsA("Folder") and child.Name == "Server" then
                local itemFolder = child:FindFirstChild("SpawnedItems")
                if itemFolder then
                    -- Check existing items
                    for _, model in pairs(itemFolder:GetChildren()) do
                        if model:IsA("Model") and not model.Name:lower():find("zeni") then
                            createItemESP(model)
                        end
                    end
                    
                    -- Watch for new items
                    itemFolder.ChildAdded:Connect(function(model)
                        if model:IsA("Model") and not model.Name:lower():find("zeni") then
                            createItemESP(model)
                        end
                    end)
                end
                
                -- Watch for SpawnedItems folder to be created
                child.ChildAdded:Connect(function(folder)
                    if folder:IsA("Folder") and folder.Name == "SpawnedItems" then
                        -- Check existing items
                        for _, model in pairs(folder:GetChildren()) do
                            if model:IsA("Model") and not model.Name:lower():find("zeni") then
                                createItemESP(model)
                            end
                        end
                        
                        -- Watch for new items
                        folder.ChildAdded:Connect(function(model)
                            if model:IsA("Model") and not model.Name:lower():find("zeni") then
                                createItemESP(model)
                            end
                        end)
                    end
                end)
            end
        end)
    end
    
    Tabs.ESP:AddToggle("ESP Items", { Title = "ESP Items", Default = false }):OnChanged(function(value)
        itemESPEnabled = value
        
        for _, highlight in pairs(itemHighlights) do highlight:Destroy() end
        table.clear(itemHighlights)
        
        if value then
            monitorItems()
        end
    end)
end

-- Save Manager Setup
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("PETAPETA")
SaveManager:SetFolder("PETAPETA")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Create mobile toggle button for Fluent UI
local function createMobileToggleButton()
    local UserInputService = game:GetService("UserInputService")
    
    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "FluentToggleButton"
    ToggleGui.ResetOnSpawn = false
    ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ToggleGui.DisplayOrder = 999999 -- Set extremely high to stay on top of other UI

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 40, 0, 40)
    ToggleButton.Position = UDim2.new(0.05, 0, 0.5, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
    ToggleButton.Text = "UI"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 14
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.AutoButtonColor = true
    ToggleButton.ZIndex = 9999 -- High Z-index to stay on top
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
        
        -- Simulate LeftControl press using both old and new methods for compatibility
        local downEvent = { KeyCode = Enum.KeyCode.LeftControl, UserInputType = Enum.UserInputType.Keyboard, UserInputState = Enum.UserInputState.Begin }
        local upEvent = { KeyCode = Enum.KeyCode.LeftControl, UserInputType = Enum.UserInputType.Keyboard, UserInputState = Enum.UserInputState.End }
        
        -- Method 1: Fire all connections
        for _, con in pairs(getconnections(UserInputService.InputBegan)) do 
            pcall(function() con.Function(downEvent) end)
        end
        
        -- Method 2: Fire a synthetic event (works better on mobile)
        pcall(function()
            UserInputService:FireInputBegan(downEvent)
        end)
        
        task.delay(0.1, function()
            -- End the key press
            for _, con in pairs(getconnections(UserInputService.InputEnded)) do 
                pcall(function() con.Function(upEvent) end)
            end
            
            pcall(function()
                UserInputService:FireInputEnded(upEvent)
            end)
        end)
    end)

    local player = game:GetService("Players").LocalPlayer
    ToggleGui.Parent = player:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
    return ToggleGui
end

-- Create the mobile toggle button
task.spawn(createMobileToggleButton)

Fluent:Notify({
   Title = "PETAPETA",
   Content = "The script has been loaded.",
   Duration = 8
})

SaveManager:LoadAutoloadConfig()
