getgenv().AutoSave = true


--// Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService");
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
	Title = "???",
	Theme = "Dark",
	Size = Device,
	Transparency = 0.2,
	Blurring = true,
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


Window:AddParagraph({
	Title = "Paragraph",
	Description = "Insert any important text here.",
	Tab = Main
}) 

Window:AddSection({ Name = "Interactable", Tab = Main }) 

Window:AddButton({
	Title = "Button",
	Description = "I wonder what this does",
	Tab = Main,
	Callback = function() 
		Window:Notify({
			Title = "hi",
			Description = "i'm a notification", 
			Duration = 5
		})
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

Window:AddSection({ Name = "Server", Tab = Settings }) 

local function rejoin()
	if #Players:GetPlayers() <= 1 then
		Players.LocalPlayer:Kick("\nRejoining...")
		wait()
		TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
	else
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
	end
end

function ServerHop()
	local placeId = game.PlaceId
	local success, servers = pcall(function()
		return HttpService:JSONDecode(
			game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
		).data
	end)

	if success and servers then
		local validServers = {}
		for _, server in ipairs(servers) do
			if server.playing < server.maxPlayers and server.id ~= game.JobId then
				table.insert(validServers, server)
			end
		end

		if #validServers > 0 then
			local chosenServer = validServers[math.random(1, #validServers)]
			TeleportService:TeleportToPlaceInstance(placeId, chosenServer.id, LocalPlayer)
		else
			TeleportService:Teleport(placeId, LocalPlayer)
		end
	else
		TeleportService:Teleport(placeId, LocalPlayer)
	end
end

local antiAfkConnection
local function EnableAntiAfk()
    antiAfkConnection = LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end
local function DisableAntiAfk()
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
end

local autoRejoinConnection
local function EnableAutoRejoin()
	autoRejoinConnection = GuiService.ErrorMessageChanged:Connect(function()
		rejoin()
	end)
end
local function DisableAutoRejoin()
	if autoRejoinConnection then
		autoRejoinConnection:Disconnect()
		autoRejoinConnection = nil
	end
end

Window:AddToggle({
	Title = "Anti-Afk",
	Description = "No more AFK kick.",
	Default = true,
	Tab = Settings,
	Callback = function(Boolean) 
		if Boolean then
			EnableAntiAfk()
		else
			DisableAntiAfk()
		end
	end,
}) 
EnableAntiAfk()
Window:AddToggle({
	Title = "Auto Rejoin",
	Description = "Automatic Rejoin When Disconnected.",
	Default = true,
	Tab = Settings,
	Callback = function(Boolean) 
		if Boolean then
			EnableAutoRejoin()
		else
			DisableAutoRejoin()
		end
	end,
}) 
EnableAutoRejoin()
Window:AddButton({
	Title = "Rejoin",
	Description = "Rejoin current server.",
	Tab = Settings,
	Callback = function() 
		rejoin()
	end,
})
Window:AddButton({
	Title = "Server Hop",
	Description = "Join another server.",
	Tab = Settings,
	Callback = function() 
		ServerHop()
	end,
})
Window:AddButton({
	Title = "Infinite Yield",
	Description = "Admin commands script.",
	Tab = Settings,
	Callback = function() 
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
	end,
}) 


Window:AddSection({ Name = "UI", Tab = Settings }) 

Window:AddKeybind({
	Title = "Minimize Keybind",
	Description = "Set the keybind for Minimizing",
	Tab = Settings,
	Callback = function(Key) 
		Window:SetSetting("Keybind", Key)
	end,
}) 

Window:AddDropdown({
	Title = "Set Theme",
	Description = "Set the theme of the library!",
	Tab = Settings,
	Options = {
		["Light Mode"] = "Light",
		["Dark Mode"] = "Dark",
		["Extra Dark"] = "Void",
	},
	Default = "Dark",
	Flag = "Theme",
	Callback = function(Theme) 
		Window:SetTheme(Themes[Theme])
	end,
}) 

Window:AddToggle({
	Title = "UI Blur",
	Description = "If enabled, must have your Roblox graphics set to 8+ for it to work",
	Default = true,
	Flag = "Blur",
	Tab = Settings,
	Callback = function(Boolean) 
		Window:SetSetting("Blur", Boolean)
	end,
}) 


Window:AddSlider({
	Title = "UI Transparency",
	Description = "Set the transparency of the UI",
	Tab = Settings,
	AllowDecimals = true,
	MaxValue = 1,
	Default = 0.2,
	Flag = "Transparency",
	Callback = function(Amount) 
		Window:SetSetting("Transparency", Amount)
	end,
})

Window:AddSection({ Name = "Config", Tab = Settings })

Window:AddToggle({
	Title = "Auto Save",
	Description = "Automatically saves settings.",
	Default = true,
	Tab = Settings,
	Callback = function(Boolean)
		getgenv().AutoSave = Boolean
		if Boolean then
			task.spawn(function()
				while getgenv().AutoSave do
					task.wait(1)
					if getgenv().AutoSave then
						Window:SaveConfig()
					end
				end
			end)
		end
	end,
})
if getgenv().AutoSave then
	task.spawn(function()
		while getgenv().AutoSave do
			task.wait(1)
			if getgenv().AutoSave then
				Window:SaveConfig()
			end
		end
	end)
end

Window:AddButton({
	Title = "Save Settings",
	Description = "Manually save current settings.",
	Tab = Settings,
	Callback = function()
		Window:SaveConfig()
	end,
})

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
