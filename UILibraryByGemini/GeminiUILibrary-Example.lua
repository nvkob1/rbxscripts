-- local GeminiUI = loadfile("GeminiUILibrary.lua")() 
-- If you hosted it online, use:
local GeminiUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/GeminiUILibrary.lua"))()

local Window = GeminiUI:CreateWindow({
    Name = "Gemini Hub - Example",
    Size = UDim2.new(0, 500, 0, 400),
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
