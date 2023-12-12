fx_version 'cerulean'
game 'gta5'

description 'Hopefully one day a feature rich property system'
repository 'https://github.com/Qbox-project/qbx_properties'
version '0.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/utils.lua',
    '@qbx_core/shared/locale.lua',
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