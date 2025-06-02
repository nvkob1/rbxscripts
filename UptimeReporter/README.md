```lua
getgenv().WEBHOOK_URL = "your_webhook_url_here" -- Set webhook URL (required)
getgenv().WEBHOOK_INTERVAL = 600 -- default is 600 seconds (10 minutes)
loadstring(game:HttpGet("https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/UptimeReporter/UptimeReporter.lua"))()
```
