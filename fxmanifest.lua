fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'TheStoicBear'
description 'Stoic-PhoneExchange'
version '1.0'

client_script 'client.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
} 

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}
files {
    'index.html'
}

ui_page 'index.html'
