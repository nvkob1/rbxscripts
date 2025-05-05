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

local Window = Fluent:CreateWindow({
    Title = "PETAPETA",
    SubTitle = "Made by Kob",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
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
            
            if hidePoint and hidingPlayer and (hidingPlayer.Value == nil) then
                local distance = (hidePoint.Position - hrp.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestHideTansu = model
                end
            end
        end
    end
    
    return closestHideTansu
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
    if isHiding then return end
    
    local hideTansu = getClosestEmptyHideTansu()
    if hideTansu then
        isHiding = true
        currentHideCloset = hideTansu
        
        local success = tweenToHideTansu(hideTansu)
        
        if not success then
            isHiding = false
            currentHideCloset = nil
        end
    end
end

-- PETAPETA Detection and Auto Hide
do
    local notifyEnabled = false
    local espEnabled = false
    local activePetapeta = {}
    local petapetaDetected = false
    local autoHideEnabled = false
    
    local function notifyPetapetaAppeared()
        if notifyEnabled and not petapetaDetected then
            petapetaDetected = true
            Fluent:Notify({
                Title = "⚠️ PETAPETA",
                Content = "PETAPETA has appeared.",
                Duration = 4
            })
            
            -- Auto hide when PETAPETA appears
            if autoHideEnabled and not isHiding then
                hideInCloset()
            end
        end
    end
    
    local function notifyPetapetaVanished()
        if notifyEnabled and petapetaDetected then
            petapetaDetected = false
            Fluent:Notify({
                Title = "✅ PETAPETA",
                Content = "PETAPETA has vanished.",
                Duration = 4
            })
            
            -- Reset hiding status
            isHiding = false
            currentHideCloset = nil
        end
    end
    
    local function createPetapetaESP(obj)
        if activePetapeta[obj] then return end
        
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(128, 0, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Adornee = obj
        highlight.Parent = game.CoreGui
        activePetapeta[obj] = highlight
        
        -- Create ESP for each part in the object
        if obj:IsA("Model") then
            for _, part in pairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then
                    local partHighlight = Instance.new("Highlight")
                    partHighlight.FillColor = Color3.fromRGB(255, 0, 0)
                    partHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    partHighlight.Adornee = part
                    partHighlight.Parent = game.CoreGui
                    activePetapeta[part] = partHighlight
                end
            end
        end
        
        notifyPetapetaAppeared()
    end
    
    local function removePetapetaESP(obj)
        local highlight = activePetapeta[obj]
        if highlight then highlight:Destroy() end
        activePetapeta[obj] = nil
        
        -- Remove ESP for parts as well
        if obj:IsA("Model") then
            for _, part in pairs(obj:GetDescendants()) do
                if activePetapeta[part] then
                    activePetapeta[part]:Destroy()
                    activePetapeta[part] = nil
                end
            end
        end
        
        if next(activePetapeta) == nil then
            notifyPetapetaVanished()
        end
    end
    
    local function clearAllESP()
        for obj, highlight in pairs(activePetapeta) do
            if highlight then highlight:Destroy() end
        end
        table.clear(activePetapeta)
        petapetaDetected = false
    end
    
    local function addHighlightWithDelay(model)
        task.wait(0.5)
        if espEnabled then
            createPetapetaESP(model)
        else
            notifyPetapetaAppeared()
        end
    end
    
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
            if not value then
                clearAllESP()
            else
                -- Check for existing PETAPETA using new path
                local ClientFolder = workspace:FindFirstChild("Client")
                if ClientFolder then
                    local enemyFolder = ClientFolder:FindFirstChild("Enemy")
                    if enemyFolder then
                        for _, part in pairs(enemyFolder:GetChildren()) do
                            if part:IsA("Part") and part.Size == Vector3.new(2, 2, 2) then
                                createPetapetaESP(part)
                            end
                            if part:IsA("Part") and part.Name == "ClientEnemy" then
                                if part:FindFirstChild("EnemyModel") and part:FindFirstChild("EnemyModel"):IsA("Model") then
                                    createPetapetaESP(part:FindFirstChild("EnemyModel"))
                                end
                            end
                        end
                    end
                end
            end
        end
    })

    Tabs.PETAPETA:AddToggle("AutoHideToggle", {
        Title = "Auto Hide When PETAPETA Spawns",
        Default = false,
        Callback = function(value)
            autoHideEnabled = value
        end
    })
    
    local function setupEnemyFolderMonitoring(enemyFolder)
        -- Monitor parts added to Enemy folder
        enemyFolder.ChildAdded:Connect(function(part)
            -- Check for 2x2x2 parts like in Enemy.lua
            if part:IsA("Part") and part.Size == Vector3.new(2, 2, 2) then
                if espEnabled then
                    createPetapetaESP(part)
                else
                    notifyPetapetaAppeared()
                end
            end
            
            -- Check for ClientEnemy parts
            if part:IsA("Part") and part.Name == "ClientEnemy" then
                part.ChildAdded:Connect(function(model)
                    if model:IsA("Model") and model.Name == "EnemyModel" then
                        if espEnabled then
                            addHighlightWithDelay(model)
                        else
                            notifyPetapetaAppeared()
                        end
                    end
                end)
                
                if part:FindFirstChild("EnemyModel") then
                    local existingModel = part:FindFirstChild("EnemyModel")
                    if existingModel:IsA("Model") then
                        if espEnabled then
                            addHighlightWithDelay(existingModel)
                        else
                            notifyPetapetaAppeared()
                        end
                    end
                end
            end
        end)
        
        -- Monitor parts removed from Enemy folder
        enemyFolder.ChildRemoved:Connect(function(part)
            if activePetapeta[part] then
                removePetapetaESP(part)
            end
            
            if part:IsA("Part") and part.Name == "ClientEnemy" then
                if part:FindFirstChild("EnemyModel") and activePetapeta[part:FindFirstChild("EnemyModel")] then
                    removePetapetaESP(part:FindFirstChild("EnemyModel"))
                end
            end
            
            -- Check if there are no more enemies
            local foundEnemies = false
            for _, child in pairs(enemyFolder:GetChildren()) do
                if (child:IsA("Part") and child.Size == Vector3.new(2, 2, 2)) or 
                   (child:IsA("Part") and child.Name == "ClientEnemy") then
                    foundEnemies = true
                    break
                end
            end
            
            if not foundEnemies then
                notifyPetapetaVanished()
            end
        end)
        
        -- Check for existing PETAPETA
        for _, part in pairs(enemyFolder:GetChildren()) do
            if part:IsA("Part") and part.Size == Vector3.new(2, 2, 2) then
                if espEnabled then
                    createPetapetaESP(part)
                else
                    notifyPetapetaAppeared()
                end
            end
            
            if part:IsA("Part") and part.Name == "ClientEnemy" then
                if part:FindFirstChild("EnemyModel") then
                    local existingModel = part:FindFirstChild("EnemyModel")
                    if existingModel:IsA("Model") then
                        if espEnabled then
                            addHighlightWithDelay(existingModel)
                        else
                            notifyPetapetaAppeared()
                        end
                    end
                end
            end
        end
    end
    
    local function monitorPetapeta()
        -- Wait for the Client.Enemy folder
        local clientFolder = workspace:FindFirstChild("Client")
        if not clientFolder then
            -- Set up listener for Client folder to be created
            workspace.ChildAdded:Connect(function(child)
                if child:IsA("Folder") and child.Name == "Client" then
                    child.ChildAdded:Connect(function(subChild)
                        if subChild:IsA("Folder") and subChild.Name == "Enemy" then
                            setupEnemyFolderMonitoring(subChild)
                        end
                    end)
                    
                    if child:FindFirstChild("Enemy") then
                        setupEnemyFolderMonitoring(child:FindFirstChild("Enemy"))
                    end
                end
            end)
            return
        end
        
        local enemyFolder = clientFolder:FindFirstChild("Enemy") or clientFolder:WaitForChild("Enemy", 30)
        if not enemyFolder then return end
        
        setupEnemyFolderMonitoring(enemyFolder)
    end
    
    task.spawn(monitorPetapeta)
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
    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "FluentToggleButton"
    ToggleGui.ResetOnSpawn = false
    ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
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
    ToggleButton.Parent = ToggleGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.5, 0)
    UICorner.Parent = ToggleButton
    
    -- Make the button draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    -- Create a frame to preview where button will be
    local dragFrame = Instance.new("Frame")
    dragFrame.Size = ToggleButton.Size
    dragFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dragFrame.BackgroundTransparency = 0.5
    dragFrame.Visible = false
    dragFrame.Parent = ToggleGui
    
    local dragFrameCorner = Instance.new("UICorner")
    dragFrameCorner.CornerRadius = UDim.new(0.5, 0)
    dragFrameCorner.Parent = dragFrame
    
    local function updateDrag(input)
        if dragging then
            local delta = input.Position - dragStart
            -- Update the preview frame position
            dragFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end
    
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = ToggleButton.Position
            
            -- Show preview frame
            dragFrame.Position = ToggleButton.Position
            dragFrame.Visible = true
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    -- Hide preview and update actual button position
                    dragFrame.Visible = false
                    ToggleButton.Position = dragFrame.Position
                end
            end)
        end
    end)
    
    ToggleButton.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                updateDrag(input)
            end
        end
    end)
    
    -- Toggle UI when clicked (simulate left control keypress)
    ToggleButton.MouseButton1Click:Connect(function()
       -- Visual feedback
       ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
       task.delay(0.1, function()
           ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
       end)
       
       -- Simulate LeftControl keypress
       local leftControl = Enum.KeyCode.LeftControl
       local downEvent = {
           KeyCode = leftControl,
           UserInputType = Enum.UserInputType.Keyboard,
           UserInputState = Enum.UserInputState.Begin
       }
       
       local upEvent = {
           KeyCode = leftControl,
           UserInputType = Enum.UserInputType.Keyboard,
           UserInputState = Enum.UserInputState.End
       }
       
       -- Fire events to simulate keypress
       for _, connection in pairs(getconnections(UserInputService.InputBegan)) do
           connection.Function(downEvent)
       end
       
       task.delay(0.1, function()
           for _, connection in pairs(getconnections(UserInputService.InputEnded)) do
               connection.Function(upEvent)
           end
       end)
   end)
   
   -- Parent to PlayerGui
   if game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui") then
       ToggleGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
   else
       ToggleGui.Parent = game:GetService("CoreGui")
   end
   
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
