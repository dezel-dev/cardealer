---@author Dezel

Citizen.CreateThread(function()
    while (true) do
        local interval = 1000
        local dst = #(GetEntityCoords(PlayerPedId()) - Config.Garage.Coords)
        if (dst <= 10.0) then
            interval = 0
            DrawMarker(36, Config.Garage.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 255, false, false, 2, false, nil, nil, false)
            if (dst <= 2.0) then
                if (IsPedInAnyVehicle(PlayerPedId(), false)) then
                    ESX.ShowHelpNotification("Appuyez sur  ~INPUT_CONTEXT~ pour ranger le véhicule")
                    if (IsControlJustPressed(0,51)) then
                        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                        TriggerServerEvent("CarDealer:RentVehicle", GetVehicleNumberPlateText(vehicle))
                        ESX.Game.DeleteVehicle(vehicle)
                    end
                else
                    ESX.ShowHelpNotification("Appuyez sur  ~INPUT_CONTEXT~ pour ouvrir le garage")
                    if (IsControlJustPressed(0,51)) then
                        if (not CarDealer.Permissions["GarageAccess"][ESX.PlayerData.job.grade_name]) then
                            ESX.ShowNotification("~r~Vous n'avez pas la permission d'ouvrir le garage")
                        else
                            ESX.TriggerServerCallback("CarDealer:GetStock", function(stock)
                                CarDealer.Stock = stock
                            end)
                            CarDealer.OpenGarage()
                        end
                    end
                end
            end
        end
        Wait(interval)
    end
end)

CarDealer.OpenGarage = function()
    local main = RageUI.CreateMenu("Garage", "Menu principal");


    RageUI.Visible(main, not RageUI.Visible(main))

    while main do

        Citizen.Wait(0)

        RageUI.IsVisible(main, function()
            for _,v in pairs(CarDealer.Stock) do
                RageUI.Button("[~b~"..v.plate.."~s~] "..v.label, v.isStored and "~r~Impossible de sortir la voiture (ell est exposé ou déjà sortie!)" or nil, {RightLabel = "→→"}, not v.isStored, {
                    onSelected = function()
                        local model = GetHashKey(v.model)
                        RequestModel(model)
                        while not HasModelLoaded(model) do
                            Citizen.Wait(20)
                        end
                        local vehicle = CreateVehicle(model, Config.Garage.Stored.coords, Config.Garage.Stored.heading, true, true)
                        ESX.Game.SetVehicleProperties(vehicle, v.properties)
                        SetVehicleNumberPlateText(vehicle, v.plate)
                        TriggerServerEvent("CarDealer:StoredVehicle", v.plate)
                    end
                })
            end
        end)

        if not RageUI.Visible(main) then
            main = RMenu:DeleteType('main', true)
        end
    end
end