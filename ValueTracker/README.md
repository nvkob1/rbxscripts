Usage Example:
```lua
getgenv().Config = {
    ScriptName = "Project Auto",
    IntervalSeconds = 3600, -- 1 hour = 3600 seconds
    Webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL_HERE",
    ValueLocation = "game:GetService("Players").LocalPlayer.leaderstats.Money"
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/ValueTracker/script.lua"))()
```
