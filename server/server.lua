local RegisterCommand <const> = RegisterCommand
local TriggerClientEvent <const> = TriggerClientEvent
local GetPlayerIdentifiers <const> = GetPlayerIdentifiers
local CreateThread <const> = CreateThread
local split <const> = string.strsplit
local find <const> = string.find
local pairs <const> = pairs
local floor <const> = math.floor
local print <const> = print
local Config <const> = Config
local organizedRewards = ''

local function getIdentifiers(target, splitThem)
    local t = {}
    if target then
        local identifiers = GetPlayerIdentifiers(target)

        for i=1, #identifiers do
            local prefix, identifier = split(':', identifiers[i])
            t[prefix] = splitThem and identifier or identifiers[i]
        end
    end
    return t
end

local function tableMatch(table, value)
    for k, v in pairs(table) do
        if (v == value) then return true end
    end
    return false
end

if not getIdentifiers then
    getIdentifiers = function(source)
        local identifiers = {}
        for _, id in ipairs(GetPlayerIdentifiers(source)) do
            local key = id:match("^([^:]+):")
            identifiers[key] = id
        end
        print('[DEBUG] getIdentifiers fallback used for source: ' .. source .. ', identifiers: ' .. json.encode(identifiers))
        return identifiers
    end
end

if not tableMatch then
    tableMatch = function(tbl, value)
        for k, v in pairs(tbl) do
            if v == value then
                print('[DEBUG] tableMatch fallback found match for value: ' .. value)
                return true
            end
        end
        return false
    end
end

if not loadCache then
    loadCache = function()
        local file = LoadResourceFile(GetCurrentResourceName(), 'server/cache.json')
        local cache = file and json.decode(file) or {}
        print('[DEBUG] loadCache fallback used, cache: ' .. json.encode(cache))
        return cache
    end
end

if not logRewards then
    logRewards = function(source)
        print('[DEBUG] logRewards fallback called for source: ' .. source)
    end
end

local function isPlayerWhitelisted(target)
    print('[DEBUG] isPlayerWhitelisted called for target: ' .. tostring(target))
    if (Config.Whitelisted.Type == 'donk_api') then
        local has_permission = exports['donk_api']:validatePremiumAccess(target, {'gunplug'})
        print('[DEBUG] Permission check for gunplug: ' .. tostring(has_permission))
        if has_permission then
            return true
        else
            print('^4[donk_gunplug] ^1[ERROR]^0: Does not have access!')
            return false
        end
    else
        print('^4[donk_gunplug] ^1[ERROR]^0: Config.Whitelisted type is not set correctly!')
        return false
    end
end

local function getPlayerItemCount(source)
    local identifier = getIdentifiers(source)[Config.Cooldown.Identifier]
    print('[DEBUG] getPlayerItemCount for identifier: ' .. tostring(identifier))
    local result = MySQL.Sync.fetchAll('SELECT item_count FROM gunplug WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    })
    if result and result[1] then
        print('[DEBUG] MySQL item count: ' .. result[1].item_count)
        return result[1].item_count or 30
    end
    print('[DEBUG] MySQL no item count, defaulting to 30')
    return 30
end

local function updatePlayerItemCount(source, newCount)
    local identifier = getIdentifiers(source)[Config.Cooldown.Identifier]
    print('[DEBUG] updatePlayerItemCount for identifier: ' .. tostring(identifier) .. ', newCount: ' .. newCount)
    local affectedRows = MySQL.Sync.execute('UPDATE gunplug SET item_count = @item_count, time = @time WHERE identifier = @identifier', {
        ['@identifier'] = identifier,
        ['@item_count'] = newCount,
        ['@time'] = os.time()
    })
    if affectedRows > 0 then
        print('[DEBUG] MySQL updated item_count for identifier: ' .. tostring(identifier) .. ', newCount: ' .. newCount)
    else
        print('[DEBUG] MySQL no record found for identifier: ' .. tostring(identifier) .. ', no update performed')
    end
end

local function giveRewards(source)
    print('[DEBUG] giveRewards called for source: ' .. tostring(source))
    local totalItems = getPlayerItemCount(source)
    if totalItems <= 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'You have no reward items left!',
            type = 'error',
            duration = 5000
        })
        print('[DEBUG] No items left for source: ' .. source)
        return
    end
    local weapons = {}
    for _, item in ipairs(Config.Rewards.Rewards) do
        if string.find(item, 'WEAPON_') then
            table.insert(weapons, item)
        end
    end
    print('[DEBUG] Weapons available: ' .. json.encode(weapons))
    if #weapons == 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'No weapons available!',
            type = 'error',
            duration = 5000
        })
        print('[DEBUG] No weapons in Config.Rewards.Rewards')
        return
    end
    TriggerClientEvent('donk_gunplug:openWeaponMenu', source, weapons, totalItems)
end

local function loadCache()
    if Config.Cooldown.Enabled then
        if (not MySQL) then
            print('^4[donk_gunplug] ^1[ERROR]^0: Config.Cooldown type is set to MySQL, but MySQL is not loaded correctly!')
            return {}
        end
        local success, result = pcall(function()
            return MySQL.Sync.fetchAll('SELECT * FROM gunplug')
        end)
        if (not success) then
            print('^4[donk_gunplug] ^3[WARNING]^0: Config.Cooldown type is set to MySQL, but no table was found! Creating now!')
            local timeOld = os.microtime()
            MySQL.Sync.execute('CREATE TABLE IF NOT EXISTS gunplug (identifier VARCHAR(50), time INT)')
            local took = os.microtime() - timeOld
            print('^4[donk_gunplug] ^2[SUCCESS]^0: Database table created in '..took..'ms!')
            return {}
        end
        return result
    end
end

RegisterNetEvent('donk_gunplug:confirmWeaponSelection')
AddEventHandler('donk_gunplug:confirmWeaponSelection', function(weapon, quantity)
    local source = source
    print('[DEBUG] confirmWeaponSelection for source: ' .. source .. ', weapon: ' .. weapon .. ', quantity: ' .. quantity)
    if not weapon or not quantity or quantity < 1 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Invalid selection!',
            type = 'error',
            duration = 5000
        })
        print('[DEBUG] Invalid selection')
        return
    end
    local totalItems = getPlayerItemCount(source)
    if quantity > totalItems then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Not enough reward items remaining!',
            type = 'error',
            duration = 5000
        })
        print('[DEBUG] Quantity exceeds remaining items: ' .. totalItems)
        return
    end
    local isValidWeapon = false
    for _, item in ipairs(Config.Rewards.Rewards) do
        if item == weapon and string.find(item, 'WEAPON_') then
            isValidWeapon = true
            break
        end
    end
    if not isValidWeapon then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Invalid weapon selected!',
            type = 'error',
            duration = 5000
        })
        print('[DEBUG] Invalid weapon: ' .. weapon)
        return
    end
    elseif Config.Rewards.Type == 'ox_inventory' then -- ox_inventory
        exports[Config.Rewards.Type]:AddItem(source, weapon, quantity)
        print('[DEBUG] Added ox_inventory weapon: ' .. weapon .. ', quantity: ' .. quantity .. ' to player: ' .. source)
    else
        print('^4[donk_gunplug] ^1[ERROR]^0: Config.Rewards.Type is not set correctly!')
        return
    end
    updatePlayerItemCount(source, totalItems - quantity)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Received ' .. quantity .. 'x ' .. weapon,
        type = 'success',
        duration = 5000
    })
end)

local function canRedeem(target)
    print('[DEBUG] canRedeem called for target: ' .. tostring(target))
    local identifier = getIdentifiers(target)[Config.Cooldown.Identifier]
    print('[DEBUG] MySQL cooldown check for identifier: ' .. tostring(identifier))
    local result = MySQL.Sync.fetchAll('SELECT * FROM gunplug WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    })
    if (next(result)) then
        local redeemed = result[1].time
        local item_count = result[1].item_count or 0
        local timeNow = os.time()
        local timeDiff = timeNow - redeemed
        local timeLeft = Config.Cooldown.Time * 86400 - timeDiff
        local timeindays = math.floor(timeLeft / 86400)
        print('[DEBUG] MySQL record found: item_count: ' .. item_count .. ', timeDiff: ' .. timeDiff .. ', timeLeft: ' .. timeLeft .. ', timeindays: ' .. timeindays)
        if item_count > 0 then
            print('[DEBUG] MySQL item_count > 0, can redeem')
            return true
        else
            if timeDiff >= Config.Cooldown.Time * 86400 then
                MySQL.Sync.execute('UPDATE gunplug SET item_count = @item_count, time = @time WHERE identifier = @identifier', {
                    ['@identifier'] = identifier,
                    ['@item_count'] = 30,
                    ['@time'] = os.time()
                })
                print('[DEBUG] MySQL cooldown expired, reset item_count to 30, can redeem')
                return true
            else
                TriggerClientEvent('ox_lib:notify', target, {
                    title = (Config.Strings['Cooldown'] or 'Cooldown active, {TIME_REMAINING} days left'):gsub('{TIME_REMAINING}', timeindays),
                    type = 'error',
                    duration = 5000
                })
                print('[DEBUG] MySQL cooldown active, cannot redeem')
                return false
            end
        end
    else
        MySQL.Sync.execute('INSERT INTO gunplug (identifier, time, item_count) VALUES (@identifier, @time, @item_count)', {
            ['@identifier'] = identifier,
            ['@time'] = os.time(),
            ['@item_count'] = 30
        })
        print('[DEBUG] MySQL no cooldown record, created with item_count = 30, can redeem')
        return true
    end
end

local function organizeRewards()
    local rewardsString = ''
    for k, v in pairs(Config.Rewards.Rewards) do
        local fixedString = ('**%s** - x%s'):format(k, v)
        rewardsString = rewardsString .. fixedString .. "\n"
    end
    organizedRewards = rewardsString
end

local function orgainizeIdentifiers(target)
    local t = {}
    local identifiers = getIdentifiers(target, true)
    for k, v in pairs(identifiers) do
        if k == 'steam' then
            t[#t+1] = ('Steam: [%s](https://steamcommunity.com/profiles/%s)'):format(v, tonumber(v, 16))
        elseif k == 'discord' then
            t[#t+1] = ('Discord: <@%s>'):format(v)
        elseif k == 'license' then
            t[#t+1] = ('License: %s'):format(v)
        elseif k == 'license2' then
            t[#t+1] = ('License 2: %s'):format(v)
        elseif k == 'fivem' then
            t[#t+1] = ('FiveM: %s'):format(v)
        elseif k == 'xbl' then
            t[#t+1] = ('Xbox: %s'):format(v)
        elseif k == 'live' then
            t[#t+1] = ('Live: %s'):format(v)
        end
    end
    return table.concat(t, '\n')
end

local function logRewards(target)
    if (not Config.DiscordLogs.Enabled) then return end
    if (Config.DiscordLogs.Webhook == '') then
        return print('^4[donk_gunplug] ^3[WARNING]^0: Config.DiscordLogs was enabled but a webhook is not set!')
    end
    local fields = {}
    fields[#fields+1] = { name = 'Player', value = ('%s (ID: %s)'):format(GetPlayerName(target), target), inline = false }
    fields[#fields+1] = { name = 'Rewards Received', value = organizedRewards, inline = false }
    fields[#fields+1] = { name = 'Player Identifiers', value = orgainizeIdentifiers(target), inline = false }
    local embed = {
        color = Config.DiscordLogs.Embed.Color,
        type = 'rich',
        title = Config.Strings['LOGS_Title'],
        description = Config.Strings['LOGS_Description'],
        timestamp = os.date('!%Y-%m-%dT%H:%M:%S'),
        fields = fields,
        footer = {
            text = 'Donk Gunplug',
            icon_url = 'https://imgur.com/L2Z2upC.png'
        }
    }
    local encodedData = {
        username = Config.DiscordLogs.Embed.Username,
        avatar_url = Config.DiscordLogs.Embed.UserIcon,
        embeds = { embed }
    }
    PerformHttpRequest(Config.DiscordLogs.Webhook, function(statusCode, responseText, headers)
    end, 'POST', json.encode(encodedData), { ['Content-Type'] = 'application/json' })
end

function sendNotification(source, message)
    print('[DEBUG] sendNotification called for source: ' .. tostring(source) .. ', message: ' .. tostring(message))
    TriggerClientEvent('ox_lib:notify', source, {
        title = message,
        type = 'success',
        duration = 5000
    })
end

RegisterNetEvent('donk_gunplug:giveTrunkRewards')
AddEventHandler('donk_gunplug:giveTrunkRewards', function()
    local source = source -- Automatically provided by FiveM
    print('[DEBUG] giveTrunkRewards event triggered for source: ' .. tostring(source))
    if (Config.Whitelisted.Enabled) then
        local whitelisted = isPlayerWhitelisted(source)
        print('[DEBUG] Whitelist check for source: ' .. tostring(source) .. ', result: ' .. tostring(whitelisted))
        if (not whitelisted) then
            sendNotification(source, Config.Strings['NotWhitelisted'] or 'You are not whitelisted!')
            return
        end
    end
    if (Config.Cooldown.Enabled) then
        local canRedeemResult = canRedeem(source)
        print('[DEBUG] canRedeem check for source: ' .. tostring(source) .. ', result: ' .. tostring(canRedeemResult))
        if (not canRedeemResult) then
            return
        end
    end
    giveRewards(source)
    if (Config.DiscordLogs.Enabled) then
        print('[DEBUG] Logging rewards to Discord for source: ' .. tostring(source))
        logRewards(source)
    end
end)

CreateThread(function()
    loadCache()
    local timeOld = os.microtime()
    if (Config.Rewards.Type == 'ox_inventory') then
        local success, hasExport = pcall(function()
            return exports[Config.Rewards.Type] and exports[Config.Rewards.Type].AddItem ~= nil
        end)

        if not success or not hasExport then
            print('^4[donk_gunplug] ^1[ERROR]^0: OX_Inventory is not loaded correctly! Please make sure you have the correct export set in config.lua')
        end
    else
        print('^4[donk_gunplug] ^1[ERROR]^0: Config.Rewards type is not set correctly!')
    end
    if (Config.DiscordLogs.Enabled) then organizeRewards() end
    local took = os.microtime() - timeOld
    print('^4[donk_gunplug] ^2[SUCCESS]^0: Framework loaded in '..took..'ms!')
end)