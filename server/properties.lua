if not Config.useProperties then return end
local properties = {}
local propertiesGroups = {}

--- Create a new property
--- @param data table {name: string, interior: number, furnished: boolean, garage: boolean, coords: vector4, price: number, rent: number}
--- @return integer | boolean propertyId
local function createProperty(data)
    if not data or not data.coords then return false end
    local result = MySQL.Sync.fetchAll('SELECT id FROM properties ORDER BY id DESC LIMIT 1', {})
    local id = (result?[1]?.id or 0) + 1

    local name = id .. ' ' .. data.name
    exports.oxmysql:insert('INSERT INTO properties (name, interior, property_type, coords, price, rent, appliedtaxes, maxweight, slots) VALUES (@name, @interior, @property_type, @coords, @price, @rent, @appliedtaxes, @maxweight, @slots)', {
        ['@name'] = name,
        ['@interior'] = data.interior,
        ['@property_type'] = data.garage and 'garage' or data.furnished and 'ipl' or 'shell',
        ['@coords'] = json.encode(data.coords),
        ['@price'] = data.price,
        ['@rent'] = data.rent,
        ['@appliedtaxes'] = json.encode(data.appliedtaxes or {}),
        ['@maxweight'] = data.maxweight or 10000,
        ['@slots'] = data.slots or 10
    }, function(result)
        if not result then return false end
    end)
    return id
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
    return math.floor(price + (price * (totaltax/100)))
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

local function calcDaysLeft(time)
    --[[ calc days left ]]
    return time and time > 0 and math.floor((time/1000 - os.time()) / 86400) or false
end

--- Formats the property data
---@param PropertyData table
---@param owners table
---@return table
local function formatPropertyData(PropertyData, owners)
    local coords = type(PropertyData.coords) == "string" and json.decode(PropertyData.coords) or PropertyData.coords
    return {
        name = PropertyData.name,
        interior = PropertyData.interior,
        property_type = PropertyData.property_type or 'ipl',
        decorations = PropertyData.decorations or nil,
        garage_slots = (type(PropertyData.garage_slots) == "string" and json.decode(PropertyData.garage_slots)) or nil,
        coords = vector4(coords.x, coords.y, coords.z, coords.h),
        stash = type(PropertyData.stash) == "string" and json.decode(PropertyData.stash),
        logout = type(PropertyData.logout) == "string" and json.decode(PropertyData.logout) or nil,
        outfit = type(PropertyData.outfit) == "string" and json.decode(PropertyData.outfit) or nil,
        appliedtaxes = PropertyData.appliedtaxes or {},
        price = PropertyData.price,
        rent = PropertyData.rent,
        rent_expiration = calcDaysLeft(PropertyData.rent_expiration) or false,
        owners = next(owners) and owners or {},
        playersInside = {}
    }
end

local function updatePropertiesGroups()
    propertiesGroups = {}
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
local function RefreshProperties()
    properties = {}
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
local function PropertiesRentCheck()
    local rentedproperties = MySQL.query.await('SELECT * FROM properties WHERE NOT rent_expiration = false', {})
    if not rentedproperties then return end

    for _, v in pairs(rentedproperties) do
        if v.rent_expiration / 1000 > os.time() or os.date("%x", v.rent_expiration / 1000) == os.date("%x", os.time()) then goto continue end
        MySQL.Async.execute('UPDATE properties SET rent_expiration = NULL, garage_slots = NULL WHERE id = ?', { v.id })
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

local function addPropertyToList(propertyData, propertyId)
    local property = formatPropertyData(propertyData, {})
    properties[propertyId] = property
    updatePropertiesGroups()
end

RegisterNetEvent('qbx-property:server:CreateProperty', function(propertyData)
    if not propertyData then return end
    local source = source

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local PlayerData = Player.PlayerData
    if not PlayerData.job.type == 'realestate' then return end

    local propertyId = createProperty(propertyData)
    if not propertyId then
        QBCore.Functions.Notify(source, Lang:t('error.failed_createproperty'), 'error')
        return
    end

    addPropertyToList(propertyData, propertyId)
    TriggerClientEvent('qbx-property:client:refreshProperties', -1)
end)

RegisterNetEvent('qbx-property:server:AddProperty', function()
    local source = source
    local PlayerData = QBCore.Functions.GetPlayer(source).PlayerData
    if not PlayerData.job.type == 'realestate' then return end

    TriggerClientEvent('qbx-property:client:OpenCreationMenu', source)
end)

lib.callback.register('qbx-property:server:GetOwnedOrRentedProperties', function(source)
    local citizenid = QBCore.Functions.GetPlayer(source).PlayerData.citizenid
    local hasKeys = MySQL.query.await('SELECT property_id FROM property_owners WHERE citizenid = ?', { citizenid })
    if not hasKeys then return end
    local propertyList = {}
    for _, v in pairs(hasKeys) do
        propertyList[v.property_id] = {
            isRented = properties[v.property_id].rent_expiration and true or false,
        }
    end
    return propertyList
end)

lib.callback.register('qbx-property:server:GetProperties', function()
    return propertiesGroups or false
end)

lib.callback.register('qbx-property:server:GetPropertyData', function(source, propertyId)
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