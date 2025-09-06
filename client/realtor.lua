local sharedConfig = require 'config.shared'
local values = {}
for k in pairs(sharedConfig.interiors) do
    values[#values + 1] = k
end

local car = 0
local shell = 0
local playerCoords = vec3(0, 0, 0)
local garageCoords = nil
local garageHeading = 0.0
local isPreviewing = false

local function showText()
    lib.showTextUI('BACKSPACE - Exit  \n ARROW LEFT - Turn left  \n ARROW RIGHT - Turn right  \n ENTER - Confirm Placement')
end

local function spawnCar()
    local model = lib.requestModel('sultanrs', 2500)
    car = CreateVehicle(model, 0.0, 0.0, 0.0, 0.0, false, false)
    SetEntityCompletelyDisableCollision(car, false, false)
    SetModelAsNoLongerNeeded(model)
end

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

local function addGaragePoint()
    local isAddingGarage = true
    garageCoords = nil

    showText()
    spawnCar()

    while isAddingGarage do
        Wait(0)

        local hit, _, endCoords = lib.raycast.fromCamera(511, 4, 25.0)

        if not hit then
            SetEntityCoords(car, 0.0, 0.0, 0.0, false, false, false, false)
        else
            SetEntityCoords(car, endCoords.x, endCoords.y, endCoords.z + 1.0, false, false, false, false)
            SetVehicleOnGroundProperly(car)
        end

        if IsControlJustPressed(0, 202) then
            if DoesEntityExist(car) then
                DeleteEntity(car)
            end
            isAddingGarage = false
        end

        if IsControlPressed(0, 190) then
            garageHeading = (garageHeading + 2.5) % 360.0
            SetEntityHeading(car, garageHeading)
            Wait(100)
        end

        if IsControlPressed(0, 189) then
            garageHeading = (garageHeading - 2.5) % 360.0
            SetEntityHeading(car, garageHeading)
            Wait(100)
        end

        if IsControlJustPressed(0, 18) then
            if hit then
                garageCoords = endCoords
                garageHeading = GetEntityHeading(car)
                if DoesEntityExist(car) then
                    DeleteEntity(car)
                end
                isAddingGarage = false
            else
                lib.notify({type = 'error', title = 'Error', description = 'Invalid garage location.'})
            end
        end

        SetEntityHeading(car, garageHeading) -- Prevent the car from rotating
    end

    lib.hideTextUI()
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
        {type = 'checkbox', label = locale('alert.add_garage')},
    })
    if not input then return end

    local garageData = nil
    
    if input[4] then
        addGaragePoint()
        if garageCoords then
            garageData = vec4(garageCoords.x, garageCoords.y, garageCoords.z + 1.0, garageHeading)
        end
    end

    TriggerServerEvent('qbx_properties:server:createProperty', args[scrollIndex], input, playerCoords, garageData)
end)

RegisterNetEvent('qbx_properties:client:createProperty', function()
    playerCoords = GetEntityCoords(cache.ped)
    garageCoords = nil
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
