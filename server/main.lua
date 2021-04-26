ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('PackageDelivery:NewDriver')
AddEventHandler('PackageDelivery:NewDriver', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayerName = xPlayer.getName()
    TriggerClientEvent('PackageDelivery:NewDriverNotification', -1, xPlayerName)
end)

RegisterServerEvent('PackageDelivery:PackageDelivered')
AddEventHandler('PackageDelivery:PackageDelivered', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayerName = xPlayer.getName()
    xPlayer.addMoney(Config.DeliveryPay)
    xPlayer.showNotification('You were paid ~g~$' .. Config.DeliveryPay .. " ~w~for a delivery!")
    xPlayer.removeInventoryItem('package', 1)
    TriggerClientEvent('PackageDelivery:PackageDeliveredNotification', -1, xPlayerName)
end)

RegisterServerEvent('PackageDelivery:GivePackages')
AddEventHandler('PackageDelivery:GivePackages', function(Deliverycount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayerName = xPlayer.getName()
    xPlayer.addInventoryItem('package', Deliverycount)
end)