local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:FindFirstChildWhichIsA("Humanoid")
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

local bag = localPlayer:WaitForChild("States"):WaitForChild("Bag")
local bagSizeLevel = localPlayer:WaitForChild("Stats"):WaitForChild("BagSizeLevel"):WaitForChild("CurrentAmount")
local robEvent = ReplicatedStorage:WaitForChild("GeneralEvents"):WaitForChild("Rob")
local targetPosition = CFrame.new(1636.62537, 104.349976, -1736.184)

-- Godmode
if humanoid then
    local clonedHumanoid = humanoid:Clone()
    clonedHumanoid.Parent = character
    localPlayer.Character = nil
    clonedHumanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    clonedHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    clonedHumanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    humanoid:Destroy()
    localPlayer.Character = character
    local camera = Workspace.CurrentCamera
    camera.CameraSubject = clonedHumanoid
    clonedHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    local animate = character:FindFirstChild("Animate")
    if animate then
        animate.Disabled = true
        task.wait()
        animate.Disabled = false
    end
    clonedHumanoid.Health = clonedHumanoid.MaxHealth
    humanoid = clonedHumanoid
    humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
end

-- Prevent AFK Kick
localPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Farming Function
local function farmTargets()
    if bag.Value >= bagSizeLevel.Value then
        humanoidRootPart.CFrame = targetPosition
        return
    end

    for _, item in ipairs(Workspace:GetChildren()) do
        if item:IsA("Model") then
            local openPart = item:FindFirstChild("Open")
            local unionPart = item:FindFirstChild("Union")
            local activeValue = item:FindFirstChild("Active")

            if item.Name == "CashRegister" and openPart then
                humanoidRootPart.CFrame = openPart.CFrame
                robEvent:FireServer("Register", { Part = unionPart, OpenPart = openPart, ActiveValue = activeValue, Active = true })
                return
            elseif item.Name == "Safe" and item:FindFirstChild("Amount") and item.Amount.Value > 0 then
                local safePart = item:FindFirstChild("Safe")
                if safePart then
                    humanoidRootPart.CFrame = safePart.CFrame
                    if item:FindFirstChild("Open").Value then
                        robEvent:FireServer("Safe", item)
                    else
                        item:FindFirstChild("OpenSafe"):FireServer("Completed")
                        robEvent:FireServer("Safe", item)
                    end
                    return
                end
            end
        end
    end
end

-- Run Efficiently with RenderStepped
RunService.RenderStepped:Connect(farmTargets)
