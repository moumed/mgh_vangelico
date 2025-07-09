local F = require 'client.functions'
local storeMarkers = {}
local storeZones = {}
local caseMarkers = {}
local caseZones = {}
local soundid = GetSoundId()
local robberyStartTime = 0
local alarmStartTime = 0

RegisterNetEvent('mgh_vangelico:currentlyrobbing')
AddEventHandler('mgh_vangelico:currentlyrobbing', function(robb)
	F.holdingup = true
	F.store = robb
	robberyStartTime = GetGameTimer()
	alarmStartTime = GetGameTimer()
	
	-- Start alarm sound
	local store = Locations.stores[robb]
	if store then
		PlaySoundFromCoord(soundid, "VEHICLES_HORNS_AMBULANCE_WARNING", store.position.x, store.position.y, store.position.z)
	end
end)

RegisterNetEvent('mgh_vangelico:toofarlocal')
AddEventHandler('mgh_vangelico:toofarlocal', function(robb)
	F.holdingup = false
	robberyStartTime = 0
	alarmStartTime = 0
end)

RegisterNetEvent('mgh_vangelico:robberycomplete')
AddEventHandler('mgh_vangelico:robberycomplete', function(robb)
	F.holdingup = false
	F.Notify(_U('robbery_complete'), '', 'success')
	F.store = ""
	robberyStartTime = 0
	alarmStartTime = 0
end)

-- Thread to handle robbery and alarm timeouts
CreateThread(function()
	while true do
		if F.holdingup then
			local currentTime = GetGameTimer()
			
			-- Check if max robbery time exceeded
			if robberyStartTime > 0 and (currentTime - robberyStartTime) >= Config.MaxRobberyTime then
				F.Notify(_U('robbery_timeout'), '', 'error')
				TriggerServerEvent('mgh_vangelico:endrob', F.store)
				F.holdingup = false
				StopSound(soundid)
				robberyStartTime = 0
				alarmStartTime = 0
			end
			
			-- Check if alarm should stop
			if alarmStartTime > 0 and (currentTime - alarmStartTime) >= Config.AlarmDuration then
				StopSound(soundid)
				alarmStartTime = 0
				F.Notify(_U('alarm_stopped'), '', 'inform')
			end
			
			Wait(1000)
		else
			Wait(5000)
		end
	end
end)

CreateThread(function()
	if not Config.UseBlips then return end
	
	for k,v in pairs(Locations.stores) do
		F.CreateBlip(v.position, v.blip.sprite, v.blip.color, v.blip.scale, _U('shop_robbery'))
	end
end)

for k,v in pairs(Locations.stores) do
    storeMarkers[k] = lib.marker.new({
        type = 27,
        coords = vec3(v.position.x, v.position.y, v.position.z - 0.9),
        color = { r = 255, g = 0, b = 0, a = 200 },
        width = 2.001,
        height = 0.5001
    })

    v.caseStates = {}
    for i,case in pairs(v.display_cases) do
        v.caseStates[i] = { isOpen = false }
    end

    storeZones[k] = lib.zones.sphere({
        coords = vec3(v.position.x, v.position.y, v.position.z),
        radius = 15,
        debug = false,
        inside = function()
            if not F.holdingup then
                if Config.EnableMarker then
                    storeMarkers[k]:draw()
                end
            else
                for i,case in pairs(v.display_cases) do
                    if not v.caseStates[i].isOpen and Config.EnableMarker then
                        caseMarkers[i]:draw()
                    end
                end
            end
        end,
        onExit = function()
            if F.holdingup and F.store == k then
                TriggerServerEvent('mgh_vangelico:toofar', k)
                F.holdingup = false
                for i,_ in pairs(v.display_cases) do 
                    v.caseStates[i].isOpen = false
                    F.brokenCases = 0
                end
                StopSound(soundid)
            end
        end
    })

    lib.zones.sphere({
        coords = vec3(v.position.x, v.position.y, v.position.z),
        radius = 1.0,
        debug = false,
        inside = function()
            if not F.holdingup and IsPedShooting(cache.ped) then
                -- Always try to rob, let server handle cop count verification
                TriggerServerEvent('mgh_vangelico:rob', k)
                -- Sound will be managed by the robbery start event
            end
        end,
        onEnter = function()
            if not F.holdingup then
                lib.showTextUI(_U('press_to_rob'), {
                    position = 'top-center',
                    icon = 'gun',
                    iconColor = '#30c940'
                })
            end
        end,
        onExit = function()
            lib.hideTextUI()
        end
    })

    for i,case in pairs(v.display_cases) do
        caseMarkers[i] = lib.marker.new({
            type = 20,
            coords = vec3(case.x, case.y, case.z),
            color = { r = 0, g = 255, b = 0, a = 200 },
            width = 0.3,
            height = 0.3
        })

        caseZones[i] = lib.zones.sphere({
            coords = vec3(case.x, case.y, case.z),
            radius = 0.75,
            debug = false,
            onEnter = function()
                if F.holdingup and not v.caseStates[i].isOpen then
                    lib.showTextUI(_U('press_to_collect'), {
                        position = 'right-center',
                        icon = 'gem',
                        iconColor = '#4a76d4'
                    })
                end
            end,
            onExit = function()
                lib.hideTextUI()
            end
        })
    end
end

CreateThread(function()
    while true do
        if F.holdingup then
            local playerCoords = GetEntityCoords(cache.ped)
            local store = Locations.stores[F.store]
            
            for i,case in pairs(store.display_cases) do
                if not store.caseStates[i].isOpen and caseZones[i]:contains(playerCoords) then
                    if IsControlJustPressed(0, 38) then
                        lib.hideTextUI()
                        
                        local canProceed = true
                        if Config.Skillcheck then
                            local success = lib.skillCheck({'medium', 'medium', 'medium'}, {'w', 'a', 's', 'd'})
                            if not success then
                                F.Notify(_U('skillcheck_failed'), '', 'error')
                                canProceed = false
                            end
                        end

                        if canProceed then
                            F.PlayCaseAnimation(cache.ped, case.x, case.y, case.z, case.w)
                            store.caseStates[i].isOpen = true 
                            F.PlayCaseEffects(case.x, case.y, case.z)
                            
                            F.Notify(_U('collectinprogress'), '', 'inform')
                            Wait(Config.CaseBreakingTime)
                            ClearPedTasksImmediately(cache.ped)
                            
                            lib.callback('mgh_vangelico:getLoot', false, function(success, items)
                                if success then
                                    PlaySound(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                                    F.brokenCases = F.brokenCases + 1
                                    
                                    -- Show notification for received items
                                    for itemName, amount in pairs(items) do
                                        F.Notify(_U('received_item') .. amount .. _U('times') .. _U(itemName), '', 'success')
                                    end
                                    
                                    if F.brokenCases >= Config.MaxWindows then 
                                        F.ResetStoreCases(F.store)
                                        TriggerServerEvent('mgh_vangelico:endrob', F.store)
                                        F.holdingup = false
                                        StopSound(soundid)
                                    end
                                else
                                    F.Notify(_U('inventory_full'), '', 'error')
                                end
                            end)
                        end
                    end
                end
            end
            Wait(0)
        else
            Wait(1000)
        end
    end
end)