fx_version "cerulean"
game "gta5"
lua54 "yes"
author "Pandateam"
client_scripts {
    "client.lua"
}

server_scripts {
    "server.lua",
    '@oxmysql/lib/MySQL.lua'
}

shared_scripts {
    "config.lua",
    "@es_extended/imports.lua",
    "@ox_lib/init.lua"
}
files {
    "html/*.*"
}
ui_page "html/*.html"