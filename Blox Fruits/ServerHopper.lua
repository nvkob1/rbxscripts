getgenv().ServerHopConfig = getgenv().ServerHopConfig or {
    Region = "singapore",
    LowPlayers = true
}
local ServerBrowser = game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser")

function ServerHop()
    local config = getgenv().ServerHopConfig
    local currentJob = game.JobId
    local maxAttempts = 5

    for attempt = 1, maxAttempts do
        local list = {}
        local done = 0

        for i = 1, 100 do
            task.spawn(function()
                local ok, res = pcall(function() return ServerBrowser:InvokeServer(i) end)
                if ok and res then
                    for jobId, data in pairs(res) do
                        data.Job = jobId
                        table.insert(list, data)
                    end
                end
                done += 1
            end)
            task.wait(1/50)
        end
        repeat task.wait() until done >= 100

        local candidates = {}
        for _, s in ipairs(list) do
            if s.Job ~= currentJob and s.Count then
                local regionMatch = true
                if config.Region and config.Region ~= "" and s.Region then
                    regionMatch = s.Region:lower():find(config.Region:lower()) ~= nil
                end
                if regionMatch then
                    table.insert(candidates, s)
                end
            end
        end

        if #candidates == 0 then
            warn(("[ServerHop] Attempt %d: No matching servers found"):format(attempt))
            task.wait(2)
            continue
        end

        local target
        if config.LowPlayers then
            table.sort(candidates, function(a, b) return a.Count < b.Count end)
            target = candidates[1]
        else
            target = candidates[math.random(1, #candidates)]
        end

        print(("[ServerHop] Attempt %d: Joining Job: %s | Region: %s | Players: %s"):format(
            attempt, target.Job, tostring(target.Region), tostring(target.Count)
        ))

        local ok = pcall(function() ServerBrowser:InvokeServer("teleport", target.Job) end)
        if ok then
            task.wait(3)
            if game.JobId ~= currentJob then
                print("[ServerHop] Teleport succeeded.")
                return true
            else
                warn(("[ServerHop] Attempt %d: Target server unavailable, retrying..."):format(attempt))
            end
        else
            warn(("[ServerHop] Attempt %d: Invoke failed, retrying..."):format(attempt))
        end
    end

    warn("[ServerHop] All attempts exhausted. Giving up.")
    return false
end

ServerHop()
