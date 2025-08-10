# Usage Example
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/UNC_Check/UNC-Check.lua"))()({
    scriptName = "FluentUI",
    requiredFunctions = {
        "loadstring",
        "game.HttpGet",
        "isfolder",
        "makefolder",
        "writefile",
        "isfile",
        "getgenv",
        "task.spawn",
        "task.wait"
    },
    optionalFunctions = {
        "cloneref",
        "hookmetamethod",
        "getrawmetatable"
    },
    mainScript = function()
        -- Your main script code here
    end
})
```
