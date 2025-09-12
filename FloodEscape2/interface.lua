local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local Multiplayer = Workspace.Multiplayer
local icon = player.PlayerGui:WaitForChild("GameGui"):WaitForChild("HUD"):WaitForChild("Main"):WaitForChild("MenuButtons"):WaitForChild("Content"):GetChildren()[8].Icon
local remote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("dKgyIXnLdhwvSyEorkEWJJAkgUslGCtR")

local MapDetect
local AutoFarmEnabled = true
local AntiAfkEnabled = true
local AntiAfkConnection

local Device;
function checkDevice()
    if player then
        if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
            Device = UDim2.fromOffset(480, 360)
        else
            Device = UDim2.fromOffset(580, 460)
        end
    end
end
checkDevice()

if not isfolder("FE2AutoFarm") then makefolder("FE2AutoFarm") end
if not isfile("FE2AutoFarm/options.json") then
writefile("FE2AutoFarm/options.json", '{"MenuKeybind":"LeftControl","Transparency":false,"Theme":"Darker","Acrylic":false}')
end

local Window = Fluent:CreateWindow({
    Title = "FE2 Auto Farm",
    SubTitle = "by nvkob1",
    TabWidth = 160,
    Size = Device,
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

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
    return player.Character or (player.CharacterAdded:Wait() and player.Character)
end

local function Check(Flag)
    local HumanoidRootPart = GetChar():FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return false end
    if Flag == "InGame" then
        if HumanoidRootPart.Position.X > 50 then
            return true
        end
    end
    return false
end

local function isPlayerAlive()
    return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

local function OnMapLoad(Map)
    if not AutoFarmEnabled then return end
    Map:GetPropertyChangedSignal("Name"):Wait()
    if not Check("InGame") then return end
    local Buttons = {}
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
                Hitbox.Name = "Hitbox"
                table.insert(Buttons, MapObject)
            end
        end
    end
    local HumanoidRootPart = GetChar().HumanoidRootPart
    local OriginalCFrame = HumanoidRootPart.CFrame
    local LostPage = Map:FindFirstChild("_LostPage", true)
    if LostPage then
        HumanoidRootPart.CFrame = LostPage.CFrame
        task.wait()
        HumanoidRootPart.CFrame = OriginalCFrame
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
            task.wait()
            HumanoidRootPart.CFrame = OriginalCFrame
        end
    end
    local Humanoid = GetChar().Humanoid
    local GodMode = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        Humanoid.Health = 1000
    end)
    local Attempts = 0
    while task.wait() and Check("InGame") and AutoFarmEnabled do
        local ExitRegion = Map:FindFirstChild("ExitRegion", true)
        Humanoid.Jump = true
        local FailedScan = true
        if not ExitRegion then
            for i, Button in pairs(Buttons) do
                local ButtonHitbox = Button:FindFirstChild("Hitbox")
                if ButtonHitbox then
                    local TouchFound = Button:FindFirstChild("TouchInterest", true)
                    local GuiFound = Button:FindFirstChildWhichIsA("BillboardGui", true)
                    if (TouchFound and GuiFound) then
                        FailedScan = false
                        HumanoidRootPart.Anchored = false
                        HumanoidRootPart.CFrame = CFrame.new(ButtonHitbox.Position)
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        HumanoidRootPart.Velocity = Vector3.new(0, 100, 0)
                        task.wait(.1)
                        HumanoidRootPart.Anchored = true
                        task.wait()
                    end
                end
            end
        elseif ExitRegion then
            HumanoidRootPart.Anchored = false
            if Attempts < 50 then
                Attempts += 1
                HumanoidRootPart.CFrame = ExitRegion.CFrame
                Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
                HumanoidRootPart.Velocity = Vector3.new(50, -1, 50)
                task.wait()
                if (HumanoidRootPart.Position - ExitRegion.Position).Magnitude <= 5 then
                    Attempts += 1
                end
            else
                break
            end
        end
    end
    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    task.wait()
    GodMode:Disconnect()
    GetChar().Head:Destroy()
end

local function ConnectMap()
    MapDetect = Multiplayer.ChildAdded:Connect(function(NewMap)
        MapDetect:Disconnect()
        MapDetect = nil
        OnMapLoad(NewMap)
    end)
end

local function onPlayerRespawn()
    RunService.Heartbeat:Connect(function()
        if isPlayerAlive() and icon.Image == "rbxassetid://12812989387" and AutoFarmEnabled then
            remote:FireServer()
            if not MapDetect then
                ConnectMap()
            end
        end
    end)
end

-- UI Setup
local AutoFarmToggle = Tabs.Main:AddToggle("AutoFarm", {Title = "Auto Farm", Default = true})

AutoFarmToggle:OnChanged(function()
    AutoFarmEnabled = AutoFarmToggle.Value
    if AutoFarmEnabled then
        Fluent:Notify({
            Title = "AutoFarm",
            Content = "AutoFarm enabled",
            Duration = 3
        })
        if isPlayerAlive() then
            onPlayerRespawn()
        end
    else
        Fluent:Notify({
            Title = "AutoFarm", 
            Content = "AutoFarm disabled",
            Duration = 3
        })
        if MapDetect then
            MapDetect:Disconnect()
            MapDetect = nil
        end
    end
end)

local AntiAfkToggle = Tabs.Main:AddToggle("AntiAfk", {Title = "Anti AFK", Default = true})

AntiAfkToggle:OnChanged(function()
    AntiAfkEnabled = AntiAfkToggle.Value
    if AntiAfkEnabled then
        AntiAfkConnection = player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    else
        if AntiAfkConnection then
            AntiAfkConnection:Disconnect()
            AntiAfkConnection = nil
        end
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FE2AutoFarm")
SaveManager:SetFolder("FE2AutoFarm")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

player.CharacterAdded:Connect(onPlayerRespawn)

Window:SelectTab(1)

-- UI Toggle Button
loadstring(game:HttpGet("https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/FluentUIToggle.lua"))()

Fluent:Notify({
    Title = "AutoFarm",
    Content = "Script loaded successfully",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
