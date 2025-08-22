getgenv().TomatoAutoFarm = false

local ALERTS_ENABLED = true
local EXITREGION_MAX_ATTEMPTS = 50
local CHECK_DELAY = 0.1 -- Added minimum delay to prevent excessive CPU usage
local BUTTON_DELAY = 0
local EXITREGION_WAIT = 0

local LocalPlayer = game:GetService("Players").LocalPlayer
local Multiplayer = Workspace.Multiplayer
local RunService = game:GetService("RunService")

-- Connection cleanup tracking
local ActiveConnections = {}
local function AddConnection(connection)
    table.insert(ActiveConnections, connection)
    return connection
end

local function CleanupConnections()
    for i, connection in ipairs(ActiveConnections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    ActiveConnections = {}
end

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

function isRandomString(str)
    if #str == 0 then return false end
    for i = 1, #str do
        local ltr = str:sub(i, i)
        if ltr:lower() == ltr then
            return false
        end
    end
    return true
end

local function GetChar()
    return LocalPlayer.Character or (LocalPlayer.CharacterAdded:wait() and LocalPlayer.Character)
end

local function Check(Flag)
    local HumanoidRootPart = GetChar():FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return false end
    if Flag == "InLift" then
        if HumanoidRootPart.Position.X < 50 and HumanoidRootPart.Position.Z > 70 then
            return true
        end
    elseif Flag == "InGame" then
        if HumanoidRootPart.Position.X > 50 then
            return true
        end
    end
    return false
end

local MapDetect
local ConnectMap

local function OnMapLoad(Map)
    local MapName = Map:WaitForChild("Settings"):GetAttribute("MapName")
    if MapName then
        Alert("Map Loaded!" .. MapName)
    end
    
    if Check("InGame") == false then
        Alert("Skipping due to InGame == false.")
        ConnectMap()
        return
    end
    
    -- FIXED: Clear buttons table and use more efficient scanning
    local Buttons = {}
    local ButtonCount = 0
    
    -- More efficient scanning with early termination
    for i, MapObject in pairs(Map:GetDescendants()) do
        if ButtonCount > 100 then break end -- Prevent excessive scanning
        
        if isRandomString(MapObject.Name) and MapObject.ClassName == "Model" then
            local Hitbox
            for j, Candidate in pairs(MapObject:GetChildren()) do
                if Candidate:IsA("BasePart") and tostring(Candidate.BrickColor) ~= "Medium stone grey" then
                    Hitbox = Candidate
                    break
                end
            end
            if Hitbox and isRandomString(Hitbox.Name) then
                Hitbox.Name = "Hitbox"
                table.insert(Buttons, MapObject)
                ButtonCount += 1
            end
        end
    end
    
    local HumanoidRootPart = GetChar().HumanoidRootPart
    local OriginalCFrame = HumanoidRootPart.CFrame
    
    -- Grab Lost Page and Escapee
    local LostPage = Map:FindFirstChild("_LostPage", true)
    if LostPage then
        HumanoidRootPart.CFrame = LostPage.CFrame
        task.wait(0.1)
        HumanoidRootPart.CFrame = OriginalCFrame
        Alert("Got Lost Page.")
    end
    
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
            task.wait(0.1)
            HumanoidRootPart.CFrame = OriginalCFrame
            Alert("Got Escapee.")
        end
    end
    
    -- Auto Farm Loop with better resource management
    Alert("Commencing Auto Farm")
    local CurrentButton = nil
    local Humanoid = GetChar().Humanoid
    local GodMode = AddConnection(Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        Humanoid.Health = 1000
    end))
    
    local Attempts = 0
    local LoopIteration = 0
    
    while task.wait(CHECK_DELAY) and Check("InGame") do
        LoopIteration += 1
        
        -- FIXED: Periodic cleanup to prevent memory buildup
        if LoopIteration % 100 == 0 then
            task.wait(0.5) -- Brief pause for garbage collection
        end
        
        local ExitRegion = Map:FindFirstChild("ExitRegion", true)
        local HumanoidRootPart = GetChar().HumanoidRootPart
        
        if not HumanoidRootPart then break end -- Safety check
        
        Humanoid.Jump = true
        local FailedScan = true
        
        if not ExitRegion then
            -- FIXED: More efficient button processing with limits
            local ButtonsProcessed = 0
            for i, Button in pairs(Buttons) do
                if ButtonsProcessed > 10 then break end -- Limit processing per frame
                
                local ButtonHitbox = Button:FindFirstChild("Hitbox")
                if ButtonHitbox then
                    CurrentButton = Button
                    local TouchFound = Button:FindFirstChild("TouchInterest", true)
                    local GuiFound = Button:FindFirstChildWhichIsA("BillboardGui", true)
                    
                    if TouchFound and GuiFound then
                        FailedScan = false
                        ButtonsProcessed += 1
                        
                        -- Teleport to button + bypass button anti-cheat
                        HumanoidRootPart.Anchored = false
                        local OriginalCFrame = HumanoidRootPart.CFrame
                        HumanoidRootPart.CFrame = CFrame.new(ButtonHitbox.Position)
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        HumanoidRootPart.Velocity = Vector3.new(0, 100, 0)
                        task.wait(0.1)
                        HumanoidRootPart.Anchored = true
                        task.wait(BUTTON_DELAY)
                    end
                end
            end
        elseif ExitRegion then
            HumanoidRootPart.Anchored = false
            if Attempts < EXITREGION_MAX_ATTEMPTS then
                Attempts += 1
                HumanoidRootPart.CFrame = ExitRegion.CFrame
                Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
                HumanoidRootPart.Velocity = Vector3.new(50, -1, 50)
                task.wait()
                if (HumanoidRootPart.Position - ExitRegion.Position).Magnitude <= 5 then
                    Attempts += 1
                end
            else
                Alert("Teleported to ExitRegion.")
                break
            end
        end
        
        -- FIXED: Check for cancellation more frequently
        if _G.LoopCancel == true or getgenv().TomatoAutoFarm == false then
            break
        end
    end
    
    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    task.wait(EXITREGION_WAIT)
    Alert("Complete.")
    
    -- FIXED: Proper cleanup of connections
    CleanupConnections()
    
    -- Clear buttons table to free memory
    Buttons = nil
    CurrentButton = nil
    
    Alert("Preparing for next Map! Resetting..")
    GetChar().Head:Destroy()
    Alert("Waiting for Player..")
    task.wait(2)
    
    local HumanoidRootPart = GetChar():WaitForChild("HumanoidRootPart")
    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
    
    repeat
        task.wait(0.1) -- Prevent excessive CPU usage
        HumanoidRootPart.Velocity = Vector3.new(0, 0, 100)
    until Check("InLift")
    
    Alert("Reconnecting map detection...")
    ConnectMap()
end

ConnectMap = function()
    -- FIXED: Proper cleanup of existing connections
    if MapDetect then
        MapDetect:Disconnect()
        MapDetect = nil
    end
    
    MapDetect = Multiplayer.ChildAdded:Connect(function(NewMap)
        -- FIXED: Don't disconnect immediately, let the system handle it
        if MapDetect then
            MapDetect:Disconnect()
            MapDetect = nil
        end
        NewMap:GetPropertyChangedSignal("Name"):Wait()
        OnMapLoad(NewMap)
    end)
    Alert("Map detection connected.")
end

-- FIXED: Cleanup existing resources before starting
if _G.LoopCancel ~= nil then
    _G.LoopCancel = true
    task.wait(0.5) -- Give time for cleanup
end

-- Clean up any existing connections
CleanupConnections()

_G.LoopCancel = false
Alert("Ready! Starting Update Loop.")

-- FIXED: Main loop with better resource management
local MainLoopIteration = 0
while wait(0.1) do -- Added minimum delay
    MainLoopIteration += 1
    
    -- Periodic cleanup
    if MainLoopIteration % 500 == 0 then
        task.wait(1) -- Longer pause for major cleanup
        collectgarbage("collect") -- Force garbage collection
        Alert("Performed maintenance cleanup.")
    end
    
    local function Cancel()
        Alert("Update Loop cancelled.")
        CleanupConnections()
        if MapDetect then
            MapDetect:Disconnect()
            MapDetect = nil
        end
    end
    
    if Check("InLift") == true and not MapDetect then
        ConnectMap()
    elseif Check("InLift") == false and MapDetect then
        if MapDetect then
            MapDetect:Disconnect()
            MapDetect = nil
        end
    end
    
    if _G.LoopCancel == true then
        _G.LoopCancel = false
        Cancel()
        break
    end
    
    if getgenv().TomatoAutoFarm == false then
        Alert("Auto Farm Paused!")
        repeat 
            wait(0.5) -- Prevent excessive checking while paused
        until getgenv().TomatoAutoFarm == true or _G.LoopCancel == true
        Alert("Auto Farm Resumed!")
    end
end
