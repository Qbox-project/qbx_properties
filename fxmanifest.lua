fx_version 'cerulean'
game 'gta5'

version '0.0.1'
repository 'https://github.com/Qbox-project/qbx-properties'
description 'Hopefully one day a feature rich property system'

shared_scripts {
    '@qbx-core/import.lua',
    '@qbx-core/shared/locale.lua',
    '@ox_lib/init.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

modules {
    'qbx-core:core',
    'qbx-core:utils'
}

lua54 'yes'
use_experimental_fxv2_oal 'true'