loadstring(game:HttpGet("https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/UNC_Check/UNC-Check.lua"))()({
    scriptName = "MuscletoBreakWalls",
    requiredFunctions = {
        "loadstring",
        "game.HttpGet",
        "isfolder",
        "makefolder",
        "writefile",
        "isfile",
        "getgenv",
        "task.spawn",
        "task.wait",
        "firetouchinterest",
        "gethui"
    },
    optionalFunctions = {
        "cloneref",
        "hookmetamethod",
        "getrawmetatable"
    },
    mainScript = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/%2B1MuscletoBreakWalls/script.lua"))()
    end
})
