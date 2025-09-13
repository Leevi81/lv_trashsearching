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

    if chance >= serverConfig.rewards.chance then 
        utils.notify(locale('notify.nothingfound'), 'error')

        utils.createLog(source, {
            title = 'Nothing Found',
            message = 'Player searched the trash but found nothing.',
            color = 16776960
        })
        return
    end

    local differentItems = 0
    local rewardAmount = math.random(serverConfig.rewards.amount.min, serverConfig.rewards.amount.max)
    local foundItems = {}

    for i=1, #serverConfig.rewards.items do
        if differentItems >= rewardAmount then break end

        local item = serverConfig.rewards.items[math.random(#serverConfig.rewards.items)]
        local itemAmount = math.random(item.amount.min, item.amount.max)
        if chance <= item.chance then
            if not exports.ox_inventory:CanCarryItem(source, item.name, itemAmount) then
                utils.notify(locale('notify.cannotcarry'), 'error')
                return
            end

            exports.ox_inventory:AddItem(source, item.name, itemAmount)
            differentItems = differentItems + 1

            foundItems[#foundItems + 1] = { name = item.name, amount = itemAmount }
        end
    end

    local itemList = {}

    for _, item in ipairs(foundItems) do
        itemList[#itemList + 1] = ('- %sx %s'):format(item.amount, item.name)
    end

    utils.createLog(source, {
        title = 'Items Found',
        message = ('Player searched the trash and found:\n%s'):format(table.concat(itemList, '\n')),
        color = 65280
    })
end
 
RegisterNetEvent('lv_trashsearching:server:startSearching', function(token, entity, entityId, entityCoords)
    if not validateToken(source, token) then
        utils.handleExploit(source, 'Player attempted to exploit the trash searching system by sending an invalid token.')
        return
    end

    local closestObj, closestObjCoords = lib.callback.await('lv_trashsesarching:client:getClosestObjCoords', source)

    if not closestObjCoords then
        utils.handleExploit(source, 'Player attempted to exploit the trash searching system without being near an object.')
        return
    end

    if entity ~= closestObj then
        utils.handleExploit(source, 'Player attempted to exploit the trash searching system by giving invalid entity.')
        return
    end

    if not entityId then
        utils.handleExploit(source, 'Player attempted to exploit the trash searching system by sending an invalid entityId.')
        return 
    end

    if serverConfig.playercooldown.enabled and hasCooldown(source) then
        utils.notify(locale('notify.cooldown'), 'error')
        return
    end

    if not entityCoords then
        utils.handleExploit(source, 'Player attempted to exploit the trash searching system by sending invalid coords.')
        return 
    end

    local pedCoords = GetEntityCoords(GetPlayerPed(source))
    local dist = #(entityCoords - pedCoords)
    if dist > serverConfig.maxDistance then
        utils.handleExploit(source, 'Player attempted to exploit trash searching without being near an object.')
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

lib.callback.register('lv_trashsearching:server:hasPlayerCooldown', function(source)
    return hasCooldown(source)
end)

lib.callback.register('lv_trashsearching:server:hasBinCooldown', function(source, entityId)
    return hasCooldown(entityId)
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