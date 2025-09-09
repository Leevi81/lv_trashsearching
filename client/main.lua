local clientConfig = require 'config.client'
local utils = require 'client.utils'

local function startSearching(entityId, entityCoords)
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
        local token = lib.callback.await('lv_trashsearching:server:generateToken', false)
        if not token then return end

        TriggerServerEvent('lv_trashsearching:server:startSearching', token, entityId, entityCoords)
    else
        utils.notify(locale('notify.canceled'), 'error')
    end
end

CreateThread(function()
    exports.ox_target:addModel(clientConfig.models, {
        label = locale('target.label'),
        icon = clientConfig.target.icon,
        distance = clientConfig.target.distance,
        onSelect = function(data)
            local entityCoords = GetEntityCoords(data.entity)
            local entityId = string.format("%d_%d_%d", math.floor(entityCoords.x), math.floor(entityCoords.y), math.floor(entityCoords.z))
            startSearching(entityId, entityCoords) 
        end
    })
end)
