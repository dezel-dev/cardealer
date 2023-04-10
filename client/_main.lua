---@author Dezel

CarDealer.Stock = {}
CarDealer.Permissions = {}
CarDealer.History = {}

RegisterCommand('+cardealer', function()
    Citizen.CreateThread(function()
        while (not ESX.PlayerData.job) do
            ESX.PlayerData = ESX.GetPlayerData()
            ESX.PlayerData.job = ESX.GetPlayerData().job
            ESX.GetPlayerData()
            Citizen.Wait(20)
        end
        if (ESX.PlayerData.job.name == 'cardealer') or (ESX.PlayerData.job2.name == 'cardealer') then
            CarDealer.OpenMenu()
        end
    end)
end, false)
RegisterKeyMapping('+cardealer', 'Open car dealer menu', 'keyboard', Config.CommandOpen)

Citizen.CreateThread(function()
    while (not NetworkIsSessionStarted()) do
        Citizen.Wait(20)
    end
    CarDealer.InitPermissions()
    TriggerServerEvent("CarDealer:RequestCategories")
end)

RegisterNetEvent("CarDealer:RefreshStock", function(stock)
    CarDealer.Stock = stock
end)
RegisterNetEvent("CarDealer:RefreshCategories", function(categories)
    CarDealer.CategoriesList = categories
end)

CarDealer.Keyboard = function(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry) --Sets the Text above the typing field in the black square
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght) --Actually calls the Keyboard Input
    blockinput = true --Blocks new input while typing if **blockinput** is used

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do --While typing is not aborted and not finished, this loop waits
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult() --Gets the result of the typing
        Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
        blockinput = false --This unblocks new Input when typing is done
        return result --Returns the result
    else
        Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
        blockinput = false --This unblocks new Input when typing is done
        return nil --Returns nil if the typing got aborted
    end
end
CarDealer.InitPermissions = function()
    for k,v in pairs(Config.Permissions) do
        if (v == "recruit") then
            CarDealer.Permissions[k] = {
                ["recruit"] = true,
                ["novice"] = true,
                ["experienced"] = true,
                ["boss"] = true
            }
        elseif (v == "novice") then
            CarDealer.Permissions[k] = {
                ["recruit"] = false,
                ["novice"] = true,
                ["experienced"] = true,
                ["boss"] = true
            }
        elseif (v == "experienced") then
            CarDealer.Permissions[k] = {
                ["recruit"] = false,
                ["novice"] = false,
                ["experienced"] = true,
                ["boss"] = true
            }
        elseif (v == "boss") then
            CarDealer.Permissions[k] = {
                ["recruit"] = false,
                ["novice"] = false,
                ["experienced"] = false,
                ["boss"] = true
            }
        end
    end
end