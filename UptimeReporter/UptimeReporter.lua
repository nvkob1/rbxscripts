-- Webhook Configuration
if not getgenv().WEBHOOK_URL then
   warn("No webhook URL configured. Set getgenv().WEBHOOK_URL before running this script.")
   return
end

local webhook = getgenv().WEBHOOK_URL
local interval = getgenv().WEBHOOK_INTERVAL or 600 -- Default 10 minutes (600 seconds)
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")
local TitleLabel = Instance.new("TextLabel")
local TimeLabel = Instance.new("TextLabel")
local SendButton = Instance.new("TextButton")
local ButtonUICorner = Instance.new("UICorner")

ScreenGui.Name = "UptimeGUI"
ScreenGui.Parent = CoreGui

Frame.Size = UDim2.new(0, 280, 0, 150)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

UIGradient.Color = ColorSequence.new{
   ColorSequenceKeypoint.new(0, Color3.new(0.15, 0.15, 0.2)),
   ColorSequenceKeypoint.new(1, Color3.new(0.1, 0.1, 0.15))
}
UIGradient.Rotation = 45
UIGradient.Parent = Frame

TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Position = UDim2.new(0, 0, 0, 10)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⏱️ Server Uptime Monitor"
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = Frame

TimeLabel.Size = UDim2.new(1, -20, 0, 40)
TimeLabel.Position = UDim2.new(0, 10, 0, 50)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "🕐 Uptime: 0 Second(s)"
TimeLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
TimeLabel.TextSize = 14
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.TextWrapped = true
TimeLabel.Parent = Frame

SendButton.Size = UDim2.new(1, -20, 0, 35)
SendButton.Position = UDim2.new(0, 10, 0, 105)
SendButton.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
SendButton.Text = "📤 Send Report"
SendButton.TextColor3 = Color3.new(1, 1, 1)
SendButton.TextSize = 14
SendButton.Font = Enum.Font.GothamBold
SendButton.BorderSizePixel = 0
SendButton.Parent = Frame

ButtonUICorner.CornerRadius = UDim.new(0, 8)
ButtonUICorner.Parent = SendButton

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
   
   -- Try to get map name, fallback to "Unknown" if failed
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
   
   -- Button feedback
   SendButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
   SendButton.Text = "✅ Sent!"
   wait(1)
   SendButton.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
   SendButton.Text = "📤 Send Report"
end

-- Update time display
spawn(function()
   while true do
       TimeLabel.Text = "🕐 Uptime: " .. getUptimeString()
       wait(1)
   end
end)

-- Button click event
SendButton.MouseButton1Click:Connect(sendUptime)

-- Send initial notification
sendUptime()

-- Send uptime with custom interval
spawn(function()
   while true do
       wait(interval)
       sendUptime()
   end
end)
