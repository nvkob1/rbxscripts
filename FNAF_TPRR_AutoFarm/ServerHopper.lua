local folderName = "TPRR Auto Farm"
if not isfolder(folderName) then makefolder(folderName) end

local HttpService, TeleportService, CoreGui = game:GetService("HttpService"), game:GetService("TeleportService"), game:GetService("CoreGui")
local RemoveErrorPrompts = true
local IterationSpeed = 0.25
local ExcludefullServers = true
local SaveTeleportAttempts = false
local API = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"

local serversFile = folderName .. "/Servers.JSON"
local attemptsFile = folderName .. "/Attempts.txt"

local function SafeHttpGet(url, retries)
    retries = retries or 3
    for i = 1, retries do
        local s, res = pcall(function() return game:HttpGet(url) end)
        if s and res and res ~= "" then
            return res
        end
        task.wait(1)
    end
    return nil
end

local function SafeDecode(str)
    if not str or str == "" then return nil end
    local s, data = pcall(function() return HttpService:JSONDecode(str) end)
    if s and data and data.data then return data end
    return nil
end

local function NextCursor(ep)
    local url = API .. "&excludeFullGames=" .. tostring(ExcludefullServers) .. ((ep and "&cursor=" .. ep) or "")
    return SafeHttpGet(url)
end

local function EncodeToFile(JSONString)
    local JSONData = SafeDecode(JSONString)
    if not JSONData then
        warn("Failed to decode JSONData.")
        return nil
    end
    JSONData.gameId = game.PlaceId
    local s, encoded = pcall(function() return HttpService:JSONEncode(JSONData) end)
    if s then writefile(serversFile, encoded) end
    return JSONData
end

local function StartTeleport()
    local raw = readfile(serversFile)
    local JSONData = SafeDecode(raw)
    if not JSONData then
        local fresh = SafeHttpGet(API)
        if not fresh then warn("Failed to fetch server list.") return end
        writefile(serversFile, fresh)
        JSONData = SafeDecode(fresh)
        if not JSONData then warn("Server list invalid after retry.") return end
        JSONData.gameId = game.PlaceId
        local s, encoded = pcall(function() return HttpService:JSONEncode(JSONData) end)
        if s then writefile(serversFile, encoded) end
    end

    for i = 0, 99 do
        if #JSONData.data <= 1 then
            local nextRaw = NextCursor(JSONData.nextPageCursor)
            if nextRaw then
                JSONData = EncodeToFile(nextRaw) or JSONData
            end
            TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
            return
        end
        if JSONData.data[i] then
            local JobId = JSONData.data[i].id
            table.remove(JSONData.data, i)
            local s, encoded = pcall(function() return HttpService:JSONEncode(JSONData) end)
            if s then writefile(serversFile, encoded) end
            if SaveTeleportAttempts then appendfile(attemptsFile, JobId .. "\n") end
            TeleportService:TeleportToPlaceInstance(game.PlaceId, JobId, game.Players.LocalPlayer)
            task.wait(IterationSpeed)
        end
    end
end

local function SetMainPage()
    local raw = SafeHttpGet(API)
    if not raw then warn("Failed to fetch main page.") return end
    writefile(serversFile, raw)
    StartTeleport()
end

if RemoveErrorPrompts then
    pcall(function()
        CoreGui:WaitForChild("RobloxGui"):WaitForChild("Modules"):WaitForChild("ErrorPrompt"):Destroy()
        CoreGui.RobloxPromptGui:Destroy()
    end)
end

if isfile(serversFile) then
    local JSONData = SafeDecode(readfile(serversFile))
    if JSONData then
        if JSONData.gameId ~= game.PlaceId then
            warn("Game mismatch, remaking cache.")
            SetMainPage()
        elseif JSONData.data and #JSONData.data >= 1 then
            StartTeleport()
        elseif JSONData.nextPageCursor then
            local nextRaw = NextCursor(JSONData.nextPageCursor)
            if nextRaw then EncodeToFile(nextRaw) end
            StartTeleport()
        else
            SetMainPage()
        end
    else
        SetMainPage()
    end
else
    SetMainPage()
end
