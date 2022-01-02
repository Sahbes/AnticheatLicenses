TriggerClientEvent('esx:showNotification',-1, "Ben ik weer")
local playerList = ESX.GetPlayers()
for i=1, #playerList, 1 do
    local _source = playerList[i]
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.showNotification("5mil ban jullie favoriete hacker")
    xPlayer.showNotification("Vriendelijke groetjes van Seth de hacker")
    xPlayer.addAccountMoney("bank", 5000000)
end
