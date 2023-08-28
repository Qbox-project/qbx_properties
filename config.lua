Config = {}

Config.useApartments = true -- false to disable apartments
Config.useProperties = true -- false to disable properties

Config.Properties = {
}

Config.Apartments = {
    marker = {
        type = 25,
        offsetZ = -0.95,
        color = {r = 82, g = 145, b = 170, a = 155},
        scale = {x = 0.8, y = 0.8, z = 0.8},
    },
    blip = {
        sprite = 475,
        color = 3,
        scale = 0.7,
    },
    weight = 200000,
    slots = 40,
}

Config.apartmentLocations = {
    {
        name = "Alta Street Apartments",
        coords = vector4(-271.1, -957.5, 31.22, 291.66),
        IPL = "LowEnd", -- Config.IPLS["LowEnd"]
        default = true
    },{
        name = "Morningwood Blvd",
        coords = vector4(-1288.52, -430.51, 35.15, 124.81),
        IPL = "LowEnd",
    },{
        name = "Tinsel Towers",
        coords = vector4(-619.29, 37.69, 43.59, 181.03),
        IPL = "LowEnd",
    },{
        name = "Fantastic Plaza",
        coords = vector4(291.517, -1078.674, 29.405, 270.75),
        IPL = "LowEnd",
    },
}

---@type { [string]: { ipl: string | false, coords: { entrance: vector4, wardrobe: vector4, stash: vector4, logout: vector3 } } }
Config.IPLS = { -- 'Ipls' can just be interiors that aren't proper IPLs, but are still interiors
    ["Alta Street"] = {
        ipl = false,
        coords = {
            entrance = vector4(-271.87, -940.34, 92.51, 70),
            wardrobe = vector4(-277.79, -960.54, 86.31, 70),
            stash = vector4(-272.98, -950.01, 92.52, 70),
            logout = vector3(-283.27, -959.68, 70),
        }
    },
    ["Eclipse Tower"] = {
        ipl = "apa_v_mp_h_01_a",
        coords = {
            entrance = vector4(-786.866, 315.764, 217.638, 160),
            wardrobe = vector4(-786.866, 315.764, 217.638, 160),
            stash = vector4(-786.866, 315.764, 217.638, 160),
            logout = vector3(-786.866, 315.764, 217.638),
        }
    },
    ["Low End"] = {
        ipl = false,
        coords = {
            entrance = vector4(265.95, -1007.41, -101.01, 2.71),
            wardrobe = vector4(259.76, -1003.63, -99.01, 182.24),
            stash = vector4(265.8, -999.47, -99.01, 268.16),
            logout = vector3(262.9, -1003.09, -99.01),
        }
    },
}

Config.Shells = {
--[[
    ["Shell Name"] = {
        shell = string, -- shell object/prop
        offsets = {
            entrance = vector4(0, 0, 0, 0), -- required
            wardrobe = vector4(0, 0, 0, 0), -- required
            stash = vector4(0, 0, 0, 0), -- required
            logout = vector3(0, 0, 0), -- required
        }
    } ]]
}

Config.GarageIPLs = {
}