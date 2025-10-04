local clientConfig = require 'config.client'
local utils = require 'client.utils'

local function resetPrickEffects()
    ClearTimecycleModifier()
    SetPedMotionBlur(cache.ped, false)
end

local function applyPrickEffects()
    local ped = PlayerPedId()

    ClearPedTasksImmediately(cache.ped)
    SetPedMotionBlur(cache.ped, true)
    SetTimecycleModifier("spectator5")

    local currenthHealth = GetEntityHealth(cache.ped)
    local newHealth = currenthHealth - clientConfig.prick.healthLoss
    SetEntityHealth(cache.ped, newHealth)

    if clientConfig.prick.enableSoundEffect then
        PlaySoundFrontend(-1, "Frontend_Beast_Freeze_Screen", "FM_Events_Sasquatch_Sounds", 0)
    end

    SetPedToRagdoll(ped, clientConfig.prick.waitTime, clientConfig.prick.waitTime, 0, true, true, false)

    Wait(clientConfig.prick.waitTime)
    resetPrickEffects()
end

local function shouldPrick()
    local ped = PlayerPedId()
    local isWearingGloves = utils.isWearingGloves()

    if not clientConfig.prick.enable then return false end
    if isWearingGloves then return false end

    if not isWearingGloves then
        local prickChance = math.random(1, 100)

        if prickChance <= clientConfig.prick.prickChance then
            utils.notify(locale('notify.gloves'), 'error')
            applyPrickEffects()
            return true
        end
    end
end

local function startSearching(entity, entityId, entityCoords)
    if not entityId or not entityCoords then return end

    if cache.vehicle then
        utils.notify(locale('notify.vehicle'), 'error')
        return
    end

    local hasBinCooldown = lib.callback.await('lv_trashsearching:server:hasBinCooldown', false, entityId)
    if hasBinCooldown then
        utils.notify(locale('notify.searched'), 'error')
        return
    end

    local hasPlayerCooldown = lib.callback.await('lv_trashsearching:server:hasPlayerCooldown', false)
    if hasPlayerCooldown then
        utils.notify(locale('notify.cooldown'), 'error')
        return
    end

    if not clientConfig.disableskillCheck then
        local skillSuccess = utils.skillCheck()
        if not skillSuccess then
            utils.notify(locale('notify.failed'), 'error')
            return
        end
    end

    local progressSuccess = lib.progressCircle({
        duration = clientConfig.progressBar.duration,
        label = locale('progress.label'),
        position = clientConfig.progressBar.position,
        useWhileDead = false,
        allowRagdoll = false,
        allowSwimming = false,
        allowCuffed = false,
        allowFalling = false,
        canCancel = true,
        anim = {
            scenario = clientConfig.progressBar.anim.scenario,
        },
        disable = {
            move = clientConfig.progressBar.disable.move,
            car = clientConfig.progressBar.disable.car,
            combat = clientConfig.progressBar.disable.combat,
            mouse = clientConfig.progressBar.disable.mouse,
        }
    })

    if progressSuccess then
        if shouldPrick() then return end
        
        local token = lib.callback.await('lv_trashsearching:server:generateToken', false)
        if not token then return end

        TriggerServerEvent('lv_trashsearching:server:startSearching', token, entity, entityId, entityCoords)
    else
        utils.notify(locale('notify.canceled'), 'error')
    end
end

lib.callback.register('lv_trashsesarching:client:getClosestObjCoords', function()
    local pedCoords = GetEntityCoords(cache.ped)
    local closestObj, closestObjCoords = lib.getClosestObject(pedCoords, 2.0)

    return closestObj, closestObjCoords
end)

CreateThread(function()
    exports.ox_target:addModel(clientConfig.models, {
        label = locale('target.label'),
        icon = clientConfig.target.icon,
        distance = clientConfig.target.distance,
        onSelect = function(data)
            local entity = data.entity
            local entityCoords = GetEntityCoords(entity)
            local entityId = string.format("%d_%d_%d", math.floor(entityCoords.x), math.floor(entityCoords.y), math.floor(entityCoords.z))
            startSearching(entity, entityId, entityCoords) 
        end
    })
end)

