-- Auto-hops servers if a friend joins.
local Players, TeleportService, HttpService = game:GetService("Players"), game:GetService("TeleportService"), game:GetService("HttpService")
local LocalPlayer, PlaceId = Players.LocalPlayer, game.PlaceId

local function GetFriends(id)
    local s, r = pcall(function() return Players:GetFriendsAsync(id):GetCurrentPage() end)
    if s then 
        local f = {} 
        for _, v in pairs(r) do f[v.Id] = true end 
        return f 
    end
    return {}
end

local function ServerHop()
    local s, r = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")) end)
    if s and r and r.data then
        for _, v in pairs(r.data) do
            if v.id ~= game.JobId and v.playing < v.maxPlayers then
                return TeleportService:TeleportToPlaceInstance(PlaceId, v.id, LocalPlayer)
            end
        end
    end
end

local f = GetFriends(LocalPlayer.UserId)
for _, v in pairs(Players:GetPlayers()) do if f[v.UserId] then return ServerHop() end end
Players.PlayerAdded:Connect(function(p) if f[p.UserId] then ServerHop() end end)
