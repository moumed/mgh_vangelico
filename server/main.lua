local robbers = {}
local CopsConnected = 0
local Dispatch = require 'server.dispatch'

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Discord webhook function
function SendDiscordWebhook(playerName, playerId, playerIdentifier, storeName, storeCoords)
    if not Config.Discord.Enable or not Config.Discord.WebhookURL or Config.Discord.WebhookURL == "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL_HERE" then
        return
    end
    
    local currentTime = os.date("%d/%m/%Y à %H:%M:%S")
    local coordsText = string.format("X: %.2f, Y: %.2f, Z: %.2f", storeCoords.x, storeCoords.y, storeCoords.z)
    
    local embed = {
        {
            ["title"] = Config.Discord.Title,
            ["color"] = Config.Discord.Color,
            ["description"] = "Un braquage de bijouterie a été commencé !",
            ["fields"] = {
                {
                    ["name"] = "👤 Joueur",
                    ["value"] = playerName,
                    ["inline"] = true
                },
                {
                    ["name"] = "🆔 ID Serveur",
                    ["value"] = playerId,
                    ["inline"] = true
                },
                {
                    ["name"] = "🔗 Identifier",
                    ["value"] = playerIdentifier,
                    ["inline"] = true
                },
                {
                    ["name"] = "🏪 Bijouterie",
                    ["value"] = storeName,
                    ["inline"] = true
                },
                {
                    ["name"] = "📍 Coordonnées",
                    ["value"] = coordsText,
                    ["inline"] = true
                },
                {
                    ["name"] = "🕒 Heure",
                    ["value"] = currentTime,
                    ["inline"] = true
                }
            },
            ["footer"] = {
                ["text"] = Config.Discord.Footer
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    local data = {
        ["username"] = Config.Discord.BotName,
        ["embeds"] = embed
    }
    
    PerformHttpRequest(Config.Discord.WebhookURL, function(err, text, headers)
        if err ~= 200 then
            print("^1[MGH Vangelico] Erreur webhook Discord: " .. err .. "^0")
        end
    end, 'POST', json.encode(data), {['Content-Type'] = 'application/json'})
end

-- Initialize cop count on script start
CreateThread(function()
    Wait(1000) -- Wait for ESX to be ready
    local xPlayers = ESX.GetPlayers()
    CopsConnected = 0
    
    for i = 1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer and table.contains(Config.Police.Jobs, xPlayer.job.name) then
            CopsConnected = CopsConnected + 1
        end
    end
    
    print("[mgh_vangelico] Initialized with " .. CopsConnected .. " cops connected")
end)

-- Count cops only when they connect/disconnect or change job
AddEventHandler('esx:playerLoaded', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if table.contains(Config.Police.Jobs, xPlayer.job.name) then
        CopsConnected = CopsConnected + 1
    end
end)

AddEventHandler('esx:playerDropped', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and table.contains(Config.Police.Jobs, xPlayer.job.name) then
        CopsConnected = math.max(0, CopsConnected - 1)
    end
end)

AddEventHandler('esx:setJob', function(source, job, lastJob)
    if table.contains(Config.Police.Jobs, lastJob.name) then
        CopsConnected = math.max(0, CopsConnected - 1)
    end
    if table.contains(Config.Police.Jobs, job.name) then
        CopsConnected = CopsConnected + 1
    end
end)

RegisterNetEvent('mgh_vangelico:toofar')
AddEventHandler('mgh_vangelico:toofar', function(robb)
	local source = source
	if robbers[source] then
		TriggerClientEvent('mgh_vangelico:toofarlocal', source)
		robbers[source] = nil
	end
end)

RegisterNetEvent('mgh_vangelico:endrob')
AddEventHandler('mgh_vangelico:endrob', function(robb)
	local source = source
	local xPlayers = ESX.GetPlayers()
	
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if table.contains(Config.Police.Jobs, xPlayer.job.name) then
			TriggerClientEvent('ox_lib:notify', xPlayers[i], {
				title = _U('end'),
				type = 'success'
			})
		end
	end
	
	if robbers[source] then
		TriggerClientEvent('mgh_vangelico:robberycomplete', source)
		robbers[source] = nil
	end
end)

RegisterNetEvent('mgh_vangelico:rob')
AddEventHandler('mgh_vangelico:rob', function(robb)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if Locations.stores[robb] then
		local store = Locations.stores[robb]

		if not store.lastRobbed then
			store.lastRobbed = 0
		end

		if (os.time() - store.lastRobbed) < Config.SecBetwNextRob and store.lastRobbed ~= 0 then
			local remainingTime = Config.SecBetwNextRob - (os.time() - store.lastRobbed)
			local minutes = math.floor(remainingTime / 60)
			local seconds = remainingTime % 60
			local timeText = ""
			
			if minutes > 0 then
				timeText = minutes .. " minute(s) et " .. seconds .. " seconde(s)"
			else
				timeText = seconds .. " seconde(s)"
			end
			
			TriggerClientEvent('ox_lib:notify', source, {
				title = _U('already_robbed') .. timeText,
				type = 'error'
			})
			return
		end

		-- Check cops at the moment of starting robbery with real-time count
		local currentCops = 0
		local xPlayers = ESX.GetPlayers()
		
		for i = 1, #xPlayers do
			local xPlayerLoop = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayerLoop and table.contains(Config.Police.Jobs, xPlayerLoop.job.name) then
				currentCops = currentCops + 1
			end
		end
		
		-- Update the global counter
		CopsConnected = currentCops
		
		if currentCops >= Config.Police.RequiredCops then
			robbers[source] = robb
			Dispatch.SendDispatchAlert(store.position, store.nameofstore)
			TriggerClientEvent('mgh_vangelico:currentlyrobbing', source, robb)
			store.lastRobbed = os.time()
			
			-- Send Discord webhook
			local playerName = xPlayer.getName()
			local playerId = source
			local playerIdentifier = xPlayer.identifier
			local storeName = store.nameofstore or "Bijouterie"
			local storeCoords = store.position
			
			SendDiscordWebhook(playerName, playerId, playerIdentifier, storeName, storeCoords)
		else
			TriggerClientEvent('ox_lib:notify', source, {
				title = _U('min_two_police') .. ' ' .. Config.Police.RequiredCops .. ' ' .. _U('min_two_police2') .. ' (Actuellement: ' .. currentCops .. ')',
				type = 'error'
			})
		end
	end
end)

-- Give loot based on configurable items
lib.callback.register('mgh_vangelico:getLoot', function(source)
    if not robbers[source] then return false end
    
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    
    -- Check if player is near any display case in the store they're robbing
    local isNearCase = false
    local store = Locations.stores[robbers[source]]
    if store then
        for _, displayCase in pairs(store.display_cases) do
            if #(coords - vector3(displayCase.x, displayCase.y, displayCase.z)) < 1.0 then
                isNearCase = true
                break
            end
        end
    end
    
    if not isNearCase then return false end
    
    local receivedItems = {}
    local totalWeight = 0
    
    -- Calculate what items to give based on configuration
    for _, lootItem in pairs(Config.LootItems) do
        if math.random(100) <= lootItem.chance then
            local amount = math.random(lootItem.min, lootItem.max)
            local itemData = exports.ox_inventory:Items(lootItem.item)
            if itemData then
                local itemWeight = itemData.weight * amount
                totalWeight = totalWeight + itemWeight
                receivedItems[lootItem.item] = amount
            end
        end
    end
    
    -- Check if player can carry all items
    local canCarryWeight = exports.ox_inventory:CanCarryWeight(source, totalWeight)
    
    if canCarryWeight and next(receivedItems) then
        -- Give all items to player
        for itemName, amount in pairs(receivedItems) do
            exports.ox_inventory:AddItem(source, itemName, amount)
        end
        return true, receivedItems
    end
    
    return false, {}
end)

lib.callback.register('mgh_vangelico:getCopCount', function(source)
    return CopsConnected
end)

-- Debug command to check cop count
ESX.RegisterCommand('copcount', 'admin', function(xPlayer, args, showError)
    xPlayer.showNotification('Policiers connectés: ' .. CopsConnected)
end, false, {help = 'Affiche le nombre de policiers connectés'})

-- Command to refresh cop count
ESX.RegisterCommand('refreshcops', 'admin', function(xPlayer, args, showError)
    local xPlayers = ESX.GetPlayers()
    CopsConnected = 0
    
    for i = 1, #xPlayers do
        local xPlayerLoop = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayerLoop and table.contains(Config.Police.Jobs, xPlayerLoop.job.name) then
            CopsConnected = CopsConnected + 1
        end
    end
    
    xPlayer.showNotification('Compteur de policiers rafraîchi: ' .. CopsConnected)
    print("[mgh_vangelico] Cop count refreshed: " .. CopsConnected)
end, false, {help = 'Rafraîchit le compteur de policiers'})