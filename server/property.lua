local enteredProperty = {}
local insideProperty = {}
local citizenid = {}
local ring = {}

local function calculateOffsetCoords(propertyCoords, offset)
    return vector3(propertyCoords.x + offset.x, propertyCoords.y + offset.y, (propertyCoords.z - ShellUndergroundOffset) + offset.z)
end

function EnterProperty(playerSource, id)
    local property = MySQL.single.await('SELECT * FROM properties WHERE id = ?', {id})
    local propertyCoords = json.decode(property.coords)
    propertyCoords = vector3(propertyCoords.x, propertyCoords.y, propertyCoords.z)
    local playerCoords = GetEntityCoords(GetPlayerPed(playerSource))

    if #(playerCoords - propertyCoords) > 8.0 then return end

    local player = exports.qbx_core:GetPlayer(playerSource)
    citizenid[playerSource] = player.PlayerData.citizenid

    local interactions = {}
    local isInteriorShell = tonumber(property.interior) ~= nil
    local stashes = json.decode(property.stash_options)
    for i = 1, #stashes do
        local stashCoords = isInteriorShell and calculateOffsetCoords(propertyCoords, stashes[i].coords) or stashes[i].coords
        interactions[#interactions+1] = {
            type = 'stash',
            coords = vector3(stashCoords.x, stashCoords.y, stashCoords.z)
        }
        exports.ox_inventory:RegisterStash(string.format('qbx_properties_%s', property.property_name), string.format('Property: %s', property.property_name), stashes[i].slots, stashes[i].maxWeight, property.owner)
    end

    if isInteriorShell then
        TriggerClientEvent('qbx_properties:client:createInterior', playerSource, tonumber(property.interior), vector3(propertyCoords.x, propertyCoords.y, propertyCoords.z - ShellUndergroundOffset))
    end

    local interactData = json.decode(property.interact_options)
    for i = 1, #interactData do
        local coords = isInteriorShell and calculateOffsetCoords(propertyCoords, interactData[i].coords) or interactData[i].coords
        interactions[#interactions+1] = {
            type = interactData[i].type,
            coords = vector3(coords.x, coords.y, coords.z)
        }
        if interactData[i].type == 'exit' then
            SetEntityCoords(GetPlayerPed(playerSource), coords.x, coords.y, coords.z, false, false, false, false)
        end
    end

    local decorations = json.decode(property.decorations)
    for i = 1, #decorations do
        decorations[i].coords = calculateOffsetCoords(propertyCoords, decorations[i].coords) or vector3(decorations[i].coords.x, decorations[i].coords.y, decorations[i].coords.z)
    end
    TriggerClientEvent('qbx_properties:client:loadDecorations', playerSource, decorations)

    enteredProperty[playerSource] = id
    insideProperty[id] = insideProperty[id] or {}
    insideProperty[id][#insideProperty[id] + 1] = playerSource
    for i = 1, #insideProperty[id] do
        TriggerClientEvent('qbx_properties:client:concealPlayers', insideProperty[id][i], insideProperty[id])
    end

    TriggerClientEvent('qbx_properties:client:updateInteractions', playerSource, interactions)
end

RegisterNetEvent('qbx_properties:server:exitProperty', function()
    local playerSource = source --[[@as number]]
    if not enteredProperty[playerSource] then return end

    TriggerClientEvent('qbx_properties:client:unloadProperty', playerSource)
    TriggerClientEvent('qbx_properties:client:revealPlayers', playerSource)

    local enterCoords = json.decode(MySQL.single.await('SELECT coords FROM properties WHERE id = ?', {enteredProperty[source]}).coords)
    SetEntityCoords(GetPlayerPed(playerSource), enterCoords.x, enterCoords.y, enterCoords.z, false, false, false, false)
    for i = 1, #insideProperty[enteredProperty[playerSource]] do
        if insideProperty[enteredProperty[playerSource]][i] == playerSource then
            table.remove(insideProperty[enteredProperty[playerSource]], i)
            break
        end
    end
    for i = 1, #insideProperty[enteredProperty[playerSource]] do
        TriggerClientEvent('qbx_properties:client:concealPlayers', insideProperty[enteredProperty[playerSource]][i], insideProperty[enteredProperty[playerSource]])
    end
    enteredProperty[playerSource] = nil
end)

lib.callback.register('qbx_properties:callback:loadProperties', function()
    local result = MySQL.query.await('SELECT coords FROM properties GROUP BY coords')
    local properties = {}
    for i = 1, #result do
        local coords = json.decode(result[i].coords)
        properties[i] = vector3(coords.x, coords.y, coords.z)
    end
    return properties
end)

lib.callback.register('qbx_properties:callback:requestProperties', function(_, propertyCoords)
    return MySQL.query.await('SELECT property_name, owner, id, keyholders FROM properties WHERE coords = ?', {json.encode(propertyCoords)})
end)

local function hasAccess(citizenid, propertyId)
    local property = MySQL.single.await('SELECT owner, keyholders FROM properties WHERE id = ?', {propertyId})
    if citizenid == property.owner then return true end
    local keyholders = json.decode(property.keyholders)
    for i = 1, #keyholders do
        if citizenid == keyholders[i] then return true end
    end
    return false
end

RegisterNetEvent('qbx_properties:server:enterProperty', function(data)
    local playerSource = source --[[@as number]]
    local player = exports.qbx_core:GetPlayer(playerSource)
    local propertyId = data.id

    if not hasAccess(player.PlayerData.citizenid, propertyId) then return end

    EnterProperty(playerSource, propertyId)
end)

RegisterNetEvent('qbx_properties:server:ringProperty', function(data)
    local playerSource = source --[[@as number]]
    local propertyId = data.id
    local property = MySQL.single.await('SELECT owner FROM properties WHERE id = ?', {propertyId})
    local owner = exports.qbx_core:GetPlayerByCitizenId(property.owner)

    ring[propertyId] = ring[propertyId] or {}
    if not lib.table.contains(ring[propertyId], playerSource) then
        ring[propertyId][#ring[propertyId] + 1] = playerSource
        SetTimeout(300000, function()
            for i = 1, #ring[propertyId] do
                if ring[propertyId][i] == playerSource then
                    table.remove(ring[propertyId], i)
                    break
                end
            end
        end)
    end
    if owner and enteredProperty[owner.PlayerData.source] == propertyId then
        exports.qbx_core:Notify(owner.PlayerData.source, locale('notify.someone_at_door'))
    end
end)

lib.callback.register('qbx_properties:callback:requestKeyHolders', function(source)
    local propertyId = enteredProperty[source]
    local result = MySQL.single.await('SELECT owner, keyholders FROM properties WHERE id = ?', {propertyId})
    local player = exports.qbx_core:GetPlayer(source)

    if player.PlayerData.citizenid ~= result.owner then return end

    local keyholders = json.decode(result.keyholders)
    local currentholders = {}
    for i = 1, #keyholders do
        local offlinePlayer = exports.qbx_core:GetOfflinePlayer(keyholders[i])
        if offlinePlayer then
            currentholders[#currentholders + 1] = {
                citizenid = offlinePlayer.PlayerData.citizenid,
                name = offlinePlayer.PlayerData.charinfo.firstname .. ' ' .. offlinePlayer.PlayerData.charinfo.lastname
            }
        end
    end
    return currentholders
end)

lib.callback.register('qbx_properties:callback:requestPotentialKeyholders', function(source)
    local propertyId = enteredProperty[source]
    local result = MySQL.single.await('SELECT owner FROM properties WHERE id = ?', {propertyId})
    local owner = exports.qbx_core:GetPlayer(source)

    if owner.PlayerData.citizenid ~= result.owner then return end

    local players = insideProperty[propertyId]
    local insidePlayers = {}
    for i = 1, #players do
        local player = exports.qbx_core:GetPlayer(players[i])
        if player and not hasAccess(player.PlayerData.citizenid, propertyId) then
            insidePlayers[#insidePlayers + 1] = {
                citizenid = player.PlayerData.citizenid,
                name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
            }
        end
    end
    return insidePlayers
end)

lib.callback.register('qbx_properties:callback:requestRingers', function(source)
    local propertyId = enteredProperty[source]
    local players = ring[propertyId] or {}
    local ringers = {}
    for i = 1, #players do
        local player = exports.qbx_core:GetPlayer(players[i])
        if player then
            ringers[#ringers + 1] = {
                citizenid = player.PlayerData.citizenid,
                name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
            }
        end
    end
    return ringers
end)

lib.callback.register('qbx_properties:callback:checkAccess', function(source)
    local propertyId = enteredProperty[source]
    local result = MySQL.single.await('SELECT owner FROM properties WHERE id = ?', {propertyId})
    return result.owner == exports.qbx_core:GetPlayer(source).PlayerData.citizenid
end)

RegisterNetEvent('qbx_properties:server:letRingerIn', function(visitorCid)
    local playerSource = source --[[@as number]]
    local player = exports.qbx_core:GetPlayer(playerSource)
    local propertyId = enteredProperty[playerSource]
    local result = MySQL.single.await('SELECT owner, interior FROM properties WHERE id = ?', {propertyId})

    if player.PlayerData.citizenid ~= result.owner then return end

    local visitor = exports.qbx_core:GetPlayerByCitizenId(visitorCid)
    if not visitor then return end

    EnterProperty(visitor.PlayerData.source, propertyId)
    for i = 1, #ring[propertyId] do
        if ring[propertyId][i] == visitor.PlayerData.source then
            table.remove(ring[propertyId], i)
            break
        end
    end
end)

RegisterNetEvent('qbx_properties:server:addKeyholder', function(keyholderCid)
    local playerSource = source --[[@as number]]
    local owner = exports.qbx_core:GetPlayer(playerSource)
    local propertyId = enteredProperty[playerSource]
    local result = MySQL.single.await('SELECT owner, keyholders FROM properties WHERE id = ?', {propertyId})

    if owner.PlayerData.citizenid ~= result.owner then return end

    local keyholders = json.decode(result.keyholders)
    if lib.table.contains(keyholders, keyholderCid) then return end
    keyholders[#keyholders + 1] = keyholderCid
    MySQL.Sync.execute('UPDATE properties SET keyholders = ? WHERE id = ?', {json.encode(keyholders), propertyId})
    local keyholder = exports.qbx_core:GetPlayerByCitizenId(keyholderCid)
    exports.qbx_core:Notify(playerSource, keyholder.PlayerData.charinfo.firstname.. locale('notify.keyholder'))
    exports.qbx_core:Notify(keyholder.PlayerData.source, locale('notify.added_as_keyholder'))
end)

RegisterNetEvent('qbx_properties:server:removeKeyholder', function(keyholderCid)
    local playerSource = source --[[@as number]]
    local owner = exports.qbx_core:GetPlayer(playerSource)
    local propertyId = enteredProperty[playerSource]

    local result = MySQL.single.await('SELECT owner, keyholders FROM properties WHERE id = ?', {propertyId})

    if owner.PlayerData.citizenid ~= result.owner then return end

    local keyholders = json.decode(result.keyholders)
    if not lib.table.contains(keyholders, keyholderCid) then return end
    for i = 1, #keyholders do
        if keyholders[i] == keyholderCid then
            table.remove(keyholders, i)
            break
        end
    end
    MySQL.Sync.execute('UPDATE properties SET keyholders = ? WHERE id = ?', {json.encode(keyholders), propertyId})
    local keyholder = exports.qbx_core:GetOfflinePlayer(keyholderCid)
    exports.qbx_core:Notify(playerSource, keyholder.PlayerData.charinfo.firstname.. locale('notify.removed_as_keyholder'))
end)

RegisterNetEvent('qbx_properties:server:logoutProperty', function()
    local playerSource = source --[[@as number]]
    local propertyId = enteredProperty[playerSource]

    if not propertyId then return end

    local result = MySQL.single.await('SELECT owner, coords FROM properties WHERE id = ?', {propertyId})
    local player = exports.qbx_core:GetPlayer(playerSource)

    if player.PlayerData.citizenid ~= result.owner then return end

    TriggerClientEvent('qbx_properties:client:unloadProperty', playerSource)
    TriggerClientEvent('qbx_properties:client:revealPlayers', playerSource)
    for i = 1, #insideProperty[enteredProperty[playerSource]] do
        if insideProperty[enteredProperty[playerSource]][i] == playerSource then
            table.remove(insideProperty[enteredProperty[playerSource]], i)
            break
        end
    end
    for i = 1, #insideProperty[enteredProperty[playerSource]] do
        TriggerClientEvent('qbx_properties:client:concealPlayers', insideProperty[enteredProperty[playerSource]][i], insideProperty[enteredProperty[playerSource]])
    end
    enteredProperty[playerSource] = nil
    exports.qbx_core:Logout(playerSource)
    Wait(50)
    local coords = json.decode(result.coords)
    MySQL.update('UPDATE players SET position = ? WHERE citizenid = ?', { json.encode(vector4(coords.x, coords.y, coords.z, 0.0)), player.PlayerData.citizenid })
end)

RegisterNetEvent('qbx_properties:server:openStash', function()
    local playerSource = source --[[@as number]]
    local propertyId = enteredProperty[playerSource]
    local player = exports.qbx_core:GetPlayer(playerSource)

    if not hasAccess(player.PlayerData.citizenid, propertyId) then return end

    local property = MySQL.single.await('SELECT property_name FROM properties WHERE id = ?', {propertyId})
    exports.ox_inventory:forceOpenInventory(playerSource, 'stash', { id = string.format('qbx_properties_%s', property.property_name) })
end)

AddEventHandler('playerDropped', function ()
    local playerSource = source --[[@as number]]

    if not enteredProperty[playerSource] then return end

    for i = 1, #insideProperty[enteredProperty[playerSource]] do
        if insideProperty[enteredProperty[playerSource]][i] == playerSource then
            table.remove(insideProperty[enteredProperty[playerSource]], i)
            break
        end
    end
    Wait(50)
    local coords = json.decode(MySQL.single.await('SELECT coords FROM properties WHERE id = ?', {enteredProperty[playerSource]}).coords)
    MySQL.update('UPDATE players SET position = ? WHERE citizenid = ?', { json.encode(vector4(coords.x, coords.y, coords.z, 0.0)), citizenid[playerSource] })
end)
