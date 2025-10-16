return {
    rewards = {
        amount = { min = 1, max = 3 }, -- Amount of different items to give
        chance = 65, -- Chance to find something in % (0-100)
        items = {
            { name = 'garbage', amount = { min = 1, max = 3 }, chance = 85 }, -- item name, min/max amount, chance to get this item in % (0-100)
            { name = 'panties', amount = { min = 1, max = 3 }, chance = 70 },
            { name = 'weapon_knife', amount = { min = 1, max = 1 }, chance = 3 },
            { name = 'phone', amount = { min = 1, max = 1 }, chance = 15 }, 
            { name = 'money', amount = { min = 100, max = 250 }, chance = 25 }, 
            { name = 'goldchain', amount = { min = 1, max = 2 }, chance = 10 },          
        }
    },

    playercooldown = {
        enabled = true,
        time = 10 -- time that a player has to wait before being able to search again (in seconds)
    },

    bincooldown = {
        enabled = true,
        time = 300 -- time before a bin can be searched again (in seconds)
    },

    logging = {
        enabled = true,
        system = 'ox_lib', -- 'ox_lib' / 'discord'

        webhookUrl = '', -- Discord webhook for logging
        name = 'Trash Searching', -- Name of the webhook (if using discord)
        image = '' -- Image of the webhook (if using discord)
    },

    maxDistance = 3.0, -- Maximum allowed distance from the trash bin

    enableVersionCheck = true

}
