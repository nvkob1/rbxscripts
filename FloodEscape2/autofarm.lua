getgenv().TomatoAutoFarm = false

local ALERTS_ENABLED = true
local EXITREGION_MAX_ATTEMPTS = 50
local CHECK_DELAY = 0
local BUTTON_DELAY = 0
local EXITREGION_WAIT = 0
local MAP_NAME_TIMEOUT = 10 -- Timeout for map name change

local LocalPlayer = game:GetService("Players").LocalPlayer
local Multiplayer = Workspace.Multiplayer

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
    local character = GetChar()
    if not character then 
        Alert("DEBUG: No character found in Check()")
        return false 
    end
    
    local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then 
        Alert("DEBUG: No HumanoidRootPart found in Check()")
        return false 
    end
    
    local pos = HumanoidRootPart.Position
    Alert("DEBUG: Character position - X: " .. pos.X .. ", Y: " .. pos.Y .. ", Z: " .. pos.Z)
    
    if Flag == "InLift" then
        if pos.X < 50 and pos.Z > 70 then
            Alert("DEBUG: InLift = true")
            return true
        else
            Alert("DEBUG: InLift = false (X: " .. pos.X .. ", Z: " .. pos.Z .. ")")
        end
    elseif Flag == "InGame" then
        if pos.X > 50 then
            Alert("DEBUG: InGame = true")
            return true
        else
            Alert("DEBUG: InGame = false (X: " .. pos.X .. ")")
        end
    end
    return false
end

local MapDetect
local ConnectMap

local function OnMapLoad(Map)
    Alert("=== OnMapLoad Started ===")
    Alert("Map object: " .. tostring(Map))
    
    local success, MapName = pcall(function()
        local settings = Map:WaitForChild("Settings", 5)
        if settings then
            return settings:GetAttribute("MapName")
        end
        return nil
    end)
    
    if success and MapName then
        Alert("Map Loaded! " .. MapName)
    else
        Alert("Map Loaded but no MapName found or settings missing!")
    end
    
    -- Check if we're in game
    local inGameStatus = Check("InGame")
    Alert("InGame check result: " .. tostring(inGameStatus))
    
    if not inGameStatus then
        Alert("Skipping auto-farm due to InGame == false. Waiting to return to lift...")
        return -- Exit early if not in game
    end
    
    Alert("=== Starting Auto-Farm Setup ===")
    
    -- Verify character exists
    local character = GetChar()
    if not character then
        Alert("ERROR: No character found!")
        return
    end
    
    local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then
        Alert("ERROR: No HumanoidRootPart found!")
        return
    end
    
    Alert("Character ready. Position: " .. tostring(HumanoidRootPart.Position))
    
    -- Scan for buttons
    local Buttons = {}
    Alert("Scanning map for buttons...")
    
    local buttonCount = 0
    for i, MapObject in pairs(Map:GetDescendants()) do
        if isRandomString(MapObject.Name) and MapObject.ClassName == "Model" then
            local Hitbox
            for _, Candidate in pairs(MapObject:GetChildren()) do
                if Candidate:IsA("BasePart") and tostring(Candidate.BrickColor) ~= "Medium stone grey" then
                    Hitbox = Candidate
                    break
                end
            end
            if Hitbox and isRandomString(Hitbox.Name) then
                -- Confirmed button
                Hitbox.Name = "Hitbox"
                table.insert(Buttons, MapObject)
                buttonCount = buttonCount + 1
            end
        end
    end
    
    Alert("Found " .. buttonCount .. " buttons")
    
    -- Grab Lost Page
    Alert("Searching for Lost Page...")
    local LostPage = Map:FindFirstChild("_LostPage", true)
    if LostPage then
        local OriginalCFrame = HumanoidRootPart.CFrame
        HumanoidRootPart.CFrame = LostPage.CFrame
        task.wait(0.1)
        HumanoidRootPart.CFrame = OriginalCFrame
        Alert("Got Lost Page!")
    else
        Alert("No Lost Page found")
    end
    
    -- Grab Escapee
    Alert("Searching for Escapee...")
    local Escapee = Map:FindFirstChild("NPC", true)
    if Escapee then
        Escapee = Escapee.Parent
        if Escapee then
            Escapee = Escapee.Contact
        else
            Escapee = Map:FindFirstChild("Contact", true)
        end
        if Escapee then
            local OriginalCFrame = HumanoidRootPart.CFrame
            HumanoidRootPart.CFrame = Escapee.CFrame
            task.wait(0.1)
            HumanoidRootPart.CFrame = OriginalCFrame
            Alert("Got Escapee!")
        else
            Alert("Contact not found")
        end
    else
        Alert("No Escapee found")
    end
    
    -- Auto Farm Loop
    Alert("=== Commencing Auto Farm ===")
    local CurrentButton = nil
    local Humanoid = character.Humanoid
    local GodMode
    
    -- God mode setup
    if Humanoid then
        GodMode = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            Humanoid.Health = 1000
        end)
        Alert("God mode activated")
    else
        Alert("WARNING: No Humanoid found!")
    end
    
    local Attempts = 0
    local loopCount = 0
    
    while task.wait(CHECK_DELAY) and Check("InGame") do
        loopCount = loopCount + 1
        if loopCount % 50 == 0 then -- Log every 50 loops to avoid spam
            Alert("Auto-farm loop iteration: " .. loopCount)
        end
        
        local ExitRegion = Map:FindFirstChild("ExitRegion", true)
        local currentChar = GetChar()
        if not currentChar then
            Alert("Character lost during auto-farm!")
            break
        end
        
        local currentHRP = currentChar:FindFirstChild("HumanoidRootPart")
        if not currentHRP then
            Alert("HumanoidRootPart lost during auto-farm!")
            break
        end
        
        local currentHumanoid = currentChar:FindFirstChild("Humanoid")
        if currentHumanoid then
            currentHumanoid.Jump = true
        end
        
        local FailedScan = true
        
        if not ExitRegion then
            -- Look for buttons to press
            for i, Button in pairs(Buttons) do
                local ButtonHitbox = Button:FindFirstChild("Hitbox")
                if ButtonHitbox then
                    CurrentButton = Button
                    local TouchFound = Button:FindFirstChild("TouchInterest", true)
                    local GuiFound = Button:FindFirstChildWhichIsA("BillboardGui", true)
                    
                    if TouchFound and GuiFound then
                        FailedScan = false
                        -- Teleport to button
                        currentHRP.Anchored = false
                        currentHRP.CFrame = CFrame.new(ButtonHitbox.Position + Vector3.new(0, 2, 0))
                        if currentHumanoid then
                            currentHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                        currentHRP.Velocity = Vector3.new(0, 100, 0)
                        task.wait(0.1)
                        currentHRP.Anchored = true
                        task.wait(BUTTON_DELAY)
                        break
                    end
                end
            end
            
            if FailedScan then
                if loopCount % 100 == 0 then -- Only alert every 100 failed scans
                    Alert("No valid buttons found (scan " .. loopCount .. ")")
                end
            end
        else
            -- Exit region found
            Alert("Exit region detected! Attempting to exit...")
            currentHRP.Anchored = false
            
            if Attempts < EXITREGION_MAX_ATTEMPTS then
                Attempts = Attempts + 1
                currentHRP.CFrame = ExitRegion.CFrame
                if currentHumanoid then
                    currentHumanoid:ChangeState(Enum.HumanoidStateType.Landed)
                end
                currentHRP.Velocity = Vector3.new(50, -1, 50)
                task.wait(0.1)
                
                if (currentHRP.Position - ExitRegion.Position).Magnitude <= 5 then
                    Attempts = Attempts + 5 -- Speed up if close
                end
            else
                Alert("Successfully reached ExitRegion after " .. Attempts .. " attempts!")
                break
            end
        end
    end
    
    Alert("Auto-farm loop ended")
    
    -- Cleanup
    local finalChar = GetChar()
    if finalChar and finalChar:FindFirstChild("Humanoid") then
        finalChar.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    
    task.wait(EXITREGION_WAIT)
    
    if GodMode then
        GodMode:Disconnect()
        GodMode = nil
        Alert("God mode disabled")
    end
    
    Alert("=== Map Complete ===")
    Alert("Preparing for next map - resetting character...")
    
    -- Reset character
    local charToReset = GetChar()
    if charToReset and charToReset:FindFirstChild("Head") then
        charToReset.Head:Destroy()
    end
    
    Alert("Waiting for respawn...")
    task.wait(2)
    
    -- Move back to lift
    local respawnedChar = GetChar()
    if respawnedChar then
        local respawnedHRP = respawnedChar:WaitForChild("HumanoidRootPart", 10)
        if respawnedHRP then
            respawnedHRP.CFrame = respawnedHRP.CFrame + Vector3.new(0, 5, 0)
            Alert("Moving back to lift...")
            
            local moveAttempts = 0
            repeat
                task.wait(0.1)
                if respawnedHRP.Parent then
                    respawnedHRP.Velocity = Vector3.new(0, 0, 100)
                end
                moveAttempts = moveAttempts + 1
                if moveAttempts > 100 then
                    Alert("WARNING: Taking too long to reach lift!")
                    break
                end
            until Check("InLift") or moveAttempts > 100
            
            if Check("InLift") then
                Alert("Successfully returned to lift!")
            end
        end
    end
end

ConnectMap = function()
    Alert("=== Setting up map detection ===")
    MapDetect = Multiplayer.ChildAdded:Connect(function(NewMap)
        Alert("New map detected: " .. tostring(NewMap))
        MapDetect:Disconnect()
        MapDetect = nil
        
        -- Wait for map name change with timeout
        Alert("Waiting for map name to update...")
        local nameChanged = false
        local nameConnection
        local timeoutConnection
        
        nameConnection = NewMap:GetPropertyChangedSignal("Name"):Connect(function()
            Alert("Map name changed to: " .. NewMap.Name)
            nameChanged = true
            nameConnection:Disconnect()
            if timeoutConnection then 
                timeoutConnection:Disconnect() 
            end
        end)
        
        timeoutConnection = task.delay(MAP_NAME_TIMEOUT, function()
            if not nameChanged then
                Alert("WARNING: Map name didn't change within " .. MAP_NAME_TIMEOUT .. " seconds!")
                if nameConnection then
                    nameConnection:Disconnect()
                end
                nameChanged = true
            end
        end)
        
        -- Wait for name change or timeout
        repeat 
            task.wait(0.1) 
        until nameChanged
        
        Alert("Proceeding to map processing...")
        OnMapLoad(NewMap)
        Alert("Reconnecting map detector...")
        ConnectMap() -- Reconnect for next map
    end)
    Alert("Map detection is now active!")
end

-- Setup Main Update Loop
if _G.LoopCancel ~= nil then
    _G.LoopCancel = true
    task.wait(0.1)
end
_G.LoopCancel = false

Alert("=== TOMATO AUTO FARM STARTING ===")
Alert("Ready! Starting main update loop...")

while wait(1) do -- Changed to 1 second intervals
    local function Cancel()
        Alert("=== UPDATE LOOP CANCELLED ===")
        if MapDetect then
            MapDetect:Disconnect()
            MapDetect = nil
        end
    end
    
    -- Check if we should connect map detector
    if Check("InLift") and not MapDetect then
        Alert("In lift - connecting map detector")
        ConnectMap()
    elseif not Check("InLift") and MapDetect then
        Alert("Left lift - disconnecting map detector")
        MapDetect:Disconnect()
        MapDetect = nil
    end
    
    -- Check for manual cancellation
    if _G.LoopCancel == true then
        _G.LoopCancel = false
        Cancel()
        break
    end
    
    -- Check for pause/resume
    if getgenv().TomatoAutoFarm == false then
        Alert("=== AUTO FARM PAUSED ===")
        repeat 
            wait(1) 
        until getgenv().TomatoAutoFarm == true or _G.LoopCancel == true
        
        if not _G.LoopCancel then
            Alert("=== AUTO FARM RESUMED ===")
        end
    end
end

Alert("=== SCRIPT ENDED ===")
