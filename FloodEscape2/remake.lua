-- Auto Farm created by tomato.txt on discord
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))();task.spawn(loadstring(game:HttpGet("https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/FloodEscape2/autofarm.lua")))
local Window = Library.CreateLib("WinIt x1000", "Ocean")
local Tab = Window:NewTab("Auto")
local Section = Tab:NewSection("Main")
Section:NewToggle("Auto-Farm", "Wins for your noob self!", function(state)
    getgenv().TomatoAutoFarm = state
end);Section:NewLabel("made by tomato.txt")
