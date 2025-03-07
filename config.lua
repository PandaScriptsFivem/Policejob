Config = {
    jobname = {
        "police",
        --"unemployed",
    },  
    tryCuffs = true, --Bilincseléskol minigame
    Blip = {
        coords = {370.0430, -1576.2585, 29.2919}, 
        color = 29, 
        sprite = 137, 
        scale = 0.789,
        label = "Rendör Fökapitányság"
    },
    boss = {
        coords = {364.5060, -1583.3218, 33.8258},
        label = "[E] - Főnöki Menü",
        grade = 4,
    },
    Clockin = {
        coords = {362.8510, -1590.3938, 29.2920},
        label = "[E] - Szolgálat felvétele"
    },
    Clothing = {
        coords = {368.1618, -1602.4203, 29.2921},
        textuilabel = "[E] - Szolgálati ruha",
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
        Coords = {371.5039, -1612.7756, 29.2921},
        label = "[E] - Jármüvek",
        DelCoords = {377.8198, -1630.4070, 28.2367},
        delLabel = "[E] - Jármü visszaadása",
        HeliDelCoords = {363.2061, -1598.2372, 37.3365},
        HelidelLabel = "[E] - Jármü visszaadása",
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
            {392.3918, -1628.5360, 29.2920, 50.1962},
            {395.2501, -1626.2037, 29.2920, 47.1237},
            {397.3145, -1624.0144, 29.2920, 47.1237},
            {399.3328, -1621.3234, 29.2920, 51.5933},
            {401.1773, -1619.0337, 29.2920, 51.5933},
            {403.0291, -1616.7347, 29.2920, 51.5933},
            {388.9037, -1612.8855, 29.2920, 232.0890},
            {390.5821, -1610.6948, 29.2920, 232.0890},
            {392.5816, -1608.0466, 29.2920, 232.0890},
            {385.0798, -1634.2410, 29.2920, 316.3173},
            {387.4838, -1636.4906, 29.2920, 321.6774},
            {370.6715, -1622.6929, 29.2921, 318.3419},
            {372.8760, -1624.7058, 29.2921, 318.3419}
        },
        helioutcoords = {
            {363.1382, -1598.3138, 36.9487, 320.3092},
        }
    }
}