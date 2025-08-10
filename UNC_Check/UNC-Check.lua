-- UNC Compatibility Check
return function(config)
    local SCRIPT_NAME = config.scriptName or "Script"
    local MAIN_SCRIPT = config.mainScript
    
    local function checkUNCCompatibility()
        local requiredFunctions = config.requiredFunctions or {
            "loadstring",
            "game.HttpGet",
            "isfolder",
            "makefolder",
            "writefile",
            "isfile",
            "getgenv",
            "task.spawn",
            "task.wait"
        }
        
        local missingFunctions = {}
        local warnings = {}
        
        -- Check core functions
        for _, funcName in ipairs(requiredFunctions) do
            if funcName == "game.HttpGet" then
                if not game.HttpGet then
                    table.insert(missingFunctions, funcName)
                end
            elseif funcName:find("task%.") then
                local taskFunc = funcName:gsub("task%.", "")
                if not task or not task[taskFunc] then
                    table.insert(missingFunctions, funcName)
                end
            else
                if not _G[funcName] and not getfenv(0)[funcName] then
                    table.insert(missingFunctions, funcName)
                end
            end
        end
        
        -- Check optional functions
        local optionalFunctions = config.optionalFunctions or {
            "cloneref",
            "hookmetamethod",
            "getrawmetatable"
        }
        
        for _, funcName in ipairs(optionalFunctions) do
            if not _G[funcName] and not getfenv(0)[funcName] then
                table.insert(warnings, funcName)
            end
        end
        
        return #missingFunctions == 0, missingFunctions, warnings
    end

    -- Notification function using StarterGui
    local function sendNotification(title, text, duration)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = duration or 5
            })
        end)
    end

    -- Check compatibility
    local isCompatible, missingFuncs, optionalWarnings = checkUNCCompatibility()

    -- Always show compatibility status
    if isCompatible and #optionalWarnings == 0 then
        sendNotification("✅ Ready to Go!", "Executor fully supported", 3)
        print("✅ " .. SCRIPT_NAME .. ": Fully supported")
        
    elseif isCompatible and #optionalWarnings > 0 then
        sendNotification("⚠️ Almost There!", "Some features may be limited", 4)
        print("⚠️ " .. SCRIPT_NAME .. ": Partial support")
        
    else
        sendNotification("❌ Heads Up!", "May not work properly", 5)
        print("❌ " .. SCRIPT_NAME .. ": Limited support")
    end

    print("🔄 Loading " .. SCRIPT_NAME .. " (compatibility check completed)...")

    -- Run main script function if provided
    if MAIN_SCRIPT and type(MAIN_SCRIPT) == "function" then
        local success, error = pcall(MAIN_SCRIPT)
        
        if not success then
            local errorMsg = "❌ SCRIPT EXECUTION ERROR!\n\nError details:\n" .. tostring(error)
            sendNotification("❌ Execution Failed!", "Check console for details", 8)
            print(errorMsg)
        end
    end
end
