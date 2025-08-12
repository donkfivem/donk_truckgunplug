fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'donk'
description 'Gun Plug Script for Voodoo Garbage Truck'
version '1.0.0'

client_scripts {'client/client.lua', 'config.lua',}

shared_scripts {
  '@ox_lib/init.lua',
}

server_scripts {
  '@mysql-async/lib/MySQL.lua', -- If not using SQL, remove this line
  'config.lua',
  'server/server.lua',
}