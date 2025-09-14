fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Leevi81'
description 'Trash searching resource for FiveM'
version '1.0.1'

client_scripts {
    'client/*.lua'
}

ox_lib 'locale'

server_scripts {
    'server/*.lua'
}

shared_scripts {
    '@ox_lib/init.lua'
}

files {
    'config/*.lua'
    'locales/*.json'
}