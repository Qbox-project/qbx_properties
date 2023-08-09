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
    exports.oxmysql:insert('INSERT INTO properties (name, interior, furnished, garage, coords, price, rent) VALUES (@name, @interior, @furnished, @garage, @coords, @price, @rent)', {
        ['@name'] = name,
        ['@interior'] = data.interior,
        ['@furnished'] = data.furnished or false,
        ['@garage'] = data.garage or false,
        ['@coords'] = json.encode(data.coords),
        ['@price'] = data.price,
        ['@rent'] = data.rent,
    })
end

local function fillInsideTable()
    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local InProperty = Player(v).state.inProperty
        if not InProperty then goto continue end
        print('fillInsideTable')
        DebugPrint(InProperty)
        print(InProperty.propertyid..'\n --')

        local property = properties[InProperty.propertyid]
        if property then
            property.inside[#property.inside + 1] = v
        end

        ::continue::
    end
end

--- Refresh the properties table on the server
function RefreshProperties()
    table.wipe(properties)

    local result = MySQL.query.await('SELECT * FROM properties', {})
    if not result then return end

    for _, v in pairs(result) do
        local propertyowners = MySQL.query.await('SELECT * FROM property_owners WHERE property_id = ?', { v.id })
        local owners = {}

        if propertyowners then
            for _, owner in pairs(propertyowners) do
                owners[owner.citizenid] = (owner.owner and 'owner') or (owner.co_owner and 'co_owner') or
                (owner.tenant and 'tenant') or false
            end
        end

        v.coords = json.decode(v.coords)
        properties[v.id] = {
            name = v.name,
            interior = v.interior,
            furnished = v.furnished or false,
            decorations = v.decorations or nil,
            garage = v.garage or false,
            garage_slots = (v.garage_slots and json.decode(v.garage_slots)) or nil,
            coords = vector4(v.coords.x, v.coords.y, v.coords.z, v.coords.h),
            stash = v.stash or nil,
            logout = v.logout or nil,
            outfit = v.outfit or nil,
            price = v.price,
            rent = v.rent,
            rent_date = v.rent_date ~= 0 and v.rent_date/1000 or false,
            owners = next(owners) and owners or false,
            inside = {}
        }
    end

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
                propertyType = v.garage and 'garage' or 'property'
            }
        end
    end

    fillInsideTable()

    TriggerClientEvent('qbx-property:client:refreshProperties', -1)
end

-- Enter furnished property
RegisterNetEvent('qbx-property:server:enterProperty', function(propertyid)
    local source = source
    local concealedPlayers = {}
    local PlayersInside = {}

    for k, v in pairs(properties) do
        if v.garage or not v.furnished then goto continue end
        if k == propertyid then
            for _, serverid in pairs(v.inside) do
                PlayersInside[#PlayersInside + 1] = serverid
            end
            goto continue
        end
        for _, serverid in pairs(v.inside) do
            concealedPlayers[#concealedPlayers + 1] = serverid
        end
        ::continue::
    end

    TriggerClientEvent('qbx-property:client:concealPlayers', source, concealedPlayers, true)
    for _, v in pairs(PlayersInside) do
        TriggerClientEvent('qbx-property:client:concealPlayers', v, {source}, false)
    end

    TriggerClientEvent('qbx-property:client:enterProperty', source, propertyid)
    Player(source).set('InProperty', {propertyid = propertyid})
end)

-- Enter garage
RegisterNetEvent('qbx-property:server:enterGarage', function(garageId)
    local source = source
    local concealedPlayers = {}

    for k, v in pairs(properties) do
        if not v.garage then goto continue end
        if k == garageId then goto continue end
        for _, serverid in pairs(v.inside) do
            concealedPlayers[#concealedPlayers + 1] = serverid
        end
        ::continue::
    end

    TriggerClientEvent('qbx-property:client:concealPlayers', source, concealedPlayers, true)
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

        local renters = MySQL.query.await('SELECT citizenid FROM property_owners WHERE property_id = ? AND owner = 1', { v.id })
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

    createProperty(PropertyData)
    TriggerClientEvent('qbx-property:client:refreshProperties', -1)
end)

RegisterNetEvent('qbx-property:server:AddProperty', function()
    local source = source
    local PlayerData = QBCore.Functions.GetPlayer(source).PlayerData
    if not PlayerData.job.type == 'realestate' then return end

    TriggerClientEvent('qbx-property:client:OpenCreationMenu', source)
end)

lib.callback.register('qbx-property:server:IsOwner', function(source, propertyId, citizenId)
    local isOwner = properties[propertyId]?.owners?[citizenId] and true or false
    local isRented = properties[propertyId]?.rent_date and true or false
    return isOwner, isRented
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