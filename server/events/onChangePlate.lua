---@author Dezel

RegisterNetEvent("CarDealer:ChangePlate", function(plate, new_plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.update("UPDATE cardealer_stock SET plate = @new_plate WHERE plate = @plate", {
        ['@plate'] = plate,
        ['@new_plate'] = new_plate
    }, function()
        xPlayer.showNotification("~g~La plaque a bien été changé.")
        CarDealer.RefreshStock()
    end)
end)