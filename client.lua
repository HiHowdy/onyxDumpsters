ESX = nil

local searched = {3423423424}
local canSearch = true
local dumpsters = {218085040, 666561306, -58485588, -206690185, 1511880420, 682791951}
local searchTime = 14000

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if canSearch then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local dumpsterFound = false

            for i = 1, #dumpsters do
                local dumpster = GetClosestObjectOfType(pos, 1.0, dumpsters[i], false, false, false)
                local dumpPos = GetEntityCoords(dumpster)
                local dist = #(pos - dumpPos)

                while dist < 1.8 and canSearch and DoesEntityExist(dumpster) do
                    Citizen.Wait(0)
                    dumpPos = GetEntityCoords(dumpster)
                    dist = #(GetEntityCoords(ped) - dumpPos)
                    DrawText3Ds(dumpPos.x, dumpPos.y, dumpPos.z + 1.0, 'Press [~y~H~w~] to dumpster dive')
                    if IsControlJustReleased(0, 74) then
                        for i = 1, #searched do
                            if searched[i] == dumpster then
                                dumpsterFound = true
                                break
                            end 
                        end
                        if dumpsterFound then
                            exports['mythic_notify']:DoHudText('error', 'This dumpster has already been searched')
                            break
                        else
                            exports['mythic_notify']:DoHudText('inform', 'You begin to search the dumpster')
                            startSearching(searchTime, 'amb@prop_human_bum_bin@base', 'base', 'onyx:giveDumpsterReward')
                            TriggerServerEvent('onyx:startDumpsterTimer', dumpster)
                            table.insert(searched, dumpster)
                            break
                        end
                        Citizen.Wait(1000)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('onyx:removeDumpster')
AddEventHandler('onyx:removeDumpster', function(object)
    for i = 1, #searched do
        if searched[i] == object then
            table.remove(searched, i)
        end
    end
end)

-- Functions

function startSearching(time, dict, anim, cb)
    local animDict = dict
    local animation = anim
    local ped = GetPlayerPed(-1)

    canSearch = false

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
    exports['progressBars']:startUI(time, "Searching Dumpster")
    TaskPlayAnim(ped, animDict, animation, 8.0, 8.0, time, 1, 1, 0, 0, 0)

    local ped = GetPlayerPed(-1)

    Wait(time)
    ClearPedTasks(ped)
    canSearch = true
    TriggerServerEvent(cb)
end

function DrawText3Ds(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local factor = #text / 460
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	
	SetTextScale(0.3, 0.3)
	SetTextFont(6)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 160)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	DrawRect(_x,_y + 0.0115, 0.02 + factor, 0.027, 28, 28, 28, 95)
end
