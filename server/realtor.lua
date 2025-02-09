local config = require 'config.server'
local sharedConfig = require 'config.shared'

lib.addCommand('createproperty', {
    help = 'Create a property at your current location',
}, function(source)
    local player = exports.qbx_core:GetPlayer(source)

    if player.PlayerData.job.name ~= 'realestate' then exports.qbx_core:Notify(source, 'Not a realtor', 'error') return end

    TriggerClientEvent('qbx_properties:client:createProperty', source)
end)

RegisterNetEvent('qbx_properties:server:createProperty', function(interiorIndex, data, propertyCoords, garageCoords)
    local playerSource = source --[[@as number]]
    local player = exports.qbx_core:GetPlayer(playerSource)
    local playerCoords = GetEntityCoords(GetPlayerPed(playerSource))

    if player.PlayerData.job.name ~= 'realestate' then return end
    if not garageCoords and #(playerCoords - propertyCoords) > 5.0 then return end
    if garageCoords and #(playerCoords - garageCoords.xyz) > 5.0 then return end

    local interactData = {
        {
            type = 'logout',
            coords = sharedConfig.interiors[interiorIndex].logout
        },
        {
            type = 'clothing',
            coords = sharedConfig.interiors[interiorIndex].clothing
        },
        {
            type = 'exit',
            coords = sharedConfig.interiors[interiorIndex].exit
        }
    }

    local stashData = {
        {
            coords = sharedConfig.interiors[interiorIndex].stash,
            slots = config.apartmentStash.slots,
            maxWeight = config.apartmentStash.maxWeight,
        }
    }

    local result = MySQL.single.await('SELECT id FROM properties ORDER BY id DESC', {})
    local propertyNumber = result?.id or 0
    local propertyName = string.format('%s %s', data[1], propertyNumber)

    MySQL.insert('INSERT INTO `properties` (`coords`, `property_name`, `price`, `interior`, `interact_options`, `stash_options`, `rent_interval`, `garage`) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        json.encode(propertyCoords),
        propertyName,
        data[2],
        interiorIndex,
        json.encode(interactData),
        json.encode(stashData),
        data[3],
        garageCoords and json.encode(garageCoords) or nil,
    })
    TriggerClientEvent('qbx_properties:client:addProperty', -1, propertyCoords)
end)