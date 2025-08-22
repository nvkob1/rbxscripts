getgenv().TomatoAutoFarm = false

local ALERTS_ENABLED = true
local EXITREGION_MAX_ATTEMPTS = 50
local CHECK_DELAY = 0.1
local BUTTON_DELAY = 0.2
local EXITREGION_WAIT = 0
local BUTTON_COOLDOWN = 2 -- Seconds to wait before retrying same button
local MAX_BUTTON_DISTANCE = 500 -- Maximum distance to consider a button valid

local LocalPlayer = game:GetService("Players").LocalPlayer
local Multiplayer = Workspace.Multiplayer
local RunService = game:GetService("RunService")

-- Connection cleanup tracking
local ActiveConnections = {}
local ButtonCooldowns = {}
local ProcessedButtons = {} -- Track successfully processed buttons

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

local function GetValidChar()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    local humanoid = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not hrp or humanoid.Health <= 0 then
        return nil
    end
    
    return char
end

local function GetChar()
    return LocalPlayer.Character or (LocalPlayer.CharacterAdded:wait() and LocalPlayer.Character)
end

local function Check(Flag)
    local char = GetValidChar()
    if not char then return false end
    
    local HumanoidRootPart = char:FindFirstChild("HumanoidRootPart")
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

local function IsButtonValid(Button)
    if not Button or not Button.Parent then
        return false
    end
    
    local ButtonHitbox = Button:FindFirstChild("Hitbox")
    if not ButtonHitbox then return false end
    
    local TouchFound = Button:FindFirstChild("TouchInterest", true)
    local GuiFound = Button:FindFirstChildWhichIsA("BillboardGui", true)
    
    return TouchFound ~= nil and GuiFound ~= nil
end

local function IsButtonOnCooldown(Button)
    local buttonId = tostring(Button)
    return ButtonCooldowns[buttonId] and tick() - ButtonCooldowns[buttonId] < BUTTON_COOLDOWN
end

local function SetButtonCooldown(Button)
    local buttonId = tostring(Button)
    ButtonCooldowns[buttonId] = tick()
end

local function IsButtonProcessed(Button)
    local buttonId = tostring(Button)
    return ProcessedButtons[buttonId] == true
end

local function MarkButtonProcessed(Button)
    local buttonId = tostring(Button)
    ProcessedButtons[buttonId] = true
end

local function SafeTeleportToButton(HumanoidRootPart, Humanoid, ButtonHitbox)
    if not HumanoidRootPart or not Humanoid or not ButtonHitbox then
        return false
    end
    
    -- Validate button position
    local buttonPos = ButtonHitbox.Position
    local currentPos = HumanoidRootPart.Position
    
    if (buttonPos - currentPos).Magnitude > MAX_BUTTON_DISTANCE then
        Alert("Button too far away, skipping...")
        return false
    end
    
    local success = pcall(function()
        -- Store original state
        local wasAnchored = HumanoidRootPart.Anchored
        
        -- Ensure character is free
        HumanoidRootPart.Anchored = false
        Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        task.wait(0.05)
        
        -- Teleport to button
        HumanoidRootPart.CFrame = CFrame.new(buttonPos + Vector3.new(0, 3, 0))
        task.wait(0.05)
        
        -- Activate button interaction
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        HumanoidRootPart.Velocity = Vector3.new(0, 50, 0)
        task.wait(0.1)
        
        -- Brief anchor for stability
        HumanoidRootPart.Anchored = true
        task.wait(BUTTON_DELAY)
        
        -- Always unanchor after button interaction
        HumanoidRootPart.Anchored = false
        Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    end)
    
    return success
end

local MapDetect
local ConnectMap

local function OnMapLoad(Map)
    local MapName = Map:WaitForChild("Settings"):GetAttribute("MapName")
    if MapName then
        Alert("Map Loaded: " .. MapName)
    end
    
    if Check("InGame") == false then
        Alert("Skipping due to InGame == false.")
        ConnectMap()
        return
    end
    
    -- Clear previous button tracking
    ButtonCooldowns = {}
    ProcessedButtons = {}
    
    -- Scan for buttons with improved efficiency
    local Buttons = {}
    local ButtonCount = 0
    
    Alert("Scanning for buttons...")
    for i, MapObject in pairs(Map:GetDescendants()) do
        if ButtonCount > 200 then break end -- Reasonable limit
        
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
    
    Alert("Found " .. ButtonCount .. " buttons")
    
    local char = GetValidChar()
    if not char then
        Alert("Invalid character, reconnecting...")
        ConnectMap()
        return
    end
    
    local HumanoidRootPart = char.HumanoidRootPart
    local OriginalCFrame = HumanoidRootPart.CFrame
    
    -- Grab Lost Page
    local LostPage = Map:FindFirstChild("_LostPage", true)
    if LostPage then
        Alert("Getting Lost Page...")
        HumanoidRootPart.Anchored = false
        HumanoidRootPart.CFrame = LostPage.CFrame
        task.wait(0.2)
        HumanoidRootPart.CFrame = OriginalCFrame
        Alert("Got Lost Page.")
    end
    
    -- Grab Escapee
    local Escapee = Map:FindFirstChild("NPC", true)
    if Escapee then
        Alert("Getting Escapee...")
        Escapee = Escapee.Parent
        if Escapee then
            Escapee = Escapee.Contact
        else
            Escapee = Map:FindFirstChild("Contact", true)
        end
        if Escapee then
            HumanoidRootPart.Anchored = false
            HumanoidRootPart.CFrame = Escapee.CFrame
            task.wait(0.2)
            HumanoidRootPart.CFrame = OriginalCFrame
            Alert("Got Escapee.")
        end
    end
    
    -- Auto Farm Loop
    Alert("Commencing Auto Farm with " .. #Buttons .. " buttons")
    local CurrentButton = nil
    local Humanoid = char.Humanoid
    
    -- God mode connection
    local GodMode = AddConnection(Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        Humanoid.Health = 1000
    end))
    
    local Attempts = 0
    local LoopIteration = 0
    local LastButtonCount = #Buttons
    
    while task.wait(CHECK_DELAY) and Check("InGame") do
        LoopIteration += 1
        
        -- Periodic maintenance
        if LoopIteration % 200 == 0 then
            task.wait(0.3)
            collectgarbage("collect")
            Alert("Maintenance: " .. #Buttons .. " buttons remaining")
        end
        
        local char = GetValidChar()
        if not char then
            Alert("Character became invalid, breaking...")
            break
        end
        
        local ExitRegion = Map:FindFirstChild("ExitRegion", true)
        local HumanoidRootPart = char.HumanoidRootPart
        local Humanoid = char.Humanoid
        
        if not HumanoidRootPart then break end
        
        Humanoid.Jump = true
        local FoundValidButton = false
        
        if not ExitRegion then
            -- Clean up invalid buttons first
            for i = #Buttons, 1, -1 do
                local Button = Buttons[i]
                if not IsButtonValid(Button) or IsButtonProcessed(Button) then
                    table.remove(Buttons, i)
                end
            end
            
            -- Process valid buttons
            for i, Button in pairs(Buttons) do
                if IsButtonValid(Button) and not IsButtonOnCooldown(Button) and not IsButtonProcessed(Button) then
                    CurrentButton = Button
                    FoundValidButton = true
                    
                    Alert("Processing button " .. i .. "/" .. #Buttons)
                    
                    local ButtonHitbox = Button:FindFirstChild("Hitbox")
                    if ButtonHitbox then
                        -- Attempt to interact with button
                        local success = SafeTeleportToButton(HumanoidRootPart, Humanoid, ButtonHitbox)
                        
                        if success then
                            SetButtonCooldown(Button)
                            
                            -- Check if button was successfully pressed
                            task.wait(0.3)
                            if not IsButtonValid(Button) then
                                MarkButtonProcessed(Button)
                                Alert("Button pressed successfully!")
                            else
                                Alert("Button press may have failed, will retry later")
                            end
                        else
                            Alert("Failed to teleport to button safely")
                            SetButtonCooldown(Button)
                        end
                    end
                    
                    break -- Process one button per iteration
                end
            end
            
            -- Alert if no valid buttons found
            if not FoundValidButton and #Buttons == 0 then
                Alert("No more buttons to process, waiting for exit...")
            elseif not FoundValidButton then
                Alert("All buttons on cooldown, waiting...")
            end
            
        elseif ExitRegion then
            Alert("Exit region found, attempting to exit...")
            HumanoidRootPart.Anchored = false
            
            if Attempts < EXITREGION_MAX_ATTEMPTS then
                Attempts += 1
                HumanoidRootPart.CFrame = ExitRegion.CFrame
                Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
                HumanoidRootPart.Velocity = Vector3.new(50, -1, 50)
                task.wait(0.1)
                
                if (HumanoidRootPart.Position - ExitRegion.Position).Magnitude <= 5 then
                    Attempts += 1
                end
            else
                Alert("Teleported to ExitRegion successfully.")
                break
            end
        end
        
        -- Check for cancellation
        if _G.LoopCancel == true or getgenv().TomatoAutoFarm == false then
            Alert("Auto farm cancelled by user")
            break
        end
    end
    
    -- Cleanup
    Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    if HumanoidRootPart then
        HumanoidRootPart.Anchored = false
    end
    
    task.wait(EXITREGION_WAIT)
    Alert("Map complete! Processed buttons, cleaning up...")
    
    -- Proper cleanup
    CleanupConnections()
    ButtonCooldowns = {}
    ProcessedButtons = {}
    Buttons = nil
    CurrentButton = nil
    
    Alert("Preparing for next Map! Resetting character...")
    pcall(function()
        GetChar().Head:Destroy()
    end)
    
    Alert("Waiting for respawn...")
    task.wait(3)
    
    -- Wait for valid character
    local newChar = GetValidChar()
    local attempts = 0
    while not newChar and attempts < 50 do
        task.wait(0.2)
        newChar = GetValidChar()
        attempts += 1
    end
    
    if newChar then
        local HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart", 5)
        if HumanoidRootPart then
            HumanoidRootPart.Anchored = false
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
            
            Alert("Moving to lift...")
            repeat
                task.wait(0.1)
                if HumanoidRootPart then
                    HumanoidRootPart.Velocity = Vector3.new(0, 0, 100)
                end
            until Check("InLift") or not GetValidChar()
        end
    end
    
    Alert("Reconnecting map detection...")
    ConnectMap()
end

ConnectMap = function()
    -- Cleanup existing connection
    if MapDetect then
        MapDetect:Disconnect()
        MapDetect = nil
    end
    
    MapDetect = AddConnection(Multiplayer.ChildAdded:Connect(function(NewMap)
        -- Disconnect this connection since we're handling a new map
        if MapDetect then
            MapDetect:Disconnect()
            MapDetect = nil
        end
        
        -- Wait for map to fully load
        NewMap:GetPropertyChangedSignal("Name"):Wait()
        task.wait(0.5) -- Additional safety wait
        
        OnMapLoad(NewMap)
    end))
    
    Alert("Map detection connected and ready.")
end

-- Initialize cleanup
if _G.LoopCancel ~= nil then
    _G.LoopCancel = true
    task.wait(0.5)
end

CleanupConnections()
ButtonCooldowns = {}
ProcessedButtons = {}

_G.LoopCancel = false
Alert("Tomato Auto Farm Ready! Starting main loop...")

-- Main loop with improved resource management
local MainLoopIteration = 0
while wait(0.1) do
    MainLoopIteration += 1
    
    -- Periodic maintenance
    if MainLoopIteration % 600 == 0 then -- Every 60 seconds
        task.wait(1)
        collectgarbage("collect")
        Alert("Performed periodic maintenance cleanup.")
        
        -- Clear old cooldowns (older than 60 seconds)
        local currentTime = tick()
        for buttonId, cooldownTime in pairs(ButtonCooldowns) do
            if currentTime - cooldownTime > 60 then
                ButtonCooldowns[buttonId] = nil
            end
        end
    end
    
    local function Cancel()
        Alert("Main loop cancelled, cleaning up...")
        CleanupConnections()
        if MapDetect then
            MapDetect:Disconnect()
            MapDetect = nil
        end
        ButtonCooldowns = {}
        ProcessedButtons = {}
    end
    
    -- Handle map detection based on location
    if Check("InLift") == true and not MapDetect then
        Alert("In lift, connecting map detection...")
        ConnectMap()
    elseif Check("InLift") == false and MapDetect then
        Alert("Left lift, disconnecting map detection...")
        if MapDetect then
            MapDetect:Disconnect()
            MapDetect = nil
        end
    end
    
    -- Handle cancellation
    if _G.LoopCancel == true then
        _G.LoopCancel = false
        Cancel()
        break
    end
    
    -- Handle pause/resume
    if getgenv().TomatoAutoFarm == false then
        Alert("Auto Farm Paused!")
        repeat 
            wait(0.5)
        until getgenv().TomatoAutoFarm == true or _G.LoopCancel == true
        Alert("Auto Farm Resumed!")
    end
end

Alert("Auto farm script ended.")
