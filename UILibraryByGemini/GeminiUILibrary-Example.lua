-- local GeminiUI = loadfile("GeminiUILibrary.lua")() 
-- If you hosted it online, use:
local GeminiUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/UILibraryByGemini/GeminiUILibrary.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local Device;
function checkDevice()
    if LocalPlayer then
        if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
            Device = UDim2.new(0, 500, 0, 320)
        else
            Device = UDim2.new(0, 500, 0, 400)
        end
    end
end
checkDevice()

local Window = GeminiUI:CreateWindow({
    Name = "Gemini Hub - Example",
    Size = Device,
    ThemeColor = Color3.fromRGB(255, 85, 127), -- Pinkish theme
    ToggleKey = Enum.KeyCode.RightControl -- Default key to toggle the UI visibility (PC)
})

-- Creating Tabs
local MainTab = Window:CreateTab("Main")
local PlayerTab = Window:CreateTab("Player")
local SettingsTab = Window:CreateTab("Settings")

-- == Main Tab ==
MainTab:CreateButton({
    Name = "Print Hello World",
    Callback = function()
        print("Hello World! This is a button test.")
    end
})

MainTab:CreateToggle({
    Name = "Auto Farm (Example)",
    Default = false,
    Callback = function(state)
        print("Auto Farm is now:", state)
        -- Auto Farm logic would go here
    end
})

-- == Player Tab ==
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 150,
    Default = 16,
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = value
            player.Character.Humanoid.UseJumpPower = true
        end
    end
})

PlayerTab:CreateDropdown({
    Name = "Teleport To",
    Options = {"Spawn", "VIP Area", "Shop", "Boss Arena"},
    Default = "Spawn",
    Callback = function(selectedOption)
        print("Teleporting to:", selectedOption)
        -- Add teleport logic here
    end
})

-- Dynamic Inventory / Weapon Dropdown with AutoRefresh
local function GetWeapons()
    local items = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, v in ipairs(backpack:GetChildren()) do
            if v:IsA("Tool") then
                table.insert(items, v.Name)
            end
        end
    end

    if LocalPlayer.Character then
        for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("Tool") and not table.find(items, v.Name) then
                table.insert(items, v.Name)
            end
        end
    end

    return items
end

PlayerTab:CreateDropdown({
    Name = "Select Weapon",
    Options = GetWeapons, -- Pass function reference directly without parentheses
    AutoRefresh = true,   -- Automatically refreshes when Backpack or Character tools change
    Default = getgenv().Weapon or "",
    Callback = function(selectedOption)
        getgenv().Weapon = selectedOption
        print("Selected Weapon:", selectedOption)
    end
})

-- == Settings Tab ==
SettingsTab:CreateKeybind({
    Name = "UI Toggle Key",
    Default = Enum.KeyCode.RightControl,
    Callback = function(newKey)
        print("Changed UI Toggle Key to:", newKey.Name)
        Window:ChangeToggleKey(newKey)
    end
})

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        -- The UI is named "GeminiUI" when created
        local ui = game:GetService("CoreGui"):FindFirstChild("GeminiUI") 
            or game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("GeminiUI")
        
        if ui then
            ui:Destroy()
        end
    end
})
