if not Config.useProperties then return end
local propertyZones = {}
local isInZone = false
local inSelection = false

--#region Functions

local function calcPrice(price, taxes)
    local totaltax = Config.Properties.taxes.general
    if taxes then
        for taxname, tax in pairs(Config.Properties.taxes) do
            if taxes[taxname] then
                totaltax += tax
            end
        end
    end
    return math.round(price + (price * (totaltax / 100)))
end

--- Get the list of applied taxes if any
---@param taxes table | nil
---@return table | nil
local function getAppliedTaxesList(taxes)
    if not taxes then return nil end
    local appliedTaxes = {}
    for i = 1, #taxes do
        appliedTaxes[taxes[i]] = Config.Properties.taxes[taxes[i]]
    end
    return appliedTaxes
end

--- Create a list of interiors
--- @param Garage boolean
--- @param Furnished boolean
--- @return table
local function createInteriorsList(Garage, Furnished)
    local options = {}
    for k,v in pairs(Garage and Config.GarageIPLs or Furnished and Config.IPLS or Config.Shells) do
        options[#options+1] = {}
        options[#options].label = Garage and Lang:t('create_property_menu.interior_label_garage', {interior = v.label, slots = #v.coords?.slots}) or v.label
        options[#options].value = k
    end
    return options
end

--- Get the list of taxes
--- return table
local function getTaxesList()
    local taxes = {}
    for k in pairs(Config.Properties.taxes) do
        if k ~= 'general' then
            taxes[#taxes + 1] = {
                label = k,
                value = k
            }
        end
    end
    return taxes
end

local function showSelectionScaleform(scaleform, action)
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    local scaleformButtons = {
        {GetControlInstructionalButton(0, 38, true), Lang:t("selection.action", {action = action})},
        {GetControlInstructionalButton(0, 120, true), Lang:t("selection.cancel")},
        {GetControlInstructionalButton(0, 44, true), Lang:t("selection.nextPlayer")}
    }

    for i = 1, #scaleformButtons, 1 do
        PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(i - 1)
        PushScaleformMovieFunctionParameterString(scaleformButtons[i][1])
        PushScaleformMovieFunctionParameterString(scaleformButtons[i][2])
        PopScaleformMovieFunctionVoid()
    end

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PushScaleformMovieFunctionParameterInt(0)
    PopScaleformMovieFunctionVoid()
    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
end

--- Start the player selection and return the selected player
---@param players table
---@param callback function
local function selectPlayer(players, action, callback)
    inSelection = true
    local playerNumber = 1
    local scaleform = lib.requestScaleformMovie("instructional_buttons", 10000)
    CreateThread(function()
        while true do
            Wait(0)
            showSelectionScaleform(scaleform, action)
            local player = players[playerNumber]
            local playerPed = player.ped
            local playerCoords = GetEntityCoords(playerPed)
            DrawMarker(2, playerCoords.x, playerCoords.y, playerCoords.z + 1.1, 0, 0, 0, 180, 0, 0, 0.25, 0.25, 0.25, 255, 50, 50, 255, true, true, 2, false, nil, nil, false)
            if IsControlJustPressed(0, 38) then -- E
                inSelection = false
                callback(player)
                break
            elseif IsControlJustPressed(0, 120) then -- X
                inSelection = false
                exports.qbx_core:Notify(Lang:t("error.cancelled"), 'error', 7500)
                break
            elseif IsControlJustPressed(0, 44) then -- Q (A on AZERTY)
                if playerNumber >= #players then
                    playerNumber = 1
                else
                    playerNumber += 1
                end
            end
        end
    end)
end

--- Sell the property to a player
---@param propertyData table
local function sellToPlayer(propertyData)
    local input = lib.inputDialog('Property Creator', {
        {
            type = 'slider',
            label = 'Commission %',
            default = Config.Properties.realtorCommission.default,
            min = Config.Properties.realtorCommission.min,
            max = Config.Properties.realtorCommission.max,
            step = 0.5,
            required = true,
            icon = 'percent'
        },
    }, { allowCancel = true })
    if not input then return end
    local comission = input[1]

    local players = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 10, Config.Properties.realtorsBuyThemselves)
    if not players then
        exports.qbx_core:Notify(Lang:t('error.players_nearby'), 'error', 7500)
        return
    end

    selectPlayer(players, "Sell", function(player)
        TriggerServerEvent('qbx-properties:server:sellProperty', GetPlayerServerId(player.id), propertyData.id, comission)
    end)
end

--- Rent (or extends the rent) the property to a player
--- @param propertyData table
--- @param isExtend boolean
local function rentToPlayer(propertyData, isExtend)
    local players = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 10, Config.Properties.realtorsBuyThemselves)
    if not players then
        exports.qbx_core:Notify(Lang:t('error.players_nearby'), 'error', 7500)
        return
    end

    selectPlayer(players, "Rent", function(player)
        TriggerServerEvent('qbx-properties:server:rentProperty', GetPlayerServerId(player.id), propertyData.id, isExtend)
    end)
end

--- Get a string of all taxes applied to a property
---@param taxes table
---@return string
local function getTaxesString(taxes)
    if not taxes or not next(taxes) then return Lang:t('general.none') end
    local str = ""
    for k in pairs(taxes) do
        str = str .. k .. ", "
    end
    return string.sub(str, 1, -3)
end

--- Modify the property's characteristics
---@param propertyData table
local function modifyProperty(propertyData)
    local newData = {}
    local options = {
        {label = Lang:t('modify_property_menu.name', {name = propertyData.name}), args = { action = "name" }, close = true},
        {label = Lang:t('modify_property_menu.price', {price = propertyData.price}), args = { action = "price" }, close = true},
        {label = Lang:t('modify_property_menu.rent', {price = propertyData.rent}), args = { action = "rent" }, close = true},
        {label = Lang:t('modify_property_menu.property_type', {property_type = Lang:t('general.'..propertyData.property_type)}), close = false},
        {label = Lang:t('modify_property_menu.interior', {interior = propertyData.interior}), args = { action = "interior" }, close = true},
    }

    if propertyData.property_type ~= 'garage' then
        options[#options+1] = {label = Lang:t('modify_property_menu.storage.slots', {value = propertyData.slots or 0}), args = { action = "slots" }, close = true}
        options[#options+1] = {label = Lang:t('modify_property_menu.storage.maxweight', {value = propertyData.maxweight/1000}), args = { action = "maxweight" }, close = true}
    end
    if Config.Properties.useTaxes then
        options[#options+1] = {label = Lang:t('modify_property_menu.taxes', {taxes = getTaxesString(propertyData.appliedtaxes)}), args = { action = "taxes" }, close = true}
    end
    options[#options+1] = {label = Lang:t('modify_property_menu.coords'), args = { action = "coords" }, close = true}
    options[#options+1] = {label = Lang:t('modify_property_menu.done'), args = { action = "done" }, close = true}

    local point = lib.points.new({
        coords = propertyData.coords.xyz,
        heading = propertyData.coords.w,
        distance = 15,
    })

    function point:nearby()
        if not self?.currentDistance then return end
        DrawMarker(26,
            self.coords.x, self.coords.y, self.coords.z + Config.Properties.marker.offsetZ, -- coords
            0.0, 0.0, 0.0, -- direction?
            0.0, 0.0, self.heading, -- rotation
            1,1,1, -- scale
            255, 50, 50, 255, -- color RBGA
            false, false, 2, false, nil, nil, false
        )
    end

    lib.registerMenu({
        id = 'modify_property_menu',
        title = Lang:t('modify_property_menu.title'),
        position = 'top-left',
        options = options,
    }, function(_, _, args)
        if not args then return end
        if args.action == "name" then
            local propertyString = string.split(propertyData.name, ' ')
            local propertyNumber = tonumber(propertyString[1])
            local input = lib.inputDialog(Lang:t('modify_property_menu.title'), {
                {type = 'input', label = Lang:t('modify_property_menu.name', {name = propertyData.name}), default = table.concat(propertyString, ' ', 2), required = true},
            }, {allowCancel = true})

            if input then
                newData.name = propertyNumber .. " " .. input[1]
                lib.setMenuOptions('modify_property_menu', {label = Lang:t('modify_property_menu.name', {name = newData.name})}, 1)
            end
        elseif args.action == "price" or args.action == "rent" then
            local price = newData[args.action] or propertyData[args.action]
            local input = lib.inputDialog(Lang:t('modify_property_menu.title'), {
                {type = 'input', label = Lang:t('modify_property_menu.'..args.action, {price = price}), default = price, required = true},
            }, {allowCancel = true})

            if input then
                newData[args.action] = tonumber(input[1])
                local newOptions = options[args.action == "price" and 2 or 3]
                newOptions.label = Lang:t('modify_property_menu.'..args.action, {price = newData[args.action]})
                lib.setMenuOptions('modify_property_menu', newOptions, args.action == "price" and 2 or 3)
            end
        elseif args.action == "interior" then
            local interior = newData.interior or propertyData.interior
            local input = lib.inputDialog(Lang:t('modify_property_menu.title'), {
                {type = 'select', label = Lang:t('modify_property_menu.interior', {interior = interior}), default = interior, options = createInteriorsList(propertyData.property_type == 'garage', propertyData.property_type ~= 'garage')},
            }, {allowCancel = true})

            if input then
                newData.interior = input[1]
                local newOptions = options[5]
                newOptions.label = Lang:t('modify_property_menu.interior', {interior = newData.interior})
                lib.setMenuOptions('modify_property_menu', newOptions, 5)
            end
        elseif args.action == "slots" or args.action == "maxweight" then
            local value = (newData[args.action] or propertyData[args.action]) / (args.action == "maxweight" and 1000 or 1)
            local input = lib.inputDialog(Lang:t('modify_property_menu.title'), {
                {type = 'number', label = Lang:t('modify_property_menu.storage.'..args.action, {value = value}), default = value, required = true},
            }, {allowCancel = true})

            if input then
                newData[args.action] = tonumber(input[1]) * (args.action == "maxweight" and 1000 or 1)
                local newOptions = options[args.action == "slots" and 6 or 7]
                newOptions.label = Lang:t('modify_property_menu.storage.'..args.action, {value = newData[args.action] / (args.action == "maxweight" and 1000 or 1)})
                lib.setMenuOptions('modify_property_menu', newOptions, args.action == "slots" and 6 or 7)
            end
        elseif args.action == "taxes" then
            local index = #options - 2
            local taxes = newData.taxes or propertyData.appliedtaxes
            local default = {}
            for k in pairs(taxes) do
                default[#default+1] = k
            end
            local input = lib.inputDialog(Lang:t('modify_property_menu.title'), {
                {type = 'multi-select', label = Lang:t('modify_property_menu.taxes', {taxes = getTaxesString(taxes)}), default = default, options = getTaxesList()},
            }, {allowCancel = true})
            if input then
                newData.taxes = getAppliedTaxesList(input[1])
                local newOptions = options[index]
                newOptions.label = Lang:t('modify_property_menu.taxes', {taxes = getTaxesString(newData.taxes)})
                lib.setMenuOptions('modify_property_menu', newOptions, index)
            end
        elseif args.action == "coords" then
            local coord, heading = GetEntityCoords(cache.ped), GetEntityHeading(cache.ped)
            local coords = {x = coord.x, y = coord.y, z = coord.z, w = heading}
            coords = GetRoundedCoords(coords)
            newData.coords = vec4(coords.x, coords.y, coords.z, coords.w)
            point.coords, point.heading = newData.coords.xyz, newData.coords.w
        end

        if args.action == 'done' then
            point:remove()
            if not next(newData) then return end
            TriggerServerEvent('qbx-properties:server:modifyProperty', propertyData.id, propertyData.property_type, newData)
        else
            lib.showMenu('modify_property_menu')
        end
    end)
    lib.showMenu('modify_property_menu')
end

--- Populate the property menu
---@param propertyData table
---@param propertyType string
local function populatePropertyMenu(propertyData, propertyType)
    if not propertyData then return end
    if not QBX.PlayerData then return end
    local isRealEstateAgent = QBX.PlayerData.job.type == 'realestate'
    local isBought, isRented, hasKeys = next(propertyData.owners) ~= nil and true or false, propertyData.rent_expiration and true or false, propertyData.owners[QBX.PlayerData.citizenid] and true or false
    local options = {}
    if isBought or isRented then
        if hasKeys then
            options[#options+1] = {
                label = Lang:t('property_menu.enter'),
                icon = 'door-open',
                args = {
                    action = 'enter',
                    propertyData = propertyData,
                    propertyType = propertyType,
                },
                close = true
            }
        else
            options[#options+1] = {
                label = Lang:t('property_menu.ring'),
                icon = 'bell',
                args = {
                    action = 'ring',
                    propertyData = propertyData,
                    propertyType = propertyType,
                },
                close = true
            }
        end
        if isRented and isRealEstateAgent then
            options[#options+1] = {
                label = Lang:t('property_menu.extend_rent'),
                description = Lang:t('property_menu.extend_rent_desc', {rent_expiration = propertyData.rent_expiration, price = calcPrice(propertyData.rent, propertyData.appliedtaxes)}),
                icon = 'file-invoice-dollar',
                args = {
                    action = 'extend_rent',
                    propertyData = propertyData,
                    propertyType = propertyType,
                },
                close = true
            }
        end
    else
        options[#options+1] = {
            label = Lang:t('property_menu.visit'),
            icon = 'door-open',
            args = {
                action = 'visit',
                propertyData = propertyData,
                propertyType = propertyType,
            },
            close = true
        }
        if isRealEstateAgent then
            options[#options+1] = {
                label = Lang:t('property_menu.sell'),
                description = Lang:t('property_menu.sell_desc', {price = calcPrice(propertyData.price, propertyData.taxes)}),
                icon = 'file-invoice-dollar',
                args = {
                    action = 'sell',
                    propertyData = propertyData,
                    propertyType = propertyType,
                },
                close = true
            }
            options[#options+1] = {
                label = Lang:t('property_menu.rent', {price = calcPrice(propertyData.rent, propertyData.taxes)}),
                description = Lang:t('property_menu.rent_desc', {price = calcPrice(propertyData.rent, propertyData.taxes)}),
                icon = 'file-invoice-dollar',
                args = {
                    action = 'rent',
                    propertyData = propertyData,
                    propertyType = propertyType,
                },
                close = true
            }
        end
    end

    if isRealEstateAgent then
        options[#options+1] = {
            label = Lang:t('property_menu.modify'),
            icon = "toolbox",
            args = {
                action = 'modify',
                propertyData = propertyData,
                propertyType = propertyType,
            },
            close = true
        }
    end

    options[#options+1] = {
        label = Lang:t('property_menu.back'),
        icon = 'arrow-left',
        args = {
            action = 'back',
        },
        close = true
    }


    lib.registerMenu({
        id = 'property_menu',
        title = propertyData.name,
        position = 'top-left',
        options = options,
        onClose = function(keyPressed)
            if keyPressed == "Backspace" then
                lib.showMenu('properties_menu')
            end
        end,
    }, function(_, _, args)
        if args.action == 'enter' or args.action == "visit" then
            if args.propertyType == 'garage' then
                TriggerServerEvent('qbx-properties:server:enterGarage', args.propertyData.id, args.action == "visit", cache.vehicle or false)
            else
                TriggerServerEvent('qbx-properties:server:enterProperty', args.propertyData.id, args.action == "visit")
            end
        elseif args.action == 'ring' then
            TriggerServerEvent('qbx-properties:server:RingDoor', args.propertyData.id)
        elseif args.action == 'extend_rent' then
            rentToPlayer(args.propertyData, true)
        elseif args.action == 'sell' then
            sellToPlayer(args.propertyData)
        elseif args.action == 'rent' then
            rentToPlayer(args.propertyData, false)
        elseif args.action == 'modify' then
            modifyProperty(args.propertyData)
        elseif args.action == 'back' then
            lib.showMenu('properties_menu')
        end
    end)
end

--- Populate the properties menu (list of properties in a same location)
---@param ids table
---@param propertyType string
---@param coords vector4
local function populatePropertiesMenu(ids, propertyType, coords)
    if not ids then return end
    local options = {}

    for propertyId, name in pairs(ids) do
        local propertyData = lib.callback.await('qbx-properties:server:GetPropertyData', false, propertyId)
        if not propertyData then goto continue end
        options[#options+1] = {
            label = name,
            icon = propertyType == 'garage' and 'warehouse' or 'house-chimney',
            args = {
                propertyData = propertyData,
                propertyType = propertyType,
            },
            close = true
        }
        ::continue::
    end

    if QBX.PlayerData.job.type == 'realestate' then
        options[#options+1] = {
            label = Lang:t('properties_menu.create'),
            icon = 'plus',
            args = {
                action = 'create',
                coords = coords,
                propertyType = propertyType,
            },
            close = true
        }
    end

    lib.registerMenu({
        id = 'properties_menu',
        title = 'Property List',
        position = 'top-left',
        options = options
    }, function(_, _, args)
        if args.action == "create" then
            TriggerEvent("qbx-properties:client:OpenCreationMenu", args.coords, args.propertyType)
            return
        end
        populatePropertyMenu(args.propertyData, args.propertyType)
        lib.showMenu('property_menu')
    end)
end

local function populateRolesMenu(propertyId, propertyData)
    local options = {}
    local roles = propertyData.owners
    local playerNames = lib.callback.await('qbx-properties:server:GetPlayerNames', false, roles)

    if not playerNames then return false end

    for citizenid, role in pairs(roles) do
        options[#options+1] = {
            label = playerNames[citizenid],
            icon = 'user',
            values = {Lang:t('general.owner'), Lang:t('general.co_owner'), Lang:t("general.tenant"), Lang:t('general.remove')},
            defaultindex = role == "owner" and 1 or role == "co_owner" and 2 or 3,
            args = {
                action = 'role',
                citizenid = citizenid,
                propertyId = propertyId,
            },
            close = true
        }
    end

    options[#options+1] = {
        label = Lang:t('manage_property_menu.manage_roles.add'),
        icon = 'plus',
        args = {
            action = 'add',
            propertyId = propertyId,
        },
        close = true
    }

    lib.registerMenu({
        id = 'propertyRoles_menu',
        title = Lang:t('manage_property_menu.manage_roles.title'),
        position = 'top-left',
        options = options
    }, function(_, scrollIndex, args)
        if args.action == "role" then
            local newRole = scrollIndex == 1 and "owner" or scrollIndex == 2 and "co_owner" or scrollIndex == 3 and "tenant" or "remove"
            TriggerServerEvent('qbx-properties:server:modifyRole', args.propertyId, args.citizenid, newRole)
        elseif args.action == "add" then
            local players = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 10, Config.Properties.realtorsBuyThemselves or false)
            if not players then
                exports.qbx_core:Notify(Lang:t('error.players_nearby'), 'error', 7500)
                return
            end

            selectPlayer(players, "Add", function(player)
                TriggerServerEvent('qbx-properties:server:addTenant', args.propertyId, GetPlayerServerId(player.id))
            end)
        end
    end)
    return true
end

local function populateCoordsMenu(propertyId, propertyData)
    local configCoords = Config[propertyData.property_type == 'garage' and 'GarageIPLs' or propertyData.property_type == 'shell' and 'Shells' or 'IPLS'][propertyData.interior].coords
    local propertyCoords = {
        stash = propertyData.stash or configCoords.stash,
        logout = propertyData.logout or configCoords.logout,
        wardrobe = propertyData.wardrobe or configCoords.wardrobe,
        manage = propertyData.manage or configCoords.manage
    }
    local points = {}
    local newData = {
        interiorCoords = {}
    }
    local options = {}

    for k, v in pairs(propertyCoords) do
        options[#options+1] = {
            label = Lang:t('manage_property_menu.manage_coords.'..k),
            icon = 'map-marker',
            values = {Lang:t('manage_property_menu.manage_coords.set'), Lang:t('manage_property_menu.manage_coords.reset')},
            args = {
                action = k,
                coord = v,
            },
            close = false
        }
    end

    options[#options+1] = {
        label = Lang:t('manage_property_menu.manage_coords.save'),
        icon = 'check',
        args = {
            action = 'save',
            propertyId = propertyId,
        },
        close = true
    }

    lib.registerMenu({
        id = 'propertyCoords_menu',
        title = Lang:t('manage_property_menu.manage_coords.title'),
        position = 'top-left',
        options = options,
        onClose = function()
            if keyPressed == "Backspace" then
                lib.showMenu('manageProperty_menu')
            end
            for _, v in pairs(points) do
                v:remove()
            end
        end
    }, function(_, scrollIndex, args)
        if args.action == "save" then
            local isSure = lib.alertDialog({
                content = Lang:t('general.areYouSure'),
                centered = true,
                cancel = true
            })
            if isSure then
                TriggerServerEvent('qbx-properties:server:modifyProperty', propertyId, propertyData.property_type, newData)
            end
            for _, v in pairs(points) do
                v:remove()
            end
            return
        end
        if scrollIndex == 1 then
            local coord = GetEntityCoords(cache.ped)
            local coords = {x = coord.x, y = coord.y, z = coord.z}
            coords = GetRoundedCoords(coords)
            newData.interiorCoords[args.action] = vec3(coords.x, coords.y, coords.z)
            points[args.action].coords = newData.interiorCoords[args.action].xyz
        else
            newData.interiorCoords[args.action] = "reset"
            points[args.action].coords = configCoords[args.action].xyz
            exports.qbx_core:Notify(Lang:t("manage_property_menu.manage_coords.willBeReset"), 'primary', 7500)
        end
    end)

    for k, v in pairs(propertyCoords) do
        points[k] = lib.points.new({
            coords = v.xyz,
            heading = 0,
            distance = 15
        })

        points[k].nearby = function(self)
            if not self then return end
            if not self.currentDistance then return end
            DrawMarker(26,
                self.coords.x, self.coords.y, self.coords.z + Config.Properties.marker.offsetZ, -- coords
                0.0, 0.0, 0.0, -- direction?
                0.0, 0.0, self.heading, -- rotation
                1,1,1, -- scale
                255, 50, 50, 255, -- color RBGA
                false, false, 2, false, nil, nil, false
            )
        end
    end
end

local function openManageMenu(propertyId)
    local propertyData = lib.callback.await('qbx-properties:server:GetPropertyData', false, propertyId)
    local Role = propertyData.owners[PlayerData.citizenid]
    if not Role then return end
    local options = {
        {label = Lang:t('manage_property_menu.name', {name = propertyData.name}), icon = "fas fa-pen", args = { action = "name" }, close = true},
        {label = Lang:t('manage_property_menu.roles'), icon = "fas fa-users", args = { action = "roles" }, close = true},
        {label = Lang:t('manage_property_menu.customcoords'), icon = "fas fa-map", args = { action = "customcoords" }, close = true},
    }

    if propertyData.property_type ~= 'garage' then
        options[#options+1] = {label = Lang:t('manage_property_menu.decorate'), icon = "fas fa-bed", args = { action = "decorate" }, close = true}
    else
        options[#options+1] = {label = Lang:t('manage_property_menu.vehicles'), icon = "fas fa-car", args = { action = "vehicles" }, close = true}
    end

    lib.registerMenu({
        id = 'manageProperty_menu',
        title = propertyData.name,
        position = 'top-left',
        options = options,
    }, function(_, _, args)
        if args.action == "name" then
            local propertyString = string.split(propertyData.name, ' ')
            local propertyNumber = tonumber(propertyString[1])
            local input = lib.inputDialog(Lang:t('manage_property_menu.title'), {
                {type = 'input', label = Lang:t('manage_property_menu.name', {name = propertyData.name}), default = table.concat(propertyString, ' ', 2), required = true},
            }, {allowCancel = true})

            if input then
                TriggerServerEvent('qbx-properties:server:modifyProperty', propertyId, propertyData.property_type, {name = propertyNumber .. " " .. input[1]})
            end
        elseif args.action == "roles" then
            if Role ~= "owner" and Role ~= "co_owner" then
                return exports.qbx_core:Notify(Lang:t('error.not_owner'), 'error', 7500)
            end
            if populateRolesMenu(propertyId, propertyData) then
                lib.showMenu('propertyRoles_menu')
            end
        elseif args.action == "customcoords" then
            if Role ~= "owner" and Role ~= "co_owner" then
                return exports.qbx_core:Notify(Lang:t('error.not_owner'), 'error', 7500)
            end
            populateCoordsMenu(propertyId, propertyData)
            lib.showMenu('propertyCoords_menu')
        elseif args.action == "decorate" then
            if Role ~= "owner" then
                return exports.qbx_core:Notify(Lang:t('error.not_owner'), 'error', 7500)
            end
            -- TODO: decoration menu
        elseif args.action == "vehicles" then
            -- TODO: vehicle management
        end
    end)
    lib.showMenu('manageProperty_menu')
end

local function addPropertyGroupBlip(propertyId, propertyGroup, isRented)
    local Status = propertyGroup.propertyType == 'garage' and 'garage' or isRented and 'rent' or 'owned'
    AddBlip(propertyId, propertyGroup.properties[propertyId], propertyGroup.coords, Config.Properties.blip[Status].sprite, Config.Properties.blip[Status].color, Config.Properties.blip[Status].scale)
end

--- Create the properties lib points
local function createPropertiesZones()
    local starttime = GetGameTimer()
    local propertiesGroups = lib.callback.await('qbx-properties:server:GetProperties', false)
    if not propertiesGroups then return end

    local markerColor = Config.Properties.marker.color
    local markerScale = Config.Properties.marker.scale
    local ownedOrRentedProperties = lib.callback.await('qbx-properties:server:GetOwnedOrRentedProperties', false)

    for k, v in pairs(propertiesGroups) do
        local zone = lib.points.new({
            coords = v.coords.xyz,
            heading = v.coords.h,
            distance = 15,
            reset = false,
            propertyIds = v.properties,
            propertyType = v.propertyType
        })

        function zone:nearby()
            if self?.reset then self:remove() return end
            if not self.currentDistance then return end
            DrawMarker(Config.Properties.marker.type,
                self.coords.x, self.coords.y, self.coords.z + Config.Properties.marker.offsetZ, -- coords
                0.0, 0.0, 0.0, -- direction?
                0.0, 0.0, 0.0, -- rotation
                markerScale.x, markerScale.y, markerScale.z, -- scale
                markerColor.r, markerColor.g, markerColor.b, markerColor.a, -- color RBGA
                false, true, 2, false, nil, nil, false
            )

            if self.currentDistance < 1 and not lib.getOpenMenu() and not inSelection then
                SetTextComponentFormat("STRING")
                AddTextComponentString(Lang:t('properties_menu.showmenuhelp', {propertyType = Lang:t('properties_menu.'..self.propertyType)}))
                DisplayHelpTextFromStringLabel(0, false, true, 20000)
                isInZone = true
                if IsControlJustPressed(0, 38) then
                    populatePropertiesMenu(self.propertyIds, self.propertyType, self.coords)
                    lib.showMenu('properties_menu')
                end
            else
                isInZone = false
            end
        end
        propertyZones[k] = zone
        for propertyId in pairs(v.properties) do
            if ownedOrRentedProperties[propertyId] then
                addPropertyGroupBlip(propertyId, v, ownedOrRentedProperties[propertyId].isRented)
            end
        end
    end
    lib.print.info(string.format('Created %s property zones in %s ms', tostring(#propertiesGroups), tostring(GetGameTimer() - starttime)))
end

--- removes the lib.points objects and clears the propertyZones table
local function clearProperties()
    for i = 1, #propertyZones do
        propertyZones[i].reset = true
    end
    propertyZones = {}
    RemoveBlips()
end

local function refreshProperties()
    Wait(1000)
    if LocalPlayer.state.isLoggedIn then
        clearProperties()
        createPropertiesZones()
    end
end

--- Create a property
---@param propertyData table
local function createProperty(propertyData)
    propertyData.maxweight = propertyData.maxweight and propertyData.maxweight * 1000 or false
    TriggerServerEvent('qbx-properties:server:CreateProperty', propertyData)
end

local interiors = {
    [290561] = { -- Eclipse Boulevard
        entitysets = {
            "entity_set_shell_02",
            "entity_set_numbers_01",
            "entity_set_tint_01",
        },
        color = {
            "entity_set_tint_01",
            1
        }
    },
    [291841] = { -- Vinewood Car Club
        entitysets = {
            "entity_set_signs",
            "entity_set_plus",
            "entity_set_stairs",
            "entity_set_backdrop_frames"
        }
    },
    [290817] = {
        entitysets = {
            "entity_set_roller_door_closed"
        }
    },
    [271873] = {
        entitysets = {
            "Int02_ba_garage_blocker",
            "Int02_ba_sec_upgrade_desk",
            "Int02_ba_sec_desks_L2345",
            "Int02_ba_sec_upgrade_desk02",
            "Int02_ba_FanBlocker01",
            "Int02_ba_DeskPC",
            "Int02_ba_storage_blocker",
            "Int02_ba_floor01"
        }
    },
    [286721] = {
        entitysets = {
            "Entity_Set_Workshop_Wall",
            "Entity_Set_Wallpaper_01"
        },
    }
}

--- Setup the IPLs
local function setupInteriors()
    local Franklin = exports.bob74_ipl:GetFranklinObject()
    Franklin.Style.Set(Franklin.Style.settled)
    Franklin.GlassDoor.Set(Franklin.GlassDoor.closed, true)

    for k, v in pairs(interiors) do
        for i = 1, #v.entitysets do
            ActivateInteriorEntitySet(k, v.entitysets[i])
        end
        if v.color then
            SetInteriorEntitySetColor(k, v.color[1], v.color[2])
        end
        RefreshInterior(k)
    end
end

--- Setup the IPL style
---@param interior number
---@param style table
---@param options table
local function setupIPL(interior, style, options)
    if not interior or not style or table.type(options) == 'empty' then return end

    -- Deactivate all entitysets
    for i = 1, #style do
        for u = 1, #style[i] do
            DeactivateInteriorEntitySet(interior, style[i][u])
        end
    end

    -- Activate the selected entitysets
    for styleType, entityset in pairs(options.style) do
        ActivateInteriorEntitySet(interior, style[styleType][entityset])
    end

    -- Set the interior color
    if options.color then
        SetInteriorEntitySetColor(interior, style.Tint.entityset, style.Tint.colors[options.color])
    end
    RefreshInterior(interior)
end

--- Load the IPL with the selected style and teleport the player to the entrance
---@param coords table
---@param isGarage boolean
---@param interior number
---@param propertyOptions table
local function LoadAndTeleportToIPL(coords, isGarage, interior, propertyOptions)
    if propertyOptions then
        setupIPL(GetInteriorAtCoords(GetEntityCoords(cache.ped, false)), isGarage and Config.GarageIPLs[interior].style or Config.IPLS[interior].style, propertyOptions)
    end
    SetEntityCoords(cache.ped, coords.entrance.x, coords.entrance.y, coords.entrance.z, true, false, false, false)
    SetEntityHeading(cache.ped, coords.entrance.w)
end

--- Teleport the player outside the property
---@param coords table
local function TeleportOutside(coords)
    DoScreenFadeOut(500)
    Wait(250)
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z, true, false, false, false)
    SetEntityHeading(cache.ped, coords.w)
    DoScreenFadeIn(500)
end
--#endregion Functions

--#region Events
RegisterNetEvent('qbx-properties:client:refreshProperties', refreshProperties)

--- Create a property
--- @param coords vector4 | nil
--- @param propertyType string | nil
RegisterNetEvent('qbx-properties:client:OpenCreationMenu', function(coords, propertyType)
    if not coords and isInZone then
        exports.qbx_core:Notify('A property already exists there!', 'error', 5000)
        return
    end
    local generalOptions = lib.inputDialog('Property Creator', {
        {type = 'input', label = 'Name', description = 'Name the Property (Optional)', placeholder = 'Vinewood Villa'},
        {type = 'number', label = 'Price', required = true, icon = 'dollar-sign', default = Config.Properties.minimumPrice, min = Config.Properties.minimumPrice},
        {type = 'number', label = 'Rent Price', required = true, description = 'Rent price for 7 days', icon = 'dollar-sign', default = 100, placeholder = "69"},
        not propertyType and {type = 'checkbox', label = 'Garage?', checked = false},
        not propertyType and {type = 'checkbox', label = 'Furnished? (Not For Garages!)', checked = true},
    }, {allowCancel = true})
    if not generalOptions then return end
    if generalOptions[1] == '' then generalOptions[1] = nil end
    if propertyType then
        generalOptions[4] = propertyType == 'garage'
        generalOptions[5] = propertyType == 'ipl'
    end

    local propertyOptions = {
        {type = 'select', clearable = false, label = "Interior", options = createInteriorsList(generalOptions[4], generalOptions[5])}
    }
    if not generalOptions[4] then
        propertyOptions[2] = {type = 'number', label = "Storage Volume", description = "Size of the storage (Kg)", default = 50, min = 1}
        propertyOptions[3] = {type = 'number', label = "Storage Size", description = "Number of slots the Storage has", default = 10, min = 1}
        if Config.Properties.useTaxes then
            propertyOptions[4] = {type = 'multi-select', label = "Taxes", description = "Adds a tax if the property has the selected feature", options = getTaxesList()}
        end
    end

    local propertyCreation = lib.inputDialog('Property Creator', propertyOptions, {allowCancel = true})
    if not propertyCreation then return end
    if not propertyCreation[1] then
        exports.qbx_core:Notify('You need to select an interior!', 'error')
        return
    end
    if not coords then
        local coord, heading = GetEntityCoords(cache.ped), GetEntityHeading(cache.ped)
        coords = {x = coord.x, y = coord.y, z = coord.z, w = heading}
        coords = GetRoundedCoords(coords)
    end

    local inputResult = {
        name = generalOptions[1] or GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z)),
        price = generalOptions[2],
        rent = generalOptions[3],
        garage = generalOptions[4] or nil,
        furnished = generalOptions[4] and nil or generalOptions[5],
        interior = propertyCreation[1],
        maxweight = propertyCreation[2] or nil,
        slots = propertyCreation[3] or nil,
        appliedtaxes = getAppliedTaxesList(propertyCreation[4]) or nil,
        coords = {x = coords.x, y = coords.y, z = coords.z, w = coords.w},
    }
    createProperty(inputResult)
end)

RegisterNetEvent('qbx-properties:client:enterIplProperty', function(interior, propertyId, isVisit, propertyOptions)
    local coords = Config.IPLS[interior].coords
    DoScreenFadeOut(1500)
    Wait(250)
    LoadAndTeleportToIPL(coords, false, interior, propertyOptions)
    DoScreenFadeIn(1500)
    CreatePropertyInteriorZones(coords, propertyId, isVisit)
end)

RegisterNetEvent('qbx-properties:client:enterGarage', function(interior, propertyId, isVisit, propertyOptions)
    local coords = Config.GarageIPLs[interior].coords
    DoScreenFadeOut(1500)
    Wait(250)
    LoadAndTeleportToIPL(coords, true, interior, propertyOptions)
    DoScreenFadeIn(1500)
    CreatePropertyInteriorZones(coords, propertyId, isVisit)
end)

RegisterNetEvent('qbx-properties:client:leaveProperty', function(coords)
    if not coords then return end
    for i = 1, #InteriorZones do
        InteriorZones[i]:remove()
    end
    InteriorZones = {}
    TeleportOutside(coords)
end)

RegisterNetEvent("qbx-properties:client:leaveGarage", function(coords)
    if not coords then return end
    for i = 1, #InteriorZones do
        InteriorZones[i]:remove()
    end
    InteriorZones = {}
    TeleportOutside(coords)
end)

RegisterNetEvent('qbx-properties:client:openManageMenu', openManageMenu)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    setupInteriors()
    refreshProperties()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        setupInteriors()
        SetTimeout(2000, function()
            if table.type(propertyZones) == 'empty' then
                refreshProperties()
            end
        end)
    end
end)
--#endregion Events

--#region Callbacks
lib.callback.register('qbx-properties:client:promptOffer', function(price, isRent)
    local alert = lib.alertDialog({
        header = Lang:t('general.promptOfferHeader'),
        content = Lang:t('general.promptOffer', {action = Lang:t('general.'.. (isRent and 'rent' or 'buy')), amount = price}),
        centered = true,
        cancel = true
    })
    return alert == 'confirm'
end)
--#endregion Callbacks