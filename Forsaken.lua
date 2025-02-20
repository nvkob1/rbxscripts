task.wait(5)
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
if queueteleport then
	queueteleport(
		"loadstring(game:HttpGet('https://raw.githubusercontent.com/ivannetta/ShitScripts/main/PathfindGens.lua'))()"
	)
end

task.spawn(function()
	pcall(function()
		game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer(
			"UpdateSettings",
			game:GetService("Players").LocalPlayer.PlayerData.Settings.Game.MaliceDisabled,
			true
		)
	end)
end)

if _G.CancelPathEvent then
	_G.CancelPathEvent:Fire()
end

_G.CancelPathEvent = Instance.new("BindableEvent")

local function teleportToRandomServer()
	local Counter = 0
	local MaxRetry = 10
	local RetryingDelays = 10

	local Request = http_request or syn.request or request
	if Request then
		local url = "https://games.roblox.com/v1/games/18687417158/servers/Public?sortOrder=Asc&limit=100"

		while Counter < MaxRetry do
			local success, response = pcall(function()
				return Request({
					Url = url,
					Method = "GET",
					Headers = { ["Content-Type"] = "application/json" },
				})
			end)

			if success and response and response.Body then
				local data = HttpService:JSONDecode(response.Body)
				if data and data.data and #data.data > 0 then
					local server = data.data[math.random(1, #data.data)]
					if server.id then
						TeleportService:TeleportToPlaceInstance(18687417158, server.id, Players.LocalPlayer)
						return
					end
				end
			end

			Counter = Counter + 1
			task.wait(RetryingDelays)
		end
	end
end

local function findGenerators()
	local folder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
	local map = folder and folder:FindFirstChild("Map")
	local generators = {}
	if map then
		for _, g in ipairs(map:GetChildren()) do
			if g.Name == "Generator" and g.Progress.Value < 100 then
				local playersNearby = false
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= Players.LocalPlayer and player:DistanceFromCharacter(g:GetPivot().Position) <= 25 then
						playersNearby = true
					end
				end
				if not playersNearby then
					table.insert(generators, g)
				end
			end
		end
	end

	table.sort(generators, function(a, b)
		local player = Players.LocalPlayer
		local character = player.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then
			return false
		end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local aPosition = a:IsA("Model") and a:GetPivot().Position or a.Position
		local bPosition = b:IsA("Model") and b:GetPivot().Position or b.Position
		return (aPosition - rootPart.Position).Magnitude < (bPosition - rootPart.Position).Magnitude
	end)

	return generators
end

-- Function to Teleport Instead of Walking
local function TeleportToGenerator(generator)
	local player = Players.LocalPlayer
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local generatorPosition = generator:GetPivot().Position
		rootPart.CFrame = CFrame.new(generatorPosition + Vector3.new(0, 3, 0)) -- Teleport slightly above to avoid glitches
		return true
	end
	return false
end

local function DoAllGenerators()
	for _, g in ipairs(findGenerators()) do
		local pathStarted = false
		for attempt = 1, 3 do
			local playersNearby = false
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= Players.LocalPlayer and player:DistanceFromCharacter(g:GetPivot().Position) <= 25 then
					playersNearby = true
					break
				end
			end

			if (Players.LocalPlayer.Character:GetPivot().Position - g:GetPivot().Position).Magnitude > 500 then
				break
			end

			if not playersNearby and g:FindFirstChild("Progress") and g.Progress.Value < 100 then
				g:GetPivot()
			end

			pathStarted = TeleportToGenerator(g) -- Use teleport instead of pathfinding
			if pathStarted then
				break
			else
				task.wait(1)
			end
		end
		if pathStarted then
			task.wait(0.5)
			local prompt = g:FindFirstChild("Main") and g.Main:FindFirstChild("Prompt")
			if prompt then
				fireproximityprompt(prompt)
			end
			for i = 1, 6 do
				if g:FindFirstChild("Remotes") and g.Remotes:FindFirstChild("RE") then
					g.Remotes.RE:FireServer()
				end
				if i < 6 then
					task.wait(2.5)
				end
			end
		else
			return
		end
	end
	teleportToRandomServer()
end

local function AmIInGameYet()
	workspace.Players.Survivors.ChildAdded:Connect(function(child)
		task.wait(1)
		if child == game:GetService("Players").LocalPlayer.Character then
			task.wait(5)
			DoAllGenerators()
		end
	end)
end

local function DidiDie()
	while task.wait(0.5) do
		if Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
			if Players.LocalPlayer.Character.Humanoid.Health == 0 then
				task.wait(5)
				teleportToRandomServer()
			end
		end
	end
end

pcall(task.spawn(DidiDie))
AmIInGameYet()
