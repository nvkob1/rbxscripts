-- Auto hops servers when a friend joins.

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- Function to get the player's friends
local function GetFriends(userId)
    local success, result = pcall(function()
        return Players:GetFriendsAsync(userId)
    end)
    if success then
        local friendsList = {}
        for _, friend in pairs(result:GetCurrentPage()) do
            friendsList[friend.Id] = true
        end
        return friendsList
    else
        warn("Failed to fetch friends list:", result)
        return {}
    end
end

-- Function to find a new server
local function ServerHop()
    local serversUrl = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(serversUrl))
    end)
    
    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                return
            end
        end
    end
end

-- Monitor for friends joining
local friendsList = GetFriends(LocalPlayer.UserId)

Players.PlayerAdded:Connect(function(player)
    if friendsList[player.UserId] then
        print("Friend joined! Hopping to a new server...")
        ServerHop()
    end
end)
