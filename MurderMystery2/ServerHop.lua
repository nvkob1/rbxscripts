local API, HttpService, TeleportService, CoreGui = nil, game:GetService("HttpService"), game:GetService("TeleportService"), game:GetService("CoreGui");
local RemoveErrorPrompts = true
local IterationSpeed = 0.25
local ExcludefullServers = false
local SaveTeleportAttempts = false

local FolderPath = "MM2AutoFarm/CachedServerHop/"

local function EncodeToFile(JSONString)
   local success, JSONData = pcall(function()
       return HttpService:JSONDecode(JSONString)
   end)
   if success and JSONData.data then
       JSONData.gameId = game.PlaceId
       local success, encoded = pcall(function()
           return HttpService:JSONEncode(JSONData)
       end)
       if success then
           if not isfolder("MM2AutoFarm") then makefolder("MM2AutoFarm") end
           if not isfolder("MM2AutoFarm/CachedServerHop") then makefolder("MM2AutoFarm/CachedServerHop") end
           writefile(FolderPath .. "Servers.JSON", encoded)
       else
           error("Failed to encode JSON string.")
           return
       end
   else
       error("Failed to decode JSONData.")
       return
   end
   return JSONData
end

local function GetLowestPingServer(servers)
   local lowestPing = math.huge
   local bestServer = nil
   local bestIndex = nil
   
   for i, server in pairs(servers) do
       if server.ping and server.ping < lowestPing then
           lowestPing = server.ping
           bestServer = server
           bestIndex = i
       end
   end
   
   return bestServer, bestIndex
end

local function NextCursor(ep)
   return game:HttpGet(API .. "&excludeFullGames=" .. tostring(ExcludefullServers) .. ((ep and "&cursor=" .. ep) or ""))
end

local function StartTeleport()
   local JSONData = EncodeToFile(readfile(FolderPath .. "Servers.JSON"))
   for i = 0, 99 do
       if #JSONData.data <= 1 then
           EncodeToFile(NextCursor(JSONData.nextPageCursor))
           TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
       end
       
       local bestServer, bestIndex = GetLowestPingServer(JSONData.data)
       if bestServer then
           local JobId = bestServer.id
           table.remove(JSONData.data, bestIndex)
           local sucess, encoded = pcall(function()
               return HttpService:JSONEncode(JSONData)
           end)
           writefile(FolderPath .. "Servers.JSON", encoded)
           if SaveTeleportAttempts then
               appendfile(FolderPath .. "Attempts.txt", JobId .. "\n")
           end
           TeleportService:TeleportToPlaceInstance(game.PlaceId, JobId, game.Players.LocalPlayer)
           task.wait(IterationSpeed)
       end
   end
end

local function SetMainPage()
   local MainPage = game:HttpGet(API)
   if not isfolder("MM2AutoFarm") then makefolder("MM2AutoFarm") end
   if not isfolder("MM2AutoFarm/CachedServerHop") then makefolder("MM2AutoFarm/CachedServerHop") end
   writefile(FolderPath .. "Servers.JSON", MainPage)
   StartTeleport()
end

API = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"

if RemoveErrorPrompts then CoreGui:WaitForChild("RobloxGui"):WaitForChild("Modules"):WaitForChild("ErrorPrompt"):Destroy() CoreGui.RobloxPromptGui:Destroy() end

if isfile(FolderPath .. "Servers.JSON") then
   local success, JSONData = pcall(function()
       return HttpService:JSONDecode(readfile(FolderPath .. "Servers.JSON"))
   end)
   if success and JSONData then
       if JSONData.gameId ~= game.PlaceId then
           warn("Game mismatch from cache, remaking cache for --> " .. game.PlaceId)
           SetMainPage()
       end
       if JSONData.data and #JSONData.data >= 1 then
           StartTeleport()
       else
           if success and JSONData.nextPageCursor then
               EncodeToFile(NextCursor(JSONData.nextPageCursor))
               StartTeleport()
           else
               SetMainPage()
           end
       end
   else
       SetMainPage()
   end
else
   SetMainPage()
end
