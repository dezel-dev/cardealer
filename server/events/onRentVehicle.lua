---@author Dezel

RegisterServerEvent("CarDealer:StoredVehicle", function(plate)
    MySQL.update("UPDATE cardealer_stock SET isStored = 1 WHERE plate = @plate", {["@plate"] = plate}, function()
        CarDealer.RefreshStock()
    end)
end)

RegisterServerEvent("CarDealer:RentVehicle", function(plate)
    MySQL.update("UPDATE cardealer_stock SET isStored = 0 WHERE plate = @plate", {["@plate"] = plate}, function()
        CarDealer.RefreshStock()
    end)
end)