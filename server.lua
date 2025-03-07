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
		if xPlayer.get('sex') == 'm' then data.sex = 'Férfi' else data.sex = 'Nő' end

        return data
    end
end)

RegisterServerEvent('policejob:handcufftry')
AddEventHandler('policejob:handcufftry', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)
    if xPlayer and xTarget then
        if IsInJob(source) then
            TriggerClientEvent('policejob:handcufftry', -1, xTarget.source, xPlayer.source)

        end
    end
end)

RegisterServerEvent('policejob:handcuff')
AddEventHandler('policejob:handcuff', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)
    if xPlayer and xTarget then
        if IsInJob(source) then
            TriggerClientEvent('policejob:handcuff', -1, xTarget.source)
        end
    end
end)

RegisterServerEvent('policejob:drag')
AddEventHandler('policejob:drag', function(target)
    local xPlayer = ESX.GetPlayerFromId(source) 
    local xTarget = ESX.GetPlayerFromId(target) 

    if xPlayer and xTarget then
        if IsInJob(source) then
            TriggerClientEvent('policejob:drag', xTarget.source, xPlayer.source)
            TriggerClientEvent('policejob:dragStart', xPlayer.source, xTarget.source)
        end
    end
end)

RegisterServerEvent('policejob:dragStop')
AddEventHandler('policejob:dragStop', function(target)
    local xPlayer = ESX.GetPlayerFromId(source) 
    local xTarget = ESX.GetPlayerFromId(target) 

    if xPlayer and xTarget then
        if IsInJob(source) then
            TriggerClientEvent('policejob:dragStop', xTarget.source)
        end
    end
end)

RegisterServerEvent('policejob:getin')
AddEventHandler('policejob:getin', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)

    if xPlayer and xTarget then
        if IsInJob(source) then
            TriggerClientEvent('policejob:getin', xTarget.source)
        end
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
