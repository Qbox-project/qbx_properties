fx_version 'cerulean'
game 'gta5'

name 'qbx_properties'
description 'Hopefully one day a feature rich property system'
repository 'https://github.com/Qbox-project/qbx_properties'
version '0.0.1'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'shared/main.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/apartmentselect.lua',
    'client/property.lua',
    'client/realtor.lua',
    'client/dataview.lua',
    'client/decorating.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/apartmentselect.lua',
    'server/property.lua',
    'server/realtor.lua',
    --'server/decorating.js' only used for taking screenshots of furniture
}

files {
    'config/client.lua',
    'config/shared.lua',
    'locales/*.json',
    'screenshots/*.png'
}

lua54 'yes'
use_experimental_fxv2_oal 'true'