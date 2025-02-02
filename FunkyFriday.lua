-- Auto Play Script
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nadir3709/ScriptHub/main/Loader"))()

-- Auto Solo
while true do
for i,k in pairs(game:GetService("Workspace").Map.Stages:GetDescendants()) do
   if k.Parent.Name == ("Pads") and k.BrickColor.Name == ("Institutional white") then
       game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(k.Position)
   end
end
task.wait(0.2)
local vs = game:GetService("VirtualUser")
for i,v in pairs(game:GetService("Workspace").Map.Stages:GetDescendants()) do
   if v:IsA("ProximityPrompt") then
       v.HoldDuration = 0
   end
end
vs:SetKeyDown("e")
wait()
vs:SetKeyUp("e")
wait(5)

local args = {
    [1] = {
        [1] = "Server",
        [2] = "StageManager",
        [3] = "Select"
    },
    [2] = {
        [1] = "VSCamellia_Ghost",
        [2] = "Mania"
    }
}

game:GetService("ReplicatedStorage").RE:FireServer(unpack(args))

wait(5)
local args = {
    [1] = {
        [1] = "Server",
        [2] = "StageManager",
        [3] = "PlaySolo"
    },
    [2] = {}
}

game:GetService("ReplicatedStorage").RE:FireServer(unpack(args))

wait(360)
end
