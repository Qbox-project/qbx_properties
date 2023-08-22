Config = {}

Config.useApartments = true -- false to disable apartments
Config.useProperties = true -- false to disable properties

Config.Properties = {
    marker = {
        type = 25,
        offsetZ = -0.95,
        color = {r = 82, g = 145, b = 170, a = 155},
        scale = {x = 0.8, y = 0.8, z = 0.8},
    },
    blip = {
        owned = {
            sprite = 40,
            color = 38,
            scale = 0.7,
        },
        rent = {
            sprite = 40,
            color = 25,
            scale = 0.7,
        },
        garage = {
            sprite = 357,
            color = 3,
            scale = 0.7,
        },
    },
    --- @type number Minimum price for a property (Avoid Players making their own properties for 1$ for example, i guess?)
    minimumPrice = 10000,
    --- @type boolean
    useTaxes = true,
    --- @type { [string]: number } Applies to both rent (repeatedly) and buy (once)
    --- /!\ Case sensitive /!\
    taxes = {
        garden = 3,
        pool = 5,
        general = 10,
    },
    realtorCommission = {
        default = 5,
        min = 1,
        max = 15,
    }
}

Config.Apartments = {
    Marker = {
        type = 25,
        offsetZ = -0.95,
        color = {r = 82, g = 145, b = 170, a = 155},
        scale = {x = 0.8, y = 0.8, z = 0.8},
    },
    Blip = {
        sprite = 475,
        color = 3,
        scale = 0.7,
    },
    weight = 200000,
    slots = 40,
}

Config.defaultapartment = 1
Config.apartmentlocations = {
    {
        name = "Alta Street Apartments",
        coords = vector4(-271.1, -957.5, 31.22, 291.66),
        IPL = "LowEnd", -- Config.IPLS["LowEnd"]
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
    ["Franklin House"] = {
        ipl = false,
        coords = {
            entrance = vector4(7.52, 539.13, 176.02, 160),
            wardrobe = vector4(8.65, 528, 170.5, 300),
            stash = vector4(9, 535, 170.5, 0),
            logout = vector3(0, 523, 170.5),
        }
    },
    ["Warehouse"] = {
        ipl = false,
        coords = {
            entrance = vector4(782.6, -2998.04, -69.0, 284.77),
            wardrobe = vector4(0, 0, 0, 0),
            stash = vector4(0, 0, 0, 0),
            logout = vector3(0, 0, 0),
        }
    },
    ["Fixer Office"] = {
        ipl = false,
        coords = {
            entrance = vector4(-1003.2, -774.7, 61.89, 356.88),
            wardrobe = vector4(0,0,0, 0),
            stash = vector4(0, 0, 0, 0),
            logout = vector3(0,0,0),
        }
    },
    ["Office"] = {
        ipl = false,
        coords = {
            entrance = vector4(-78.99, -829.41, 243.39, 249.68),
            wardrobe = vector4(-78.87, -811.43, 243.39, 170.82),
            stash = vector4(-81.78, -799.38, 243.39, 64.69),
            logout = vector3(-83.26, -809.64, 243.39),
        }
    },
    ["Basement"] = {
        ipl = false,
        coords = {
            entrance = vector4(844.23, -3004.99, -44.4, 3.57),
            wardrobe = vector4(0, 0, 0, 0),
            stash = vector4(0, 0, 0, 0),
            logout = vector3(0, 0, 0),
        }
    },
    ["Small Methlab"] = {
        ipl = false,
        coords = {
            entrance = vector4(482.35, -2623.92, -49.06, 183.29),
            wardrobe = vector4(0, 0, 0, 0),
            stash = vector4(0, 0, 0, 0),
            logout = vector3(0, 0, 0),
        }
    }
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

---@type { [string]: { ipl: string | false, coords: { entrance: vector4, slots: { index: vector4 }, styles: table} } }
Config.GarageIPLs = {
    ["Low End"] = {
        ipl = false,
        coords = {
            entrance = vector4(265.95, -1007.41, -101.01, 2.71),
            slots = {
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
            }
        }
    },
    ["Medium"] = {
        ipl = false,
        coords = {
            entrance = vector4(265.95, -1007.41, -101.01, 2.71),
            slots = {
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
            }
        }
    },
    ["High End"] = {
        ipl = false,
        coords = {
            entrance = vector4(265.95, -1007.41, -101.01, 2.71),
            slots = {
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
            }
        }
    },
    ["Fixer Office Garage"] = {
        ipl = false,
        coords = {
            entrance = vector4(-1067.1, -88.2, -90.2, 2.27),
            slots = {
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
            }
        }
    },
    ["Office Garage"] = {
        ipl = false,
        coords = {
            entrance = vector4(-91.35, -821.23, 222.0, 249.63),
            slots = {
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
                vec4(0, 0, 0, 0),
            }
        }
    },
    ["Eclipse Boulevard"] = { -- 10 slots garages of the Acid DLC
        ipl = false,
        coords = {
            entrance = vector4(531.65, -2637.61, -49.0, 89.55),
            slots = {
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
            }
        },
        styles = {
            Walls = {
                ["White"] = "entity_set_shell_01",
                ["Industrial"] = "entity_set_shell_02",
                ["Indulgent"] = "entity_set_shell_03",
            },
            Number = {
                ["1"] = "entity_set_numbers_01",
                ["2"] = "entity_set_numbers_02",
                ["3"] = "entity_set_numbers_03",
                ["4"] = "entity_set_numbers_04",
                ["5"] = "entity_set_numbers_05",
            },
            Tint = {
                color = true,
                entityset = "entity_set_tint_01",
                colors = {
                    ["White"] = 1,
                    ["Gray"] = 2,
                    ["Black"] = 3,
                    ["Purple"] = 4,
                    ["Orange"] = 5,
                    ["Yellow"] = 6,
                    ["Blue"] = 7,
                    ["Red"] = 8,
                    ["Green"] = 9,
                    ["Vintage Blue"] = 10,
                    ["Vintage Red"] = 11,
                    ["Vintage green"] = 12
                }
            },
        }
    },
    ["Casino"] = {
        ipl = false,
        coords = {
            entrance = vector4(1295, 230, -50, 0),
            slots = {
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
            }
        }
    },
    ["Casino Large"] = {
        ipl = false,
        coords = {
            entrance = vector4(1380, 200, -50, 0),
            slots = {
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
            }
        }
    },
    ["Nightclub"] = {
        ipl = false,
        coords = {
            entrance = vector4(-1521.01, -2978.57, -80.44, 272.48),
            slots = {
                vec4(-1518, -2988, -82.83, 200),
                vec4(-1514, -2988, -82.83, 200),
                vec4(-1510, -2988, -82.83, 200),
                vec4(-1506, -2988, -82.83, 200),
                vec4(-1502, -2988, -82.83, 200),
                vec4(-1498, -2988, -82.83, 200),
                vec4(-1498, -2998.5, -82.83, 20),
                vec4(-1502, -2998.5, -82.83, 20),
                vec4(-1506, -2998.5, -82.83, 20),
                vec4(-1510, -2998.5, -82.83, 20),
                vec4(-1514, -2998.5, -82.83, 20),
                vec4(-1518, -2998.5, -82.83, 20),
            }
        }
    },
    ["Autoshop"] = {
        ipl = false,
        coords = {
            entrance = vector4(265.95, -1007.41, -101.01, 2.71),
            slots = {
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
            }
        }
    },
    ["VineWood Car Club"] = {
        ipl = 'm23_1_dlc_int_02_m23_1',
        coords = {
            entrance = vector4(1200, -3250, -50, 0.0),
            slots = {},
        },
        styles = {
            Props = {
                ["Signs"] = "entity_set_signs",
                ["Plus"] = "entity_set_plus",
                ["Stairs"] = "entity_set_stairs",
                ["Backdrop Frames"] = "entity_set_backdrop_frames"
            }
        }
    },
    --[[ Can the garage be isolated from the rest of the interior ? :hmm:
    ["Arcade"] = {
        ipl = false,
        coords = {
            entrance = vector4(265.95, -1007.41, -101.01, 2.71),
            wardrobe = vector4(259.76, -1003.63, -99.01, 182.24),
            stash = vector4(265.8, -999.47, -99.01, 268.16),
            logout = vector3(262.9, -1003.09, -99.01),
            slots = {
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
            }
        }
    }, ]]
    ["Freak Shop"] = {
        ipl = false,
        coords = {
            entrance = vector4(570.0, -415.0, -70.0, 0),
            slots = {
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
            }
        }
    },
}