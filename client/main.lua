local blips = {}

--#region Functions

--- Get the rounded coords
---@param coords table
---@return table
function GetRoundedCoords(coords)
    local newcoords = {}
    for k, v in pairs(coords) do
        newcoords[k] = math.floor(v*1000)/1000
    end
    return newcoords
end

--- Create a blip for the Apartment
---@param coords vector3
---@param name string name that will be displayed on the blip
function AddApartmentBlip(coords, name)
    AddBlip('apartment', name, coords, Config.Apartments.Blip.sprite, Config.Apartments.Blip.color, Config.Apartments.Blip.scale)
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
    if GetInvokingResource() ~= nil then return end
    if not players then return end

    for _, player in ipairs(players) do
        NetworkConcealPlayer(player, conceal, false)
    end
end

RegisterNetEvent('qbx-property:client:concealPlayers', concealPlayers)