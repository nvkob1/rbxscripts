return function(config)
    local SCRIPT_NAME = config.scriptName or "Script"
    local MAIN_SCRIPT = config.mainScript

    local function checkUNCCompatibility()
        local required = {
            loadstring = loadstring,
            isfolder = isfolder,
            makefolder = makefolder,
            writefile = writefile,
            isfile = isfile,
            getgenv = getgenv
        }

        local optional = {
            cloneref = cloneref,
            hookmetamethod = hookmetamethod,
            getrawmetatable = getrawmetatable
        }

        local missingFunctions = {}
        local warnings = {}

        for name, func in pairs(required) do
            if not func then
                table.insert(missingFunctions, name)
            end
        end

        for name, func in pairs(optional) do
            if not func then
                table.insert(warnings, name)
            end
        end

        return #missingFunctions == 0, missingFunctions, warnings
    end

    local function sendNotification(title, text, duration)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = duration or 5
            })
        end)
    end

    local isCompatible, missingFuncs, optionalWarnings = checkUNCCompatibility()

    if isCompatible and #optionalWarnings == 0 then
        sendNotification("✅ Ready to Go!", "Executor fully supported", 3)
        print("✅ " .. SCRIPT_NAME .. ": Fully supported")

    elseif isCompatible and #optionalWarnings > 0 then
        sendNotification("⚠️ Almost There!", "Some features may be limited", 4)
        print("⚠️ " .. SCRIPT_NAME .. ": Partial support (missing: " .. table.concat(optionalWarnings, ", ") .. ")")

    else
        sendNotification("❌ Heads Up!", "May not work properly", 5)
        print("❌ " .. SCRIPT_NAME .. ": Limited support (missing: " .. table.concat(missingFuncs, ", ") .. ")")
    end

    print("🔄 Loading " .. SCRIPT_NAME .. " (compatibility check completed)...")

    if MAIN_SCRIPT and type(MAIN_SCRIPT) == "function" then
        local success, err = pcall(MAIN_SCRIPT)
        if not success then
            sendNotification("❌ Execution Failed!", "Check console for details", 8)
            print("❌ SCRIPT EXECUTION ERROR!\n\nError details:\n" .. tostring(err))
        end
    end
end
