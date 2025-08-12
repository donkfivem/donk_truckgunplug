Citizen.CreateThread(function()
    local model = Config.VehicleModel --set model you want
    local offset = vector3(0.0, -1, 1)
    local distance = 2.0
    local size = vector3(1.5, 1.5, 1.5)
    local lastVehicle = nil
    local lastZone = nil

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local vehicle = GetClosestVehicle(playerCoords, 10.0, GetHashKey(model), 70)
        if vehicle ~= 0 then
            local vehicleCoords = GetEntityCoords(vehicle)
            if not vehicleCoords then
                Citizen.Wait(1000)
                goto continue
            end
            local zoneCoords = vehicleCoords + offset
            local rotation = GetEntityHeading(vehicle)
            if zoneCoords.x == 0.0 and zoneCoords.y == 0.0 and zoneCoords.z == 0.0 then
                Citizen.Wait(1000)
                goto continue
            end
            if lastVehicle ~= vehicle and lastZone then
                exports.ox_target:removeZone(lastZone)
                lastZone = nil
            end
            lastVehicle = vehicle
            if not lastZone then
                lastZone = exports.ox_target:addBoxZone({
                    coords = zoneCoords,
                    size = size,
                    rotation = rotation,
                    debug = false,
                    options = {
                        {
                            label = 'Gun Plug Weapons',
                            icon = 'fas fa-gun',
                            distance = distance,
                            onSelect = function(data)
                                local serverId = GetPlayerServerId(PlayerId())
                                TriggerServerEvent('donk_gunplug:giveTrunkRewards', serverId)
                            end
                        }
                    }
                })
            end
        else
            if lastZone then
                exports.ox_target:removeZone(lastZone)
                lastVehicle = nil
                lastZone = nil
            end
        end
        ::continue::
        Citizen.Wait(1000)
    end
end)

RegisterNetEvent('donk_gunplug:openWeaponMenu')
AddEventHandler('donk_gunplug:openWeaponMenu', function(weapons, totalItems)
    local options = {}
    for _, weapon in ipairs(weapons) do
        local weaponLabel = exports.ox_inventory:Items(weapon) and exports.ox_inventory:Items(weapon).label or weapon
        table.insert(options, {
            title = weaponLabel,
            description = 'Select to choose quantity',
            icon = 'fas fa-gun',
            metadata = { spawnCode = weapon }, -- Store spawn code
            onSelect = function()
                local input = lib.inputDialog('Select Quantity for ' .. weaponLabel, {
                    {
                        type = 'number',
                        label = 'Quantity',
                        description = 'Enter amount (1-' .. totalItems .. ')',
                        required = true,
                        min = 1,
                        max = totalItems
                    }
                })
                if input and input[1] then
                    local quantity = tonumber(input[1])
                    print('[DEBUG] Selected weapon: ' .. weapon .. ', label: ' .. weaponLabel .. ', quantity: ' .. quantity)
                    TriggerServerEvent('donk_gunplug:confirmWeaponSelection', weapon, quantity)
                else
                    print('[DEBUG] Quantity input cancelled')
                    TriggerClientEvent('ox_lib:notify', -1, {
                        title = 'Selection cancelled',
                        type = 'error',
                        duration = 5000
                    })
                end
            end
        })
    end
    lib.registerContext({
        id = 'gunplug_weapon_menu',
        title = 'Gunplug Rewards (Remaining: ' .. totalItems .. ')',
        options = options
    })
    lib.showContext('gunplug_weapon_menu')
end)