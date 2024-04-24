
local values = {}
for k in pairs(Interiors) do
    values[#values + 1] = k
end

local shell = 0
local playerCoords = vector3(0, 0, 0)
local isPreviewing = false

local function previewProperty(propertyIndex)
    if DoesEntityExist(shell) then DeleteEntity(shell) end
    if type(propertyIndex) == 'number' then
        lib.requestModel(propertyIndex, 5000)
        shell = CreateObject(propertyIndex, playerCoords.x, playerCoords.y, playerCoords.z - ShellUndergroundOffset, false, false, false)
        FreezeEntityPosition(shell, true)
        SetModelAsNoLongerNeeded(propertyIndex)
        local teleportCoords = CalculateOffsetCoords(playerCoords, Interiors[propertyIndex].exit)
        SetEntityCoords(cache.ped, teleportCoords.x, teleportCoords.y, teleportCoords.z, false, false, false, false)
    else
        local teleportCoords = Interiors[propertyIndex].exit
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
    title = 'Interior Preview',
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
        {type = 'input', label = 'Property Name', description = 'A simple descriptive name of the property', required = true, min = 4, max = 32, icon = 'home'},
        {type = 'number', label = 'Price', description = 'The purchasing price or the price deducted for rent', icon = 'dollar-sign', required = true, min = 1},
        {type = 'number', label = 'Rent interval', description = 'The interval in which the rent will be deducted in hours (makes the property rentable instead of purchasable)', icon = 'clock', min = 1, max = 24, step = 1},
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
