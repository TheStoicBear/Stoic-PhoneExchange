local function getPlayerIdentifier(source)
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if string.match(identifier, "license:") then
            return identifier
        end
    end
    return nil
end

local function getPhoneNumber(identifier, callback)
    MySQL.Async.fetchScalar('SELECT phonenumber FROM nd_characters WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(phoneNumber)
        callback(phoneNumber)
    end)
end

-- When a player shares their phone number with another player
RegisterServerEvent('givePhoneNumberToPlayer')
AddEventHandler('givePhoneNumberToPlayer', function(targetId)
    local sourceId = source
    local identifier = getPlayerIdentifier(sourceId)

    if targetId and identifier then
        getPhoneNumber(identifier, function(phoneNumber)
            if phoneNumber then
                -- Notify both players
                TriggerClientEvent('showNotification', sourceId, 'SYSTEM', 'You shared your phone number with player ' .. GetPlayerName(targetId) .. '.')
                TriggerClientEvent('showNotification', targetId, 'SYSTEM', 'Player ' .. GetPlayerName(sourceId) .. ' has shared their phone number with you: ' .. phoneNumber)
            else
                TriggerClientEvent('showNotification', sourceId, 'SYSTEM', 'Failed to retrieve your phone number.')
            end
        end)
    else
        TriggerClientEvent('showNotification', sourceId, 'SYSTEM', 'Invalid target ID or player identifier.')
    end
end)

-- When a player requests another player's phone number
RegisterServerEvent('requestPhoneNumberFromPlayer')
AddEventHandler('requestPhoneNumberFromPlayer', function(targetId)
    local sourceId = source

    if targetId then
        -- Send a request dialog to the target player
        TriggerClientEvent('showPhoneRequestDialog', targetId, sourceId)
        TriggerClientEvent('showNotification', sourceId, 'SYSTEM', 'Phone number request sent to Player ' .. GetPlayerName(targetId) .. '.')
    else
        TriggerClientEvent('showNotification', sourceId, 'SYSTEM', 'Invalid target ID.')
    end
end)

-- When a player approves a phone number request
RegisterServerEvent('approvePhoneNumberRequest')
AddEventHandler('approvePhoneNumberRequest', function(requesterId)
    local sourceId = source
    local identifier = getPlayerIdentifier(sourceId)

    if requesterId and identifier then
        getPhoneNumber(identifier, function(phoneNumber)
            if phoneNumber then
                -- Notify both players
                TriggerClientEvent('showNotification', requesterId, 'SYSTEM', 'Player ' .. GetPlayerName(sourceId) .. ' has approved your request. Their phone number is: ' .. phoneNumber)
                TriggerClientEvent('showNotification', sourceId, 'SYSTEM', 'You shared your phone number with Player ' .. GetPlayerName(requesterId) .. '.')
            else
                TriggerClientEvent('showNotification', sourceId, 'SYSTEM', 'Failed to retrieve your phone number.')
            end
        end)
    else
        TriggerClientEvent('showNotification', sourceId, 'SYSTEM', 'Invalid requester ID or player identifier.')
    end
end)
