local httpService = game:GetService("HttpService")

local SaveManager = {} do
	SaveManager.Folder = "FluentSettings" -- Default folder, can be changed with :SetFolder()
	SaveManager.Ignore = {}
    -- Creates a unique file name for each user to prevent settings from being overwritten.
    SaveManager.FileName = tostring(game.Players.LocalPlayer.UserId) .. "_Settings.json"

	-- The Parser defines HOW to save and load each type of UI element.
	-- This part remains unchanged as it's essential for handling different option types.
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = "Toggle", idx = idx, value = object.Value } 
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = "Slider", idx = idx, value = tostring(object.Value) }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = "Dropdown", idx = idx, value = object.Value, mutli = object.Multi }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Colorpicker = {
			Save = function(idx, object)
				return { type = "Colorpicker", idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		Keybind = {
			Save = function(idx, object)
				return { type = "Keybind", idx = idx, mode = object.Mode, key = object.Value }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.key, data.mode)
				end
			end,
		},
		Input = {
			Save = function(idx, object)
				return { type = "Input", idx = idx, text = object.Value }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] and type(data.text) == "string" then
					SaveManager.Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function SaveManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

    -- This is the new AutoSave function. It saves all settings to a single, user-specific file.
	function SaveManager:AutoSave()
		local fullPath = self.Folder .. "/" .. self.FileName
		local data = { objects = {} }

		for idx, option in next, SaveManager.Options do
			if not self.Parser[option.Type] or self.Ignore[idx] then continue end
			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end	

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			warn("Fluent AutoSave Error: failed to encode settings.")
			return
		end

		writefile(fullPath, encoded)
	end

    -- This is the new AutoLoad function. It loads settings from the user-specific file on start.
	function SaveManager:AutoLoad()
		local file = self.Folder .. "/" .. self.FileName
		if not isfile(file) then return end -- No save file found, do nothing.

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success or type(decoded) ~= "table" then 
            warn("Fluent AutoLoad Error: could not decode settings file.")
            return
        end

		for _, option in next, decoded.objects or {} do
			if self.Parser[option.type] and SaveManager.Options[option.idx] then
				-- Use a pcall to prevent one broken setting from stopping the entire load process.
                pcall(function() 
                    self.Parser[option.type].Load(option.idx, option) 
                end)
			end
		end
	end

	function SaveManager:BuildFolderTree()
		if not isfolder(self.Folder) then
			makefolder(self.Folder)
		end
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
        self.Options = library.Options
	end

    -- This is the core new function. It loads settings and then attaches the AutoSave function
    -- to every UI element's OnChanged event. This should be called after :SetLibrary().
    function SaveManager:Initialize()
        assert(self.Library, "Fluent SaveManager: You must call :SetLibrary(Fluent) before :Initialize()")

        -- 1. Load existing settings from the file at the start.
        self:AutoLoad()

        -- 2. Attach the AutoSave function to every option's OnChanged event.
        for idx, option in next, self.Options do
            if not self.Ignore[idx] and typeof(option.OnChanged) == "function" then
                -- This connects our AutoSave function to the OnChanged signal of the element.
                -- Now, any change to a toggle, slider, input, etc., will trigger a save.
                option:OnChanged(function()
                    SaveManager:AutoSave()
                end)
            end
        end

        if self.Library.Notify then
            self.Library:Notify({
                Title = "Save Manager",
                Content = "Settings will be saved automatically.",
                Duration = 5
            })
        end
    end

    -- The manual save UI has been removed as requested.
    -- This function now just adds a label to inform the user that auto-save is active.
	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, "Must set SaveManager.Library")

		local section = tab:AddSection("Configuration")
        section:AddLabel("Auto Save Active", {
            Description = "Your settings are saved automatically whenever you make a change."
        })
	end

	SaveManager:BuildFolderTree()
end

return SaveManager
