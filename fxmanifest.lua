fx_version 'cerulean'
game 'gta5'

version '0.0.1'
repository 'https://github.com/Qbox-project/qbx_properties'
description 'Hopefully one day a feature rich property system'

shared_scripts {
    '@qbx_core/modules/utils.lua',
    '@qbx_core/shared/locale.lua',
    '@ox_lib/init.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

lua54 'yes'
use_experimental_fxv2_oal 'true'