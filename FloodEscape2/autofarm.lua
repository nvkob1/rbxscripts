getgenv().TomatoAutoFarm = false

local ALERTS_ENABLED = true
local EXITREGION_MAX_ATTEMPTS = 30  -- Reduced from 50
local CHECK_DELAY = 0.1  -- Added small delay to reduce CPU usage
local BUTTON_DELAY = 0.05  -- Reduced from 0
local EXITREGION_WAIT = 0.5  -- Increased slightly for stability

-- Services
local LocalPlayer = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Multiplayer = Workspace.Multiplayer

-- Cache frequently used objects
local CLMAIN = LocalPlayer.PlayerScripts.CL_MAIN_GameScript
local CLMAINenv = getsenv(CLMAIN)
local gameAlert = CLMAINenv and CLMAINenv.newAlert
local Alert

if CLMAINenv then
    Alert = function(...)
        if ALERTS_ENABLED then
            local Output = tostring(...)
            gameAlert(Output, nil, nil, "rainbow")
            print(Output)
        end
    end
else
    Alert = print
end

-- Optimized string check with early exit
local function isRandomString(str)
    local len = #str
    if len == 0 then return false end
    
    for i = 1, len do
        local char = str:sub(i, i)
        if char:byte() >= 97 and char:byte() <= 122 then  -- lowercase a-z
            return false
        end
    end
    return true
end

-- Cached character getter
local cachedCharacter
local lastCharacterCheck = 0
local function GetChar()
    local now = tick()
    if now - lastCharacterCheck > 1 or not cachedCharacter or not cachedCharacter.Parent then
        cachedCharacter = LocalPlayer.Character
        lastCharacterCheck = now
        if not cachedCharacter then
            cachedCharacter = LocalPlayer.CharacterAdded:Wait()
        end
    end
    return cachedCharacter
end

-- Optimized position checks
local function Check(Flag)
    local char = GetChar()
    if not char then return false end
    
    local HumanoidRootPart = char:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return false end
    
    local pos = HumanoidRootPart.Position
    if Flag == "InLift" then
        return pos.X < 50 and pos.Z > 70
    elseif Flag == "InGame" then
        return pos.X > 50
    end
    return false
end

local MapDetect
local ConnectMap
local currentButtons = {}  -- Cache buttons to avoid repeated scanning

-- Optimized button scanning
local function ScanForButtons(Map)
    local buttons = {}
    local descendants = Map:GetDescendants()
    
    -- Process in batches to avoid frame drops
    local batchSize = 50
    local processed = 0
    
    for i, MapObject in pairs(descendants) do
        if MapObject.ClassName == "Model" and isRandomString(MapObject.Name) then
            local hitbox
            local children = MapObject:GetChildren()
            
            for j, candidate in pairs(children) do
                if candidate:IsA("BasePart") and candidate.BrickColor.Name ~= "Medium stone grey" then
                    hitbox = candidate
                    break
                end
            end
            
            if hitbox and isRandomString(hitbox.Name) then
                hitbox.Name = "Hitbox"
                buttons[#buttons + 1] = MapObject
            end
        end
        
        -- Yield every batch to maintain FPS
        processed = processed + 1
        if processed >= batchSize then
            processed = 0
            RunService.Heartbeat:Wait()
        end
    end
    
    return buttons
end

local function OnMapLoad(Map)
    local Settings = Map:WaitForChild("Settings", 5)
    if not Settings then
        Alert("Failed to load map settings")
        return
    end
    
    local MapName = Settings:GetAttribute("MapName")
    if MapName then
        Alert("Map Loaded: " .. MapName)
    end
    
    if not Check("InGame") then
        Alert("Skipping - not in game")
        return
    end
    
    -- Scan for buttons once
    Alert("Scanning for buttons...")
    currentButtons = ScanForButtons(Map)
    Alert("Found " .. #currentButtons .. " buttons")
    
    local char = GetChar()
    if not char then return end
    
    local HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    local Humanoid = char:WaitForChild("Humanoid")
    
    -- Handle Lost Page and Escapee more efficiently
    local originalCFrame = HumanoidRootPart.CFrame
    
    -- Lost Page
    local LostPage = Map:FindFirstChild("_LostPage", true)
    if LostPage then
        HumanoidRootPart.CFrame = LostPage.CFrame
        task.wait(0.1)
        HumanoidRootPart.CFrame = originalCFrame
        Alert("Collected Lost Page")
    end
    
    -- Escapee
    local Escapee = Map:FindFirstChild("NPC", true)
    if Escapee then
        local parent = Escapee.Parent
        local contact = parent and parent:FindFirstChild("Contact") or Map:FindFirstChild("Contact", true)
        if contact then
            HumanoidRootPart.CFrame = contact.CFrame
            task.wait(0.1)
            HumanoidRootPart.CFrame = originalCFrame
            Alert("Collected Escapee")
        end
    end
    
    Alert("Starting auto farm...")
    
    -- Optimized god mode
    local godModeConnection
    if Humanoid then
        godModeConnection = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if Humanoid.Health < 100 then
                Humanoid.Health = 1000
            end
        end)
    end
    
    local attempts = 0
    local lastButtonCheck = 0
    local buttonCheckInterval = 0.2  -- Check buttons less frequently
    
    -- Main farming loop with better performance
    while Check("InGame") do
        local now = tick()
        local exitRegion = Map:FindFirstChild("ExitRegion", true)
        
        HumanoidRootPart.Anchored = false  -- Ensure unanchored at start
        
        if exitRegion then
            -- Handle exit region
            if attempts < EXITREGION_MAX_ATTEMPTS then
                attempts = attempts + 1
                HumanoidRootPart.CFrame = exitRegion.CFrame
                Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
                HumanoidRootPart.Velocity = Vector3.new(50, -50, 50)
                
                -- Check if close to exit
                local distance = (HumanoidRootPart.Position - exitRegion.Position).Magnitude
                if distance <= 8 then
                    attempts = attempts + 5  -- Speed up completion
                end
            else
                Alert("Reached exit region")
                break
            end
        else
            -- Handle buttons (check less frequently for performance)
            if now - lastButtonCheck > buttonCheckInterval then
                lastButtonCheck = now
                
                local foundValidButton = false
                
                -- Check buttons more efficiently
                for i = 1, #currentButtons do
                    local button = currentButtons[i]
                    if button and button.Parent then
                        local hitbox = button:FindFirstChild("Hitbox")
                        if hitbox then
                            local touchFound = button:FindFirstChild("TouchInterest", true)
                            local guiFound = button:FindFirstChildWhichIsA("BillboardGui", true)
                            
                            if touchFound and guiFound then
                                foundValidButton = true
                                
                                -- Quick teleport to button
                                HumanoidRootPart.CFrame = CFrame.new(hitbox.Position + Vector3.new(0, 3, 0))
                                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                HumanoidRootPart.Velocity = Vector3.new(0, 50, 0)
                                
                                task.wait(BUTTON_DELAY)
                                break
                            end
                        end
                    end
                end
                
                if not foundValidButton then
                    -- Keep character moving to avoid getting stuck
                    Humanoid.Jump = true
                end
            end
        end
        
        task.wait(CHECK_DELAY)
    end
    
    -- Cleanup
    HumanoidRootPart.Anchored = false
    
    if godModeConnection then
        godModeConnection:Disconnect()
    end
    
    Alert("Map completed - resetting...")
    
    -- Quick reset
    char.Head:Destroy()
    task.wait(1.5)  -- Reduced wait time
    
    -- Return to lift efficiently
    local newChar = GetChar()
    if newChar then
        local newHRP = newChar:WaitForChild("HumanoidRootPart")
        newHRP.CFrame = newHRP.CFrame + Vector3.new(0, 10, 0)
        
        -- Quick return to lift
        local maxReturnAttempts = 50
        local returnAttempts = 0
        
        while not Check("InLift") and returnAttempts < maxReturnAttempts do
            returnAttempts = returnAttempts + 1
            newHRP.Velocity = Vector3.new(0, 0, 150)  -- Increased speed
            task.wait(0.1)
        end
    end
    
    Alert("Ready for next map")
    
    -- Clear cached buttons
    currentButtons = {}
end

-- Optimized map connection
ConnectMap = function()
    if MapDetect then
        MapDetect:Disconnect()
    end
    
    MapDetect = Multiplayer.ChildAdded:Connect(function(NewMap)
        task.spawn(function()  -- Use spawn to avoid blocking
            local success, err = pcall(function()
                -- Wait for map to be named with shorter timeout
                local timeout = 5
                local elapsed = 0
                
                while NewMap.Name == "Part" and NewMap.Parent and elapsed < timeout do
                    task.wait(0.2)
                    elapsed = elapsed + 0.2
                end
                
                if NewMap.Parent then
                    OnMapLoad(NewMap)
                end
            end)
            
            if not success then
                Alert("Map error: " .. tostring(err))
            end
            
            -- Reconnect for next map
            task.wait(0.5)
            ConnectMap()
        end)
    end)
end

-- Main loop with better performance
if _G.LoopCancel then
    _G.LoopCancel = true
    task.wait(0.1)
end
_G.LoopCancel = false

Alert("Auto farm started - optimized version")

-- Use heartbeat for better performance than wait()
local connection
connection = RunService.Heartbeat:Connect(function()
    if _G.LoopCancel then
        _G.LoopCancel = false
        if MapDetect then
            MapDetect:Disconnect()
        end
        connection:Disconnect()
        Alert("Auto farm stopped")
        return
    end
    
    if not getgenv().TomatoAutoFarm then
        Alert("Auto farm paused")
        repeat
            RunService.Heartbeat:Wait()
        until getgenv().TomatoAutoFarm or _G.LoopCancel
        Alert("Auto farm resumed")
        return
    end
    
    local inLift = Check("InLift")
    
    if inLift and not MapDetect then
        ConnectMap()
    elseif not inLift and MapDetect then
        -- Keep connection active for performance
    end
end)
