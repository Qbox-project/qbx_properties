local Blips = {}

--#region Functions
--- Create a blip for the property
---@param IsApartment boolean
---@param BlipId integer | nil
---@param coords vector3
---@param blip integer | nil
---@param color integer | nil
---@param size integer | nil
---@param name string
function AddBlip(IsApartment, BlipId, coords, blip, color, size, name)
    if not IsApartment and (not BlipId or not coords or not blip or not color or not size or not name) then return end
    if IsApartment then
        blip = Config.Apartments.Blip.sprite
        color = Config.Apartments.Blip.color
        size = Config.Apartments.Blip.scale
        BlipId = 'apartment'
    end

    Blips[BlipId] = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(Blips[BlipId], blip)
    SetBlipDisplay(Blips[BlipId], 4)
    SetBlipScale(Blips[BlipId], size)
    SetBlipColour(Blips[BlipId], color)
    SetBlipAsShortRange(Blips[BlipId], true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(Blips[BlipId])
end
--#endregion Functions

---@param player number
---@param players table | nil
---@param conceal boolean
local function ConcealPlayers(player, players, conceal)
    if player == cache.serverId then return end
    for _, player in ipairs(players) do
        NetworkConcealPlayer(player, conceal, false)
    end
end

RegisterNetEvent('qbx-property:client:concealPlayers', ConcealPlayers)