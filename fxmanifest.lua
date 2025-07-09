fx_version 'cerulean'

game 'gta5'

author 'MGH Development'
description 'Vangelico Robbery - MGH Edition'
version '1.0.0'

client_scripts {
	'client/*.lua',
}

server_scripts {
	'server/*.lua'
}

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua', 
	'@ox_lib/init.lua',
	'locales/*.lua',
	'shared/*.lua',
	'config.lua'
}

dependencies {
	'es_extended',
	'ox_lib',
}

lua54 'yes'