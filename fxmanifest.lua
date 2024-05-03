fx_version 'cerulean'
game 'gta5'
lua54 'on'
name "Koja-Jobcenter"
author "KojaScripts <discord.gg/kojascripts>"
version "1.0"
description "Koja Jobcenter Manager"

shared_scripts {
    "@ox_lib/init.lua", -- if you are using ox
    "shared/**/*"
}

client_scripts {
	'client/client.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua', -- if you are using oxmysql
	--'@mysql-async/lib/MySQL.lua', -- if you are using mysql
	'server/server.lua',
	'server_config.lua'
}

files {
	'html/ui.html',
	'html/font/*.ttf',
	'html/font/*.otf',
	'html/css/*.css',
	'html/images/*.jpg',
	'html/images/*.png',
	'html/js/*.js',
}

ui_page {
	'html/ui.html'
}
