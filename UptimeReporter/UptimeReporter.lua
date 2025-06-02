-- Webhook Configuration
if not getgenv().WEBHOOK_URL then
  warn("No webhook URL configured. Set getgenv().WEBHOOK_URL before running this script.")
  return
end

local webhook = getgenv().WEBHOOK_URL
local interval = getgenv().WEBHOOK_INTERVAL or 600
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")
local TitleLabel = Instance.new("TextLabel")
local TimeLabel = Instance.new("TextLabel")
local IntervalLabel = Instance.new("TextLabel")
local SendButton = Instance.new("TextButton")
local ToggleButton = Instance.new("TextButton")
local ButtonUICorner = Instance.new("UICorner")
local ToggleUICorner = Instance.new("UICorner")
local SendUICorner = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")

ScreenGui.Name = "UptimeGUI"
ScreenGui.Parent = CoreGui

Frame.Size = UDim2.new(0, 300, 0, 190)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = Frame

UIStroke.Color = Color3.fromRGB(60, 60, 80)
UIStroke.Thickness = 1
UIStroke.Parent = Frame

UIGradient.Color = ColorSequence.new{
  ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
}
UIGradient.Rotation = 135
UIGradient.Parent = Frame

TitleLabel.Size = UDim2.new(0.75, 0, 0, 35)
TitleLabel.Position = UDim2.new(0, 15, 0, 10)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⏱️ Server Uptime Monitor"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Frame

ToggleButton.Size = UDim2.new(0, 35, 0, 25)
ToggleButton.Position = UDim2.new(1, -50, 0, 15)
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
ToggleButton.Text = "−"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 18
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = Frame

ToggleUICorner.CornerRadius = UDim.new(0, 8)
ToggleUICorner.Parent = ToggleButton

TimeLabel.Size = UDim2.new(1, -30, 0, 30)
TimeLabel.Position = UDim2.new(0, 15, 0, 50)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "🕐 Uptime: 0 Second(s)"
TimeLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
TimeLabel.TextSize = 14
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.TextWrapped = true
TimeLabel.Parent = Frame

IntervalLabel.Size = UDim2.new(1, -30, 0, 25)
IntervalLabel.Position = UDim2.new(0, 15, 0, 85)
IntervalLabel.BackgroundTransparency = 1
IntervalLabel.Text = "📤 Auto-send: " .. math.floor(interval/60) .. " min"
IntervalLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
IntervalLabel.TextSize = 13
IntervalLabel.Font = Enum.Font.Gotham
IntervalLabel.Parent = Frame

SendButton.Size = UDim2.new(1, -30, 0, 40)
SendButton.Position = UDim2.new(0, 15, 0, 120)
SendButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
SendButton.Text = "📤 Send Report"
SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SendButton.TextSize = 15
SendButton.Font = Enum.Font.GothamBold
SendButton.BorderSizePixel = 0
SendButton.Parent = Frame

SendUICorner.CornerRadius = UDim.new(0, 10)
SendUICorner.Parent = SendButton

-- Toggle functionality with animations
local isVisible = true
ToggleButton.MouseButton1Click:Connect(function()
  isVisible = not isVisible
  local targetSize, targetText, targetColor
  
  if isVisible then
      targetSize = UDim2.new(0, 300, 0, 190)
      targetText = "−"
      targetColor = Color3.fromRGB(70, 70, 90)
      TimeLabel.Visible = true
      IntervalLabel.Visible = true
      SendButton.Visible = true
  else
      targetSize = UDim2.new(0, 300, 0, 55)
      targetText = "+"
      targetColor = Color3.fromRGB(52, 152, 219)
      TimeLabel.Visible = false
      IntervalLabel.Visible = false
      SendButton.Visible = false
  end
  
  ToggleButton.Text = targetText
  ToggleButton.BackgroundColor3 = targetColor
  
  local tween = TweenService:Create(Frame, 
      TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
      {Size = targetSize}
  )
  tween:Play()
end)

-- Hover effects
SendButton.MouseEnter:Connect(function()
  local tween = TweenService:Create(SendButton,
      TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
      {BackgroundColor3 = Color3.fromRGB(70, 170, 240)}
  )
  tween:Play()
end)

SendButton.MouseLeave:Connect(function()
  if SendButton.Text == "📤 Send Report" then
      local tween = TweenService:Create(SendButton,
          TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
          {BackgroundColor3 = Color3.fromRGB(52, 152, 219)}
      )
      tween:Play()
  end
end)

ToggleButton.MouseEnter:Connect(function()
  local currentColor = ToggleButton.BackgroundColor3
  local targetColor = Color3.new(currentColor.R + 0.1, currentColor.G + 0.1, currentColor.B + 0.1)
  local tween = TweenService:Create(ToggleButton,
      TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
      {BackgroundColor3 = targetColor}
  )
  tween:Play()
end)

ToggleButton.MouseLeave:Connect(function()
  local targetColor = isVisible and Color3.fromRGB(70, 70, 90) or Color3.fromRGB(52, 152, 219)
  local tween = TweenService:Create(ToggleButton,
      TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
      {BackgroundColor3 = targetColor}
  )
  tween:Play()
end)

-- Drag functionality
local dragging = false
local dragStart = nil
local startPos = nil

local function updateInput(input)
  local delta = input.Position - dragStart
  Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Frame.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = true
      dragStart = input.Position
      startPos = Frame.Position
      
      input.Changed:Connect(function()
          if input.UserInputState == Enum.UserInputState.End then
              dragging = false
          end
      end)
  end
end)

Frame.InputChanged:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseMovement then
      if dragging then
          updateInput(input)
      end
  end
end)

UserInputService.InputChanged:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseMovement then
      if dragging then
          updateInput(input)
      end
  end
end)

local function getUptimeString()
  local totalSeconds = math.floor(workspace.DistributedGameTime)
  local minutes = math.floor(totalSeconds / 60)
  local hours = math.floor(minutes / 60)
  local seconds = totalSeconds % 60
  minutes = minutes % 60
  
  if hours > 0 then
      return string.format("%d Hour(s), %d Minute(s), %d Second(s)", hours, minutes, seconds)
  elseif minutes > 0 then
      return string.format("%d Minute(s), %d Second(s)", minutes, seconds)
  else
      return string.format("%d Second(s)", seconds)
  end
end

local function sendUptime()
  local uptimeString = getUptimeString()
  local mapName = "Unknown"
  local username = Players.LocalPlayer.Name
  
  pcall(function()
      mapName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
  end)
  
  local data = {
      embeds = {{
          title = "⏱️ Server Uptime Report",
          description = "**🕐 Current uptime:** " .. uptimeString .. "\n**🗺️ Map:** " .. mapName .. "\n**👤 Player:** " .. username,
          color = 3447003,
          timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
      }}
  }
  
  request({
      Url = webhook,
      Method = "POST",
      Headers = {
          ["Content-Type"] = "application/json"
      },
      Body = game:GetService("HttpService"):JSONEncode(data)
  })
  
  SendButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
  SendButton.Text = "✅ Sent!"
  task.wait(1.5)
  SendButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
  SendButton.Text = "📤 Send Report"
end

task.spawn(function()
  while true do
      TimeLabel.Text = "🕐 Uptime: " .. getUptimeString()
      task.wait(1)
  end
end)

SendButton.MouseButton1Click:Connect(sendUptime)
sendUptime()

task.spawn(function()
  while true do
      task.wait(interval)
      sendUptime()
  end
end)
