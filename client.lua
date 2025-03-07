local ispolice = false
local clocked = false
local locthet = false
local handcuffed = false
local isDragging = false
local draggedPlayer = nil
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
    local x, y, z = table.unpack(Config.Blip.coords)
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipScale(blip, Config.Blip.scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.label)
    EndTextCommandSetBlipName(blip)
    SetBlipAsShortRange(blip, true)
end)

local function clocking()
    if not clocked then
        options = {
            {
                title = "Szolgálat felvétele",
                description = "Minden rendőr fel kell vagye a szolgálatot mielött elkezdi a munkáját!",
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
                        description = "Szolgálat felvéve!",
                        type = "success"
                    })
                end
            }
        }
    else
        options = {
            {
                title = "Szolgálat leadása",
                description = "Ha úgy gondolod hogy elegett tettél akkor le tudod adni a szolgálatot!!",
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
                    title = "Ruha választás",
                    options = {
                        {
                            title = "Ruhaváltás",
                            description = "Szolgálati ruha levétele!",
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
                    title = "Ruha választás",
                    options = {
                        {
                            title = "Ruhaváltás",
                            description = "Szolgálati ruha felvétele!",
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
    lib.showTextUI(Config.Clothing.label, {
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
            lib.showTextUI(Config.Clockin.label, {
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
        print("Érvénytelen jármű modell: " .. model)
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
    onEnter = function ()
        if clocked then
            lib.showTextUI(Config.Vehicles.label, {
                position = "right-center",
                icon = 'car',
            })
        end
    end,
    onExit = function ()
        lib.hideTextUI()
    end,
    nearby = function ()
        if clocked then
            if IsControlJustReleased(0, 38) then
                local helicopterOptionsAvailable = #Config.Vehicles.helicopters > 0
                local helicopterColor = helicopterOptionsAvailable and "#34ed66" or "#ff0000"
                local carOptionsAvailable = #Config.Vehicles.vehicle > 0
                local carColor = carOptionsAvailable and "#34ed66" or "#ff0000"
                lib.registerContext({
                    id = "pd",
                    title = "Rendőrség",
                    options = {
                        {
                            title = "Jármüvek",
                            arrow = true,
                            description = carOptionsAvailable and "Válassz egy jármüvet!" or "Nincsen elérhető Jármüvek!",
                            icon = "car",
                            iconColor = carColor,
                            disabled = not carOptionsAvailable,
                            onSelect = function ()
                                if carOptionsAvailable then
                                    local playerGrade =  ESX.PlayerData.job.grade
                                    local options = {}

                                    table.insert(options, {
                                        title = "Vissza",
                                        icon = "arrow-left",
                                        iconColor = "#ffffff",
                                        onSelect = function()
                                            lib.showContext('pd')
                                        end
                                    })

                                    for _, vehicleData in ipairs(Config.Vehicles.vehicle) do
                                        local isAvailable = vehicleData.grade <= playerGrade 
                                        local iconColor = isAvailable and "#34ed66" or "#ff0000" 

                                        table.insert(options, {
                                            title = vehicleData.label,
                                            description = isAvailable and "Vegyél ki egy " .. vehicleData.label .. " járművet!" or "Nincs jogosultságod ehhez a járműhöz!",
                                            icon = "car",
                                            iconColor = iconColor,
                                            disabled = not isAvailable,
                                            onSelect = isAvailable and function()
                                                local coords, heading = getFreeOutCoords()
                                                if coords then
                                                    spawnVehicle(vehicleData.model, coords, heading)
                                                    lib.notify({description = vehicleData.label .. " kivéve!", type = "success" })
                                                else
                                                    lib.notify({description = "Nincs szabad parkolóhely!", type = "error" })
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
                            end
                        },
                        {
                            title = "Helikopterek",
                            arrow = true,
                            description = helicopterOptionsAvailable and "Válassz egy helikoptert!" or "Nincs elérhető helikopter!",
                            icon = "helicopter",
                            iconColor = helicopterColor,
                            disabled = not helicopterOptionsAvailable,
                            onSelect = function ()
                                local options = {}
                                local playerGrade =  ESX.PlayerData.job.grade
                                table.insert(options, {
                                    title = "Vissza",
                                    icon = "arrow-left",
                                    iconColor = "#ffffff",
                                    onSelect = function()
                                        lib.showContext('pd')
                                    end
                                })
                                for _, helicopterData in ipairs(Config.Vehicles.helicopters) do
                                    local isAvailable = helicopterData.grade <= playerGrade
                                    local iconColor = isAvailable and "#34ed66" or "#ff0000"
                            
                                    table.insert(options, {
                                        title = helicopterData.label,
                                        description = isAvailable and "Vegyél ki egy " .. helicopterData.label .. " helikoptert!" or "Nincs jogosultságod ehhez a helikopterhez!",
                                        icon = "helicopter",
                                        iconColor = iconColor,
                                        disabled = not isAvailable,
                                        onSelect = isAvailable and function()
                                            local coords, heading = getFreeheliOutCoords()
                                            if coords then
                                                spawnVehicle(helicopterData.model, coords, heading)
                                                lib.notify({description = helicopterData.label .. " kivéve!", type = "success" })
                                            else
                                                lib.notify({description = "Nincs szabad parkolóhely!", type = "error" })
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
                        }
                    }
                })
                lib.showContext('pd')

            end
        end
    end
})

lib.points.new({
    coords = Config.Vehicles.DelCoords,
    distance = 5,
    onEnter = function()
        local playerPed = PlayerPedId()
        if clocked and IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local vehicleModel = GetEntityModel(vehicle)
            local isAllowedVehicle = false

            for _, v in ipairs(Config.Vehicles.vehicle) do
                if GetHashKey(v.model) == vehicleModel then
                    isAllowedVehicle = true
                    break
                end
            end

            if not isAllowedVehicle then
                for _, v in ipairs(Config.Vehicles.helicopters) do
                    if GetHashKey(v.model) == vehicleModel then
                        isAllowedVehicle = true
                        break
                    end
                end
            end

            if isAllowedVehicle then
                lib.showTextUI(Config.Vehicles.delLabel, {
                    position = "right-center",
                    icon = 'car',
                })
            end
        end
    end,
    onExit = function()
        lib.hideTextUI()
    end,
    nearby = function()
        local playerPed = PlayerPedId()
        if clocked and IsPedInAnyVehicle(playerPed, false) then
            if IsControlJustReleased(0, 38) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                local vehicleModel = GetEntityModel(vehicle)
                local isAllowedVehicle = false

                for _, v in ipairs(Config.Vehicles.vehicle) do
                    if GetHashKey(v.model) == vehicleModel then
                        isAllowedVehicle = true
                        break
                    end
                end

                if not isAllowedVehicle then
                    for _, v in ipairs(Config.Vehicles.helicopters) do
                        if GetHashKey(v.model) == vehicleModel then
                            isAllowedVehicle = true
                            break
                        end
                    end
                end

                if isAllowedVehicle then
                    TaskLeaveVehicle(playerPed, vehicle, 0) 
                    Wait(1000)
                    ESX.Game.DeleteVehicle(vehicle)
                    lib.notify({ description = "Jármű visszaadva!", type = "success" })
                    lib.hideTextUI()
                else
                    lib.notify({ description = "Ez a jármű nem adható vissza itt!", type = "error" })
                end
            end
        end
    end
})

lib.points.new({
    coords = Config.Vehicles.HeliDelCoords,
    distance = 8,
    onEnter = function()
        local playerPed = PlayerPedId()
        if clocked and IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local vehicleModel = GetEntityModel(vehicle)
            local isAllowedVehicle = false

            for _, v in ipairs(Config.Vehicles.vehicle) do
                if GetHashKey(v.model) == vehicleModel then
                    isAllowedVehicle = true
                    break
                end
            end

            if not isAllowedVehicle then
                for _, v in ipairs(Config.Vehicles.helicopters) do
                    if GetHashKey(v.model) == vehicleModel then
                        isAllowedVehicle = true
                        break
                    end
                end
            end

            if isAllowedVehicle then
                lib.showTextUI(Config.Vehicles.HelidelLabel, {
                    position = "right-center",
                    icon = 'car',
                })
            end
        end
    end,
    onExit = function()
        lib.hideTextUI()
    end,
    nearby = function()
        local playerPed = PlayerPedId()
        if clocked and IsPedInAnyVehicle(playerPed, false) then
            if IsControlJustReleased(0, 38) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                local vehicleModel = GetEntityModel(vehicle)
                local isAllowedVehicle = false

                for _, v in ipairs(Config.Vehicles.vehicle) do
                    if GetHashKey(v.model) == vehicleModel then
                        isAllowedVehicle = true
                        break
                    end
                end

                if not isAllowedVehicle then
                    for _, v in ipairs(Config.Vehicles.helicopters) do
                        if GetHashKey(v.model) == vehicleModel then
                            isAllowedVehicle = true
                            break
                        end
                    end
                end

                if isAllowedVehicle then
                    TaskLeaveVehicle(playerPed, vehicle, 0) 
                    Wait(2000)
                    ESX.Game.DeleteVehicle(vehicle)
                    lib.notify({ description = "Jármű visszaadva!", type = "success" })
                    lib.hideTextUI()
                else
                    lib.notify({ description = "Ez a jármű nem adható vissza itt!", type = "error" })
                end
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
            lib.showTextUI(Config.boss.label, {
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

local function updateContextMenu()
    local player, distance = ESX.Game.GetClosestPlayer()
    local isPlayerNear = distance ~= -1 and distance <= 3.0
    local closestVehicle = lib.getClosestVehicle(GetEntityCoords(PlayerPedId()), 3.0, true)

    lib.registerContext({
        id = "f",
        title = "Rendőrség",
        options = {
            {
                title = "Ember Interackiók",
                icon = "handshake",
                onSelect = function()
                    local player, distance = ESX.Game.GetClosestPlayer()
                    local isPlayerNear = distance ~= -1 and distance <= 3.0
                    local closestVehicle = lib.getClosestVehicle(GetEntityCoords(PlayerPedId()), 3.0, true)
                    lib.registerContext({
                        id = "ember",
                        title = "Ember Interackiók",
                        menu = "f",
                        options = {
                            {
                                title = "Személyi ellenőrzés",
                                icon = "id-card",
                                onSelect = function()
                                    if isPlayerNear then
                                        lib.callback('policejob:checkid', false, function(data)
                                            if data then
                                                lib.registerContext({
                                                    id = "idcard",
                                                    title = "Személyi ellenőrzés",
                                                    menu = "ember",
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
                                        end, GetPlayerServerId(player))
                                    else
                                        lib.notify({
                                            description = "Nincs játékos a közeledben!",
                                            type = "warning"
                                        })
                                    end
                                end,
                                iconColor = isPlayerNear and "#34ed66" or "#ff0000" 
                            },
                            {
                                title = "Átkutatás",
                                icon = "search",
                                onSelect = function()
                                    if isPlayerNear then
                                        exports.ox_inventory:openNearbyInventory()
                                    else
                                        lib.notify({
                                            description = "Nincs játékos a közeledben!",
                                            type = "warning"
                                        })
                                    end
                                end,
                                iconColor = isPlayerNear and "#34ed66" or "#ff0000"
                            },
                            {
                                title = "Bilincselés",
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
                                            description = "Nincs játékos a közeledben!",
                                            type = "warning"
                                        })
                                    end
                                end,
                                iconColor = isPlayerNear and "#34ed66" or "#ff0000"
                            },
                            {
                                title = "Kisérés",
                                icon = "person-walking",
                                onSelect = function()
                                    if isPlayerNear then
                                        TriggerServerEvent('policejob:drag', GetPlayerServerId(player))
                                    else
                                        lib.notify({
                                            description = "Nincs játékos a közeledben!",
                                            type = "warning"
                                        })
                                    end
                                end,
                                iconColor = isPlayerNear and "#34ed66" or "#ff0000"
                            },
                            {
                                title = "járműböl kivétel/betétel",
                                icon = "car-side",
                                onSelect = function()
                                    if closestVehicle and isPlayerNear then
                                        TriggerServerEvent('policejob:getin', GetPlayerServerId(player))
                                    elseif isPlayerNear then
                                        lib.notify({
                                            description = "Nincs jármű a közeledben!",
                                            type = "warning"
                                        })
                                    elseif closestVehicle then
                                        lib.notify({
                                            description = "Nincs játékos a közeledben!",
                                            type = "warning"
                                        })
                                    else
                                        lib.notify({
                                            description = "Nincs játékos és jármű a közeledben!",
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
                title = "Jármü Interackiók",
                icon = "car",
                onSelect = function()
                    local player, distance = ESX.Game.GetClosestPlayer()
                    local isPlayerNear = distance ~= -1 and distance <= 3.0
                    local closestVehicle = lib.getClosestVehicle(GetEntityCoords(PlayerPedId()), 3.0, true)
                    lib.registerContext({
                        id = "kocsi",
                        title = "Jármü Interackiók",
                        menu = "f",
                        options = {
                            {
                                title = "Jármü lefoglalása",
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
                                            description = "Nincs jármű a közeledben!",
                                            type = "warning"
                                        })
                                    end
                                end
                            },
                        }
                    })
                    lib.showContext("kocsi")
                end
            }
        }
    })
end

RegisterNetEvent('policejob:getin')
AddEventHandler('policejob:getin', function()
    local playerPed = PlayerPedId()
    local closestVehicle = lib.getClosestVehicle(GetEntityCoords(playerPed), 3.0, true)

    if closestVehicle then
        if IsPedInAnyVehicle(playerPed, false) then
            TaskLeaveVehicle(playerPed, closestVehicle, 0)
        else
            local seats = { -1, 0, 1, 2 }
            local freeSeat = nil

            for _, seat in ipairs(seats) do
                if IsVehicleSeatFree(closestVehicle, seat) and seat ~= -1 then
                    freeSeat = seat
                    break
                end
            end

            if freeSeat then
                TaskEnterVehicle(playerPed, closestVehicle, -1, freeSeat, 1.0, 1, 0)
            end
        end
    end
end)

RegisterNetEvent('policejob:handcufftry')
AddEventHandler('policejob:handcufftry', function(target, police)
    local playerPed = PlayerPedId() 
    local targetPed = GetPlayerPed(GetPlayerFromServerId(target)) 
    local policePed = GetPlayerPed(GetPlayerFromServerId(police)) 
    if targetPed ~= policePed then
        if clocked then  
            RequestAnimDict("mp_arrest_paired")
            while not HasAnimDictLoaded("mp_arrest_paired") do
                Wait(10)
            end
            TaskPlayAnim(playerPed, "mp_arrest_paired", "cop_p2_back_right", 8.0, -8.0, -1, 3, 0, false, false, false)
            Wait(3500)
            ClearPedTasks(playerPed)
        end
    end
    if targetPed == playerPed then
        if not handcuffed then
            RequestAnimDict("mp_arrest_paired")
            while not HasAnimDictLoaded("mp_arrest_paired") do
                Wait(10)
            end
            TaskPlayAnim(targetPed, "mp_arrest_paired", "crook_p2_back_right", 8.0, -8.0, -1, 3, 0, false, false, false)
            RemoveAnimDict('mp_arrest_paired')
            Wait(3500)
            ClearPedTasks(playerPed)
        end
    end
end)

RegisterNetEvent('policejob:handcuff')
AddEventHandler('policejob:handcuff', function(target)
    local playerPed = PlayerPedId() 
    local targetPed = GetPlayerPed(GetPlayerFromServerId(target)) 
    if targetPed == playerPed then
        if not handcuffed then
            RequestAnimDict("mp_arresting")
            while not HasAnimDictLoaded("mp_arresting") do
                Wait(10)
            end
            TaskPlayAnim(playerPed, "mp_arresting", "idle", 8.0, -8.0, -1, 49, 0, false, false, false)
            RemoveAnimDict('mp_arresting')
            SetEnableHandcuffs(playerPed, true)
            DisablePlayerFiring(playerPed, true)
            SetPedCanPlayGestureAnims(playerPed, false)
            handcuffed = true

            CreateThread(function()
                while handcuffed do
                    Wait(0)
                    DisableControlAction(0, 22, true)
                    DisableControlAction(0, 23, true)
                    DisableControlAction(0, 24, true)
                    DisableControlAction(0, 25, true) 
                    DisableControlAction(0, 36, true) 
                    DisableControlAction(0, 45, true) 
                    DisableControlAction(0, 49, true)
                    DisableControlAction(0, 75, true)
                    DisableControlAction(0, 59, true)
                    DisableControlAction(0, 63, true) 
                    DisableControlAction(0, 64, true) 
                    DisableControlAction(0, 140, true) 
                    DisableControlAction(0, 141, true)
                    if not IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 49) and handcuffed then
                        RequestAnimDict("mp_arresting")
                        while not HasAnimDictLoaded("mp_arresting") do
                            Wait(10)
                        end
                        TaskPlayAnim(playerPed, "mp_arresting", "idle", 8.0, -8.0, -1, 49, 0, false, false, false)
                        RemoveAnimDict('mp_arresting')
                    end
                end
            end)
        else
            ClearPedTasks(playerPed)
            ClearPedTasksImmediately(playerPed)
            ClearPedSecondaryTask(playerPed)
            SetEnableHandcuffs(playerPed, false)
            DisablePlayerFiring(playerPed, false)
            SetPedCanPlayGestureAnims(playerPed, true)
            FreezeEntityPosition(playerPed, false)
            handcuffed = false
        end
    end
end)

RegisterNetEvent('policejob:drag')
AddEventHandler('policejob:drag', function(copSource)
    local playerPed = PlayerPedId() 
    local copPed = GetPlayerPed(GetPlayerFromServerId(copSource)) 

    if DoesEntityExist(copPed) then
        AttachEntityToEntity(
            playerPed, copPed, 11816, -0.16, 0.55, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true
        )

        SetEntityCollision(playerPed, false, false)
        SetEntityInvincible(playerPed, true)
        SetPedCanBeTargetted(playerPed, false)
    end
end)

RegisterNetEvent('policejob:dragStop')
AddEventHandler('policejob:dragStop', function()
    local playerPed = PlayerPedId()
    ClearPedSecondaryTask(playerPed)
    DetachEntity(playerPed, true, true)
    SetEntityCollision(playerPed, true, true)
    SetEntityInvincible(playerPed, false)
    SetPedCanBeTargetted(playerPed, true)
    if handcuffed then
        RequestAnimDict("mp_arresting")
        while not HasAnimDictLoaded("mp_arresting") do
            Wait(10)
        end
        TaskPlayAnim(playerPed, "mp_arresting", "idle", 8.0, -8.0, -1, 49, 0, false, false, false)
        RemoveAnimDict('mp_arresting')
    end

end)

RegisterNetEvent('policejob:dragStart')
AddEventHandler('policejob:dragStart', function(target)
    local playerPed = PlayerPedId()
    isDragging = true
    draggedPlayer = target
    if DoesEntityExist(playerPed) then
        RequestAnimDict("anim@amb@nightclub@mini@drinking@drinking_shots@ped_b@normal")
        while not HasAnimDictLoaded("anim@amb@nightclub@mini@drinking@drinking_shots@ped_b@normal") do
            Wait(10)
        end
        TaskPlayAnim(playerPed, "anim@amb@nightclub@mini@drinking@drinking_shots@ped_b@normal", "glass_hold", 8.0, -8.0, -1, 49, 0, false, false, false)
        RemoveAnimDict('anim@amb@nightclub@mini@drinking@drinking_shots@ped_b@normal')
    end
    lib.showTextUI("[E] - Elengedés", {
        position = "right-center",
        icon = 'handcuffs',
    })
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

RegisterCommand("Policemenu", function ()
    local job = ESX.PlayerData.job.name
    if IsInJob() and clocked then
        updateContextMenu()
        lib.showContext("f")
    end
end)

RegisterKeyMapping("Policemenu", "Rendőrségi menü", "keyboard", "F6")