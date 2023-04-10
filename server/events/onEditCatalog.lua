---@author Dezel

RegisterNetEvent("CarDealer:EditCatalog", function(label, model, new_price)
    MySQL.update("UPDATE vehicles SET price = @price WHERE model = @model", {
        ['@price'] = new_price,
        ['@model'] = model,
    }, function()
        CarDealer.RefreshCategories()
    end)
end)