getgenv().TomatoAutoFarm = false

local ALERTS_ENABLED = true
local EXITREGION_MAX_ATTEMPTS = 50
local CHECK_DELAY = 0.03  -- Slightly increased to reduce CPU load
local BUTTON_DELAY = 0
local EXITREGION_WAIT = 0

local LocalPlayer = game:GetService("Players").LocalPlayer
local Multiplayer = Workspace.Multiplayer
local RunService = game:GetService("RunService")

-- Cache frequently used objects
local CLMAIN = LocalPlayer.PlayerScripts.CL_MAIN_GameScript
local CLMAINenv = getsenv(CLMAIN)
local gameAlert = CLMAINenv.newAlert
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

-- Cache string operations
local string_sub = string.sub
local string_lower = string.lower

function isRandomString(str)
    if #str == 0 then return false end
    for i = 1, #str do
        local ltr = string_sub(str, i, i)
        if string_lower(ltr) == ltr then
            return false
        end
    end
    return true
end

-- Cache character and components
local CachedChar = nil
local CachedHRP = nil
local CachedHumanoid = nil
local CharConnection = nil

local function UpdateCharCache()
    CachedChar = LocalPlayer.Character
    if CachedChar then
        CachedHRP = CachedChar:FindFirstChild("HumanoidRootPart")
        CachedHumanoid = CachedChar:FindFirstChild("Humanoid")
    else
        CachedHRP = nil
        CachedHumanoid = nil
    end
end

local function GetChar()
    if not CachedChar or not CachedChar.Parent then
        UpdateCharCache()
        if not CachedChar then
            CachedChar = LocalPlayer.CharacterAdded:wait()
            UpdateCharCache()
        end
    end
    return CachedChar
end

local function GetHRP()
    if not CachedHRP or not CachedHRP.Parent then
        UpdateCharCache()
    end
    return CachedHRP
end

local function GetHumanoid()
    if not CachedHumanoid or not CachedHumanoid.Parent then
        UpdateCharCache()
    end
    return CachedHumanoid
end

-- Set up character cache updates
if CharConnection then
    CharConnection:Disconnect()
end
CharConnection = LocalPlayer.CharacterAdded:Connect(UpdateCharCache)

local function Check(Flag)
    local HumanoidRootPart = GetHRP()
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

-- Optimize button scanning with better caching
local function ScanForButtons(Map)
    local Buttons = {}
    local descendants = Map:GetDescendants()
    
    for i = 1, #descendants do
        local MapObject = descendants[i]
        if MapObject.ClassName == "Model" and isRandomString(MapObject.Name) then
            local children = MapObject:GetChildren()
            for j = 1, #children do
                local Candidate = children[j]
                if Candidate:IsA("BasePart") and tostring(Candidate.BrickColor) ~= "Medium stone grey" then
                    if isRandomString(Candidate.Name) then
                        Candidate.Name = "Hitbox"
                        Buttons[#Buttons + 1] = MapObject
                        break
                    end
                end
            end
        end
    end
    
    return Buttons
end

local function OnMapLoad(Map)
    local Settings = Map:WaitForChild("Settings")
    local MapName = Settings:GetAttribute("MapName")
    if MapName then
        Alert("Map Loaded!" .. MapName)
    end
    
    if not Check("InGame") then
        Alert("Skipping due to InGame == false.")
        return
    end
    
    -- Scan for buttons with optimized method
    local Buttons = ScanForButtons(Map)
    local HumanoidRootPart = GetHRP()
    
    -- Cache original position
    local OriginalCFrame = HumanoidRootPart.CFrame
    
    -- Handle Lost Page
    local LostPage = Map:FindFirstChild("_LostPage", true)
    if LostPage then
        HumanoidRootPart.CFrame = LostPage.CFrame
        task.wait()
        HumanoidRootPart.CFrame = OriginalCFrame
        Alert("Got Lost Page.")
    end
    
    -- Handle Escapee
    local Escapee = Map:FindFirstChild("NPC", true)
    if Escapee then
        Escapee = Escapee.Parent
        if Escapee then
            Escapee = Escapee.Contact
        else
            Escapee = Map:FindFirstChild("Contact", true)
        end
        if Escapee then
            HumanoidRootPart.CFrame = Escapee.CFrame
            task.wait()
            HumanoidRootPart.CFrame = OriginalCFrame
            Alert("Got Escapee.")
        end
    end
    
    -- Auto Farm Loop with optimizations
    Alert("Commencing Auto Farm")
    local Humanoid = GetHumanoid()
    local GodMode = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        Humanoid.Health = 1000
    end)
    
    local Attempts = 0
    local lastFrameTime = tick()
    
    while task.wait(CHECK_DELAY) and Check("InGame") do
        -- Simple FPS limiter to prevent excessive CPU usage
        local currentTime = tick()
        if currentTime - lastFrameTime < CHECK_DELAY then
            continue
        end
        lastFrameTime = currentTime
        
        local ExitRegion = Map:FindFirstChild("ExitRegion", true)
        HumanoidRootPart = GetHRP()
        Humanoid = GetHumanoid()
        
        if not HumanoidRootPart or not Humanoid then
            break
        end
        
        Humanoid.Jump = true
        
        if not ExitRegion then
            local FoundValidButton = false
            -- More efficient button checking
            for i = 1, #Buttons do
                local Button = Buttons[i]
                if Button and Button.Parent then
                    local ButtonHitbox = Button:FindFirstChild("Hitbox")
                    if ButtonHitbox then
                        local TouchFound = Button:FindFirstChild("TouchInterest", true)
                        local GuiFound = Button:FindFirstChildWhichIsA("BillboardGui", true)
                        
                        if TouchFound and GuiFound then
                            FoundValidButton = true
                            -- Optimized teleportation
                            HumanoidRootPart.Anchored = false
                            HumanoidRootPart.CFrame = CFrame.new(ButtonHitbox.Position)
                            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            HumanoidRootPart.Velocity = Vector3.new(0, 100, 0)
                            task.wait(0.1)
                            HumanoidRootPart.Anchored = true
                            task.wait(BUTTON_DELAY)
                            HumanoidRootPart.Anchored = false
                            break
                        end
                    end
                end
            end
            
            if not FoundValidButton then
                HumanoidRootPart.Anchored = false
            end
        else
            -- ExitRegion handling with optimizations
            HumanoidRootPart.Anchored = false
            if Attempts < EXITREGION_MAX_ATTEMPTS then
                Attempts = Attempts + 1
                HumanoidRootPart.CFrame = ExitRegion.CFrame
                Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
                HumanoidRootPart.Velocity = Vector3.new(50, -1, 50)
                task.wait()
                
                -- Quick distance check
                local distance = (HumanoidRootPart.Position - ExitRegion.Position).Magnitude
                if distance <= 5 then
                    Attempts = Attempts + 1
                end
            else
                Alert("Teleported to ExitRegion.")
                break
            end
        end
        
        -- Ensure unanchored
        if HumanoidRootPart.Anchored then
            HumanoidRootPart.Anchored = false
        end
    end
    
    -- Cleanup
    HumanoidRootPart = GetHRP()
    if HumanoidRootPart then
        HumanoidRootPart.Anchored = false
        local Humanoid = GetHumanoid()
        if Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    
    task.wait(EXITREGION_WAIT)
    Alert("Complete.")
    
    if GodMode then
        GodMode:Disconnect()
        GodMode = nil
    end
    
    Alert("Preparing for next Map! Resetting..")
    local Head = GetChar():FindFirstChild("Head")
    if Head then
        Head:Destroy()
    end
    Alert("Waiting for Player..")
    task.wait(2)
    
    HumanoidRootPart = GetChar():WaitForChild("HumanoidRootPart")
    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
    repeat
        task.wait(0.1) -- Reduced wait time
        HumanoidRootPart.Velocity = Vector3.new(0, 0, 100)
    until Check("InLift")
    Alert("Connecting..")
end

-- Optimized connection management
ConnectMap = function()
    if MapDetect then
        MapDetect:Disconnect()
        MapDetect = nil
    end
    
    MapDetect = Multiplayer.ChildAdded:Connect(function(NewMap)
        task.spawn(function()
            local success, err = pcall(function()
                local nameChanged = false
                local nameConnection
                local startTime = tick()
                
                nameConnection = NewMap:GetPropertyChangedSignal("Name"):Connect(function()
                    nameChanged = true
                    if nameConnection then
                        nameConnection:Disconnect()
                        nameConnection = nil
                    end
                end)
                
                -- Wait for name change with timeout
                while not nameChanged and NewMap.Parent and (tick() - startTime) < 10 do
                    task.wait(0.1)
                end
                
                if nameConnection then
                    nameConnection:Disconnect()
                    nameConnection = nil
                end
                
                if NewMap.Parent then
                    OnMapLoad(NewMap)
                else
                    Alert("Map was removed before processing, reconnecting...")
                end
            end)
            
            if not success then
                Alert("Error processing map: " .. tostring(err))
            end
            
            -- Reconnect for next map
            task.wait(1)
            ConnectMap()
        end)
    end)
end

-- Cleanup function
local function Cleanup()
    if MapDetect then
        MapDetect:Disconnect()
        MapDetect = nil
    end
    if CharConnection then
        CharConnection:Disconnect()
        CharConnection = nil
    end
end

-- Main loop with optimizations
if _G.LoopCancel ~= nil then
    _G.LoopCancel = true
    task.wait(0.1)
end
_G.LoopCancel = false

Alert("Ready! Starting Update Loop.")

-- Use RunService for better performance
local lastUpdateTime = 0
local function UpdateLoop()
    local currentTime = tick()
    if currentTime - lastUpdateTime < 0.1 then -- Limit to 10 FPS for main loop
        return
    end
    lastUpdateTime = currentTime
    
    if _G.LoopCancel == true then
        _G.LoopCancel = false
        Alert("Update Loop cancelled.")
        Cleanup()
        return
    end
    
    if getgenv().TomatoAutoFarm == false then
        Alert("Auto Farm Paused!")
        repeat 
            task.wait(0.1) 
        until getgenv().TomatoAutoFarm == true or _G.LoopCancel == true
        Alert("Auto Farm Resumed!")
    end
    
    local inLift = Check("InLift")
    if inLift and not MapDetect then
        ConnectMap()
    end
end

local loopConnection = RunService.Heartbeat:Connect(UpdateLoop)

-- Cleanup on script end
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        Cleanup()
        if loopConnection then
            loopConnection:Disconnect()
        end
    end
end)
