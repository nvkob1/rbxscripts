local httpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local SaveManager = {} do
   SaveManager.Folder = "FluentSettings_" .. Players.LocalPlayer.UserId
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
   		writefile(self.Folder .. "/autosave.json", encoded)
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

   	writefile(self.Folder .. "/settings.json", encoded)
   	return true
   end

   function SaveManager:LoadSettings()
   	local autoFile = self.Folder .. "/autosave.json"
   	local manualFile = self.Folder .. "/settings.json"
   	
   	local file = isfile(manualFile) and manualFile or (isfile(autoFile) and autoFile or nil)
   	if not file then return false, "no save file found" end

   	local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
   	if not success then return false, "decode error" end

   	for _, option in next, decoded.objects do
   		if self.Parser[option.type] then
   			task.spawn(function() self.Parser[option.type].Load(option.idx, option) end)
   		end
   	end

   	return true
   end

   function SaveManager:StartAutoSave()
   	task.spawn(function()
   		while self.AutoSaveEnabled do
   			task.wait(5)
   			self:AutoSave()
   		end
   	end)
   end

   function SaveManager:BuildFolderTree()
   	if not isfolder(self.Folder) then
   		makefolder(self.Folder)
   	end
   end

   function SaveManager:SetLibrary(library)
   	self.Library = library
   	self.Options = library.Options
   	
   	for _, option in pairs(library.Options) do
   		if option.OnChanged then
   			local originalCallback = option.OnChanged
   			option.OnChanged = function(...)
   				if originalCallback then originalCallback(...) end
   				self:AutoSave()
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
   			if value then
   				self:StartAutoSave()
   			end
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
   SaveManager:StartAutoSave()
end

return SaveManager
