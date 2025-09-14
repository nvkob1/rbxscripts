local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Default config if none provided
local defaultConfig = {
    ScriptName = "Money Tracker",
    IntervalSeconds = 3600,
    Webhook = "",
    ValueLocation = "game:GetService(\"Players\").LocalPlayer.leaderstats.Money"
}

local config = getgenv().Config or defaultConfig

-- Validate required config
if not config.Webhook or config.Webhook == "" then
    error("Webhook URL is required in config")
    return
end

if not config.ValueLocation or config.ValueLocation == "" then
    error("ValueLocation is required in config")
    return
end

local function request(url, data)
    local success, result = pcall(function()
        return game:HttpPost(url, game:GetService("HttpService"):JSONEncode(data))
    end)
    if not success then
        warn("Webhook request failed: " .. tostring(result))
    end
end

local function getValueFromPath(path)
    local success, result = pcall(function()
        return loadstring("return " .. path)()
    end)
    return success and result or nil
end

local function getMapName()
    return Workspace.Name or "Unknown Map"
end

local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function sendWebhook(startMoney, currentMoney, duration)
    local gained = currentMoney - startMoney
    local perHour = math.floor((gained / duration) * 3600)
    
    local data = {
        content = string.format(
            "**%s Report**\n" ..
            "🗺️ Map: %s\n" ..
            "💰 Money Gained: %d\n" ..
            "⏱️ Duration: %s\n" ..
            "📈 Money Per Hour: %d",
            config.ScriptName,
            getMapName(),
            gained,
            formatTime(duration),
            perHour
        )
    }
    
    request(config.Webhook, data)
end

local startTime = tick()
local moneyValue = getValueFromPath(config.ValueLocation)

if not moneyValue then
    error("Invalid ValueLocation: " .. config.ValueLocation .. " - Could not find value")
    return
end

local startMoney = moneyValue.Value

while player.Parent do
    wait(config.IntervalSeconds)
    
    moneyValue = getValueFromPath(config.ValueLocation)
    if moneyValue then
        local currentMoney = moneyValue.Value
        local duration = tick() - startTime
        
        sendWebhook(startMoney, currentMoney, duration)
        startMoney = currentMoney
        startTime = tick()
    else
        warn("ValueLocation became invalid during runtime")
    end
end
