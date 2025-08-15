# Modded SaveManager for Fluent UI

## Features

-   **Instant Auto-Save**: Automatically saves settings the moment a change is made.
-   **Manual Save & Load**: Save and load your configuration on demand.
-   **Username-Based Files**: Settings are saved to a file named after the player's username (e.g., `Player1.json`).
-   **Customizable Folder**: Set a custom main folder for all your settings files.
-   **Simple Integration**: Easily add the save/load UI to any Fluent tab.

## Usage

```lua
local SaveManager = loadstring(game:HttpGet("[https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/ModdedFluent/SaveManager.lua](https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/ModdedFluent/SaveManager.lua)"))()

-- Optional: Set a custom name for the main settings folder.
-- If you don't set this, it will default to "FluentSettings".
SaveManager:SetFolder("MyCustomConfigFolder")

-- Set up with your Fluent window
SaveManager:SetLibrary(Fluent)

-- Add save section to your settings tab
SaveManager:BuildConfigSection(Tabs.Settings)

-- Load saved settings on startup
SaveManager:LoadSettings()
```
