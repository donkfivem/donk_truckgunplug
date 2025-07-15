fx_version 'cerulean'
games { 'gta5' }
author 'donk'
lua54 'yes'

client_scripts {'client/client.lua', 'config.lua',}

shared_scripts {
  '@ox_lib/init.lua',
}

server_scripts {
  '@mysql-async/lib/MySQL.lua', -- If not using SQL, remove this line
  'config.lua',
  'server/server.lua',
}