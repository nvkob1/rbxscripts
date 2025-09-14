Usage Example:
```lua
-- Configuration
local config = {
    ScriptName = "Project Auto",
    Interval = 3600, -- Seconds (1 hour)
    Webhook = "YOUR_WEBHOOK_URL_HERE", -- Replace with your webhook URL
    ValuePath = "game:GetService('Players').LocalPlayer.leaderstats.Money" -- Path to money value
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/ValueTracker/script.lua"))()
```
