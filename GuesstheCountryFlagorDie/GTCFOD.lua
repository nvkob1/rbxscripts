local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

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

if not isfolder("GTCFOD") then makefolder("GTCFOD") end
if not isfile("GTCFOD/options.json") then
    writefile("GTCFOD/options.json", '{"MenuKeybind":"LeftControl","Transparency":false,"Theme":"Darker","Acrylic":false}')
end

local Window = Fluent:CreateWindow({
    Title = "GTCFOD",
    SubTitle = "by nvkob1",
    TabWidth = 160,
    Size = Device,
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options
local currentFlagName = "Searching..."

local FlagLabel = Tabs.Main:AddParagraph({
    Title = "Flag Name",
    Content = currentFlagName
})

Tabs.Main:AddButton({
    Title = "Answer",
    Description = "Submit the flag answer",
    Callback = function()
        local args = {currentFlagName}
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("FlagsService"):WaitForChild("RF"):WaitForChild("Solve"):InvokeServer(unpack(args))
        Fluent:Notify({
            Title = "Answered",
            Content = "Submitted: " .. currentFlagName,
            Duration = 3
        })
    end
})

Tabs.Main:AddButton({
    Title = "Copy Flag Name",
    Description = "Copy flag name to clipboard",
    Callback = function()
        setclipboard(currentFlagName)
        Fluent:Notify({
            Title = "Copied",
            Content = "Flag name copied to clipboard!",
            Duration = 3
        })
    end
})

local AutoAnswerToggle = Tabs.Main:AddToggle("AutoAnswer", {
    Title = "Auto Answer",
    Default = false
})

local DelaySlider = Tabs.Main:AddSlider("AnswerDelay", {
    Title = "Delay Before Answer",
    Description = "Delay in seconds",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 1
})

Tabs.Misc:AddButton({
    Title = "Rejoin",
    Description = "Rejoin current server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

Tabs.Misc:AddButton({
    Title = "Server Hop",
    Description = "Join a different server",
    Callback = function()
        local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in pairs(servers.data) do
            if server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end
})

local AntiAfkToggle = Tabs.Misc:AddToggle("AntiAfk", {
    Title = "Anti-Afk",
    Default = true
})

local function getFlagName()
    local success, result = pcall(function()
        local topFlag = LocalPlayer.PlayerGui.GameUI.REFERENCED__GameUIFrame.TopFlag.FlagImage
        local targetAssetId = topFlag.Image:match("%d+")
        
        local scrollFrame = LocalPlayer.PlayerGui.Practise.REFERENCED__PractiseFrame.Contents.ScrollingFrame
        
        for _, child in pairs(scrollFrame:GetDescendants()) do
            if child:IsA("ImageLabel") and child.Name == "FlagImage" then
                local assetId = child.Image:match("%d+")
                if assetId == targetAssetId then
                    return child.Parent.Name
                end
            end
        end
        
        return "Unknown"
    end)
    
    if success then
        return result
    else
        return "Error"
    end
end

local function isInRound()
    local success, result = pcall(function()
        return workspace.References.Blocks:FindFirstChild(LocalPlayer.Name) ~= nil
    end)
    return success and result
end

local function submitAnswer()
    if currentFlagName ~= "Searching..." and currentFlagName ~= "Unknown" and currentFlagName ~= "Error" then
        local args = {currentFlagName}
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("FlagsService"):WaitForChild("RF"):WaitForChild("Solve"):InvokeServer(unpack(args))
    end
end

task.spawn(function()
    while true do
        local flagName = getFlagName()
        currentFlagName = flagName
        FlagLabel:SetDesc(flagName)
        task.wait(1)
    end
end)

task.spawn(function()
    local currentConnection
    local wasInRound = false
    
    while true do
        local inRound = isInRound()
        
        if Options.AutoAnswer.Value and inRound and not wasInRound then
            if currentConnection then
                currentConnection:Disconnect()
            end
            
            local success, guessTimer = pcall(function()
                return LocalPlayer.PlayerGui.GameUI.REFERENCED__GameUIFrame.TopFlag.GuessTimer
            end)
            
            if success and guessTimer then
                currentConnection = guessTimer:GetPropertyChangedSignal("Text"):Connect(function()
                    if guessTimer.Text == "00:30" and Options.AutoAnswer.Value then
                        local delay = Options.AnswerDelay.Value
                        task.wait(delay)
                        submitAnswer()
                    end
                end)
            end
        end
        
        if not inRound and wasInRound then
            if currentConnection then
                currentConnection:Disconnect()
                currentConnection = nil
            end
        end
        
        wasInRound = inRound
        task.wait(0.5)
    end
end)

LocalPlayer.Idled:Connect(function()
    if Options.AntiAfk.Value then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("GTCFOD")
SaveManager:SetFolder("GTCFOD")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
loadstring(game:HttpGet("https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/FluentUIToggle.lua"))()
Fluent:Notify({
    Title = "GTCFOD",
    Content = "The script has been loaded.",
    Duration = 5
})
