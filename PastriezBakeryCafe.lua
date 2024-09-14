-- Sometimes the boat may disappear. If this happens, either re-run the script or rejoin the game.
-- It takes 10 - 20 seconds for the script to run
-- Have fun nuking the fuck out of pastriez


local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer



local function setPrimaryPartIfNeeded(model)
	if not model.PrimaryPart then
		for _, part in pairs(model:GetChildren()) do
			if part:IsA("BasePart") then
				model.PrimaryPart = part
				print("PrimaryPart set to: " .. part.Name)
				break
			end
		end
		if not model.PrimaryPart then
			warn("No BasePart found to set as PrimaryPart.")
		end
	end
end

local function TPOffMap()
	local activeBoats = Workspace.Functionality.Dock:FindFirstChild("ActiveBoats")
	local ActiveJetskis = Workspace.Functionality.Dock:FindFirstChild("ActiveJetskis")
	if ActiveJetskis then
		
		for _, Jetski in ipairs(ActiveJetskis:GetChildren()) do
			task.wait(5)
			local localPlayer = Players.LocalPlayer
			local localCharacter = localPlayer.Character
			if localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") then
				
				local jetskicontrol = Jetski:WaitForChild("BoatControl")
				local seat = jetskicontrol:WaitForChild("Seat")
				local localPlayer = Players.LocalPlayer
				local localCharacter = localPlayer.Character
				
				if localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") then
					local humanoidRootPart = localCharacter.HumanoidRootPart
					humanoidRootPart.CFrame = seat.CFrame
					setPrimaryPartIfNeeded(Jetski)
					task.wait(1)

					if Jetski.PrimaryPart then
						Jetski:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, -250, 0)))
						local localPlayer = Players.LocalPlayer
						game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics) game.Players.LocalPlayer.Character.Humanoid:Move(Vector3.new(0, 50, 0))
						game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-26, 22, 356)




					end

				end
			end
		end


	end
	if activeBoats then
		for _, boat in ipairs(activeBoats:GetChildren()) do
			if boat:IsA("Model") then
				task.wait(5)
				local seat = boat:WaitForChild("PassengerSeatThree")
				local localPlayer = Players.LocalPlayer
				local localCharacter = localPlayer.Character
				if localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") then
					local humanoidRootPart = localCharacter.HumanoidRootPart
					local seat = boat:WaitForChild("PassengerSeatThree")
					humanoidRootPart.CFrame = seat.CFrame 
					setPrimaryPartIfNeeded(boat)
					task.wait(1)

					if boat.PrimaryPart then
						boat:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, -250, 0)))
						local localPlayer = Players.LocalPlayer
						game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics) game.Players.LocalPlayer.Character.Humanoid:Move(Vector3.new(0, 50, 0))
						game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-26, 22, 356)

						

					end


					
				end


			end

		end
	end
end 



TPOffMap()    



    
game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(Vector3.new(-38, 22, 362)))        
        
      
task.wait(3)
game:GetService("ReplicatedStorage").Packages.Knit.Services.DockService.RE.SpawnVehicle:FireServer("Boat")
game:GetService("ReplicatedStorage").Packages.Knit.Services.DockService.RE.SpawnVehicle:FireServer("Jetski")


local name= `{game.Players.LocalPlayer.Name}Boat`

local boat = Workspace.Functionality.Dock.ActiveBoats:WaitForChild(name)
local seat = boat:WaitForChild("PassengerSeatTwo")
local seat2 = boat:WaitForChild("PassengerSeatThree")

local function setPrimaryPartIfNeeded2(model)
	if not model.PrimaryPart then
		for _, part in pairs(model:GetChildren()) do
			if part:IsA("BasePart") then
				model.PrimaryPart = part
				print("PrimaryPart set to: " .. part.Name)
				break
			end
		end
		if not model.PrimaryPart then
			warn("No BasePart found to set as PrimaryPart.")
		end
	end
end



local function makeLocalPlayerSit()
	local localPlayer = Players.LocalPlayer
	local localCharacter = localPlayer.Character
	if localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = localCharacter.HumanoidRootPart
		humanoidRootPart.CFrame = seat2.CFrame + Vector3.new(0, 1, 0) 
		print(localPlayer.Name .. " has been teleported to PassengerSeatTwo.")
	else
		warn(localPlayer.Name .. " does not have a character or HumanoidRootPart!")
	end
end








local function teleportPlayerToSeat(targetPlayer)
	
	local targetCharacter = targetPlayer.Character
	if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = targetCharacter.HumanoidRootPart   
		humanoidRootPart.CFrame = seat.CFrame + Vector3.new(0, 1, 0) 
		print(targetPlayer.Name .. " has been teleported to PassengerSeatTwo.")
	else
		warn(targetPlayer.Name .. " does not have a character or HumanoidRootPart!")
	end
end
local function teleportBoatToPlayer(targetPlayer)
	local targetCharacter = targetPlayer.Character
	if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
		local targetPosition = targetCharacter.HumanoidRootPart.Position
		setPrimaryPartIfNeeded2(boat)

		if boat.PrimaryPart then
			boat:SetPrimaryPartCFrame(CFrame.new(targetPosition))
			print("Boat has been teleported to " .. targetPlayer.Name)
			teleportPlayerToSeat(targetPlayer)
		else
			warn("Boat does not have a valid PrimaryPart.")
		end
	else
		warn("Target player does not have a character or HumanoidRootPart!")
	end
end

task.wait(1)



local localPlayer = Players.LocalPlayer

while true do
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
			teleportBoatToPlayer(player)
			makeLocalPlayerSit()

            task.wait(0.04) 
        end
    end
    
end
