-- Enhanced Uptime Monitor with Executor Detection
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local webhook = getgenv().WEBHOOK_URL
local interval = getgenv().WEBHOOK_INTERVAL or 600
local startTime = tick()

-- Get executor name
local function getExecutorName()
    local success, result = pcall(function()
        local response = request({
            Url = "https://httpbin.org/user-agent",
            Method = "GET",
        })
        local data = HttpService:JSONDecode(response.Body)
        return data["user-agent"] or "Unknown"
    end)
    return success and result or "Unknown"
end

local executorName = getExecutorName()

-- Optimized webhook input GUI
local function createWebhookInputGUI()
    local InputGui = Instance.new("ScreenGui")
    local InputFrame = Instance.new("Frame")
    
    InputGui.Name = "WebhookInput"
    InputGui.Parent = CoreGui
    
    -- Main frame
    InputFrame.Size = UDim2.new(0, 420, 0, 300)
    InputFrame.Position = UDim2.new(0.5, -210, 0.5, -150)
    InputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = InputGui
    
    -- Frame styling
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = InputFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 70, 90)
    stroke.Thickness = 2
    stroke.Parent = InputFrame
    
    -- Title
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -40, 0, 40)
    titleText.Position = UDim2.new(0, 20, 0, 15)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🔧 Discord Webhook Setup"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 18
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = InputFrame
    
    -- Webhook section
    local webhookLabel = Instance.new("TextLabel")
    webhookLabel.Size = UDim2.new(1, -40, 0, 25)
    webhookLabel.Position = UDim2.new(0, 20, 0, 65)
    webhookLabel.BackgroundTransparency = 1
    webhookLabel.Text = "🔗 Webhook URL (Optional)"
    webhookLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    webhookLabel.TextSize = 14
    webhookLabel.Font = Enum.Font.GothamSemibold
    webhookLabel.TextXAlignment = Enum.TextXAlignment.Left
    webhookLabel.Parent = InputFrame
    
    local webhookBox = Instance.new("TextBox")
    webhookBox.Size = UDim2.new(1, -40, 0, 45)
    webhookBox.Position = UDim2.new(0, 20, 0, 95)
    webhookBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    webhookBox.BorderSizePixel = 0
    webhookBox.Text = ""
    webhookBox.PlaceholderText = "https://discord.com/api/webhooks/..."
    webhookBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    webhookBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    webhookBox.TextSize = 13
    webhookBox.Font = Enum.Font.Gotham
    webhookBox.TextWrapped = true
    webhookBox.Parent = InputFrame
    
    local webhookCorner = Instance.new("UICorner")
    webhookCorner.CornerRadius = UDim.new(0, 8)
    webhookCorner.Parent = webhookBox
    
    -- Interval section
    local intervalLabel = Instance.new("TextLabel")
    intervalLabel.Size = UDim2.new(1, -40, 0, 25)
    intervalLabel.Position = UDim2.new(0, 20, 0, 155)
    intervalLabel.BackgroundTransparency = 1
    intervalLabel.Text = "⏰ Send Interval (Minutes)"
    intervalLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    intervalLabel.TextSize = 14
    intervalLabel.Font = Enum.Font.GothamSemibold
    intervalLabel.TextXAlignment = Enum.TextXAlignment.Left
    intervalLabel.Parent = InputFrame
    
    local intervalBox = Instance.new("TextBox")
    intervalBox.Size = UDim2.new(1, -40, 0, 45)
    intervalBox.Position = UDim2.new(0, 20, 0, 185)
    intervalBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    intervalBox.BorderSizePixel = 0
    intervalBox.Text = tostring(math.floor(interval/60))
    intervalBox.PlaceholderText = "10"
    intervalBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    intervalBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    intervalBox.TextSize = 14
    intervalBox.Font = Enum.Font.Gotham
    intervalBox.Parent = InputFrame
    
    local intervalCorner = Instance.new("UICorner")
    intervalCorner.CornerRadius = UDim.new(0, 8)
    intervalCorner.Parent = intervalBox
    
    -- Buttons
    local confirmButton = Instance.new("TextButton")
    confirmButton.Size = UDim2.new(0, 140, 0, 40)
    confirmButton.Position = UDim2.new(0, 20, 0, 245)
    confirmButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
    confirmButton.Text = "✅ Confirm"
    confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmButton.TextSize = 15
    confirmButton.Font = Enum.Font.GothamBold
    confirmButton.BorderSizePixel = 0
    confirmButton.Parent = InputFrame
    
    local confirmCorner = Instance.new("UICorner")
    confirmCorner.CornerRadius = UDim.new(0, 8)
    confirmCorner.Parent = confirmButton
    
    local skipButton = Instance.new("TextButton")
    skipButton.Size = UDim2.new(0, 140, 0, 40)
    skipButton.Position = UDim2.new(1, -160, 0, 245)
    skipButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    skipButton.Text = "⏭️ Skip"
    skipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    skipButton.TextSize = 15
    skipButton.Font = Enum.Font.GothamBold
    skipButton.BorderSizePixel = 0
    skipButton.Parent = InputFrame
    
    local skipCorner = Instance.new("UICorner")
    skipCorner.CornerRadius = UDim.new(0, 8)
    skipCorner.Parent = skipButton
    
    -- Validation functions
    local function validateWebhook(url)
        if url == "" then return true end
        return url:match("^https://discord%.com/api/webhooks/%d+/[%w%-_]+$") or url:match("^https://discordapp%.com/api/webhooks/%d+/[%w%-_]+$")
    end
    
    local function testWebhook(url)
        local success, result = pcall(function()
            return request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    embeds = {{
                        title = "🔧 Webhook Test",
                        description = "Webhook connection successful!",
                        color = 65280
                    }}
                })
            })
        end)
        return success and result and result.StatusCode and result.StatusCode >= 200 and result.StatusCode < 300
    end
    
    local function showStatus(message, color, isError)
        local statusLabel = InputFrame:FindFirstChild("StatusLabel")
        if statusLabel then statusLabel:Destroy() end
        
        statusLabel = Instance.new("TextLabel")
        statusLabel.Name = "StatusLabel"
        statusLabel.Size = UDim2.new(1, -40, 0, 20)
        statusLabel.Position = UDim2.new(0, 20, 0, 222)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = message
        statusLabel.TextColor3 = color
        statusLabel.TextSize = 12
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.Parent = InputFrame
        
        if not isError then
            task.wait(2)
            if statusLabel and statusLabel.Parent then
                statusLabel:Destroy()
            end
        end
    end
    
    local validating = false
    local finished = false
    
    confirmButton.MouseButton1Click:Connect(function()
        if validating then return end
        validating = true
        
        confirmButton.Text = "⏳ Validating..."
        confirmButton.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
        
        local inputText = webhookBox.Text:gsub("%s+", "")
        local intervalText = intervalBox.Text:gsub("%s+", "")
        
        -- Validate interval
        if intervalText ~= "" then
            local intervalMinutes = tonumber(intervalText)
            if not intervalMinutes or intervalMinutes < 1 or intervalMinutes > 1440 then
                showStatus("❌ Interval must be between 1-1440 minutes", Color3.fromRGB(231, 76, 60), true)
                confirmButton.Text = "✅ Confirm"
                confirmButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
                validating = false
                return
            end
        end
        
        -- Validate webhook if provided
        if inputText ~= "" then
            if not validateWebhook(inputText) then
                showStatus("❌ Invalid Discord webhook URL format", Color3.fromRGB(231, 76, 60), true)
                confirmButton.Text = "✅ Confirm"
                confirmButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
                validating = false
                return
            end
            
            showStatus("🔍 Testing webhook connection...", Color3.fromRGB(52, 152, 219))
            
            if not testWebhook(inputText) then
                showStatus("❌ Webhook test failed - Check URL or permissions", Color3.fromRGB(231, 76, 60), true)
                confirmButton.Text = "✅ Confirm"
                confirmButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
                validating = false
                return
            end
            
            showStatus("✅ Webhook validated successfully!", Color3.fromRGB(46, 204, 113))
            webhook = inputText
            getgenv().WEBHOOK_URL = webhook
        end
        
        -- Save interval
        if intervalText ~= "" then
            local intervalMinutes = tonumber(intervalText)
            interval = intervalMinutes * 60
            getgenv().WEBHOOK_INTERVAL = interval
        end
        
        confirmButton.Text = "✅ Saved!"
        confirmButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        task.wait(1)
        finished = true
        validating = false
    end)
    
    skipButton.MouseButton1Click:Connect(function()
        finished = true
    end)
    
    repeat RunService.Heartbeat:Wait() until finished
    InputGui:Destroy()
end

if not webhook or webhook == "" then
    createWebhookInputGUI()
end

-- Main GUI creation with better organization
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")

ScreenGui.Name = "UptimeGUI"
ScreenGui.Parent = CoreGui

Frame.Size = UDim2.new(0, 300, 0, 190)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true
Frame.Parent = ScreenGui

-- Add styling components
local styling = {
    {Instance.new("UICorner"), {CornerRadius = UDim.new(0, 15)}},
    {Instance.new("UIStroke"), {Color = Color3.fromRGB(60, 60, 80), Thickness = 1}},
    {Instance.new("UIGradient"), {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
        },
        Rotation = 135
    }}
}

for _, style in pairs(styling) do
    local component, props = style[1], style[2]
    for prop, value in pairs(props) do
        component[prop] = value
    end
    component.Parent = Frame
end

-- GUI elements with improved organization
local elements = {}
local elementData = {
    TitleLabel = {
        class = "TextLabel",
        Size = UDim2.new(0.75, 0, 0, 35),
        Position = UDim2.new(0, 15, 0, 10),
        BackgroundTransparency = 1,
        Text = "⏱️ Server Uptime Monitor",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    },
    ToggleButton = {
        class = "TextButton",
        Size = UDim2.new(0, 35, 0, 25),
        Position = UDim2.new(1, -50, 0, 15),
        BackgroundColor3 = Color3.fromRGB(70, 70, 90),
        Text = "−",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0
    },
    TimeLabel = {
        class = "TextLabel",
        Size = UDim2.new(1, -30, 0, 30),
        Position = UDim2.new(0, 15, 0, 50),
        BackgroundTransparency = 1,
        Text = "🕐 Uptime: 0 Second(s)",
        TextColor3 = Color3.fromRGB(200, 200, 220),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextWrapped = true
    },
    IntervalLabel = {
        class = "TextLabel",
        Size = UDim2.new(1, -30, 0, 25),
        Position = UDim2.new(0, 15, 0, 85),
        BackgroundTransparency = 1,
        Text = webhook and webhook ~= "" and ("📤 Auto-send: " .. math.floor(interval/60) .. " min") or "⚠️ No webhook configured",
        TextColor3 = Color3.fromRGB(150, 150, 170),
        TextSize = 13,
        Font = Enum.Font.Gotham
    },
    SendButton = {
        class = "TextButton",
        Size = UDim2.new(1, -30, 0, 40),
        Position = UDim2.new(0, 15, 0, 120),
        BackgroundColor3 = webhook and webhook ~= "" and Color3.fromRGB(52, 152, 219) or Color3.fromRGB(100, 100, 100),
        Text = webhook and webhook ~= "" and "📤 Send Report" or "❌ No Webhook",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0
    }
}

-- Create elements
for name, data in pairs(elementData) do
    local element = Instance.new(data.class)
    data.class = nil
    for prop, value in pairs(data) do
        element[prop] = value
    end
    element.Parent = Frame
    elements[name] = element
    
    if name:match("Button") then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, name == "ToggleButton" and 8 or 10)
        corner.Parent = element
    end
end

-- Optimized toggle functionality
local isVisible = true
elements.ToggleButton.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    
    local targetSize = isVisible and UDim2.new(0, 300, 0, 190) or UDim2.new(0, 300, 0, 55)
    elements.ToggleButton.Text = isVisible and "−" or "+"
    elements.ToggleButton.BackgroundColor3 = isVisible and Color3.fromRGB(70, 70, 90) or Color3.fromRGB(52, 152, 219)
    
    for _, elementName in pairs({"TimeLabel", "IntervalLabel", "SendButton"}) do
        elements[elementName].Visible = isVisible
    end
    
    TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- Enhanced drag system
local dragConnection
local function setupDragging()
    local dragging = false
    local dragStart, startPos
    
    local function getInputPos(input)
        return input.UserInputType == Enum.UserInputType.Touch and input.Position or input.Position
    end
    
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = getInputPos(input)
            startPos = Frame.Position
        end
    end)
    
    dragConnection = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = getInputPos(input) - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

setupDragging()

-- Optimized uptime calculation
local function getUptimeString()
    local totalSeconds = math.floor(tick() - startTime)
    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60
    
    if hours > 0 then
        return string.format("%d Hour(s), %d Minute(s), %d Second(s)", hours, minutes, seconds)
    elseif minutes > 0 then
        return string.format("%d Minute(s), %d Second(s)", minutes, seconds)
    else
        return string.format("%d Second(s)", seconds)
    end
end

-- Improved webhook sending with executor info
local function sendUptime()
    if not webhook or webhook == "" then return end
    
    local success, result = pcall(function()
        local uptimeString = getUptimeString()
        local mapName = MarketplaceService:GetProductInfo(game.PlaceId).Name or "Unknown"
        local username = Players.LocalPlayer.Name
        
        local data = {
            embeds = {{
                title = "⏱️ Server Uptime Report",
                description = string.format("**🕐 Current uptime:** %s\n**🗺️ Map:** %s\n**👤 Player:** %s\n**⚡ Executor:** %s", uptimeString, mapName, username, executorName),
                color = 3447003,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        
        request({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
        
        elements.SendButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        elements.SendButton.Text = "✅ Sent!"
        task.wait(1.5)
        elements.SendButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
        elements.SendButton.Text = "📤 Send Report"
    end)
    
    if not success then
        elements.SendButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        elements.SendButton.Text = "❌ Failed"
        task.wait(1.5)
        elements.SendButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
        elements.SendButton.Text = "📤 Send Report"
    end
end

-- Update loop with better performance
task.spawn(function()
    while elements.TimeLabel and elements.TimeLabel.Parent do
        elements.TimeLabel.Text = "🕐 Uptime: " .. getUptimeString()
        task.wait(1)
    end
end)

-- Setup webhook functionality
if webhook and webhook ~= "" then
    elements.SendButton.MouseButton1Click:Connect(sendUptime)
    sendUptime()
    
    task.spawn(function()
        while true do
            task.wait(interval)
            if elements.SendButton and elements.SendButton.Parent then
                sendUptime()
            else
                break
            end
        end
    end)
end

-- Cleanup on GUI destruction
ScreenGui.AncestryChanged:Connect(function()
    if not ScreenGui.Parent then
        if dragConnection then
            dragConnection:Disconnect()
        end
    end
end)
