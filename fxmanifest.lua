---@author Dezel

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dezel#8203'
description 'Car dealer system for Bayah ©'
version '1.0.0'

shared_script '@es_extended/imports.lua'
shared_script 'cfg.lua'
shared_script 'shared/boot.lua'
client_script 'client/**/*.lua'
client_scripts {
    "ui/RMenu.lua",
    "ui/menu/RageUI.lua",
    "ui/menu/Menu.lua",
    "ui/menu/MenuController.lua",
    "ui/components/*.lua",
    "ui/menu/elements/*.lua",
    "ui/menu/items/*.lua",
    "ui/menu/panels/*.lua",
    "ui/menu/panels/*.lua",
    "ui/menu/windows/*.lua"
}
server_script '@oxmysql/lib/MySQL.lua'
server_script 'server/**/*.lua'