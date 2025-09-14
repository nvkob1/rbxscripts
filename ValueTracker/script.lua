-- Configuration
local config = config or {
    ScriptName = "Unknown",
    Interval = 3600, -- Seconds (1 hour)
    Webhook = "YOUR_WEBHOOK_URL_HERE", -- Replace with your webhook URL
    ValuePath = "" -- Path to value
}

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

-- Check webhook and value path validity
if config.Webhook == "YOUR_WEBHOOK_URL_HERE" or config.Webhook == "" then
    StarterGui:SetCore("SendNotification", {
        Title = "Error",
        Text = "Webhook URL is required. Please set a valid webhook URL in the config.",
        Duration = 10
    })
    error("Webhook URL is required.")
end

if config.ValuePath == "" then
    StarterGui:SetCore("SendNotification", {
        Title = "Error",
        Text = "Value path is required. Please set a valid value path in the config.",
        Duration = 10
    })
    error("Value path is required.")
end

-- Get money value from path
local money
local success, result = pcall(function()
    return loadstring("return " .. config.ValuePath)()
end)
if success and result then
    money = result
else
    StarterGui:SetCore("SendNotification", {
        Title = "Error",
        Text = "Invalid value path. Ensure it points to a valid IntValue (e.g., game:GetService('Players').LocalPlayer.leaderstats.Money).",
        Duration = 10
    })
    error("Invalid value path.")
end

local mapName = MarketplaceService:GetProductInfo(game.PlaceId).Name

-- Test webhook
local success, response = pcall(function()
    request({
        Url = config.Webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({content = "Started"})
    })
end)

if not success or response.StatusCode >= 400 then
    StarterGui:SetCore("SendNotification", {
        Title = "Error",
        Text = "Invalid webhook URL. Please check the webhook and try again.",
        Duration = 10
    })
    error("Invalid webhook URL.")
end

while true do
    local initialMoney = money.Value
    local startTime = os.clock()
    wait(config.Interval)
    local endTime = os.clock()
    local elapsed = endTime - startTime
    local currentMoney = money.Value
    local gained = currentMoney - initialMoney
    local perHour = math.round(gained * (3600 / elapsed))
    local duration = tostring(config.Interval) .. " seconds"
    
    local embed = {
        title = config.ScriptName .. " Report",
        color = 3447003,
        fields = {
            {name = "Map Name", value = mapName, inline = true},
            {name = "Money Gained", value = tostring(gained), inline = true},
            {name = "Duration", value = duration, inline = true},
            {name = "Money Per Hour", value = tostring(perHour), inline = true}
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    request({
        Url = config.Webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({embeds = {embed}})
    })
end
