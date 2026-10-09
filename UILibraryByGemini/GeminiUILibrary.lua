--[[
    Gemini UI Library
    A modern, sleek, and lightweight UI library for Roblox.
    Author: cook45 (via clack's request)
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Gemini = {}

-- Utility for dragging
local function MakeDraggable(topbarobject, object)
    local Dragging = false
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        TweenService:Create(object, TweenInfo.new(0.15), {Position = pos}):Play()
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

function Gemini:CreateWindow(options)
    options = options or {}
    local WindowName = options.Name or "Gemini UI"
    local WindowSize = options.Size or UDim2.new(0, 500, 0, 350)
    local ThemeColor = options.ThemeColor or Color3.fromRGB(114, 137, 218)
    local ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GeminiUI"
    screenGui.ResetOnSpawn = false
    
    -- Attempt to parent to CoreGui, fallback to PlayerGui for testing in studio
    local success = pcall(function()
        screenGui.Parent = CoreGui
    end)
    if not success then
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = screenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -WindowSize.X.Offset/2, 0.5, -WindowSize.Y.Offset/2)
    MainFrame.Size = WindowSize
    MainFrame.ClipsDescendants = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Top bar for title and dragging
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 35)

    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 8)
    TopBarCorner.Parent = TopBar
    
    -- Fix bottom corners of topbar to merge with main frame
    local TopBarFix = Instance.new("Frame")
    TopBarFix.Name = "TopBarFix"
    TopBarFix.Parent = TopBar
    TopBarFix.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBarFix.BorderSizePixel = 0
    TopBarFix.Position = UDim2.new(0, 0, 1, -8)
    TopBarFix.Size = UDim2.new(1, 0, 0, 8)

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(1, -15, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = WindowName
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TopBar
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(1, -35, 0, 0)
    CloseButton.Size = UDim2.new(0, 35, 1, 0)
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseButton.TextSize = 14

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = TopBar
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Position = UDim2.new(1, -70, 0, 0)
    MinimizeButton.Size = UDim2.new(0, 35, 1, 0)
    MinimizeButton.Font = Enum.Font.Gotham
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinimizeButton.TextSize = 18

    -- Mobile Toggle Button
    local MobileToggle = Instance.new("TextButton")
    MobileToggle.Name = "MobileToggle"
    MobileToggle.Parent = screenGui
    MobileToggle.BackgroundColor3 = ThemeColor
    MobileToggle.AnchorPoint = Vector2.new(0.5, 0)
    MobileToggle.Position = UDim2.new(0.5, 0, 0, -50)
    MobileToggle.Size = UDim2.new(1, 0, 0, 16)
    MobileToggle.Font = Enum.Font.GothamBold
    MobileToggle.Text = WindowName:sub(1,1)
    MobileToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    MobileToggle.TextSize = 24
    MobileToggle.Visible = false
    MobileToggle.ClipsDescendants = true

    local MobileToggleCorner = Instance.new("UICorner")
    MobileToggleCorner.CornerRadius = UDim.new(1, 0)
    MobileToggleCorner.Parent = MobileToggle
    
    MakeDraggable(MobileToggle, MobileToggle)

    local IsMinimized = false

    local function ToggleUI()
        IsMinimized = not IsMinimized
        if IsMinimized then
            -- Animate scale out
            TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            task.wait(0.2)
            MainFrame.Visible = false
            MobileToggle.Visible = true
            TweenService:Create(MobileToggle, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50)}):Play()
        else
            MobileToggle.Visible = false
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = WindowSize}):Play()
        end
    end

    MinimizeButton.MouseButton1Click:Connect(ToggleUI)
    MobileToggle.MouseButton1Click:Connect(ToggleUI)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == ToggleKey then
            ToggleUI()
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        local shrinkTween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
        shrinkTween:Play()
        shrinkTween.Completed:Wait()
        screenGui:Destroy()
    end)

    MakeDraggable(TopBar, MainFrame)

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainFrame
    TabContainer.Active = true
    TabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0, 35)
    TabContainer.Size = UDim2.new(0, 130, 1, -35)
    TabContainer.ScrollBarThickness = 0
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabContainer
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)

    local TabPadding = Instance.new("UIPadding")
    TabPadding.Parent = TabContainer
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Position = UDim2.new(0, 130, 0, 35)
    ContentContainer.Size = UDim2.new(1, -130, 1, -35)

    -- Window Object
    local Window = {
        Tabs = {},
        ActiveTab = nil
    }

    function Window:ChangeToggleKey(newKey)
        ToggleKey = newKey
    end

    function Window:CreateTab(tabName)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TabButton_" .. tabName
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextSize = 13
        TabButton.AutoButtonColor = false

        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 6)
        TabButtonCorner.Parent = TabButton

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = "TabContent_" .. tabName
        TabContent.Parent = ContentContainer
        TabContent.Active = true
        TabContent.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = ThemeColor
        TabContent.Visible = false

        local ContentListLayout = Instance.new("UIListLayout")
        ContentListLayout.Parent = TabContent
        ContentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentListLayout.Padding = UDim.new(0, 8)

        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.Parent = TabContent
        ContentPadding.PaddingTop = UDim.new(0, 10)
        ContentPadding.PaddingLeft = UDim.new(0, 10)
        ContentPadding.PaddingRight = UDim.new(0, 10)
        ContentPadding.PaddingBottom = UDim.new(0, 10)

        TabButton.MouseButton1Click:Connect(function()
            if Window.ActiveTab then
                TweenService:Create(Window.ActiveTab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                Window.ActiveTab.Content.Visible = false
            end
            
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = ThemeColor, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TabContent.Visible = true
            Window.ActiveTab = {Button = TabButton, Content = TabContent}
        end)

        if not Window.ActiveTab then
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabButton.BackgroundColor3 = ThemeColor
            TabContent.Visible = true
            Window.ActiveTab = {Button = TabButton, Content = TabContent}
        end
        
        ContentListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentListLayout.AbsoluteContentSize.Y + 20)
        end)

        local Tab = {}

        -- BUTTON
        function Tab:CreateButton(options)
            options = options or {}
            local btnName = options.Name or "Button"
            local btnCallback = options.Callback or function() end

            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = "ButtonFrame"
            ButtonFrame.Parent = TabContent
            ButtonFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.Size = UDim2.new(1, 0, 0, 35)

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = ButtonFrame

            local ButtonBtn = Instance.new("TextButton")
            ButtonBtn.Name = "ButtonBtn"
            ButtonBtn.Parent = ButtonFrame
            ButtonBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            ButtonBtn.BackgroundTransparency = 1
            ButtonBtn.Size = UDim2.new(1, 0, 1, 0)
            ButtonBtn.Font = Enum.Font.Gotham
            ButtonBtn.Text = btnName
            ButtonBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonBtn.TextSize = 14

            ButtonBtn.MouseEnter:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
            end)

            ButtonBtn.MouseLeave:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
            end)

            ButtonBtn.MouseButton1Click:Connect(function()
                local clickTween = TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = ThemeColor})
                clickTween:Play()
                clickTween.Completed:Wait()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
                
                pcall(btnCallback)
            end)
        end

        -- TOGGLE
        function Tab:CreateToggle(options)
            options = options or {}
            local tglName = options.Name or "Toggle"
            local tglDefault = options.Default or false
            local tglCallback = options.Callback or function() end

            local ToggleState = tglDefault

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = "ToggleFrame"
            ToggleFrame.Parent = TabContent
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Size = UDim2.new(1, 0, 0, 35)

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "ToggleLabel"
            ToggleLabel.Parent = ToggleFrame
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.Text = tglName
            ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleLabel.TextSize = 14
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

            local ToggleBox = Instance.new("Frame")
            ToggleBox.Name = "ToggleBox"
            ToggleBox.Parent = ToggleFrame
            ToggleBox.BackgroundColor3 = ToggleState and ThemeColor or Color3.fromRGB(25, 25, 25)
            ToggleBox.Position = UDim2.new(1, -45, 0.5, -10)
            ToggleBox.Size = UDim2.new(0, 35, 0, 20)

            local ToggleBoxCorner = Instance.new("UICorner")
            ToggleBoxCorner.CornerRadius = UDim.new(1, 0)
            ToggleBoxCorner.Parent = ToggleBox

            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Name = "ToggleCircle"
            ToggleCircle.Parent = ToggleBox
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleCircle.Position = ToggleState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            ToggleCircle.Size = UDim2.new(0, 16, 0, 16)

            local ToggleCircleCorner = Instance.new("UICorner")
            ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
            ToggleCircleCorner.Parent = ToggleCircle

            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Name = "ToggleBtn"
            ToggleBtn.Parent = ToggleFrame
            ToggleBtn.BackgroundTransparency = 1
            ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
            ToggleBtn.Text = ""

            ToggleBtn.MouseButton1Click:Connect(function()
                ToggleState = not ToggleState
                if ToggleState then
                    TweenService:Create(ToggleBox, TweenInfo.new(0.2), {BackgroundColor3 = ThemeColor}):Play()
                    TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
                else
                    TweenService:Create(ToggleBox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
                    TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                end
                pcall(tglCallback, ToggleState)
            end)
            
            -- Init callback on spawn to trigger any default states
            task.spawn(function()
                pcall(tglCallback, ToggleState)
            end)
        end

        -- SLIDER
        function Tab:CreateSlider(options)
            options = options or {}
            local sldrName = options.Name or "Slider"
            local sldrMin = options.Min or 0
            local sldrMax = options.Max or 100
            local sldrDefault = options.Default or sldrMin
            local sldrCallback = options.Callback or function() end

            local SliderValue = sldrDefault

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = "SliderFrame"
            SliderFrame.Parent = TabContent
            SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)

            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame

            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "SliderLabel"
            SliderLabel.Parent = SliderFrame
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Position = UDim2.new(0, 10, 0, 0)
            SliderLabel.Size = UDim2.new(1, -20, 0, 25)
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.Text = sldrName
            SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            SliderLabel.TextSize = 14
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Name = "ValueLabel"
            ValueLabel.Parent = SliderFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Position = UDim2.new(0, 10, 0, 0)
            ValueLabel.Size = UDim2.new(1, -20, 0, 25)
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.Text = tostring(sldrDefault)
            ValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            ValueLabel.TextSize = 14
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

            local SliderBG = Instance.new("Frame")
            SliderBG.Name = "SliderBG"
            SliderBG.Parent = SliderFrame
            SliderBG.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            SliderBG.Position = UDim2.new(0, 10, 0, 30)
            SliderBG.Size = UDim2.new(1, -20, 0, 6)

            local SliderBGCorner = Instance.new("UICorner")
            SliderBGCorner.CornerRadius = UDim.new(1, 0)
            SliderBGCorner.Parent = SliderBG

            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "SliderFill"
            SliderFill.Parent = SliderBG
            SliderFill.BackgroundColor3 = ThemeColor
            SliderFill.Size = UDim2.new(math.clamp((sldrDefault - sldrMin) / (sldrMax - sldrMin), 0, 1), 0, 1, 0)

            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(1, 0)
            SliderFillCorner.Parent = SliderFill

            local SliderBtn = Instance.new("TextButton")
            SliderBtn.Name = "SliderBtn"
            SliderBtn.Parent = SliderFrame
            SliderBtn.BackgroundTransparency = 1
            SliderBtn.Position = UDim2.new(0, 10, 0, 20)
            SliderBtn.Size = UDim2.new(1, -20, 0, 25)
            SliderBtn.Text = ""

            local Dragging = false

            local function UpdateSlider(input)
                local percentage = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                local value = math.floor(sldrMin + ((sldrMax - sldrMin) * percentage))
                SliderValue = value
                
                TweenService:Create(SliderFill, TweenInfo.new(0.05), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
                ValueLabel.Text = tostring(value)
                pcall(sldrCallback, value)
            end

            SliderBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    UpdateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
            
            -- Init callback
            task.spawn(function()
                pcall(sldrCallback, SliderValue)
            end)
        end

        -- KEYBIND
        function Tab:CreateKeybind(options)
            options = options or {}
            local keyName = options.Name or "Keybind"
            local defaultKey = options.Default or Enum.KeyCode.RightControl
            local keyCallback = options.Callback or options.OnChanged or function() end
            local keyPressed = options.OnPressed or options.Pressed

            local currentKey = defaultKey
            local IsBinding = false

            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Name = "KeybindFrame"
            KeybindFrame.Parent = TabContent
            KeybindFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            KeybindFrame.BorderSizePixel = 0
            KeybindFrame.Size = UDim2.new(1, 0, 0, 35)

            local KeybindCorner = Instance.new("UICorner")
            KeybindCorner.CornerRadius = UDim.new(0, 6)
            KeybindCorner.Parent = KeybindFrame

            local KeybindLabel = Instance.new("TextLabel")
            KeybindLabel.Name = "KeybindLabel"
            KeybindLabel.Parent = KeybindFrame
            KeybindLabel.BackgroundTransparency = 1
            KeybindLabel.Position = UDim2.new(0, 10, 0, 0)
            KeybindLabel.Size = UDim2.new(1, -100, 1, 0)
            KeybindLabel.Font = Enum.Font.Gotham
            KeybindLabel.Text = keyName
            KeybindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            KeybindLabel.TextSize = 14
            KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left

            local KeybindBtn = Instance.new("TextButton")
            KeybindBtn.Name = "KeybindBtn"
            KeybindBtn.Parent = KeybindFrame
            KeybindBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            KeybindBtn.Position = UDim2.new(1, -80, 0.5, -10)
            KeybindBtn.Size = UDim2.new(0, 70, 0, 20)
            KeybindBtn.Font = Enum.Font.Gotham
            KeybindBtn.Text = currentKey.Name
            KeybindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            KeybindBtn.TextSize = 12

            local KeybindBtnCorner = Instance.new("UICorner")
            KeybindBtnCorner.CornerRadius = UDim.new(0, 4)
            KeybindBtnCorner.Parent = KeybindBtn

            KeybindBtn.MouseButton1Click:Connect(function()
                IsBinding = true
                KeybindBtn.Text = "..."
                KeybindBtn.TextColor3 = ThemeColor
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if IsBinding then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        KeybindBtn.Text = currentKey.Name
                        KeybindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                        IsBinding = false
                        pcall(keyCallback, currentKey)
                    end
                else
                    if not gameProcessed and input.KeyCode == currentKey then
                        if keyPressed then
                            pcall(keyPressed, currentKey)
                        end
                    end
                end
            end)
        end

        -- DROPDOWN
        function Tab:CreateDropdown(options)
            options = options or {}
            local dropName = options.Name or "Dropdown"
            local dropOptionsRaw = options.Options
            local dropOptionsFunc = (type(dropOptionsRaw) == "function" and dropOptionsRaw)
                or (type(options.Function) == "function" and options.Function)
                or (type(options.GetOptions) == "function" and options.GetOptions)
                or (type(options.RefreshFunc) == "function" and options.RefreshFunc)

            local dropOptions = {}
            if dropOptionsFunc then
                local success, res = pcall(dropOptionsFunc)
                if success and type(res) == "table" then
                    dropOptions = res
                end
            elseif type(dropOptionsRaw) == "table" then
                dropOptions = dropOptionsRaw
            end

            local dropDefault = options.Default or ""
            local dropCallback = options.Callback or function() end
            local autoRefresh = options.AutoRefresh

            local DropdownOpen = false
            local CurrentValue = dropDefault

            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = "DropdownFrame"
            DropdownFrame.Parent = TabContent
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
            DropdownFrame.ClipsDescendants = true

            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = DropdownFrame

            local DropdownBtn = Instance.new("TextButton")
            DropdownBtn.Name = "DropdownBtn"
            DropdownBtn.Parent = DropdownFrame
            DropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            DropdownBtn.BackgroundTransparency = 1
            DropdownBtn.Size = UDim2.new(1, 0, 0, 35)
            DropdownBtn.Font = Enum.Font.Gotham
            DropdownBtn.Text = ""

            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Name = "DropdownLabel"
            DropdownLabel.Parent = DropdownBtn
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            DropdownLabel.Size = UDim2.new(1, -60, 1, 0)
            DropdownLabel.Font = Enum.Font.Gotham
            DropdownLabel.Text = dropName
            DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            DropdownLabel.TextSize = 14
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left

            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Name = "SelectedLabel"
            SelectedLabel.Parent = DropdownBtn
            SelectedLabel.BackgroundTransparency = 1
            SelectedLabel.Position = UDim2.new(1, -110, 0, 0)
            SelectedLabel.Size = UDim2.new(0, 80, 1, 0)
            SelectedLabel.Font = Enum.Font.Gotham
            SelectedLabel.Text = typeof(CurrentValue) == "Instance" and CurrentValue.Name or tostring(CurrentValue)
            SelectedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            SelectedLabel.TextSize = 12
            SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right

            local Icon = Instance.new("TextLabel")
            Icon.Name = "Icon"
            Icon.Parent = DropdownBtn
            Icon.BackgroundTransparency = 1
            Icon.Position = UDim2.new(1, -25, 0, 0)
            Icon.Size = UDim2.new(0, 20, 1, 0)
            Icon.Font = Enum.Font.GothamBold
            Icon.Text = "+"
            Icon.TextColor3 = Color3.fromRGB(200, 200, 200)
            Icon.TextSize = 16

            local OptionContainer = Instance.new("ScrollingFrame")
            OptionContainer.Name = "OptionContainer"
            OptionContainer.Parent = DropdownFrame
            OptionContainer.Active = true
            OptionContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            OptionContainer.BorderSizePixel = 0
            OptionContainer.Position = UDim2.new(0, 5, 0, 35)
            OptionContainer.Size = UDim2.new(1, -10, 1, -40)
            OptionContainer.ScrollBarThickness = 2
            OptionContainer.ScrollBarImageColor3 = ThemeColor

            local OptionCorner = Instance.new("UICorner")
            OptionCorner.CornerRadius = UDim.new(0, 4)
            OptionCorner.Parent = OptionContainer

            local OptionListLayout = Instance.new("UIListLayout")
            OptionListLayout.Parent = OptionContainer
            OptionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionListLayout.Padding = UDim.new(0, 2)

            local OptionPadding = Instance.new("UIPadding")
            OptionPadding.Parent = OptionContainer
            OptionPadding.PaddingTop = UDim.new(0, 2)
            OptionPadding.PaddingBottom = UDim.new(0, 2)

            local function RefreshDropdownOptions()
                for _, child in ipairs(OptionContainer:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end

                for i, option in ipairs(dropOptions) do
                    local optText = typeof(option) == "Instance" and option.Name or tostring(option)
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Name = "OptBtn_" .. optText
                    OptBtn.Parent = OptionContainer
                    OptBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    OptBtn.BorderSizePixel = 0
                    OptBtn.Size = UDim2.new(1, 0, 0, 25)
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.Text = optText
                    OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    OptBtn.TextSize = 12

                    local OptCorner = Instance.new("UICorner")
                    OptCorner.CornerRadius = UDim.new(0, 4)
                    OptCorner.Parent = OptBtn

                    OptBtn.MouseEnter:Connect(function()
                        TweenService:Create(OptBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        TweenService:Create(OptBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
                    end)

                    OptBtn.MouseButton1Click:Connect(function()
                        CurrentValue = option
                        SelectedLabel.Text = optText
                        DropdownOpen = false
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
                        Icon.Text = "+"
                        pcall(dropCallback, CurrentValue)
                    end)
                end
                
                local totalSize = (#dropOptions * 27) + 4
                OptionContainer.CanvasSize = UDim2.new(0, 0, 0, totalSize)
                
                return math.clamp(totalSize + 40, 75, 150)
            end

            local maxFrameSize = RefreshDropdownOptions()

            DropdownBtn.MouseButton1Click:Connect(function()
                DropdownOpen = not DropdownOpen
                if DropdownOpen then
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, maxFrameSize)}):Play()
                    Icon.Text = "-"
                else
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
                    Icon.Text = "+"
                end
            end)
            
            -- Init callback
            if dropDefault ~= "" then
                task.spawn(function()
                    pcall(dropCallback, CurrentValue)
                end)
            end

            local DropdownController = {}

            function DropdownController:Refresh(newList, keepCurrent)
                dropOptions = newList or {}
                maxFrameSize = RefreshDropdownOptions()
                
                local isFound = false
                for _, opt in ipairs(dropOptions) do
                    if opt == CurrentValue then
                        isFound = true
                        break
                    end
                end

                if keepCurrent == false or not isFound then
                    CurrentValue = dropOptions[1] or ""
                    SelectedLabel.Text = typeof(CurrentValue) == "Instance" and CurrentValue.Name or tostring(CurrentValue)
                end

                if DropdownOpen then
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, maxFrameSize)}):Play()
                end
            end

            function DropdownController:Set(value)
                CurrentValue = value
                SelectedLabel.Text = typeof(value) == "Instance" and value.Name or tostring(value)
                pcall(dropCallback, CurrentValue)
            end

            function DropdownController:Get()
                return CurrentValue
            end

            if autoRefresh and dropOptionsFunc then
                local function AreTablesEqual(t1, t2)
                    if #t1 ~= #t2 then return false end
                    for i = 1, #t1 do
                        if t1[i] ~= t2[i] then return false end
                    end
                    return true
                end

                local isBusy = false
                local function TriggerRefresh()
                    if isBusy then return end
                    isBusy = true
                    task.delay(0.05, function()
                        local success, updated = pcall(dropOptionsFunc)
                        if success and type(updated) == "table" then
                            if not AreTablesEqual(dropOptions, updated) then
                                DropdownController:Refresh(updated, true)
                            end
                        end
                        isBusy = false
                    end)
                end

                -- Inventory reactive hook
                local function ConnectInventory(character)
                    local backpack = Players.LocalPlayer:FindFirstChild("Backpack") or Players.LocalPlayer:WaitForChild("Backpack", 3)
                    if backpack then
                        backpack.ChildAdded:Connect(function(c) if c:IsA("Tool") then TriggerRefresh() end end)
                        backpack.ChildRemoved:Connect(function(c) if c:IsA("Tool") then TriggerRefresh() end end)
                    end
                    if character then
                        character.ChildAdded:Connect(function(c) if c:IsA("Tool") then TriggerRefresh() end end)
                        character.ChildRemoved:Connect(function(c) if c:IsA("Tool") then TriggerRefresh() end end)
                    end
                end

                if Players.LocalPlayer.Character then
                    ConnectInventory(Players.LocalPlayer.Character)
                end
                Players.LocalPlayer.CharacterAdded:Connect(ConnectInventory)

                -- Polling loop as backup or for non-inventory dynamic lists
                local interval = (type(autoRefresh) == "number" and autoRefresh) or 1
                task.spawn(function()
                    while DropdownFrame and DropdownFrame.Parent do
                        task.wait(interval)
                        TriggerRefresh()
                    end
                end)
            end

            return DropdownController
        end

        return Tab
    end

    return Window
end

return Gemini
