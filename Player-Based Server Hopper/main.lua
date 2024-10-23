local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Function to hop servers
local function hopServer()
    local servers = {}
    local gameId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Asc&limit=100"

    local response = HttpService:JSONDecode(game:HttpGet(url))
    
    if response and response.data then
        for _, server in pairs(response.data) do
            if server.playing and server.playing < server.maxPlayers then
                table.insert(servers, server.id)
            end
        end
    end

    -- Hop to a random server
    if #servers > 0 then
        local serverToJoin = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(gameId, serverToJoin, Players.LocalPlayer)
    end
end

-- Check players count in the server (excluding yourself)
if #Players:GetPlayers() - 1 == minimumPlayers then
    hopServer()
end
