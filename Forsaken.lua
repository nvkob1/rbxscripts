task.wait(5)
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

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

local function findFurthestGenerator()
	local folder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame")
	local map = folder and folder:FindFirstChild("Map")
	local generators = {}

	if not map then return nil end

	-- Find all valid generators
	for _, g in ipairs(map:GetChildren()) do
		if g.Name == "Generator" and g.Progress.Value < 100 then
			table.insert(generators, g)
		end
	end

	-- Get all Killers
	local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
	local killers = killersFolder and killersFolder:GetChildren() or {}

	-- Function to calculate distance from a generator to all killers
	local function getMinDistanceToKillers(generator)
		local generatorPosition = generator:GetPivot().Position
		local minDistance = math.huge
		for _, killer in ipairs(killers) do
			if killer:IsA("Model") and killer.PrimaryPart then
				local killerPosition = killer.PrimaryPart.Position
				local distance = (generatorPosition - killerPosition).Magnitude
				if distance < minDistance then
					minDistance = distance
				end
			end
		end
		return minDistance
	end

	-- Find the generator that is the furthest from all killers
	local furthestGenerator = nil
	local maxDistance = 0

	for _, generator in ipairs(generators) do
		local distance = getMinDistanceToKillers(generator)
		if distance > maxDistance then
			maxDistance = distance
			furthestGenerator = generator
		end
	end

	return furthestGenerator
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
	while true do
		local generator = findFurthestGenerator()
		if not generator then
			teleportToRandomServer()
			return
		end

		-- Teleport to the furthest generator
		local pathStarted = TeleportToGenerator(generator)
		if not pathStarted then
			task.wait(1)
			continue
		end

		-- Start fixing the generator
		task.wait(0.5)
		local prompt = generator:FindFirstChild("Main") and generator.Main:FindFirstChild("Prompt")
		if prompt then
			fireproximityprompt(prompt)
		end
		for i = 1, 6 do
			if generator:FindFirstChild("Remotes") and generator.Remotes:FindFirstChild("RE") then
				generator.Remotes.RE:FireServer()
			end
			if i < 6 then
				task.wait(2.5)
			end
		end
	end
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
