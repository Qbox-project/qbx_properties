if not Config.useProperties then return end
local properties = {}
local propertiesGroups = {}

--- Create a new property
---@param data table {name: string, interior: number, furnished: boolean, garage: boolean, coords: vector4, price: number, rent: number}
---@return boolean
local function createProperty(data)
    if not data or not data.coords then return false end
    local result = MySQL.Sync.fetchAll('SELECT id FROM properties ORDER BY id DESC LIMIT 1', {})
    local id = result?[1].id + 1 or 1

    local name = id .. ' ' .. data.name
    local SQLid = exports.oxmysql.insert_async('INSERT INTO properties (name, interior, property_type, coords, price, rent, appliedtaxes, maxweight, slots) VALUES (@name, @interior, @property_type, @coords, @price, @rent, @appliedtaxes, @maxweight, @slots)', {
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
    if not SQLid then
        return false
    end
end

--- Finds the players inside properties and adds them to the playersInside table
local function findPlayersInsideProperties()
    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local InProperty = Player(v).state.inProperty
        if not InProperty then goto continue end
        DebugPrint(InProperty)
        print(InProperty.propertyid..'\n --')

        local property = properties[InProperty.propertyid]
        if property then
            property.playersInside[#property.playersInside + 1] = v
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
            owners[owner.citizenid] = owner.role or false
        end
    end

    return owners
end

--- Formats the property data
---@param PropertyData table
---@param owners table
---@return table
local function formatPropertyData(PropertyData, owners)
    local coords = json.decode(PropertyData.coords)
    return {
        name = PropertyData.name,
        interior = PropertyData.interior,
        property_type = PropertyData.property_type or 'ipl',
        decorations = PropertyData.decorations or nil,
        garage_slots = (PropertyData.garage_slots and json.decode(PropertyData.garage_slots)) or nil,
        coords = vector4(coords.x, coords.y, coords.z, coords.h),
        stash = json.decode(PropertyData.stash) or nil,
        logout = json.decode(PropertyData.logout) or nil,
        outfit = json.decode(PropertyData.outfit) or nil,
        appliedtaxes = PropertyData.appliedtaxes or nil,
        price = PropertyData.price,
        rent = PropertyData.rent,
        rent_date = PropertyData.rent_date ~= 0 and PropertyData.rent_date/1000 or false,
        owners = next(owners) and owners or false,
        playersInside = {}
    }
end

local function updatePropertiesGroups()
    for k, v in pairs(properties) do
        local propertyCoords = v.coords
        local found = false
        for _, group in pairs(propertiesGroups) do
            local calcCoords = vec3(math.floor(propertyCoords.x + 0.5), math.floor(propertyCoords.y + 0.5), math.floor(propertyCoords.z + 0.5))
            local calcGroupCoords = vec3(math.floor(group.coords.x + 0.5), math.floor(group.coords.y + 0.5), math.floor(group.coords.z + 0.5))

            if calcGroupCoords == calcCoords then
                group.properties[#group.properties + 1] = k
                found = true
                break
            end
        end
        if not found then
            propertiesGroups[#propertiesGroups + 1] = {
                name = v.name,
                coords = propertyCoords,
                properties = {k},
                propertyType = v.property_type
            }
        end
    end
end

--- Refresh the properties table on the server
function RefreshProperties()
    table.wipe(properties)

    local result = MySQL.query.await('SELECT * FROM properties', {})
    if not result then return end

    for _, v in pairs(result) do
        local owners = getPropertyOwners(v.id)
        local property = formatPropertyData(v, owners)
        properties[v.id] = property
    end

    updatePropertiesGroups()
    findPlayersInsideProperties()

    TriggerClientEvent('qbx-property:client:refreshProperties', -1)
end

-- Enter furnished property
RegisterNetEvent('qbx-property:server:enterProperty', function(propertyId)
    local source = source
    local playersToConceal = {}
    local playersInsideProperty = {}

    for k, v in pairs(properties) do
        if v.property_type == 'ipl' then
            if k == propertyId then
                for _, serverid in pairs(playersInside) do
                    playersInsideProperty[#playersInsideProperty + 1] = serverid
                end
            else
                for _, serverid in pairs(v.playersInside) do
                    playersToConceal[#playersToConceal + 1] = serverid
                end
            end
        end
    end

    TriggerClientEvent('qbx-property:client:concealPlayers', source, playersToConceal, true)
    for _, v in pairs(playersInsideProperty) do
        TriggerClientEvent('qbx-property:client:concealPlayers', v, {source}, false)
    end

    TriggerClientEvent('qbx-property:client:enterProperty', source, propertyId)
    Player(source).set('InProperty', {propertyid = propertyId})
end)

-- Enter garage
RegisterNetEvent('qbx-property:server:enterGarage', function(garageId)
    local source = source
    local playersToConceal = {}
    local playersInsideProperty = {}

    for k, v in pairs(properties) do
        if v.property_type == 'garage' then
            if k == propertyId then
                for _, serverid in pairs(playersInside) do
                    playersInsideProperty[#playersInsideProperty + 1] = serverid
                end
            else
                for _, serverid in pairs(v.playersInside) do
                    playersToConceal[#playersToConceal + 1] = serverid
                end
            end
        end
    end

    TriggerClientEvent('qbx-property:client:concealPlayers', source, playersToConceal, true)
    for _, v in pairs(playersInsideProperty) do
        TriggerClientEvent('qbx-property:client:concealPlayers', v, {source}, false)
    end

    TriggerClientEvent('qbx-property:client:enterGarage', source, propertyid)
    Player(source).set('InProperty', {propertyid = propertyid})
end)

--- Check for expired rents
function PropertiesRentCheck()
    local rentedproperties = MySQL.query.await('SELECT * FROM properties WHERE NOT rent_date = false', {})
    if not rentedproperties then return end

    for _, v in pairs(rentedproperties) do
        if v.rent_date / 1000 > os.time() or os.date("%x", v.rent_date / 1000) == os.date("%x", os.time()) then goto continue end
        MySQL.Async.execute('UPDATE properties SET rent_date = false, garage_slots = NULL WHERE id = ?', { v.id })
        MySQL.Async.execute('DELETE FROM property_owners WHERE property_id = ?', { v.id })

        local renters = MySQL.query.await('SELECT citizenid FROM property_owners WHERE property_id = ? AND role = 1', { v.id })
        if not renters then goto continue end
        for _, owner in pairs(renters) do
            TriggerEvent('qbx-phone:server:sendNewMailToOffline', owner.citizenid, {
                sender = 'Real Estate Agency',
                subject = 'Rent Expired',
                message = 'The rent of '.. v.name ..' expired.',
            })
        end
        ::continue::
    end
end

RegisterNetEvent('qbx-property:server:CreateProperty', function(PropertyData)
    if not PropertyData then return end

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local PlayerData = Player.PlayerData
    if not PlayerData.job.type == 'realestate' then return end

    if not createProperty(PropertyData) then
        QBCore.Functions.Notify(source, Lang:t('error.failed_createproperty'), 'error')
        return
    end
    TriggerClientEvent('qbx-property:client:refreshProperties', -1)
end)

RegisterNetEvent('qbx-property:server:AddProperty', function()
    local source = source
    local PlayerData = QBCore.Functions.GetPlayer(source).PlayerData
    if not PlayerData.job.type == 'realestate' then return end

    TriggerClientEvent('qbx-property:client:OpenCreationMenu', source)
end)

lib.callback.register('qbx-property:server:hasPropertyKeys', function(source, propertyId, citizenId)
    local hasKeys = properties[propertyId]?.owners?[citizenId] and true or false
    return hasKeys, isRented
end)

lib.callback.register('qbx-property:server:isPropertyRented', function(source, propertyId)
    local isRented = properties[propertyId]?.rent_date and true or false
    return isRented
end)

lib.callback.register('qbx-property:server:GetProperties', function()
    return propertiesGroups or false
end)

lib.callback.register('qbx-property:server:GetPropertyData', function(propertyId)
    return properties[propertyId] or false
end)

lib.addCommand('createproperty', {
    help = 'Create a property',
    params = {},
    restricted = false,
}, function(source)
    local PlayerData = QBCore.Functions.GetPlayer(source).PlayerData
    if not PlayerData.job.type == 'realestate' then return end
    TriggerClientEvent('qbx-property:client:OpenCreationMenu', source)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        PropertiesRentCheck()
        RefreshProperties()
    end
end)