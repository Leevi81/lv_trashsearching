local utils = {}
local serverConfig = require 'config.server'

utils.notify = function(message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = locale('notify.label'),
        description = message,
        duration = 5000,
        position = 'top-right',
        type = type
    })
end

utils.handleExploit = function(playerId, message)
    DropPlayer(playerId, 'Attempted exploit abuse') 
    utils.createLog(playerId, {
        title = 'Attempted Exploit Abuse',
        message = message,
        color = 16711680
    })
end

utils.createLog = function(source, data)
    if not serverConfig.logging.enabled then return end

    if serverConfig.logging.system == 'ox_lib' then
        lib.logger(source, locale('logs.description'), data.message)
    elseif serverConfig.logging.system == 'discord' then
        local playerName = GetPlayerName(source)
        local identifiers = GetPlayerIdentifiers(source)

        local playerIdentifiers = {}

        for _, id in pairs(identifiers) do
            if id:find('discord:') then
                playerIdentifiers.discord = id:gsub('discord:', '')
            elseif id:find('steam:') then
                playerIdentifiers.steam = id:gsub('steam:', '')
            elseif id:find('license:') then
                playerIdentifiers.license = id:gsub('license:', '')
            elseif id:find('license2:') then
                playerIdentifiers.license2 = id:gsub('license2:', '')
            elseif id:find('xbl:') then
                playerIdentifiers.xbox = id:gsub('xbox:', '')
            elseif id:find('live:') then
                playerIdentifiers.live = id:gsub('live:', '')
            elseif id:find('ip:') then
                playerIdentifiers.ip = id:gsub('ip:', '')
            elseif id:find('fivem:') then
                playerIdentifiers.fivem = id:gsub('fivem:', '')
            end
        end

        local logMessage = ('%s\n\n**Player Identifiers:**\n' ..
            'Player: %s\n' ..
            'FiveM: %s\n' ..
            'Discord: %s\n' ..
            'Steam: %s\n' ..
            'License: %s\n' ..
            'License2: %s\n' ..
            'Xbox: %s\n' ..
            'Live: %s\n' ..
            'IP: %s'):format(
            data.message, 
            playerName,
            playerIdentifiers.fivem or 'Unknown',
            playerIdentifiers.discord or 'Unknown',
            playerIdentifiers.steam or 'Unknown',
            playerIdentifiers.license or 'Unknown',
            playerIdentifiers.license2 or 'Unknown',
            playerIdentifiers.xbox or 'Unknown',
            playerIdentifiers.live or 'Unknown',
            playerIdentifiers.ip or 'Unknown'
        )


        local payload = {
            username = serverConfig.logging.name,
            avatar_url = serverConfig.logging.image,
            embeds = {}
        }

        if data.title then
            table.insert(payload.embeds, {
                color = data.color,
                title = ('**%s**'):format(data.title),
                description = logMessage,
                footer = {
                    text = os.date('%a %b %d, %I:%M%p'),
                    icon_url = serverConfig.logging.image
                }
            })
        end
    
        if #payload.embeds == 0 then
            payload.embeds = nil
        end

        PerformHttpRequest(serverConfig.logging.webhookUrl, function(err, text, headers) end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
    end
end

return utils