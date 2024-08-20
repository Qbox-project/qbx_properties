RegisterNetEvent('qbx_properties:server:apartmentSelect', function(apartmentIndex)
    local playerSource = source --[[@as number]]
    local player = exports.qbx_core:GetPlayer(playerSource)
    if not ApartmentOptions[apartmentIndex] then return end

    local hasApartment = MySQL.single.await('SELECT * FROM properties WHERE owner = ?', {player.PlayerData.citizenid})
    if hasApartment then return end

    local interior = ApartmentOptions[apartmentIndex].interior
    local interactData = {
        {
            type = 'logout',
            coords = Interiors[interior].logout
        },
        {
            type = 'clothing',
            coords = Interiors[interior].clothing
        },
        {
            type = 'exit',
            coords = Interiors[interior].exit
        }
    }
    local stashData = {
        {
            coords = Interiors[interior].stash,
            slots = ApartmentStash.slots,
            maxWeight = ApartmentStash.maxWeight,
        }
    }

    local result = MySQL.single.await('SELECT id FROM properties ORDER BY id DESC')
    local apartmentNumber = result?.id or 0

    ::again::

    apartmentNumber += 1
    local numberExists = MySQL.single.await('SELECT * FROM properties WHERE property_name = ?', {string.format('%s %s', ApartmentOptions[apartmentIndex].label, apartmentNumber)})
    if numberExists then goto again end

    local id = MySQL.insert.await('INSERT INTO `properties` (`coords`, `property_name`, `owner`, `interior`, `interact_options`, `stash_options`) VALUES (?, ?, ?, ?, ?, ?)', {
        json.encode(ApartmentOptions[apartmentIndex].enter),
        string.format('%s %s', ApartmentOptions[apartmentIndex].label, apartmentNumber),
        player.PlayerData.citizenid,
        interior,
        json.encode(interactData),
        json.encode(stashData),
    })

    TriggerClientEvent('qbx_properties:client:addProperty', -1, ApartmentOptions[apartmentIndex].enter)
    TriggerClientEvent('qb-clothes:client:CreateFirstCharacter', playerSource)
    EnterProperty(playerSource, id, true)
end)
