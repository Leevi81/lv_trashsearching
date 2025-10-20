local serverConfig = require 'config.server'
local utils = require 'server.utils'

local tokens = {}
local cooldowns = {}

local function setCooldown(id, time)
    if cooldowns[id] then return end

    cooldowns[id] = os.time() + time
end

local function hasCooldown(id)
    if not cooldowns[id] then return false end

    if os.time() >= cooldowns[id] then
        cooldowns[id] = nil
        return false
    end

    return true
end

local function validateToken(source, token)
    if tokens[source] and tokens[source] == token then
        tokens[source] = nil
        return true
    end
    return false
end

local function giveReward(source)
    local chance = math.random(1, 100)

    if chance > serverConfig.rewards.chance then
        utils.notify(locale('notify.nothingfound'), 'error')

        utils.createLog(source, {
            title = 'Nothing Found',
            message = 'Player searched the trash but found nothing.',
            color = 16776960
        })
        return
    end

    local rewardAmount = math.random(serverConfig.rewards.amount.min, serverConfig.rewards.amount.max)
    local foundItems = {}

    for i = 1, rewardAmount do
        local item = serverConfig.rewards.items[math.random(#serverConfig.rewards.items)]
        local itemChance = math.random(1, 100)
        local itemAmount = math.random(item.amount.min, item.amount.max)

        if itemChance <= item.chance then
            if not exports.ox_inventory:CanCarryItem(source, item.name, itemAmount) then
                utils.notify(locale('notify.cannotcarry'), 'error')
                return
            end

            exports.ox_inventory:AddItem(source, item.name, itemAmount)
            foundItems[#foundItems + 1] = ('- %sx %s'):format(itemAmount, item.name)
        end
    end

    if #foundItems == 0 then
        utils.notify(source, locale('notify.nothingfound'), 'error')
        utils.createLog(source, {
            title = 'Nothing Found',
            message = 'Player searched the trash but found nothing (no items passed chance check).',
            color = 16776960
        })
        return
    end

    utils.createLog(source, {
        title = 'Items Found',
        message = ('Player searched the trash and found:\n%s'):format(table.concat(foundItems, '\n')),
        color = 65280
    })
end

RegisterNetEvent('lv_trashsearching:server:startSearching', function(token, entityId)
    if not validateToken(source, token) then
        utils.handleExploit(source, 'Player attempted to exploit the trash searching system by sending an invalid token.')
        return
    end

    if serverConfig.playercooldown.enabled and hasCooldown(source) then
        utils.notify(locale('notify.cooldown'), 'error')
        return
    end

    giveReward(source)

    if serverConfig.playercooldown.enabled then
        setCooldown(source, serverConfig.playercooldown.time)
    end

    if serverConfig.bincooldown.enabled then
        setCooldown(entityId, serverConfig.bincooldown.time)
    end
end)

lib.callback.register('lv_trashsearching:server:checkCooldowns', function(source, entityId)
    return {
        player = hasCooldown(source),
        bin = hasCooldown(entityId)
    }
end)

lib.callback.register('lv_trashsearching:server:generateToken', function(source)
    local token = tostring(math.random(111111, 999999)) .. ":" .. source .. ":" .. os.time()
    tokens[source] = token

    return token
end)

AddEventHandler('playerDropped', function()
    tokens[source] = nil
end)

if serverConfig.enableVersionCheck then
    lib.versionCheck('Leevi81/lv_trashsearching')
end
