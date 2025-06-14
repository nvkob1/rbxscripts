# HnS_HopBot
```lua
getgenv().Config = {
    delayBeforeHop = 2, -- seconds to wait before hopping
    debug = true, -- enable/disable debug notifications
    webhook = "", -- optional
    webhookInterval = 600, -- send status every 10 minutes (0 to disable)
    notHopIfTimeBelow = 45 -- don't hop if time is below this value
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/HideAndSeekExtreme/HnS_HopBot.lua"))()
```
Smart auto farm + server hop bot for **Hide and Seek Extreme**.

## Features
- Collects all coins
- Smart server hop based on timer and object availability
- Saves server data to avoid bad servers
- Auto retries on full/invalid servers

## How to Use
1. Put the script in autoexec folder and join the [Hide and Seek Extreme](https://www.roblox.com/games/205224386/Hide-and-Seek-Extreme).
2. The bot will:
   - Check timer & objects
   - Farm if possible
   - Server hop if needed

## Files
- `servers.txt`: Stores known server info (`JobId:Time:Timestamp`)

> Requires executor with `writefile`, `readfile`, `isfile`, `isfolder`, `makefolder`.
