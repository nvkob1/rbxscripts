--[[
	User Interface Library
	Made by Late
]]

--// Connections
local GetService = game.GetService
local Connect = game.Loaded.Connect
local Wait = game.Loaded.Wait
local Clone = game.Clone 
local Destroy = game.Destroy 

if (not game:IsLoaded()) then
	local Loaded = game.Loaded
	Loaded.Wait(Loaded);
end

--// Important 
local Setup = {
	Keybind = Enum.KeyCode.LeftControl,
	Transparency = 0.2,
	ThemeMode = "Dark",
	Size = nil,
}

local Theme = { --// (Dark Theme)
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
}

--// Services & Functions
local Type, Blur = nil
local LocalPlayer = GetService(game, "Players").LocalPlayer;
local Services = {
	Insert = GetService(game, "InsertService");
	Tween = GetService(game, "TweenService");
	Run = GetService(game, "RunService");
	Input = GetService(game, "UserInputService");
	Http = GetService(game, "HttpService");
}

local Player = {
	Mouse = LocalPlayer:GetMouse();
	GUI = LocalPlayer.PlayerGui;
}

local Tween = function(Object : Instance, Speed : number, Properties : {},  Info : { EasingStyle: Enum?, EasingDirection: Enum? })
	local Style, Direction

	if Info then
		Style, Direction = Info["EasingStyle"], Info["EasingDirection"]
	else
		Style, Direction = Enum.EasingStyle.Sine, Enum.EasingDirection.Out
	end

	return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end

local SetProperty = function(Object: Instance, Properties: {})
	for Index, Property in next, Properties do
		Object[Index] = (Property);
	end

	return Object
end

local Multiply = function(Value, Amount)
	local New = {
		Value.X.Scale * Amount;
		Value.X.Offset * Amount;
		Value.Y.Scale * Amount;
		Value.Y.Offset * Amount;
	}

	return UDim2.new(unpack(New))
end

local Color = function(Color, Factor, Mode)
	Mode = Mode or Setup.ThemeMode

	if Mode == "Light" then
		return Color3.fromRGB((Color.R * 255) - Factor, (Color.G * 255) - Factor, (Color.B * 255) - Factor)
	else
		return Color3.fromRGB((Color.R * 255) + Factor, (Color.G * 255) + Factor, (Color.B * 255) + Factor)
	end
end

local Drag = function(Canvas)
	if Canvas then
		local Dragging;
		local DragInput;
		local Start;
		local StartPosition;

		local function Update(input)
			local delta = input.Position - Start
			Canvas.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
		end

		Connect(Canvas.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				Dragging = true
				Start = Input.Position
				StartPosition = Canvas.Position

				Connect(Input.Changed, function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)

		Connect(Canvas.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				DragInput = Input
			end
		end)

		Connect(Services.Input.InputChanged, function(Input)
			if Input == DragInput and Dragging and not Type then
				Update(Input)
			end
		end)
	end
end

Resizing = { 
	TopLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, -1)};
	TopRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, -1)};
	BottomLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, 1)};
	BottomRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, 1)};
}

Resizeable = function(Tab, Minimum, Maximum)
	task.spawn(function()
		local MousePos, Size, UIPos = nil, nil, nil

		if Tab and Tab:FindFirstChild("Resize") then
			local Positions = Tab:FindFirstChild("Resize")

			for Index, Types in next, Positions:GetChildren() do
				Connect(Types.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = Types
						MousePos = Vector2.new(Player.Mouse.X, Player.Mouse.Y)
						Size = Tab.AbsoluteSize
						UIPos = Tab.Position
					end
				end)

				Connect(Types.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = nil
					end
				end)
			end
		end

		local Resize = function(Delta)
			if Type and MousePos and Size and UIPos and Tab:FindFirstChild("Resize")[Type.Name] == Type then
				local Mode = Resizing[Type.Name]
				local NewSize = Vector2.new(Size.X + Delta.X * Mode.X.X, Size.Y + Delta.Y * Mode.Y.Y)
				NewSize = Vector2.new(math.clamp(NewSize.X, Minimum.X, Maximum.X), math.clamp(NewSize.Y, Minimum.Y, Maximum.Y))

				local AnchorOffset = Vector2.new(Tab.AnchorPoint.X * Size.X, Tab.AnchorPoint.Y * Size.Y)
				local NewAnchorOffset = Vector2.new(Tab.AnchorPoint.X * NewSize.X, Tab.AnchorPoint.Y * NewSize.Y)
				local DeltaAnchorOffset = NewAnchorOffset - AnchorOffset

				Tab.Size = UDim2.new(0, NewSize.X, 0, NewSize.Y)

				local NewPosition = UDim2.new(
					UIPos.X.Scale, 
					UIPos.X.Offset + DeltaAnchorOffset.X * Mode.X.X,
					UIPos.Y.Scale,
					UIPos.Y.Offset + DeltaAnchorOffset.Y * Mode.Y.Y
				)
				Tab.Position = NewPosition
			end
		end

		Connect(Player.Mouse.Move, function()
			if Type then
				Resize(Vector2.new(Player.Mouse.X, Player.Mouse.Y) - MousePos)
			end
		end)
	end)
end

--// Setup [UI]
if (identifyexecutor) then
	Screen = Services.Insert:LoadLocalAsset("rbxassetid://18490507748");
	Blur = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Assets/Blur.lua"))();
else
	Screen = (script.Parent);
	Blur = require(script.Blur)
end

Screen.Main.Visible = false

xpcall(function()
	Screen.Parent = game.CoreGui
end, function() 
	Screen.Parent = Player.GUI
end)

--// Tables for Data
local Animations = {}
local Blurs = {}
local Components = (Screen:FindFirstChild("Components"));
local Library = {};
local StoredInfo = {
	["Sections"] = {};
	["Tabs"] = {}
};

--// Animations [Window]
function Animations:Open(Window: CanvasGroup, Transparency: number, UseCurrentSize: boolean)
	local Original = (UseCurrentSize and Window.Size) or Setup.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")


	SetProperty(Shadow, { Transparency = 1 })
	SetProperty(Window, {
		Size = Multiplied,
		GroupTransparency = 1,
		Visible = true,
	})

	Tween(Shadow, .25, { Transparency = 0.5 })
	Tween(Window, .25, {
		Size = Original,
		GroupTransparency = Transparency or 0,
	})
end

function Animations:Close(Window: CanvasGroup)
	local Original = Window.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")

	SetProperty(Window, {
		Size = Original,
	})

	Tween(Shadow, .25, { Transparency = 1 })
	Tween(Window, .25, {
		Size = Multiplied,
		GroupTransparency = 1,
	})

	task.wait(.25)
	Window.Size = Original
	Window.Visible = false
end


function Animations:Component(Component: any, Custom: boolean)	
	Connect(Component.InputBegan, function() 
		if Custom then
			Tween(Component, .25, { Transparency = .85 });
		else
			Tween(Component, .25, { BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode) });
		end
	end)

	Connect(Component.InputEnded, function() 
		if Custom then
			Tween(Component, .25, { Transparency = 1 });
		else
			Tween(Component, .25, { BackgroundColor3 = Theme.Component });
		end
	end)
end

--// Library [Window]

function Library:CreateWindow(Settings: { Title: string, Size: UDim2, Transparency: number, MinimizeKeybind: Enum.KeyCode?, Blurring: boolean, Theme: string, Folder: string?, FileName: string?, ForceCursorShow: boolean? })
	local Window = Clone(Screen:WaitForChild("Main"));
	local Sidebar = Window:FindFirstChild("Sidebar");
	local Holder = Window:FindFirstChild("Main");
	local BG = Window:FindFirstChild("BackgroundShadow");
	local Tab = Sidebar:FindFirstChild("Tab");
	
	-- Convert Tab to a ScrollingFrame if it's a regular Frame so it can scroll
	if Tab and not Tab:IsA("ScrollingFrame") then
		local ScrollingTab = Instance.new("ScrollingFrame")
		ScrollingTab.Name = "Tab"
		ScrollingTab.Size = Tab.Size
		ScrollingTab.Position = Tab.Position
		ScrollingTab.BackgroundTransparency = Tab.BackgroundTransparency
		ScrollingTab.BackgroundColor3 = Tab.BackgroundColor3
		ScrollingTab.BorderSizePixel = Tab.BorderSizePixel
		ScrollingTab.CanvasSize = UDim2.new(0, 0, 0, 0)
		ScrollingTab.AutomaticCanvasSize = Enum.AutomaticSize.Y
		ScrollingTab.ScrollBarThickness = 0
		
		for _, child in ipairs(Tab:GetChildren()) do
			child.Parent = ScrollingTab
		end
		
		ScrollingTab.Parent = Tab.Parent
		Tab:Destroy()
		Tab = ScrollingTab
	elseif Tab then
		Tab.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Tab.ScrollBarThickness = 0
	end

	local Options = {
		Flags = {},
		Folder = Settings.Folder or "lates-lib",
		FileName = Settings.FileName or "config.json",
		DropdownSearch = Settings.DropdownSearch,
		AutoSave = false
	};
	
	local saveThread = nil
	function Options:QueueSave()
		if not Options.AutoSave then return end
		if saveThread then
			task.cancel(saveThread)
		end
		saveThread = task.delay(0.5, function()
			Options:SaveConfig()
		end)
	end

	local Examples = {};
	local Opened = true;
	local Maximized = false;
	local BlurEnabled = false
	local DropdownOpen = false

	for Index, Descendant in next, Window:GetDescendants() do
		if Descendant.Name:find("Example") and not Examples[Descendant.Name] then
			Examples[Descendant.Name] = Descendant
		end
		
		if Descendant:IsA("ScrollingFrame") then
			Descendant.AutomaticCanvasSize = Enum.AutomaticSize.Y
		end
	end

	--// UI Blur & More
	Drag(Window);
	Resizeable(Window, Vector2.new(411, 271), Vector2.new(9e9, 9e9));
	Setup.Transparency = Settings.Transparency or 0
	Setup.Size = Settings.Size
	Setup.ThemeMode = Settings.Theme or "Dark"

	if Settings.Blurring then
		Blurs[Settings.Title] = Blur.new(Window, 5)
		BlurEnabled = true
	end

	if Settings.MinimizeKeybind then
		Setup.Keybind = Settings.MinimizeKeybind
	end

	if Settings.ForceCursorShow then
		local UIS = GetService(game, "UserInputService")
		local RS = GetService(game, "RunService")
		local GS = GetService(game, "GuiService")
		
		Connect(RS.RenderStepped, function()
			local mpos = UIS:GetMouseLocation()
			local inset = GS:GetGuiInset()
			local isHovering = false

			local function checkHover(guiObj)
				if not guiObj or not guiObj.Visible or not guiObj.Parent then return false end
				local screenGui = guiObj:FindFirstAncestorOfClass("ScreenGui")
				local pos = guiObj.AbsolutePosition
				local size = guiObj.AbsoluteSize
				
				-- GetMouseLocation() includes the top bar (GuiInset). 
				-- If IgnoreGuiInset is false, AbsolutePosition is relative to the viewport (excludes top bar).
				-- So we must subtract inset.Y from mpos.Y to match AbsolutePosition.
				local my = mpos.Y
				if screenGui and not screenGui.IgnoreGuiInset then
					my = my - inset.Y
				end
				
				return mpos.X >= pos.X and mpos.X <= pos.X + size.X and my >= pos.Y and my <= pos.Y + size.Y
			end

			if Opened and checkHover(Window) then
				isHovering = true
			end

			if not isHovering and checkHover(Options.ToggleButton) then
				isHovering = true
			end
			
			if isHovering then
				UIS.MouseIconEnabled = true
			else
				UIS.MouseIconEnabled = false 
			end
		end)
	end

	--// Animate
	local Close = function()
		if Opened then
			if BlurEnabled then
				Blurs[Settings.Title].root.Parent = nil
			end

			Opened = false
			Animations:Close(Window)
			Window.Visible = false
		else
			Animations:Open(Window, Setup.Transparency)
			Opened = true

			if BlurEnabled then
				Blurs[Settings.Title].root.Parent = workspace.CurrentCamera
			end
		end
	end

	for Index, Button in next, Sidebar.Top.Buttons:GetChildren() do
		if Button:IsA("TextButton") then
			local Name = Button.Name
			Animations:Component(Button, true)

			Connect(Button.MouseButton1Click, function() 
				if Name == "Close" then
					Close()
				elseif Name == "Maximize" then
					if Maximized then
						Maximized = false
						Tween(Window, .15, { Size = Setup.Size });
					else
						Maximized = true
						Tween(Window, .15, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5 )});
					end
				elseif Name == "Minimize" then
					Opened = false
					Window.Visible = false
					Blurs[Settings.Title].root.Parent = nil
				end
			end)
		end
	end

	Services.Input.InputBegan:Connect(function(Input, Focused) 
		if (Input == Setup.Keybind or Input.KeyCode == Setup.Keybind) and not Focused then
			Close()
		end
	end)

	--// Tab Functions

	function Options:SetTab(Name: string)
		for Index, Button in next, Tab:GetChildren() do
			if Button:IsA("TextButton") then
				local Opened, SameName = Button.Value, (Button.Name == Name);
				local Padding = Button:FindFirstChildOfClass("UIPadding");

				if SameName and not Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 25) });
					Tween(Button, .25, { BackgroundTransparency = 0.9, Size = UDim2.new(1, -15, 0, 30) });
					SetProperty(Opened, { Value = true });
				elseif not SameName and Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 20) });
					Tween(Button, .25, { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 0, 30) });
					SetProperty(Opened, { Value = false });
				end
			end
		end

		for Index, Main in next, Holder:GetChildren() do
			if Main:IsA("CanvasGroup") then
				local Opened, SameName = Main.Value, (Main.Name == Name);
				local Scroll = Main:FindFirstChild("ScrollingFrame");

				if SameName and not Opened.Value then
					Opened.Value = true
					Main.Visible = true

					Tween(Main, .3, { GroupTransparency = 0 });
					Tween(Scroll["UIPadding"], .3, { PaddingTop = UDim.new(0, 5) });

				elseif not SameName and Opened.Value then
					Opened.Value = false

					Tween(Main, .15, { GroupTransparency = 1 });
					Tween(Scroll["UIPadding"], .15, { PaddingTop = UDim.new(0, 15) });	

					task.delay(.2, function()
						Main.Visible = false
					end)
				end
			end
		end
	end

	function Options:AddTabSection(Settings: { Name: string, Order: number })
		local Example = Examples["SectionExample"];
		local Section = Clone(Example);

		StoredInfo["Sections"][Settings.Name] = (Settings.Order);
		SetProperty(Section, { 
			Parent = Example.Parent,
			Text = Settings.Name,
			Name = Settings.Name,
			LayoutOrder = Settings.Order,
			Visible = true
		});
	end

	function Options:AddTab(Settings: { Title: string, Icon: string, Section: string? })
		if StoredInfo["Tabs"][Settings.Title] then 
			error("[UI LIB]: A tab with the same name has already been created") 
		end 

		local Example, MainExample = Examples["TabButtonExample"], Examples["MainExample"];
		local Section = StoredInfo["Sections"][Settings.Section];
		local Main = Clone(MainExample);
		local Tab = Clone(Example);

		if not Settings.Icon then
			Destroy(Tab["ICO"]);
		else
			SetProperty(Tab["ICO"], { Image = Settings.Icon });
		end

		StoredInfo["Tabs"][Settings.Title] = { Tab }
		SetProperty(Tab["TextLabel"], { Text = Settings.Title });

		SetProperty(Main, { 
			Parent = MainExample.Parent,
			Name = Settings.Title;
		});

		SetProperty(Tab, { 
			Parent = Example.Parent,
			LayoutOrder = Section or #StoredInfo["Sections"] + 1,
			Name = Settings.Title;
			Visible = true;
		});

		Tab.MouseButton1Click:Connect(function()
			Options:SetTab(Tab.Name);
		end)

		return Main.ScrollingFrame
	end
	
	--// Notifications
	
	function Options:Notify(Settings: { Title: string, Description: string, Duration: number }) 
		local Notification = Clone(Components["Notification"]);
		local Title, Description = Options:GetLabels(Notification);
		local Timer = Notification["Timer"];
		
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Notification, {
			Parent = Screen["Frame"],
		})
		
		task.spawn(function() 
			local Duration = Settings.Duration or 2
			local Wait = task.wait;
			
			Animations:Open(Notification, Setup.Transparency, true); Tween(Timer, Duration, { Size = UDim2.new(0, 0, 0, 4) });
			Wait(Duration);
			Animations:Close(Notification);
			Wait(1);
			Notification:Destroy();
		end)
	end

	--// Component Functions

	function Options:GetLabels(Component)
		local Labels = Component:FindFirstChild("Labels")

		return Labels.Title, Labels.Description
	end

	function Options:AddSection(Settings: { Name: string, Tab: Instance }) 
		local Section = Clone(Components["Section"]);
		SetProperty(Section, {
			Text = Settings.Name,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	
	function Options:AddButton(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Button = Clone(Components["Button"]);
		local Title, Description = Options:GetLabels(Button);

		Connect(Button.MouseButton1Click, Settings.Callback)
		Animations:Component(Button)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Button, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddInput(Settings: { Title: string, Description: string, Default: string?, Flag: string?, Tab: Instance, Callback: any }) 
		local Input = Clone(Components["Input"]);
		local Title, Description = Options:GetLabels(Input);
		local TextBox = Input["Main"]["Input"];

		local Set = function(Value)
			TextBox.Text = Value
			Settings.Callback(Value)
			if Settings.Flag then
				if not Options.Flags[Settings.Flag] then
					Options.Flags[Settings.Flag] = {}
				end
				Options.Flags[Settings.Flag].Value = Value
				Options:QueueSave()
			end
		end

		Connect(Input.MouseButton1Click, function() 
			TextBox:CaptureFocus()
		end)

		Connect(TextBox.FocusLost, function() 
			Set(TextBox.Text)
		end)
		
		if Settings.Default then
			Set(Settings.Default)
		end
		
		if Settings.Flag then
			Options.Flags[Settings.Flag] = { Value = Settings.Default or "", Set = Set }
		end

		Animations:Component(Input)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Input, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddToggle(Settings: { Title: string, Description: string, Default: boolean, Flag: string?, Tab: Instance, Callback: any }) 
		local Toggle = Clone(Components["Toggle"]);
		local Title, Description = Options:GetLabels(Toggle);

		local On = Toggle["Value"];
		local Main = Toggle["Main"];
		local Circle = Main["Circle"];
		
		local Set = function(Value)
			if Value then
				Tween(Main,   .2, { BackgroundColor3 = Color3.fromRGB(153, 155, 255) });
				Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) });
			else
				Tween(Main,   .2, { BackgroundColor3 = Theme.Interactables });
				Tween(Circle, .2, { BackgroundColor3 = Theme.Primary, Position = UDim2.new(0, 3, 0.5, 0) });
			end
			
			On.Value = Value
			
			if Settings.Flag then
				if not Options.Flags[Settings.Flag] then
					Options.Flags[Settings.Flag] = {}
				end
				Options.Flags[Settings.Flag].Value = Value
				Options:QueueSave()
			end
		end 
		
		if Settings.Flag then
			Options.Flags[Settings.Flag] = { 
				Value = Settings.Default, 
				Set = function(val) 
					Set(val) 
					Settings.Callback(val) 
				end 
			}
		end

		Connect(Toggle.MouseButton1Click, function()
			local Value = not On.Value

			Set(Value)
			Settings.Callback(Value)
		end)

		Animations:Component(Toggle);
		Set(Settings.Default);
		if Settings.Callback then
			Settings.Callback(Settings.Default)
		end
		
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Toggle, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	
	function Options:AddKeybind(Settings: { Title: string, Description: string, Default: any, Flag: string?, Tab: Instance, Callback: any }) 
		local Dropdown = Clone(Components["Keybind"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Bind = Dropdown["Main"].Options;
		
		local Mouse = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }; 
		local Types = { 
			["Mouse"] = "Enum.UserInputType.MouseButton", 
			["Key"] = "Enum.KeyCode." 
		}
		
		local Set = function(Key)
			local Type = typeof(Key) == "EnumItem" and Key or (Key.UserInputType == Enum.UserInputType.Keyboard and Key.KeyCode or Key.UserInputType)
			local Str = tostring(Type)
			
			if Str:find("UserInputType") then
				SetProperty(Bind, { Text = Str:gsub(Types.Mouse, "MB") })
			else
				SetProperty(Bind, { Text = Str:gsub(Types.Key, "") })
			end
			Settings.Callback(Key)
			
			if Settings.Flag then
				if not Options.Flags[Settings.Flag] then
					Options.Flags[Settings.Flag] = {}
				end
				Options.Flags[Settings.Flag].Value = Type.Name
				Options:QueueSave()
			end
		end

		Connect(Dropdown.MouseButton1Click, function()
			local Time = tick();
			local Detect, Finished
			
			SetProperty(Bind, { Text = "..." });
			Detect = Connect(game.UserInputService.InputBegan, function(Key, Focused) 
				local InputType = (Key.UserInputType);
				
				if not Finished and not Focused then
					Finished = (true)
					
					if table.find(Mouse, InputType) or InputType == Enum.UserInputType.Keyboard then
						Set(Key)
					end
				end 
			end)
		end)
		
		if Settings.Default then
			Set(Settings.Default)
		end
		
		if Settings.Flag then
			Options.Flags[Settings.Flag] = { 
				Value = Settings.Default and Settings.Default.Name or "", 
				Set = function(val)
					pcall(function()
						local foundEnum = Enum.KeyCode[val] or Enum.UserInputType[val]
						if foundEnum then
							Set(foundEnum)
						end
					end)
				end
			}
		end

		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddDropdown(Settings: { Title: string, Description: string, Options: {}, Flag: string?, Search: boolean?, Default: any, Tab: Instance, Callback: any }) 
		local Dropdown = Clone(Components["Dropdown"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Text = Dropdown["Main"].Options;
		
		local Set = function(Value)
			local textIndex = tostring(Value)
			for k, v in pairs(Settings.Options) do
				if v == Value or k == Value then
					textIndex = k
					break
				end
			end
			Text.Text = textIndex
			Settings.Callback(Value)
			
			if Settings.Flag then
				if not Options.Flags[Settings.Flag] then
					Options.Flags[Settings.Flag] = {}
				end
				Options.Flags[Settings.Flag].Value = Value
				Options:QueueSave()
			end
		end

		if Settings.Default then
			Set(Settings.Default)
		end
		
		if Settings.Flag then
			Options.Flags[Settings.Flag] = { Value = Settings.Default, Set = Set }
		end

		Connect(Dropdown.MouseButton1Click, function()
			if DropdownOpen then return end
			DropdownOpen = true
			
			local Example = Clone(Examples["DropdownExample"]);
			local Buttons = Example["Top"]["Buttons"];

			Tween(BG, .25, { BackgroundTransparency = 0.6 });
			SetProperty(Example, { Parent = Window });
			Animations:Open(Example, 0, true)
			
			local bgConnection
			local function closeDropdown()
				if bgConnection then
					bgConnection:Disconnect()
					bgConnection = nil
				end
				if not DropdownOpen then return end
				DropdownOpen = false
				Tween(BG, .25, { BackgroundTransparency = 1 });
				Animations:Close(Example);
				task.wait(2)
				Destroy(Example);
			end

			bgConnection = Connect(Services.Input.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					local x, y = Player.Mouse.X, Player.Mouse.Y
					local exX, exY = Example.AbsolutePosition.X, Example.AbsolutePosition.Y
					local exSize = Example.AbsoluteSize
					
					if x < exX or x > exX + exSize.X or y < exY or y > exY + exSize.Y then
						closeDropdown()
					end
				end
			end)

			for Index, Button in next, Buttons:GetChildren() do
				if Button:IsA("TextButton") then
					Animations:Component(Button, true)

					Connect(Button.MouseButton1Click, function()
						closeDropdown()
					end)
				end
			end

			local optionButtons = {}
			local shouldSearch = (Settings.Search ~= nil) and Settings.Search or Options.DropdownSearch
			
			if shouldSearch then
				local SearchContainer = Instance.new("Frame")
				SearchContainer.Name = "SearchContainer"
				SearchContainer.Size = UDim2.new(1, 0, 0, 36)
				SearchContainer.BackgroundTransparency = 1
				SearchContainer.Parent = Example.ScrollingFrame
				SearchContainer.LayoutOrder = -1
				
				local SearchBox = Instance.new("TextBox")
				SearchBox.Name = "SearchBox"
				SearchBox.Size = UDim2.new(1, -16, 1, -8)
				SearchBox.Position = UDim2.new(0, 8, 0, 4)
				SearchBox.BackgroundColor3 = Theme.Component
				SearchBox.TextColor3 = Theme.Title
				SearchBox.PlaceholderText = "Search options..."
				SearchBox.PlaceholderColor3 = Theme.Description
				SearchBox.Text = ""
				SearchBox.Font = Enum.Font.Gotham
				SearchBox.TextSize = 13
				SearchBox.Parent = SearchContainer
				
				local UICorner = Instance.new("UICorner")
				UICorner.CornerRadius = UDim.new(0, 4)
				UICorner.Parent = SearchBox

				Connect(SearchBox:GetPropertyChangedSignal("Text"), function()
					local query = SearchBox.Text:lower()
					for index, btn in pairs(optionButtons) do
						if query == "" or string.find(index:lower(), query, 1, true) then
							btn.Visible = true
						else
							btn.Visible = false
						end
					end
				end)
			end

			for Index, Option in next, Settings.Options do
				local Button = Clone(Examples["DropdownButtonExample"]);
				local Title, Description = Options:GetLabels(Button);
				local Selected = Button["Value"];

				Animations:Component(Button);
				SetProperty(Title, { Text = Index });
				SetProperty(Button, { Parent = Example.ScrollingFrame, Visible = true });
				Destroy(Description);
				
				optionButtons[Index] = Button

				Connect(Button.MouseButton1Click, function() 
					local NewValue = not Selected.Value 

					if NewValue then
						Tween(Button, .25, { BackgroundColor3 = Theme.Interactables });
						Set(Option)

						for _, Others in next, Example:GetChildren() do
							if Others:IsA("TextButton") and Others ~= Button then
								Others.BackgroundColor3 = Theme.Component
							end
						end
					else
						Tween(Button, .25, { BackgroundColor3 = Theme.Component });
					end

					Selected.Value = NewValue
					closeDropdown()
				end)
			end
		end)

		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddSlider(Settings: { Title: string, Description: string, MaxValue: number, AllowDecimals: boolean, DecimalAmount: number, Flag: string?, Default: number?, Tab: Instance, Callback: any }) 
		local Slider = Clone(Components["Slider"]);
		local Title, Description = Options:GetLabels(Slider);

		local Main = Slider["Slider"];
		local Amount = Main["Main"].Input;
		local Slide = Main["Slide"];
		local Fire = Slide["Fire"];
		local Fill = Slide["Highlight"];
		local Circle = Fill["Circle"];

		local Active = false
		local Value = 0
		
		local SetNumber = function(Number)
			if Settings.AllowDecimals then
				local Power = 10 ^ (Settings.DecimalAmount or 2)
				Number = math.floor(Number * Power + 0.5) / Power
			else
				Number = math.round(Number)
			end
			
			return Number
		end

		local Update = function(Number)
			local Scale = (Player.Mouse.X - Slide.AbsolutePosition.X) / Slide.AbsoluteSize.X			
			Scale = (Scale > 1 and 1) or (Scale < 0 and 0) or Scale
			
			if Number then
				Number = (Number > Settings.MaxValue and Settings.MaxValue) or (Number < 0 and 0) or Number
			end
			
			Value = SetNumber(Number or (Scale * Settings.MaxValue))
			Amount.Text = Value
			Fill.Size = UDim2.fromScale((Value / Settings.MaxValue), 1)
			Settings.Callback(Value)
			
			if Settings.Flag then
				if not Options.Flags[Settings.Flag] then
					Options.Flags[Settings.Flag] = {}
				end
				Options.Flags[Settings.Flag].Value = Value
				Options:QueueSave()
			end
		end

		local Activate = function()
			Active = true

			repeat task.wait()
				Update()
			until not Active
		end
		
		Connect(Amount.FocusLost, function() 
			Update(tonumber(Amount.Text) or 0)
		end)

		Connect(Fire.MouseButton1Down, Activate)
		Connect(Services.Input.InputEnded, function(Input) 
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Active = false
			end
		end)

		Fill.Size = UDim2.fromScale(Value / Settings.MaxValue, 1);
		
		if Settings.Default then
			Update(Settings.Default)
		end
		
		if Settings.Flag then
			Options.Flags[Settings.Flag] = { Value = Settings.Default or 0, Set = Update }
		end
		
		Animations:Component(Slider);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Slider, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddParagraph(Settings: { Title: string, Description: string, Tab: Instance }) 
		local Paragraph = Clone(Components["Paragraph"]);
		local Title, Description = Options:GetLabels(Paragraph);

		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Paragraph, {
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	local Themes = {
		Names = {	
			["Paragraph"] = function(Label)
				if Label:IsA("TextButton") then
					Label.BackgroundColor3 = Color(Theme.Component, 5, "Dark");
				end
			end,
			
			["Title"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Description"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Description
				end
			end,
			
			["Section"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Options"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
				end
			end,
			
			["Notification"] = function(Label)
				if Label:IsA("CanvasGroup") then
					Label.BackgroundColor3 = Theme.Primary
					Label.UIStroke.Color = Theme.Outline
				end
			end,

			["TextLabel"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent:FindFirstChild("List") then
					Label.TextColor3 = Theme.Tab
				end
			end,

			["Main"] = function(Label)
				if Label:IsA("Frame") then

					if Label.Parent == Window then
						Label.BackgroundColor3 = Theme.Secondary
					elseif Label.Parent:FindFirstChild("Value") then
						local Toggle = Label.Parent.Value 
						local Circle = Label:FindFirstChild("Circle")
						
						if not Toggle.Value then
							Label.BackgroundColor3 = Theme.Interactables
							Label.Circle.BackgroundColor3 = Theme.Primary
						end
					else
						Label.BackgroundColor3 = Theme.Interactables
					end
				elseif Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Amount"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,

			["Slide"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,

			["Input"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				elseif Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				elseif Label:IsA("TextBox") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Outline"] = function(Stroke)
				if Stroke:IsA("UIStroke") then
					Stroke.Color = Theme.Outline
				end
			end,

			["DropdownExample"] = function(Label)
				Label.BackgroundColor3 = Theme.Secondary
			end,

			["Underline"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Outline
				end
			end,
		},

		Classes = {
			["ImageLabel"] = function(Label)
				if Label.Image ~= "rbxassetid://6644618143" then
					Label.ImageColor3 = Theme.Icon
				end
			end,

			["TextLabel"] = function(Label)
				if Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["TextButton"] = function(Label)
				if Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				end
			end,

			["ScrollingFrame"] = function(Label)
				Label.ScrollBarImageColor3 = Theme.Component
			end,
		},
	}

	function Options:SetTheme(Info)
		Theme = Info or Theme

		Window.BackgroundColor3 = Theme.Primary
		Holder.BackgroundColor3 = Theme.Secondary
		Window.UIStroke.Color = Theme.Shadow

		for Index, Descendant in next, Screen:GetDescendants() do
			local Name, Class =  Themes.Names[Descendant.Name],  Themes.Classes[Descendant.ClassName]

			if Name then
				Name(Descendant);
			elseif Class then
				Class(Descendant);
			end
		end
	end

	--// Changing Settings

	function Options:SetSetting(Setting, Value) --// Available settings - Size, Transparency, Blur, Theme
		if Setting == "Size" then
			
			Window.Size = Value
			Setup.Size = Value
			
		elseif Setting == "Transparency" then
			
			Window.GroupTransparency = Value
			Setup.Transparency = Value
			
			for Index, Notification in next, Screen:GetDescendants() do
				if Notification:IsA("CanvasGroup") and Notification.Name == "Notification" then
					Notification.GroupTransparency = Value
				end
			end
			
		elseif Setting == "Blur" then
			
			local AlreadyBlurred, Root = Blurs[Settings.Title], nil
			
			if AlreadyBlurred then
				Root = Blurs[Settings.Title]["root"]
			end
			
			if Value then
				BlurEnabled = true

				if not AlreadyBlurred or not Root then
					Blurs[Settings.Title] = Blur.new(Window, 5)
				elseif Root and not Root.Parent then
					Root.Parent = workspace.CurrentCamera
				end
			elseif not Value and (AlreadyBlurred and Root and Root.Parent) then
				Root.Parent = nil
				BlurEnabled = false
			end
			
		elseif Setting == "Theme" and typeof(Value) == "table" then
			
			Options:SetTheme(Value)
			
		elseif Setting == "Keybind" then
			
			Setup.Keybind = Value
			
		else
			warn("Tried to change a setting that doesn't exist or isn't available to change.")
		end
	end

	function Options:SaveConfig()
		if not isfolder(Options.Folder) then
			makefolder(Options.Folder)
		end
		
		local data = {}
		for flag, flagData in pairs(Options.Flags) do
			data[flag] = flagData.Value
		end
		
		local path = Options.Folder .. "/" .. Options.FileName
		local success, encoded = pcall(Services.Http.JSONEncode, Services.Http, data)
		if success then
			writefile(path, encoded)
		end
	end

	function Options:LoadConfig()
		local path = Options.Folder .. "/" .. Options.FileName
		if isfile(path) then
			local success, decoded = pcall(function()
				return Services.Http:JSONDecode(readfile(path))
			end)
			if success and decoded then
				for flag, value in pairs(decoded) do
					if Options.Flags[flag] and Options.Flags[flag].Set then
						pcall(Options.Flags[flag].Set, value)
					end
				end
			end
		end
	end

	function Options:SetFlag(flag, value)
		if Options.Flags[flag] and Options.Flags[flag].Set then
			Options.Flags[flag].Set(value)
		else
			warn("[lates-lib] SetFlag: flag '" .. tostring(flag) .. "' not found or not settable")
		end
	end

	function Options:BuildSettingsSection(Tab, Themes)
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		local TeleportService = game:GetService("TeleportService")
		local HttpService = game:GetService("HttpService")
		local VirtualUser = game:GetService("VirtualUser")
		local GuiService = game:GetService("GuiService")

		Options:AddSection({ Name = "Server", Tab = Tab }) 

		local function rejoin()
			if #Players:GetPlayers() <= 1 then
				LocalPlayer:Kick("\nRejoining...")
				task.wait()
				TeleportService:Teleport(game.PlaceId, LocalPlayer)
			else
				TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
			end
		end

		local function ServerHop()
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

		Options:AddToggle({
			Title = "Anti-Afk",
			Description = "No more AFK kick.",
			Default = true,
			Flag = "AntiAfk",
			Tab = Tab,
			Callback = function(Boolean) 
				if Boolean then
					EnableAntiAfk()
				else
					DisableAntiAfk()
				end
			end,
		}) 

		Options:AddToggle({
			Title = "Auto Rejoin",
			Description = "Automatic Rejoin When Disconnected.",
			Default = true,
			Flag = "AutoRejoin",
			Tab = Tab,
			Callback = function(Boolean) 
				if Boolean then
					EnableAutoRejoin()
				else
					DisableAutoRejoin()
				end
			end,
		}) 

		Options:AddButton({
			Title = "Rejoin",
			Description = "Rejoin current server.",
			Tab = Tab,
			Callback = function() 
				rejoin()
			end,
		})
		Options:AddButton({
			Title = "Server Hop",
			Description = "Join another server.",
			Tab = Tab,
			Callback = function() 
				ServerHop()
			end,
		})
		Options:AddButton({
			Title = "Infinite Yield",
			Description = "Admin commands script.",
			Tab = Tab,
			Callback = function() 
				loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
			end,
		}) 

		Options:AddSection({ Name = "UI", Tab = Tab }) 

		Options:AddKeybind({
			Title = "Minimize Keybind",
			Description = "Set the keybind for Minimizing",
			Tab = Tab,
			Default = Settings.MinimizeKeybind or Enum.KeyCode.RightControl,
			Flag = "MinimizeKeybind",
			Callback = function(Key) 
				Options:SetSetting("Keybind", Key)
			end,
		}) 

		if Themes then
			Options:AddDropdown({
				Title = "Set Theme",
				Description = "Set the theme of the library!",
				Tab = Tab,
				Options = {
					["Light Mode"] = "Light",
					["Dark Mode"] = "Dark",
					["Extra Dark"] = "Void",
				},
				Default = "Dark Mode",
				Flag = "Theme",
				Callback = function(ThemeStr) 
					Options:SetTheme(Themes[ThemeStr])
				end,
			}) 
		end

		Options:AddToggle({
			Title = "UI Blur",
			Description = "If enabled, must have your Roblox graphics set to 8+ for it to work",
			Default = false,
			Flag = "Blur",
			Tab = Tab,
			Callback = function(Boolean) 
				Options:SetSetting("Blur", Boolean)
			end,
		}) 

		Options:AddSlider({
			Title = "UI Transparency",
			Description = "Set the transparency of the UI",
			Tab = Tab,
			AllowDecimals = true,
			MaxValue = 1,
			Default = 0,
			Flag = "Transparency",
			Callback = function(Amount) 
				Options:SetSetting("Transparency", Amount)
			end,
		})

		Options:AddSection({ Name = "Config", Tab = Tab })

		Options:AddToggle({
			Title = "Auto Save",
			Description = "Automatically saves settings.",
			Default = getgenv().AutoSave or false,
			Flag = "AutoSave",
			Tab = Tab,
			Callback = function(Boolean)
				getgenv().AutoSave = Boolean
				Options.AutoSave = Boolean
			end,
		})

		Options:AddButton({
			Title = "Save Settings",
			Description = "Manually save current settings.",
			Tab = Tab,
			Callback = function()
				Options:SaveConfig()
				Options:Notify({
					Title = "Settings Saved",
					Description = "Your settings have been saved successfully!",
					Duration = 3,
				})
			end,
		})
	end

	SetProperty(Window, { Size = Settings.Size, Visible = true, Parent = Screen });
	function Options:CreateToggleButton()
		local hiddenUI = gethui and gethui() or game:GetService("CoreGui")
		local existingGui = hiddenUI:FindFirstChild("nvkob1ToggleButton")
		if existingGui then 
			existingGui:Destroy() 
		end

		local ToggleGui = Instance.new("ScreenGui")
		ToggleGui.Name = "nvkob1ToggleButton"
		ToggleGui.ResetOnSpawn = false
		ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		ToggleGui.DisplayOrder = 999999
		ToggleGui.Parent = hiddenUI

		local ToggleButton = Instance.new("ImageButton")
		ToggleButton.Size = UDim2.new(0, 65, 0, 65) 
		ToggleButton.Position = UDim2.new(0.05, 0, 0.05, 0)
		ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		ToggleButton.AutoButtonColor = false
		ToggleButton.ScaleType = Enum.ScaleType.Fit
		ToggleButton.Parent = ToggleGui
		Options.ToggleButton = ToggleButton

		local UICorner = Instance.new("UICorner")
		UICorner.CornerRadius = UDim.new(0.5, 0)
		UICorner.Parent = ToggleButton

		task.spawn(function()
			local success, response = pcall(function()
				return request({
					Url = "https://scriptblox.com/images/photo/62a46c5b3203c751aec2e7fe-1694938703252.png",
					Method = "GET"
				})
			end)
			
			if success and response and response.StatusCode == 200 then
				writefile("nvkob1.png", response.Body)
				ToggleButton.Image = getcustomasset("nvkob1.png")
			end
		end)

		local dragging = false
		local dragInput, dragStart, startPos
		local hasDragged = false

		local function update(input)
			local delta = input.Position - dragStart
			if delta.Magnitude > 5 then
				hasDragged = true
			end
			ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end

		ToggleButton.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				hasDragged = false
				dragStart = input.Position
				startPos = ToggleButton.Position
				
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		ToggleButton.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)

		Services.Input.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)

		ToggleButton.Activated:Connect(function()
			if not hasDragged then
				Close()
			end
		end)
	end

	Animations:Open(Window, Settings.Transparency or 0)

	return Options
end

return Library
