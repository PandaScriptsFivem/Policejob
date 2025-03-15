lib.callback.register("policejob:checkjob", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local job = xPlayer.job.name
        return(job)
    end
end)

lib.callback.register("policejob:checkid", function(source, target)
    local xPlayer = ESX.GetPlayerFromId(target)
    if xPlayer then
		local data = {
			name = xPlayer.getName(),
			job = xPlayer.job.label,
			grade = xPlayer.job.grade_label,
			inventory = xPlayer.getInventory(),
			accounts = xPlayer.getAccounts(),
            dob = xPlayer.get('dateofbirth'),
			height = xPlayer.get('height')
		}
		if xPlayer.get('sex') == 'm' then data.sex = Config.Locale.ID_Gender_Male else data.sex = Config.Locale.ID_Gender_Female end

        return data
    end
end)
RegisterNetEvent('policejob:getin', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)
    
    if xPlayer and xTarget and IsInJob(source) then
        TriggerClientEvent('policejob:getin', xTarget.source)
    end
end)

RegisterNetEvent('policejob:handcuff', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)
    
    if xPlayer and xTarget and IsInJob(source) then
        TriggerClientEvent('policejob:handcuff', xTarget.source)
    end
end)

RegisterNetEvent('policejob:handcufftry', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)
    
    if xPlayer and xTarget and IsInJob(source) then
        TriggerClientEvent('policejob:handcufftry', xTarget.source, xTarget.source)
        TriggerClientEvent('policejob:handcufftry', xPlayer.source, xTarget.source)
    end
end)


RegisterNetEvent('policejob:checkplate', function(plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and IsInJob(source) then
        local result = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE plate = @plate", {['@plate'] = plate})
        if result[1] then
            local owner = ESX.GetPlayerFromIdentifier(result[1].owner)
            local vehicleData = json.decode(result[1].vehicle) 
            local vehicleModel = vehicleData.model 
            local tuning = {}
            if result[1].vehicle then
                tuning = json.decode(result[1].vehicle)
            end

            if owner then
                TriggerClientEvent('policejob:checkplate', xPlayer.source, owner.getName(), vehicleModel, tuning, owner.source, plate)
            else
                TriggerClientEvent('policejob:checkplate', xPlayer.source, "Ismeretlen", vehicleModel, tuning, "N/A")
            end
        else
            TriggerClientEvent('policejob:checkplate', xPlayer.source, "Ismeretlen", "N/A", {}, "N/A")
        end
    end
end)

RegisterNetEvent('policejob:drag', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)
    
    if xPlayer and xTarget and IsInJob(source) then
        TriggerClientEvent('policejob:drag', xTarget.source, xPlayer.source)
        TriggerClientEvent('policejob:dragStart', xPlayer.source, xTarget.source)
    end
end)

RegisterNetEvent('policejob:dragStop', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)
    
    if xPlayer and xTarget and IsInJob(source) then
        TriggerClientEvent('policejob:dragStop', xTarget.source)
    end
end)

function IsInJob(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local job = xPlayer.job.name
        for i, jobs in ipairs(Config.jobname) do
            if job == jobs then
                return true
            else
                return false
            end
        end
    end
end


RegisterServerEvent('spike:placeProp')
AddEventHandler('spike:placeProp', function(x, y, z, heading)
    TriggerClientEvent('spike:placeProp', -1, x, y, z, heading) -- Minden játékos számára küldjük
end)