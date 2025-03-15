Config = {
    jobname = {
        "police",
        --"unemployed",
    },  
    tryCuffs = true, --Bilincseléskol minigame
    Blip = {
        coords = vector3(370.0430, -1576.2585, 29.2919), 
        color = 29, 
        sprite = 137, 
        scale = 0.789,
    },
    boss = {
        coords = vector3(364.5060, -1583.3218, 33.8258),
        grade = 4,
    },
    Clockin = {
        coords = vector3(362.8510, -1590.3938, 29.2920),
    },
    Clothing = {
        coords = vector3(368.1618, -1602.4203, 29.2921),
        male = {
            ['torso_1'] = 55, 
            ['torso_2'] = 0,   
            ['tshirt_1'] = 15,
            ['tshirt_2'] = 0,  
            ['arms'] = 19,    
            ['pants_1'] = 35, 
            ['pants_2'] = 0, 
            ['shoes_1'] = 25, 
            ['shoes_2'] = 0    
        },
        female = {
            ['torso_1'] = 48, 
            ['torso_2'] = 0,   
            ['tshirt_1'] = 14,
            ['tshirt_2'] = 0, 
            ['arms'] = 14,     
            ['pants_1'] = 34,  
            ['pants_2'] = 0, 
            ['shoes_1'] = 27,  
            ['shoes_2'] = 0   
        }
    },
    Vehicles = {
        Coords = vector3(371.5039, -1612.7756, 29.2921),
        DelCoords = vector3(377.8198, -1630.4070, 28.2367),
        HeliDelCoords = vector3(363.2061, -1598.2372, 37.3365),
        vehicle = {
            {label = "Rendőr Autó", model = "police", grade = 0},
            {label = "Rendőr Motor", model = "policeb", grade = 1},
            {label = "Rendőr SUV", model = "police2", grade = 2},
            {label = "Rendőr Kamion", model = "policet", grade = 3}
        },
        helicopters = {
            {label = "Rendör Helikopter", model = "polmav", grade = 4}
        },
        outcoords = {
            vector4(392.3918, -1628.5360, 29.2920, 50.1962),
            vector4(395.2501, -1626.2037, 29.2920, 47.1237),
            vector4(397.3145, -1624.0144, 29.2920, 47.1237),
            vector4(399.3328, -1621.3234, 29.2920, 51.5933),
            vector4(401.1773, -1619.0337, 29.2920, 51.5933),
            vector4(403.0291, -1616.7347, 29.2920, 51.5933),
            vector4(388.9037, -1612.8855, 29.2920, 232.0890),
            vector4(390.5821, -1610.6948, 29.2920, 232.0890),
            vector4(392.5816, -1608.0466, 29.2920, 232.0890),
            vector4(385.0798, -1634.2410, 29.2920, 316.3173),
            vector4(387.4838, -1636.4906, 29.2920, 321.6774),
            vector4(370.6715, -1622.6929, 29.2921, 318.3419),
            vector4(372.8760, -1624.7058, 29.2921, 318.3419)
        },
        helioutcoords = {
            vector4(363.1382, -1598.3138, 36.9487, 320.3092),
        }
    },
    Locale = {
        Prop_Rotate = "[Q]    - Felfele  \n" ..
                     "[E]    - Lefele  \n" ..
                     "[NYILAK] - Mozgatás  \n" ..
                     "[GÖRGŐ] - Forgatás  \n" ..
                     "[ENTER]  - Letétel  \n",
        Prop_Delete = "[E] - Eltávolítás",

        Helicopter_Del = "[E] - Jármü visszaadása",

        Vehicle_Del = "[E] - Jármü visszaadása",
        Vehicle_Get = "[E] - Jármüvek",
        Vehicle_Take = "Vegyél ki egy ",
        Vehicle_TakeOut = " kivéve!",
        Vehicle_NoParking = "Nincs szabad parkolóhely!",
        Vehicle_NoPermission = "Nincs jogosultságod ehhez a járműhöz!",

        Clockin = "[E] - Szolgálat felvétele",
        Clockin_Title = "Szolgálat felvétele",
        Clockin_Desc = "Minden rendőr fel kell vagye a szolgálatot mielött elkezdi a munkáját!",
        Clockin_Notify = "Szolgálat felvéve!",

        ClockOut = "",
        ClockOut_Title = "Szolgálat leadása",
        ClockOut_Desc = "Ha úgy gondolod hogy elegett tettél akkor le tudod adni a szolgálatot!!",
        ClockOut_Notify = "Szolgálat leadva!",

        BossMenu = "[E] - Főnöki Menü",
        BlipName = "Rendör Fökapitányság",

        Clothing = "[E] - Szolgálati ruha",
        Clothing_Title = "Ruha választás",
        Clothing_Desc = "Szolgálati ruha felvétele!",

        unClothing_Desc = "Szolgálati ruha levétele!",
        
        Back = "Vissza",
        
        Copy = "Kattints a vágólapra másoláshoz!",
        Copy_Notify = "kimásolva a vágólapra!",

        Menu_Peaple = "Ember Interackiók",
        Menu_vehicle = "Jármü Interackiók",
        Menu_Object = "Objektum Lerakása",
        Menu_checkID = "Személyi ellenőrzés",
        
        No_Player_Nearby = "Nincs játékos a közeledben!",
        No_Vehicle_Nearby = "Nincs jármű a közeledben!",
        No_Vehicle_and_Player_Nearby = "Nincs játékos és jármű a közeledben!",

        ID_Name = "Név: ",
        ID_Job = "Munka: ",
        ID_Gender = "Nem: ",
        ID_Gender_Male = "Férfi",
        ID_Gender_Female = "Nő",
        ID_DOB = "Születési dátum: ",
        ID_Height = "Magasság: ",

        VehicleMenu_Inpound = "Jármü lefoglalása",
        VehicleMenu_Info = "Jármü Információk",
        Vehicle_Menu_Lockpick = "Jármü Zár feltörése",

        Vehicle_Not_lock = "A jármü nincsen lezárva!",
        Vehicle_Unlocked = "Sikeresen kinyitottad a jármüvet",

        Object_Barrier = "Útzár",
        Object_RoadCone = "Bólya",
        Object_SpikeStrip = "szögesdrót",

        Search = "Átkutatás",
        HandCuff = "Bilincselés",
        Escort = "Kisérés",
        Put_Out_car = "járműböl kivétel/betétel",
    }
}