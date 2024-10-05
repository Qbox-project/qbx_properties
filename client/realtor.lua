local sharedConfig = require 'config.shared'
local values = {}
for k in pairs(sharedConfig.interiors) do
    values[#values + 1] = k
end

local shell = 0
local playerCoords = vec3(0, 0, 0)
local isPreviewing = false

local function previewProperty(propertyIndex)
    if DoesEntityExist(shell) then DeleteEntity(shell) end
    if type(propertyIndex) == 'number' then
        lib.requestModel(propertyIndex, 5000)
        shell = CreateObject(propertyIndex, playerCoords.x, playerCoords.y, playerCoords.z - sharedConfig.shellUndergroundOffset, false, false, false)
        FreezeEntityPosition(shell, true)
        SetModelAsNoLongerNeeded(propertyIndex)
        local teleportCoords = CalculateOffsetCoords(playerCoords, sharedConfig.interiors[propertyIndex].exit)
        SetEntityCoords(cache.ped, teleportCoords.x, teleportCoords.y, teleportCoords.z, false, false, false, false)
    else
        local teleportCoords = sharedConfig.interiors[propertyIndex].exit
        SetEntityCoords(cache.ped, teleportCoords.x, teleportCoords.y, teleportCoords.z, false, false, false, false)
    end
end

local function stopPreview()
    isPreviewing = false
    if DoesEntityExist(shell) then DeleteEntity(shell) end
    SetEntityCoords(cache.ped, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false, false)
    local players = GetActivePlayers()
    for i = 1, #players do
        if players[i] ~= cache.playerId then
            NetworkConcealPlayer(players[i], false, false)
        end
    end
end

lib.registerMenu({
    id = 'qbx_properties_realtor_menu',
    title = locale('menu.interior_preview'),
    position = 'top-right',
    onSideScroll = function(_, scrollIndex, args)
        previewProperty(args[scrollIndex])
    end,
    onClose = function()
        stopPreview()
    end,
    options = {
        { label = 'Interiors', values = values, args = values, icon = 'house' },
    }
}, function(_, scrollIndex, args)
    stopPreview()
    local input = lib.inputDialog('Realestate Creator', {
        {type = 'input', label = locale('alert.property_name'), description = locale('alert.property_name_description'), required = true, min = 4, max = 32, icon = 'home'},
        {type = 'number', label = locale('alert.price'), description = locale('alert.price_description'), icon = 'dollar-sign', required = true, min = 1},
        {type = 'number', label = locale('alert.rent_interval'), description = locale('alert.rent_interval_description'), icon = 'clock', min = 1, max = 24, step = 1},
    })
    if input then
        TriggerServerEvent('qbx_properties:server:createProperty', args[scrollIndex], input, playerCoords)
    end
end)

RegisterNetEvent('qbx_properties:client:createProperty', function()
    playerCoords = GetEntityCoords(cache.ped)
    isPreviewing = true
    previewProperty(values[1])
    lib.showMenu('qbx_properties_realtor_menu')
    while isPreviewing do
        local players = GetActivePlayers()
        for i = 1, #players do
            if players[i] ~= cache.playerId then
                NetworkConcealPlayer(players[i], true, false)
            end
        end
        Wait(3000)
    end
end)