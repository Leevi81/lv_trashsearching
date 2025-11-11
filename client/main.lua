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

local function startSearching(entity, entityCoords)
    if cache.vehicle then
        utils.notify(locale('notify.vehicle'), 'error')
        return
    end

    local cooldowns = lib.callback.await('lv_trashsearching:server:checkCooldowns', false, entityCoords)

    if cooldowns.bin then
        utils.notify(locale('notify.searched'), 'error')
        return
    end

    if cooldowns.player then
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

        TriggerServerEvent('lv_trashsearching:server:startSearching', token, entity, entityCoords)
    else
        utils.notify(locale('notify.canceled'), 'error')
    end
end

lib.callback.register('lv_trashsearching:client:getNearbyObjects', function()
    local pedCoords = GetEntityCoords(cache.ped)
    local nearbyObjects = lib.getNearbyObjects(pedCoords, 3.0)

    return nearbyObjects
end)

CreateThread(function()
    exports.ox_target:addModel(clientConfig.models, {
        label = locale('target.label'),
        icon = clientConfig.target.icon,
        distance = clientConfig.target.distance,
        onSelect = function(data)
            local entity = data.entity
            local entityCoords = GetEntityCoords(entity)
            startSearching(entity, entityCoords)
        end
    })
end)

