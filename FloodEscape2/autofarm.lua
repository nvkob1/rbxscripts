getgenv().TomatoAutoFarm = false

local ALERTS_ENABLED = true
local EXITREGION_MAX_ATTEMPTS = 50
local CHECK_DELAY = 0
local BUTTON_DELAY = 0
local EXITREGION_WAIT = 0

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
    local Character = GetChar()
    if not Character then return false end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
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
    -- Add safety wait for map to fully load
    task.wait(0.5)
    
    local MapName = Map:WaitForChild("Settings"):GetAttribute("MapName")
    if MapName then
        Alert("Map Loaded!" .. MapName)
    end
    
    -- Wait for character to be properly positioned
    local maxWait = 10
    local waited = 0
    while waited < maxWait do
        if Check("InGame") == true then
            break
        end
        task.wait(0.1)
        waited = waited + 0.1
    end
    
    if Check("InGame") == false then
        Alert("Skipping due to InGame == false.")
        return -- Exit the function instead of continuing
    end
    
    Alert("InGame check passed, starting scan...")
    
    -- if Map Loaded and InGame code after this will run.
    local Buttons = {}
    -- Single Scan of Map to reduce lag.
    for i, MapObject in pairs(Map:GetDescendants()) do
        if isRandomString(MapObject.Name) and MapObject.ClassName == "Model" then
            local Hitbox
            for i, Candidate in pairs(MapObject:GetChildren()) do
                if Candidate:IsA("BasePart") and tostring(Candidate.BrickColor) ~= "Medium stone grey" then
                    Hitbox = Candidate
                    break
                end
            end
            if Hitbox and isRandomString(Hitbox.Name) then
                -- Confirmed Buttonness
                Hitbox.Name = "Hitbox"
                table.insert(Buttons, MapObject)
            end
        end
    end
    
    Alert("Found " .. #Buttons .. " buttons")
    
    -- Ensure character and components exist
    local Character = GetChar()
    if not Character then
        Alert("Character not found, aborting map")
        return
    end
    
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)
    if not HumanoidRootPart then
        Alert("HumanoidRootPart not found, aborting map")
        return
    end
    
    -- Grab Lost Page and Escapee
    local OriginalCFrame = HumanoidRootPart.CFrame
    local LostPage = Map:FindFirstChild("_LostPage", true)
    if LostPage then
        HumanoidRootPart.CFrame = LostPage.CFrame
        task.wait()
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
            local OriginalCFrame = HumanoidRootPart.CFrame
            HumanoidRootPart.CFrame = Escapee.CFrame
            task.wait()
            HumanoidRootPart.CFrame = OriginalCFrame
            Alert("Got Escapee.")
        end
    end
    
    -- Auto Farm Loop
    Alert("Commencing Auto Farm")
    local CurrentButton = nil
    local Humanoid = Character:WaitForChild("Humanoid", 5)
    if not Humanoid then
        Alert("Humanoid not found, aborting map")
        return
    end
    
    local GodMode
    GodMode = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        Humanoid.Health = 1000
    end)
    local Attempts = 0
    local DifferentScan = false
    
    while task.wait(CHECK_DELAY) and Check("InGame") do
        local ExitRegion = Map:FindFirstChild("ExitRegion", true)
        -- Refresh character references in case of respawn
        Character = GetChar()
        if not Character then break end
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        Humanoid = Character:FindFirstChild("Humanoid")
        if not HumanoidRootPart or not Humanoid then break end
        
        Humanoid.Jump = true
        local FailedScan = true
        
        if not ExitRegion then
            for i, Button in pairs(Buttons) do
                local ButtonHitbox = Button:FindFirstChild("Hitbox")
                if ButtonHitbox then
                    CurrentButton = Button
                    local ButtonID = tostring(i)
                    local ButtonColor = tostring(Button.Hitbox.BrickColor)
                    local TouchFound = Button:FindFirstChild("TouchInterest", true)
                    local GuiFound = Button:FindFirstChildWhichIsA("BillboardGui", true)
                    --if ButtonColor ~= "Black" and ButtonColor ~= "Bright yellow" then
                    if (TouchFound and GuiFound) then
                        FailedScan = false
                        -- Teleport to button + bypass button anti-cheat.
                        HumanoidRootPart.Anchored = false
                        local OriginalCFrame = HumanoidRootPart.CFrame
                        HumanoidRootPart.CFrame = CFrame.new(ButtonHitbox.Position)
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        HumanoidRootPart.Velocity = Vector3.new(0, 100, 0)
                        task.wait(.1)
                        HumanoidRootPart.Anchored = true
                        task.wait(BUTTON_DELAY)
                        --task.wait(BUTTON_DELAY)
                        --break
                    end
                end
            end
            if FailedScan == true then
                DifferentScan = true
                -- Add debug info when no buttons found
                Alert("No valid buttons found in this scan - buttons may be pressed already")
            end
            --HumanoidRootPart.Velocity = Vector3.new(0,)
        elseif ExitRegion then
            HumanoidRootPart.Anchored = false
            if Attempts < EXITREGION_MAX_ATTEMPTS then
                Attempts += 1
                -- Teleport to ExitRegion
                HumanoidRootPart.CFrame = ExitRegion.CFrame -- Vector3.new(0, 10, 0)
                Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
                HumanoidRootPart.Velocity = Vector3.new(50, -1, 50)
                task.wait()
                if (HumanoidRootPart.Position - ExitRegion.Position).Magnitude <= 5 then
                    -- Speed it up.
                    Attempts += 1
                end
            else
                Alert("Teleported to ExitRegion.")
                break
            end
        end
    end
    
    -- Ensure character still exists before cleanup
    Character = GetChar()
    if Character then
        Humanoid = Character:FindFirstChild("Humanoid")
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
    Character = GetChar()
    if Character then
        local Head = Character:FindFirstChild("Head")
        if Head then
            Head:Destroy()
        end
    end
    
    Alert("Waiting for Player..")
    task.wait(2)
    
    Character = GetChar()
    if Character then
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
            repeat
                task.wait()
                HumanoidRootPart.Velocity = Vector3.new(0, 0, 100)
            until Check("InLift")
        end
    end
    --ConnectMap()
end

ConnectMap = function()
    MapDetect = Multiplayer.ChildAdded:Connect(function(NewMap)
        if MapDetect then
            MapDetect:Disconnect()
            MapDetect = nil
        end
        
        -- Add safety check for map object
        if not NewMap or not NewMap.Parent then
            Alert("Invalid map detected, reconnecting...")
            task.wait(1)
            ConnectMap()
            return
        end
        
        Alert("Connecting..")
        
        -- Handle both fast and slow map loading
        local function ProcessMap()
            if NewMap and NewMap.Parent then
                OnMapLoad(NewMap)
            else
                Alert("Map became invalid, reconnecting...")
                task.wait(1)
                ConnectMap()
                return
            end
        end
        
        -- Check if map name already changed (fast loading)
        if NewMap.Name ~= "Map" and NewMap.Name ~= "" then
            -- Map already loaded, process immediately
            Alert("Map loaded quickly, processing immediately")
            ProcessMap()
        else
            -- Map still loading, wait for name change
            Alert("Waiting for map name to change...")
            local success, err = pcall(function()
                NewMap:GetPropertyChangedSignal("Name"):Wait()
            end)
            
            if success then
                ProcessMap()
            else
                Alert("Name change wait failed, trying direct processing...")
                task.wait(0.5) -- Give it a moment
                ProcessMap()
            end
        end
    end)
end

-- Setup Main Update Loop
if _G.LoopCancel ~= nil then
    _G.LoopCancel = true
    task.wait(.1)
end
_G.LoopCancel = false
Alert("Ready! Starting Update Loop.")

while wait() do
    local function Cancel()
        Alert("Update Loop cancelled.")
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
        repeat wait() until getgenv().TomatoAutoFarm == true or _G.LoopCancel == true
        Alert("Auto Farm Resumed!")
    end
end
