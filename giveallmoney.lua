ESX = nil
local playerList = ESX.GetPlayers()
for i=1, #playerList, 1 do
    local _source = playerList[i]
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.addAccountMoney("money", 1000000)
end