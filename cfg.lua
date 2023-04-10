---@author Dezel

Config = {}
Config.CommandOpen = 'F6'
Config.ExpositionCoords = vec3(-38.624176, -1099.885742, 26.415405)
Config.Permissions = {
    ["BuyingCar"] = "novice",
    ["GarageAccess"] = "novice",
    ["EditCatalog"] = "experienced",
}
Config.Deliver = {
    Time = {5,10},
    Positions = {
        { coords = vector3(-8.149448, -1081.476929, 26.668091), heading = 121.0 },
        { coords = vector3(-10.879116, -1080.250488, 26.668091), heading = 121.0 },
        { coords = vector3(-13.991207, -1079.696655, 26.668091), heading = 121.0 }
    }
}
Config.Garage = {
    Coords = vector3(-16.338459, -1089.811035, 26.668091),
    Stored = {
        coords = vec3(-10.483513, -1097.261475, 26.668091),
        heading = 0.0
    }
}
Config.SpawnExpositionCar = {
    {
        tablet = vector3(-51.2242, -1087.6290, 26.2744),
        car = vector3(-49.8378, -1084.1207, 26.3023),
    },
    {
        tablet = vector3(-51.4571, -1094.7684, 26.2744),
        car = vector3(-54.4797, -1096.8159, 26.3023)
    },
    {
        tablet = vector3(-38.4802, -1100.0861, 26.2744),
        car = vector3(-42.2197, -1101.4570, 26.3023)
    },
    {
        tablet = vector3(-40.6849, -1094.7960, 26.2744),
        car = vector3(-37.2083, -1093.5328, 26.3023)
    }
}