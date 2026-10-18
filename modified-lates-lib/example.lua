getgenv().AutoSave = true


--// Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

--// Device
local Device;
function checkDevice()
if LocalPlayer then
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    Device = UDim2.fromOffset(470, 270)
else
    Device = UDim2.fromOffset(570, 370)
end
end
end
checkDevice()

--// Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/modified-lates-lib/lates-lib-source.lua"))()
local Window = Library:CreateWindow({
	Title = "LatesLibs",
	Theme = "Dark",
	Size = Device,
	Transparency = 0,
	Blurring = false,
	DropdownSearch = true,
    ForceCursorShow = false,   -- Force Show Roblox Cursor When Cursor at UI
	MinimizeKeybind = Enum.KeyCode.RightControl,
	Folder = "lates-libs-example",
	FileName = LocalPlayer.Name..".json",
})

Window:CreateToggleButton()

local Themes = {
	Light = {
		--// Frames:
		Primary = Color3.fromRGB(232, 232, 232),
		Secondary = Color3.fromRGB(255, 255, 255),
		Component = Color3.fromRGB(245, 245, 245),
		Interactables = Color3.fromRGB(235, 235, 235),

		--// Text:
		Tab = Color3.fromRGB(50, 50, 50),
		Title = Color3.fromRGB(0, 0, 0),
		Description = Color3.fromRGB(100, 100, 100),

		--// Outlines:
		Shadow = Color3.fromRGB(255, 255, 255),
		Outline = Color3.fromRGB(210, 210, 210),

		--// Image:
		Icon = Color3.fromRGB(100, 100, 100),
	},
	
	Dark = {
		--// Frames:
		Primary = Color3.fromRGB(30, 30, 30),
		Secondary = Color3.fromRGB(35, 35, 35),
		Component = Color3.fromRGB(40, 40, 40),
		Interactables = Color3.fromRGB(45, 45, 45),

		--// Text:
		Tab = Color3.fromRGB(200, 200, 200),
		Title = Color3.fromRGB(240,240,240),
		Description = Color3.fromRGB(200,200,200),

		--// Outlines:
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(40, 40, 40),

		--// Image:
		Icon = Color3.fromRGB(220, 220, 220),
	},
	
	Void = {
		--// Frames:
		Primary = Color3.fromRGB(15, 15, 15),
		Secondary = Color3.fromRGB(20, 20, 20),
		Component = Color3.fromRGB(25, 25, 25),
		Interactables = Color3.fromRGB(30, 30, 30),

		--// Text:
		Tab = Color3.fromRGB(200, 200, 200),
		Title = Color3.fromRGB(240,240,240),
		Description = Color3.fromRGB(200,200,200),

		--// Outlines:
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(40, 40, 40),

		--// Image:
		Icon = Color3.fromRGB(220, 220, 220),
	},

}

--// Set the default theme
Window:SetTheme(Themes.Dark)

--// Sections
Window:AddTabSection({
	Name = "Main",
	Order = 1,
})

Window:AddTabSection({
	Name = "Settings",
	Order = 2,
})

--// Tab [MAIN]

local Main = Window:AddTab({
	Title = "Components",
	Section = "Main",
	Icon = "rbxassetid://11963373994"
})

Window:AddSection({ Name = "Non Interactable", Tab = Main }) 


local StatusParagraph = Window:AddParagraph({
	Title = "Status",
	Description = "Waiting for action...",
	Tab = Main
})

Window:AddSection({ Name = "Interactable", Tab = Main }) 

local clickCount = 0
local messages = {
	{ title = "Status", desc = "Waiting for action..." },
	{ title = "Status — Active!", desc = "Button was clicked once." },
	{ title = "Status — Running!", desc = "Something is happening right now..." },
	{ title = "Status — Done!", desc = "All finished. Click again to reset." },
}

Window:AddButton({
	Title = "Update Paragraph",
	Description = "Click to change the paragraph text above",
	Tab = Main,
	Callback = function()
		clickCount = (clickCount % #messages) + 1
		local msg = messages[clickCount]
		StatusParagraph:Set(msg.title, msg.desc)
	end,
})

Window:AddSlider({
	Title = "Slider",
	Description = "Sliding",
	Tab = Main,
	MaxValue = 100,
	Flag = "Slider1",
	Callback = function(Amount) 
		warn(Amount);
	end,
}) 

Window:AddToggle({
	Title = "Toggle",
	Description = "Switching",
	Tab = Main,
	Flag = "Toggle1",
	Callback = function(Boolean) 
		warn(Boolean);
	end,
}) 

Window:AddInput({
	Title = "Input",
	Description = "Typing",
	Tab = Main,
	Flag = "Input1",
	Callback = function(Text) 
		warn(Text);
	end,
}) 


Window:AddDropdown({
	Title = "Dropdown",
	Description = "Selecting",
	Tab = Main,
	Options = {
		["An Option"] = "hi",
		["And another"] = "hi",
		["Another"] = "hi",
	},
	Flag = "Dropdown1",
	Callback = function(Number) 
		warn(Number);
	end,
}) 

Window:AddKeybind({
	Title = "Keybind",
	Description = "Binding",
	Tab = Main,
	Flag = "Keybind1",
	Callback = function(Key) 
		warn("Key Set")
	end,
}) 

--// Tab [SETTINGS]
local Keybind = nil
local Settings = Window:AddTab({
	Title = "Settings",
	Section = "Settings",
	Icon = "rbxassetid://11293977610",
})

-- Load Settings Tab
Window:BuildSettingsSection(Settings, Themes)

-- Load Config
Window:LoadConfig() 

Window:Notify({
	Title = "Hello World!",
	Description = "Press Left Alt to Minimize and Open the tab!", 
	Duration = 10
})

--// Keybind Example
UserInputService.InputBegan:Connect(function(Key) 
	if Key == Keybind then
		warn("You have pressed the minimize keybind!");
	end
end)
