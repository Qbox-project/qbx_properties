local PropertyZones = {}
local InteriorZones = {}
local isInZone = false

local function createPropertyInteriorZones(IPL, customZones)
    --[[   coords = {
            entrance = vector4(-271.87, -940.34, 92.51, 70),
            wardrobe = vector4(-277.79, -960.54, 86.31, 70),
            stash = vector4(-272.98, -950.01, 92.52, 70),
            logout = vector3(-283.27, -959.68, 70),
        }
     ]]
    InteriorZones[#InteriorZones+1] = lib.points.new({
        coords = customZones.entrance.xyz or IPL.coords.entrance.xyz,
        distance = 15,
    })

    InteriorZones[#InteriorZones+1] = lib.points.new({
        coords = customZones.wardrobe.xyz or IPL.coords.wardrobe.xyz,
        distance = 15,
    })

    InteriorZones[#InteriorZones+1] = lib.points.new({
        coords = customZones.stash.xyz or IPL.coords.stash.xyz,
        distance = 15,
    })

    InteriorZones[#InteriorZones+1] = lib.points.new({
        coords = customZones.logout.xyz or IPL.coords.logout.xyz,
        distance = 15,
    })
end

local function populatePropertiesMenu(ids, propertyType)
    if not ids then return end
    local options = {}

    for _, v in pairs(ids) do
        local propertyData = lib.callback.await('qbx-property:server:GetPropertyData', false, v)
        if not propertyData then goto continue end
        options[#options+1] = {
            label = propertyData.name,
            propertyType = propertyType,
            args = propertyData,
            isCheck = false,
            isScroll = false,
        }
        ::continue::
    end

    lib.registerMenu({
        id = 'properties_menu',
        title = 'Property List',
        position = 'top-left',
        onSelected = function(selected, secondary, args)
            if not secondary then
                print("Normal button")
            else
                if args.isCheck then
                    print("Check button")
                end

                if args.isScroll then
                    print("Scroll button")
                end
            end
        end,
        options = options
    }, function(selected, scrollIndex, args)
        print(selected, scrollIndex, args)
    end)
end

local function createPropertiesZones()
    local propertiesGroups = lib.callback.await('qbx-property:server:GetProperties', false)
    if not propertiesGroups then return end

    local Markercolor = Config.Properties.Marker.color
    local MarkerScale = Config.Properties.Marker.scale
    for k, v in pairs(propertiesGroups) do
        print(string.format('ID: %s, Coords: %s, Type: %s', tostring(v.properties[1]), tostring(v.coords), tostring(v.propertyType)))
        local zone = lib.points.new({
            coords = v.coords.xyz,
            heading = v.coords.h,
            distance = 15,
            reset = false,
            propertyIds = v.properties,
            propertyType = v.propertyType
        })

        function zone:nearby()
            if self.reset then self.remove() return end
            if not self.currentDistance then return end
            DrawMarker(Config.Properties.Marker.type,
            self.coords.x, self.coords.y, self.coords.z + Config.Properties.Marker.offsetZ, -- coords
            0.0, 0.0, 0.0, -- direction?
            0.0, 0.0, 0.0, -- rotation
            MarkerScale.x, MarkerScale.y, MarkerScale.z, -- scale
            Markercolor.r, Markercolor.g, Markercolor.b, Markercolor.a, -- color RBGA
            false, true, 2, false, nil, nil, false)

            if self.currentDistance < 1 and not lib.getOpenMenu() then
                SetTextComponentFormat("STRING")
                AddTextComponentString(Lang:t('properties_menu.showmenuhelp', {propertyType = Lang:t('properties_menu.'..self.propertyType)}))
                DisplayHelpTextFromStringLabel(0, 0, 1, 20000)
                isInZone = true
                if IsControlJustPressed(0, 38) then
                    populatePropertiesMenu(self.propertyIds, self.propertyType)
                    --lib.showMenu('properties_menu')
                end
            end
        end
        PropertyZones[k] = zone

        local PlayerData = QBCore.Functions.GetPlayerData() or {}
        for _, value in pairs(v.properties) do
            local isOwner, isRented = lib.callback.await('qbx-property:server:IsOwner', false, value, PlayerData.citizenid)
            if isOwner then
                local Status = (v.propertyType == 'garage' and 'Garage') or (isRented and 'Rent') or 'Owned'
                AddBlip(false, k, v.coords, Config.Properties.Blip[Status].sprite, Config.Properties.Blip[Status].color, Config.Properties.Blip[Status].scale, v.name)
            end
        end
    end
end

local function clearProperties()
    for _, v in pairs(PropertyZones) do
        v.reset = true
    end
    table.wipe(PropertyZones)
end

RegisterNetEvent('qbx-property:client:refreshProperties', function()
    print('refreshProperties')
    clearProperties()
    createPropertiesZones()
end)

local function CreatePropertiesList(Garage, Furnished)
    local options = {}
    for k,v in pairs((Garage and Config.GarageIPLs) or (Furnished and Config.IPLS) or Config.Shells) do
        options[#options+1] = {}
        options[#options].label = Garage and (k .. " (" .. #v.coords.slots .. ' Slots)') or nil -- Lang:t('', {slots = #v.slots})
        options[#options].value = k
    end
    return options
end

local function CreateProperty(Data)
    local totalprice = Data.price + (Data.price * ((Config.Taxes.General + (Data.garden and Config.Taxes.Garden or 0) + (Data.pool and Config.Taxes.Pool or 0)) / 100)) or Config.MinimumPrice
    local totalrent = (Data.rent and Data.rent + (Data.rent * ((Config.Taxes.General + (Data.garden and Config.Taxes.Garden or 0) + (Data.pool and Config.Taxes.Pool or 0)) / 100))) or false
    local StorageWeight = Data.weight and Data.weight * 1000 or false
    Data.price, totalrent, StorageWeight = totalprice, totalrent, StorageWeight

    TriggerServerEvent('qbx-property:server:CreateProperty', Data)
end

RegisterNetEvent('qbx-property:client:OpenCreationMenu', function()
    if isInZone then
        TriggerClientEvent('QBCore:Notify', source, text, type, length)
        return
    end
    local GeneralOptions = lib.inputDialog('Property Creator', {
        {type = 'input', label = 'Name', description = 'Name the Property (Optional)', placeholder = 'Vinewood Villa'},
        {type = 'number', label = 'Price', required = true, icon = 'dollar-sign', default = 1000, min = Config.MinimumPrice},
        {type = 'number', label = 'Rent Price', required = true, description = 'Rent price for 7 days', icon = 'dollar-sign', default = 100, placeholder = "69"},
        {type = 'checkbox', label = 'Garage?', checked = false},
        {type = 'checkbox', label = 'Furnished? (Not For Garages!)', checked = true},
    }, {allowCancel = true})
    if not GeneralOptions then return end
    if GeneralOptions[1] == '' then GeneralOptions[1] = nil end

    local PropertyOptions = {
        {type = 'select', clearable = false, label = "Interior", options = CreatePropertiesList(GeneralOptions[4], GeneralOptions[5])}
    }
    if not GeneralOptions[4] then
        PropertyOptions[2] = {type = 'number', label = "Storage Volume", description = "Size of the storage (Kg)", default = 50, min = 1}
        PropertyOptions[3] = {type = 'number', label = "Storage Size", description = "Number of slots the Storage has", default = 10, min = 1}
        if Config.GardenAndPoolTaxes then
            PropertyOptions[4] = {type = 'checkbox', label = "Garden?", description = "Adds a tax if the property has a pool", checked = false}
            PropertyOptions[5] = {type = 'checkbox', label = "Pool?", description = "Adds a tax if the property has a pool", checked = false}
        end
    end

    local PropertyCreation = lib.inputDialog('Property Creator', PropertyOptions, {allowCancel = true})
    if not PropertyCreation then return end
    if not PropertyCreation[1] then
        TriggerEvent('QBCore:Notify', 'You need to select an interior!', 'error')
        return
    end
    local coords = GetEntityCoords(cache.ped)
    local Result = {
        name = GeneralOptions[1] or GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z)),
        price = GeneralOptions[2],
        rent = GeneralOptions[3],
        garage = GeneralOptions[4] or nil,
        furnished = GeneralOptions[4] and nil or GeneralOptions[5],
        interior = PropertyCreation[1],
        weight = PropertyCreation[2] or nil,
        slots = PropertyCreation[3] or nil,
        garden = PropertyCreation[4] or nil,
        pool = PropertyCreation[5] or nil,
        coords = {x = coords.x, y = coords.y, z = coords.z, h = GetEntityHeading(cache.ped)},
    }
    CreateProperty(Result)
end)

RegisterNetEvent('qbx-property:client:enterProperty', function(coords, propertyid)

end)

RegisterNetEvent('qbx-property:client:LeaveProperty', function(coords)
    if not coords then return end
    InteriorZones = nil
    DoScreenFadeOut(500)
    Wait(250)
    SetEntityCoords(cache.ped, coords.xyz, 0.0, 0.0, false, false, false, false)
    SetEntityHeading(cache.ped, coords.h or coords.w)
    DoScreenFadeIn(500)
end)

CreateThread(function()
    createPropertiesZones()
end)
