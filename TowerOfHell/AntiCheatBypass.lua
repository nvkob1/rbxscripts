if game.GameId ~= 703124385 then
	task.defer(task.cancel, coroutine.running())
	coroutine.yield()
end

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer or Localplayer.CharacterAdded:Wait()

local PlayerScripts = LocalPlayer:FindFirstChildWhichIsA('PlayerScripts')
while not PlayerScripts do
	LocalPlayer.ChildAdded:Wait()
	PlayerScripts = LocalPlayer:FindFirstChildWhichIsA('PlayerScripts')
end

for _,v in {'LocalScript', 'LocalScript2'} do
	v = PlayerScripts:WaitForChild(v)
	for _,c in getconnections(v.Changed) do
		local f = c.Function
		if not f or isexecutorclosure(f) then
			continue
		end
		c:Disable()
	end
	v.Enabled = false
end
