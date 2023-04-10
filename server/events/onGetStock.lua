---@author Dezel

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('CarDealer:GetStock', function(source, cb)
    MySQL.query("SELECT * FROM cardealer_stock", {}, function(result)
        local stock = {}
        for _,v in pairs(result) do
            table.insert(stock, {
                plate = v.plate,
                model = v.model,
                label = v.label,
                properties = json.decode(v.properties),
                isDelivered = v.inDeliver,
                deliveryTime = v.deliverTime,
                isStored = v.isStored,
            })
        end
        cb(stock)
    end)
end)

CarDealer.RefreshStock = function()
    MySQL.query("SELECT * FROM cardealer_stock", {}, function(result)
        local stock = {}
        for _,v in pairs(result) do
            table.insert(stock, {
                plate = v.plate,
                model = v.model,
                label = v.label,
                properties = json.decode(v.properties),
                isDelivered = v.inDeliver,
                deliveryTime = v.deliverTime,
                isStored = v.isStored,
            })
        end
        TriggerClientEvent("CarDealer:RefreshStock", -1, stock)
    end)
end

CarDealer.RefreshCategories = function()
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
            TriggerClientEvent("CarDealer:RefreshCategories", -1, categories)
        end)
    end)
end