-- Original is from https://www.roblox.com/games/16531896413/Avatar-Forge

-- Lighting Set Up
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

-- Clear all Lighting children
for _, child in ipairs(Lighting:GetChildren()) do
    child:Destroy()
end

-- Mute/stop all sounds recursively
local function killSounds(parent)
    for _, obj in ipairs(parent:GetDescendants()) do
        if obj:IsA("Sound") then
            obj.Volume = 0
            obj:Stop()
        end
    end
end

killSounds(game.Workspace)
killSounds(SoundService)

-- Also mute master SoundService channels
for _, channel in ipairs(SoundService:GetChildren()) do
    if channel:IsA("SoundGroup") then
        channel.Volume = 0
    end
end

-- Apply Lighting properties
Lighting.Brightness = 2
Lighting.Ambient = Color3.new(0, 0, 0)
Lighting.OutdoorAmbient = Color3.new(0.501961, 0.501961, 0.501961)
Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
Lighting.ColorShift_Top = Color3.new(0, 0, 0)
Lighting.ShadowSoftness = 0.5
Lighting.GeographicLatitude = 41.733
Lighting.ClockTime = 19
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0
Lighting.ExposureCompensation = 0

local sunRays = Instance.new("SunRaysEffect")
sunRays.Name = "SunRays"
sunRays.Enabled = true
sunRays.Intensity = 0.25
sunRays.Spread = 1
sunRays.Parent = Lighting

local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "Atmosphere"
atmosphere.Density = 0.395
atmosphere.Offset = 0
atmosphere.Color = Color3.fromRGB(141, 60, 255)
atmosphere.Decay = Color3.fromRGB(255, 170, 255)
atmosphere.Glare = 0
atmosphere.Haze = 2
atmosphere.Parent = Lighting

local sky = Instance.new("Sky")
sky.Name = "Sky"
sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
sky.SkyboxOrientation = Vector3.new(0, 0, 0)
sky.SunAngularSize = 21
sky.MoonAngularSize = 11
sky.SunTextureId = "rbxasset://sky/sun.jpg"
sky.MoonTextureId = "rbxasset://sky/moon.jpg"
sky.StarCount = 3000
sky.CelestialBodiesShown = true
sky.Parent = Lighting

-- Music Player Gui
-- Destroy existing MusicGui if present
local existingGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("MusicGui")
if existingGui then
    existingGui:Destroy()
end

-- Instances:
local MusicGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Progress = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Fill = Instance.new("Frame")
local UICorner_2 = Instance.new("UICorner")
local MusicName = Instance.new("TextLabel")
local Control = Instance.new("Frame")
local Next = Instance.new("ImageButton")
local ImageLabel = Instance.new("ImageLabel")
local Aspect = Instance.new("UIAspectRatioConstraint")
local Previous = Instance.new("ImageButton")
local ImageLabel_2 = Instance.new("ImageLabel")
local Aspect_2 = Instance.new("UIAspectRatioConstraint")
local Pause = Instance.new("ImageButton")
local ImageLabel_3 = Instance.new("ImageLabel")
local Aspect_3 = Instance.new("UIAspectRatioConstraint")
local UIListLayout = Instance.new("UIListLayout")
local Title = Instance.new("TextLabel")
local UICorner_3 = Instance.new("UICorner")
local Status = Instance.new("TextLabel")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")

--Properties:

MusicGui.Name = "MusicGui"
MusicGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
MusicGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MusicGui.ResetOnSpawn = false

Frame.Parent = MusicGui
Frame.AnchorPoint = Vector2.new(0.980000019, 0.970000029)
Frame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
Frame.BackgroundTransparency = 0.500
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.232062832, 0, 0.419386297, 0)
Frame.Size = UDim2.new(0.204981863, 0, 0.209758982, 0)

Progress.Name = "Progress"
Progress.Parent = Frame
Progress.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Progress.BackgroundTransparency = 0.300
Progress.BorderColor3 = Color3.fromRGB(0, 0, 0)
Progress.BorderSizePixel = 0
Progress.Position = UDim2.new(0.109285735, 0, 0.0529583469, 0)
Progress.Size = UDim2.new(0.800000012, 0, 0.119999997, 0)

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = Progress

Fill.Name = "Fill"
Fill.Parent = Progress
Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Fill.BorderColor3 = Color3.fromRGB(0, 0, 0)
Fill.BorderSizePixel = 0
Fill.Position = UDim2.new(-4.36072924e-07, 0, 0, 0)
Fill.Size = UDim2.new(0.0639382899, 0, 0.999999881, 0)

UICorner_2.CornerRadius = UDim.new(1, 0)
UICorner_2.Parent = Fill

MusicName.Name = "MusicName"
MusicName.Parent = Frame
MusicName.AnchorPoint = Vector2.new(0.5, 0)
MusicName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MusicName.BackgroundTransparency = 1.000
MusicName.BorderColor3 = Color3.fromRGB(0, 0, 0)
MusicName.BorderSizePixel = 0
MusicName.Position = UDim2.new(0.542976677, 0, 0.225420713, 0)
MusicName.Size = UDim2.new(0.785954297, 0, 0.210899889, 0)
MusicName.Font = Enum.Font.SourceSansBold
MusicName.Text = "Music Name"
MusicName.TextColor3 = Color3.fromRGB(255, 255, 255)
MusicName.TextScaled = true
MusicName.TextSize = 14.000
MusicName.TextWrapped = true
MusicName.TextXAlignment = Enum.TextXAlignment.Right

Control.Name = "Control"
Control.Parent = Frame
Control.AnchorPoint = Vector2.new(0.5, 0)
Control.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Control.BackgroundTransparency = 1.000
Control.BorderColor3 = Color3.fromRGB(0, 0, 0)
Control.BorderSizePixel = 0
Control.Position = UDim2.new(0.462977052, 0, 0.487688422, 0)
Control.Size = UDim2.new(0.935954094, 0, 0.207746491, 0)

Next.Name = "Next"
Next.Parent = Control
Next.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Next.BackgroundTransparency = 1.000
Next.BorderColor3 = Color3.fromRGB(0, 0, 0)
Next.BorderSizePixel = 0
Next.LayoutOrder = 3
Next.Position = UDim2.new(0.682093143, 0, 0, 0)
Next.Size = UDim2.new(0.142000005, 0, 1, 0)
Next.AutoButtonColor = false

ImageLabel.Parent = Next
ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel.BackgroundTransparency = 1.000
ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel.BorderSizePixel = 0
ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel.Size = UDim2.new(0.5, 0, 1, 0)
ImageLabel.Image = "rbxassetid://3367486717"

Aspect.Name = "Aspect"
Aspect.Parent = Next
Aspect.AspectRatio = 1.300

Previous.Name = "Previous"
Previous.Parent = Control
Previous.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Previous.BackgroundTransparency = 1.000
Previous.BorderColor3 = Color3.fromRGB(0, 0, 0)
Previous.BorderSizePixel = 0
Previous.LayoutOrder = 1
Previous.Position = UDim2.new(0.120530486, 0, 0, 0)
Previous.Size = UDim2.new(0.141786814, 0, 0.999999881, 0)
Previous.AutoButtonColor = false

ImageLabel_2.Parent = Previous
ImageLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel_2.BackgroundTransparency = 1.000
ImageLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel_2.BorderSizePixel = 0
ImageLabel_2.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel_2.Size = UDim2.new(0.5, 0, 1, 0)
ImageLabel_2.Image = "rbxassetid://3367487001"

Aspect_2.Name = "Aspect"
Aspect_2.Parent = Previous
Aspect_2.AspectRatio = 1.300

Pause.Name = "Pause"
Pause.Parent = Control
Pause.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Pause.BackgroundTransparency = 1.000
Pause.BorderColor3 = Color3.fromRGB(0, 0, 0)
Pause.BorderSizePixel = 0
Pause.LayoutOrder = 2
Pause.Position = UDim2.new(0.428893596, 0, 0, 0)
Pause.Size = UDim2.new(0.18485713, 0, 1, 0)
Pause.AutoButtonColor = false

ImageLabel_3.Parent = Pause
ImageLabel_3.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel_3.BackgroundTransparency = 1.000
ImageLabel_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel_3.BorderSizePixel = 0
ImageLabel_3.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel_3.Size = UDim2.new(0.5, 0, 1, 0)
ImageLabel_3.Image = "rbxassetid://13980756617"

Aspect_3.Name = "Aspect"
Aspect_3.Parent = Pause
Aspect_3.AspectRatio = 1.600

UIListLayout.Parent = Control
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.Padding = UDim.new(0.0250000004, 0)

Title.Name = "Title"
Title.Parent = Frame
Title.AnchorPoint = Vector2.new(0.5, 0)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
Title.BorderSizePixel = 0
Title.Position = UDim2.new(0.622328818, 0, 0.756521702, 0)
Title.Size = UDim2.new(0.607250333, 0, 0.182608798, 0)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Currently Playing"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.TextSize = 14.000
Title.TextTransparency = 1.000
Title.TextWrapped = true
Title.TextXAlignment = Enum.TextXAlignment.Right

UICorner_3.CornerRadius = UDim.new(0.100000001, 0)
UICorner_3.Parent = Frame

Status.Name = "Status"
Status.Parent = Frame
Status.AnchorPoint = Vector2.new(0.5, 0)
Status.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Status.BackgroundTransparency = 1.000
Status.BorderColor3 = Color3.fromRGB(0, 0, 0)
Status.BorderSizePixel = 0
Status.Position = UDim2.new(0.189741015, 0, 0.756521702, 0)
Status.Size = UDim2.new(0.261390001, 0, 0.182608798, 0)
Status.Font = Enum.Font.SourceSansBold
Status.Text = "Status:"
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextScaled = true
Status.TextSize = 14.000
Status.TextWrapped = true
Status.TextXAlignment = Enum.TextXAlignment.Right

UIAspectRatioConstraint.Parent = Frame
UIAspectRatioConstraint.AspectRatio = 1.739

-- Scripts:

local function VYUDCMG_fake_script() -- MusicGui.MusicManager 
	local script = Instance.new('LocalScript', MusicGui)

	local Gui = script.Parent
	local Components = {}
	local CurrentSong, SongStatus = nil, "Playing"
	local SoundEndRender, TimeLeft
	local TotalTime
	local LastTick, LastLeft
	local elapsed = 0
	local Debounce = false
	
	-- Song list (Name and Sound ID)
	local SONG_LIST = {
		{Name = "Beach Cushions", SoundId = "rbxassetid://9047104411"},
		{Name = "Decompression", SoundId = "rbxassetid://9047104650"},
		{Name = "Home Town Easy", SoundId = "rbxassetid://9047104571"},
		{Name = "Light Dreamer", SoundId = "rbxassetid://9047105702"},
		{Name = "Monday Morning", SoundId = "rbxassetid://9047104752"},
		{Name = "Moving Round The Block", SoundId = "rbxassetid://9047105108"},
		{Name = "No Smoking", SoundId = "rbxassetid://9047105533"},
		{Name = "On The Verge", SoundId = "rbxassetid://9047105584"},
		{Name = "Poolside", SoundId = "rbxassetid://9046863253"},
		{Name = "Sunday In Bed", SoundId = "rbxassetid://9047104336"},
	}
	
	-- Container for sound instances
	local SoundContainer = {}
	
	-- Services
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	
	-- Constants
	local FADE_TIME = 0.5
	local BUTTON_TWEEN_TIME = 0.2
	local VOLUME_TWEEN_TIME = 1
	local LOAD_TIMEOUT = 8
	local TITLE_DISPLAY_TIME = 3
	local DEBOUNCE_TIME = 0.4
	
	-- Initialize components safely
	local function InitializeComponents()
		local frame = Gui:FindFirstChild("Frame")
		if not frame then
			error("Frame not found in GUI")
		end
	
		for _, child in pairs(frame:GetChildren()) do 
			if child:IsA("GuiObject") then
				Components[child.Name] = child
			end
		end
	
		-- Validate required components
		local requiredComponents = {"Title", "MusicName", "Progress", "Control"}
		for _, componentName in pairs(requiredComponents) do
			if not Components[componentName] then
				error("Required component '" .. componentName .. "' not found")
			end
		end
	
		-- Validate control buttons
		local control = Components.Control
		local requiredButtons = {"Pause", "Next", "Previous"}
		for _, buttonName in pairs(requiredButtons) do
			if not control:FindFirstChild(buttonName) then
				error("Required button '" .. buttonName .. "' not found in Control")
			end
		end
	end
	
	-- Music title fade animation
	local MusicTitleTransparency = {}
	local function MusicTitleFade()
		-- Cancel existing tweens
		if MusicTitleTransparency["TitleIn"] then
			MusicTitleTransparency["TitleIn"]:Cancel()
		end
		if MusicTitleTransparency["TitleOut"] then
			MusicTitleTransparency["TitleOut"]:Cancel()
		end
	
		MusicTitleTransparency["TitleIn"] = TweenService:Create(
			Components.Title, 
			TweenInfo.new(FADE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), 
			{TextTransparency = 0}
		)
	
		MusicTitleTransparency["TitleOut"] = TweenService:Create(
			Components.Title, 
			TweenInfo.new(FADE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), 
			{TextTransparency = 1}
		)
	
		MusicTitleTransparency["TitleIn"].Completed:Connect(function()
			task.wait(TITLE_DISPLAY_TIME)
			if MusicTitleTransparency["TitleOut"] then
				MusicTitleTransparency["TitleOut"]:Play()
			end
		end)
	
		MusicTitleTransparency["TitleIn"]:Play()
	end
	
	-- Create sound instances from the song list
	local function CreateSoundsFromList()
		SoundContainer = {}
		for i, songData in pairs(SONG_LIST) do
			local sound = Instance.new("Sound")
			sound.Name = songData.Name
			sound.SoundId = songData.SoundId
			sound.Volume = 1
			sound.Parent = script
	
			local Number = Instance.new("IntValue")
			Number.Name = "Number"
			Number.Value = i
			Number.Parent = sound
	
			local Volume = Instance.new("NumberValue")
			Volume.Name = "Volume"
			Volume.Value = 1
			Volume.Parent = sound
	
			table.insert(SoundContainer, sound)
		end
	end
	
	-- Get valid songs only
	local function GetValidSongs()
		return SoundContainer
	end
	
	-- Return random song
	local function ReturnRandomSong()
		local songs = GetValidSongs()
		if #songs == 0 then
			warn("No valid songs found in MusicHolder")
			return nil
		end
		return songs[math.random(1, #songs)]
	end
	
	-- Return next song in sequence
	local function ReturnNext()
		if not CurrentSong or not CurrentSong:FindFirstChild("Number") then
			return ReturnRandomSong()
		end
	
		local currentNumber = CurrentSong:FindFirstChild("Number").Value
		local validSongs = GetValidSongs()
		local nextNumber = (currentNumber % #validSongs) + 1
	
		for _, sound in pairs(validSongs) do 
			if sound:FindFirstChild("Number") and sound:FindFirstChild("Number").Value == nextNumber then
				return sound
			end
		end
	
		return ReturnRandomSong()
	end
	
	-- Return previous song in sequence
	local function ReturnPrevious()
		if not CurrentSong or not CurrentSong:FindFirstChild("Number") then
			return ReturnRandomSong()
		end
	
		local currentNumber = CurrentSong:FindFirstChild("Number").Value
		local validSongs = GetValidSongs()
		local prevNumber = currentNumber - 1
		if prevNumber < 1 then
			prevNumber = #validSongs
		end
	
		for _, sound in pairs(validSongs) do 
			if sound:FindFirstChild("Number") and sound:FindFirstChild("Number").Value == prevNumber then
				return sound
			end
		end
	
		return ReturnRandomSong()
	end
	
	-- Button color animation
	local function ButtonColourTween(Button)
		if not Button then return end
	
		Button.ImageColor3 = Color3.fromRGB(255, 255, 255)
		TweenService:Create(
			Button, 
			TweenInfo.new(BUTTON_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0), 
			{ImageColor3 = Color3.fromRGB(34, 255, 122)}
		):Play()
	end
	
	-- Title effect
	local function Effect()
		if MusicTitleTransparency["TitleIn"] then
			MusicTitleTransparency["TitleIn"]:Cancel()
		end
		if MusicTitleTransparency["TitleOut"] then
			MusicTitleTransparency["TitleOut"]:Cancel()
		end
	
		Components.Title.TextTransparency = 1
		task.delay(1, function()
			MusicTitleFade()
		end)
	end
	
	-- Stop current song with fade out
	local function StopCurrentSong(shouldPause, targetSound)
		local soundToStop = targetSound or CurrentSong
		if not soundToStop or not soundToStop:IsA("Sound") then 
			return 
		end
	
		local fadeOutTween = TweenService:Create(
			soundToStop, 
			TweenInfo.new(VOLUME_TWEEN_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), 
			{Volume = 0}
		)
	
		fadeOutTween.Completed:Connect(function()
			if shouldPause then
				soundToStop:Pause()
			else 
				soundToStop:Stop()
			end
		end)
	
		fadeOutTween:Play()
	end
	
	-- Format time as MM:SS
	local function FormatTime(seconds)
		local minutes = math.floor(seconds / 60)
		local secs = seconds % 60
		return string.format("%i:%02i", minutes, secs)
	end
	
	-- Main play song function
	local function PlaySong(Sound)
		if not Sound or not Sound:IsA("Sound") then
			warn("Invalid sound provided, selecting random song")
			Sound = ReturnRandomSong()
			if not Sound then
				warn("No valid sounds available in MusicHolder")
				return false
			end
		end
	
		-- Disconnect existing render connection
		if SoundEndRender then 
			SoundEndRender:Disconnect() 
			SoundEndRender = nil
		end
	
		-- Wait for sound to load
		local function WaitForSoundLoad()
			local startTime = tick()
			while tick() - startTime < LOAD_TIMEOUT do
				if Sound.TimeLength > 0.1 then
					print("Loaded Sound: " .. Sound.Name)
					return true
				end
				task.wait(0.1)
			end
	
			warn(Sound.Name .. " failed to load within timeout")
			return false
		end
	
		if not WaitForSoundLoad() then
			local nextSong = ReturnNext()
			if nextSong and nextSong ~= Sound then
				return PlaySong(nextSong)
			else
				warn("Cannot load any songs in MusicHolder")
				return false
			end
		end
	
		-- Set up timing variables
		TotalTime = math.floor(Sound.TimeLength + 0.5)
		LastTick = tick()
		LastLeft = TotalTime
	
		-- Handle resume vs new song
		if SongStatus == "Paused" and Sound == CurrentSong then
			elapsed = math.floor(Sound.TimePosition + 0.5)
			Components.Title.Text = "Currently Resumed"
			Sound:Resume()
		else
			elapsed = 0
			Components.MusicName.Text = Sound.Name .. " [" .. FormatTime(elapsed) .. "]"
			Components.Title.Text = "Currently Playing"
			Sound:Play()
		end
	
		-- Set up progress tracking
		SoundEndRender = RunService.RenderStepped:Connect(function()
			if (tick() - LastTick) >= 1 and SongStatus == "Playing" then
				-- Stop any other playing sounds
				for _, otherSound in pairs(GetValidSongs()) do 
					if otherSound.IsPlaying and otherSound ~= Sound then
						StopCurrentSong(false, otherSound)
					end
				end
	
				elapsed = math.floor(Sound.TimePosition + 0.5)
				TimeLeft = TotalTime - elapsed
	
				-- Update UI
				Components.MusicName.Text = Sound.Name .. " [" .. FormatTime(elapsed) .. "]"
	
				-- Check if song ended
				if TimeLeft <= 0 or not Sound.IsPlaying then
					if SoundEndRender then
						SoundEndRender:Disconnect()
						SoundEndRender = nil
					end
	
					local nextSong = ReturnNext()
					if nextSong then
						CurrentSong = nextSong
						PlaySong(CurrentSong)
					end
					return
				end
	
				-- Update progress bar
				local fillPercentage = math.min(1, elapsed / TotalTime)
				if Components.Progress and Components.Progress:FindFirstChild("Fill") then
					TweenService:Create(
						Components.Progress.Fill, 
						TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), 
						{Size = UDim2.fromScale(fillPercentage, Components.Progress.Fill.Size.Y.Scale)}
					):Play()
				end
	
				LastLeft = TimeLeft
				LastTick = tick()
			end
		end)
	
		-- Fade in volume
		Sound.Volume = 0
		local targetVolume = 1
		if Sound:FindFirstChild("Volume") then
			targetVolume = Sound:FindFirstChild("Volume").Value
		end
	
		TweenService:Create(
			Sound, 
			TweenInfo.new(VOLUME_TWEEN_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), 
			{Volume = targetVolume}
		):Play()
	
		Effect()
		return true
	end
	
	-- Initialize the music player
	local function Initialize()
		InitializeComponents()
		CreateSoundsFromList()
	
		CurrentSong = ReturnRandomSong()
		if CurrentSong then
			PlaySong(CurrentSong)
		else
			warn("No songs found in song list")
		end
	end
	
	-- Control button connections
	local function SetupControls()
		-- Pause/Resume button
		Components.Control.Pause.Activated:Connect(function()
			if Debounce then return end
			Debounce = true
	
			local pauseButton = Components.Control.Pause:FindFirstChild("ImageLabel")
			if pauseButton then
				ButtonColourTween(pauseButton)
			end
	
			if SongStatus == "Paused" then
				if CurrentSong then
					PlaySong(CurrentSong)
				end
				SongStatus = "Playing"
				if pauseButton then
					pauseButton.Image = "rbxassetid://13980756617"
				end
			else
				Components.Title.Text = "Currently Paused"
				Effect()
				SongStatus = "Paused" 
				StopCurrentSong(true) 
				if pauseButton then
					pauseButton.Image = "rbxassetid://5048853382"
				end
			end
	
			task.wait(DEBOUNCE_TIME)
			Debounce = false
		end)
	
		-- Next button
		Components.Control.Next.Activated:Connect(function()
			if Debounce then return end
			Debounce = true
	
			local nextButton = Components.Control.Next:FindFirstChild("ImageLabel")
			if nextButton then
				ButtonColourTween(nextButton)
			end
	
			local nextSong = ReturnNext()
			if nextSong then
				StopCurrentSong(false)
	
				if SongStatus == "Paused" then
					SongStatus = "Playing"
					local pauseButton = Components.Control.Pause:FindFirstChild("ImageLabel")
					if pauseButton then
						pauseButton.Image = "rbxassetid://13980756617"
					end
				end
	
				CurrentSong = nextSong
				PlaySong(CurrentSong)
			end
	
			task.wait(DEBOUNCE_TIME)
			Debounce = false
		end)
	
		-- Previous button
		Components.Control.Previous.Activated:Connect(function()
			if Debounce then return end
			Debounce = true
	
			local prevButton = Components.Control.Previous:FindFirstChild("ImageLabel")
			if prevButton then
				ButtonColourTween(prevButton)
			end
	
			local prevSong = ReturnPrevious()
			if prevSong then
				StopCurrentSong(false)
	
				if SongStatus == "Paused" then
					SongStatus = "Playing"
					local pauseButton = Components.Control.Pause:FindFirstChild("ImageLabel")
					if pauseButton then
						pauseButton.Image = "rbxassetid://13980756617"
					end
				end
	
				CurrentSong = prevSong
				PlaySong(CurrentSong)
			end
	
			task.wait(DEBOUNCE_TIME)
			Debounce = false
		end)
	end
	
	-- Cleanup function
	local function Cleanup()
		if SoundEndRender then
			SoundEndRender:Disconnect()
			SoundEndRender = nil
		end
	
		for _, tween in pairs(MusicTitleTransparency) do
			if tween then
				tween:Cancel()
			end
		end
	end
	
	-- Handle script cleanup
	script.AncestryChanged:Connect(function()
		if not script.Parent then
			Cleanup()
		end
	end)
	
	-- Initialize everything
	pcall(function()
		Initialize()
		SetupControls()
	end)
end
coroutine.wrap(VYUDCMG_fake_script)()
local function VXDMR_fake_script() -- MusicGui.LocalScript 
	local script = Instance.new('LocalScript', MusicGui)

	frame = script.Parent.Frame
	frame.Draggable = true
	frame.Selectable = true
	frame.Active = true
end
coroutine.wrap(VXDMR_fake_script)()
