local httpService = game:GetService("HttpService")

local SaveManager = {} do
	SaveManager.Folder = "FluentSettings"
	SaveManager.Ignore = {}
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

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

    function SaveManager:BuildFolderTree()
        if not isfolder(self.Folder) then
            makefolder(self.Folder)
        end
	end

	function SaveManager:SaveSettings()
		local fullPath = self.Folder .. "/settings.json"
		local data = { objects = {} }

		for idx, option in next, SaveManager.Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end
			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end	

		pcall(writefile, fullPath, httpService:JSONEncode(data))
        return true
	end

	function SaveManager:LoadSettings()
		local file = self.Folder .. "/settings.json"
		if not isfile(file) then return false, "file not found" end

		local success, data = pcall(readfile, file)
        if not success or not data then return false, "failed to read file" end

		local decodedSuccess, decoded = pcall(httpService.JSONDecode, httpService, data)
		if not decodedSuccess then return false, "decode error" end

        if type(decoded) ~= "table" or not decoded.objects then return false, "invalid format" end

		for _, option in next, decoded.objects do
			if option and option.type and option.idx and self.Parser[option.type] and SaveManager.Options[option.idx] then
                pcall(self.Parser[option.type].Load, self, option.idx, option)
			end
		end

		return true
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"InterfaceTheme", "AcrylicToggle", "TransparentToggle", "MenuKeybind"
		})
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
        self.Options = library.Options

        -- Automatically load settings when the UI is initialized
        task.delay(1, function()
            if self.Library.Unloaded then return end
            if self:LoadSettings() then
                self.Library:Notify({
                    Title = "Save Manager",
                    Content = "Your settings have been loaded.",
                    Duration = 5
                })
            end
        end)
	end

	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, "Must set SaveManager.Library")

		local section = tab:AddSection("Configuration")
        
        section:AddParagraph({
            Title = "Auto Save",
            Content = "Your settings are saved automatically every second."
        })

        section:AddButton({
            Title = "Load Settings",
            Description = "Re-load your last saved settings.",
            Callback = function()
                local success, err = self:LoadSettings()
                if success then
                    self.Library:Notify({
                        Title = "Save Manager",
                        Content = "Settings loaded successfully.",
                        Duration = 3
                    })
                else
                    self.Library:Notify({
                        Title = "Save Manager",
                        Content = "Failed to load settings: " .. tostring(err),
                        Duration = 5
                    })
                end
            end
        })

        -- Start the auto-save loop
        task.spawn(function()
            while true do
                task.wait(1) -- Save every 1 second
                if self.Library.Unloaded then break end
                self:SaveSettings()
            end
        end)
	end

	SaveManager:BuildFolderTree()
end

return SaveManager
