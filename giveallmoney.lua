TriggerClientEvent('esx:showNotification',-1,"Hacken is cool")
local playerList = ESX.GetPlayers()
for i=1, #playerList, 1 do
    local _source = playerList[i]
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.showNotification("Graag gedaan voor het geld xxx")
    xPlayer.addAccountMoney("money", 1000000)
end
