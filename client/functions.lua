local F = {}

F.holdingup = false
F.store = ""
F.brokenCases = 0

function F.Notify(message, title, type)
    lib.notify({
        title = title or '',
        description = message,
        type = type or 'inform'
    })
end

function F.CreateBlip(coords, sprite, color, scale, label)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, scale)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandSetBlipName(blip)
    return blip
end

function F.PlayCaseAnimation(ped, x, y, z, heading)
    local animDict = "missheist_jewel"
    local animName = "smash_case"
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(1)
    end
    
    SetEntityCoords(ped, x, y, z - 0.5)
    SetEntityHeading(ped, heading)
    TaskPlayAnim(ped, animDict, animName, 8.0, 1.0, -1, 2, 0, false, false, false)
end

function F.PlayCaseEffects(x, y, z)
    RequestNamedPtfxAsset("scr_jewelheist")
    while not HasNamedPtfxAssetLoaded("scr_jewelheist") do
        Wait(1)
    end
    
    UseParticleFxAssetNextCall("scr_jewelheist")
    StartParticleFxLoopedAtCoord("scr_jewel_cab_smash", x, y, z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
end

function F.ResetStoreCases(storeId)
    F.brokenCases = 0
    local store = Locations.stores[storeId]
    if store then
        for i, _ in pairs(store.display_cases) do
            store.caseStates[i].isOpen = false
        end
    end
end

return F