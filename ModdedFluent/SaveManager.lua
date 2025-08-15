local httpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local SaveManager = {} do
   SaveManager.MainFolder = "FluentSettings"
   SaveManager.UserFile = Players.LocalPlayer.Name .. ".json"
   SaveManager.Ignore = {}
   SaveManager.AutoSaveEnabled = true
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

    -- Use this function to set a custom name for the main settings folder.
    function SaveManager:SetFolder(name)
        assert(type(name) == "string", "Folder name must be a string.")
        self.MainFolder = name
        self:BuildFolderTree() -- Re-check and create the folder if it doesn't exist.
    end

   function SaveManager:SetIgnoreIndexes(list)
   	for _, key in next, list do
   		self.Ignore[key] = true
   	end
   end

   function SaveManager:AutoSave()
   	if not self.AutoSaveEnabled then return end
   	
   	local data = {
   		objects = {}
   	}

   	for idx, option in next, SaveManager.Options do
   		if not self.Parser[option.Type] then continue end
   		if self.Ignore[idx] then continue end
   		table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
   	end	

   	local success, encoded = pcall(httpService.JSONEncode, httpService, data)
   	if success then
        -- Save to the user-specific file inside the main folder.
   		writefile(self.MainFolder .. "/" .. self.UserFile, encoded)
   	end
   end

   function SaveManager:ManualSave()
   	local data = {
   		objects = {}
   	}

   	for idx, option in next, SaveManager.Options do
   		if not self.Parser[option.Type] then continue end
   		if self.Ignore[idx] then continue end
   		table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
   	end	

   	local success, encoded = pcall(httpService.JSONEncode, httpService, data)
   	if not success then
   		return false, "failed to encode data"
   	end

    -- Save to the user-specific file inside the main folder.
   	writefile(self.MainFolder .. "/" .. self.UserFile, encoded)
   	return true
   end

   function SaveManager:LoadSettings()
   	local userFile = self.MainFolder .. "/" .. self.UserFile
   	
   	if not isfile(userFile) then return false, "no save file found" end

   	local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(userFile))
   	if not success then return false, "decode error" end

   	for _, option in next, decoded.objects do
   		if self.Parser[option.type] then
   			task.spawn(function() self.Parser[option.type].Load(option.idx, option) end)
   		end
   	end

   	return true
   end

   -- This function now only ensures the main settings folder exists.
   function SaveManager:BuildFolderTree()
   	if not isfolder(self.MainFolder) then
   		makefolder(self.MainFolder)
   	end
   end

    function SaveManager:SetLibrary(library)
        self.Library = library
        self.Options = library.Options
        
        for idx, option in pairs(self.Options) do
            if option.OnChanged and not self.Ignore[idx] then
                local originalOnChanged = option.OnChanged
                
                option.OnChanged = function(self, userCallback)
                    local wrappedCallback = function(...)
                        if userCallback then
                            pcall(userCallback, ...)
                        end
                        SaveManager:AutoSave()
                    end
                    
                    originalOnChanged(self, wrappedCallback)
                end
            end
        end
    end

   function SaveManager:BuildConfigSection(tab)
   	assert(self.Library, "Must set SaveManager.Library")

   	local section = tab:AddSection("Save Settings")

   	section:AddToggle("AutoSave", {
   		Title = "Auto Save", 
   		Default = true,
   		Callback = function(value)
   			self.AutoSaveEnabled = value
   		end
   	})

   	section:AddButton({
   		Title = "Manual Save",
   		Description = "Save current settings manually",
   		Callback = function()
   			local success, err = self:ManualSave()
   			if not success then
   				return self.Library:Notify({
   					Title = "Save Manager",
   					Content = "Failed to save: " .. err,
   					Duration = 5
   				})
   			end

   			self.Library:Notify({
   				Title = "Save Manager",
   				Content = "Settings saved successfully",
   				Duration = 3
   			})
   		end
   	})

   	section:AddButton({
   		Title = "Load Settings",
   		Description = "Load saved settings",
   		Callback = function()
   			local success, err = self:LoadSettings()
   			if not success then
   				return self.Library:Notify({
   					Title = "Save Manager",
   					Content = "Failed to load: " .. err,
   					Duration = 5
   				})
   			end

   			self.Library:Notify({
   				Title = "Save Manager",
   				Content = "Settings loaded successfully",
   				Duration = 3
   			})
   		end
   	})

   	SaveManager:SetIgnoreIndexes({"AutoSave"})
   end

   SaveManager:BuildFolderTree()
end

return SaveManager
