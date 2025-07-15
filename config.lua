Config = {}

Config.VehicleModel = 'garbagedoo'

Config.Rewards = {
    Type = 'ox_inventory',
    OX = 'ox_inventory',  -- Used for export to giveitem via inventory
    Rewards = { -- itemName = rewardCount
        'WEAPON_G29',
        'WEAPON_MGLOCK',
        'WEAPON_TIRACG19',
        'WEAPON_CAMOG17S',
    }
}

Config.DiscordLogs = {
    Enabled = false, -- If enabled, it will send a discord log once a player redeems a gunplug
    Webhook = '',
    Embed = {
        Color = 0, -- Use decimal color code
        Username = 'Gunplug',
        UserIcon = 'https://imgur.com/L2Z2upC.png'
    }
}

Config.Whitelisted = {
    Enabled = true, -- Whitelist command access?
    Type = 'api', -- DONT CHANGE
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