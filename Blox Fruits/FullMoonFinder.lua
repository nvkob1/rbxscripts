local Moon = {
['8'] = "http://www.roblox.com/asset/?id=9709149431",
['7'] = "http://www.roblox.com/asset/?id=9709149052",
['6'] = "http://www.roblox.com/asset/?id=9709143733",
['5'] = "http://www.roblox.com/asset/?id=9709150401",
['4'] = "http://www.roblox.com/asset/?id=9709135895",
['3'] = "http://www.roblox.com/asset/?id=9709139597",
['2'] = "http://www.roblox.com/asset/?id=9709150086",
['1'] = "http://www.roblox.com/asset/?id=9709149680",
};

function CheckMoonAndExecute()
    if game:GetService("Lighting").Sky.MoonTextureId == Moon['1'] then
        MoonIcon = '🌔'
    elseif game:GetService("Lighting").Sky.MoonTextureId == Moon['2'] then
        MoonIcon = '🌓'
    elseif game:GetService("Lighting").Sky.MoonTextureId == Moon['3'] then
        MoonIcon = '🌒'
    elseif game:GetService("Lighting").Sky.MoonTextureId == Moon['4'] then
        MoonIcon = '🌑'
    elseif game:GetService("Lighting").Sky.MoonTextureId == Moon['5'] then
        MoonIcon = '🌘'
    elseif game:GetService("Lighting").Sky.MoonTextureId == Moon['6'] then
        MoonIcon = '🌗'
    elseif game:GetService("Lighting").Sky.MoonTextureId == Moon['7'] then
        MoonIcon = '🌖'
    elseif game:GetService("Lighting").Sky.MoonTextureId == Moon['8'] then
        MoonIcon = '🌕'
    end

    for i,v in pairs(Moon) do
        if game:GetService("Lighting").Sky.MoonTextureId == v then
            MoonPercent = i / 8 * 100
        end
    end
    
    for i,v in pairs(game.Players:GetPlayers()) do
        PlayersMin = i
    end

    MoonMessage = '```'..tostring(MoonPercent..'%'..' : '..MoonIcon)..'```'
    CodeServer = 'game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,'..'\''..tostring(game.JobId)..'\''..')'

    if _G.LinkHook and _G.LinkHook ~= "" then
        local Embed = {
            ["username"] = "Full Moon Notify",
            ["avatar_url"] = "https://cdn.discordapp.com/attachments/1258228428881137677/1258228644959096907/1705502093042.jpg?ex=6687483d&is=6685f6bd&hm=31d72cdb691c08bba64e22e59af42a1c4bad11b6ef8bad223436bf883d4e334a&",
            ["embeds"] = {
                {
                    ["title"] = "**Full Moon Notify**",
                    ["color"] = tonumber(00000000),
                    ["type"] = "rich",
                    ["fields"] =  {
                        {
                            ["name"] = "Players",
                            ["value"] = '```'..tostring(PlayersMin)..'/12```',
                            ["inline"] = false
                        },
                        {
                            ["name"] = "Job Id",
                            ["value"] = '```'..tostring(game.JobId)..'```',
                            ["inline"] = false
                        },
                        {
                            ["name"] = "Code",
                            ["value"] = '```'..CodeServer..'```',
                            ["inline"] = true
                        },
                        {
                            ["name"] = "Moon",
                            ["value"] = ''..MoonMessage..'',
                            ["inline"] = true
                        }
                    },
                    ["thumbnail"] = {
                    ["url"] = "https://cdn.discordapp.com/attachments/1258228428881137677/1258228644959096907/1705502093042.jpg?ex=6687483d&is=6685f6bd&hm=31d72cdb691c08bba64e22e59af42a1c4bad11b6ef8bad223436bf883d4e334a&",
                    },
                    ["footer"] = {
                        ["timestamp"] = DateTime.now():ToIsoDate(),
                        ["icon_url"] = "https://cdn.britannica.com/89/145489-050-4E9609BA/moon-return-journey-Apollo-11-July-21-1969.jpg"
                    }
                }
            },
        }
        
        local Data = game:GetService("HttpService"):JSONEncode(Embed)
        local Head = {["content-type"] = "application/json"}
        Send = http_request or request or HttpPost or syn.request
        local sendhook = {Url = _G.LinkHook, Body = Data, Method = "POST", Headers = Head}
        Send(sendhook)
    end
    
    if MoonPercent == 100 then
        print("Full moon found! Stopping execution.")
        return true
    end
    
    return false
end

function Hop()
    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""
    local actualHour = os.date("!*t").hour
    
    function TPReturner()
        local Site;
        if foundAnything == "" then
            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
        else
            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
        end
        local ID = ""
        if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
            foundAnything = Site.nextPageCursor
        end
        local num = 0;
        for i,v in pairs(Site.data) do
            local Possible = true
            ID = tostring(v.id)
            if tonumber(v.maxPlayers) > tonumber(v.playing) then
                for _,Existing in pairs(AllIDs) do
                    if num ~= 0 then
                        if ID == tostring(Existing) then
                            Possible = false
                        end
                    else
                        if tonumber(actualHour) ~= tonumber(Existing) then
                            local delFile = pcall(function()
                                AllIDs = {}
                                table.insert(AllIDs, actualHour)
                            end)
                        end
                    end
                    num = num + 1
                end
                if Possible == true then
                    table.insert(AllIDs, ID)
                    wait()
                    pcall(function()
                        wait()
                        game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                    end)
                    wait(4)
                end
            end
        end
    end
    
    function Teleport() 
        while wait() do
            pcall(function()
                TPReturner()
                if foundAnything ~= "" then
                    TPReturner()
                end
            end)
        end
    end
    Teleport()
end

game.Players.LocalPlayer.OnTeleport:Connect(function()
    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/Blox%20Fruits/FullMoonFinder.lua"))()')
end)

if CheckMoonAndExecute() then
    -- Full moon found, stop execution
else
    -- Continue hopping
    Hop()
end
