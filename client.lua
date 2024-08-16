
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
    print("Adding option for player ID: " .. targetPlayerId)
    exports.ox_target:addGlobalPlayer({
        label = "Give Phone Number",
        icon = "fa-phone",
        distance = 5.0,  -- Adjust as necessary
        onSelect = function()
            -- Execute the /givenum command for the target player
            ExecuteCommand("givenum " .. targetPlayerId)
        end
    })
end

-- Function to add the 'Request Phone Number' option to a specific player
local function addReqPhoneNumberOption(targetPlayerId)
    print("Adding option for player ID: " .. targetPlayerId)
    exports.ox_target:addGlobalPlayer({
        label = "Request Phone Number",
        icon = "fa-phone",
        distance = 5.0,  -- Adjust as necessary
        onSelect = function()
            -- Execute the /reqnum command for the target player
            ExecuteCommand("reqnum " .. targetPlayerId)
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
        TriggerServerEvent('givePhoneNumber', requesterId, GetPlayerServerId(PlayerId()))
        TriggerEvent('showNotification', 'SYSTEM', 'You approved the phone number request.')
    else
        TriggerEvent('showNotification', 'SYSTEM', 'You denied the phone number request.')
    end
end)

-- Example usage: Listen for when the resource is started
AddEventHandler("onClientResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        -- Example: Add 'Give Phone Number' option to all players (replace with your logic)
        local players = GetActivePlayers()
        print("Active players: " .. json.encode(players))
        for _, player in ipairs(players) do
            if player ~= PlayerId() then
                local serverId = GetPlayerServerId(player)
                addGivePhoneNumberOption(serverId)
                addReqPhoneNumberOption(serverId)
                print("Added option for player with Server ID: " .. serverId)
            end
        end
    end
end)
