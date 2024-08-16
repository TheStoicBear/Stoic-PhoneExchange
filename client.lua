RegisterNetEvent('showNotification')
AddEventHandler('showNotification', function(header, message)
    SendNUIMessage({
        type = 'notification',
        header = header,
        message = message,
        position = Config.position -- Send position to NUI
    })
end)

RegisterNetEvent('copyPhoneNumberToClipboard')
AddEventHandler('copyPhoneNumberToClipboard', function(phoneNumber)
    SendNUIMessage({
        type = 'copyClipboard',
        phoneNumber = phoneNumber
    })
    TriggerEvent('showNotification', 'SYSTEM', 'Phone number copied to clipboard.')
end)

-- Function to set notification position
function setNotificationPosition(position)
    Config.position = position
end

-- Function to add the 'Give Phone Number' option to a specific player
local function addGivePhoneNumberOption(targetPlayerId)
    print("Adding 'Give Phone Number' option for player ID: " .. targetPlayerId)
    exports.ox_target:addGlobalPlayer({
        label = "Give Phone Number",
        icon = "fa-phone",
        distance = 5.0,  -- Adjust as necessary
        onSelect = function()
            -- Send the selected target's server ID to the server for processing
            TriggerServerEvent('givePhoneNumberToPlayer', targetPlayerId)
        end
    })
end

-- Function to add the 'Request Phone Number' option to a specific player
local function addReqPhoneNumberOption(targetPlayerId)
    print("Adding 'Request Phone Number' option for player ID: " .. targetPlayerId)
    exports.ox_target:addGlobalPlayer({
        label = "Request Phone Number",
        icon = "fa-phone",
        distance = 5.0,  -- Adjust as necessary
        onSelect = function()
            -- Send the selected target's server ID to the server for processing
            TriggerServerEvent('requestPhoneNumberFromPlayer', targetPlayerId)
        end
    })
end

RegisterNetEvent('showPhoneRequestDialog')
AddEventHandler('showPhoneRequestDialog', function(requesterId)
    local requesterName = GetPlayerName(GetPlayerFromServerId(requesterId))
    local alert = lib.alertDialog({
        header = 'Phone Number Request',
        content = 'Player ' .. requesterName .. ' is requesting your phone number. Do you approve?',
        centered = true,
        cancel = true,
        labels = {
            cancel = 'Deny',
            confirm = 'Approve'
        }
    })
    
    if alert == 'confirm' then
        -- Confirm the phone number request to the server
        TriggerServerEvent('approvePhoneNumberRequest', requesterId)
        TriggerEvent('showNotification', 'SYSTEM', 'You approved the phone number request.')
    else
        -- Deny the phone number request
        TriggerEvent('showNotification', 'SYSTEM', 'You denied the phone number request.')
    end
end)

-- Example usage: Listen for when the resource is started
AddEventHandler("onClientResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        -- Example: Add 'Give Phone Number' option to all players (replace with your logic)
        local players = GetActivePlayers()
        for _, player in ipairs(players) do
            if player ~= PlayerId() then
                local serverId = GetPlayerServerId(player)
                addGivePhoneNumberOption(serverId)
                addReqPhoneNumberOption(serverId)
            end
        end
    end
end)
