local config = require 'config.server'
local sharedConfig = require 'config.shared'

RegisterNetEvent('qbx_properties:server:apartmentSelect', function(apartmentIndex)
    local playerSource = source --[[@as number]]
    local player = exports.qbx_core:GetPlayer(playerSource)
    if not sharedConfig.apartmentOptions[apartmentIndex] then return end

    local hasApartment = MySQL.single.await('SELECT * FROM properties WHERE owner = ?', {player.PlayerData.citizenid})
    if hasApartment then return end

    local interior = sharedConfig.apartmentOptions[apartmentIndex].interior
    local interactData = {
        {
            type = 'logout',
            coords = sharedConfig.interiors[interior].logout
        },
        {
            type = 'clothing',
            coords = sharedConfig.interiors[interior].clothing
        },
        {
            type = 'exit',
            coords = sharedConfig.interiors[interior].exit
        }
    }
    local stashData = {
        {
            coords = sharedConfig.interiors[interior].stash,
            slots = config.apartmentStash.slots,
            maxWeight = config.apartmentStash.maxWeight,
        }
    }

    local result = MySQL.single.await('SELECT id FROM properties ORDER BY id DESC')
    local apartmentNumber = result?.id or 0

    ::again::

    apartmentNumber += 1
    local numberExists = MySQL.single.await('SELECT * FROM properties WHERE property_name = ?', {string.format('%s %s', sharedConfig.apartmentOptions[apartmentIndex].label, apartmentNumber)})
    if numberExists then goto again end

    local id = MySQL.insert.await('INSERT INTO `properties` (`coords`, `property_name`, `owner`, `interior`, `interact_options`, `stash_options`) VALUES (?, ?, ?, ?, ?, ?)', {
        json.encode(sharedConfig.apartmentOptions[apartmentIndex].enter),
        string.format('%s %s', sharedConfig.apartmentOptions[apartmentIndex].label, apartmentNumber),
        player.PlayerData.citizenid,
        interior,
        json.encode(interactData),
        json.encode(stashData),
    })

    TriggerClientEvent('qbx_properties:client:addProperty', -1, sharedConfig.apartmentOptions[apartmentIndex].enter)
    EnterProperty(playerSource, id, true)
    Wait(200)
    TriggerClientEvent('qb-clothes:client:CreateFirstCharacter', playerSource)
end)

local startingApartment = require '@qbx_core.config.client'.characters.startingApartment

if not startingApartment then return end

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local playerSource = source --[[@as number]]
    local player = exports.qbx_core:GetPlayer(playerSource)
    local hasApartment = MySQL.single.await('SELECT * FROM properties WHERE owner = ?', {player.PlayerData.citizenid})
    if not hasApartment then
        TriggerClientEvent('apartments:client:setupSpawnUI', playerSource)
    end
end)