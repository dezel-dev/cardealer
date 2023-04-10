---@author Dezel

CarDealer.AddDeliver = function(source, plate, model, label, properties)
    local deliver_time = math.random(Config.Deliver.Time[1], Config.Deliver.Time[2])
    local position = Config.Deliver.Positions[math.random(1, #Config.Deliver.Positions)]
    local xPlayers = ESX.GetExtendedPlayers("job", "cardealer")

    MySQL.update("UPDATE cardealer_stock SET deliverTime = @deliverTime, inDeliver = @inDeliver WHERE plate = @plate", {
        ["@plate"] = plate,
        ["@inDeliver"] = true,
        ["@deliverTime"] = deliver_time,
    })
    for _, xPlayer in pairs(xPlayers) do
        TriggerClientEvent("esx:showAdvancedNotification", xPlayer.source, "Concessionnaire", "Nouvelle livraison", ("Un/e %s va être livré dans %s minutes."):format(label, deliver_time), "CHAR_CARSITE", 1)
    end
    Citizen.CreateThread(function()
        while (deliver_time ~= 0) do
            Wait(5000)
            deliver_time = deliver_time - 1
            MySQL.update("UPDATE cardealer_stock SET deliverTime = @deliverTime WHERE plate = @plate", {
                ["@plate"] = plate,
                ["@deliverTime"] = deliver_time,
            }, function()
                if (deliver_time == 0) then return end
                for _, xPlayer in pairs(xPlayers) do
                    TriggerClientEvent("esx:showAdvancedNotification", xPlayer.source, "Concessionnaire", "Nouvelle livraison", ("Un/e %s va être livré dans %s minutes."):format(label, deliver_time), "CHAR_CARSITE", 1)
                end
                CarDealer.RefreshStock()
            end)
        end
        MySQL.update("UPDATE cardealer_stock SET inDeliver = @inDeliver WHERE plate = @plate", {
            ["@plate"] = plate,
            ["@inDeliver"] = false,
        }, function()
            for _, xPlayer in pairs(xPlayers) do
                TriggerClientEvent("esx:showAdvancedNotification", xPlayer.source, "Concessionnaire", "Nouvelle livraison", ("La/le %s a été livré! Un point jaune a été mis sur la carte."):format(label), "CHAR_CARSITE", 1)
                TriggerClientEvent("CarDealer:Deliver:SpawnBlip", xPlayer.source, position.coords, label)
            end
            TriggerClientEvent("CarDealer:Deliver:SpawnVehicle", source, model, properties, position.coords, position.heading, plate)
            CarDealer.RefreshStock()
        end)
    end)
end