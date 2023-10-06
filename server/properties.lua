if not Config.useProperties then return end
local properties = {}
local propertiesGroups = {}

--- Create a new property
--- @param data table {name: string, interior: number, furnished: boolean, garage: boolean, coords: vector4, price: number, rent: number}
--- @return integer | boolean propertyId
local function createProperty(data)
    if not data?.coords then return false end
    local result = MySQL.Sync.fetchAll('SELECT id FROM properties ORDER BY id DESC LIMIT 1', {})
    local id = (result?[1]?.id or 0) + 1

    local name = id .. ' ' .. data.name
    local dbResult = MySQL.Sync.insert('INSERT INTO properties (name, interior, property_type, coords, price, rent, appliedtaxes, maxweight, slots) VALUES (@name, @interior, @property_type, @coords, @price, @rent, @appliedtaxes, @maxweight, @slots)', {
        ['@name'] = name,
        ['@interior'] = data.interior,
        ['@property_type'] = data.garage and 'garage' or data.furnished and 'ipl' or 'shell',
        ['@coords'] = json.encode(data.coords),
        ['@price'] = data.price,
        ['@rent'] = data.rent,
        ['@appliedtaxes'] = json.encode(data.appliedtaxes or {}),
        ['@maxweight'] = data.maxweight or 10000,
        ['@slots'] = data.slots or 10
    })
        if not dbResult then return false end
    if not data.garage then
        exports.ox_inventory:RegisterStash("property_"..id, "property_"..id, data.slots, data.maxweight, false, false, Config.IPLS[data.interior].coords.stash.xyz)
    end
    return id
end

local function RefreshStashes()
    for propertyId, v in pairs(properties) do
        if v.property_type ~= 'garage' then
            exports.ox_inventory:RegisterStash("property_"..propertyId, "property_"..propertyId, v.slots, v.maxweight, false, false, v?.stash?.xyz or Config.IPLS[v.interior].coords.stash.xyz)
        end
    end
end

--- Calculate the price with taxes
--- @param price integer
--- @param taxes table
--- @return integer
local function calcPrice(price, taxes)
    local totaltax = Config.Properties.taxes.general
    if taxes then
        for taxname, tax in pairs(Config.Properties.taxes) do
            if taxes[taxname] then
                totaltax = totaltax + tax
            end
        end
    end
    return math.round(price + (price * (totaltax/100)))
end

--- Finds the players inside properties and adds them to the playersInside table
local function findPlayersInsideProperties()
    local Players = GetPlayers()
    for i = 1, #Players do
            local inProperty = Player(Players[i]).state.inProperty
        if not inProperty then goto continue end

        local property = properties[inProperty.propertyid]
        if property then
            property.playersInside[#property.playersInside + 1] = Players[i]
        end

        ::continue::
    end
end


--- Get the properties from the database
--- @param propertyId integer
--- @return table
local function getPropertyOwners(propertyId)
    local propertyowners = MySQL.query.await('SELECT * FROM property_owners WHERE property_id = ?', { propertyId })
    local owners = {}

    if propertyowners then
        for _, owner in pairs(propertyowners) do
            owners[owner.citizenid] = owner.role
        end
    end

    return owners
end

local function calcDaysLeft(time)
    return time and time > 0 and math.round((time/1000 - os.time()) / 86400)
end

--- Formats the property data
---@param PropertyData table
---@param owners table
---@return table
local function formatPropertyData(PropertyData, owners)
    local coords = type(PropertyData.coords) == "string" and json.decode(PropertyData.coords) or PropertyData.coords
    local stash, logout, outfit = nil, nil, nil
    if PropertyData.data then
        stash = type(PropertyData.data.stash) == "string" and json.decode(PropertyData.data.stash) or PropertyData.data.stash
        logout = type(PropertyData.data.logout) == "string" and json.decode(PropertyData.data.logout) or PropertyData.data.logout
        outfit = type(PropertyData.data.outfit) == "string" and json.decode(PropertyData.data.outfit) or PropertyData.data.outfit
    end

    return {
        name = PropertyData.name,
        interior = PropertyData.interior,
        property_type = PropertyData.property_type or 'ipl',
        decorations = PropertyData.decorations or nil,
        garage_slots = (type(PropertyData.garage_slots) == "string" and json.decode(PropertyData.garage_slots)) or nil,
        coords = vec4(coords.x, coords.y, coords.z, coords.w or 0),
        stash = stash,
        logout = logout,
        outfit = outfit,
        appliedtaxes = type(PropertyData.appliedtaxes) ~= "table" and json.decode(PropertyData.appliedtaxes) or PropertyData.appliedtaxes or {},
        price = PropertyData.price,
        rent = PropertyData.rent,
        maxweight = PropertyData.maxweight,
        slots = PropertyData.slots,
        rent_expiration = calcDaysLeft(PropertyData.rent_expiration) or false,
        options = type(PropertyData.options) == "string" and json.decode(PropertyData.options) or {},
        owners = next(owners) and owners or {},
        playersInside = {}
    }
end

local function updatePropertiesGroups()
    propertiesGroups = {}
    for id, v in pairs(properties) do
        local propertyCoords = v.coords
        local found = false
        for _, group in pairs(propertiesGroups) do
            if #(propertyCoords.xyz - group.coords.xyz) <= 1.1 then
                group.properties[id] = v.name
                found = true
                break
            end
        end
        if not found then
            propertiesGroups[#propertiesGroups + 1] = {
                coords = propertyCoords,
                properties = {},
                propertyType = v.property_type
            }
            propertiesGroups[#propertiesGroups].properties[id] = v.name
        end
    end
end

--- Refresh the properties table on the server
local function RefreshProperties()
    properties = {}
    local result = MySQL.query.await('SELECT * FROM properties', {})
    if not result then return end

    for i = 1, #result do
        local owners = getPropertyOwners(result[i].id)
        local property = formatPropertyData(result[i], owners)
        properties[result[i].id] = property
    end

    updatePropertiesGroups()
    findPlayersInsideProperties()

    TriggerClientEvent('qbx-properties:client:refreshProperties', -1)
end

-- Enter furnished property
RegisterNetEvent('qbx-properties:server:enterProperty', function(propertyId, isVisit)
    local source = source
    local playersToConceal = {}
    local playersInsideProperty = {}
    local property = properties[propertyId]
    if property.property_type ~= 'ipl' then return end -- remove when shells are implemented
    for k, v in pairs(properties) do
        if v.property_type == 'ipl' then
            if k == propertyId then
                for _, serverid in pairs(v.playersInside) do
                    playersInsideProperty[#playersInsideProperty + 1] = serverid
                end
            else
                for _, serverid in pairs(v.playersInside) do
                    playersToConceal[#playersToConceal + 1] = serverid
                end
            end
        end
    end

    if property.property_type == 'ipl' then
        TriggerClientEvent('qbx-properties:client:enterIplProperty', source, property.interior, propertyId, isVisit, property.options or false)
    else
        return -- do nothing for now
        -- TODO: shell stuff (have fun with that)
    end
    TriggerClientEvent('qbx-properties:client:concealPlayers', source, playersToConceal, true)
    TriggerClientEvent('qbx-properties:client:concealPlayers', -1, {source}, true)
    for _, v in pairs(playersInsideProperty) do
        TriggerClientEvent('qbx-properties:client:concealPlayers', v, {source}, false)
    end
    Player(source).state:set('inProperty', {propertyid = propertyId}, true)
end)

-- Enter garage
---WIP
RegisterNetEvent('qbx-properties:server:enterGarage', function(propertyId, isVisit, isInVehicle)
    if not propertyId then return end
    local property = properties[propertyId]
    if isVisit then
        if isInVehicle then
            return TriggerClientEvent('QBCore:Notify', source, Lang:t('error.inVehicle'), 'error')
        end
        TriggerClientEvent('qbx-properties:client:enterIplProperty', source, property.interior, propertyId, true, property.options or false)
        return
    end

    local playersToConceal = {}
    local playersInsideProperty = {}
    for k, v in pairs(properties) do
        if v.property_type == 'garage' then
            if k == propertyId then
                for _, serverid in pairs(v.playersInside) do
                    playersInsideProperty[#playersInsideProperty + 1] = serverid
                end
            else
                for _, serverid in pairs(v.playersInside) do
                    playersToConceal[#playersToConceal + 1] = serverid
                end
            end
        end
    end

    if isInVehicle then
        return -- Do nothing for now
        -- get the vehicle, add it to the garage and remove it from the world
        -- add it to the first available slot
    end

    TriggerClientEvent('qbx-properties:client:concealPlayers', source, playersToConceal, true)
    TriggerClientEvent('qbx-properties:client:concealPlayers', -1, {source}, true)
    for _, v in pairs(playersInsideProperty) do
        TriggerClientEvent('qbx-properties:client:concealPlayers', v, {source}, false)
    end
    TriggerClientEvent('qbx-properties:client:enterGarage', source, property.interior, propertyId, true, property.options or false)
    Player(source).state:set('inProperty', {propertyid = propertyId}, true)
end)

--- Check for expired rents
local function PropertiesRentCheck()
    local rentedproperties = MySQL.query.await('SELECT * FROM properties WHERE NOT rent_expiration = false', {})
    if not rentedproperties then return end
    for i = 1, #rentedproperties do
        if rentedproperties[i].rent_expiration / 1000 > os.time() or os.date("%x", rentedproperties[i].rent_expiration / 1000) == os.date("%x", os.time()) then goto continue end
        MySQL.update.await('UPDATE properties SET rent_expiration = NULL, garage_slots = NULL WHERE id = ?', { rentedproperties[i].id })
        MySQL.query.await('DELETE FROM property_owners WHERE property_id = ?', { rentedproperties[i].id })

        local renters = MySQL.query.await('SELECT citizenid FROM property_owners WHERE property_id = ? AND role = 1', { rentedproperties[i].id })
        if not renters then goto continue end
        for index = 1, #renters do
            TriggerEvent('qb-phone:server:sendNewMailToOffline', renters[index].citizenid, {
                sender = 'Real Estate Agency',
                subject = 'Rent Expired',
                message = 'The rent of '.. rentedproperties[i].name ..' expired.',
            })
        end
        ::continue::
    end
end

local function addPropertyToList(propertyData, propertyId)
    local property = formatPropertyData(propertyData, {})
    properties[propertyId] = property
    updatePropertiesGroups()
end

RegisterNetEvent('qbx-properties:server:CreateProperty', function(propertyData)
    if not propertyData then return end
    local source = source

    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end

    if player.PlayerData.job.type ~= 'realestate' then return end

    local propertyId = createProperty(propertyData)
    if not propertyId then
        QBCore.Functions.Notify(source, Lang:t('error.failed_createproperty'), 'error')
        return
    end

    propertyData.name = propertyId .. ' ' .. propertyData.name
    addPropertyToList(propertyData, propertyId)
    TriggerClientEvent('qbx-properties:client:refreshProperties', -1)
end)

local function hasMoney(player, amount)
    return player and (player.Functions.GetMoney('cash') >= amount and 'cash' or player.Functions.GetMoney('bank') >= amount and 'bank')
end

--- Sets the role of a player for a property
--- @param playerId integer
--- @param propertyId integer
--- @param role string
--- @return boolean
local function setRole(playerId, propertyId, role)
    if not playerId or not role or not propertyId then return false end
    local player = QBCore.Functions.GetPlayer(playerId)
    if not player then return false end
    local result = MySQL.insert.await('INSERT INTO property_owners (`property_id`, `citizenid`, `role`) VALUES (?, ?, ?)', {
        propertyId, player.PlayerData.citizenid, role
    })
    return not not result
end

--- Buys the property
---@param propertyId integer
---@param playerId integer
---@param price integer
---@return boolean | string
local function buyProperty(propertyId, playerId, price)
    local player = QBCore.Functions.GetPlayer(playerId)
    if not player then return 'error' end
    local moneyType = hasMoney(player, price)
    if not moneyType then
        QBCore.Functions.Notify(playerId, Lang:t('error.notenoughmoney'), 'error')
        return false
    end

    if not player.Functions.RemoveMoney(moneyType, price, 'Bought property') or not setRole(playerId, propertyId, "owner") then QBCore.Functions.Notify(playerId, Lang:t('error.problem'), 'error') return false end
    properties[propertyId].owners[player.PlayerData.citizenid] = 'owner'
    return true
end

RegisterNetEvent('qbx-properties:server:sellProperty', function(targetId, propertyId, comission)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    local PlayerData = player.PlayerData
    if PlayerData.job.type ~= 'realestate' then return end

    local property = properties[propertyId]
    if not property then return QBCore.Functions.Notify(source, Lang:t('error.problem'), 'error') end

    local propertyPrice = calcPrice(property.price, property.appliedtaxes)
    local priceToPay = math.round((propertyPrice * (1+(comission/100))))

    local isAccepted = lib.callback.await("qbx-properties:client:promptOffer", targetId, priceToPay, false)
    if not isAccepted then return QBCore.Functions.Notify(source, Lang:t('error.offerDenied'), 'error') end

    local hasBought = buyProperty(propertyId, targetId, priceToPay)
    if not hasBought then
        return QBCore.Functions.Notify(source, Lang:t("error.problem"), 'error', 7500)
    end
    player.Functions.AddMoney('bank', propertyPrice*(comission/100), 'Sold property')
    QBCore.Functions.Notify(targetId, Lang:t('success.boughtProperty', {price = priceToPay}), 'success')
    QBCore.Functions.Notify(source, Lang:t('success.soldProperty', {price = propertyPrice}), 'success')
end)

local function extendRent(propertyId, playerId, time)
    if not MySQL.update.await('UPDATE `properties` SET `rent_expiration` = IF(`rent_expiration` IS NULL, DATE_ADD(NOW(), INTERVAL @time DAY), DATE_ADD(`rent_expiration`, INTERVAL @time DAY)) WHERE `id` = @propertyId', { time = time, propertyId = propertyId }) then
        QBCore.Functions.Notify(playerId, Lang:t('error.problem'), 'error')
        return false
    end
    properties[propertyId].rent_expiration = (properties[propertyId].rent_expiration or -1) + Config.Properties.rentTime
    return true
end

local function rentProperty(propertyId, playerId, price, isExtend)
    local player = QBCore.Functions.GetPlayer(playerId)
    if not player then return false end
    local moneyType = hasMoney(player, price)
    if not moneyType then
        QBCore.Functions.Notify(playerId, Lang:t('error.notenoughmoney'), 'error')
        return false
    end

    if not player.Functions.RemoveMoney(moneyType, price, 'Property rent') then QBCore.Functions.Notify(playerId, Lang:t('error.problem'), 'error') return false end
    extendRent(propertyId, playerId, Config.Properties.rentTime)
    if not isExtend then
        if not setRole(playerId, propertyId, "owner") then QBCore.Functions.Notify(playerId, Lang:t('error.problem'), 'error') return false end
        properties[propertyId].owners[player.PlayerData.citizenid] = 'owner'
    end
    return true
end

RegisterNetEvent('qbx-properties:server:rentProperty', function(targetId, propertyId, isExtend)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    local PlayerData = player.PlayerData
    if PlayerData.job.type ~= 'realestate' then return end

    local property = properties[propertyId]
    if not property then return QBCore.Functions.Notify(source, Lang:t('error.problem'), 'error') end

    local rentAmount = calcPrice(property.rent, property.appliedtaxes) * Config.Properties.rentTime
    local isAccepted = lib.callback.await("qbx-properties:client:promptOffer", targetId, rentAmount, true)
    if not isAccepted then return QBCore.Functions.Notify(source, Lang:t('error.offerDenied'), 'error') end

    local hasBought = rentProperty(propertyId, targetId, rentAmount, isExtend)
    if not hasBought then
        return QBCore.Functions.Notify(source, Lang:t("error.problem"), 'error', 7500)
    end
    player.Functions.AddMoney('bank', rentAmount*(Config.Properties.realtorCommission.rent), 'Rent Commission')
    QBCore.Functions.Notify(targetId, Lang:t('success.boughtProperty', {price = rentAmount}), 'success')
    QBCore.Functions.Notify(source, Lang:t('success.soldProperty', {price = rentAmount}), 'success')
end)

RegisterNetEvent('qbx-properties:server:AddProperty', function()
    local source = source
    local PlayerData = QBCore.Functions.GetPlayer(source).PlayerData
    if PlayerData.job.type ~= 'realestate' then return end

    TriggerClientEvent('qbx-properties:client:OpenCreationMenu', source)
end)

RegisterNetEvent('qbx-properties:server:RingDoor', function(propertyId)
    -- trigger a phone notification (system) on the property owners
    -- if they accept the source gets to enter the property
    -- might be complicated with the current npwd notification system :headscratch:
    QBCore.Functions.Notify(source, "Feature incoming soon :tm:. Property: "..propertyId, "error", 5000)
end)

RegisterNetEvent('qbx-properties:server:leaveProperty', function(propertyId, isInVehicle)
    local source = source
    local property = properties[propertyId]
    local playersToConceal = {}
    if not property then return end
    local exitcoords = property.coords
    for _, v in pairs(properties) do
        for _, serverid in pairs(v.playersInside) do
            playersToConceal[#playersToConceal + 1] = serverid
        end
    end

    TriggerClientEvent('qbx-properties:client:concealPlayers', source, playersToConceal, true)
    TriggerClientEvent('qbx-properties:client:concealPlayers', -1, {source}, false)

    if not isInVehicle then
        Player(source).state:set('inProperty', false, true)
        TriggerClientEvent('qbx-properties:client:leaveProperty', source, exitcoords)
    else
        Player(source).state:set('inProperty', false, true)
        TriggerClientEvent('qbx-properties:client:leaveGarage', source, exitcoords)
    end
end)

--- Modifies the property's data in the database
---@param propertyId integer
local function modifyProperty(propertyId)
    if not propertyId then return end
    local propertyData = properties[propertyId]
    local affectedRows = MySQL.update.await('UPDATE properties SET name = @name, interior = @interior, price = @price, rent = @rent, coords = @coords, appliedtaxes = @appliedtaxes, maxweight = @maxweight, slots = @slots, options = @options WHERE id = @propertyId', {
        ['@name'] = propertyData.name,
        ['@interior'] = propertyData.interior,
        ['@coords'] = json.encode(propertyData.coords),
        ['@price'] = propertyData.price,
        ['@rent'] = propertyData.rent,
        ['@appliedtaxes'] = json.encode(propertyData.appliedtaxes or {}),
        ['@maxweight'] = propertyData.maxweight or 10000,
        ['@slots'] = propertyData.slots or 10,
        ['@options'] = json.encode(propertyData.options or {}),
        ['@propertyId'] = propertyId
    })
    if not affectedRows then return end
    RefreshProperties()
    exports.ox_inventory:RegisterStash("property_"..propertyId, "property_"..propertyId, propertyData.slots, propertyData.maxweight, false, false, Config.IPLS[propertyData.interior].coords.stash.xyz)
end

--- Modifies the property's data
---@param propertyId integer
---@param newData table
RegisterNetEvent('qbx-properties:server:modifyProperty', function(propertyId, newData)
    if not propertyId or not newData then return end
    for k, v in pairs(newData) do
        properties[propertyId][k] = v
    end
    modifyProperty(propertyId)
end)

lib.callback.register('qbx-properties:server:GetOwnedOrRentedProperties', function(source)
    local citizenid = QBCore.Functions.GetPlayer(source).PlayerData.citizenid
    local hasKeys = MySQL.query.await('SELECT property_id FROM property_owners WHERE citizenid = ?', { citizenid })
    if not hasKeys or not properties then return end
    local propertyList = {}
    for i = 1, #hasKeys do
        propertyList[hasKeys[i].property_id] = {
            isRented = not not properties[hasKeys[i].property_id]?.rent_expiration,
        }
    end
    return propertyList
end)

lib.callback.register('qbx-properties:server:GetProperties', function()
    return propertiesGroups
end)

lib.callback.register('qbx-properties:server:GetPropertyData', function(_, propertyId)
    local data = properties[propertyId]
    if not data then return false end
    data.id = propertyId
    return data
end)

lib.callback.register('qbx-properties:server:GetCustomZones', function(_, propertyId)
    local property = properties[propertyId]
    if not property then return false end
    local zones = {
        wardrobe = property.stash,
        stash = property.stash,
        logout = property.logout,
    }
    return zones or {}
end)

lib.addCommand('createproperty', {
    help = 'Create a property',
    params = {},
    restricted = false,
}, function(source)
    local PlayerData = QBCore.Functions.GetPlayer(source).PlayerData
    if PlayerData.job.type ~= 'realestate' then return end
    TriggerClientEvent('qbx-properties:client:OpenCreationMenu', source)
end)

AddEventHandler('onServerResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        PropertiesRentCheck()
        RefreshProperties()
        RefreshStashes()
    end
end)