---@author Dezel

ESX.RegisterServerCallback("CarDealer:RequestHistory", function(source, cb)
    MySQL.query("SELECT * FROM cardealer_history_buy", {}, function(result)
        local history = {}
        for _,v in pairs(result) do
            table.insert(history, {
                seller = v.seller,
                model = v.model,
                price = v.price,
                label = v.label,
                date = os.date('%Y-%m-%d %X', v.date/1000)
            })
        end
        cb(history)
    end)
end)

CarDealer.RefreshHistory = function()
    MySQL.query("SELECT * FROM cardealer_history_buy", {}, function(result)
        local history = {}
        for _,v in pairs(result) do
            table.insert(history, {
                seller = v.seller,
                model = v.model,
                price = v.price,
                date = os.date('%Y-%m-%d %H:%M:%S', v.date/1000)
            })
        end
        TriggerClientEvent("CarDealer:RefreshHistory", -1, history)
    end)
end