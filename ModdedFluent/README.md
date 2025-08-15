# Modded SaveManager for Fluent UI

## Features

- **Auto Save**: Automatically saves settings every 5 seconds
- **Manual Save**: Save settings on demand
- **Account-Specific**: Settings are saved per Roblox user ID
- **Simple Interface**: Easy-to-use toggle and buttons

## Usage

```lua
local SaveManager = loadstring(game:HttpGet("your-savemanager-url"))()

-- Set up with your Fluent window
SaveManager:SetLibrary(Fluent)

-- Add save section to your settings tab
SaveManager:BuildConfigSection(Tabs.Settings)

-- Load saved settings on startup
SaveManager:LoadSettings()
```
