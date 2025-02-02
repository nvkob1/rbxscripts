local function findEmptyPad()
    local stages = workspace.Map.Stages:GetChildren()
    for _, stage in ipairs(stages) do
        if stage:FindFirstChild("Pads") then
            local pads = stage.Pads:GetChildren()
            for _, pad in ipairs(pads) do
                local playersNearby = false
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (pad.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if distance < 10 then -- Adjust distance threshold as needed
                            playersNearby = true
                            break
                        end
                    end
                end
                if not playersNearby then
                    return pad -- Returns the first empty pad found
                end
            end
        end
    end
    return nil -- No empty pad found
end

while true do
    local player = game.Players.LocalPlayer
    local emptyPad = findEmptyPad()
    if emptyPad and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = emptyPad.CFrame
        print("Teleported to empty pad at:", emptyPad.Position)
        
        -- Fire all proximity prompts in the workspace after waiting 0.1 seconds
        local function fire()
            wait(0.2)
            for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    fireproximityprompt(v)
                end
            end
        end
        
        fire()
        print("Fired all proximity prompts after delay.")
        
        -- Wait 1 second and select Ghost Song
        wait(1)
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
        print("Selected Ghost Song")
        
        -- Wait 10.5 seconds and start solo
        wait(10.5)
        local args2 = {
            [1] = {
                [1] = "Server",
                [2] = "StageManager",
                [3] = "PlaySolo"
            },
            [2] = {}
        }
        game:GetService("ReplicatedStorage").RE:FireServer(unpack(args2))
        print("Started Solo")
        
        -- Wait 360 seconds and restart process
        wait(360)
    else
        print("No empty pad found or unable to teleport.")
    end
end
