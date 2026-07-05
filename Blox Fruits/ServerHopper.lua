getgenv().ServerHopConfig = getgenv().ServerHopConfig or {
    Region = "singapore",
    LowPlayers = true
}

local ServerBrowser = game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser")

function ServerHop()
    local config = getgenv().ServerHopConfig
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

    local currentJob = game.JobId
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
        warn("[ServerHop] No matching servers found")
        return false
    end

    local target
    if config.LowPlayers then
        table.sort(candidates, function(a, b) return a.Count < b.Count end)
        target = candidates[1]
    else
        target = candidates[math.random(1, #candidates)]
    end

    print(("[ServerHop] Joining Job: %s | Region: %s | Players: %s"):format(
        target.Job, tostring(target.Region), tostring(target.Count)
    ))

    local ok = pcall(function() ServerBrowser:InvokeServer("teleport", target.Job) end)
    if not ok then return false end

    task.wait(3)
    return game.JobId ~= currentJob
end

ServerHop()
