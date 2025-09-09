local utils = {}

utils.notify = function(message, type)
    lib.notify({
        title = locale('notify.label'),
        description = message,
        duration = 5000,
        position = 'top-right',
        type = type
    })
end

utils.skillCheck = function()
    local success = lib.skillCheck({ 'easy', 'easy', 'medium', 'easy' }, {'w', 'a', 's', 'd'})

    return success
end

return utils

