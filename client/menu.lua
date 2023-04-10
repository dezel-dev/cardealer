---@author Dezel

local colour_index= {
    primary = {1,5},
    secondary = {1,5}
}
local payment_index = 1
local selectedPrimaryColor = {
    r = 0,
    g = 0,
    b = 0,
}
local selectedSecondaryColor = {
    r = 0,
    g = 0,
    b = 0,
}
local entity_vehicle
local vehicle_plate
local vehicle_properties

local selectedPrice = 0
local selectedVehicle

local selectedCar

local basic_price = 0
local min_price = 0
local max_price = 0

CarDealer.SetVehicleColor = function()
    SetVehicleCustomPrimaryColour(entity_vehicle, selectedPrimaryColor.r, selectedPrimaryColor.g, selectedPrimaryColor.b)
    SetVehicleCustomSecondaryColour(entity_vehicle, selectedSecondaryColor.r, selectedSecondaryColor.g, selectedSecondaryColor.b)
end

CarDealer.OpenMenu = function()
    local main = RageUI.CreateMenu("Concessionnaire", "Menu principal");
    local manage_vehicles = RageUI.CreateSubMenu(main, "Gestions véhicules", "Menu de gestion des véhicules");
    local catalog = RageUI.CreateSubMenu(main, "Catalogue", "Menu d'accès au catalogue");
    local stock = RageUI.CreateSubMenu(manage_vehicles, "Voir le stock", "Menu d'accès au stock");
    local give_keys = RageUI.CreateSubMenu(manage_vehicles, "Donner les clés", "Menu d'accès au don des clés");
    local history_buy = RageUI.CreateSubMenu(manage_vehicles, "Historique des achats", "Menu d'accès à l'historique des achats");
    local catalog_vehicle = RageUI.CreateSubMenu(catalog, "Catalogue", "Menu d'accès à la modification du catalogue");
    local catalog_buy = RageUI.CreateSubMenu(catalog, "Catalogue", "Menu d'accès à l'achat du véhicule");
    local manage_car = RageUI.CreateSubMenu(stock, "Stock", "Menu d'accès à la gestion du véhicule");
    local edit_catalog = RageUI.CreateSubMenu(catalog, "Catalogue", "Modification du catalogue");
    catalog.EnableMouse = true
    catalog.Closed = function()
        if DoesEntityExist(entity_vehicle) then
            DeleteEntity(entity_vehicle)
        end
    end
    edit_catalog.EnableMouse = true
    history_buy.WidthOffset = 125

    local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(PlayerPedId()), 5.0)
    for _, vehicle in pairs(vehicles) do
        DeleteEntity(vehicle)
    end


    RageUI.Visible(main, not RageUI.Visible(main))

    while main do

        Citizen.Wait(0)

        RageUI.IsVisible(main, function()
            RageUI.Button("Gestions des véhicules", nil, { RightBadge = RageUI.BadgeStyle.Car }, true, {}, manage_vehicles)
            RageUI.Button("Catalogue", nil, { RightBadge = RageUI.BadgeStyle.Tick }, CarDealer.Permissions["BuyingCar"][ESX.PlayerData.job.grade_name], {}, catalog)
        end)
        RageUI.IsVisible(manage_vehicles, function()
            RageUI.Button("Voir le stock", nil, { RightLabel = "→→→", LeftBadge = RageUI.BadgeStyle.Star}, CarDealer.Permissions["GarageAccess"][ESX.PlayerData.job.grade_name], {
                onSelected = function()
                    ESX.TriggerServerCallback("CarDealer:GetStock", function(vehicles)
                        CarDealer.Stock = vehicles
                    end)
                end
            }, stock)
            RageUI.Line()
            RageUI.Button("Historique des achats", nil, { RightLabel = "→→→", LeftBadge = RageUI.BadgeStyle.Star}, true, {
                onSelected = function()
                    ESX.TriggerServerCallback("CarDealer:RequestHistory", function(history)
                        CarDealer.History = history
                    end)
                end
            }, history_buy)
        end)

        RageUI.IsVisible(catalog, function()
            RageUI.Button("Modifier le catalogue", nil, { RightBadge = RageUI.BadgeStyle.Tick}, CarDealer.Permissions["EditCatalog"][ESX.PlayerData.job.grade_name], {}, edit_catalog)
            RageUI.Button("Rechercher un modèle", nil, { RightLabel = "→→→", LeftBadge = RageUI.BadgeStyle.Star}, true, {
                onSelected = function()
                    local model = CarDealer.Keyboard("Modèle", nil, 15)
                    if (model) then
                        ESX.Game.SpawnLocalVehicle(model, Config.ExpositionCoords, 0.0, function(entity)
                            SetEntityVisible(entity, false, false)
                            SetVehicleDoorsLocked(entity, 2)
                            entity_vehicle = entity
                            vehicle_plate = GetVehicleNumberPlateText(entity_vehicle)
                            vehicle_properties = ESX.Game.GetVehicleProperties(entity_vehicle)
                        end)
                        for _,v in pairs(CarDealer.CategoriesList) do
                            for _,v2 in pairs(v.vehicles) do
                                if (v2.model == model) then
                                    selectedPrice = v2.price
                                    selectedVehicle = v2
                                end
                            end
                        end
                        RageUI.Visible(catalog_buy, true)
                    end
                end
            })
            RageUI.Line()
            for _,v in pairs(CarDealer.CategoriesList) do
                RageUI.List(v.label, v.vehicles, v.index, ("Prix du véhicule : ~g~%s$"):format(selectedPrice), {}, true, {
                    onListChange = function(Index, Value)
                        v.index = Index
                        ESX.Game.DeleteVehicle(entity_vehicle)
                        Wait(200)
                        ESX.Game.SpawnLocalVehicle(Value.model, Config.ExpositionCoords, 0.0, function(entity)
                            SetEntityAlpha(entity, 255, false)
                            SetVehicleDoorsLocked(entity, 2)
                            entity_vehicle = entity
                            vehicle_plate = GetVehicleNumberPlateText(entity_vehicle)
                        end)
                    end,
                    onActive = function( Value)
                        selectedPrice = Value.price
                        selectedVehicle = Value
                    end,
                    onSelected = function()
                        if (not vehicle_plate or not selectedVehicle) then
                            return ESX.ShowNotification("~r~Veuillez sélectionner un véhicule")
                        end
                        vehicle_properties = ESX.Game.GetVehicleProperties(entity_vehicle)
                        RageUI.Visible(catalog_buy, true)
                    end
                })
            end
        end, function()
            RageUI.ColourPanel("Couleur primaire", RageUI.PanelColour.HairCut, colour_index.primary[1], colour_index.primary[2], {
                onColorChange = function(MinimumIndex, CurrentIndex)
                    colour_index.primary[1] = MinimumIndex
                    colour_index.primary[2] = CurrentIndex

                    selectedPrimaryColor.r = RageUI.PanelColour.HairCut[CurrentIndex][1]
                    selectedPrimaryColor.g = RageUI.PanelColour.HairCut[CurrentIndex][2]
                    selectedPrimaryColor.b = RageUI.PanelColour.HairCut[CurrentIndex][3]
                    CarDealer.SetVehicleColor()
                end
            }, 3, {})
            RageUI.ColourPanel("Couleur secondaire", RageUI.PanelColour.HairCut, colour_index.secondary[1], colour_index.secondary[2], {
                onColorChange = function(MinimumIndex, CurrentIndex)
                    colour_index.secondary[1] = MinimumIndex
                    colour_index.secondary[2] = CurrentIndex

                    selectedSecondaryColor.r = RageUI.PanelColour.HairCut[CurrentIndex][1]
                    selectedSecondaryColor.g = RageUI.PanelColour.HairCut[CurrentIndex][2]
                    selectedSecondaryColor.b = RageUI.PanelColour.HairCut[CurrentIndex][3]
                    CarDealer.SetVehicleColor()
                end
            }, 3, {})
        end)

        RageUI.IsVisible(catalog_buy, function()
            RageUI.Separator("Nom du véhicule : ~y~"..selectedVehicle.Name)
            RageUI.Separator("Prix du véhicule : ~g~"..selectedVehicle.price.."$")
            RageUI.Line()
            RageUI.List("Moyen de paiment:", {"~g~Espèces~s~", "~b~Banque~s~"}, payment_index, nil, {}, true, {
                onListChange = function(Index, Value)
                    payment_index = Index
                end,
            })
            RageUI.Button("Acheter", nil, {Color = {BackgroundColor={50, 168, 82, 255}}, RightBadge = RageUI.BadgeStyle.Tick}, true, {
                onSelected = function()
                    TriggerServerEvent(("CarDealer:BuyVehicle:%s"):format(payment_index == 1 and "liquid" or "bank"), selectedVehicle, vehicle_plate, vehicle_properties)
                end
            })
            RageUI.Button("Changer le prix", nil, { RightLabel = "→→→", LeftBadge = RageUI.BadgeStyle.Star}, CarDealer.Permissions["EditCatalog"][ESX.PlayerData.job.grade_name], {
                onSelected = function()
                    local price = CarDealer.Keyboard("Nouveau prix", nil, 15)
                    if (tonumber(price)) then
                        price = tonumber(price)
                        basic_price = selectedPrice
                        min_price = basic_price/1.25
                        max_price = basic_price*1.25
                        if (price < min_price or price > max_price) then
                            return ESX.ShowNotification("~r~Le prix doit être compris entre "..min_price.."$ et "..max_price.."$")
                        end
                        selectedVehicle.price = price
                        TriggerServerEvent("CarDealer:EditCatalog", selectedVehicle.Name, selectedVehicle.model, price)
                    end
                end
            })
        end)

        RageUI.IsVisible(stock, function()
            for _,v in pairs(CarDealer.Stock) do
                RageUI.Button(("[~y~%s~s~] %s"):format(v.label, v.plate), ("Statut : %s"):format(not v.isDelivered and "~b~Livré" or ("~r~En livraison : %s minutes"):format(v.deliveryTime)), { RightBadge = RageUI.BadgeStyle.Car }, true, {
                    onSelected = function()
                        selectedCar = v
                        RageUI.Visible(manage_car, true)
                    end
                })
            end
        end)
        RageUI.IsVisible(edit_catalog, function()
            for _,v in pairs(CarDealer.CategoriesList) do
                RageUI.List(v.label, v.vehicles, v.index, ("Prix du véhicule : ~g~%s$"):format(selectedPrice), {}, true, {
                    onListChange = function(Index, Value)
                        v.index = Index
                    end,
                    onActive = function( Value)
                        selectedPrice = Value.price
                        basic_price = selectedPrice
                        min_price = basic_price/1.25
                        max_price = basic_price*1.25
                    end,
                    onSelected = function()
                        local new_price = CarDealer.Keyboard("Nouveau prix", "", 10)
                        if (new_price == nil) then
                            return
                        end
                        if (tonumber(new_price) == nil) then
                            return ESX.ShowNotification("~r~Le prix doit être un nombre")
                        end
                        if (tonumber(new_price) < min_price or tonumber(new_price) > max_price) then
                            return ESX.ShowNotification("~r~Le prix doit être compris entre "..min_price.."$ et "..max_price.."$")
                        end
                        TriggerServerEvent("CarDealer:EditCatalog", v.label, v.vehicles[v.index].model, new_price)
                    end
                })
            end
        end)
        RageUI.IsVisible(manage_car, function()
            RageUI.Button("Donner les clés", nil, { RightLabel = "→→→"}, true, {
                onActive = function()
                    local target, distance = ESX.Game.GetClosestPlayer()
                    if (distance < 3.0) then
                        local pos = GetEntityCoords(GetPlayerPed(target))
                        DrawMarker(2, pos.x, pos.y, pos.z+1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 255, false, false, 2, false, nil, nil, false)
                    end
                end,
                onSelected = function()
                    local target, distance = ESX.Game.GetClosestPlayer()
                    if (not target) or (distance > 3.0) then
                        return ESX.ShowNotification("~r~Aucun joueur à proximité")
                    end
                    if (target == 0) then return end
                    TriggerServerEvent("CarDealer:GiveKeys", GetPlayerServerId(target), selectedCar.plate)
                end
            })
            RageUI.Button("Modifier la plaque", nil, { RightLabel = "→→→"}, true, {
                onSelected = function()
                    local new_plate = CarDealer.Keyboard("Plaque", nil, 8)
                    if (new_plate) then
                        for _,v in pairs(CarDealer.Stock) do
                            if (v.plate == new_plate) then
                                return ESX.ShowNotification("~r~Cette plaque est déjà utilisée")
                            end
                        end
                        TriggerServerEvent("CarDealer:ChangePlate", selectedCar.plate, new_plate)
                    end
                end
            })
        end)
        RageUI.IsVisible(history_buy, function()
            for _,v in pairs(CarDealer.History) do
                RageUI.Button("["..v.date.."] "..v.label.." (~b~"..v.seller.."~s~)", nil, { RightLabel = ("~r~-%s$"):format(v.price)}, true, {})
            end
        end)

        if not RageUI.Visible(main) and not RageUI.Visible(edit_catalog) and not RageUI.Visible(manage_car) and not RageUI.Visible(catalog_buy)  and not RageUI.Visible(history_buy) and not RageUI.Visible(stock) and not RageUI.Visible(give_keys) and not RageUI.Visible(manage_vehicles) and not RageUI.Visible(catalog) then
            main = RMenu:DeleteType('main', true)
            manage_vehicles = RMenu:DeleteType('manage_vehicles', true)
            catalog = RMenu:DeleteType('catalog', true)
            stock = RMenu:DeleteType('stock', true)
            give_keys = RMenu:DeleteType('give_keys', true)
            history_buy = RMenu:DeleteType('history_buy', true)
            catalog_vehicle = RMenu:DeleteType('catalog_vehicle', true)
            catalog_buy = RMenu:DeleteType('catalog_buy', true)
            manage_car = RMenu:DeleteType('manage_car', true)
            edit_catalog = RMenu:DeleteType('edit_catalog', true)
        end
    end
end