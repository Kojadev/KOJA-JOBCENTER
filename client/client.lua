local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
Koja = {}
Koja.Framework = Utils.Functions.GetFramework()
Koja.Utils = Utils.Functions
Koja.Callbacks = {}
Koja.Client = {}

Koja.Client.TriggerServerCallback = function(key, payload, func)
    if not func then
        func = function() end
    end

    Koja.Callbacks[key] = func
    TriggerServerEvent("koja-crafting:Server:HandleCallback", key, payload)
end

RegisterNetEvent("koja-crafting:Client:HandleCallback", function(key, data)
    if Koja.Callbacks[key] then
        Koja.Callbacks[key](data)
        Koja.Callbacks[key] = nil
    end
end)

CreateThread(function()
    while Koja.Framework == nil do
        Koja.Framework = Utils.Functions.GetFramework()
        Wait(15)
    end
end)

local menuopen = false

RegisterNetEvent('KOJA_jobcenter:client_addXP')
AddEventHandler('KOJA_jobcenter:client_addXP', function(amount)
	TriggerServerEvent('KOJA_jobcenter:addXP', amount)
end)

RegisterNUICallback('selectJob', function(data, cb)
    for k,v in pairs(Config.BlackListedJobs) do
        if data.jobInfo.jobid == v then
            TriggerServerEvent("KOJA_jobcenter:dropplayer", v)
        end
    end
    if menuopen then
        TriggerServerEvent("KOJA_jobcenter:setjob", data.jobInfo.jobid)
    else
        TriggerServerEvent("KOJA_jobcenter:dropplayer", data.jobInfo.jobid)
    end
end)

local currentPed = nil

Citizen.CreateThread(function()
    Wait(500)
    for k, v in pairs(Config.Peds) do 
        RequestModel(v.pedHash)
        while not HasModelLoaded(v.pedHash) do
            Wait(1)
        end
        currentPed = CreatePed(v.pedName, v.pedHash, v.pedCoord.x, v.pedCoord.y, v.pedCoord.z, v.h + 0.0, false, true)
        FreezeEntityPosition(currentPed, true)
        SetEntityInvincible(currentPed, true)
        SetBlockingOfNonTemporaryEvents(currentPed, true)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        local pos = GetEntityCoords(PlayerPedId())
        local sleep = true
        for k, v in pairs(Config.Peds) do 
            if #(v.pedCoord - pos) < 3 then 
                sleep = false
                local text = v.drawText
                if #(v.pedCoord - pos) < 2 then 
                    text = "[E] - "..v.drawText
                    if IsControlJustReleased(0, 38) then 
                        openMenu()
                    end
                end
                DrawText3D(v.pedCoord.x, v.pedCoord.y, v.pedCoord.z+2, text)
            end
        end
        if sleep then
            Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        local pos = GetEntityCoords(PlayerPedId())
        local sleep = true
        for k, v in pairs(Config.Peds) do 
            local distance = #(v.pedCoord - pos)
            if distance > 3 and distance < 20 then
                sleep = false
                RequestAnimDict('anim@amb@waving@male')
                while not HasAnimDictLoaded('anim@amb@waving@male') do Wait(0) end
                TaskPlayAnim(currentPed, 'anim@amb@waving@male', 'ground_wave', 8.0, -8.0, -1, 1, 0, false,
                false, false)
                Citizen.Wait(6000)
                ClearPedTasksImmediately(currentPed)
            end
        end
        if sleep then
            Wait(500)
        end
    end
end)

local openMenuSpamProtect = 0
function openMenu()
    if openMenuSpamProtect < GetGameTimer() then 
        openMenuSpamProtect = GetGameTimer() + 1000
        menuopen = true
        Koja.Client.TriggerServerCallback("KOJA_jobcenter:getPlayerDetails", {}, function(result)

            SetNuiFocus(true,true)
            SendNUIMessage({
                type = "show",
                xp = result.currentXP,
                jobs = Config.Jobs,
                avatar = result.avatar,
                apiKey = result.apiKey, 
                job = result.job,   
                firstname = result.firstname,
                lastname = result.lastname, 
                gender = result.gender, 
                moneyCash = result.money,
                moneyBank = result.bank,  
                translate = Config.Language,
            })  
        end)
    end
end

--[[ -- TO ONLY TEST
RegisterCommand('addxp', function()
    TriggerServerEvent('KOJA_jobcenter:addXP', 390)
end)
]]

RegisterNUICallback('closeMenu', function(data, cb)
	SetNuiFocus(false, false)
    menuopen = false
end)


function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.28, 0.28)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 245)
    SetTextOutline(true)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end