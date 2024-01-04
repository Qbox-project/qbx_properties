local blips = {}
InteriorZones = {}

--#region Functions
--- Create the zones inside the property
---@param coords table
---@param propertyId number | nil
---@param isVisit boolean
function CreatePropertyInteriorZones(coords, propertyId, isVisit)
    if table.type(InteriorZones) ~= 'empty' then
        for _, v in pairs(InteriorZones) do
            v:remove()
        end
        InteriorZones = {}
    end
    local customZones = propertyId and lib.callback.await('qbx_properties:server:GetCustomZones', false, propertyId) or
    {}

    InteriorZones.entrance = lib.points.new({
        coords = customZones?.entrance?.xyz or coords.entrance.xyz,
        distance = 7.5,
    })

    function InteriorZones.entrance:nearby()
        if not self?.currentDistance then return end
        local marker = Config.InteriorZones.entrance.marker
        DrawMarker(marker.type,
            self.coords.x, self.coords.y, self.coords.z + marker.offsetZ,   -- coords
            0.0, 0.0, 0.0,                                                  -- direction?
            0.0, 0.0, 0.0,                                                  -- rotation
            marker.scale.x, marker.scale.y, marker.scale.z,                 -- scale
            marker.color.r, marker.color.g, marker.color.b, marker.color.a, -- color RBGA
            false, false, 2, false, nil, nil, false
        )

        if self.currentDistance < 1 then
            SetTextComponentFormat("STRING")
            AddTextComponentString(Lang:t('interiorZones.leave'))
            DisplayHelpTextFromStringLabel(0, 0, 1, 20000)
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('qbx_properties:server:leaveProperty', propertyId, cache.vehicle)
            end
        end
    end

    if not isVisit then
        if coords.wardrobe then
            InteriorZones.wardrobe = lib.points.new({
                coords = customZones?.wardrobe?.xyz or coords.wardrobe.xyz,
                distance = 7.5,
            })

            function InteriorZones.wardrobe:nearby()
                if not self?.currentDistance then return end
                local marker = Config.InteriorZones.wardrobe.marker
                DrawMarker(marker.type,
                    self.coords.x, self.coords.y, self.coords.z + marker.offsetZ,   -- coords
                    0.0, 0.0, 0.0,                                                  -- direction?
                    0.0, 0.0, 0.0,                                                  -- rotation
                    marker.scale.x, marker.scale.y, marker.scale.z,                 -- scale
                    marker.color.r, marker.color.g, marker.color.b, marker.color.a, -- color RBGA
                    false, true, 2, false, nil, nil, false
                )

                if self.currentDistance < 1 then
                    SetTextComponentFormat("STRING")
                    AddTextComponentString(Lang:t('interiorZones.wardrobe'))
                    DisplayHelpTextFromStringLabel(0, 0, 1, 20000)
                    if IsControlJustPressed(0, 38) then
                        TriggerEvent('qb-clothing:client:openOutfitMenu') -- definitely probably doesn't do shit with illenium
                    end
                end
            end
        end

        if coords.stash then
            InteriorZones.stash = lib.points.new({
                coords = customZones?.stash?.xyz or coords.stash.xyz,
                distance = 7.5,
            })
            function InteriorZones.stash:nearby()
                if not self?.currentDistance then return end
                local marker = Config.InteriorZones.stash.marker
                DrawMarker(marker.type,
                    self.coords.x, self.coords.y, self.coords.z + marker.offsetZ, -- coords
                    0.0, 0.0, 0.0,                                              -- direction?
                    0.0, 0.0, 0.0,                                              -- rotation
                    marker.scale.x, marker.scale.y, marker.scale.z,             -- scale
                    marker.color.r, marker.color.g, marker.color.b, marker.color.a, -- color RBGA
                    false, true, 2, false, nil, nil, false
                )

                if self.currentDistance < 1 then
                    SetTextComponentFormat("STRING")
                    AddTextComponentString(Lang:t('interiorZones.stash'))
                    DisplayHelpTextFromStringLabel(0, 0, 1, 20000)
                    if IsControlJustPressed(0, 38) then
                        exports.ox_inventory:openInventory("stash",
                            propertyId and "property_" .. propertyId or "apartment_" .. QBX.PlayerData.citizenid)
                    end
                end
            end
        end

        if coords.logout then
            InteriorZones.logout = lib.points.new({
                coords = customZones?.logout?.xyz or coords.logout.xyz,
                distance = 7.5,
            })
            function InteriorZones.logout:nearby()
                if not self?.currentDistance then return end
                local marker = Config.InteriorZones.logout.marker
                DrawMarker(marker.type,
                    self.coords.x, self.coords.y, self.coords.z + marker.offsetZ, -- coords
                    0.0, 0.0, 0.0,                                              -- direction?
                    0.0, 0.0, 0.0,                                              -- rotation
                    marker.scale.x, marker.scale.y, marker.scale.z,             -- scale
                    marker.color.r, marker.color.g, marker.color.b, marker.color.a, -- color RBGA
                    false, true, 2, false, nil, nil, false
                )

                if self.currentDistance < 1 then
                    SetTextComponentFormat("STRING")
                    AddTextComponentString(Lang:t('interiorZones.logout'))
                    DisplayHelpTextFromStringLabel(0, 0, 1, 20000)
                    if IsControlJustPressed(0, 38) then
                        TriggerEvent('qbx_properties:server:Logout')
                    end
                end
            end
        end

        if coords.manage then
            InteriorZones.manage = lib.points.new({
                coords = customZones?.manage?.xyz or coords.manage.xyz,
                distance = 15,
            })
            function InteriorZones.manage:nearby()
                if not self then return end
                if not self.currentDistance then return end
                local marker = Config.InteriorZones.manage.marker
                DrawMarker(marker.type,
                    self.coords.x, self.coords.y, self.coords.z + marker.offsetZ, -- coords
                    0.0, 0.0, 0.0,                                              -- direction?
                    0.0, 0.0, 0.0,                                              -- rotation
                    marker.scale.x, marker.scale.y, marker.scale.z,             -- scale
                    marker.color.r, marker.color.g, marker.color.b, marker.color.a, -- color RBGA
                    false, true, 2, false, nil, nil, false
                )

                if self.currentDistance < 1 then
                    SetTextComponentFormat("STRING")
                    AddTextComponentString(Lang:t('interiorZones.manage'))
                    DisplayHelpTextFromStringLabel(0, false, true, 20000)
                    if IsControlJustPressed(0, 38) then
                        TriggerEvent('qbx_properties:client:openManageMenu', propertyId)
                    end
                end
            end
        end
    end
end

--- Get the rounded coords
---@param coords table
---@return table
function GetRoundedCoords(coords)
    local newcoords = {}
    for k, v in pairs(coords) do
        newcoords[k] = math.round(v, 3)
    end
    return newcoords
end

--- Create a blip for the Apartment
---@param coords vector3
---@param name string name that will be displayed on the blip
function AddApartmentBlip(coords, name)
    AddBlip('apartment', name, coords, Config.Apartments.Blip.sprite, Config.Apartments.Blip.color,
        Config.Apartments.Blip.scale)
end

--- Create a blip for the property/apartment
---@param blipId integer | string property id
---@param name string name that will be displayed on the blip
---@param coords vector3
---@param blip? integer
---@param color? integer
---@param size? integer
function AddBlip(blipId, name, coords, blip, color, size)
    if not blipId or not coords or not blip or not color or not size or not name then return end
    blips[blipId] = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blips[blipId], blip)
    SetBlipDisplay(blips[blipId], 4)
    SetBlipScale(blips[blipId], size)
    SetBlipColour(blips[blipId], color)
    SetBlipAsShortRange(blips[blipId], true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blips[blipId])
end

--- Remove blips
function RemoveBlips()
    for _, blip in pairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
end

--#endregion Functions

---@param players table
---@param conceal boolean
local function concealPlayers(players, conceal)
    if GetInvokingResource() or not players then return end

    for i = 1, #players do
        NetworkConcealPlayer(players[i], conceal, false)
    end
end

local function concealVehicles(netids, conceal)
    if GetInvokingResource() or not netids then return end

    for i = 1, #netids do
        local entity = NetToVeh(netids[i])
        NetworkConcealEntity(entity, conceal)
    end
end

RegisterNetEvent('qbx_properties:client:concealPlayers', concealPlayers)
RegisterNetEvent('qbx_properties:client:concealEntities', concealVehicles)

RegisterNetEvent("qbx_properties:client:refreshInteriorZones", function(propertyId, coords)
    CreatePropertyInteriorZones(coords, propertyId, false)
end)
