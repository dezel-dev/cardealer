---@author Dezel

local characters = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}

function createRandomPlateText()
    local plate = ""

    for i = 1, 3 do
        plate = plate..characters[math.random(1, #characters)]
    end
    plate = plate.." "
    for i = 1, 3 do
        plate = plate..math.random(1, 9)
    end

    return plate
end

RegisterNetEvent("CarDealer:BuyVehicle:liquid", function(vehicle, plate, properties)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local plate = createRandomPlateText()
    if (not xPlayer) then return end
    if (xPlayer.getMoney() < vehicle.price) then return xPlayer.showNotification("~r~Vous n'avez pas assez d'argent!") end
    MySQL.query("INSERT INTO cardealer_stock(plate, model, label, properties, inDeliver, deliverTime) VALUES(@plate, @model, @label, @properties, @isDeliver, @deliverTime)", {
        ["@plate"] = plate,
        ["@model"] = vehicle.model,
        ["@label"] = vehicle.Name,
        ["@properties"] = json.encode(properties),
        ["@isDeliver"] = false,
        ["@deliverTime"] = 0
    }, function()
        xPlayer.removeMoney(vehicle.price)
        CarDealer.AddDeliver(_src, plate, vehicle.model, vehicle.Name, properties)
        MySQL.query("INSERT INTO cardealer_history_buy(seller, model, label, price) VALUES(@seller, @model, @label, @price)", {
            ["@seller"] = xPlayer.getName(),
            ["@model"] = vehicle.model,
            ["@label"] = vehicle.Name,
            ["@price"] = vehicle.price
        }, function()
            CarDealer.RefreshHistory()
        end)
    end)
end)
RegisterNetEvent("CarDealer:BuyVehicle:bank", function(vehicle, plate, properties)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local plate = createRandomPlateText()
    if (not xPlayer) then return end
    if (xPlayer.getAccount("bank").money < vehicle.price) then return xPlayer.showNotification("~r~Vous n'avez pas assez d'argent!") end
    MySQL.query("INSERT INTO cardealer_stock(plate, model, label, properties, inDeliver, deliverTime) VALUES(@plate, @model, @label, @properties, @isDeliver, @deliverTime)", {
        ["@plate"] = plate,
        ["@model"] = vehicle.model,
        ["@label"] = vehicle.Name,
        ["@properties"] = json.encode(properties),
        ["@isDeliver"] = false,
        ["@deliverTime"] = 0
    }, function()
        xPlayer.removeAccountMoney("bank", vehicle.price)
        CarDealer.AddDeliver(_src, plate, vehicle.model, vehicle.Name, properties)
        MySQL.query("INSERT INTO cardealer_history_buy(seller, model, label, price) VALUES(@seller, @model, @label, @price)", {
            ["@seller"] = xPlayer.getName(),
            ["@model"] = vehicle.model,
            ["@label"] = vehicle.Name,
            ["@price"] = vehicle.price
        }, function()
            CarDealer.RefreshHistory()
        end)
    end)
end)