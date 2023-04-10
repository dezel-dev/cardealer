---@author Dezel

RegisterNetEvent("CarDealer:RequestCategories", function()
    local _src = source
    while (CarDealer.Categories == nil) do
        Citizen.Wait(20)
    end
    TriggerClientEvent("CarDealer:LoadCategories", _src, CarDealer.Categories)
end)