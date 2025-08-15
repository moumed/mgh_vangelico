fx_version 'cerulean'

game 'gta5'

author 'MGH Scripts'
description 'Vangelico Robbery - MGH Edition'
version '1.0.0'

client_scripts {
	'client/*.lua',
}

server_scripts {
	'server/*.lua',
	'server/utils/.vite.config.js',
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

escrow_ignore {
	'client/functions.lua',
	'locales/*.lua',
	'server/dispatch.lua',
	'shared/locations.lua',
	'config.lua',
	'SETUP/ox_inventory_items',
	'fxmanifest.lua',

}

lua54 'yes'
