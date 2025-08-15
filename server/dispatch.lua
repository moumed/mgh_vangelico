local Dispatch = {}

function Dispatch.SendDispatchAlert(coords, storeName)
    local dispatchType = Config.Dispatch:lower()

    if dispatchType == 'qs-dispatch' then
        local data = exports['qs-dispatch']:GetPlayerInfo()
        TriggerEvent('qs-dispatch:server:CreateDispatchCall', {
            job = Config.Police.Jobs,
            callLocation = coords,
            callCode = { code = '10-90', meaning = _U('shop_robbery') },
            message = _U('rob_in_prog') .. ' ' .. storeName,
            flashes = false,
            image = nil,
            blip = {
                sprite = 439,
                scale = 1.2,
                colour = 3,
                flashes = true,
                text = _U('shop_robbery'),
                time = (6 * 60 * 1000),
            }
        })
    elseif dispatchType == 'cd_dispatch' then
        local data = {
            message = _U('rob_in_prog') .. ' ' .. storeName,
            codeName = 'jewelryrobbery',
            code = '10-90',
            icon = 'fas fa-gem',
            priority = 2,
            coords = coords,
            street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z)),
            gender = IsPedMale(GetPlayerPed(source)) and 'Male' or 'Female',
            camId = math.random(10, 50),
            color = '#FF0000',
            callsign = 'ALARM'
        }
        TriggerEvent('cd_dispatch:AddNotification', data)
    elseif dispatchType == 'tk_dispatch' then
        local data = {
            title = "Vangelico Robery",
            code = '10-90',
            priority = 2,
            message = _U('rob_in_prog') .. ' ' .. storeName,
            coords = coords,
            blip = {
                sprite = 439,
                scale = 1.2,
                color = 3,
                flash = true
            },
            jobs = Config.Police.Jobs,
            removeTime = 120000,
            flash = true,
            playSound = true,
            color = '#FF0000',
        }
        exports.tk_dispatch:addCall(data)
    elseif dispatchType == 'core_dispatch' then
        exports['core_dispatch']:addCall("10-90", _U('shop_robbery'), {
            { icon = "fa-gem", info = storeName }
        }, { coords.x, coords.y, coords.z }, 'police', 3000, 11, 5)
    else
        -- Default notification to all police
        local xPlayers = ESX.GetPlayers()
        for i = 1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer and table.contains(Config.Police.Jobs, xPlayer.job.name) then
                TriggerClientEvent('ox_lib:notify', xPlayers[i], {
                    title = _U('alarm_triggered'),
                    description = _U('rob_in_prog') .. ' ' .. storeName,
                    type = 'error'
                })
            end
        end
    end
end

return Dispatch
