Config = {}
Config.VehicleModel = 'garbagedoo' -- DONT CHANGE ONLY WORKS WITH THIS MODEL!
Config.Rewards = {
    Type = 'ox_inventory', -- DONT CHANGE UNLESS IF YOU KNOW WHAT YOU'RE DOING!
    Rewards = { -- itemName = rewardCount
        'WEAPON_PISTOL',
        -- 'WEAPON_PISTOL',
        -- 'WEAPON_PISTOL',
        -- 'WEAPON_PISTOL',
    }
}

Config.DiscordLogs = {
    Enabled = false, -- If enabled, it will send a discord log once a player redeems a gunplug
    Webhook = '',
    Embed = {
        Color = 0, -- Use decimal color code
        Username = 'Donk Gunplug',
        UserIcon = 'https://r2.fivemanage.com/oosFEgKFisbM36c2K1JXV/3b6b68ae80a6710a5a31c7872ccb68fe.png'
    }
}

Config.Whitelisted = {
    Enabled = true, -- Whitelist command access?
    Type = 'donk_api', -- DONT CHANGE
}

Config.Cooldown = {
    Enabled = true, -- Cooldown enabled?
    Time = 30, -- Time in days to wait before redeeming again
    Type = 1, -- 1 = MySQL (highly recommended) | 2 = JSON
    Identifier = 'discord' -- Identifier to save it to (discord is default) [discord, license, steam, xbl, live, fivem]
}

Config.Strings = {
    ['Prefix'] = '^1Gunplug',
    ['NotWhitelisted'] = 'You are not whitelisted to use this command!',
    ['Cooldown'] = 'You still need to wait {TIME_REMAINING} more day(s) before claiming again!',
    ['Success'] = 'You have successfully claimed your gunplug!',

    -- Discord log strings
    ['LOGS_Title'] = 'Gunplug Claimed',
    ['LOGS_Description'] = 'A player claimed there gunplug and got there rewards!',
}