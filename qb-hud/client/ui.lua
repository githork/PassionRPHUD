local speed = 0.0
local seatbeltOn = false
local cruiseOn = false

local bleedingPercentage = 0

function CalculateTimeToDisplay()
	hour = GetClockHours()
    minute = GetClockMinutes()
    
    local obj = {}
    
	if minute <= 9 then
		minute = "0" .. minute
    end
    
	if hour <= 9 then
		hour = "0" .. hour
    end
    
    obj.hour = hour
    obj.minute = minute

    return obj
end

local toggleHud = true

RegisterNetEvent('qb-hud:toggleHud')
AddEventHandler('qb-hud:toggleHud', function(toggleHud1)
    toggleHud = toggleHud1
end)

Citizen.CreateThread(function()
    Citizen.Wait(500)
    while true do 
        if QBCore ~= nil and isLoggedIn and QBHud.Show then
            speed = GetEntitySpeed(GetVehiclePedIsIn(GetPlayerPed(-1), false)) * 2.4
            local pos = GetEntityCoords(GetPlayerPed(-1))
            local time = CalculateTimeToDisplay()
            local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
            local current_zone = GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z))
            local fuel = exports['LegacyFuel']:GetFuel(GetVehiclePedIsIn(GetPlayerPed(-1)))
            local engine = GetVehicleEngineHealth(GetVehiclePedIsIn(GetPlayerPed(-1)))
            local stamina = (100 - GetPlayerSprintStaminaRemaining(PlayerId()))
            local inwater = IsPedSwimmingUnderWater(GetPlayerPed(-1))
            local oxygen = GetPlayerUnderwaterTimeRemaining(PlayerId())
            SendNUIMessage({
                action = "hudtick",
                show = IsPauseMenuActive(),
                health = GetEntityHealth(GetPlayerPed(-1)),
                armor = GetPedArmour(GetPlayerPed(-1)),
                bleeding = bleedingPercentage,
                -- direction = GetDirectionText(GetEntityHeading(GetPlayerPed(-1))),
                street1 = GetStreetNameFromHashKey(street1),
                street2 = GetStreetNameFromHashKey(street2),
                area_zone = current_zone,
                speed = math.ceil(speed),
                fuel = fuel,
                time = time,
                engine = engine,
                stamina = stamina,
                inwater = inwater,
                oxygen = oxygen,
                togglehud = toggleHud
                
            })
            Citizen.Wait(500)
        else
            Citizen.Wait(1000)
        end
    end
end)


local radarActive = false
Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(1000)
        TriggerEvent("hud:client:SetMoney")
        if IsPedInAnyVehicle(PlayerPedId()) and isLoggedIn and QBHud.Show then
            DisplayRadar(true)
            SendNUIMessage({
                action = "car",
                show = true,
            })
            radarActive = true
        else
            DisplayRadar(false)
            SendNUIMessage({
                action = "car",
                show = false,
            })
            seatbeltOn = false
            cruiseOn = false

            SendNUIMessage({
                action = "seatbelt",
                seatbelt = seatbeltOn,
            })

            SendNUIMessage({
                action = "cruise",
                cruise = cruiseOn,
            })
            radarActive = false
        end
    end
end)


RegisterNetEvent("seatbelt:client:ToggleSeatbelt")
AddEventHandler("seatbelt:client:ToggleSeatbelt", function(toggle)
    if toggle == nil then
        seatbeltOn = not seatbeltOn
        SendNUIMessage({
            action = "seatbelt",
            seatbelt = seatbeltOn,
        })
    else
        seatbeltOn = toggle
        SendNUIMessage({
            action = "seatbelt",
            seatbelt = toggle,
        })
    end
end)

RegisterNetEvent('qb-hud:client:ToggleHarness')
AddEventHandler('qb-hud:client:ToggleHarness', function(toggle)
    SendNUIMessage({
        action = "harness",
        toggle = toggle
    })
end)

RegisterNetEvent('qb-hud:client:UpdateNitrous')
AddEventHandler('qb-hud:client:UpdateNitrous', function(toggle, level, IsActive)
    SendNUIMessage({
        action = "nitrous",
        toggle = toggle,
        level = level,
        active = IsActive
    })
end)

RegisterNetEvent('qb-hud:client:UpdateDrivingMeters')
AddEventHandler('qb-hud:client:UpdateDrivingMeters', function(toggle, amount)
    SendNUIMessage({
        action = "UpdateDrivingMeters",
        amount = amount,
        toggle = toggle,
    })
end)

RegisterNetEvent('qb-hud:client:UpdateVoiceProximity')
AddEventHandler('qb-hud:client:UpdateVoiceProximity', function(Proximity)
    SendNUIMessage({
        action = "proximity",
        prox = Proximity
    })
end)

RegisterNetEvent('qb-hud:client:ProximityActive')
AddEventHandler('qb-hud:client:ProximityActive', function(active)
    SendNUIMessage({
        action = "talking",
        IsTalking = active
    })
end)


-- doesnt need to run whilst not in
--Citizen.CreateThread(function()
--    while true do
--        if isLoggedIn and QBHud.Show and QBCore ~= nil then
--            QBCore.Functions.TriggerCallback('hospital:GetPlayerBleeding', function(playerBleeding)
--                if playerBleeding == 0 then
--                    bleedingPercentage = 0
--                elseif playerBleeding == 1 then
--                    bleedingPercentage = 25
--                elseif playerBleeding == 2 then
--                    bleedingPercentage = 50
--                elseif playerBleeding == 3 then
--                    bleedingPercentage = 75
--                elseif playerBleeding == 4 then
--                    bleedingPercentage = 100
--                end
--            end)
--        end
--
--        Citizen.Wait(2500)
--    end
--end)

local LastHeading = nil
local Rotating = "left"
local toggleCompass = true

RegisterNetEvent('qb-hud:toggleCompass')
AddEventHandler('qb-hud:toggleCompass', function(toggleCompass1)
    toggleCompass = toggleCompass1
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    isLoggedIn = true
    QBHud.Show = true
    PlayerJob = QBCore.Functions.GetPlayerData().job

end)
Citizen.CreateThread(function()
    while true do
        if isLoggedIn and QBHud.Show and QBCore ~= nil and toggleCompass then
            local ped = GetPlayerPed(-1)
            local PlayerHeading = GetEntityHeading(ped)
            if LastHeading ~= nil then
                if PlayerHeading < LastHeading then
                    Rotating = "right"
                elseif PlayerHeading > LastHeading then
                    Rotating = "left"
                end
            end
            LastHeading = PlayerHeading
            SendNUIMessage({
                action = "UpdateCompass",
                heading = PlayerHeading,
                lookside = Rotating,
                toggle = toggleCompass
            })
            Citizen.Wait(50)
        else
            SendNUIMessage({
                action = "UpdateCompass",
                heading = 1,
                lookside = 1,
                toggle = toggleCompass
            })
            Citizen.Wait(1500)
        end
    end
end)

function GetDirectionText(heading)
    if ((heading >= 0 and heading < 45) or (heading >= 315 and heading < 360)) then
        return "Noord"
    elseif (heading >= 45 and heading < 135) then
        return "Oost"
    elseif (heading >=135 and heading < 225) then
        return "Zuid"
    elseif (heading >= 225 and heading < 315) then
        return "West"
    end
end