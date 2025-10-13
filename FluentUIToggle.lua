local function createMobileToggleButton()
   local UserInputService = game:GetService("UserInputService")
   local CoreGui = game:GetService("CoreGui")

   local existingGui = CoreGui:FindFirstChild("FluentToggleButton")
   if existingGui then
       existingGui:Destroy()
   end

   local ToggleGui = Instance.new("ScreenGui")
   ToggleGui.Name = "FluentToggleButton"
   ToggleGui.ResetOnSpawn = false
   ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
   ToggleGui.DisplayOrder = 999999

   local ToggleButton = Instance.new("TextButton")
   ToggleButton.Name = "ToggleButton"
   ToggleButton.Size = UDim2.new(0, 40, 0, 40)
   ToggleButton.Position = UDim2.new(0.05, 0, 0.05, 0)
   ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
   ToggleButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
   ToggleButton.Text = "UI"
   ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
   ToggleButton.TextSize = 14
   ToggleButton.Font = Enum.Font.GothamBold
   ToggleButton.AutoButtonColor = true
   ToggleButton.ZIndex = 9999
   ToggleButton.Parent = ToggleGui

   local UICorner = Instance.new("UICorner")
   UICorner.CornerRadius = UDim.new(0.5, 0)
   UICorner.Parent = ToggleButton

   local dragging = false
   local dragStart
   local startPos

   local function setupDragging()
       ToggleButton.Draggable = false
       ToggleButton.Selectable = false
       ToggleButton.Active = false
       
       local function updateInput(input)
           local delta = input.Position - dragStart
           ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
       end

       local conn1, conn2, conn3
       conn1 = ToggleButton.InputBegan:Connect(function(input)
           if input.UserInputType == Enum.UserInputType.MouseButton1 then
               dragging = true
               dragStart = input.Position
               startPos = ToggleButton.Position
           end
       end)

       conn2 = ToggleButton.InputEnded:Connect(function(input)
           if input.UserInputType == Enum.UserInputType.MouseButton1 then
               dragging = false
           end
       end)

       conn3 = UserInputService.InputChanged:Connect(function(input)
           if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
               updateInput(input)
           end
       end)

       return {conn1, conn2, conn3}
   end

   local function setupMobile()
       ToggleButton.Draggable = true
       ToggleButton.Selectable = true
       ToggleButton.Active = true
   end

   local connections = {}
   local function updateDeviceType()
       for _, conn in ipairs(connections) do
           conn:Disconnect()
       end
       connections = {}
       
       if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
           setupMobile()
       else
           connections = setupDragging()
       end
   end

   UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(updateDeviceType)
   UserInputService:GetPropertyChangedSignal("MouseEnabled"):Connect(updateDeviceType)
   updateDeviceType()

   ToggleButton.MouseButton1Click:Connect(function()
       if getgenv().Fluent and getgenv().Fluent.Window then
           getgenv().Fluent.Window:Minimize()
       end
       ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
       task.delay(0.1, function()
           ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
       end)
   end)

   ToggleGui.Parent = CoreGui
   return ToggleGui
end

task.spawn(createMobileToggleButton)
