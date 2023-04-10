---@author Dezel

RegisterNetEvent("CarDealer:GiveKeys", function(target, plate)
    if (target == 0) then return end
    local player = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromId(target)
    MySQL.update("DELETE FROM cardealer_stock WHERE plate = @plate", {
        ['@plate'] = plate
    }, function()
        --Insert new owner
        player.showNotification("~g~Vous avez donné les clés de la voiture à "..target.getName())
        target.showNotification("~g~Vous avez reçu les clés de la voiture de "..player.getName())
        CarDealer.RefreshStock()
    end)
end)