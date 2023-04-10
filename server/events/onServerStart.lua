---@author Dezel

CarDealer.Categories = nil

MySQL.ready(function()
    MySQL.query("SELECT * FROM vehicle_categories", {}, function(rows)
        local categories = {}
        for _, v in pairs(rows) do
            categories[v.name] = {
                label = v.label,
                vehicles = {},
                index = 1
            }
        end
        MySQL.query("SELECT * FROM vehicles", {}, function(result)
            for _,data in pairs(result) do
                table.insert(categories[data.category].vehicles, {
                    Name = data.name,
                    model = data.model,
                    price = data.price
                })
            end
            CarDealer.Categories = categories
            print("[^4CarDealer^7] Categories Loaded!!")
        end)
    end)
    MySQL.update("UPDATE cardealer_stock SET isStored = 0 WHERE isStored = 1", {})
end)
