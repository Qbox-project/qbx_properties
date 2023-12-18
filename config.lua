Config = {}

Config.useApartments = true -- false to disable apartments
Config.useProperties = true -- false to disable properties

Config.InteriorZones = {
    entrance = {
        marker = {
            type = 25,
            offsetZ = -0.95,
            color = {r = 82, g = 145, b = 170, a = 155},
            scale = {x = 0.8, y = 0.8, z = 0.8},
        },
    },
    wardrobe = {
        marker = {
            type = 25,
            offsetZ = -0.95,
            color = {r = 82, g = 145, b = 170, a = 155},
            scale = {x = 0.8, y = 0.8, z = 0.8},
        },
    },
    stash = {
        marker = {
            type = 25,
            offsetZ = -0.95,
            color = {r = 82, g = 145, b = 170, a = 155},
            scale = {x = 0.8, y = 0.8, z = 0.8},
        },
    },
    logout = {
        marker = {
            type = 25,
            offsetZ = -0.95,
            color = {r = 82, g = 145, b = 170, a = 155},
            scale = {x = 0.8, y = 0.8, z = 0.8},
        },
    },
    manage = {
        marker = {
            type = 25,
            offsetZ = -0.95,
            color = {r = 82, g = 145, b = 170, a = 155},
            scale = {x = 0.8, y = 0.8, z = 0.8},
        },
    },
}

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
    --- @type { [string]: number }
    --- rent commission is fixed, buy commission can be adjusted
    realtorCommission = {
        default = 5,
        min = 1,
        max = 15,
        rent = 5,
    },
    --- How long to rent/extend rent for (in days)
    rentTime = 7,
    realtorsBuyThemselves = true,
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
        coords = vec4(-271.1, -957.5, 31.22, 291.66),
        IPL = "LowEnd", -- Config.IPLS["LowEnd"]
    },{
        name = "Morningwood Blvd",
        coords = vec4(-1288.52, -430.51, 35.15, 124.81),
        IPL = "LowEnd",
    },{
        name = "Tinsel Towers",
        coords = vec4(-619.29, 37.69, 43.59, 181.03),
        IPL = "LowEnd",
    },{
        name = "Fantastic Plaza",
        coords = vec4(291.517, -1078.674, 29.405, 270.75),
        IPL = "LowEnd",
    },
}

---@type { [string]: { label: string, ipl: string | false, coords: { entrance: vector4, wardrobe: vector4 | boolean, stash: vector4, manage: vector3, logout: vector3 | boolean }, style: table | nil } }
Config.IPLS = { -- 'Ipls' can just be interiors that aren't proper IPLs, but are still interiors
    alta_street = {
        label = "Alta Street",
        ipl = false,
        coords = {
            entrance = vec4(-271.87, -940.34, 92.51, 70),
            wardrobe = vec4(-277.79, -960.54, 86.31, 70),
            stash = vec4(-272.98, -950.01, 92.52, 70),
            logout = vec3(-283.27, -959.68, 70),
        }
    },
    eclipse_tower = {
        label = "Eclipse Tower",
        ipl = "apa_v_mp_h_01_a",
        coords = {
            entrance = vec4(-786.866, 315.764, 217.638, 160),
            manage = vec3(-788.66, 320.83, 217.04),
            wardrobe = vec4(-797.97, 329.0, 220.44, 172.76),
            stash = vec4(-796.04, 326.82, 217.04, 348.06),
            logout = vec3(-795.9, 336.0, 220.44),
        }
    },
    low_end = {
        label = "Low End",
        ipl = false,
        coords = {
            entrance = vec4(265.95, -1007.41, -101.01, 2.71),
            wardrobe = vec4(259.76, -1003.63, -99.01, 182.24),
            stash = vec4(265.8, -999.47, -99.01, 268.16),
            logout = vec3(262.9, -1003.09, -99.01),
        }
    },
    franklin = {
        label = "Franklin House",
        ipl = false,
        coords = {
            entrance = vec4(7.66, 538.31, 176.03, 170),
            wardrobe = vec4(8.65, 528, 170.62, 300),
            stash = vec4(9.2, 535.55, 170.62, 206.48),
            logout = vec3(0, 523, 170.62),
        }
    },
    warehouse = {
        label = "Warehouse",
        ipl = false,
        coords = {
            entrance = vec4(782.6, -2998.04, -69.0, 284.77),
            wardrobe = false,
            stash = vec4(787.85, -2991.92, -69.0, 272.58),
            logout = false,
        }
    },
    fixer_office = {
        label = "Fixer Office",
        ipl = false,
        coords = {
            entrance = vec4(-1003.2, -774.7, 61.89, 356.88),
            wardrobe = vec4(-997.55, -748.18, 70.49, 267.34),
            stash = vec4(-1004.25, -758.83, 70.49, 184.27),
            logout = vec3(-997.15, -757.16, 70.49),
        }
    },
    office = {
        label = "Office",
        ipl = false,
        coords = {
            entrance = vec4(-78.99, -829.41, 243.39, 249.68),
            wardrobe = vec4(-78.87, -811.43, 243.39, 170.82),
            stash = vec4(-81.78, -799.38, 243.39, 64.69),
            logout = vec3(-83.26, -809.64, 243.39),
        }
    },
    basement = {
        label = "Basement",
        ipl = false,
        coords = {
            entrance = vec4(844.23, -3004.99, -44.4, 3.57),
            wardrobe = vec4(0, 0, 0, 0),
            stash = vec4(0, 0, 0, 0),
            logout = vec3(0, 0, 0),
        }
    },
    small_methlab = {
        label = "Small Methlab",
        ipl = false,
        coords = {
            entrance = vec4(482.35, -2623.92, -49.06, 183.29),
            wardrobe = vec4(0, 0, 0, 0),
            stash = vec4(0, 0, 0, 0),
            logout = vec3(0, 0, 0),
        }
    }
}

Config.Shells = {
--[[
    shell_name = {
        label = string, -- label for the shell
        shell = string, -- shell object/prop
        offsets = {
            entrance = vec4(0, 0, 0, 0), -- required
            wardrobe = vec4(0, 0, 0, 0), -- required
            stash = vec4(0, 0, 0, 0), -- required
            manage = vec4(0, 0, 0, 0) -- required
            logout = vec3(0, 0, 0), -- required
        }
    } ]]
}

---@type { [string]: { label: string, ipl: string | false, coords: { entrance: vector4, slots: { index: vector4 }, manage: vector4}, style: table } }
Config.GarageIPLs = {
    low_end = {
        label = "Low End",
        ipl = false,
        coords = {
            entrance = vec4(179, -1000.5, -99.0, 180),
            manage = vec3(173.03, -1000.27, -99.0),
            slots = {
                vec4(171.5, -1004.5, -99.61, 180),
                vec4(175, -1004.5, -99.61, 180),
            }
        }
    },
    medium = {
        label = "Medium",
        ipl = false,
        coords = {
            entrance = vec4(212, -999, -99.0, 90),
            manage = vec3(205.78, -995.11, -99.0),
            slots = {
                vec4(202, -998, -99.5, 150),
                vec4(198, -998, -99.5, 150),
                vec4(194, -998, -99.5, 150),
                vec4(194, -1004, -99.5, 20),
                vec4(198, -1004, -99.5, 20),
                vec4(202, -1004, -99.5, 20),
            }
        }
    },
    high_end = {
        label = "High End",
        ipl = false,
        coords = {
            entrance = vec4(240.5, -1005, -99.0, 90),
            manage = vec3(235, -976.25, -99.0),
            slots = {
                vec4(223, -1000, -99.65, 240),
                vec4(223, -996, -99.65, 240),
                vec4(223, -992, -99.65, 240),
                vec4(223, -988, -99.65, 240),
                vec4(223, -984, -99.65, 240),
                vec4(233.5, -984, -99.65, 120),
                vec4(233.5, -988, -99.65, 120),
                vec4(233.5, -992, -99.65, 120),
                vec4(233.5, -996, -99.65, 120),
                vec4(233.5, -1000, -99.65, 120),
            }
        }
    },
    fixer_garage = {
        label = "Fixer Office Garage",
        ipl = false,
        coords = {
            entrance = vec4(-1067.1, -88.2, -90.2, 2.27),
            manage = vec3(-1069.78, -90.9, -90.2),
            slots = {
                vec4(-1079.5, -84.75, -99.61, 270),
                vec4(-1079.5, -81.0, -99.61, 270),
                vec4(-1079.5, -76.5, -99.61, 270),
                vec4(-1079.5, -72.75, -99.61, 270),
                vec4(-1079.5, -68.25, -99.61, 270),
                vec4(-1065.5, -64.5, -99.61, 90),
                vec4(-1065.5, -68.5, -99.61, 90),
                vec4(-1065.5, -72.75, -99.61, 90),
                vec4(-1065.5, -76.5, -99.61, 90),
                vec4(-1065.5, -81, -99.61, 90),
                vec4(-1079.5, -84.75, -95.21, 270),
                vec4(-1079.5, -81.0, -95.21, 270),
                vec4(-1079.5, -76.5, -95.21, 270),
                vec4(-1079.5, -72.75, -95.21, 270),
                vec4(-1079.5, -68.25, -95.21, 270),
                vec4(-1065.5, -64.5, -95.21, 90),
                vec4(-1065.5, -68.5, -95.21, 90),
                vec4(-1065.5, -72.75, -95.21, 90),
                vec4(-1065.5, -76.5, -95.21, 90),
                vec4(-1065.5, -81, -95.21, 90),
                vec4(-1079.5, -84.75, -84.95, 270),
                vec4(-1079.5, -81.0, -84.95, 270),
                vec4(-1079.5, -76.5, -84.95, 270),
                vec4(-1079.5, -72.75, -84.95, 270),
                vec4(-1079.5, -68.25, -84.95, 270),
            }
        },
        style = {
            Props = {
                Entity_Set_Art_1 = "Entity_Set_Art_1",
                Entity_Set_Art_1_NoMod = "Entity_Set_Art_1_NoMod",
                Entity_Set_Art_2 = "Entity_Set_Art_2",
                Entity_Set_Art_2_NoMod = "Entity_Set_Art_2_NoMod",
                Entity_Set_Art_3 = "Entity_Set_Art_3",
                Entity_Set_Art_3_NoMod = "Entity_Set_Art_3_NoMod",
                Entity_Set_Wallpaper_01 = "Entity_Set_Wallpaper_01",
                Entity_Set_Wallpaper_02 = "Entity_Set_Wallpaper_02",
                Entity_Set_Wallpaper_03 = "Entity_Set_Wallpaper_03",
                Entity_Set_Wallpaper_04 = "Entity_Set_Wallpaper_04",
                Entity_Set_Wallpaper_05 = "Entity_Set_Wallpaper_05",
                Entity_Set_Wallpaper_06 = "Entity_Set_Wallpaper_06",
                Entity_Set_Wallpaper_07 = "Entity_Set_Wallpaper_07",
                Entity_Set_Wallpaper_08 = "Entity_Set_Wallpaper_08",
                Entity_Set_Wallpaper_09 = "Entity_Set_Wallpaper_09",
                Entity_Set_Workshop_Lights = "Entity_Set_Workshop_Lights",
                Entity_Set_Workshop_Wall = "Entity_Set_Workshop_Wall"

            },
            Tint = {
                entityset = "entity_set_tints",
                colors = {
                    Black = 0,
                    Green = 1,
                    Vintage_Green = 2,
                    Gray = 3,
                    Purple = 4,
                    Red = 5,
                    Brown = 6,
                    White = 7,
                    Yellow = 8
                }
            },
        }
    },
    office_garage = {
        label = "Office Garage",
        ipl = false,
        coords = {
            entrance = vec4(-91.35, -821.23, 222.0, 249.63),
            manage = vec3(-90.36, -819.68, 222.0),
            slots = {
                vec4(-80.5, -818.2, 221.39, 180),
                vec4(-74.5, -820, 221.39, 160),
                vec4(-70, -822, 221.39, 140),
                vec4(-67, -826, 221.39, 120),
                vec4(-67, -832, 221.39, 70),
                vec4(-70, -836.5, 221.4, 45),
                vec4(-85.5, -819, 226.75, 200),
                vec4(-80, -818, 226.74, 170),
                vec4(-75, -819.5, 226.74, 170),
                vec4(-70, -822, 226.74, 140),
                vec4(-67, -826.5, 226.74, 110),
                vec4(-67, -832, 226.74, 70),
                vec4(-70, -836, 226.75, 45),
                vec4(-85.5, -819, 232.1, 200),
                vec4(-80, -817.5, 232.1, 170),
                vec4(-75, -819.5, 232.1, 170),
                vec4(-70.5, -822, 232.1, 140),
                vec4(-67, -826, 232.1, 110),
                vec4(-67, -832, 232.1, 70),
                vec4(-70, -836, 232.1, 45),
            }
        },
        style ={
            Props = {
                garage_decor_01 = "garage_decor_01",
                garage_decor_02 = "garage_decor_02",
                garage_decor_03 = "garage_decor_03",
                garage_decor_04 = "garage_decor_04",
                lighting_option01 = "lighting_option01",
                lighting_option02 = "lighting_option02",
                lighting_option03 = "lighting_option03",
                lighting_option04 = "lighting_option04",
                lighting_option05 = "lighting_option05",
                lighting_option06 = "lighting_option06",
                lighting_option07 = "lighting_option07",
                lighting_option08 = "lighting_option08",
                lighting_option09 = "lighting_option09",
            },
            Number = {
                numbering_style01_n1 = "numbering_style01_n1",
                numbering_style01_n2 = "numbering_style01_n2",
                numbering_style01_n3 = "numbering_style01_n3",
                numbering_style02_n1 = "numbering_style02_n1",
                numbering_style02_n2 = "numbering_style02_n2",
                numbering_style02_n3 = "numbering_style02_n3",
                numbering_style03_n1 = "numbering_style03_n1",
                numbering_style03_n2 = "numbering_style03_n2",
                numbering_style03_n3 = "numbering_style03_n3",
                numbering_style04_n1 = "numbering_style04_n1",
                numbering_style04_n2 = "numbering_style04_n2",
                numbering_style04_n3 = "numbering_style04_n3",
                numbering_style05_n1 = "numbering_style05_n1",
                numbering_style05_n2 = "numbering_style05_n2",
                numbering_style05_n3 = "numbering_style05_n3",
                numbering_style06_n1 = "numbering_style06_n1",
                numbering_style06_n2 = "numbering_style06_n2",
                numbering_style06_n3 = "numbering_style06_n3",
                numbering_style07_n1 = "numbering_style07_n1",
                numbering_style07_n2 = "numbering_style07_n2",
                numbering_style07_n3 = "numbering_style07_n3",
                numbering_style08_n1 = "numbering_style08_n1",
                numbering_style08_n2 = "numbering_style08_n2",
                numbering_style08_n3 = "numbering_style08_n3",
                numbering_style09_n1 = "numbering_style09_n1",
                numbering_style09_n2 = "numbering_style09_n2",
                numbering_style09_n3 = "numbering_style09_n3"
            }
        }
    },
    eclipse_boulevard = { -- 10 slots garages of the Acid DLC
        label = "Eclipse Boulevard",
        ipl = false,
        coords = {
            entrance = vec4(531.65, -2637.61, -49.0, 89.55),
            manage = vec3(526.33, -2609.42, -49.0),
            slots = {
                vec4(515, -2613.5, -49.61, 250),
                vec4(515, -2618, -49.61, 250),
                vec4(515, -2622.5, -49.61, 250),
                vec4(515, -2627, -49.61, 250),
                vec4(515, -2631.5, -49.61, 250),
                vec4(515, -2636, -49.61, 250),
                vec4(524.5, -2613.5, -49.61, 120),
                vec4(524.5, -2618, -49.61, 120),
                vec4(524.5, -2622.5, -49.61, 120),
                vec4(524.5, -2627, -49.61, 120),
                vec4(524.5, -2631.5, -49.61, 120)
            }
        },
        style = {
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
                entityset = "entity_set_tint_01",
                colors = {
                    White = 1,
                    Gray = 2,
                    Black = 3,
                    Purple = 4,
                    Orange = 5,
                    Yellow = 6,
                    Blue = 7,
                    Red = 8,
                    Green = 9,
                    Vintage_Blue = 10,
                    Vintage_Red = 11,
                    Vintage_green = 12
                }
            },
        }
    },
    casino = {
        label = "Casino",
        ipl = false,
        coords = {
            entrance = vec4(1295.39, 219.53, -49.06, 0.0),
            manage = vec3(1295.39, 225.43, -49.06),
            slots = {
                vec4(1280, 241.0, -49.66, 270),
                vec4(1281, 249.6, -49.66, 270),
                vec4(1281, 258.2, -49.66, 270),
                vec4(1310, 258.2, -49.66, 90),
                vec4(1310, 249.6, -49.66, 90),
                vec4(1310, 241.0, -49.66, 90),
                vec4(1310, 232.4, -49.66, 90),
                vec4(1295.3, 232.2, -49.66, 5),
                vec4(1295.3, 241.0, -49.66, 5),
                vec4(1295.3, 249.6, -49.66, 5),
            }
        }
    },
    casino_large = {
        label = "Casino Large",
        ipl = false,
        coords = {
            entrance = vec4(1380.16, 180.25, -49.0, 0),
            manage = vec3(1380.11, 186.08, -49.0),
            slots = {
                vec4(1366.5, 200.3, -49.6, 270.0),
                vec4(1366.5, 204.5, -49.6, 270.0),
                vec4(1366.5, 208.5, -49.6, 270.0),
                vec4(1366.5, 213, -49.6, 270.0),
                vec4(1366.5, 216.5, -49.6, 270.0),
                vec4(1366.5, 220.5, -49.6, 270.0),
                vec4(1366.5, 225.25, -49.6, 270.0),
                vec4(1366.5, 229.25, -49.6, 270.0),
                vec4(1366.5, 225.25, -49.6, 270.0),
                vec4(1366.5, 233.75, -49.6, 270.0),
                vec4(1366.5, 237.75, -49.6, 270.0),
                vec4(1366.5, 242, -49.6, 270.0),
                vec4(1366.5, 246.25, -49.6, 270.0),
                vec4(1366.5, 250.25, -49.6, 270.0),
                vec4(1366.5, 254.5, -49.6, 270.0),
                vec4(1395, 254.5, -49.6, 90.0),
                vec4(1395, 250.25, -49.6, 90.0),
                vec4(1395, 246.25, -49.6, 90.0),
                vec4(1395, 242.0, -49.6, 90.0),
                vec4(1395, 237.75, -49.6, 90.0),
                vec4(1395, 233.75, -49.6, 90.0),
                vec4(1395, 225.25, -49.6, 90.0),
                vec4(1395, 229.25, -49.6, 90.0),
                vec4(1395, 225.25, -49.6, 90.0),
                vec4(1395, 220.5, -49.6, 90.0),
                vec4(1395, 216.5, -49.6, 90.0),
                vec4(1395, 213.0, -49.6, 90.0),
                vec4(1395, 208.5, -49.6, 90.0),
                vec4(1395, 204.5, -49.6, 90.0),
                vec4(1395, 200.3, -49.6, 90.0),
                vec4(1380, 208.75, -49.6, 270),
                vec4(1380, 212.75, -49.6, 270),
                vec4(1380, 217, -49.6, 270),
                vec4(1380, 221.25, -49.6, 270),
                vec4(1380, 225.25, -49.6, 270),
                vec4(1380, 229.25, -49.6, 270),
                vec4(1380, 233.5, -49.6, 270),
                vec4(1380, 237.75, -49.6, 270),
                vec4(1380, 241.75, -49.6, 270),
                vec4(1380, 246, -49.6, 270)
            }
        }
    },
    nightclub_garage = {
        label = "Nightclub Garage",
        ipl = false,
        coords = {
            entrance = vec4(-1521.01, -2978.57, -80.44, 272.48),
            manage = vec3(-1521.14, -2993.43, -82.21),
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
        },
        style = {
            Number = {
                ["Int02_ba_floor01"] = "Int02_ba_floor01",
                ["Int02_ba_floor02"] = "Int02_ba_floor02",
                ["Int02_ba_floor03"] = "Int02_ba_floor03",
                ["Int02_ba_floor04"] = "Int02_ba_floor04",
                ["Int02_ba_floor05"] = "Int02_ba_floor05",
            },
            --[[ all the other entity sets
            Props = {
                ["Int02_ba_Cash_EQP"] = "Int02_ba_Cash_EQP",
                ["Int02_ba_Cash01"] = "Int02_ba_Cash01",
                ["Int02_ba_Cash02"] = "Int02_ba_Cash02",
                ["Int02_ba_Cash03"] = "Int02_ba_Cash03",
                ["Int02_ba_Cash04"] = "Int02_ba_Cash04",
                ["Int02_ba_Cash05"] = "Int02_ba_Cash05",
                ["Int02_ba_Cash06"] = "Int02_ba_Cash06",
                ["Int02_ba_Cash07"] = "Int02_ba_Cash07",
                ["Int02_ba_Cash08"] = "Int02_ba_Cash08",
                ["Int02_ba_clutterstuff"] = "Int02_ba_clutterstuff",
                ["Int02_ba_coke_EQP"] = "Int02_ba_coke_EQP",
                ["Int02_ba_coke01"] = "Int02_ba_coke01",
                ["Int02_ba_coke02"] = "Int02_ba_coke02",
                ["Int02_ba_DeskPC"] = "Int02_ba_DeskPC",
                ["Int02_ba_equipment_upgrade"] = "Int02_ba_equipment_upgrade",
                ["Int02_ba_FanBlocker01"] = "Int02_ba_FanBlocker01",
                ["Int02_ba_Forged_EQP"] = "Int02_ba_Forged_EQP",
                ["Int02_ba_Forged01"] = "Int02_ba_Forged01",
                ["Int02_ba_Forged02"] = "Int02_ba_Forged02",
                ["Int02_ba_Forged03"] = "Int02_ba_Forged03",
                ["Int02_ba_Forged04"] = "Int02_ba_Forged04",
                ["Int02_ba_Forged05"] = "Int02_ba_Forged05",
                ["Int02_ba_Forged06"] = "Int02_ba_Forged06",
                ["Int02_ba_Forged07"] = "Int02_ba_Forged07",
                ["Int02_ba_Forged08"] = "Int02_ba_Forged08",
                ["Int02_ba_Forged09"] = "Int02_ba_Forged09",
                ["Int02_ba_Forged10"] = "Int02_ba_Forged10",
                ["Int02_ba_Forged11"] = "Int02_ba_Forged11",
                ["Int02_ba_Forged12"] = "Int02_ba_Forged12",
                ["Int02_ba_garage_blocker"] = "Int02_ba_garage_blocker",
                ["Int02_ba_meth_EQP"] = "Int02_ba_meth_EQP",
                ["Int02_ba_meth01"] = "Int02_ba_meth01",
                ["Int02_ba_meth02"] = "Int02_ba_meth02",
                ["Int02_ba_meth03"] = "Int02_ba_meth03",
                ["Int02_ba_meth04"] = "Int02_ba_meth04",
                ["Int02_ba_sec_desks_L1"] = "Int02_ba_sec_desks_L1",
                ["Int02_ba_sec_desks_L2345"] = "Int02_ba_sec_desks_L2345",
                ["Int02_ba_sec_upgrade_desk"] = "Int02_ba_sec_upgrade_desk",
                ["Int02_ba_sec_upgrade_desk02"] = "Int02_ba_sec_upgrade_desk02",
                ["Int02_ba_sec_upgrade_grg"] = "Int02_ba_sec_upgrade_grg",
                ["Int02_ba_sec_upgrade_strg"] = "Int02_ba_sec_upgrade_strg",
                ["Int02_ba_storage_blocker"] = "Int02_ba_storage_blocker",
                ["Int02_ba_truckmod"] = "Int02_ba_truckmod",
                ["Int02_ba_Weed_EQP"] = "Int02_ba_Weed_EQP",
                ["Int02_ba_Weed01"] = "Int02_ba_Weed01",
                ["Int02_ba_Weed02"] = "Int02_ba_Weed02",
                ["Int02_ba_Weed03"] = "Int02_ba_Weed03",
                ["Int02_ba_Weed04"] = "Int02_ba_Weed04",
                ["Int02_ba_Weed05"] = "Int02_ba_Weed05",
                ["Int02_ba_Weed06"] = "Int02_ba_Weed06",
                ["Int02_ba_Weed07"] = "Int02_ba_Weed07",
                ["Int02_ba_Weed08"] = "Int02_ba_Weed08",
                ["Int02_ba_Weed09"] = "Int02_ba_Weed09",
                ["Int02_ba_Weed10"] = "Int02_ba_Weed10",
                ["Int02_ba_Weed11"] = "Int02_ba_Weed11",
                ["Int02_ba_Weed12"] = "Int02_ba_Weed12",
                ["Int02_ba_Weed13"] = "Int02_ba_Weed13",
                ["Int02_ba_Weed14"] = "Int02_ba_Weed14",
                ["Int02_ba_Weed15"] = "Int02_ba_Weed15",
                ["Int02_ba_Weed16"] = "Int02_ba_Weed16"
            } ]]
        }
    },
    autoshop = {
        label = "Autoshop",
        ipl = false,
        coords = {
            entrance = vec4(265.95, -1007.41, -101.01, 2.71),
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
    vineWood_car_club = {
        label = "VineWood Car Club",
        ipl = 'm23_1_dlc_int_02_m23_1',
        coords = {
            entrance = vec4(1181.0, -3260.5, -48.0, 270.49),
            manage = vec3(1212.54, -3248.92, -49.0),
            slots = {
                vec4(1182, -3253.0, -49.49, 240),
                vec4(1190, -3247.5, -49.42, 200),
                vec4(1195, -3247.5, -49.42, 200),
                vec4(1200, -3247.5, -49.42, 200),
                vec4(1205, -3247.5, -49.42, 200),
                vec4(1210, -3247.5, -49.42, 200),
                vec4(1210, -3247.5, -49.42, -20),
                vec4(1205, -3257.5, -49.42, -20),
                vec4(1200, -3257.5, -49.42, -20),
                vec4(1195, -3257.5, -49.42, -20),
                vec4(1190, -3257.5, -49.42, -20)
            },
        },
        style = {
            Props = {
                ["Signs"] = "entity_set_signs",
                ["Plus"] = "entity_set_plus",
                ["Stairs"] = "entity_set_stairs",
                ["Backdrop Frames"] = "entity_set_backdrop_frames"
            }
        }
    },
    --[[ Can the garage be isolated from the rest of the interior ? :hmm:
    arcade = {
        label = "Arcade",
        ipl = false,
        coords = {
            entrance = vec4(265.95, -1007.41, -101.01, 2.71),
            wardrobe = vec4(259.76, -1003.63, -99.01, 182.24),
            stash = vec4(265.8, -999.47, -99.01, 268.16),
            logout = vec3(262.9, -1003.09, -99.01),
            slots = {
                vec4(265.95, -1007.41, -101.01, 2.71),
                vec4(265.95, -1007.41, -101.01, 2.71),
            }
        }
    }, ]]
    freak_shop = {
        label = "Freak Shop",
        ipl = false,
        coords = {
            entrance = vec4(570.0, -415.0, -70.0, 0),
            slots = {
                vec4(0, 0, 0 ,0),
                vec4(0, 0, 0 ,0),
            }
        }
    },
}