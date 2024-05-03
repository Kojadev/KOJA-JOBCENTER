Koja = {}
Koja.Framework = Utils.Functions.GetFramework()
Koja.Utils = Utils.Functions
Koja.Server = {
    MySQL = {
        Async = {},
        Sync = {}
    }
}
Koja.Callbacks = {}
Koja.Server.RegisterServerCallback = function(key, func)
    Koja.Callbacks[key] = func
end

local cooldownTriggers = {}

CreateThread(function()
    while Koja.Framework == nil do
        Koja.Framework = Utils.Functions.GetFramework()
        Wait(15)
    end
end)

RegisterNetEvent("koja-crafting:Server:HandleCallback", function(key, payload)
    local src = source
    if Koja.Callbacks[key] then
        Koja.Callbacks[key](src, payload, function(cb)
            TriggerClientEvent("koja-crafting:Client:HandleCallback", src, key, cb)
        end)
    end
end)

Koja.Server.GetPlayerBySource = function(source)
    if Config.Framework == "esx" then
        return Koja.Framework.GetPlayerFromId(source)
    elseif Config.Framework == "qb" then
        return Koja.Framework.Functions.GetPlayer(source)
    end
end

Koja.Server.GetPlayerJob = function(source)
    local xPlayer = Koja.Server.GetPlayerBySource(source)
    local currentJob = nil

    if Config.Framework == "esx" then
        if Config.TypeJob == 'setjob' then
            currentJob = xPlayer.job.label
        elseif Config.TypeJob == 'setsecondjob' then
            currentJob = xPlayer.secondjob.label
        end
    elseif Config.Framework == "qb" then
        if Config.TypeJob == 'setjob' then
            currentJob = xPlayer.PlayerData.job.name
        elseif Config.TypeJob == 'setsecondjob' then
            currentJob = xPlayer.PlayerData.secondjob.name
        end
    end

    return currentJob
end

local function splitId(str)
    local output
    for s in string.gmatch(str, "([^:]+)") do
        output = s
    end
    return output
end

local function extractDiscordIdentifier(source)
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.find(id, "discord") then
            return splitId(id)
        end
    end
end

local function getUserData(source)
    local discordIdentifier = extractDiscordIdentifier(source)

    local name
    local image

    PerformHttpRequest("https://discord.com/api/v9/users/"..discordIdentifier, function(err, text, headers)
        local DiscordData = json.decode(text)
        if DiscordData then
            name = DiscordData.username

            if DiscordData.avatar then
                image = "https://cdn.discordapp.com/avatars/"..discordIdentifier.."/"..DiscordData.avatar..".webp?size=128"
            else
                image = "https://cdn.discordapp.com/attachments/1211803606634860644/1236033466735267860/FYNogHY.png?ex=6636895e&is=663537de&hm=d2f814c820539e45341a3399e25b300a88878bb997d4ddea4af2ba8ee378d376&"
            end
        else
            name = GetPlayerName(source)
            image = "https://cdn.discordapp.com/attachments/1211803606634860644/1236033466735267860/FYNogHY.png?ex=6636895e&is=663537de&hm=d2f814c820539e45341a3399e25b300a88878bb997d4ddea4af2ba8ee378d376&"
        end
    end, 'GET', nil, {['Content-Type'] = 'application/json', ["Authorization"] = "Bot "..discordbottoken})

    while not name or not image do
        Wait(100)
    end

    return { name = name, image = image }
end

Koja.Server.RegisterServerCallback('KOJA_jobcenter:getPlayerDetails', function(source, payload, cb)
    local xPlayer = Koja.Server.GetPlayerBySource(source)
    local identifier, firstname, lastname, gender, bank, money, genderText
    local discordData = getUserData(source)
    local currentjob = Koja.Server.GetPlayerJob(source)

    if Config.Framework == "esx" then
        identifier = xPlayer.identifier
        firstname = xPlayer.get('firstName')
        lastname = xPlayer.get('lastName')
        genderText = (xPlayer.get('sex') == 'm' and Config.Language.male) or (xPlayer.get('sex') == 'f' and Config.Language.female) or "Unknown"
        bank = xPlayer.getAccount('bank').money
        money = xPlayer.getMoney()
    elseif Config.Framework == "qb" then
        identifier = xPlayer.PlayerData.license
        firstname = xPlayer.PlayerData.charinfo.firstname
        lastname = xPlayer.PlayerData.charinfo.lastname
        genderText = (xPlayer.PlayerData.charinfo.gender == 0 and Config.Language.male) or (xPlayer.PlayerData.charinfo.gender == 1 and Config.Language.female) or "Unknown"
        bank = xPlayer.PlayerData.money["bank"]
        money = xPlayer.PlayerData.money["cash"]
    end


    local result = ExecuteSql("SELECT * FROM KOJA_jobcenter WHERE citizenid = '".. tostring(identifier) .."'")
    local callbackData = {}

    if not result or #result == 0 then
        ExecuteSql("INSERT INTO KOJA_jobcenter SET citizenid = '".. tostring(identifier) .."', currentXP = '0'")
        callbackData = {
            currentXP = 0,
            avatar = discordData.image,
            name = GetPlayerName(source),
            job = currentjob,
            gender = genderText,
            firstname = firstname,
            lastname = lastname,
            bank = bank,
            money = money,
        }
    else
        callbackData = {
            currentXP = result[1].currentXP,
            avatar = discordData.image ,
            name = GetPlayerName(source),
            job = Koja.Server.GetPlayerJob(source),
            gender = genderText,
            firstname = firstname,
            lastname = lastname,
            bank = bank,
            money = money,
        }
    end
    if type(cb) == 'function' then
        cb(callbackData)
    else
        print("Error: Provided 'cb' is not a function, it is a " .. type(cb))
    end
end)


function removeCooldown(id)
    for i,v in ipairs(cooldownTriggers) do
        if v == id then
            table.remove(cooldownTriggers, i)
        end
    end
end

RegisterNetEvent('KOJA_jobcenter:dropplayer')
AddEventHandler('KOJA_jobcenter:dropplayer', function(job)
    local xPlayer = Koja.Server.GetPlayerBySource(source)
    local identifier = nil

    if Config.Framework == "esx" then
        identifier = xPlayer.identifier
    elseif Config.Framework == "qb" then
        identifier = xPlayer.PlayerData.license
    end

    if xPlayer then
        DropPlayer(source, "Tried to set blacklisted job or not in menu")
    else
        print("Failed to retrieve player data for source: " .. tostring(source))
    end
end)

RegisterNetEvent('KOJA_jobcenter:addXP')
AddEventHandler('KOJA_jobcenter:addXP', function(amount)
    local _source = source
    local xPlayer = Koja.Server.GetPlayerBySource(_source)
    if not xPlayer then
        print("Failed to find player with source ID:", _source)
        return
    end

    local citizenId = (Config.Framework == "esx" and xPlayer.identifier) or (Config.Framework == "qb" and xPlayer.PlayerData.license)
    local currentJob = Koja.Server.GetPlayerJob(_source)

    if cooldownTriggers[_source] or table.contains(Config.BlackListedJobs, currentJob) then
        print("^5[KOJA-JOBCENTER]^7 ID:", _source, "^8IS PROBABLY CHEATING - PLAYER GOT XP ON COOLDOWN^7")
        return
    end

    local xpToAdd = tonumber(amount)
    if not xpToAdd or xpToAdd >= Config.MaxExpAmount then
        print("^5[KOJA-JOBCENTER]^7 ID:", _source, "^8IS PROBABLY CHEATING - PLAYEGOT OVER MAX XP^7")
        return
    end

    ExecuteSql("UPDATE KOJA_jobcenter SET currentXP = currentXP + '"..xpToAdd.."' WHERE citizenid = '"..citizenId.."'")

    cooldownTriggers[_source] = true
    Citizen.CreateThread(function()
        Citizen.Wait(Config.TriggerCooldown * 1000)
        cooldownTriggers[_source] = nil
    end)
end)

function ExecuteSql(query)
    local IsBusy = true
    local result = nil
    if Config.Database == "oxmysql" then
        if MySQL == nil then
            exports.oxmysql:execute(query, function(data)
                result = data
                IsBusy = false
            end)
        else
            MySQL.query(query, {}, function(data)
                result = data
                IsBusy = false
            end)
        end
    elseif Config.Database == "mysql-async" then
        MySQL.Async.fetchAll(query, {}, function(data)
            result = data
            IsBusy = false
        end)
    end
    while IsBusy do
        Citizen.Wait(0)
    end
    return result
end

RegisterNetEvent('KOJA_jobcenter:setjob')
AddEventHandler('KOJA_jobcenter:setjob', function(data)
    local xPlayer = Koja.Server.GetPlayerBySource(source)
    currentJob = Koja.Server.GetPlayerJob(source)

    for k,v in ipairs(GetPlayerIdentifiers(source))do
        if string.sub(v, 1, string.len("license:")) == "license:" then
            license = v
        elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
            identifier = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            discord = v
        end
    end

    for k,v in pairs(Config.BlackListedJobs) do
        if data == v then
            print("^5[KOJA-JOBCENTER]^7 ID:"..source.." ^8IS PROBABLY CHEATING - CHECK KOJA LOGS^7")
            return
        end
    end

    if Config.Framework == 'esx' then
        if Config.TypeJob == 'setjob' then
            xPlayer.setJob(data, 0)
        elseif Config.TypeJob == 'setsecondjob' then
            xPlayer.setSecondJob(data, 0)
        end
    elseif Config.Framework == 'qb' then
        if Config.TypeJob == 'setjob' then
            xPlayer.Functions.SetJob(data, 0)
        elseif Config.TypeJob == 'setsecondjob' then
            xPlayer.Functions.setSecondJob(data, 0)
        end
    end
end)

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end


