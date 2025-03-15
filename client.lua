local ispolice = false
local clocked = false
local locthet = false
local handcuffed = false
local isDragging = false
local draggedPlayer = nil
local vehicles = Config.Vehicles.vehicle
local helicopters = Config.Vehicles.helicopters
local hasVehicles = #vehicles > 0
local hasHelicopters = #helicopters > 0
local helicopterColor = hasHelicopters and "#34ed66" or "#ff0000"
local carColor = hasVehicles and "#34ed66" or "#ff0000"
local allowedVehicles = {}
obj = {}
options = {}

local function IsInJob()
    local job = ESX.PlayerData.job.name
    for i, jobs in ipairs(Config.jobname) do
        if job == jobs then
            return true
        else
            return false
        end
    end
end

Citizen.CreateThread(function ()
    local blip = AddBlipForCoord(Config.Blip.coords)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipScale(blip, Config.Blip.scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Locale.BlipName)
    EndTextCommandSetBlipName(blip)
    SetBlipAsShortRange(blip, true)
end)

local function clocking()
    if not clocked then
        options = {
            {
                title = Config.Locale.Clockin_Title,
                description = Config.Locale.Clockin_Desc,
                icon = "circle-check",
                iconColor = "#34ed66",
                onSelect = function ()
                    lib.progressCircle({
                        duration = 2000,
                        position = 'bottom',
                        useWhileDead = false,
                        disable = {
                            car = true,
                            move = true
                        },
                        anim = {
                            dict = 'amb@world_human_clipboard@male@base', 
                            clip = 'base', 
                            flag = 49,  
                        },
                        prop = {
                            model = `m23_2_prop_m32_clipboard_01a`, 
                            pos = vec3(0.02, 0.00, 0.05),
                            rot = vec3(90,0,0)
                        }
                    })
                    clocked = true
                    lib.notify({
                        description = Config.Locale.Clockin_Notify,
                        type = "success"
                    })
                end
            }
        }
    else
        options = {
            {
                title = Config.Locale.ClockOut_Title,
                description = Config.Locale.ClockOut_Desc,
                icon = "circle-xmark",
                iconColor = "#ed4434",
                onSelect = function ()
                    lib.progressCircle({
                        duration = 2000,
                        position = 'bottom',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                        },
                        anim = {
                            dict = 'amb@world_human_clipboard@male@base', 
                            clip = 'base', 
                            flag = 49,  
                        },
                        prop = {
                            model = `m23_2_prop_m32_clipboard_01a`, 
                            pos = vec3(0.02, 0.00, 0.05),
                            rot = vec3(90,0,0)
                        }
                    })
                    lib.notify({
                        description = "Szolgálat leadva!",
                        type = "warning"
                    })
                    clocked = false
                end
            }
        }
    end
end

local clothing = lib.points.new({
    coords = Config.Clothing.coords,
    distance = 3,
})

function clothing:nearby()
    if clocked then
        local marker = lib.marker.new({
            type = 2,
            coords = self.coords,
            color = { r = 0, g = 0, b = 100, a = 100 },
            width = 0.3,
            height = 0.2
        })
        marker:draw()
        if IsControlJustReleased(0, 38) then
            if locthet then
                lib.registerContext({
                    id = "ruha",
                    title = Config.Locale.Clothing_Title,
                    options = {
                        {
                            title = Config.Locale.Clothing_Title,
                            description = Config.Locale.unClothing_Desc,
                            icon = "shirt",
                            iconColor = "#34ed66",
                            onSelect = function()
                                lib.progressCircle({
                                    duration = 3000, 
                                    useWhileDead = false,
                                    canCancel = false,
                                    disable = {
                                        move = true,
                                        car = true,
                                        combat = true
                                    },
                                    anim = {
                                        dict = 'clothingshirt',
                                        clip = 'try_shirt_positive_a'
                                    }
                                })
                                TriggerEvent('skinchanger:getSkin', function(skin)
                                    TriggerEvent('skinchanger:loadSkin', skin)
                                    TriggerEvent('esx:restoreLoadout')
                                end)
                                locthet = not locthet
                            end
                        }
                    }
                })
                lib.showContext("ruha")
            else
                lib.registerContext({
                    id = "ruha",
                    title = Config.Locale.Clothing_Title,
                    options = {
                        {
                            title = Config.Locale.Clothing_Title,
                            description = Config.Locale.Clothing_Desc,
                            icon = "shirt",
                            iconColor = "#34ed66",
                            onSelect = function()
                                TriggerEvent('skinchanger:getSkin', function(skin)
                                    lib.progressCircle({
                                        duration = 3000,
                                        useWhileDead = false,
                                        canCancel = false,
                                        disable = {
                                            move = true,
                                            car = true,
                                            combat = true
                                        },
                                        anim = {
                                            dict = 'clothingshirt',
                                            clip = 'try_shirt_positive_a'
                                        }
                                    })
                                    if skin.sex == 0 then
                                        TriggerEvent('skinchanger:loadClothes', skin, Config.Clothing.male)
                                    else 
                                        TriggerEvent('skinchanger:loadClothes', skin, Config.Clothing.female)
                                    end
                                end)
                                locthet = not locthet
                            end
                        }
                    }
                })
                lib.showContext("ruha")
                
            end
        end
    end
end

function clothing:onEnter()
    lib.showTextUI(Config.Locale.Clothing, {
        position = "right-center",
        icon = 'clothing',
    })
end

function clothing:onExit()
    lib.hideTextUI()
end

lib.points.new({
    coords = Config.Clockin.coords,
    distance = 3,
    onEnter = function ()
        lib.callback("policejob:checkjob", false, function(job)
            if IsInJob() then
                ispolice = true
            else
                return
            end
        end)
        Wait(150)
        if ispolice then
            lib.showTextUI(Config.Locale.Clockin, {
                position = "right-center",
                icon = 'clock',
            })
        end
        if not ispolice then
            return
        end
    end,
    onExit = function ()
        lib.hideTextUI()
    end,
    nearby = function ()
    if ispolice then
        if IsControlJustReleased(0, 38) then
            clocking()
           lib.registerContext({
            id = "pd",
            title = "Rendőrség",
            options = options
           })
            lib.showContext('pd')
        end
    end
    end
})

local function isPositionOccupied(coords)
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        if #(coords - vehicleCoords) < 2.0 then 
            return true
        end
    end
    return false
end

local function spawnVehicle(model, coords, heading)
    local hash = GetHashKey(model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        print("^1[Error] ^7 Invalid Model: " .. model)
        return
    end

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end

    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, true, false)
    SetVehicleOnGroundProperly(vehicle)
    SetModelAsNoLongerNeeded(hash)
    return vehicle
end

local function getFreeOutCoords()
    for _, outcoord in ipairs(Config.Vehicles.outcoords) do
        local coords = vector3(outcoord[1], outcoord[2], outcoord[3])
        if not isPositionOccupied(coords) then
            return coords, outcoord[4]
        end
    end
    return nil
end

local function getFreeheliOutCoords()
    for _, outcoord in ipairs(Config.Vehicles.helioutcoords) do
        local coords = vector3(outcoord[1], outcoord[2], outcoord[3])
        if not isPositionOccupied(coords) then
            return coords, outcoord[4] 
        end
    end
    return nil 
end

lib.points.new({
    coords = Config.Vehicles.Coords,
    distance = 3,
    onEnter = function()
        if clocked then
            lib.showTextUI(Config.Locale.Vehicle_Get, {
                position = "right-center",
                icon = 'car',
            })
        end
    end,
    onExit = function()
        lib.hideTextUI()
    end,
    nearby = function()
        if not clocked then return end

        if IsControlJustReleased(0, 38) then
            local playerGrade = ESX.PlayerData.job.grade

            local function openVehicleMenu()
                local options = {
                    {
                        title = Config.Locale.Back,
                        icon = "arrow-left",
                        iconColor = "#ffffff",
                        onSelect = function() lib.showContext('pd') end
                    }
                }

                for _, vehicleData in ipairs(vehicles) do
                    local isAvailable = vehicleData.grade <= playerGrade
                    table.insert(options, {
                        title = vehicleData.label,
                        description = isAvailable and (Config.Locale.Vehicle_Take .. " " .. vehicleData.label) or Config.Locale.Vehicle_NoPermission,
                        icon = "car",
                        iconColor = isAvailable and "#34ed66" or "#ff0000",
                        disabled = not isAvailable,
                        onSelect = isAvailable and function()
                            local coords, heading = getFreeOutCoords()
                            if coords then
                                spawnVehicle(vehicleData.model, coords, heading)
                                lib.notify({description = vehicleData.label .. Config.Locale.Vehicle_TakeOut, type = "success"})
                            else
                                lib.notify({description = Config.Locale.Vehicle_NoParking, type = "error"})
                            end
                        end or nil
                    })
                end

                lib.registerContext({
                    id = "pd_vehicles",
                    title = "Járművek",
                    options = options
                })
                lib.showContext('pd_vehicles')
            end

            local function openHelicopterMenu()
                local options = {
                    {
                        title = Config.Locale.Back,
                        icon = "arrow-left",
                        iconColor = "#ffffff",
                        onSelect = function() lib.showContext('pd') end
                    }
                }

                for _, helicopterData in ipairs(helicopters) do
                    local isAvailable = helicopterData.grade <= playerGrade
                    table.insert(options, {
                        title = helicopterData.label,
                        description = isAvailable and "Vegyél ki egy " .. helicopterData.label .. " helikoptert!" or "Nincs jogosultságod ehhez a helikopterhez!",
                        icon = "helicopter",
                        iconColor = isAvailable and "#34ed66" or "#ff0000",
                        disabled = not isAvailable,
                        onSelect = isAvailable and function()
                            local coords, heading = getFreeheliOutCoords()
                            if coords then
                                spawnVehicle(helicopterData.model, coords, heading)
                                lib.notify({description = helicopterData.label .. " kivéve!", type = "success"})
                            else
                                lib.notify({description = "Nincs szabad parkolóhely!", type = "error"})
                            end
                        end or nil
                    })
                end

                lib.registerContext({
                    id = "pd_helicopters",
                    title = "Helikopterek",
                    options = options
                })
                lib.showContext('pd_helicopters')
            end

            lib.registerContext({
                id = "pd",
                title = "Rendőrség",
                options = {
                    {
                        title = "Jármüvek",
                        arrow = true,
                        description = hasVehicles and "Válassz egy jármüvet!" or "Nincsen elérhető Jármüvek!",
                        icon = "car",
                        iconColor = carColor,
                        disabled = not hasVehicles,
                        onSelect = hasVehicles and openVehicleMenu or nil
                    },
                    {
                        title = "Helikopterek",
                        arrow = true,
                        description = hasHelicopters and "Válassz egy helikoptert!" or "Nincs elérhető helikopter!",
                        icon = "helicopter",
                        iconColor = helicopterColor,
                        disabled = not hasHelicopters,
                        onSelect = hasHelicopters and openHelicopterMenu or nil
                    }
                }
            })
            lib.showContext('pd')
        end
    end
})

for _, v in ipairs(Config.Vehicles.vehicle) do
    allowedVehicles[GetHashKey(v.model)] = true
end
for _, v in ipairs(Config.Vehicles.helicopters) do
    allowedVehicles[GetHashKey(v.model)] = true
end

lib.points.new({
    coords = Config.Vehicles.DelCoords,
    distance = 5,
    onEnter = function()
        local playerPed = PlayerPedId()
        if not clocked or not IsPedInAnyVehicle(playerPed, false) then return end

        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local vehicleModel = GetEntityModel(vehicle)

        if allowedVehicles[vehicleModel] then
            lib.showTextUI(Config.Locale.Vehicle_Del, {
                position = "right-center",
                icon = 'car',
            })
        end
    end,
    onExit = function()
        lib.hideTextUI()
    end,
    nearby = function()
        local playerPed = PlayerPedId()
        if not clocked or not IsPedInAnyVehicle(playerPed, false) then return end

        if IsControlJustReleased(0, 38) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local vehicleModel = GetEntityModel(vehicle)

            if allowedVehicles[vehicleModel] then
                TaskLeaveVehicle(playerPed, vehicle, 0)
                Wait(1000)

                if NetworkHasControlOfEntity(vehicle) or NetworkRequestControlOfEntity(vehicle) then
                    ESX.Game.DeleteVehicle(vehicle)
                    lib.notify({ description = "Jármű visszaadva!", type = "success" })
                    lib.hideTextUI()
                else
                    lib.notify({ description = "Nem sikerült eltávolítani a járművet!", type = "error" })
                end
            else
                lib.notify({ description = "Ez a jármű nem adható vissza itt!", type = "error" })
            end
        end
    end
})

local function isVehicleAllowed(vehicleModel)
    return allowedVehicles[vehicleModel] or false
end

lib.points.new({
    coords = Config.Vehicles.HeliDelCoords,
    distance = 8,
    onEnter = function()
        local playerPed = PlayerPedId()
        if not clocked or not IsPedInAnyVehicle(playerPed, false) then return end

        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if isVehicleAllowed(GetEntityModel(vehicle)) then
            lib.showTextUI(Config.Locale.Vehicle_Get, {
                position = "right-center",
                icon = 'car',
            })
        end
    end,
    onExit = function()
        lib.hideTextUI()
    end,
    nearby = function()
        local playerPed = PlayerPedId()
        if not clocked or not IsPedInAnyVehicle(playerPed, false) then return end

        if IsControlJustReleased(0, 38) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local vehicleModel = GetEntityModel(vehicle)

            if isVehicleAllowed(vehicleModel) then
                TaskLeaveVehicle(playerPed, vehicle, 0)
                Wait(2000)

                if NetworkHasControlOfEntity(vehicle) or NetworkRequestControlOfEntity(vehicle) then
                    ESX.Game.DeleteVehicle(vehicle)
                    lib.notify({ description = "Jármű visszaadva!", type = "success" })
                    lib.hideTextUI()
                else
                    lib.notify({ description = "Nem sikerült eltávolítani a járművet!", type = "error" })
                end
            else
                lib.notify({ description = "Ez a jármű nem adható vissza itt!", type = "error" })
            end
        end
    end
})

lib.points.new({
    coords = Config.boss.coords,
    distance = 2,
    onEnter = function()
        local playerGrade =  ESX.PlayerData.job.grade
        if ispolice and playerGrade == Config.boss.grade and clocked then
            lib.showTextUI(Config.Locale.BossMenu, {
                position = "right-center",
                icon = 'clipboard',
            })
        end
    end,
    nearby = function()
        local playerGrade =  ESX.PlayerData.job.grade
        if IsControlJustReleased(0, 38) and ispolice and playerGrade == Config.boss.grade and clocked then
            for i, v in ipairs(Config.jobname) do
                TriggerEvent('esx_society:openBossMenu', v, function(data, menu)
                    ESX.CloseContext()
                end, { wash = false })
            end
        end
    end,
    onExit = function()
        lib.hideTextUI()
    end
})

local function PlaceObject(prop, icon)
    local modelName = prop
    local playerPed = PlayerPedId()
    local forwardVector = GetEntityForwardVector(playerPed)
    local playerCoords = GetEntityCoords(playerPed)

    if not IsModelInCdimage(modelName) then
        return print("A modell nem található a játékban.")
    end

    RequestModel(modelName)
    while not HasModelLoaded(modelName) do
        Wait(100)
    end

    local propCoords = vector3(playerCoords.x + forwardVector.x * 1.5, playerCoords.y + forwardVector.y * 1.5, playerCoords.z)
    local prop = CreateObjectNoOffset(modelName, propCoords.x, propCoords.y, propCoords.z, false, false, false)
    SetEntityCollision(prop, false, false)
    SetEntityAlpha(prop, 200, false)
    FreezeEntityPosition(prop, true)
    local editing = true

    SetEntityVisible(prop, true, false)
    PlaceObjectOnGroundProperly(prop)
    lib.showTextUI(Config.Locale.Prop_Rotate)
    SetEntityDrawOutline(prop, true)

        Citizen.CreateThread(function()
        while editing do
            Citizen.Wait(0)
            local x, y, z = table.unpack(GetEntityCoords(prop))
            local heading = GetEntityHeading(prop)
            local playerHeading = GetEntityHeading(playerPed)
            local rad = math.rad(playerHeading)
    
            if IsControlPressed(0, 172) then
                local forwardX = -math.sin(rad) * 0.02
                local forwardY = math.cos(rad) * 0.02
                if IsControlPressed(0, 174) then
                    SetEntityCoords(prop, x + (forwardX - math.cos(rad) * 0.02), y + (forwardY - math.sin(rad) * 0.02), z)
                elseif IsControlPressed(0, 175) then
                    SetEntityCoords(prop, x + (forwardX + math.cos(rad) * 0.02), y + (forwardY + math.sin(rad) * 0.02), z)
                else
                    SetEntityCoords(prop, x + forwardX, y + forwardY, z)
                end
            end
    
            if IsControlPressed(0, 173) then
                local backwardX = math.sin(rad) * 0.02
                local backwardY = -math.cos(rad) * 0.02
                if IsControlPressed(0, 174) then
                    SetEntityCoords(prop, x + (backwardX - math.cos(rad) * 0.02), y + (backwardY - math.sin(rad) * 0.02), z)
                elseif IsControlPressed(0, 175) then
                    SetEntityCoords(prop, x + (backwardX + math.cos(rad) * 0.02), y + (backwardY + math.sin(rad) * 0.02), z)
                else
                    SetEntityCoords(prop, x + backwardX, y + backwardY, z)
                end
            end
    
            if IsControlPressed(0, 174) and not IsControlPressed(0, 172) and not IsControlPressed(0, 173) then
                local leftX = -math.cos(rad) * 0.02
                local leftY = -math.sin(rad) * 0.02
                SetEntityCoords(prop, x + leftX, y + leftY, z)
            end
    
            if IsControlPressed(0, 175) and not IsControlPressed(0, 172) and not IsControlPressed(0, 173) then
                local rightX = math.cos(rad) * 0.02
                local rightY = math.sin(rad) * 0.02
                SetEntityCoords(prop, x + rightX, y + rightY, z)
            end
    
            if IsControlPressed(0, 44) then
                SetEntityCoords(prop, x, y, z + 0.02)
            end
    
            if IsControlPressed(0, 38) then
                SetEntityCoords(prop, x, y, z - 0.02)
            end
    
            if IsControlPressed(0, 14) then
                SetEntityHeading(prop, heading + 1.5)
            end
    
            if IsControlPressed(0, 15) then
                SetEntityHeading(prop, heading - 1.5)
            end
    
            if IsControlJustPressed(0, 191) then
                editing = false
                PlaceObjectOnGroundProperly(prop)
                local props = CreateObjectNoOffset(modelName, GetEntityCoords(prop), true, false, false)
                SetEntityHeading(props, GetEntityHeading(prop))
                DeleteObject(prop) 
                SetEntityCollision(props, true, true)
                SetEntityVisible(props, true, true)
                FreezeEntityPosition(props, false)
                SetObjectAsNoLongerNeeded(prop)
            
                lib.hideTextUI()
                propCoords = GetEntityCoords(props)
                table.insert(obj, props)
                local point = lib.points.new({
                    coords = propCoords,
                    distance = 1.5,
                    onEnter = function()
                        lib.showTextUI(Config.Locale.Prop_Delete, {
                            position = "right-center",
                            icon = icon
                        })
                    end,
                    onExit = function()
                        lib.hideTextUI()
                    end
                })
                function point:nearby()
                    if IsControlJustReleased(0, 38) then
                        SetEntityAsMissionEntity(props, false, false) 
                        for i, v in ipairs(obj) do
                            if v == props then
                                table.remove(obj, i)
                                break
                            end
                        end
                        DeleteEntity(props)
                        DeleteObject(props)
                        self:remove()
                        lib.hideTextUI()
                    end
                end
            end
        end
    end)
end

local function updateContextMenu()
    lib.registerContext({
        id = "f",
        title = Config.Locale.BlipName,
        options = {
            {
                title = Config.Locale.Menu_Peaple,
                icon = "handshake",
                onSelect = function()
                    local player, distance = ESX.Game.GetClosestPlayer()
                    local isPlayerNear = distance ~= -1 and distance <= 3.0
                    local closestVehicle = lib.getClosestVehicle(GetEntityCoords(PlayerPedId()), 3.0, true)
                    lib.registerContext({
                        id = "ember",
                        title = Config.Locale.Menu_Peaple,
                        menu = "f",
                        options = {
                            {
                                title = Config.Locale.Menu_checkID,
                                icon = "id-card",
                                onSelect = function()
                                    if isPlayerNear then
                                        lib.callback('policejob:checkid', false, function(data)
                                            if data then
                                                lib.registerContext({
                                                    id = "idcard",
                                                    title = Config.Locale.Menu_checkID,
                                                    menu = "ember",
                                                    options = {
                                                        {
                                                            title = Config.Locale.ID_Name .. data.name,
                                                            icon = "id-card",
                                                            iconColor = "#ffffff",
                                                            description = Config.Locale.Copy,
                                                            onSelect = function()
                                                                lib.setClipboard(data.name)
                                                                lib.notify({
                                                                    description = Config.Locale.Copy_Notify,
                                                                    type = "success"
                                                                })
                                                            end
                                                        },
                                                        {
                                                            title = Config.Locale.ID_Job .. data.job.. " - " .. data.grade,
                                                            icon = "briefcase",
                                                            iconColor = "#bf6412"
                                                        },
                                                        {
                                                            title = Config.Locale.ID_Gender .. data.sex,
                                                            icon = data.sex == Config.Locale.ID_Gender_Male and "mars" or "venus",
                                                            iconColor = data.sex == Config.Locale.ID_Gender_Male and "#3e98f2" or "#f23edc"
                                                        },
                                                        {
                                                            title = Config.Locale.ID_DOB .. data.dob,
                                                            icon = "baby",
                                                            iconColor = "#ffffff",
                                                            description = Config.Locale.Copy,
                                                            onSelect = function()
                                                                lib.setClipboard(data.dob)
                                                                lib.notify({
                                                                    description = Config.Locale.Copy_Notify,
                                                                    type = "success"
                                                                })
                                                            end
                                                        },
                                                        {
                                                            title = Config.Locale.ID_Height .. data.height,
                                                            icon = "up-down",
                                                            iconColor = "#ffffff"
                                                        }
                                                    }
                                                })
                                                lib.showContext("idcard")
                                            end
                                        end, GetPlayerServerId(player))
                                    else
                                        lib.notify({
                                            description = Config.Locale.No_Player_Nearby,
                                            type = "warning"
                                        })
                                    end
                                end,
                                iconColor = isPlayerNear and "#34ed66" or "#ff0000" 
                            },
                            {
                                title = Config.Locale.Search,
                                icon = "search",
                                onSelect = function()
                                    if isPlayerNear then
                                        exports.ox_inventory:openNearbyInventory()
                                    else
                                        lib.notify({
                                            description = Config.Locale.No_Player_Nearby,
                                            type = "warning"
                                        })
                                    end
                                end,
                                iconColor = isPlayerNear and "#34ed66" or "#ff0000"
                            },
                            {
                                title = Config.Locale.HandCuff,
                                icon = "handcuffs",
                                onSelect = function()
                                    if isPlayerNear then
                                        if Config.tryCuffs then
                                            TriggerServerEvent('policejob:handcufftry', GetPlayerServerId(player))
                                            local success = lib.skillCheck({'easy'})
                                            if success then
                                                TriggerServerEvent('policejob:handcuff', GetPlayerServerId(player))
                                            end
                                        else
                                            TriggerServerEvent('policejob:handcufftry', GetPlayerServerId(player))
                                            Wait(3500)
                                            TriggerServerEvent('policejob:handcuff', GetPlayerServerId(player))
                                        end
                
                                    else
                                        lib.notify({
                                            description = Config.Locale.No_Player_Nearby,
                                            type = "warning"
                                        })
                                    end
                                end,
                                iconColor = isPlayerNear and "#34ed66" or "#ff0000"
                            },
                            {
                                title = Config.Locale.Escort,
                                icon = "person-walking",
                                onSelect = function()
                                    if isPlayerNear then
                                        TriggerServerEvent('policejob:drag', GetPlayerServerId(player))
                                    else
                                        lib.notify({
                                            description = Config.Locale.No_Player_Nearby,
                                            type = "warning"
                                        })
                                    end
                                end,
                                iconColor = isPlayerNear and "#34ed66" or "#ff0000"
                            },
                            {
                                title = Config.Locale.Put_Out_car,
                                icon = "car-side",
                                onSelect = function()
                                    if closestVehicle and isPlayerNear then
                                        TriggerServerEvent('policejob:getin', GetPlayerServerId(player))
                                    elseif isPlayerNear then
                                        lib.notify({
                                            description = Config.Locale.No_Vehicle_Nearby,
                                            type = "warning"
                                        })
                                    elseif closestVehicle then
                                        lib.notify({
                                            description = Config.Locale.No_Player_Nearby,
                                            type = "warning"
                                        })
                                    else
                                        lib.notify({
                                            description = Config.Locale.No_Vehicle_and_Player_Nearby,
                                            type = "warning"
                                        })
                                    end
                                end,
                                iconColor = closestVehicle and "#34ed66" or "#ff0000"
                            },
                        }
                    })
                    lib.showContext("ember")
                end
            },
            {
                title = Config.Locale.Menu_vehicle,
                icon = "car",
                onSelect = function()
                    local closestVehicle = lib.getClosestVehicle(GetEntityCoords(PlayerPedId()), 2.0, true)
                    lib.registerContext({
                        id = "kocsi",
                        title = Config.Locale.Menu_vehicle,
                        menu = "f",
                        options = {
                            {
                                title = Config.Locale.VehicleMenu_Inpound,
                                icon = "car-side",
                                iconColor = closestVehicle and "#34ed66" or "#ff0000",
                                onSelect = function()
                                    if closestVehicle then
                                        lib.progressCircle({
                                            duration = 3500,
                                            position = 'bottom',
                                            useWhileDead = false,
                                            disable = {
                                                car = true,
                                            },
                                            anim = {
                                                dict = 'mp_car_bomb',
                                                clip = 'car_bomb_mechanic',
                                                flag = 3
                                            },
                                        }) 
                                        NetworkRequestControlOfEntity(closestVehicle)
                                        Wait(250)
                                        DeleteEntity(closestVehicle)
                                    else
                                        lib.notify({
                                            description = Config.Locale.No_Vehicle_Nearby,
                                            type = "warning"
                                        })
                                    end
                                end
                            },
                            {
                                title = Config.Locale.VehicleMenu_Info,
                                icon = "car",
                                iconColor = "#34ed66",
                                onSelect = function()
                                    if closestVehicle then
                                        TriggerServerEvent('policejob:checkplate', GetVehicleNumberPlateText(closestVehicle))
                                    --[[else
                                        local input = lib.inputDialog('Rendszám', {
                                            {type = 'input', label = 'Jármü Rendszáma', default = 'ABC 123',  required = true, min = 3, max = 7},
                                        })
 
                                        if not input then return end
                                        TriggerServerEvent('policejob:checkplate', input[1])]]
                                    end
                                end
                            },
                            {
                                title = Config.Locale.Vehicle_Menu_Lockpick,
                                icon = "lock-open",
                                iconColor = closestVehicle and "#34ed66" or "#ff0000",
                                onSelect = function()
                                    local locked = GetVehicleDoorLockStatus(closestVehicle)
                                    if closestVehicle and locked == 2 then
                                        lib.progressCircle({
                                            duration = 3500,
                                            position = 'bottom',
                                            useWhileDead = false,
                                            disable = {
                                                car = true,
                                            },
                                            anim = {
                                                dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                                                clip = 'machinic_loop_mechandplayer',
                                                flag = 1
                                            },
                                        }) 
                                        SetVehicleDoorsLocked(closestVehicle, 1)
                                        SetVehicleDoorsLockedForAllPlayers(closestVehicle, false)
                                        SetVehicleNeedsToBeHotwired(closestVehicle, false)
                                        IsVehicleNeedsToBeHotwired(closestVehicle)
                                        lib.notify({
                                            description = Config.Locale.Vehicle_Unlocked,
                                            type = "success"
                                        })
                                    elseif not closestVehicle then
                                        lib.notify({
                                            description = Config.Locale.No_Vehicle_Nearby,
                                            type = "warning"
                                        })
                                    elseif locked then
                                        lib.notify({
                                            description = Config.Locale.Vehicle_Not_lock,
                                            type = "warning"
                                        })
                                    else
                                        lib.notify({
                                            description = Config.Locale.No_Vehicle_Nearby,
                                            type = "warning"
                                        })
                                    end
                                end
                            }
                        }
                    })
                    lib.showContext("kocsi")
                end
            },
            {
                title = Config.Locale.Menu_Object,
                icon = "road-barrier",
                onSelect = function()
                    lib.registerContext({
                        id = "obj",
                        title = Config.Locale.Menu_Object,
                        menu = "f",
                        options = {
                            {
                                title = Config.Locale.Object_Barrier,
                                icon = "road-barrier",
                                onSelect = function()
                                    PlaceObject("prop_barrier_work05", "road-barrier")
                                end
                            },
                            {
                                title = Config.Locale.Object_RoadCone,
                                icon = "life-ring",
                                onSelect = function()
                                    PlaceObject("prop_roadcone02a", "life-ring")
                                end
                            },
                            {
                                title = Config.Locale.Object_SpikeStrip,
                                icon = "xmarks-lines",
                                onSelect = function()
                                    PlaceObject("p_ld_stinger_s", "xmarks-lines")
                                end
                            }
                        }
                    })
                    lib.showContext("obj")
                end
            }
        }
    })
end
local function rgbToHex(r, g, b)
    if type(r) == "number" and type(g) == "number" and type(b) == "number" then
        return string.format("#%02X%02X%02X", r, g, b)
    else
        return "#FFFFFF"
    end
end

RegisterNetEvent('policejob:checkplate', function(owner, modell, tuning, id, plate)
    local closestVehicle = lib.getClosestVehicle(GetEntityCoords(PlayerPedId()), 2.0, true)
    local modelName = GetDisplayNameFromVehicleModel(modell)
    modelName = modelName:lower()
    local r, g, b = GetVehicleCustomPrimaryColour(closestVehicle)
    local r2, g2, b2 = GetVehicleCustomSecondaryColour(closestVehicle)
    local color1Hex = rgbToHex(r, g, b)
    local color2Hex = rgbToHex(r2, g2, b2)
    lib.registerContext({
        id = "carinfo",
        title = "Jármü Információk",
        menu = "kocsi",
        options = {
            {
                title = "Tulajdonos: " .. owner,
                icon = "user",
                iconColor = "#ffffff",
                description = "Kattints az információk megnézésére!",
                onSelect = function()
                    lib.callback('policejob:checkid', false, function(data)
                        if data then
                            lib.registerContext({
                                id = "idcard",
                                title = "Személyi ellenőrzés",
                                menu = "carinfo",
                                options = {
                                    {
                                        title = "Név: " .. data.name,
                                        icon = "id-card",
                                        iconColor = "#ffffff",
                                        description = "Kattints a vágólapra másoláshoz!",
                                        onSelect = function()
                                            lib.setClipboard(data.name)
                                            lib.notify({
                                                description = "Név kimásolva a vágólapra!",
                                                type = "success"
                                            })
                                        end
                                    },
                                    {
                                        title = "Munka: " .. data.job.. " - " .. data.grade,
                                        icon = "briefcase",
                                        iconColor = "#bf6412"
                                    },
                                    {
                                        title = "Nem: " .. data.sex,
                                        icon = data.sex == "Férfi" and "mars" or "venus",
                                        iconColor = data.sex == "Férfi" and "#3e98f2" or "#f23edc"
                                    },
                                    {
                                        title = "Születési dátum: " .. data.dob,
                                        icon = "baby",
                                        iconColor = "#ffffff",
                                        description = "Kattints a vágólapra másoláshoz!",
                                        onSelect = function()
                                            lib.setClipboard(data.dob)
                                            lib.notify({
                                                description = "Születési dátum kimásolva a vágólapra!",
                                                type = "success"
                                            })
                                        end
                                    },
                                    {
                                        title = "Magasság: " .. data.height,
                                        icon = "up-down",
                                        iconColor = "#ffffff"
                                    }
                                }
                            })
                            lib.showContext("idcard")
                        end
                    end, id)
                end
            },
            {
                title = "Model: " .. modelName,
                icon = "car",
                iconColor = "#3472de"
            },
            {
                title = "Rendszám: ".. plate,
                icon = "rug"
            },
            {
                title = "Elsődleges szín: " .. color1Hex,
                icon = "palette",
                iconColor = color1Hex,
                description = "Az elsődleges szín HEX kódja.",
            },
            {
                title = "Másodlagos szín: " .. color2Hex,
                icon = "palette",
                iconColor = color2Hex,
                description = "A másodlagos szín HEX kódja.",
            },
            {
                title = "Tuning",
                icon = "wrench",
                iconColor = tuning and "#34ed66" or "#ff0000",
                onSelect = function()
                    if tuning then
                        local motor = tuning.modEngine or "N/A"
                        local armor = tuning.modArmor or "N/A"
                        local brakes = tuning.modBrakes or "N/A"
                        local suspension = tuning.modSuspension or "N/A"
                        local turbo = tuning.modTurbo or "N/A"
                        local transmission = tuning.modTransmission or "N/A"
            
                        lib.registerContext({
                            id = "mods",
                            title = "Tuning",
                            menu = "carinfo",
                            options = {
                                {
                                    title = "Motor: " .. motor,
                                    icon = "wrench",
                                    iconColor = motor == "N/A" or motor == -1 and "#ff0000" or "#34ed66",
                                    disabled = motor == "N/A" or motor == -1
                                },
                                {
                                    title = "Páncél: " .. armor,
                                    icon = "shield",
                                    iconColor = armor == "N/A" or armor == -1 and "#ff0000" or "#34ed66",
                                    disabled = armor == "N/A" or armor == -1
                                },
                                {
                                    title = "Fék: " .. brakes,
                                    icon = "wrench",
                                    iconColor = brakes == "N/A" or brakes == -1 and "#ff0000" or "#34ed66",
                                    disabled = brakes == "N/A" or brakes == -1
                                },
                                {
                                    title = "Felfüggesztés: " .. suspension,
                                    icon = "wrench",
                                    iconColor = suspension == "N/A" or suspension == -1 and "#ff0000" or "#34ed66",
                                    disabled = suspension == "N/A" or suspension == -1
                                },
                                {
                                    title = "Turbo: " .. turbo,
                                    icon = "wrench",
                                    iconColor = turbo == "N/A" or turbo == -1 and "#ff0000" or "#34ed66",
                                    disabled = turbo == "N/A" or turbo == -1
                                },
                                {
                                    title = "Váltó: " .. transmission,
                                    icon = "wrench",
                                    iconColor = transmission == "N/A" or transmission == -1 and "#ff0000" or "#34ed66",
                                    disabled = transmission == "N/A" or transmission == -1
                                }
                            }
                        })
                        lib.showContext("mods")
                    else
                        print("Nincs tuning a járművön.")
                    end
                end
            }
        }
    })
    lib.showContext("carinfo")
end)

RegisterNetEvent('policejob:getin', function()
    local playerPed = cache.ped
    local closestVehicle = lib.getClosestVehicle(GetEntityCoords(playerPed), 3.0, true)

    if closestVehicle then
        if IsPedInAnyVehicle(playerPed, false) then
            TaskLeaveVehicle(playerPed, closestVehicle, 0)
        else
            for _, seat in ipairs({0, 1, 2}) do
                if IsVehicleSeatFree(closestVehicle, seat) then
                    TaskEnterVehicle(playerPed, closestVehicle, -1, seat, 1.0, 1, 0)
                    return
                end
            end
        end
    end
end)

local function playAnim(ped, dict, anim, duration, flag)
    lib.requestAnimDict(dict)
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, duration or -1, flag or 49, 0, false, false, false)
end

RegisterNetEvent('policejob:handcufftry', function(target)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
    local policePed = cache.ped

    playAnim(policePed, "mp_arrest_paired", "cop_p2_back_right", 3500, 3)
    playAnim(targetPed, "mp_arrest_paired", "crook_p2_back_right", 3500, 3)

    Wait(3500)

    ClearPedTasks(policePed)
    ClearPedTasks(targetPed)
end)

RegisterNetEvent('policejob:handcuff', function(target)
    local playerPed = cache.ped
    local targetPed = GetPlayerPed(GetPlayerFromServerId(target))

    if targetPed == playerPed then
        local isHandcuffed = Entity(playerPed).state.handcuffed

        if not isHandcuffed then
            Entity(playerPed).state:set('handcuffed', true, true)
            playAnim(playerPed, "mp_arresting", "idle")

            SetEnableHandcuffs(playerPed, true)
            DisablePlayerFiring(playerPed, true)
            SetPedCanPlayGestureAnims(playerPed, false)

            CreateThread(function()
                while Entity(playerPed).state.handcuffed do
                    Wait(0)
                    for _, control in ipairs({22, 23, 24, 25, 36, 45, 49, 75, 59, 63, 64, 140, 141}) do
                        DisableControlAction(0, control, true)
                    end
                    if not IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 49) then
                        playAnim(playerPed, "mp_arresting", "idle")
                    end
                end
            end)
        else
            Entity(playerPed).state:set('handcuffed', false, true)
            ClearPedTasksImmediately(playerPed)
            ClearPedSecondaryTask(playerPed)

            SetEnableHandcuffs(playerPed, false)
            DisablePlayerFiring(playerPed, false)
            SetPedCanPlayGestureAnims(playerPed, true)
        end
    end
end)

RegisterNetEvent('policejob:drag', function(copSource)
    local playerPed = cache.ped
    local copPed = GetPlayerPed(GetPlayerFromServerId(copSource))

    if DoesEntityExist(copPed) then
        Entity(playerPed).state:set('dragged', true, true)

        AttachEntityToEntity(playerPed, copPed, 11816, -0.16, 0.55, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        SetEntityCollision(playerPed, false, false)
        SetEntityInvincible(playerPed, true)
        SetPedCanBeTargetted(playerPed, false)
    end
end)

RegisterNetEvent('policejob:dragStop', function()
    local playerPed = cache.ped
    DetachEntity(playerPed, true, true)
    SetEntityCollision(playerPed, true, true)
    SetEntityInvincible(playerPed, false)
    SetPedCanBeTargetted(playerPed, true)
    if handcuffed then playAnim(playerPed, "mp_arresting", "idle") end
end)

RegisterNetEvent('policejob:dragStart', function(target)
    local playerPed = cache.ped
    Entity(playerPed).state:set('dragging', target, true)

    playAnim(playerPed, "anim@amb@nightclub@mini@drinking@drinking_shots@ped_b@normal", "glass_hold")
    lib.showTextUI("[E] - Elengedés", { position = "right-center", icon = 'handcuffs' })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isDragging then
            if IsControlJustPressed(0, 38) then 
                local playerPed = PlayerPedId()
                TriggerServerEvent('policejob:dragStop', draggedPlayer)
                isDragging = false
                draggedPlayer = nil
                lib.hideTextUI()
                ClearPedSecondaryTask(playerPed)
            end
        end
    end
end)

local function stopDragging()
    local playerPed = PlayerPedId()
    Entity(playerPed).state:set('dragging', nil, true)
    lib.hideTextUI()
    ClearPedSecondaryTask(playerPed)
end

Citizen.CreateThread(function()
    while true do
        local draggingState = Entity(PlayerPedId()).state.dragging
        if draggingState then
            if IsControlJustPressed(0, 38) then 
                TriggerServerEvent('policejob:dragStop', draggingState)
                stopDragging()
            end
            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for i, v in ipairs(obj) do
            DeleteEntity(v)
            DeleteObject(v)
        end
        lib.hideTextUI()
    end
end)

RegisterCommand("clock", function ()
    clocked = not clocked
end)

RegisterCommand("Policemenu", function ()
    local job = ESX.PlayerData.job.name
    if IsInJob() and clocked then
        updateContextMenu()
        lib.showContext("f")
    end
end)

RegisterKeyMapping("Policemenu", "Rendőrségi menü", "keyboard", "F6")