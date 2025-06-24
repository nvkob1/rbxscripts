getgenv().ServerHopperConfig = getgenv().ServerHopperConfig or {
   ["Players Left to Hop"] = 2
}

local config = getgenv().ServerHopperConfig
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local function serverHop()
   local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
   
   for _, server in pairs(servers.data) do
       if server.playing < server.maxPlayers and server.id ~= game.JobId then
           TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
           break
       end
   end
end

Players.PlayerRemoving:Connect(function()
   wait(1)
   if #Players:GetPlayers() <= config["Players Left to Hop"] then
       serverHop()
   end
end)
