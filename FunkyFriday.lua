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
                        if distance < 10 then 
                            playersNearby = true
                            break
                        end
                    end
                end
                if not playersNearby then
                    return pad
                end
            end
        end
    end
    return nil 
end

local function fireProximityPrompts()
    wait(0.1)
    for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            fireproximityprompt(v)
        end
    end
end

local function moveMouseAndClick(guiObject)
    local UIS = game:GetService("UserInputService")
    local pos = guiObject.AbsolutePosition + guiObject.AbsoluteSize / 2
    UIS.MouseBehavior = Enum.MouseBehavior.Default
    mousemoverel(pos.X, pos.Y)
    wait(0.1)
    mouse1click()
end

local function scrollFrameToFind(frame, target)
    local UIS = game:GetService("UserInputService")
    while not target or not target.Visible do
        frame.CanvasPosition = frame.CanvasPosition + Vector2.new(0, 50)
        wait(0.1)
    end
    moveMouseAndClick(target)
end

local function selectSong()
    local player = game.Players.LocalPlayer
    local songSelector = player.PlayerGui.GameUI.Windows.SongSelector
    
    if songSelector and songSelector.Visible then
        local categoriesFrame = songSelector.Frame.Categories
        local vsCamelliaButton = categoriesFrame["VS Camellia"]
        
        scrollFrameToFind(categoriesFrame, vsCamelliaButton)
        print("Clicked VS Camellia Button.")
        
        local songsFrame = songSelector.Frame.Songs
        local ghostSongButton = songsFrame.Ghost
        
        scrollFrameToFind(songsFrame, ghostSongButton)
        print("Clicked Ghost Song Button.")
        
        local difficultyFrame = songSelector.Frame.Difficulty
        local maniaButton = difficultyFrame.Mania
        
        scrollFrameToFind(difficultyFrame, maniaButton)
        print("Clicked Mania Difficulty Button.")
    else
        print("Song Selector not visible, retrying...")
        main()
    end
end

function main()
    local player = game.Players.LocalPlayer
    local emptyPad = findEmptyPad()
    if emptyPad and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = emptyPad.CFrame
        print("Teleported to empty pad at:", emptyPad.Position)
        
        fireProximityPrompts()
        print("Fired all proximity prompts after delay.")
        
        wait(0.5)
        selectSong()
    else
        print("No empty pad found or unable to teleport.")
    end
end

main()
