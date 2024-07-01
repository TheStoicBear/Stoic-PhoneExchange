local function getPlayerIdentifier(source)
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if string.match(identifier, "license:") then
            return identifier
        end
    end
    return nil
end

local function getPhoneNumber(identifier, callback)
    print("getPhoneNumber called with identifier: " .. identifier) -- Debug print
    MySQL.Async.fetchScalar('SELECT phonenumber FROM nd_characters WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(phoneNumber)
        if phoneNumber then
            print("Phone number found: " .. phoneNumber) -- Debug print
        else
            print("No phone number found for identifier: " .. identifier) -- Debug print
        end
        callback(phoneNumber)
    end)
end

RegisterCommand('givenum', function(source, args)
    local targetId = tonumber(args[1])
    if targetId then
        local identifier = getPlayerIdentifier(source)
        getPhoneNumber(identifier, function(phoneNumber)
            if phoneNumber then
                -- Send notification to source player
                TriggerClientEvent('showNotification', source, 'SYSTEM', 'You shared your phone number with player ' .. GetPlayerName(targetId) .. '.')
                
                -- Send notification to target player
                TriggerClientEvent('showNotification', targetId, 'SYSTEM', 'Player ' .. GetPlayerName(source) .. ' has shared their phone number with you: ' .. phoneNumber)
            else
                TriggerClientEvent('showNotification', source, 'SYSTEM', 'Failed to retrieve your phone number.')
            end
        end)
    else
        TriggerClientEvent('showNotification', source, 'SYSTEM', 'Invalid target ID.')
    end
end, false)


RegisterCommand('reqnum', function(source, args)
    print("/reqnum command called by player: " .. GetPlayerName(source)) -- Debug print
    local targetId = tonumber(args[1])
    if targetId then
        print("Requesting phone number from target ID: " .. targetId) -- Debug print
        TriggerClientEvent('showPhoneRequestDialog', targetId, source)
        TriggerClientEvent('showNotification', source, 'SYSTEM', 'Request sent to Player ' .. GetPlayerName(targetId) .. '.')
        print("Phone number request sent to target ID: " .. targetId) -- Debug print
    else
        print("Invalid target ID: " .. tostring(args[1])) -- Debug print
        TriggerClientEvent('showNotification', source, 'SYSTEM', 'Invalid target ID.')
    end
end, false)

RegisterServerEvent('givePhoneNumber')
AddEventHandler('givePhoneNumber', function(requesterId, targetId)
    local targetIdentifier = getPlayerIdentifier(targetId)
    print("Target Identifier: " .. targetIdentifier) -- Debug print
    getPhoneNumber(targetIdentifier, function(phoneNumber)
        if phoneNumber then
            print("Sharing phone number: " .. phoneNumber .. " with requester ID: " .. requesterId) -- Debug print
            TriggerClientEvent('showNotification', requesterId, 'SYSTEM', 'Player ' .. GetPlayerName(targetId) .. ' has approved your request. Their phone number is: ' .. phoneNumber)
            TriggerClientEvent('showNotification', targetId, 'SYSTEM', 'You shared your phone number with Player ' .. GetPlayerName(requesterId) .. '.')
        else
            print("Failed to retrieve phone number for player ID: " .. targetId) -- Debug print
            TriggerClientEvent('showNotification', targetId, 'SYSTEM', 'Failed to retrieve your phone number.')
        end
    end)
end)

