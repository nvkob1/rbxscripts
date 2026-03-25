local folderName = "TPRR Auto Farm"
if not isfolder(folderName) then makefolder(folderName) end

local API, HttpService, TeleportService, CoreGui = nil, game:GetService("HttpService"), game:GetService("TeleportService"), game:GetService("CoreGui")
local RemoveErrorPrompts = true
local IterationSpeed = 0.25
local ExcludefullServers = true
local SaveTeleportAttempts = false
local API = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"

local serversFile = folderName .. "/Servers.JSON"
local attemptsFile = folderName .. "/Attempts.txt"

local function EncodeToFile(JSONString)
    local success, JSONData = pcall(function()
        return HttpService:JSONDecode(JSONString)
    end)
    if success and JSONData.data then
        JSONData.gameId = game.PlaceId
        local s, encoded = pcall(function()
            return HttpService:JSONEncode(JSONData)
        end)
        if s then
            writefile(serversFile, encoded)
        else
            warn("Failed to encode JSON string.")
            return nil
        end
    else
        warn("Failed to decode JSONData.")
        return nil
    end
    return JSONData
end

local function NextCursor(ep)
    return game:HttpGet(API .. "&excludeFullGames=" .. tostring(ExcludefullServers) .. ((ep and "&cursor=" .. ep) or ""))
end

local function StartTeleport()
    local JSONData = EncodeToFile(readfile(serversFile))
    if not JSONData then
        writefile(serversFile, game:HttpGet(API))
        StartTeleport()
    end
    for i = 0, 99 do
        if #JSONData.data <= 1 then
            EncodeToFile(NextCursor(JSONData.nextPageCursor))
            TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
        end
        if JSONData.data[i] then
            local JobId = JSONData.data[i].id
            table.remove(JSONData.data, i)
            local s, encoded = pcall(function()
                return HttpService:JSONEncode(JSONData)
            end)
            writefile(serversFile, encoded)
            if SaveTeleportAttempts then
                appendfile(attemptsFile, JobId .. "\n")
            end
            TeleportService:TeleportToPlaceInstance(game.PlaceId, JobId, game.Players.LocalPlayer)
            task.wait(IterationSpeed)
        end
    end
end

local function SetMainPage()
    writefile(serversFile, game:HttpGet(API))
    StartTeleport()
end

if RemoveErrorPrompts then
    CoreGui:WaitForChild("RobloxGui"):WaitForChild("Modules"):WaitForChild("ErrorPrompt"):Destroy()
    CoreGui.RobloxPromptGui:Destroy()
end

if isfile(serversFile) then
    local success, JSONData = pcall(function()
        return HttpService:JSONDecode(readfile(serversFile))
    end)
    if success and JSONData then
        if JSONData.gameId ~= game.PlaceId then
            warn("Game mismatch, remaking cache for --> " .. game.PlaceId)
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
