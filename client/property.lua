local interiorShell
local decorationObjects = {}
local insideProperty = false
local interactions

local function prepareKeyMenu()
    local keyholders = lib.callback.await('qbx_properties:callback:requestKeyHolders')
    local options = {
        {
            title = 'Add Keyholder',
            icon = 'plus',
            arrow = true,
            onSelect = function()
                local insidePlayers = lib.callback.await('qbx_properties:callback:requestPotentialKeyholders')
                local options = {}
                for i = 1, #insidePlayers do
                    options[#options + 1] = {
                        title = insidePlayers[i].name,
                        icon = 'user',
                        arrow = true,
                        onSelect = function()
                            local alert = lib.alertDialog({
                                header = insidePlayers[i].name,
                                content = 'Give keys to this person?',
                                centered = true,
                                cancel = true
                            })
                            if alert == 'confirm' then
                                TriggerServerEvent('qbx_properties:server:addKeyholder', insidePlayers[i].citizenid)
                            end
                        end
                    }
                end
                lib.registerContext({
                    id = 'qbx_properties_insideMenu',
                    title = 'People Inside',
                    menu = 'qbx_properties_keyMenu',
                    options = options
                })
                lib.showContext('qbx_properties_insideMenu')
            end
        }
    }
    for i = 1, #keyholders do
        options[#options + 1] = {
            title = keyholders[i].name,
            icon = 'user',
            arrow = true,
            onSelect = function()
                local alert = lib.alertDialog({
                    header = keyholders[i].name,
                    content = 'Do you want to remove keys from this person?',
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('qbx_properties:server:removeKeyholder', keyholders[i].citizenid)
                end
            end
        }
    end
    lib.registerContext({
        id = 'qbx_properties_keyMenu',
        title = 'Keyholders',
        menu = 'qbx_properties_manageMenu',
        options = options
    })
    lib.showContext('qbx_properties_keyMenu')
end

local function prepareDoorbellMenu()
    local ringers = lib.callback.await('qbx_properties:callback:requestRingers')
    local options = {}
    for i = 1, #ringers do
        options[#options + 1] = {
            title = ringers[i].name,
            icon = 'user',
            arrow = true,
            onSelect = function()
                local alert = lib.alertDialog({
                    header = ringers[i].name,
                    content = 'Want to let this person in?',
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('qbx_properties:server:letRingerIn', ringers[i].citizenid)
                end
            end
        }
    end
    lib.registerContext({
        id = 'qbx_properties_doorbellMenu',
        title = 'Doorbell Ringers',
        menu = 'qbx_properties_manageMenu',
        options = options
    })
    lib.showContext('qbx_properties_doorbellMenu')
end

local function prepareManageMenu()
    local hasAccess = lib.callback.await('qbx_properties:callback:checkAccess')
    if not hasAccess then exports.qbx_core:Notify('No access', 'error') return end
    local options = {
        {
            title = 'Manage Keys',
            icon = 'key',
            arrow = true,
            onSelect = function()
                prepareKeyMenu()
            end
        },
        {
            title = 'Doorbell',
            icon = 'bell',
            arrow = true,
            onSelect = function()
                prepareDoorbellMenu()
            end
        },
    }
    lib.registerContext({
        id = 'qbx_properties_manageMenu',
        title = 'Manage Property',
        options = options
    })
    lib.showContext('qbx_properties_manageMenu')
end

local function checkInteractions()
    local interactOptions = {
        ['stash'] = function(coords)
            qbx.drawText3d({ coords = coords, text = '[E] - Stash' })
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('qbx_properties:server:openStash')
            end
        end,
        ['exit'] = function(coords)
            qbx.drawText3d({ coords = coords, text = '[E] - Exit | [G] - Manage' })
            if IsControlJustPressed(0, 38) then
                DoScreenFadeOut(1000)
                while not IsScreenFadedOut() do Wait(0) end
                TriggerServerEvent('qbx_properties:server:exitProperty')
            end
            if IsControlJustPressed(0, 47) then
                prepareManageMenu()
            end
        end,
        ['clothing'] = function(coords)
            qbx.drawText3d({ coords = coords, text = '[E] - Clothing | [G] - Outfits' })
            if IsControlJustPressed(0, 38) then
                exports['illenium-appearance']:startPlayerCustomization(function(appearance)
                    if appearance then
                        TriggerServerEvent("illenium-appearance:server:saveAppearance", appearance)
                    end
                end, {
                    components = true, componentConfig = { masks = true, upperBody = true, lowerBody = true, bags = true, shoes = true, scarfAndChains = true, bodyArmor = true, shirts = true, decals = true, jackets = true },
                    props = true, propConfig = { hats = true, glasses = true, ear = true, watches = true, bracelets = true },
                    enableExit = true,
                })
            end
            if IsControlJustPressed(0, 47) then
                TriggerEvent('illenium-appearance:client:openOutfitMenu')
            end
        end,
        ['logout'] = function(coords)
            qbx.drawText3d({ coords = coords, text = '[E] - Logout' })
            if IsControlJustPressed(0, 38) then
                DoScreenFadeOut(1000)
                while not IsScreenFadedOut() do Wait(0) end
                TriggerServerEvent('qbx_properties:server:logoutProperty')
            end
        end,
    }
    CreateThread(function()
        while insideProperty do
            local sleep = 800
            local playerCoords = GetEntityCoords(cache.ped)
            for i = 1, #interactions do
                if #(playerCoords - interactions[i].coords) < 1.5 then
                    sleep = 0
                    interactOptions[interactions[i].type](interactions[i].coords)
                end
            end
            Wait(sleep)
        end
    end)
end

RegisterNetEvent('qbx_properties:client:updateInteractions', function(interactionsData)
    DoScreenFadeIn(1000)
    interactions = interactionsData
    insideProperty = true
    checkInteractions()
end)

RegisterNetEvent('qbx_properties:client:createInterior', function(interiorHash, interiorCoords)
    lib.requestModel(interiorHash, 2000)
    interiorShell = CreateObjectNoOffset(interiorHash, interiorCoords.x, interiorCoords.y, interiorCoords.z, false, false, false)
    FreezeEntityPosition(interiorShell, true)
    SetModelAsNoLongerNeeded(interiorHash)
end)

RegisterNetEvent('qbx_properties:client:loadDecorations', function(decorations)
    for i = 1, #decorations do
        local decoration = decorations[i]
        lib.requestModel(decoration.model, 2000)
        decorationObjects[i] = CreateObjectNoOffset(decoration.model, decoration.coords.x, decoration.coords.y, decoration.coords.z, false, false, false)
        FreezeEntityPosition(decorationObjects[i], true)
        SetEntityHeading(decorationObjects[i], decoration.coords.w)
        SetModelAsNoLongerNeeded(decoration.model)
    end
end)

RegisterNetEvent('qbx_properties:client:unloadProperty', function()
    DoScreenFadeIn(1000)
    insideProperty = false
    if DoesEntityExist(interiorShell) then DeleteEntity(interiorShell) end
    for i = 1, #decorationObjects do
        if DoesEntityExist(decorationObjects[i]) then DeleteEntity(decorationObjects[i]) end
    end
    interiorShell = nil
    decorationObjects = {}
end)

local function singlePropertyMenu(property)
    local playerData = exports.qbx_core:GetPlayerData()
    local options = {}
    if playerData.citizenid == property.owner or lib.table.contains(json.decode(property.keyholders), playerData.citizenid) then
        options[#options + 1] = {
            title = 'Enter',
            icon = 'cog',
            arrow = true,
            onSelect = function()
                DoScreenFadeOut(1000)
                while not IsScreenFadedOut() do Wait(0) end
            end,
            serverEvent = 'qbx_properties:server:enterProperty',
            args = { id = property.id }
        }
    else
        options[#options + 1] = {
            title = 'Ring Doorbell',
            icon = 'bell',
            arrow = true,
            serverEvent = 'qbx_properties:server:ringProperty',
            args = { id = property.id }
        }
    end
    lib.registerContext({
        id = 'qbx_properties_propertyMenu',
        title = property.property_name,
        menu = 'qbx_properties_propertiesMenu',
        options = options
    })
    lib.showContext('qbx_properties_propertyMenu')
end

local function propertyMenu(propertyList, owned)
    local options = {
        {
            title = 'Retrieve Owned Properties',
            description = 'Only show properties you own',
            icon = 'bars',
            onSelect = function()
                propertyMenu(propertyList, true)
            end
        }
    }
    local playerData = exports.qbx_core:GetPlayerData()
    for i = 1, #propertyList do
        if owned and propertyList[i].owner == playerData.citizenid or lib.table.contains(json.decode(propertyList[i].keyholders), playerData.citizenid) then
            options[#options + 1] = {
                title = propertyList[i].property_name,
                icon = 'home',
                arrow = true,
                onSelect = function()
                    singlePropertyMenu(propertyList[i])
                end
            }
        elseif not owned then
            options[#options + 1] = {
                title = propertyList[i].property_name,
                icon = 'home',
                arrow = true,
                onSelect = function()
                    singlePropertyMenu(propertyList[i])
                end
            }
        end
    end
    lib.registerContext({
        id = 'qbx_properties_propertiesMenu',
        title = 'Properties',
        options = options
    })
    lib.showContext('qbx_properties_propertiesMenu')
end

function PreparePropertyMenu(propertyCoords)
    local propertyList = lib.callback.await('qbx_properties:callback:requestProperties', false, propertyCoords)
    if #propertyList == 1 then
        singlePropertyMenu(propertyList[1])
    else
        propertyMenu(propertyList)
    end
end

CreateThread(function()
    local properties = lib.callback.await('qbx_properties:callback:loadProperties')
    while true do
        local sleep = 800
        local playerCoords = GetEntityCoords(cache.ped)
        for i = 1, #properties do
            if #(playerCoords - properties[i].xyz) < 1.6 then
                sleep = 0
                qbx.drawText3d({ coords = properties[i].xyz, text = '[E] - View Property' })
                if IsControlJustPressed(0, 38) then
                    PreparePropertyMenu(properties[i])
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('qbx_properties:client:concealPlayers', function(playerIds)
    local players = GetActivePlayers()
    for i = 1, #players do NetworkConcealPlayer(players[i], false, false) end
    for i = 1, #players do
        if not lib.table.contains(playerIds, GetPlayerServerId(players[i])) then
            NetworkConcealPlayer(players[i], true, false)
        end
    end
end)

RegisterNetEvent('qbx_properties:client:revealPlayers', function()
    local players = GetActivePlayers()
    for i = 1, #players do NetworkConcealPlayer(players[i], false, false) end
end)
