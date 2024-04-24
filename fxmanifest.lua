fx_version 'cerulean'
game 'gta5'

version '0.0.1'
repository 'https://github.com/Qbox-project/qbx_properties'
description 'Hopefully one day a feature rich property system'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'config/shared.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/apartmentselect.lua',
    'client/property.lua',
    'client/realtor.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/apartmentselect.lua',
    'server/property.lua',
    'server/realtor.lua',
    'config/server.lua'
}

files {
    'locales/*.json'
}

lua54 'yes'
use_experimental_fxv2_oal 'true'
