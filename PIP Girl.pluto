--[[
__________._____________    ________.__       .__   
\______   \   \______   \  /  _____/|__|______|  |  
 |     ___/   ||     ___/ /   \  ___|  \_  __ \  |  
 |    |   |   ||    |     \    \_\  \  ||  | \/  |__
 |____|   |___||____|      \________/__||__|  |____/                
]]--

local SCRIPT_VERSION = "1.121"

local startupmsg = "If settings are missing PLS restart lua.\n\nAdded Custom spawns in Session>Join Settings.\nIf you use quick join, set spawn to \"Random\" or \"Last Location\" and u can profit from custom spawn.\n\nLea Tech on top!"

-- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
local status, auto_updater = pcall(require, "auto-updater")
if not status then
    local auto_update_complete = nil util.toast("Installing auto-updater...", TOAST_ALL)
    async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
        function(result, headers, status_code)
            local function parse_auto_update_result(result, headers, status_code)
                local error_prefix = "Error downloading auto-updater: "
                if status_code ~= 200 then util.toast(error_prefix..status_code, TOAST_ALL) return false end
                if not result or result == "" then util.toast(error_prefix.."Found empty file.", TOAST_ALL) return false end
                filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                if file == nil then util.toast(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                file:write(result) file:close() util.toast("Successfully installed auto-updater lib", TOAST_ALL) return true
            end
            auto_update_complete = parse_auto_update_result(result, headers, status_code)
        end, function() util.toast("Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
    async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
    if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
    auto_updater = require("auto-updater")
end
if not async_http.have_access() then return end
if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end

local auto_update_config = {
    source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/PIP%20Girl.pluto",
    script_relpath=SCRIPT_RELPATH,
    verify_file_begins_with="--",
    check_interval=666,
    silent_updates=true,
    restart_delay=1666,
    dependencies={
        {
            name="logo",
            source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/resources/1%20PIP%20Girl/logo.png",
            script_relpath="resources/1 PIP Girl/logo.png",
            check_interval=13666,
        },
        {
            name="blacklist",
            source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/resources/1%20PIP%20Girl/Blacklist.json",
            script_relpath="resources/1 PIP Girl/Blacklist.json",
            check_interval=666,
        },
        {
            name="read_me.txt",
            source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/resources/1%20PIP%20Girl/Export/read_me.txt",
            script_relpath="resources/1 PIP Girl/Export/read_me.txt",
            check_interval=13666,
        },
    }
}
auto_updater.run_auto_update(auto_update_config)

-- Load required dependencies into global namespace
for _, dependency in pairs(auto_update_config.dependencies) do
    if dependency.is_required then
        if dependency.loaded_lib == nil then
            util.toast("Error loading lib "..dependency.name, TOAST_ALL)
        else
            local var_name = dependency.name
            _G[var_name] = dependency.loaded_lib
        end
    end
end

--util.require_natives(1681379138)
util.require_natives("3095a")

resources_dir = filesystem.resources_dir() .. '/1 PIP Girl/'
logo = directx.create_texture(resources_dir .. 'logo.png')
if SCRIPT_MANUAL_START or SCRIPT_SILENT_START then
    logo_alpha = 0
    logo_alpha_incr = 0.01
    logo_alpha_thread = util.create_thread(function (thr)
        while true do
            logo_alpha = logo_alpha + logo_alpha_incr
            if logo_alpha > 1 then
                logo_alpha = 1
            elseif logo_alpha < 0 then 
                logo_alpha = 0
                util.stop_thread()
            end
            util.yield()
        end
    end)

    logo_thread = util.create_thread(function (thr)
        starttime = os.clock()
        local alpha = 0
        while true do
            directx.draw_texture(logo, 0.06, 0.06, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, logo_alpha)
            timepassed = os.clock() - starttime
            if timepassed > 1 then
                logo_alpha_incr = -0.01
            end
            if logo_alpha == 0 then
                util.stop_thread()
            end
            util.yield()
        end
    end)
end

local max_int = 2147483647
local min_int = -2147483647
local Int_PTR = memory.alloc_int()

local function getMPX()
    return 'MP'.. util.get_char_slot() ..'_'
end

local function STAT_GET_INT(Stat)
    STATS.STAT_GET_INT(util.joaat(getMPX() .. Stat), Int_PTR, -1)
    return memory.read_int(Int_PTR)
end

function ADD_MP_INDEX(stat)
    local Exceptions = {
        "MP_CHAR_STAT_RALLY_ANIM",
        "MP_CHAR_ARMOUR_1_COUNT",
        "MP_CHAR_ARMOUR_2_COUNT",
        "MP_CHAR_ARMOUR_3_COUNT",
        "MP_CHAR_ARMOUR_4_COUNT",
        "MP_CHAR_ARMOUR_5_COUNT",
    }
    for _, exception in pairs(Exceptions) do
        if stat == exception then
            return "MP" .. util.get_char_slot() .. "_" .. stat
        end
    end

    if not string.contains(stat, "MP_") and not string.contains(stat, "MPPLY_") then
        return "MP" .. util.get_char_slot() .. "_" .. stat
    end
    return stat
end

function STAT_SET_INT(stat, value)
    STATS.STAT_SET_INT(util.joaat(ADD_MP_INDEX(stat)), value, true)
end

local function session_type()
    if util.is_session_started() or util.is_session_transition_active() then
        if NETWORK.NETWORK_SESSION_IS_PRIVATE() then
            return "Privat"
        end
        if NETWORK.NETWORK_SESSION_IS_CLOSED_FRIENDS() then
            return "Priends"
        end
        if NETWORK.NETWORK_SESSION_IS_CLOSED_CREW() then
            return "Crew"
        end
        if NETWORK.NETWORK_SESSION_IS_SOLO() then
            return "Solo"
        end
        return "Public"
    end
    return "Singleplayer"
end

local function transitionState(state)
    if not util.is_session_transition_active() and util.is_session_started() and players.are_stats_ready(players.user()) then
        return state and 1 or "Docked"
    end
    if not util.is_session_transition_active() and util.is_session_started() and not players.are_stats_ready(players.user()) then
        return state and 2 or "Pressurization"
    end
    if util.is_session_transition_active() then
        return state and 3 or "Orbit"
    end
    return state and 404 or "404"
end

local function notify(msg)
    util.toast("<[Pip Girl]>: " .. msg, TOAST_CONSOLE)
    util.toast("<[Pip Girl]>\n" .. msg)
end

local function notify_cmd(msg)
    util.toast("<[Pip Girl]>: " .. msg, TOAST_CONSOLE)
end

local function warnify(msg)
    local formattedMsg = string.gsub(msg, "\n", " | ")
    chat.send_message("<[Pip Girl]>: " .. formattedMsg, true, true, false)
    util.toast("<[Pip Girl]>: " .. msg, TOAST_CONSOLE)
    util.toast("<[Pip Girl]>\n" .. msg)
end

local function warnify_net(msg)
    local formattedMsg = string.gsub(msg, "\n", " | ")
    chat.send_message("<[Pip Girl]>: " .. formattedMsg, true, true, true)
    util.toast("<[Pip Girl]>: " .. msg, TOAST_CONSOLE)
    util.toast("<[Pip Girl]>\n" .. msg)
end

local function warnify_ses(msg)
    local formattedMsg = string.gsub(msg, "\n", " | ")
    chat.send_message(formattedMsg, false, true, true)
    util.toast("<[Pip Girl]>: " .. msg, TOAST_CONSOLE)
    util.toast(msg)
end

local function player_Exist(pid)
    if pid then
        if players.exists(pid) then
            local name = players.get_name(pid)
            if name ~= "undiscoveredplayer" then
                if name ~= "InvalidPlayer" then
                    for players.list() as plid do
                        if plid == pid then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

local function allow_Join_back(name)
    util.yield(420)
    for menu.ref_by_path("Online>Session>Block Joins>Removed Players"):getChildren() as rat do
        if rat:isValid() then
            util.yield(13)
        end
        util.yield(13)
    end
    util.yield(666)
    for menu.ref_by_path("Online>Session>Block Joins>Removed Players"):getChildren() as rat do
        if rat:isValid() then
            if rat.menu_name == name then
                rat:trigger()
                break
            end
        end
    end
end

local function StandUser(pid) -- credit to sapphire for this and jinx script
    util.yield(666)
    if player_Exist(pid) and pid ~= players.user() then
        for menu.player_root(pid):getChildren() as cmd do
            if cmd:getType() == COMMAND_LIST_CUSTOM_SPECIAL_MEANING and cmd:refByRelPath("Stand User"):isValid() then
                return true
            end
        end
    end
    return false
end

local function discoveredSince(pid)
    util.yield(666)
    if player_Exist(pid) then
        local playerPath = menu.player_root(pid)
        local timeString = playerPath:refByRelPath("Information>Discovered").value
        if timeString and type(timeString) == "string" then
            local minutes, seconds = timeString:match("(%d+) minutes, (%d+) seconds ago")
            if minutes and seconds then
                local timeInSeconds = tonumber(minutes) * 60 + tonumber(seconds)
                return timeInSeconds
            end
        end
    end
    return 0
end

local function wannabeGod(pid)
    util.yield(666)
    if player_Exist(pid) and pid ~= players.user() then
        for menu.player_root(pid):getChildren() as cmd do
            if cmd:getType() == COMMAND_LIST_CUSTOM_SPECIAL_MEANING and cmd:refByRelPath("Attacking While Invulnerable"):isValid() then
                return true
            end
            if cmd:getType() == COMMAND_LIST_CUSTOM_SPECIAL_MEANING and cmd:refByRelPath("Dead For Too Long"):isValid() then
                return true
            end
        end
    end
    return false
end

local function aggressive(pid)
    util.yield(666)
    if player_Exist(pid) and pid ~= players.user() then
        for menu.player_root(pid):getChildren() as cmd do
            if cmd:getType() == COMMAND_LIST_CUSTOM_SPECIAL_MEANING and cmd:refByRelPath("Spoofed Host Token (Aggressive)"):isValid() then
                return true
            end
        end
    end
    return false
end

local function StandDetectionsRead(pid)
    util.yield(666)
    local PlayerRootChildrenArray = menu.player_root(pid):getChildren()
    for PlayerRootChildrenArray as Child do
        if Child:getType() == COMMAND_LIST_CUSTOM_SPECIAL_MEANING and lang.get_string(Child.menu_name, "en"):startswith "Classification: " then
            local DetectionsArray = Child:getChildren()
            for Index, Detection in DetectionsArray do
                DetectionsArray[Index] = lang.get_string(Detection.menu_name, "en")
            end
            return DetectionsArray
        end
    end
end

local function isModder(pid)
    if players.is_marked_as_modder(pid) then --or (StandDetectionsRead(pid) and #(StandDetectionsRead(pid)) > 0) then
        return true
    else
        return false
    end
end

local urceoname = ""
local function organization_control(org)
    if players.get_boss(players.user()) ~= -1 then
        if players.get_org_type(players.user()) == 0 then
            if org == "MC" then
                menu.trigger_commands("ceotomc")
                util.yield(666)
                if players.get_org_type(players.user()) == 1 then
                    if urceoname ~= "" then
                        menu.trigger_commands("ceoname " .. urceoname)
                    end
                    notify("Turned you into MC President!")
                else
                    notify("Failed to turn you into MC President.")
                end
            end
        else
            if org == "CEO" then
                menu.trigger_commands("ceotomc")
                util.yield(666)
                if players.get_org_type(players.user()) == 0 then
                    if urceoname ~= "" then
                        menu.trigger_commands("ceoname " .. urceoname)
                    end
                    notify("Turned you into CEO!")
                else
                    notify("Failed to turn you into CEO.")
                end
            end
        end
    else
        if org == "CEO" then
            menu.trigger_commands("ceostart")
            util.yield(666)
            if players.get_org_type(players.user()) == 0 then
                if urceoname ~= "" then
                    menu.trigger_commands("ceoname " .. urceoname)
                end
                notify("Turned you into CEO!")
            else
                notify("Failed to turn you into CEO.")
            end
        elseif org == "MC" then
            menu.trigger_commands("mcstart")
            util.yield(666)
            if players.get_org_type(players.user()) == 1 then
                if urceoname ~= "" then
                    menu.trigger_commands("ceoname " .. urceoname)
                end
                notify("Turned you into MC President!")
            else
                notify("Failed to turn you into MC President.")
            end
        end
    end
end

local function start_script(name)
    if transitionState(true) == 1 then
        if HUD.IS_PAUSE_MENU_ACTIVE() then
            notify("Close any open Game Menu first!")
            return
        end
        SCRIPT.REQUEST_SCRIPT(name)
        repeat util.yield_once() until SCRIPT.HAS_SCRIPT_LOADED(name)
        SYSTEM.START_NEW_SCRIPT(name, 5000)
        SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(name)
    end
end

local function IS_HELP_MSG_DISPLAYED(label)
    HUD.BEGIN_TEXT_COMMAND_IS_THIS_HELP_MESSAGE_BEING_DISPLAYED(label)
    return HUD.END_TEXT_COMMAND_IS_THIS_HELP_MESSAGE_BEING_DISPLAYED(0)
end

local function IS_TEXT_DISPLAYED(text) -- trying to be good :sob:
    HUD.BEGIN_TEXT_COMMAND_IS_MESSAGE_DISPLAYED(text)
    return HUD.END_TEXT_COMMAND_IS_MESSAGE_DISPLAYED()
end

local handle_ptr = memory.alloc(13*8)
local function pid_to_handle(pid)
    if pid then
        NETWORK.NETWORK_HANDLE_FROM_PLAYER(pid, handle_ptr, 13)
        return handle_ptr
    end
    return nil
end

local function find_in_table(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then
            return i
        end
    end
    return nil
end

local function contains(tbl, value)
    for ipairs(tbl) as v do
        if v == value then
            return true
        end
    end
    return false
end

local function getEntryByValue(tbl, value)
    for _, entry in ipairs(tbl) do
        if entry == value then
            return entry
        end
    end
end

local function isStuck(pid)
    if transitionState(true) ~= 1 then
        return false
    end
    if pid == players.user() then
        if ENTITY.GET_ENTITY_SPEED(pid) < 1 and HUD.BUSYSPINNER_IS_DISPLAYING() then
            return true
        end
    end
    if not players.is_visible(pid) and ENTITY.GET_ENTITY_SPEED(pid) < 1 and not NETWORK.IS_PLAYER_IN_CUTSCENE(pid) then
        if players.are_stats_ready(pid) then
            if players.get_money(pid) ~= 0 and players.get_rank(pid) ~= 0 then
                return true
            end
            if players.get_money(pid) ~= 0 and players.get_kd(pid) ~= 0 and players.get_rank(pid) ~= 0 then
                return true
            end
        end
    end
    return false
end

local function isLoading(pid)
    if transitionState(true) ~= 1 then
        if pid == players.user() then
            return true
        else
            return false
        end
    end
    if pid == players.user() then
        if ENTITY.GET_ENTITY_SPEED(pid) < 1 and HUD.BUSYSPINNER_IS_DISPLAYING() then
            return true
        end
    end
    local pPos = players.get_position(pid)
    if pPos.x == 0 and pPos.y == 0 and pPos.z == 0 then
        return true
    end
    if ENTITY.GET_ENTITY_SPEED(pid) < 1 then
        if not players.are_stats_ready(pid) then
            return true
        end
        if players.get_money(pid) == 0 then
            return true
        end
        if players.get_rank(pid) == 0 then
            return true
        end
        if not players.is_visible(pid) then
            return true
        end
    end
    return false
end

local function isFriend(pid)
    local hdl = pid_to_handle(pid)
    if hd1 then
        if NETWORK.NETWORK_IS_FRIEND(hdl) then
            return true
        end
    end
    for players.list_only(true, true, false, true) as plid do
        if plid == pid then
            return true
        end
    end
    if pid == players.user() then
        return true
    end
    return false
end

local function get_session_code()
    local applicable, code = util.get_session_code()
    if applicable then
        if code then
            return code
        end
        return "Please wait..."
    end
    return "N/A"
end

local function requestModel(hash, timeout)
    if not STREAMING.HAS_MODEL_LOADED(hash) then
        STREAMING.REQUEST_MODEL(hash)
        local startTime = os.time()
        while not STREAMING.HAS_MODEL_LOADED(hash) do
            if os.time() - startTime > timeout or timeout == 0 then
                break
            end
            util.yield(13)
        end
    end
end

local function requestControl(entity, timeout)
    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        if timeout > 0 then
            local startTime = os.time()
            while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) do
                if os.time() - startTime > timeout or timeout == 0 then
                    break
                end
                util.yield(113)
            end
        end
    end
end

local function does_entity_exist(entity)
    if entity then
        if ENTITY.DOES_ENTITY_EXIST(entity) then
            return true
        end
    end
    return false
end

local function get_user_vehicle()
    local userVehicleHandle = entities.get_user_vehicle_as_handle(true)
    if userVehicleHandle == -1 then
        return entities.get_user_personal_vehicle_as_handle()
    else
        return userVehicleHandle
    end
end

local function is_user_driving_vehicle()
    return (PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true))
end

local function is_vehicle_free_for_use(vehicle)
    local driverPed = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
    local driver = PED.IS_PED_A_PLAYER(driverPed)
    if not driver or driverPed == players.user_ped() then
        return true
    end
    return false
end

local function objectCheck(entity, hash, locationV3, pitch, roll, yaw, order, timeout, anti_collision)
    local closestDistance = nil
    local closestPlayer = nil
    local coordinatesCorrect = false
    local anglesCorrect = false    
    if anti_collision then
        for players.list() as pid do
            if isFriend(pid) then
                local playerPos = players.get_position(pid)
                local distance = SYSTEM.VDIST(locationV3.x, locationV3.y, locationV3.z, playerPos.x, playerPos.y, playerPos.z)
                if not closestDistance or distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = pid
                end
            end
            util.yield(13 + timeout)
        end
        if closestPlayer then
            requestControl(entity, timeout)
            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(entity, PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), false)
        end
    end
    local currentCoords = ENTITY.GET_ENTITY_COORDS(entity)
    coordinatesCorrect = (math.abs(currentCoords.x - locationV3.x) <= 1) and
                            (math.abs(currentCoords.y - locationV3.y) <= 1) and
                            (math.abs(currentCoords.z - locationV3.z) <= 1)
    if not coordinatesCorrect then
        requestControl(entity, timeout)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, locationV3.x, locationV3.y, locationV3.z, true, true, true)
        ENTITY.FREEZE_ENTITY_POSITION(entity, true)
    end
    local currentRotation = ENTITY.GET_ENTITY_ROTATION(entity, order)
    anglesCorrect = (math.abs(currentRotation.x - pitch) <= 1) and
                    (math.abs(currentRotation.y - roll) <= 1) and
                    (math.abs(currentRotation.z - yaw) <= 1)
    if not anglesCorrect then
        requestControl(entity, timeout)
        ENTITY.SET_ENTITY_ROTATION(entity, pitch, roll, yaw, order, true)
        ENTITY.FREEZE_ENTITY_POSITION(entity, true)
    end
end

local function SpawnCheck(entity, hash, locationV3, pitch, roll, yaw, order, timeout, anti_collision)
    if order == nil then order = 2 end
    local startTime = os.time()
    if not does_entity_exist(entity) then
        requestModel(hash, timeout)
        entity = entities.create_object(hash, locationV3)
        util.yield(13 + timeout)
        startTime = os.time()
        while not does_entity_exist(entity) do
            if os.time() - startTime > timeout or timeout == 0 then
                break
            end
            util.yield(13 + timeout)
        end
        requestControl(entity, timeout)
        entities.set_can_migrate(entity, false)
        ENTITY.FREEZE_ENTITY_POSITION(entity, true)
        objectCheck(entity, hash, locationV3, pitch, roll, yaw, order, timeout, anti_collision)
        return entity
    else
        objectCheck(entity, hash, locationV3, pitch, roll, yaw, order, timeout, anti_collision)
        util.yield(13 + timeout)
        return entity
    end
end

local function thunderForMin(min)
    if transitionState(true) == 1 then
        menu.trigger_commands("thunderon")
        notify("Thunder starts.")
        local startTimestamp = os.time()
        while os.time() - startTimestamp < min * 60 do
            local remainingTime = min - math.floor((os.time() - startTimestamp) / 60)
            if remainingTime == 1 then
                notify("Thunder will stop in 1 minute.")
            else
                notify("Thunder will stop in "..remainingTime.." minutes.")
            end
            util.yield(60000) -- one minute
        end
        notify("Thunder stops.")
        menu.trigger_commands("thunderoff")
    end
end

local function get_Street_Names(x, y, z)
    local playerPosition
    if x and y and z then
        playerPosition = {x = x, y = y, z = z}
    else
        playerPosition = players.get_position(players.user())
    end

    local streetNamePtr = memory.alloc_int()
    local crossingRoadPtr = memory.alloc_int()

    PATHFIND.GET_STREET_NAME_AT_COORD(playerPosition.x, playerPosition.y, playerPosition.z, streetNamePtr, crossingRoadPtr)

    local streetNameInt = memory.read_int(streetNamePtr)
    local crossingRoadInt = memory.read_int(crossingRoadPtr)
    local streetName = ""
    local crossingName = ""

    if streetNameInt ~= 0 then
        streetName = util.get_label_text(streetNameInt)
    end

    if crossingRoadInt ~= 0 then
        crossingName = util.get_label_text(crossingRoadInt)
    end

    return {
        streetName = streetName,
        crossingName = crossingName
    }
end

local function Wait_for_transitionState()
    local ses_cod = get_session_code()
    while transitionState(true) > 2 and ses_cod == get_session_code() do
        util.yield(666)
    end
    if ses_cod == get_session_code() then
        players.dispatch_on_join()
    end
end

local function StrategicKick(pid)
    if player_Exist(pid) and pid ~= players.user() then
        local name = players.get_name(pid)
        if name ~= players.get_name(players.user()) then
            if transitionState(true) ~= 1 then
                menu.trigger_commands("kick " .. name)
                NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
                Wait_for_transitionState()
            else
                if menu.get_edition() > 1 then
                    if players.user() == players.get_host() then
                        if not isLoading(pid) and not isLoading(players.user()) then
                            menu.trigger_commands("ban " .. name)
                        else
                            menu.trigger_commands("loveletterkick " .. name)
                        end
                    else
                        menu.trigger_commands("kick " .. name)
                        menu.trigger_commands("ignore " .. name .. " on")
                        menu.trigger_commands("desync " .. name .. " on")
                        menu.trigger_commands("blocksync " .. name .. " on")
                        NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
                    end
                else
                    menu.trigger_commands("kick " .. name)
                    menu.trigger_commands("ignore " .. name .. " on")
                    menu.trigger_commands("desync " .. name .. " on")
                    menu.trigger_commands("blocksync " .. name .. " on")
                    NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
                end
            end
        end
    end
end

menu.divider(menu.my_root(), SCRIPT_VERSION)
local PIP_Girl = menu.list(menu.my_root(), 'PIP Girl', {}, 'Personal Information Processor Girl.', function(); end)
local PIP_Girl_APPS = menu.list(PIP_Girl, 'PIP Girl Apps', {}, 'Personal Information Processor Girl apps.', function(); end)
--local PIP_Girl_Heist = menu.list(PIP_Girl, 'PIP Girl Heists', {}, 'Personal Information Processor Girl Heist Presets.', function(); end)
local Stimpak = menu.list(menu.my_root(), 'Stimpak', {}, 'Take a breath.', function(); end)
local Vehicle = menu.list(menu.my_root(), 'Vehicle', {}, 'Drive pretty and nice.', function(); end)
local Outfit = menu.list(menu.my_root(), 'Outfit', {}, 'Look pretty and nice.', function(); end)
local Game = menu.list(menu.my_root(), 'Game', {}, 'Very gaming today.', function(); end)
local Session = menu.list(menu.my_root(), 'Session', {}, '.noisseS', function(); end)
local SessionClaimer = menu.list(Session, 'Session Claimer Settings', {}, 'Session Claimer settings.', function(); end)
local Settings = menu.list(menu.my_root(), 'Settings/Misc', {}, 'Basement.', function(); end)
local Credits = menu.list(Settings, 'Credits', {}, '<3', function(); end)

menu.action(PIP_Girl_APPS, "Master Control Terminal App", {}, "Your master control terminal.", function()
    organization_control("CEO")
    start_script("apparcadebusinesshub")
end)

menu.action(PIP_Girl_APPS, "Nightclub App", {}, "Your nightclub screen.", function()
    organization_control("CEO")
    start_script("appbusinesshub")
end)

menu.action(PIP_Girl_APPS, "Bunker App", {}, "Your bunker screen.", function()
    organization_control("CEO")
    start_script("appbunkerbusiness")
end)

menu.action(PIP_Girl_APPS, "Touchscreen Terminal App", {}, "Your Terrorbyte screen.",  function()
    organization_control("CEO")
    start_script("apphackertruck")
end)

menu.action(PIP_Girl_APPS, "Air Cargo App", {}, "Your air cargo screen.", function()
    organization_control("CEO")
    start_script("appsmuggler")
end)

menu.action(PIP_Girl_APPS, "The Open Road App", {}, "Your MC management screen.", function()
    organization_control("MC")
    start_script("appbikerbusiness")
end)

menu.action(PIP_Girl_APPS, "The Agency App", {}, "Your agency screen.", function()
    organization_control("CEO")
    start_script("appfixersecurity")
end)

menu.action(PIP_Girl_APPS, "The Avenger App", {}, "Your avenger screen.", function()
    organization_control("CEO")
    start_script("appavengeroperations")
end)

menu.action(PIP_Girl_APPS, "The Internet App", {}, "Your internet screen.", function()
    start_script("appinternet")
end)

menu.action(PIP_Girl_APPS, "(Unstuck) Unstuck after starting a sale.", {}, "If you use one of the screens above and start a sale, you could get stuck.\nPerform an Suicide to unstuck.", function()
    menu.trigger_commands('ewo')
end)

local function CayoBasics()
    menu.trigger_commands("fillinventory")
    menu.trigger_commands("fillammo")
    STAT_SET_INT("H4_MISSIONS", -1)
    STAT_SET_INT("H4CNF_APPROACH", -1)
    STAT_SET_INT("H4CNF_BS_ENTR", 63)
    STAT_SET_INT("H4CNF_BS_GEN", 126975)
    STAT_SET_INT("H4CNF_BS_ABIL", -1)
    STAT_SET_INT("H4CNF_WEAPONS", 2)
    STAT_SET_INT("H4CNF_WEP_DISRP", 3)
    STAT_SET_INT("H4CNF_ARM_DISRP", 3)
    STAT_SET_INT("H4CNF_HEL_DISRP", 3)
    STAT_SET_INT("H4CNF_BOLTCUT", 4424)
    STAT_SET_INT("H4CNF_UNIFORM", 5256)
    STAT_SET_INT("H4CNF_GRAPPEL", 5156)
    STAT_SET_INT("H4CNF_TROJAN", 5)
    STAT_SET_INT("H4_PROGRESS", 131055)
    STAT_SET_INT("H4_PLAYTHROUGH_STATUS", 100)
end

local function CayoNotify()
    warnify("Note that R* has implemented a limit that prevents you from earning more than $2.550.000 per run or more than $4.100.000 per hour from this heist per person.")
    warnify("With this setup, every player gets 2m, so they can do 2 runs and reach the hourly limit.")
    warnify("The Cayo heist with a sweet legit-like preset.\nIf you're inside the submarine, go manually out and in again to refresh the board.")
    util.yield(1666)
    notify("The Cayo heist with a sweet legit-like preset.\nIf you're inside the submarine, go manually out and in again to refresh the board.")    
end
--[[
menu.action(PIP_Girl_Heist, 'Cayo 1 Player Preset (!)', {}, "", function (click_type)
    menu.show_warning(PIP_Girl, click_type, 'Want to set up cayo?', function()
        if transitionState(true) == 1 then
            CayoBasics()
            STAT_SET_INT("H4LOOT_CASH_I", 4227216)
            STAT_SET_INT("H4LOOT_CASH_I_SCOPED", 4227216)
            STAT_SET_INT("H4LOOT_CASH_C", 20)
            STAT_SET_INT("H4LOOT_CASH_C_SCOPED", 20)
            STAT_SET_INT("H4LOOT_COKE_I", 131336)
            STAT_SET_INT("H4LOOT_COKE_I_SCOPED", 131336)
            STAT_SET_INT("H4LOOT_COKE_C", 0)
            STAT_SET_INT("H4LOOT_COKE_C_SCOPED", 0)
            STAT_SET_INT("H4LOOT_GOLD_I", 0)
            STAT_SET_INT("H4LOOT_GOLD_I_SCOPED", 0)
            STAT_SET_INT("H4LOOT_GOLD_C", 192)
            STAT_SET_INT("H4LOOT_GOLD_C_SCOPED", 192)
            STAT_SET_INT("H4LOOT_WEED_I", 1067010)
            STAT_SET_INT("H4LOOT_WEED_I_SCOPED", 1067010)
            STAT_SET_INT("H4LOOT_WEED_C", 0)
            STAT_SET_INT("H4LOOT_WEED_C_SCOPED", 0)
            STAT_SET_INT("H4LOOT_PAINT", 9)
            STAT_SET_INT("H4LOOT_PAINT_SCOPED", 9)
            local randomTarget = math.random(1, 4)
            if randomTarget == 1 then
                STAT_SET_INT("H4LOOT_CASH_V", 29886)
                STAT_SET_INT("H4LOOT_COKE_V", 59772)
                STAT_SET_INT("H4LOOT_GOLD_V", 79696)
                STAT_SET_INT("H4LOOT_PAINT_V", 59772)
                STAT_SET_INT("H4LOOT_WEED_V", 39848)
                STAT_SET_INT("H4CNF_TARGET", 5) -- Panther
                warnify("You'r Cayo Target is the a Panther Statue. >:D")
            end
            if randomTarget == 2 then
                STAT_SET_INT("H4LOOT_CASH_V", 304886)
                STAT_SET_INT("H4LOOT_COKE_V", 609772)
                STAT_SET_INT("H4LOOT_GOLD_V", 813029)
                STAT_SET_INT("H4LOOT_PAINT_V", 609772)
                STAT_SET_INT("H4LOOT_WEED_V", 406514)
                STAT_SET_INT("H4CNF_TARGET", 0) -- Tequilla
                warnify("You'r Cayo Target is the Sinsimito Tequilla. :S")
            end
            if randomTarget == 3 then
                STAT_SET_INT("H4LOOT_CASH_V", 277386)
                STAT_SET_INT("H4LOOT_COKE_V", 554772)
                STAT_SET_INT("H4LOOT_GOLD_V", 739696)
                STAT_SET_INT("H4LOOT_PAINT_V", 554772)
                STAT_SET_INT("H4LOOT_WEED_V", 369848)                
                STAT_SET_INT("H4CNF_TARGET", 1) -- Ruby
                warnify("You'r Cayo Target is a Ruby Necklace. :D")
            end
            if randomTarget == 4 then
                STAT_SET_INT("H4LOOT_CASH_V", 194886)
                STAT_SET_INT("H4LOOT_COKE_V", 389772)
                STAT_SET_INT("H4LOOT_GOLD_V", 519696)
                STAT_SET_INT("H4LOOT_PAINT_V", 389772)
                STAT_SET_INT("H4LOOT_WEED_V", 259848)                            
                STAT_SET_INT("H4CNF_TARGET", 3) -- Pink
                warnify("You'r Cayo Target is a Pink Diamond. *.*")
            end
            CayoNotify()
        end
    end, function()
        notify("Aborted.")
    end, true)
end)

menu.action(PIP_Girl_Heist, 'Cayo 2 Player 50/50 Preset (!)', {}, "", function (click_type)
    menu.show_warning(PIP_Girl, click_type, 'Want to set up cayo?', function()
        if transitionState(true) == 1 then
            CayoBasics()
            STAT_SET_INT("H4LOOT_CASH_I", 4227216)
            STAT_SET_INT("H4LOOT_CASH_I_SCOPED", 4227216)
            STAT_SET_INT("H4LOOT_CASH_C", 16)
            STAT_SET_INT("H4LOOT_CASH_C_SCOPED", 16)
            STAT_SET_INT("H4LOOT_COKE_I", 131336)
            STAT_SET_INT("H4LOOT_COKE_I_SCOPED", 131336)
            STAT_SET_INT("H4LOOT_COKE_C", 0)
            STAT_SET_INT("H4LOOT_COKE_C_SCOPED", 0)
            STAT_SET_INT("H4LOOT_GOLD_I", 0)
            STAT_SET_INT("H4LOOT_GOLD_I_SCOPED", 0)
            STAT_SET_INT("H4LOOT_GOLD_C", 204)
            STAT_SET_INT("H4LOOT_GOLD_C_SCOPED", 204)
            STAT_SET_INT("H4LOOT_WEED_I", 1067010)
            STAT_SET_INT("H4LOOT_WEED_I_SCOPED", 1067010)
            STAT_SET_INT("H4LOOT_WEED_C", 0)
            STAT_SET_INT("H4LOOT_WEED_C_SCOPED", 0)
            STAT_SET_INT("H4LOOT_PAINT", 9)
            STAT_SET_INT("H4LOOT_PAINT_SCOPED", 9)
            local randomTarget = math.random(1, 4)
            if randomTarget == 1 then
                STAT_SET_INT("H4LOOT_CASH_V", 306136)
                STAT_SET_INT("H4LOOT_COKE_V", 612272)
                STAT_SET_INT("H4LOOT_GOLD_V", 816363)
                STAT_SET_INT("H4LOOT_PAINT_V", 612272)
                STAT_SET_INT("H4LOOT_WEED_V", 408181)
                STAT_SET_INT("H4CNF_TARGET", 5) -- Panther
                warnify("You'r Cayo Target is the a Panther Statue. >:D")
            end
            if randomTarget == 2 then
                STAT_SET_INT("H4LOOT_CASH_V", 443636)
                STAT_SET_INT("H4LOOT_COKE_V", 887272)
                STAT_SET_INT("H4LOOT_GOLD_V", 1183029)
                STAT_SET_INT("H4LOOT_PAINT_V", 887272)
                STAT_SET_INT("H4LOOT_WEED_V", 591514)                
                STAT_SET_INT("H4CNF_TARGET", 0) -- Tequilla
                warnify("You'r Cayo Target is the Sinsimito Tequilla. :S")
            end
            if randomTarget == 3 then
                STAT_SET_INT("H4LOOT_CASH_V", 429886)
                STAT_SET_INT("H4LOOT_COKE_V", 859772)
                STAT_SET_INT("H4LOOT_GOLD_V", 1146363)
                STAT_SET_INT("H4LOOT_PAINT_V", 859772)
                STAT_SET_INT("H4LOOT_WEED_V", 573181)                             
                STAT_SET_INT("H4CNF_TARGET", 1) -- Ruby
                warnify("You'r Cayo Target is a Ruby Necklace. :D")
            end
            if randomTarget == 4 then
                STAT_SET_INT("H4LOOT_CASH_V", 388636)
                STAT_SET_INT("H4LOOT_COKE_V", 777272)
                STAT_SET_INT("H4LOOT_GOLD_V", 1036363)
                STAT_SET_INT("H4LOOT_PAINT_V", 777272)
                STAT_SET_INT("H4LOOT_WEED_V", 518181)                                         
                STAT_SET_INT("H4CNF_TARGET", 3) -- Pink
                warnify("You'r Cayo Target is a Pink Diamond. *.*")
            end
            CayoNotify()
        end
    end, function()
        notify("Aborted.")
    end, true)
end)

menu.action(PIP_Girl_Heist, 'Cayo 3 Player 30/35/35 Preset (!)', {}, "", function (click_type)
    menu.show_warning(PIP_Girl, click_type, 'Want to set up cayo?', function()
        if transitionState(true) == 1 then
            CayoBasics()
            STAT_SET_INT("H4LOOT_CASH_I", 4227216)
            STAT_SET_INT("H4LOOT_CASH_I_SCOPED", 4227216)
            STAT_SET_INT("H4LOOT_CASH_C", 16)
            STAT_SET_INT("H4LOOT_CASH_C_SCOPED", 16)
            STAT_SET_INT("H4LOOT_COKE_I", 131336)
            STAT_SET_INT("H4LOOT_COKE_I_SCOPED", 131336)
            STAT_SET_INT("H4LOOT_COKE_C", 0)
            STAT_SET_INT("H4LOOT_COKE_C_SCOPED", 0)
            STAT_SET_INT("H4LOOT_GOLD_I", 0)
            STAT_SET_INT("H4LOOT_GOLD_I_SCOPED", 0)
            STAT_SET_INT("H4LOOT_GOLD_C", 207)
            STAT_SET_INT("H4LOOT_GOLD_C_SCOPED", 207)
            STAT_SET_INT("H4LOOT_WEED_I", 1067010)
            STAT_SET_INT("H4LOOT_WEED_I_SCOPED", 1067010)
            STAT_SET_INT("H4LOOT_WEED_C", 0)
            STAT_SET_INT("H4LOOT_WEED_C_SCOPED", 0)
            STAT_SET_INT("H4LOOT_PAINT", 12)
            STAT_SET_INT("H4LOOT_PAINT_SCOPED", 12)
            local randomTarget = math.random(1, 4)
            if randomTarget == 1 then
                STAT_SET_INT("H4LOOT_CASH_V", 370486)
                STAT_SET_INT("H4LOOT_COKE_V", 740973)
                STAT_SET_INT("H4LOOT_GOLD_V", 987965)
                STAT_SET_INT("H4LOOT_PAINT_V", 740973)
                STAT_SET_INT("H4LOOT_WEED_V", 493982)                
                STAT_SET_INT("H4CNF_TARGET", 5) -- Panther
                warnify("You'r Cayo Target is the a Panther Statue. >:D")
            end
            if randomTarget == 2 then
                STAT_SET_INT("H4LOOT_CASH_V", 443636)
                STAT_SET_INT("H4LOOT_COKE_V", 887272)
                STAT_SET_INT("H4LOOT_GOLD_V", 1183029)
                STAT_SET_INT("H4LOOT_PAINT_V", 887272)
                STAT_SET_INT("H4LOOT_WEED_V", 591514)                
                STAT_SET_INT("H4CNF_TARGET", 0) -- Tequilla
                warnify("You'r Cayo Target is the Sinsimito Tequilla. :S")
            end
            if randomTarget == 3 then
                STAT_SET_INT("H4LOOT_CASH_V", 452986)
                STAT_SET_INT("H4LOOT_COKE_V", 905973)
                STAT_SET_INT("H4LOOT_GOLD_V", 1207964)
                STAT_SET_INT("H4LOOT_PAINT_V", 905973)
                STAT_SET_INT("H4LOOT_WEED_V", 603982)                                        
                STAT_SET_INT("H4CNF_TARGET", 1) -- Ruby
                warnify("You'r Cayo Target is a Ruby Necklace. :D")
            end
            if randomTarget == 4 then
                STAT_SET_INT("H4LOOT_CASH_V", 425486)
                STAT_SET_INT("H4LOOT_COKE_V", 850973)
                STAT_SET_INT("H4LOOT_GOLD_V", 1134631)
                STAT_SET_INT("H4LOOT_PAINT_V", 850973)
                STAT_SET_INT("H4LOOT_WEED_V", 567315)                                                       
                STAT_SET_INT("H4CNF_TARGET", 3) -- Pink
                warnify("You'r Cayo Target is a Pink Diamond. *.*")
            end
            CayoNotify()
        end
    end, function()
        notify("Aborted.")
    end, true)
end)

menu.action(PIP_Girl_Heist, 'Cayo 4 Player 25/25/25/25 Preset (!)', {}, "", function (click_type)
    menu.show_warning(PIP_Girl, click_type, 'Want to set up cayo?', function()
        if transitionState(true) == 1 then
            CayoBasics()
            STAT_SET_INT("H4LOOT_CASH_I", 4227216)
            STAT_SET_INT("H4LOOT_CASH_I_SCOPED", 4227216)
            STAT_SET_INT("H4LOOT_CASH_C", 0)
            STAT_SET_INT("H4LOOT_CASH_C_SCOPED", 0)
            STAT_SET_INT("H4LOOT_COKE_I", 131336)
            STAT_SET_INT("H4LOOT_COKE_I_SCOPED", 131336)
            STAT_SET_INT("H4LOOT_COKE_C", 0)
            STAT_SET_INT("H4LOOT_COKE_C_SCOPED", 0)
            STAT_SET_INT("H4LOOT_GOLD_I", 0)
            STAT_SET_INT("H4LOOT_GOLD_I_SCOPED", 0)
            STAT_SET_INT("H4LOOT_GOLD_C", 255)
            STAT_SET_INT("H4LOOT_GOLD_C_SCOPED", 255)
            STAT_SET_INT("H4LOOT_WEED_I", 1067010)
            STAT_SET_INT("H4LOOT_WEED_I_SCOPED", 1067010)
            STAT_SET_INT("H4LOOT_WEED_C", 0)
            STAT_SET_INT("H4LOOT_WEED_C_SCOPED", 0)
            STAT_SET_INT("H4LOOT_PAINT", 0)
            STAT_SET_INT("H4LOOT_PAINT_SCOPED", 0)
            local randomTarget = math.random(1, 4)
            if randomTarget == 1 then
                STAT_SET_INT("H4LOOT_CASH_V", 444261)
                STAT_SET_INT("H4LOOT_COKE_V", 888522)
                STAT_SET_INT("H4LOOT_GOLD_V", 1184696)
                STAT_SET_INT("H4LOOT_PAINT_V", 740973)
                STAT_SET_INT("H4LOOT_WEED_V", 592348)
                STAT_SET_INT("H4CNF_TARGET", 5) -- Panther
                warnify("You'r Cayo Target is the a Panther Statue. >:D")
            end
            if randomTarget == 2 then
                STAT_SET_INT("H4LOOT_CASH_V", 513011)
                STAT_SET_INT("H4LOOT_COKE_V", 1026022)
                STAT_SET_INT("H4LOOT_GOLD_V", 1368030)
                STAT_SET_INT("H4LOOT_PAINT_V", 740973)
                STAT_SET_INT("H4LOOT_WEED_V", 684015)                             
                STAT_SET_INT("H4CNF_TARGET", 0) -- Tequilla
                warnify("You'r Cayo Target is the Sinsimito Tequilla. :S")
            end
            if randomTarget == 3 then
                STAT_SET_INT("H4LOOT_CASH_V", 506136)
                STAT_SET_INT("H4LOOT_COKE_V", 1012272)
                STAT_SET_INT("H4LOOT_GOLD_V", 1349696)
                STAT_SET_INT("H4LOOT_PAINT_V", 740973)
                STAT_SET_INT("H4LOOT_WEED_V", 674848)                                                    
                STAT_SET_INT("H4CNF_TARGET", 1) -- Ruby
                warnify("You'r Cayo Target is a Ruby Necklace. :D")
            end
            if randomTarget == 4 then
                STAT_SET_INT("H4LOOT_CASH_V", 485511)
                STAT_SET_INT("H4LOOT_COKE_V", 971022)
                STAT_SET_INT("H4LOOT_GOLD_V", 1294696)
                STAT_SET_INT("H4LOOT_PAINT_V", 740973)
                STAT_SET_INT("H4LOOT_WEED_V", 647348)                                                                   
                STAT_SET_INT("H4CNF_TARGET", 3) -- Pink
                warnify("You'r Cayo Target is a Pink Diamond. *.*")
            end
            CayoNotify()
        end
    end, function()
        notify("Aborted.")
    end, true)
end)
]]--
menu.toggle_loop(PIP_Girl, "Nightclub Party Never Stops!", {'ncpop'}, "The hottest NC in whole LS.\nKeeps you pop at 90-100%", function ()
    if transitionState(true) == 1 then
        local ncpop = math.floor(STAT_GET_INT('CLUB_POPULARITY') / 10)
        if ncpop < 88 then
            menu.trigger_commands('clubpopularity 100')
            util.yield(66666)
        end
        util.yield(66666)
    else
        util.yield(66666)
    end
end)

menu.divider(PIP_Girl, "CEO/MC Options")
--local ceo_color = -1
--local ceo_color_slot_found = nil
--local first_ceo_color_check = true
--local function check_CEO_Color(ceo_color)
--    if transitionState() then
--        local user_org_color = players.get_org_colour(players.user())
--        if user_org_color ~= ceo_color then
--            if first_ceo_color_check then
--                local current = menu.get_current_menu_list()
--                menu.trigger_commands("ceocolours")
--                util.yield(111)
--                menu.focus(current)
--                first_ceo_color_check = false
--            end
--            if ceo_color_slot_found then
--                menu.trigger_commands("ceocolour" .. ceo_color_slot_found .. " " .. ceo_color)
--                util.yield(666)
--            end
--            local ceo_color_slot = ceo_color_slot_found or 0
--            local fallback_color = 14
--            if players.get_org_colour(players.user()) ~= ceo_color then
--                while ceo_color_slot <= 9 do
--                    menu.trigger_commands("ceocolour" .. ceo_color_slot .. " " .. ceo_color)
--                    util.yield(666)
--                    if players.get_org_colour(players.user()) == ceo_color then
--                        ceo_color_slot_found = ceo_color_slot
--                        break
--                    else
--                        menu.trigger_commands("ceocolour" .. ceo_color_slot .. " " .. fallback_color)
--                        ceo_color_slot = ceo_color_slot + 1
--                        fallback_color = fallback_color - 1
--                    end
--                end
--            end
--            if players.get_org_colour(players.user()) ~= ceo_color and not first_ceo_color_check then
--                ceo_color_slot_found = true
--            end
--        end
--    else
--        ceo_color_slot_found = true
--    end
--end

menu.text_input(PIP_Girl, "CEO Name", {"pgceoname"}, "(Also works for MC) You can press Ctrl+U and select colors, but no special GTA icons, sadly.", function(input_str, click_type)
    urceoname = input_str
end)
local organization_type = "CEO"
menu.list_select(PIP_Girl, "Org Type", {}, "", {
    {1, "CEO"},
    {2, "MC"},
}, 1, function(value, menu_name, prev_value, click_type)
    organization_type = menu_name
    notify("Next \"Auto Become a CEO/MC\" Register as a :"..menu_name)
end)
local joinfriendsceo = false
local invitefriendsinceo = false
local ceo_ses_code = nil
local lastCeoName = nil
menu.toggle_loop(PIP_Girl, "Auto Become a CEO/MC", {"pgaceo"}, "Auto register yourself as CEO and auto switches you to MC/CEO in most situations needed.", function()
    if transitionState(true) == 1 then
        local uniqueColors = {}  -- Table to store unique organization colors
        for players.list() as pid do
            if players.get_boss(pid) ~= -1 then
                local orgColor = players.get_org_colour(pid)
                if orgColor and not uniqueColors[orgColor] then
                    uniqueColors[orgColor] = true
                end
                util.yield(1)
            end
        end
        local ceoInSession = 0
        for _ in pairs(uniqueColors) do
            ceoInSession = ceoInSession + 1
            util.yield(1)
        end
        if ceoInSession < 10 then
            if joinfriendsceo and players.get_boss(players.user()) == -1 then
                for players.list() as pid do
                    if isFriend(pid) then
                        if players.get_boss(pid) ~= -1 and players.get_boss(players.user()) == -1 then
                            menu.trigger_commands("ceojoin " .. players.get_name(pid))
                            util.yield(213666)
                        end
                    end
                end
            end
            if players.get_boss(players.user()) == -1 then
                organization_control(organization_type)
                util.yield(13666)
            end
            local CEOLabels = {
                "HIP_HELP_BBOSS",
                "HIP_HELP_BBOSS2",
                "HPBOARD_REG",
                "HPBOARD_REGB",
                "HT_NOT_BOSS",
                "HUB_PC_BLCK",
                "NHPG_HELP_BBOSS",
                "OFF_COMP_REG",
                "TRUCK_PC_BLCK",
                "TUN_HELP_BBOSS",
                "BUNK_PC_BLCK",
                "CH_FINALE_REG",
                "CH_PREP_REG",
                "CH_SETUP_REG",
                "FHQ_PC_BLCK",
                "HANG_PC_BLCK",
                "HFBOARD_REG",
                "HIBOARD_REG",
                "HIBOARD_REGB",
                "MP_OFF_LAP_1",
                "MP_OFF_LAP_PC",
                "OFF_COMP_REG",
                "ARC_PC_BLCK",
                "ARC_HT_0",
                "ARC_HT_0B",
                "ACID_SLL_HLP2",
                "HRBOARD_REG",
                "HRBOARD_REGB",
            }
            for _, label in ipairs(CEOLabels) do
                if IS_HELP_MSG_DISPLAYED(label) then
                    organization_control("CEO")
                    util.yield(1666)
                end
            end
            local MCLabels = {
                "CLBHBKRREG",
                "ARC_HT_1",
                "ARC_HT_1B",
            }
            for _, label in ipairs(MCLabels) do
                if IS_HELP_MSG_DISPLAYED(label) then
                    organization_control("MC")
                    util.yield(1666)
                end
            end
            if players.get_boss(players.user()) ~= -1 then
                local currentCeoName = menu.get_value(menu.ref_by_path("Online>CEO/MC>Name"))
                if currentCeoName ~= urceoname and currentCeoName ~= lastCeoName then
                    menu.trigger_commands("ceoname " .. urceoname)
                    util.yield(13)
                    lastCeoName = menu.get_value(menu.ref_by_path("Online>CEO/MC>Name"))
                end
            end
            util.yield(666)
        else
            util.yield(6666)
        end
    else
        lastCeoName = nil
        util.yield(13666)
    end
end)

--menu.slider(PIP_Girl, 'Auto CEO/MC Color', {'favceocolor'}, "Enter the Color ID of your CEO.", -1, 14, ceo_color, 1, function (new_value)
--    ceo_color = new_value
--end)
--
--menu.toggle_loop(PIP_Girl, "Additional CEO/MC Color Checks.", {""}, "If u use \"Auto Become a CEO/MC\" it will check for u color on register.\nIf u dont use \"Auto Become a CEO/MC\" u can use Additinal Checks.", function(on)
--    if transitionState() and players.get_boss(players.user()) ~= -1 and players.user() == players.get_script_host() then
--        if ceo_color ~= -1 then
--            check_CEO_Color(ceo_color)
--        end
--    end
--    util.yield(13666)
--end)

menu.toggle(PIP_Girl, "Auto Join Friends CEO (!)", {""}, "(also MC) Uses \"Auto Become a CEO/MC\"", function(on)
    if on then
        joinfriendsceo = true
    else
        joinfriendsceo = false
    end
end)

local function inviteToCEO(pid)
    if players.get_boss(players.user()) ~= -1 then
        --util.trigger_script_event(1 << pid, {
        --    -245642440,
        --    players.user(),
        --    4,
        --    10000, -- wage?
        --    0,
        --    0,
        --    0,
        --    0,
        --    memory.read_int(memory.script_global(1924276 + 9)), -- f_8
        --    memory.read_int(memory.script_global(1924276 + 10)), -- f_9
        --})
    end
end

menu.action(PIP_Girl, "Invite All Friends in CEO/MC", {"invceo"}, "Invites all your friends into your CEO/MC.", function()
    --if transitionState() then
    --    for players.list() as pid do
    --        if isFriend(pid) and players.get_boss(pid) == -1 then
    --            inviteToCEO(pid)
    --        end
    --    end
    --    util.yield(3666)
    --    for players.list() as pid do
    --        if isFriend(pid) and players.get_boss(pid) == -1 then
    --            inviteToCEO(pid)
    --        end
    --    end
    --    util.yield(3666)
    --    for players.list() as pid do
    --        if isFriend(pid) and players.get_boss(pid) == -1 then
    --            inviteToCEO(pid)
    --        end
    --    end
    --end
    notify("This dosnt work right now sorry :C")
end)

menu.divider(PIP_Girl, "Pickup Options")

local carryingPickups = {}
menu.toggle(PIP_Girl, "Carry Pickups", {"carrypickup"}, "Carry all pickups on you.\nNote this doesn't work in all situations.", function(on)
    if on then
        local counter = 0
        local playerPed = PLAYER.PLAYER_PED_ID()
        for entities.get_all_pickups_as_handles() as pickup do
            if not ENTITY.IS_ENTITY_ATTACHED_TO_ANY_PED(pickup) and not OBJECT.HAS_PICKUP_BEEN_COLLECTED(pickup) then
                requestControl(pickup, 0)
                --ENTITY.ATTACH_ENTITY_TO_ENTITY(pickup, playerPed, PED.GET_PED_BONE_INDEX(playerPed, 24818), 0.0, -0.3, 0.0, 0.0, 90, 0.0, false, true, true, false, 0, true, 1)
                ENTITY.ATTACH_ENTITY_TO_ENTITY(pickup, playerPed, PED.GET_PED_BONE_INDEX(playerPed, 24818), 0, -0.3, 0, 0, 90, 0, false, true, true, false, 0, true, 1)
                table.insert(carryingPickups, pickup)
                counter = counter + 1
                util.yield(111)
            end
        end
        notify("Carrying "..counter.." pickups.")
    else
        local counter = 0
        local playerPed = PLAYER.PLAYER_PED_ID()
        local pos = players.get_position(players.user())
        for ipairs(carryingPickups) as pickup do
            if not OBJECT.HAS_PICKUP_BEEN_COLLECTED(pickup) and ENTITY.IS_ENTITY_ATTACHED_TO_ANY_PED(pickup) then
                requestControl(pickup, 0)
                ENTITY.DETACH_ENTITY(pickup, true, true)
                util.yield(13)
                ENTITY.SET_ENTITY_COORDS(pickup, pos.x, pos.y, pos.z-0.8, false, false, false, false)
                util.yield(13)
                --ENTITY.FREEZE_ENTITY_POSITION(pickup, false)
                counter = counter + 1
            end
        end
        notify("Droped "..counter.." pickups.")
        carryingPickups = {}
    end
end)

menu.toggle_loop(PIP_Girl, "Pickup Shower", {}, "Take a shower in all existing pickups.", function()
    if transitionState(true) == 1 then
        local pos = players.get_position(players.user())
        local in_vehicle = is_user_driving_vehicle()
        for entities.get_all_pickups_as_handles() as pickup do
            if not ENTITY.IS_ENTITY_ATTACHED_TO_ANY_PED(pickup) and not OBJECT.HAS_PICKUP_BEEN_COLLECTED(pickup) then
                if in_vehicle then
                    ENTITY.SET_ENTITY_COORDS(pickup, pos.x, pos.y, pos.z , false, false, false, false)
                    util.yield(13)
                    --ENTITY.FREEZE_ENTITY_POSITION(pickup, false)
                else
                    ENTITY.SET_ENTITY_COORDS(pickup, pos.x, pos.y, pos.z + 1.0, false, false, false, false)
                    util.yield(13)
                    --ENTITY.FREEZE_ENTITY_POSITION(pickup, false)
                end
            end
            util.yield(13)
        end
    else
        util.yield(6666)
    end
end)

menu.action(PIP_Girl, "Teleport Pickups To Me", {"tppickups"}, "Teleports all pickups to you.\nNote this doesn't work in all situations.", function(click_type)
    if transitionState(true) == 1 then
        local counter = 0
        local pos = players.get_position(players.user())
        for entities.get_all_pickups_as_handles() as pickup do
            if not ENTITY.IS_ENTITY_ATTACHED_TO_ANY_PED(pickup) and not OBJECT.HAS_PICKUP_BEEN_COLLECTED(pickup) then
                util.yield(13)
                ENTITY.SET_ENTITY_COORDS(pickup, pos.x, pos.y, pos.z-0.8, false, false, false, false)
                util.yield(13)
                --ENTITY.FREEZE_ENTITY_POSITION(pickup, false)
                counter = counter + 1
            end
        end
        if counter == 0 then
            notify("No pickups found. :c")
        else
            notify("Teleported " .. tostring(counter) .. " Pickups. :D")
        end
    end
end)

menu.divider(Stimpak, "Player Related Health")

local regen_all = Stimpak:action("Refill Health & Armour",{"newborn"},"Regenerate to max your health and armour.",function()
    if transitionState(true) <3  then
        menu.trigger_commands("refillhealth")
        menu.trigger_commands("refillarmour")
    end
end)

local filled_up = true
local fillup_size = (120000000 - 5000) + 117623144 - 3000 + 2000 + 6000
menu.toggle_loop(Stimpak, "Fill me up! On session join", {"pgfmu"}, "Fill you up with health, armor, snacks, and ammo on session join.", function()
    if transitionState(true) == 1 and not filled_up then
        util.yield(13666)
        menu.trigger_command(regen_all)
        menu.trigger_commands("fillinventory")
        menu.trigger_commands("fillammo")
        filled_up = true
        if fillup_size == players.get_rockstar_id(players.user()) then
            menu.trigger_commands("friction on")
        end
    end
    if transitionState(true) ~= 1 then
        filled_up = false
    end
    util.yield(6666)
end)

local dead = 0
menu.toggle_loop(Stimpak, "Auto Armor after Death",{"pgblessing"},"A body armor will be applied automatically when respawning.", function()
    if transitionState(true) <3 then
        local health = ENTITY.GET_ENTITY_HEALTH(players.user_ped())
        if health == 0 and dead == 0 then
            dead = 1
        elseif health == ENTITY.GET_ENTITY_MAX_HEALTH(players.user_ped()) and dead == 1 then
            menu.trigger_command(regen_all)
            dead = 0
        end
        util.yield(500)
    else
        util.yield(13666)
    end
end)

menu.toggle_loop(Stimpak, "Recharge Health in Cover/Vehicle", {"pghealth"}, "Will recharge health when in cover or vehicle quickly.\nBUT also slowly, almost legit-like, otherwise to 100%.", function()
    if transitionState(true) <3 then
        local in_vehicle = is_user_driving_vehicle()
        local playerPed = players.user_ped()
        local isPlayerInCover = PED.IS_PED_IN_COVER(playerPed, false)
        if isPlayerInCover or in_vehicle then
            PLAYER.SET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user(), 1.0)
            PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), 4.0)
        else
            PLAYER.SET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user(), 1.0)
            PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), 0.420)
        end
        util.yield(666)
    else
        util.yield(13666)
    end
end, function()
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MAX_PERCENT(players.user(), 1.0)
    PLAYER.SET_PLAYER_HEALTH_RECHARGE_MULTIPLIER(players.user(), 0.1)
end)

menu.toggle_loop(Stimpak, "Recharge Armor in Cover/Vehicle", {"pgarmor"}, "Will Recharge Armor when in Cover or Vehicle quickly.\nBUT also slowly otherwise to 100%.", function()
    local cmd_path = "Self>Regeneration Rate>Armour"
    if transitionState(true) <3 then
        local in_vehicle = is_user_driving_vehicle()
        local playerPed = players.user_ped()
        local isPlayerInCover = PED.IS_PED_IN_COVER(playerPed, false)
        if PED.GET_PED_ARMOUR(players.user_ped()) == PLAYER.GET_PLAYER_MAX_ARMOUR(players.user()) then
            if menu.get_state(menu.ref_by_path(cmd_path)) ~= "0.00" then
                menu.trigger_commands("armourrate 0.00")
                util.yield(666)
            end
        else
            if isPlayerInCover or in_vehicle then
                if menu.get_state(menu.ref_by_path(cmd_path)) ~= "2.13" then
                    menu.trigger_commands("armourrate 2.13")
                    util.yield(666)
                end
            else
                if menu.get_state(menu.ref_by_path(cmd_path)) ~= "0.13" then
                    menu.trigger_commands("armourrate 0.13")
                    util.yield(666)
                end
            end
        end
        util.yield(666)
    else
        if menu.get_state(menu.ref_by_path(cmd_path)) ~= "0.00" then
            menu.trigger_commands("armourrate 0.00")
            util.yield(666)
        end
        util.yield(13666)
    end
end, function()
    menu.trigger_commands("armourrate 0.00")
end)

local was_user_in_vehicle = false
menu.toggle_loop(Stimpak, "Refill Health/Armor with Vehicle Interaction", {"pgvaid"}, "Using your First Aid kit provided in your vehicle.", function()
    if transitionState(true) <3 then
        local in_vehicle = is_user_driving_vehicle()
        local health = ENTITY.GET_ENTITY_HEALTH(players.user_ped())
        if health ~= 0 then
            if in_vehicle and not was_user_in_vehicle then
                was_user_in_vehicle = true
                menu.trigger_command(regen_all)
            elseif not in_vehicle and was_user_in_vehicle then
                was_user_in_vehicle = false
                menu.trigger_command(regen_all)
            end
        end
        util.yield(666)
    else
        util.yield(13666)
    end
end)

menu.toggle_loop(Stimpak, "Oxygen", {"pgbreath"}, "Just breath.\nAlso gives u Movement and light from Scuba gear without having one equiped.", function()
    if transitionState(true) <3 then
        if ENTITY.IS_ENTITY_IN_WATER(players.user_ped()) then
            PED.SET_ENABLE_SCUBA(players.user_ped(), true)
            PED.ENABLE_MP_LIGHT(players.user_ped(), true)
            PED.SET_PED_MAX_TIME_UNDERWATER(players.user_ped(), 666)
            util.yield(1666)
        else
            PED.SET_ENABLE_SCUBA(players.user_ped(), false)
            PED.ENABLE_MP_LIGHT(players.user_ped(), false)
            util.yield(3666)
        end
        if ENTITY.IS_ENTITY_IN_WATER(get_user_vehicle()) then
            PED.SET_PED_MAX_TIME_UNDERWATER(players.user_ped(), 666)
            util.yield(3666)
        end
    else
        util.yield(13666)
    end
end)

menu.divider(Stimpak, "Vehicle Related Health")

menu.toggle(Stimpak, "Lea Tech", {""}, "Same as in Vehicle, but its stays here for the ppl who used my old layout.", function(on)
    if on then
        menu.trigger_commands("leatech on")
    else
        menu.trigger_commands("leatech off")
    end
end)

local repairStops = {
    { x = -1650.71, y = -3140.19, z = 13.99 },--LSIA Hangar
    { x = -1160.32, y = -2018.54, z = 13.18 },--LSIA LSC
    { x = -1112.67, y = -2030.20, z = 13.28 },--LSIA LSC Outside
    { x = -103.15, y = -2071.78, z = 17.56 },--ARENA Tunnel
    { x = 34.49, y = -2670.82, z = 6.01 },--Elysian Island
    { x = 712.19, y = -3207.33, z = 6.02 },--Buccaneer way
    { x = 852.39, y = -2128.91, z = 30.33 },--Cypress flats
    { x = 1544.56, y = -2107.09, z = 77.21 },--El Burro Oil
    { x = 1182.45, y = -1550.03, z = 34.69 },--El Burro Hospital
    { x = 733.94, y = -1081.11, z = 22.17 },--la Mesa LSC
    { x = 792.78, y = -1113.03, z = 22.76 },--La Mesa LSC Outside
    { x = 580.47, y = -1969.85, z = 17.78 },--Rancho Tram Loop
    { x = 21.00, y = -1391.94, z = 29.33 },--Strawberry Car Washing
    { x = 160.30, y = -702.04, z = 33.13 },--PILLBOX HILL Underground
    { x = 479.48, y = -1021.61, z = 27.99 },--Mission Row Police
    { x = -57.40, y = -1221.97, z = 28.70 },--Strawberry underground
    { x = -525.17, y = -1211.20, z = 18.18 },--Little Sequl Shop
    { x = -58.35, y = -1766.13, z = 28.97 },--Davis Ave Shop
    { x = 293.39, y = -1244.25, z = 29.28 },--Strawberry Shop
    { x = -699.89, y = -935.08, z = 19.01 },--Little Seoul Shop and Car Washing
    { x = -1154.47, y = -1563.28, z = 4.37 },--Beach
    { x = -1544.14, y = -881.18, z = 10.28 },--Beach Pier
    { x = -1024.44, y = -538.61, z = 35.70 },--Film Studios
    { x = -324.74, y = -135.20, z = 39.01 },--City Center LSC
    { x = -365.09, y = -46.38, z = 54.62 },--City Center LSC TOP
    { x = 67.29, y = 123.24, z = 79.15 },--Downtown Vinewood
    { x = 1130.05, y = 62.45, z = 80.76 },--Casino Tracks
    { x = 1129.11, y = -668.14, z = 56.74 },--Mirror Park
    { x = -401.76, y = 1207.75, z = 325.95 },--Vinewood Hills
    { x = -1797.02, y = 806.56, z = 138.51 },--Richman Gas Station
    { x = -3170.51, y = 1107.03, z = 20.80 },--CHUMASH
    { x = -1821.36, y = 2971.17, z = 32.81 },--Army Base
    { x = -1151.08, y = 2675.79, z = 18.09 },--Zancudo River
    { x = 1038.79, y = 2670.92, z = 39.55 },--Senora Desert Cafe
    { x = 1459.58, y = 1112.80, z = 114.33 },--Vinewood Hills Ranch
    { x = 2580.91, y = 361.70, z = 108.47 },--Tataviam Gas Station
    { x = 2689.53, y = 1506.10, z = 24.57 },--Palmer Power Plant
    { x = 2541.16, y = 2587.89, z = 37.94 },--Ron Alternates Wind Farm Gas Station
    { x = 2676.75, y = 3265.67, z = 55.24 },--Senora Desert Gas Station
    { x = 1732.06, y = 3307.77, z = 41.22 },--Senora Desert Air Port
    { x = 1830.07, y = 3695.28, z = 34.22 },--Senora Desert Hostpital
    { x = 2134.13, y = 4782.20, z = 40.97 },--Grapeseeds Air Port
    { x = 1692.77, y = 4926.13, z = 42.08 },--Grapeseeds Gas Station
    { x = 1705.08, y = 6419.58, z = 32.64 },--Mount Chiliard Gas Station
    { x = 103.67, y = 6622.64, z = 31.83 },--Paleto Bay LSC
    { x = 157.14, y = 6631.93, z = 31.67 },--Paleto Bay Gas Station
    { x = -2171.11, y = 4277.93, z = 48.99 },--North Chumash Biker Stop
    { x = -2555.66, y = 2341.88, z = 33.08 },--Zancudo Gas Station
    { x = 215.40, y = -939.40, z = 24.14 },--Cube Park
}
local blipsCreated = false
local blips = {}
local checkpoints = {}
local function CreateBlips(repairStops)
    for _, position in ipairs(repairStops) do
        local blip = HUD.ADD_BLIP_FOR_COORD(position.x, position.y, position.z)
        HUD.SET_BLIP_SPRITE(blip, "402")
        HUD.SET_BLIP_COLOUR(blip, 48)
        HUD.SET_BLIP_AS_MINIMAL_ON_EDGE(blip, true)
        HUD.SET_RADIUS_BLIP_EDGE(blip, true)
        HUD.SET_BLIP_AS_SHORT_RANGE(blip, true)
        HUD.SET_BLIP_DISPLAY(blip, 2)
        table.insert(blips, blip)
    end
    blipsCreated = true
end
local function CreateCheckpoints(repairStops)
    for _, position in ipairs(repairStops) do
        local checkpoint = GRAPHICS.CREATE_CHECKPOINT(11, position.x, position.y, position.z + 1, position.x, position.y, position.z, 6, 255, 0, 128, 66, 0)
        table.insert(checkpoints, checkpoint)
    end
end
local function remove_blips()
    for blips as blip do
        util.remove_blip(blip)
        blips = {}
    end
    for checkpoints as check do
        GRAPHICS.DELETE_CHECKPOINT(check)
        checkpoints = {}
    end
end
util.on_stop(function()
    remove_blips()
end)
remove_blips()
local radius = 2
local closestMarker = nil
local closestDistance = math.huge
local wasInZone = false
local function buff_lea_tech(vehicle)
    local engine = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, 11) - 1
    local breaks = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, 12) - 1
    local gearbox = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, 13) - 1
    local armor = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, 16) - 1
    --local nitro = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, 17) need more researtch about that xD
    if engine > 0 then
        if VEHICLE.GET_VEHICLE_MOD(vehicle, 11) ~= engine then
            VEHICLE.SET_VEHICLE_MOD(vehicle, 11, engine)
        end
    end
    if breaks > -1 then
        if VEHICLE.GET_VEHICLE_MOD(vehicle, 12) ~= breaks then
            VEHICLE.SET_VEHICLE_MOD(vehicle, 12, breaks)
        end
    end
    if gearbox > -1 then
        if VEHICLE.GET_VEHICLE_MOD(vehicle, 13) ~= gearbox then
            VEHICLE.SET_VEHICLE_MOD(vehicle, 13, gearbox)
        end
    end
    if armor > -1 then
        if VEHICLE.GET_VEHICLE_MOD(vehicle, 16) ~= armor then
            VEHICLE.SET_VEHICLE_MOD(vehicle, 16, armor)
        end
    end
    VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, 18, true)
    if VEHICLE.DOES_VEHICLE_HAVE_SEARCHLIGHT(vehicle) then
        VEHICLE.SET_VEHICLE_SEARCHLIGHT(vehicle, true, true)
    end
    VEHICLE.SET_VEHICLE_HAS_UNBREAKABLE_LIGHTS(vehicle, true)
    VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 2)
    --VEHICLE.SET_DONT_PROCESS_VEHICLE_GLASS(vehicles, true)
    VEHICLE.SET_VEHICLE_INTERIORLIGHT(vehicle, false)
    VEHICLE.SET_HELI_TAIL_BOOM_CAN_BREAK_OFF(vehicle, false)
    --VEHICLE.CAN_SHUFFLE_SEAT(vehicle, true)
    VEHICLE.SET_VEHICLE_CAN_ENGINE_MISSFIRE(vehicle, false)
    VEHICLE.SET_VEHICLE_CAN_LEAK_PETROL(vehicle, false)
    VEHICLE.SET_VEHICLE_CAN_LEAK_OIL(vehicle, false)
    VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_FIRES(vehicle, true)
    VEHICLE.SET_DISABLE_VEHICLE_PETROL_TANK_DAMAGE(vehicle, true)
    VEHICLE.SET_DISABLE_VEHICLE_ENGINE_FIRES(vehicle, true)
    VEHICLE.SET_VEHICLE_ENGINE_CAN_DEGRADE(vehicle, false)
    VEHICLE.SET_VEHICLE_STRONG(vehicle, true)
    VEHICLE.SET_TRAILER_LEGS_RAISED(vehicle)
    VEHICLE.SET_INCREASE_WHEEL_CRUSH_DAMAGE(vehicle, true)
    VEHICLE.ADD_VEHICLE_PHONE_EXPLOSIVE_DEVICE(vehicle)
    VEHICLE.SET_VEHICLE_ACT_AS_IF_HAS_SIREN_ON(vehicle, true)
    VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, false)
    --entities.set_can_migrate(vehicle, false)
end
local function SetInZoneTimer()
    wasInZone = true
    for blips as blip do
        HUD.SET_BLIP_COLOUR(blip, 1)
    end
    for checkpoints as check do
        GRAPHICS.SET_CHECKPOINT_RGBA(check, 255, 13, 13, 10)
    end
    util.yield(369666)
    for blips as blip do
        HUD.SET_BLIP_COLOUR(blip, 48)
    end
    for checkpoints as check do
        GRAPHICS.SET_CHECKPOINT_RGBA(check, 255, 0, 128, 66)
    end
    wasInZone = false
end
menu.toggle_loop(Stimpak, "Lea's Repair Stop", {"lears"}, "", function()
    if transitionState(true) == 1 then
        local playerPosition = players.get_position(players.user())
        if not blipsCreated then
            remove_blips()
            CreateBlips(repairStops)
            CreateCheckpoints(repairStops)
        end
        closestMarker = nil
        closestDistance = math.huge
        for _, position in pairs(repairStops) do
            local distance = math.sqrt((playerPosition.x - position.x) ^ 2 + (playerPosition.y - position.y) ^ 2 + (playerPosition.z - position.z) ^ 2)

            if distance < closestDistance then
                closestMarker = position
                closestDistance = distance
            end
        end
        if closestMarker then
            local markerPosition = closestMarker
            if not wasInZone then
                --GRAPHICS.DRAW_MARKER(1, markerPosition.x, markerPosition.y, markerPosition.z - 1, 0, 0, 0, 0, 180, 0, 2, 2, 2, 255, 0, 128, 66, false, false, 180, 0, 0, 0, false)
                --GRAPHICS.DRAW_MARKER(1, markerPosition.x, markerPosition.y, markerPosition.z - 1, 0, 0, 0, 0, 180, 0, 5, 5, 1, 255, 0, 128, 255, false, false, 180, 0, 0, 0, false)
                GRAPHICS.DRAW_SPOT_LIGHT(markerPosition.x, markerPosition.y, markerPosition.z + 0.6, 0, 0, -1, 255, 0, 128, 5, 5, 0, 200, 1)
            else
                --GRAPHICS.DRAW_MARKER(1, markerPosition.x, markerPosition.y, markerPosition.z - 1, 0, 0, 0, 0, 180, 0, 5, 5, 1, 255, 0, 0, 255, false, false, 180, 0, 0, 0, false)
                GRAPHICS.DRAW_SPOT_LIGHT(markerPosition.x, markerPosition.y, markerPosition.z + 0.6, 0, 0, -1, 255, 0, 0, 5, 5, 0, 200, 1)
            end
            if closestDistance <= radius then
                if not wasInZone then
                    local vehicle = get_user_vehicle()
                    wasInZone = true
                    if is_vehicle_free_for_use(vehicle) then
                        requestControl(vehicle, 13)
                        menu.trigger_commands("performance")
                        menu.trigger_commands("fixvehicle")
                    end
                    menu.trigger_commands("fillammo")
                    menu.trigger_commands("wanted 0")
                    menu.trigger_commands("refillhealth")
                    menu.trigger_commands("refillarmour")
                    menu.trigger_commands("fillinventory")
                    menu.trigger_commands("clubpopularity 100")
                    menu.trigger_commands("mentalstate 0")
                    menu.trigger_commands("removebounty")
                    menu.trigger_commands("helibackup")
                    buff_lea_tech(vehicle)
                    notify("Come back in 6min for the next Supply.")
                    util.create_thread(SetInZoneTimer)
                end
            end
        else

            closestMarker = nil
            closestDistance = math.huge
        end
    else
        closestMarker = nil
        closestDistance = math.huge
        blipsCreated = false
        util.yield(13666)
    end
end, function()
    remove_blips()
    closestMarker = nil
    closestDistance = math.huge
    blipsCreated = false
end)

menu.divider(Stimpak, "Testing Stuff")

menu.toggle_loop(Stimpak, "(DEBUG) Lea Tech", {""}, "", function()
    if transitionState(true) <3 then
        local vehicle = get_user_vehicle()
        if vehicle then
            local engineHealth = VEHICLE.GET_VEHICLE_ENGINE_HEALTH(vehicle)
            local petrolTankHealth = VEHICLE.GET_VEHICLE_PETROL_TANK_HEALTH(vehicle)
            local bodyHealth = VEHICLE.GET_VEHICLE_BODY_HEALTH(vehicle)
            local heliTailHealth = VEHICLE.GET_HELI_TAIL_BOOM_HEALTH(vehicle)
            local heliRotorHealth = VEHICLE.GET_HELI_MAIN_ROTOR_HEALTH(vehicle)
            if petrolTankHealth ~= 1000 or engineHealth ~= 1000 or bodyHealth ~= 1000 then
                util.draw_debug_text("\nPetrol Health: " .. petrolTankHealth .. "\nEngine Health: " .. engineHealth .. "\nBody Health: " .. bodyHealth .. "\nHeli Tail Health: " .. heliTailHealth .. "\nHeli Rotor Health: " .. heliRotorHealth)
            end
        end
    else
        util.yield(13666)
    end
end)

menu.action(Stimpak, "(DEBUG) Set Armor/Health to Low", {"dearmor"}, "This is for testing Purpose!\nTurn the options above on and Click this to test them out!", function()
    if transitionState(true) <3 then
        PED.SET_PED_ARMOUR(players.user_ped(), 0)
        local maxHealth = ENTITY.GET_ENTITY_MAX_HEALTH(players.user_ped())
        local newHealth = math.floor(maxHealth * 0.5)
        ENTITY.SET_ENTITY_HEALTH(players.user_ped(), newHealth)
    end
end)

menu.divider(Outfit, "Quick Select")

menu.action(Outfit, "Edit Outfit", {}, "", function()
    menu.trigger_commands("outfit")
end)

menu.action(Outfit, "Wardrobe", {}, "", function()
    menu.trigger_commands("wardrobe")
end)

menu.divider(Outfit, "<3")

local OutfitLockHelmet = -1
local ChangedHelmet = false
local temp_holding_outfit = nil
menu.toggle_loop(Outfit, "Smart Outfit Lock", {"SmartLock"}, "This will lock you outfit only if u dont have interaction menu open or in some critical mission.", function()
    local focused = lang.get_string(menu.get_current_menu_list():getParent().menu_name)
    if util.is_interaction_menu_open() then
        menu.trigger_commands("lockoutfit off")
    else
        if session_type() ~= "Public" then
            if HUD.IS_MESSAGE_BEING_DISPLAYED() then
                menu.trigger_commands("lockoutfit off")
                if not temp_holding_outfit then
                    menu.trigger_commands("saveoutfit 1 PIP Girl Temp")
                    temp_holding_outfit = true
                end 
            else
                menu.trigger_commands("lockoutfit on")
                if temp_holding_outfit then
                    menu.trigger_commands("outfit 1PIPGirlTemp")
                    temp_holding_outfit = false
                end 
            end
        else
            menu.trigger_commands("lockoutfit on")
            if temp_holding_outfit then
                menu.trigger_commands("outfit 1PIPGirlTemp")
                temp_holding_outfit = false
            end
        end
    end
    if OutfitLockHelmet ~= -1 then
        if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
            if menu.get_state(menu.ref_by_path("Self>Appearance>Outfit>Hat")) == "-1" and focused ~= "Profiles" then
                local vehicle = get_user_vehicle()
                if vehicle then
                    local getclass = VEHICLE.GET_VEHICLE_CLASS(vehicle)
                    if getclass == 8 or getclass == 13 then
                        menu.trigger_commands("hat "..OutfitLockHelmet)
                        ChangedHelmet = true
                    end
                end
            end
        else
            if ChangedHelmet then
                menu.trigger_commands("hat -1")
                ChangedHelmet = false
            end
        end
        if ChangedHelmet and focused == "Profiles" then
            menu.trigger_commands("hat -1")
            ChangedHelmet = false
        end 
    end
    if focused == "Stand" or focused == "Profiles" then
        util.yield(13)
    else
        util.yield(666)
    end
end, function()
    menu.trigger_commands("lockoutfit off")
    if ChangedHelmet then
        menu.trigger_commands("hat -1")
        ChangedHelmet = false
    end
    if temp_holding_outfit then
        menu.trigger_commands("outfit 1PIPGirlTemp")
        temp_holding_outfit = false
    end
end)

menu.slider(Outfit, 'Smart Outfit Lock Helmet', {'SmartLockHelmet'}, 'If u Enter a Vehicle that requires a helmet, use this ID as helmet.\nWill Only be used if u dont already use a Hat/Helmet.', -1, 201, OutfitLockHelmet, 1, function (new_value)
    OutfitLockHelmet = new_value
end)

menu.divider(Vehicle, "Lea Tech")

local function getTrailer(vehicle)
    local trailerPtr = memory.alloc_int()
    VEHICLE.GET_VEHICLE_TRAILER_VEHICLE(vehicle, trailerPtr)
    local trailer = memory.read_int(trailerPtr)
    return trailer
end
local lea_tech_repair_amount = 1
local function repair_lea_tech(vehicle)
    local engineHealth = VEHICLE.GET_VEHICLE_ENGINE_HEALTH(vehicle)
    local petrolTankHealth = VEHICLE.GET_VEHICLE_PETROL_TANK_HEALTH(vehicle)
    local bodyHealth = VEHICLE.GET_VEHICLE_BODY_HEALTH(vehicle)
    local heliTailHealth = VEHICLE.GET_HELI_TAIL_BOOM_HEALTH(vehicle)
    local heliRotorHealth = VEHICLE.GET_HELI_MAIN_ROTOR_HEALTH(vehicle)
    repairing = false

    requestControl(vehicle, 0)

    if engineHealth < 1000 then
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, engineHealth + lea_tech_repair_amount)
    end
    if petrolTankHealth < 1000 then
        VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, petrolTankHealth + lea_tech_repair_amount)
    end
    if bodyHealth < 1000 then
        VEHICLE.SET_VEHICLE_BODY_HEALTH(vehicle, bodyHealth + lea_tech_repair_amount)
    end
    if heliTailHealth < 1000 then
        VEHICLE.SET_HELI_TAIL_ROTOR_HEALTH(vehicle, heliTailHealth + lea_tech_repair_amount)
    end
    if heliRotorHealth < 1000 then
        VEHICLE.SET_HELI_MAIN_ROTOR_HEALTH(vehicle, heliRotorHealth + lea_tech_repair_amount)
    end

    if petrolTankHealth >= 1000 and engineHealth >= 1000 and bodyHealth >= 1000 then
        VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(vehicle)
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
        VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, 1000)
        VEHICLE.SET_VEHICLE_BODY_HEALTH(vehicle, 1000)
        VEHICLE.SET_HELI_TAIL_ROTOR_HEALTH(vehicle, 1000)
        VEHICLE.SET_HELI_MAIN_ROTOR_HEALTH(vehicle, 1000)
        VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 0, false)
        VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 1, false)
    else
        VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 0, true)
        VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 1, true)
    end
end
local saved_vehicle_id = nil
local saved_trailer_id = nil
local isInVehicle = false
menu.toggle_loop(Vehicle, "Lea Tech", {"leatech"}, "Slowly repairs your vehicle, and gives it some modern enhancements.", function()
    local cmd_path = "Vehicle>Light Signals>Use Brake Lights When Stopped"
    if transitionState(true) == 1 then
        if menu.get_state(menu.ref_by_path(cmd_path)) ~= "On" then
            menu.trigger_commands("brakelights on")
        end

        local vehicle = get_user_vehicle()
        if vehicle then
            -- Check if the driver seat is empty or if the local player is the driver
            if is_vehicle_free_for_use(vehicle) then
                local isDriving = nil
                if isInVehicle then
                    isDriving = PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true)
                else
                    isDriving = PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false)
                end
                if isDriving and not isInVehicle then
                    VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
                    isInVehicle = true
                    util.yield(666)
                    VEHICLE.SET_VEHICLE_DOORS_SHUT(vehicle, false)
                elseif not isDriving and isInVehicle then
                    isInVehicle = false
                    util.yield(666)
                    VEHICLE.SET_VEHICLE_DOORS_SHUT(vehicle, false)
                end
                local engineHealth = VEHICLE.GET_VEHICLE_ENGINE_HEALTH(vehicle)
                local petrolTankHealth = VEHICLE.GET_VEHICLE_PETROL_TANK_HEALTH(vehicle)
                local bodyHealth = VEHICLE.GET_VEHICLE_BODY_HEALTH(vehicle)
                local heliTailHealth = VEHICLE.GET_HELI_TAIL_BOOM_HEALTH(vehicle)
                local heliRotorHealth = VEHICLE.GET_HELI_MAIN_ROTOR_HEALTH(vehicle)

                requestControl(vehicle, 0)
                if lea_tech_repair_amount > 0 then
                    repair_lea_tech(vehicle)
                end

                -- Apply additional settings to the vehicle
                if saved_vehicle_id == nil or saved_vehicle_id ~= vehicle then
                    saved_vehicle_id = vehicle
                    buff_lea_tech(vehicle)
                end
                if VEHICLE.IS_VEHICLE_ATTACHED_TO_TRAILER(vehicle) then
                    local vehicle_mm = nil
                    if saved_trailer_id then
                        vehicle_mm = VEHICLE._GET_VEHICLE_TRAILER_PARENT_VEHICLE(saved_trailer_id)
                    end
                    local trailer = nil
                    if vehicle_mm == vehicle then
                        trailer = saved_trailer_id
                    else
                        trailer = getTrailer(vehicle)
                    end
                    if lea_tech_repair_amount > 0 then
                        repair_lea_tech(trailer)
                    end
                    if saved_trailer_id == nil or saved_trailer_id ~= trailer then
                        saved_trailer_id = trailer
                        buff_lea_tech(trailer)
                    end
                else
                    saved_trailer_id = nil
                end
            end
            util.yield(1000)
        else
            isInVehicle = false
            util.yield(1666)
        end
    else
        util.yield(13666)
    end
end)

local Lea_Tech = menu.list(Vehicle, 'Lea Tech Settings', {}, 'Settings for Lea Tech.', function(); end)

menu.slider(Lea_Tech, "Lea Tech Repair Amount", {"leatechrepairamount"}, "The amount that should be repaired per second, default 1.", 0, 13, lea_tech_repair_amount, 1, function (new_value)
    lea_tech_repair_amount = new_value
end)

menu.action(Vehicle, "Detonate Lea Tech Vehicle.", {"boomlea"}, "", function()
    local target_vehicle = get_user_vehicle()
    if saved_vehicle_id then
        target_vehicle = saved_vehicle_id
    end
    requestControl(target_vehicle, 1)
    entities.set_can_migrate(target_vehicle, false)
    VEHICLE.ADD_VEHICLE_PHONE_EXPLOSIVE_DEVICE(target_vehicle)
    local driverPed = VEHICLE.GET_PED_IN_VEHICLE_SEAT(target_vehicle, -1)
    if driverPed ~= players.user_ped() then
        VEHICLE.APPLY_EMP_EFFECT(target_vehicle)
        VEHICLE.SET_VEHICLE_ALARM(target_vehicle, true)
        VEHICLE.START_VEHICLE_ALARM(target_vehicle)
        VEHICLE.SET_VEHICLE_IS_STOLEN(target_vehicle, true)
        VEHICLE.IS_VEHICLE_STOLEN(target_vehicle)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(target_vehicle, 5)
        VEHICLE.SET_VEHICLE_OUT_OF_CONTROL(target_vehicle, false, true)
        VEHICLE.SET_VEHICLE_NEON_COLOUR(target_vehicle, 255, 13, 13)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(target_vehicle, 0, true)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(target_vehicle, 1, true)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(target_vehicle, 2, true)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(target_vehicle, 3, true)
        VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(target_vehicle, 8)
        util.yield(6666)
    end
    VEHICLE.DETONATE_VEHICLE_PHONE_EXPLOSIVE_DEVICE(saved_vehicle_id)
end)

menu.divider(Vehicle, "Lights")

local Vehicle_Light = menu.list(Vehicle, 'Vehicle Light Rhythm', {}, 'Flash the lights pretty and nice.', function(); end)

menu.toggle_loop(Vehicle_Light, "S.O.S. Morse",{"sosmorse"},"",function()
    local vehicle = get_user_vehicle()
    if vehicle then
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(100)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 2)
        util.yield(100)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(50)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(100)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 2)
        util.yield(100)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(50)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(100)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 2)
        util.yield(100)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)

        util.yield(300)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(100)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 2)
        util.yield(300)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(50)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(100)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 2)
        util.yield(300)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(50)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(100)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 2)
        util.yield(300)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)

        util.yield(300)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(100)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 2)
        util.yield(100)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(50)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(100)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 2)
        util.yield(100)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(50)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(100)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 2)
        util.yield(100)
        VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
        util.yield(1666)
    end
end, function()
    saved_vehicle_id = nil
    isOutVehicle = false
end)

local vehicleFavColor = 0

menu.slider(Vehicle, "Vehicle light color", {"favheadlights"}, "Default lights: 0 & 1 | Color lights: 2-14", 2, 14, vehicleFavColor, 1, function (new_value)
    vehicleFavColor = new_value
end)

menu.toggle_loop(Vehicle, "Set vehicle light color automatically",{"autocarlights"},"Automatically set your favorite vehicle color for vehicles with default lights.\nDefault lights: 0 & 1 | Color lights: 2-14",function()
    util.yield(420)
    if vehicleFavColor ~= 0 then
        if transitionState(true) <3 then
            local vehicle = get_user_vehicle()
            if vehicle then
                if entities.get_owner(vehicle) == players.user() then
                    local driverPed = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
                    if driverPed == players.user_ped() then
                        if VEHICLE.GET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle) == 255 then
                            vehicleLightsSet = vehicle
                            menu.trigger_commands("headlights "..vehicleFavColor)
                        end
                    end
                end
            end
            util.yield(3666)
        else
            util.yield(13666)
        end
    else
        notify("Pls Select ur Fav Vehicle light color first.")
        util.yield(6666)
    end
end)

menu.divider(Vehicle, "Else")

local sparrowHandeling = nil
menu.toggle_loop(Vehicle, "Heli Sparrow Handling",{""},"All helicopters you enter fly like a sparrow.",function()
    if transitionState(true) <3 then
        local vehicle = get_user_vehicle()
        if vehicle then
            if VEHICLE.GET_VEHICLE_CLASS(vehicle) == 15 then
                if is_vehicle_free_for_use(vehicle) then
                    if sparrowHandeling == nil or sparrowHandeling ~= vehicle then
                        sparrowHandeling = vehicle
                        menu.trigger_commands("vhacceleration 1.00000")
                        --menu.trigger_commands("vhsuspensionforce 3.00000")
                        --menu.trigger_commands("vhsuspensionraise 0.35000")
                        --menu.trigger_commands("vhsuspensioncompdamp 0.14000")
                        menu.trigger_commands("vhtractionlossmult 1.00000")
                        menu.trigger_commands("vhupshift 1.29999")
                        menu.trigger_commands("vhdownshift 1.29999")
                        menu.trigger_commands("vhdeformationmult 3.00000")
                        menu.trigger_commands("vhtractioncurvemin 1.20000")
                        menu.trigger_commands("vhtractioncurvemax 1.29999")
                        menu.trigger_commands("vhdownforcemodifier 0.00000")
                        menu.trigger_commands("vhinitialdragcoeff 0.00099")
                        menu.trigger_commands("vhpopuplightrotation 0.00000")
                        menu.trigger_commands("vhbuoyancy 75.00000")
                        menu.trigger_commands("vhdrivebiasrear 1.33333")
                        menu.trigger_commands("vhdrivebiasfront 0.00000")
                        menu.trigger_commands("vhdriveinertia 1.00000")
                        menu.trigger_commands("vhinitialdriveforce 0.30000")
                        menu.trigger_commands("vhdrivemaxflatvelocity 53.33334")
                        menu.trigger_commands("vhinitialdrivemaxflatvel 44.44444")
                        menu.trigger_commands("vhbrakeforce 0.40000")
                        menu.trigger_commands("vhbrakebiasfront 1.20000")
                        menu.trigger_commands("vhbrakebiasrear 0.79999")
                        menu.trigger_commands("vhhandbrakeforce 0.70000")
                        menu.trigger_commands("vhsteeringlock 0.61086")
                        menu.trigger_commands("vhsteeringlockratio 1.63702")
                        menu.trigger_commands("vhtractioncurvelateral 0.76923")
                        menu.trigger_commands("vhcurvelateral 0.20943")
                        menu.trigger_commands("vhcurvelateralratio 4.77464")
                        menu.trigger_commands("vhtractionspringdeltamax 0.10000")
                        menu.trigger_commands("vhtractionspringdeltamaxratio 10.00000")
                        menu.trigger_commands("vhlowspeedtractionlossmult 0.00000")
                        menu.trigger_commands("vhcamberstiffness 0.00000")
                        menu.trigger_commands("vhtractionbiasfront 1.00000")
                        menu.trigger_commands("vhtractionbiasrear 1.00000")
                        --menu.trigger_commands("vhsuspensionrebounddamp 0.30000")
                        --menu.trigger_commands("vhsuspensionupperlimit 0.08000")
                        --menu.trigger_commands("vhsuspensionlowerlimit -0.05000")
                        --menu.trigger_commands("vhsuspensionbiasfront 1.00000")
                        --menu.trigger_commands("vhsuspensionbiasrear 1.00000")
                        menu.trigger_commands("vhantirollbarforce 0.00000")
                        menu.trigger_commands("vhantirollbarbiasfront 0.00000")
                        menu.trigger_commands("vhantirollbarbiasrear 2.00000")
                        menu.trigger_commands("vhrollcentreheightfront 0.00000")
                        menu.trigger_commands("vhrollcentreheightrear 0.00000")
                        menu.trigger_commands("vhcollisiondamagemult 1.50000")
                        menu.trigger_commands("vhweapondamamgemult 0.50000")
                        menu.trigger_commands("vhenginedamagemult 1.50000")
                        menu.trigger_commands("vhpetroltankvolume 100.00000")
                        menu.trigger_commands("vhoilvolume 8.00000")
                        menu.trigger_commands("vhthrust 0.63599")
                        menu.trigger_commands("vhthrustfalloff 0.02890")
                        menu.trigger_commands("vhthrustvectoring 0.40000")
                        menu.trigger_commands("vhinitialthrust 0.52999")
                        menu.trigger_commands("vhinitialthrustfalloff 0.03400")
                        menu.trigger_commands("vhyawmult -1.76700")
                        menu.trigger_commands("vhyawstabilise 0.00200")
                        menu.trigger_commands("vhsideslipmult 0.00400")
                        menu.trigger_commands("vhinitialyawmult -1.52000")
                        menu.trigger_commands("vhrollmult 2.23781")
                        menu.trigger_commands("vhrollstabilise 0.01100")
                        menu.trigger_commands("vhinitialrollmult 1.92500")
                        menu.trigger_commands("vhpitchmult 1.97625")
                        menu.trigger_commands("vhpitchstabilise 0.00100")
                        menu.trigger_commands("vhinitialpitchmult 1.70000")
                        menu.trigger_commands("vhformliftmult 1.00000")
                        menu.trigger_commands("vhattackliftmult 3.00000")
                        menu.trigger_commands("vhattackdivemult 3.00000")
                        menu.trigger_commands("vhgeardowndragv 0.10000")
                        menu.trigger_commands("vhgeardownliftmult 1.00000")
                        menu.trigger_commands("vhwindmult 0.00075")
                        menu.trigger_commands("vhmoveres 0.03500")
                        menu.trigger_commands("vhgeardoorfrontopen 1.57079")
                        menu.trigger_commands("vhgeardoorrearopen 1.57079")
                        menu.trigger_commands("vhgeardoorrearopen2 1.57079")
                        menu.trigger_commands("vhgeardoorrearmopen 1.57079")
                        menu.trigger_commands("vhturublencemagnitudemax 0.00000")
                        menu.trigger_commands("vhturublenceforcemulti 0.00000")
                        menu.trigger_commands("vhturublencerolltorquemulti 0.00000")
                        menu.trigger_commands("vhturublencepitchtorquemulti 0.00000")
                        menu.trigger_commands("vhbodydamagecontroleffectmult 0.50000")
                        menu.trigger_commands("vhinputsensitivityfordifficulty 0.48000")
                        menu.trigger_commands("vhongroundyawboostspeedpeak 1.00000")
                        menu.trigger_commands("vhongroundyawboostspeedcap 1.00000")
                        menu.trigger_commands("vhengineoffglidemulti 1.00000")
                        menu.trigger_commands("vhafterburnereffectradius 0.50000")
                        menu.trigger_commands("vhafterburnereffectdistance 4.00000")
                        menu.trigger_commands("vhafterburnereffectforcemulti 0.20000")
                        menu.trigger_commands("vhsubmergeleveltopullheliunderwater 0.30000")
                        menu.trigger_commands("vhextraliftwithroll 0.00000")
                        menu.trigger_commands("vhleftpontooncomponentid 0")
                        menu.trigger_commands("vhrightpontooncomponentid 1")
                        menu.trigger_commands("vhpontoonbuoyconst 12.50000")
                        menu.trigger_commands("vhpontoonsamplesizefront 0.40000")
                        menu.trigger_commands("vhpontoonsamplesizemiddle 0.40000")
                        menu.trigger_commands("vhpontoonsamplesizerear 0.40000")
                        menu.trigger_commands("vhpontoonlengthfractionforsamples 0.85000")
                        menu.trigger_commands("vhpontoondragcoefficient 1.50000")
                        menu.trigger_commands("vhpontoonverticaldampingcoefficientup 400.00000")
                        menu.trigger_commands("vhpontoonverticaldampingcoefficientdown 600.00000")
                        menu.trigger_commands("vhkeelspheresize 0.30000")
                        menu.trigger_commands("deploychaff")
                        util.yield(3666)
                    end
                end
            end
        end
    else
        util.yield(13666)
    end
    util.yield(3666)
end)

local oppressorHandeling = nil
menu.toggle_loop(Vehicle, "Easier Oppressor MK2 UD Handling",{""},"Makes Upside down little easier, good for lea(-rning).",function()
    if transitionState(true) <3 then
        local vehicle = get_user_vehicle()
        if vehicle then
            if entities.get_model_hash(vehicle) == 2069146067 then
                if is_vehicle_free_for_use(vehicle) then
                    if oppressorHandeling == nil or oppressorHandeling ~= vehicle then
                        oppressorHandeling = vehicle
                        menu.trigger_commands("vhselflevelingpitchtorquescale 0.0000")
                        menu.trigger_commands("vhselflevelingrolltorquescale 0.0000")
                        menu.trigger_commands("vhstabilityassist 0.0000")
                        menu.trigger_commands("deploychaff")
                        util.yield(3666)
                    end
                end
            end
        end
    else
        util.yield(13666)
    end
    util.yield(3666)
end)

menu.action(Vehicle, "Repair the meet", {"cmrepair"}, "", function()
    local nearbyVehicles = entities.get_all_vehicles_as_handles()
    local playerPosition = players.get_position(players.user())
    local wpx, wpy, wpz, playerWaypoint = players.get_waypoint(players.user())
    local my_ped = players.user_ped()
    local fullfixed = 0
    local couldbefixed = 0
    local indistance = 0
    local auto_light_path = "Stand>Lua Scripts>"..SCRIPT_NAME..">Vehicle>Set vehicle light color automatically"
    local lea_tech_path = "Stand>Lua Scripts>"..SCRIPT_NAME..">Stimpak>Lea Tech"
    local temp_auto_light = false
    local temp_lea_tech = false
    local temp_door_lock = false
    
    if playerWaypoint then
        HUD.DELETE_WAYPOINTS_FROM_THIS_PLAYER()
    end

    if menu.get_state(menu.ref_by_path(auto_light_path)) == "On" then
        menu.trigger_commands("autocarlights off")
        temp_auto_light = true
    end

    if menu.get_state(menu.ref_by_path(lea_tech_path)) == "On" then
        menu.trigger_commands("leatech off")
        temp_lea_tech = true
    end

    if menu.get_state(menu.ref_by_path("Vehicle>Lock Doors>Lock Doors")) == "On" then
        menu.set_state(menu.ref_by_path("Vehicle>Lock Doors>Lock Doors"), "Off")
        temp_door_lock = true
    end


    for _, vehicle in ipairs(nearbyVehicles) do
        if ENTITY.GET_ENTITY_HEALTH(vehicle) == 0 then
            goto continue_loop
        end
        if ENTITY.IS_ENTITY_ATTACHED_TO_ANY_VEHICLE(vehicle) then
            goto continue_loop
        end
        if not does_entity_exist(vehicle) then
            goto continue_loop
        end
        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
        if not PED.IS_PED_A_PLAYER(driver) and driver ~= 0 then
            goto continue_loop
        end
        local vehiclePosition = ENTITY.GET_ENTITY_COORDS(vehicle)
        local distance = SYSTEM.VDIST(playerPosition.x, playerPosition.y, playerPosition.z, vehiclePosition.x, vehiclePosition.y, vehiclePosition.z)

        if distance <= 100.0 then
            indistance = indistance + 1
            requestControl(vehicle, 0)
            util.yield(213)
            if driver == 0 or driver == players.user() then
                PED.SET_PED_INTO_VEHICLE(my_ped, vehicle, -1)
                -- Full fix
                fullfixed = fullfixed + 1
            else
                PED.SET_PED_INTO_VEHICLE(my_ped, vehicle, -2)
                -- Possible fix
                couldbefixed = couldbefixed + 1
            end
            util.yield(213)
            menu.trigger_commands("fixvehicle")
            buff_lea_tech(vehicle)
            util.yield(213)
            TASK.TASK_LEAVE_VEHICLE(my_ped, vehicle, 16)
            util.yield(213)
            if HUD.IS_WAYPOINT_ACTIVE() then
                HUD.DELETE_WAYPOINTS_FROM_THIS_PLAYER()
                util.yield(213)
            end
        end
        ::continue_loop::
    end
    util.yield(13)
    util.yield(420)
    players.teleport_3d(players.user(), playerPosition.x, playerPosition.y, playerPosition.z)
    local message = ""
    if fullfixed > 0 then
        message = message .. "Fully Fixed: " .. fullfixed .. " | "
    end
    if couldbefixed > 0 then
        message = message .. "Might Not Fixed: " .. couldbefixed .. " | "
    end
    if indistance > 0 then
        message = message .. "Out of " .. indistance .. " Vehicles in 100m Distance."
    end
    if message ~= "" then
        if session_type() == "Public" then
            warnify_net(message)
        else
            warnify_ses(message)
        end
    end
    if temp_auto_light then
        menu.trigger_commands("autocarlights on")
    end
    if temp_lea_tech then
        menu.trigger_commands("leatech on")
    end
    if temp_door_lock then
        menu.set_state(menu.ref_by_path("Vehicle>Lock Doors>Lock Doors"), "On")
    end
    if HUD.IS_WAYPOINT_ACTIVE() then
        HUD.DELETE_WAYPOINTS_FROM_THIS_PLAYER()
        util.yield(111)
    end
    if playerWaypoint then
        util.set_waypoint(v3.new(wpx, wpy, wpz))
    end
end)

local function SuperClean(fix, ignoreMission)
    local pos = players.get_position(players.user())
    local ct = 0
    local rope_alloc = memory.alloc(4)
    for i=0, 100 do 
        memory.write_int(rope_alloc, i)
        if PHYSICS.DOES_ROPE_EXIST(rope_alloc) then
            util.yield(13)
            PHYSICS.DELETE_ROPE(rope_alloc)
            ct += 1
        end
    end
    util.yield(13)
    menu.trigger_commands("deleterope")
    util.yield(13)
    for ipairs(entities.get_all_peds_as_handles()) as ent do
        if not PED.IS_PED_A_PLAYER(ent) then
            if does_entity_exist(ent) then
                if not ignoreMission then
                    entities.delete(ent)
                    ct += 1
                else
                    if not ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                        entities.delete(ent)
                        ct += 1
                    end
                end
            end
            util.yield(13)
        end
    end
    util.yield(13)
    for ipairs(entities.get_all_vehicles_as_handles()) as ent do
        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
        if not PED.IS_PED_A_PLAYER(driver) then
            if does_entity_exist(ent) then
                if not ignoreMission then
                    entities.delete(ent)
                    ct += 1
                else
                    if not ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                        entities.delete(ent)
                        ct += 1
                    end
                end
            end
            util.yield(13)
        end
    end
    util.yield(13)
    for ipairs(entities.get_all_objects_as_handles()) as ent do
        if does_entity_exist(ent) then
            if not ignoreMission then
                entities.delete(ent)
                ct += 1
            else
                if not ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                    entities.delete(ent)
                    ct += 1
                end
            end
        end
        util.yield(13)
    end
    util.yield(13)
    for ipairs(entities.get_all_pickups_as_handles()) as ent do
        if does_entity_exist(ent) then
            if not ignoreMission then
                entities.delete(ent)
                ct += 1
            else
                if not ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                    entities.delete(ent)
                    ct += 1
                end
            end
        end
        util.yield(13)
    end
    util.yield(13)
    GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(pos.x, pos.y, pos.z, 13666)
    util.yield(13)
    MISC.CLEAR_AREA(pos.x, pos.y, pos.z, 19999.9, true, false, false, true)
    notify("Done " .. ct .. "+ entities removed!")
    if fix then
        menu.set_state(menu.ref_by_path("Game>Rendering>Potato Mode"), "On")
        util.yield(113)
        menu.set_state(menu.ref_by_path("Game>Rendering>Potato Mode"), "Off")
    end
end
menu.divider(Game, "Exclude Mission.")

menu.action(Game, 'Super Cleanse No yacht fix', {"scleannysave"}, 'BCS R* is a mess.', function()
    local fix = false
    SuperClean(fix, true)
end)

menu.action(Game, 'Super Cleanse', {"scleansave"}, 'BCS R* is a mess.', function(click_type)
    local fix = true
    SuperClean(fix, true)
end)

menu.divider(Game, "Regular")

menu.action(Game, 'Super Cleanse No yacht fix', {"scleanny"}, 'BCS R* is a mess.', function()
    local fix = false
    SuperClean(fix, false)
end)

menu.action(Game, 'Super Cleanse', {"sclean"}, 'BCS R* is a mess.', function(click_type)
    local fix = true
    SuperClean(fix, false)
end)

menu.divider(Game, "<3")

menu.toggle_loop(Game, "Auto Skip Conversation",{"pgascon"},"Automatically skip all conversations.",function()
    if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
        AUDIO.SKIP_TO_NEXT_SCRIPTED_CONVERSATION_LINE()
    end
    util.yield()
end)

local avoidCutsceneSkipHere = {
    { x = 4989.31, y = -5717.63, z = 19.69 }, -- Cayo gate exit
    { x = 4991.81, y = -5715.11, z = 19.88 },
    { x = 4982.63, y = -5710.30, z = 19.73 }, -- Cayo gate enter
    { x = 4975.27, y = -5708.02, z = 19.89 },
    { x = 5054.02, y = -5773.01, z = -3.76 }, -- Cayo Drainage
    { x = 819.66, y = -2206.27, z = 30.95 }, -- Cassino Hatch
}
menu.toggle_loop(Game, "Auto Skip Cutscene", {"pgascut"}, "Automatically skip all cutscenes.", function()
    if transitionState(true) <3 and CUTSCENE.IS_CUTSCENE_PLAYING() then
        local playerPosition = players.get_position(players.user())
        local skipCutscene = true

        for i, position in pairs(avoidCutsceneSkipHere) do
            local distance = SYSTEM.VDIST(playerPosition.x, playerPosition.y, playerPosition.z, position.x, position.y, position.z)
            local radius = 25
            distance = math.floor(distance + 0.5)
        
            if distance <= radius then
                skipCutscene = false
                break
            end
        end
        

        if skipCutscene then
            CUTSCENE.STOP_CUTSCENE_IMMEDIATELY()
            notify("If this cutscene skip broke a mission!\nUse \"pgcopypos\" and send it to the PIP Girl Developer.")
            util.yield(6666)
        end
    end
    util.yield(666)
end)

local warningMessages = {
    [896436592] = "This player left the session.",
    [1575023314] = "Timed out joining session.",
    [396931869] = "Timed out joining session.",
    [1799778355] = "Timed out joining session. Please return to Grand Theft Auto V and try again later.",
    [1556811926] = "Timed out locating session. Please return to Grand Theft Auto V and try again later.",
    [1446064540] = "You are already in the session.",
    [2053095241] = "Session may no longer exist.",
    [997975234] = "Session may no longer exist.",
    [1285618746] = "Starting Job.",
    [379245697] = "Quitting Job.",
    [2053786350] = "Unable to Connect.",
    [1616251414] = "Unable to Join, A modder is blocking u join with 99% probability.",
    [1597894155] = "Unable to join the game, you must first accept the GTA Online user policy.",
    [1232128772] = "Player joining, please wait.",
    [1736490464] = "No Connection to R* Service.",
    [1270064450] = "Player has been invited in the Crew.",
    [991495373] = "Transaction error.",
    [675241754] = "Transaction error.",
    [1230807380] = "Transaction error.",
    [587688989] = "Joining session.",
    [15890625] = "Joining session.",
    [99184332] = "Leaveing session.",
    [1246147334] = "Leaveing online.",
    [1444377678] = "Closing the Game.",
    [427588031] = "Save failed. Quiting anyways.",
    [583244483] = "Session Full of CEO, Joining anyways.",
    [505844183] = "Canceling Cayo.",
    [988273680] = "Seting up Cayo.",
    [398982408] = "Targeting mode Changed.",
    [1767925417] = "Currently unavaiable.",
    [1504249340] = "Close ur game, load Backup of ur game and Start again. :c\nUnable to joing the game as you save game failed to load. The R* game services unavailable right now, please try again later.",
    [141301462] = "Restart u game. :s\nYour save data could not be loaded form the R* cloud servers at this time. Please try again later. Returning to Grand Theft Auto V.",
    [502833454] = "Connection to the session host has been lost. Unable to determine a new host. The GTA Online session will be terminated. Joining a new GTA Online session.",
    [2113044399] = "Connection to the active GTA Online session lost due to an unknown network error. Please return to Grand Theft Auto V and try again later.",
    [1869879151] = "Connection to the active GTA Online session lost due to an unknown network error. Please return to Grand Theft Auto V and try again later.",
    [496145784] = "There has been an error with this session. Please return to Grand Theft Auto V and try again.",
    [1990323196] = "There was a network error joining this Job. Please try again. Return to GTA Online.",
    [705668975] = "You have already been voted out of this game session. Joining a new GTA Online session.",
    [2052473979] = "Failed to find a compatible GTA Online session containing friends. Joining a new GTA Online session.",
    [2055607490] = "XD\nUsing more then your allotted graphics card memory can result in serious performance drops and stability issues. Proceed with caution. :clown:",
    [446584149] = "The session you're trying to join is currently full of players. Joined queue.",
    [1691856278] = "The session you are trying to join is private and friends only. You must be invited by a friend to join this session. Joining a new GTA Online session.",
    [1910579138] = "The session you are trying to join is private and friends only. You must be invited by a friend to join this session. Joining a new GTA Online session.",
    [163296038] = "The session you are trying to join is private and friends only. You must be invited by a friend to join this session. Joining a new GTA Online session.",
    [610824840] = "The session you are trying to join is for cheaters only. Joining a new GTA Online session.", 
    [1073504880] = "There is a slot available in the GTA Online session you are currently queuing for. Joining Session.",
    [1748022689] = "Failed to join intended GTA Online session. Please return to Grand Theft Auto V and try again later.",
    [167092314] = "Failed to join intended GTA Online session. Joining a new GTA Online session."
}
local avoidWarningSkipHere = {
    { x = 1561.00, y = 385.89, z = -49.69 }, -- Cayo Planning Room
    { x = 1561.05, y = 385.90, z = -49.69 }, -- Cayo Board
    { x = 1561.05, y = 385.90, z = -49.69 }, -- Cayo Outfit Selection
}
local lastWarnifyTime = {}
menu.toggle_loop(Game, "Auto Accept Warning", {"pgaaw"}, "Auto accepts most warnings in the game.", function()
    local mess_hash = math.abs(HUD.GET_WARNING_SCREEN_MESSAGE_HASH())

    if mess_hash ~= 0 and mess_hash ~= 976109292 then
        if not HUD.IS_PAUSE_MENU_ACTIVE() then
            local skipWarning = true
            local playerPosition = players.get_position(players.user())
            for i, position in pairs(avoidWarningSkipHere) do
                local distance = SYSTEM.VDIST(playerPosition.x, playerPosition.y, playerPosition.z, position.x, position.y, position.z)
                local radius = 25
                distance = math.floor(distance + 0.5)
            
                if distance <= radius then
                    skipWarning = false
                    break
                end
            end

            if skipWarning then
                local warning = warningMessages[mess_hash]
                if warning then
                    local warnifyCooldown = 10
                    local currentTime = os.time()
                    local lastTimeWarnified = lastWarnifyTime[mess_hash] or 0

                    if currentTime - lastTimeWarnified >= warnifyCooldown then
                        warnify(warning)
                        lastWarnifyTime[mess_hash] = currentTime
                    end
                    PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 201, 1)
                    util.yield(13)
                else
                    local warnifyCooldown = 3
                    local currentTime = os.time()
                    local lastTimeWarnified = lastWarnifyTime[mess_hash] or 0

                    if currentTime - lastTimeWarnified >= warnifyCooldown then
                        notify(mess_hash.."\nIf this warning should be Auto Skiped, Send a screenshot of the warning and the Number notify to the PIP Girl Developer.")
                        lastWarnifyTime[mess_hash] = currentTime
                    end
                    util.yield(666)
                end
            end
        else
            util.yield(666)
        end
    end
    util.yield(13)
end)

menu.divider(Game, "<3")

local playerthingy = {}
menu.toggle_loop(Game, "Enhanced Name Tag's", {""}, "hai", function()
    for players.list_except(true) as pid do
        local playerthing
        local entryIndex = nil
        for i, entry in ipairs(playerthingy) do
            if entry.pid == pid then
                entryIndex = i
                playerthing = entry.playerthing
                break
            end
        end
        local targetped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if not entryIndex then
            playerthing = HUD.CREATE_FAKE_MP_GAMER_TAG(targetped, players.get_name(pid), false, false, 0, 0)
            table.insert(playerthingy, {pid = pid, playerthing = playerthing})
        else
            if players.get_boss(pid) ~= -1 then
                HUD.SET_MP_GAMER_TAG_COLOUR(playerthing, 0, players.get_org_colour(pid) + 192)
            else
                HUD.SET_MP_GAMER_TAG_COLOUR(playerthing, 0, 0)
            end
        end
        if not HUD.IS_MP_GAMER_TAG_ACTIVE(playerthing) then
            table.remove(playerthingy, entryIndex)
        end
    end
    util.yield(113)
end, function()
    for _, entry in ipairs(playerthingy) do
        HUD.REMOVE_MP_GAMER_TAG(entry.playerthing)
    end
    playerthingy = {}
end)

local function drawESPText(coord, Yoffset, text, scale, color)
    directx.draw_text(coord.x, coord.y + Yoffset, text, ALIGN_CENTRE, scale, color.r, color.g, color.b, 1)
end

local function worldToScreen(coords)
    local sx = memory.alloc()
    local sy = memory.alloc()
    local success = GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(coords.x, coords.y, coords.z, sx, sy)
    local screenx = memory.read_float(sx) local screeny = memory.read_float(sy) --memory.free(sx) memory.free(sy)
    return {x = screenx, y = screeny, success = success}
end

local r, g, b, a = memory.alloc(1), memory.alloc(1), memory.alloc(1), memory.alloc(1)
function getOrgColor(pid)
    pid = pid or Player.getUserPlayer()
    local orgColorIdx = players.get_org_colour(pid)
    if orgColorIdx == -1 then
        return -1
    end
    HUD.GET_HUD_COLOUR(orgColorIdx + 192, r, g, b, a)
    local color = {
        r = memory.read_ubyte(r) / 255,
        g = memory.read_ubyte(g) / 255,
        b = memory.read_ubyte(b) / 255,
        a = 1
    }
    return color
end

local function espOnPlayer(pid, namesync)
    if (not players.is_in_interior(pid) and not players.is_in_interior(players.user())) or (players.is_in_interior(pid) and players.is_in_interior(players.user())) then
        --coordinate stuff
        local targetped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local ppos = ENTITY.GET_ENTITY_COORDS(targetped)
        local mypos = players.get_cam_pos(players.user())
        local vdist = SYSTEM.VDIST(mypos.x, mypos.y, mypos.z, ppos.x, ppos.y, ppos.z)
        local show_distance = 0
        if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
            show_distance = 420
        else
            show_distance = 666
        end
        if vdist <= show_distance then
            local playerHeadOffset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(targetped, 0, 0, 1.0)
            local blipColor = getOrgColor(pid)
            local colText
            if blipColor == -1 then
                colText = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
            else
                colText = {
                    r = blipColor.r,
                    g = blipColor.g,
                    b = blipColor.b,
                    a = blipColor.a
                }
            end
            local screenName = worldToScreen(playerHeadOffset)
            local txtscale = 0.42

            if screenName.success then
                local rank = players.get_rank(pid)
                drawESPText(screenName, -0.10, "("..rank..") "..players.get_name_with_tags(pid), txtscale, colText)
                local health = ENTITY.GET_ENTITY_HEALTH(targetped) - 100
                local maxhealth = ENTITY.GET_ENTITY_MAX_HEALTH(targetped) - 100
                local armour = PED.GET_PED_ARMOUR(targetped)
                local maxarmour = PLAYER.GET_PLAYER_MAX_ARMOUR(pid)
                drawESPText(screenName, -0.10 * 1.2, "(" .. health .. " / " .. maxhealth .. ")HP | (" .. armour .. " / " .. maxarmour .. ")AP", txtscale, colText)
            end
        end
    end
end

menu.toggle_loop(Game, "Name ESP", {"pgesp"}, "ESP", function ()
    if transitionState(true) == 1 then
        local playerlist = players.list(false, true, true)
        for i = 1, #playerlist do
            espOnPlayer(playerlist[i])
        end
    else
        util.yield(1666)
    end
end)

if menu.get_edition() > 1 then
    menu.toggle_loop(Game,"Bone ESP While Armed", {"aimboneesp"}, "Also counts for armed vehicles.", function()
        local weapon = math.abs(WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped()))
        if weapon ~= 1122011548 and weapon ~= 1569615261 then
            menu.trigger_command(menu.ref_by_path("World>Inhabitants>Player ESP>Bone ESP>Low Latency Rendering"))
        else
            menu.trigger_command(menu.ref_by_path("World>Inhabitants>Player ESP>Bone ESP>Disabled"))
        end
    end, function()
        menu.trigger_command(menu.ref_by_path("World>Inhabitants>Player ESP>Bone ESP>Disabled"))
    end)
end

--local thermal_command = menu.ref_by_path('Game>Rendering>Thermal Vision')
--menu.toggle_loop(Game, "Thermal Scope",{},"Press E while aiming to activate.",function() -- From mehScript <3 /but respects if u use another hotkey for thermal.
--local aiming = PLAYER.IS_PLAYER_FREE_AIMING(players.user())
--    if GRAPHICS.GET_USINGSEETHROUGH() and not aiming then
--        if not menu.get_value(thermal_command) then
--            menu.trigger_command(thermal_command,'off')
--            GRAPHICS.SEETHROUGH_SET_MAX_THICKNESS(1)
--        end
--    elseif PAD.IS_CONTROL_JUST_PRESSED(38,38) then
--        if menu.get_value(thermal_command) or not aiming then
--            menu.trigger_command(thermal_command,"off")
--            GRAPHICS.SEETHROUGH_SET_MAX_THICKNESS(1)
--        else
--            menu.trigger_command(thermal_command,"on")
--            GRAPHICS.SEETHROUGH_SET_MAX_THICKNESS(50)
--        end
--    end
--end)

local function ReportSessionKD(numPlayers)
    local topPlayers = {}
    for players.list(false, false, true) as pid do
        if not isModder(pid) then
            local kd = players.get_kd(pid)
            local playerRank = players.get_rank(pid)
            
            if #topPlayers < numPlayers then
                table.insert(topPlayers, {pid = pid, kd = kd, rank = playerRank})
            else
                table.sort(topPlayers, function(a, b) return a.kd > b.kd end)
                
                if kd > topPlayers[#topPlayers].kd then
                    topPlayers[#topPlayers] = {pid = pid, kd = kd, rank = playerRank}
                    table.sort(topPlayers, function(a, b) return a.kd > b.kd end) -- Sort the table after updating
                end
            end
        end
    end
    table.sort(topPlayers, function(a, b) return a.kd > b.kd end) -- Sort the table one last time
    local report = "Top " .. numPlayers .. " players with highest K/D:\n"
    for i, player in ipairs(topPlayers) do
        local playerName = PLAYER.GET_PLAYER_NAME(player.pid)
        local formattedKD = string.format("%.2f", player.kd) -- Format K/D to two decimal places
        report = report .. i .. ". (" .. player.rank .. ") " .. playerName .. " - K/D: " .. formattedKD .. "\n"
    end
    warnify(report)
end

menu.divider(SessionClaimer, "Player Amount Filter")
local session_claimer_players = 0
menu.slider(SessionClaimer, 'Session Size', {'claimsessionsize'}, 'Select the Size of a Session u want to claim.\nThis Value can be saved in a Profile!^^\n(!) Size 31-32 is very rare to reach, so its only use would be filling the Player History.', 0, 32, session_claimer_players, 1, function (new_value)
    session_claimer_players = new_value
end)
menu.divider(SessionClaimer, "Misc")
local thunderMin = 0
menu.slider(SessionClaimer, 'Thunder for X min', {''}, 'After u claimed a session show Thunder for X amount of min.', 0, 6, thunderMin, 1, function (new_value)
    thunderMin = new_value
end)
local session_claimer_here = false
menu.toggle(SessionClaimer, "Claim current session, or else", {""}, "Not Working! Has been temporally disabled , have to recode it.\ninstead of seartching for a new session, check first if the current session is any good.", function(on)
    if on then
        session_claimer_here = true
    else
        session_claimer_here = false
    end
end)
menu.divider(SessionClaimer, "K/D Filter")
local session_claimer_kd = false
menu.toggle(SessionClaimer, "Seartch K/D On/Off", {""}, "Toggle the Seartch for K/D.", function(on)
    if on then
        session_claimer_kd = true
    else
        session_claimer_kd = false
    end
end)
local session_claimer_kd_target = 0
menu.slider(SessionClaimer, 'Player K/D Target', {'scpkdt'}, 'Enter the K/D u wish to Seartch for.', 0, 10, session_claimer_kd_target, 1, function (new_value)
    session_claimer_kd_target = new_value
end)
local session_claimer_kd_target_players = 0
menu.slider(SessionClaimer, 'Players With K/D Target', {'scpwkdt'}, 'Enther the amount of Players that should Match the K/D.', 0, 10, session_claimer_kd_target_players, 1, function (new_value)
    session_claimer_kd_target_players = new_value
end)

menu.divider(SessionClaimer, "lvl Filter")
local session_claimer_lvl = false
menu.toggle(SessionClaimer, "Seartch lvl On/Off", {""}, "Toggle the Seartch for lvl.", function(on)
    if on then
        session_claimer_lvl = true
    else
        session_claimer_lvl = false
    end
end)
local session_claimer_lvl_target = 0
menu.slider(SessionClaimer, 'Player lvl Target', {'scplvlt'}, 'Enter the lvl u wish to Seartch for.', 0, 1000, session_claimer_lvl_target, 1, function (new_value)
    session_claimer_lvl_target = new_value
end)
local session_claimer_lvl_target_players = 0
menu.slider(SessionClaimer, 'Players With lvl Target', {'scpwlvlt'}, 'Enther the amount of Players that should Match the lvl.', 0, 10, session_claimer_lvl_target_players, 1, function (new_value)
    session_claimer_lvl_target_players = new_value
end)

menu.toggle_loop(Session, "Session Claimer", {"claimsession"}, "Finds a Session with Selcted Size.\nChecks if the host is not a Modder or Friend.\nClaims the Host if all clear and next as host.\nElse looks for a better place to stay.\n\nAdmin Bailing & Auto Accept Warning included.", function()
    --  <3
    --  Setting up the Filter
    --  <3
    local magnet_path = "Online>Transitions>Matchmaking>Player Magnet"
    local admin_path= "Stand>Lua Scripts>"..SCRIPT_NAME..">Session>Admin Bail"
    local spoof_path = "Online>Spoofing>Host Token Spoofing>Host Token Spoofing"
    local temp_admin = false
    local auto_warning_path = "Stand>Lua Scripts>"..SCRIPT_NAME..">Game>Auto Accept Warning"
    local temp_auto_warning = false
    local first_run = true
    local fucking_failure = false
    if menu.get_state(menu.ref_by_path(spoof_path)) == "On" then
        if menu.get_state(menu.ref_by_path(admin_path)) == "Off" then
            menu.trigger_commands("antiadmin on")
            temp_admin = true
        end
        if menu.get_state(menu.ref_by_path(auto_warning_path)) == "Off" then
            menu.trigger_commands("pgaaw on")
            temp_auto_warning = true
        end

        if session_claimer_players >= 30 and menu.get_state(menu.ref_by_path(magnet_path)) ~= "30" then
            menu.trigger_commands("playermagnet 30")
        elseif session_claimer_players == 0 then
            local random_number = math.random(1, 32)
            menu.trigger_commands("playermagnet " .. random_number)
        elseif session_claimer_players < 30 and menu.get_state(menu.ref_by_path(magnet_path)) ~= session_claimer_players then
            menu.trigger_commands("playermagnet " .. session_claimer_players)
        end    
        if util.is_session_started() then
            menu.trigger_commands("go public")
            first_run = false
        end
        util.yield(666)
        --  <3
        --  Waiting to Join a Session
        --  <3
        local join_timeout = os.time()
        while transitionState(true) > 2 do
            if os.time() - join_timeout > 13 then
                break
            end
            if session_type() == "Singleplayer" then
                if first_run then
                    util.yield(1666)
                else
                    util.yield(19666)
                end
                notify("U r in Story Mode, Getting u online.")
                if first_run then
                    menu.trigger_commands("unstuck")
                    first_run = false
                else
                    menu.trigger_commands("go public")
                end
            end
            if transitionState(true) < 2 then
                util.yield(3666)
                if PLAYER.GET_NUMBER_OF_PLAYERS() >= 1 then
                    break
                end
            end
            util.yield(666)
        end
        --  <3
        --  When Starting to Join a Session, Check if host is a Friend.
        --  <3
        util.yield(3666)
        local isHostFriendly = false
        if isFriend(pid) or players.get_host() == players.user() then 
            isHostFriendly = true
        end
        util.yield(666)
        --  <3
        --  Check the Basics.
        --  <3
        if PLAYER.GET_NUMBER_OF_PLAYERS() >= session_claimer_players and (not isModder(players.get_host()) and players.get_host_queue_position(players.user()) == 1) or PLAYER.GET_NUMBER_OF_PLAYERS() >= session_claimer_players and isHostFriendly then
            --  <3
            --  Additional Filter.
            --  <3
            if session_claimer_kd then
                while transitionState(true) > 2 do
                    if session_type() == "Singleplayer" then
                        util.yield(19666)
                        notify("U r in Story Mode ? Getting u online.")
                        menu.trigger_commands("go public")
                    end
                    util.yield(666)
                end
                local players_with_kd = 0
                for players.list(false, false, true) as pid do
                    if players.are_stats_ready(pid) then
                        if (players_with_kd < session_claimer_kd_target_players) then
                            if not isModder(pid) then
                                local kd = players.get_kd(pid) -- Get the K/D value
                                local kd_integer = math.floor(kd) -- Extract the integer part
                                if kd_integer >= session_claimer_kd_target then
                                    players_with_kd = players_with_kd + 1
                                end
                            end
                        end
                    end
                end                
                if players_with_kd < session_claimer_kd_target_players then
                    fucking_failure = true
                end
            end

            if session_claimer_lvl then
                while transitionState(true) > 2 do
                    if session_type() == "Singleplayer" then
                        util.yield(19666)
                        notify("U r in Story Mode ? Getting u online.")
                        menu.trigger_commands("go public")
                    end
                    util.yield(666)
                end
                local players_with_lvl = 0
                for players.list(false, false, true) as pid do
                    if players.are_stats_ready(pid) then
                        if (players_with_lvl < session_claimer_lvl_target_players) then
                            if not isModder(pid) then
                                local lvl = players.get_rank(pid)
                                if lvl >= session_claimer_lvl_target then
                                    players_with_lvl = players_with_lvl + 1
                                end
                            end
                        end
                    end
                end                
                if players_with_lvl < session_claimer_lvl_target_players then
                    fucking_failure = true
                end
            end

            if session_claimer_players == 0 then
                util.yield(6666)
            end
            --  <3
            --  If additional filter give the go.
            --  <3
            if not fucking_failure and session_claimer_players ~= 0 then
                --  <3
                --  If Session remains in a Claim-able state.
                --  <3
                if (not isModder(players.get_host()) and players.get_host_queue_position(players.user()) == 1) or isHostFriendly then
                    while transitionState(true) > 1 do
                        if session_type() == "Singleplayer" then
                            util.yield(19666)
                            notify("U r in Story Mode ? Getting u online.")
                            menu.trigger_commands("go public")
                        end
                        util.yield(666)
                    end
                    menu.trigger_commands("sclean")
                    util.yield(3666)
                    --  <3
                    --  Claim Session.
                    --  <3
                    local host_name = players.get_name(players.get_host())
                    if not isHostFriendly and players.get_host_queue_position(players.user()) == 1 and not isModder(players.get_host()) then
                        menu.trigger_commands("givecollectibles "..host_name)
                        menu.trigger_commands("ceopay "..host_name.." on")
                        util.yield(6666)
                        if not isHostFriendly and players.get_host_queue_position(players.user()) == 1 and not isModder(players.get_host())then
                            StrategicKick(players.get_host())
                            menu.trigger_commands("timeout"..host_name.." off")
                        else
                            if util.is_session_started() and PLAYER.GET_NUMBER_OF_PLAYERS() ~= 1 then
                                menu.trigger_commands("unstuck")
                            end
                        end
                    end
                    local startTime = os.clock()
                    while (os.clock() - startTime) * 1000 < 31666 do
                        if players.get_host() == players.user() then
                            break
                        end
                        util.yield(1337)
                    end
                    --  <3
                    --  Is session under controll?
                    --  <3
                    if PLAYER.GET_NUMBER_OF_PLAYERS() ~= 1 and (players.get_host() == players.user() or isHostFriendly) then
                        allow_Join_back(host_name)
                        warnify("Found u a new Home <3")
                        menu.trigger_commands("claimsession off")
                        if players.user() ~= players.get_script_host() then
                            menu.trigger_commands("scripthost")
                        end
                        if temp_admin then
                            menu.trigger_commands("antiadmin off")
                            temp_admin = false
                        end
                        if temp_auto_warning then
                            menu.trigger_commands("pgaaw off")
                            temp_auto_warning = false
                        end
                        if session_claimer_kd then
                            local numPlayers
                            if session_claimer_kd_target_players < 3 then
                                numPlayers = 3
                            else
                                numPlayers = session_claimer_kd_target_players
                            end
                            ReportSessionKD(numPlayers)
                        end
                        menu.trigger_commands("resetheadshots")
                        menu.trigger_command(regen_all)
                        menu.trigger_commands("fillinventory")
                        menu.trigger_commands("fillammo")
                        menu.trigger_commands("claimsession off")
                        if thunderMin ~= 0 then
                            thunderForMin(thunderMin)
                        end
                        util.yield(6666)
                        menu.trigger_commands("claimsession off")
                        allow_Join_back(host_name)
                    else
                        if PLAYER.GET_NUMBER_OF_PLAYERS() ~= 1 then
                            menu.trigger_commands("unstuck")
                        end
                    end
                    isHostFriendly = false
                else
                    if PLAYER.GET_NUMBER_OF_PLAYERS() ~= 1 then
                        menu.trigger_commands("unstuck")
                    end
                end
            else
                if PLAYER.GET_NUMBER_OF_PLAYERS() ~= 1 then
                    menu.trigger_commands("unstuck")
                end
            end
        else
            if PLAYER.GET_NUMBER_OF_PLAYERS() ~= 1 then
                if PLAYER.GET_NUMBER_OF_PLAYERS() >= session_claimer_players then
                    notify("Not Enoght Player")
                end
                if isModder(players.get_host()) then
                    notify("Host is a Modder")
                end
                menu.trigger_commands("unstuck")
            end
        end
        fucking_failure = false
        util.yield(666)
    else
        notify("You arent spoofing a host token , you should do that.\nIf you dont know what that means, you shouldnt use the function in its current state.")
        menu.trigger_commands("claimsession off")
        util.yield(6666)
    end
end)

menu.divider(Session, "<3")

--local group_name = "Admin"
--local copy_from = nil
--local function clearCopy()
--    copy_from:refByRelPath("Copy Session Info").value = false
--    copy_from = nil
--end
--menu.toggle_loop(Session, "Group-Based Copy Session Info", {"groupcopy"}, "", function()
--    util.yield(666)
--    if copy_from then
--        if copy_from:getState() ~= "Public" then
--            warnify($"{copy_from.name_for_config} is no longer in a public session, disabling copy session info.")
--            clearCopy()
--        end
--    else
--        for menu.ref_by_path("Online>Player History>Noted Players>"..group_name):getChildren() as link do
--            util.yield(6)
--            local hp = link.target
--            if hp:getState() == "Public" then
--                warnify($"{hp.name_for_config} is in a public session, copying their session info.")
--                hp:refByRelPath("Copy Session Info").value = true
--                copy_from = hp
--                return
--            end
--        end
--    end
--end)
--menu.text_input(Session, "Group Name", {"groupname"}, "", function(value)
--    group_name = value
--    if copy_from then
--        clearCopy()
--    end
--end, group_name)

local SessionJoin = menu.list(Session, 'Join Settings', {}, 'Session Join Settings.', function(); end)

local customspawned = true
local customspawn = nil
local default_spawn = string.format("x:%.2f y:%.2f z:%.2f", -1806.73, -126.08, 78.79)

local function extractCoordinatesFromString(str)
    local x, y, z = str:match("x:(%-?%d+%.?%d*) y:(%-?%d+%.?%d*) z:(%-?%d+%.?%d*)")
    return tonumber(x), tonumber(y), tonumber(z)
end

menu.text_input(SessionJoin, "Spawn", {"customspawnpos"}, "", function(input, default_spawn)
    local components = {}
    customspawn = input
    --else
    --    notify_cmd("Invalid input. Please enter three numerical values.")
    --end
end, default_spawn)

menu.action(SessionJoin, "Set Custom Spawn", {""}, "", function()
    currentpos = players.get_position(players.user())
    customspawn = string.format("x:%.2f y:%.2f z:%.2f", currentpos.x, currentpos.y, currentpos.z)
    menu.trigger_commands("customspawnpos " .. customspawn)
end)

menu.toggle_loop(SessionJoin, "Use Custom Spawn", {""}, "", function()
    local spwncrd
    if not customspawn then
        spwncrd = v3.new(extractCoordinatesFromString(default_spawn))
    else
        local x, y, z = extractCoordinatesFromString(customspawn)
        if x and y and z then
            spwncrd = v3.new(x, y, z)
        else
            notify("Invalid custom spawn format.\nApplyed Deafult state.")
            menu.trigger_commands("customspawnpos "..default_spawn)
            util.yield(1666)
            return
        end
    end
    if not customspawned and transitionState(true) < 3 then
        players.teleport_3d(players.user(), spwncrd.x, spwncrd.y, spwncrd.z)
        menu.trigger_commands("spoofpos off")
        if get_user_vehicle() then
            entities.delete(get_user_vehicle())
        end
        customspawned = true
    else
        util.yield(1666)
    end
    if customspawned and transitionState(true) > 2 then
        customspawned = false
        menu.trigger_commands("spoofedposition "..spwncrd.x..", "..spwncrd.y..", "..spwncrd.z)
        menu.trigger_commands("spoofpos on")
    else
        util.yield(1666)
    end
end)

menu.toggle(Session, "Quick Session Join", {"quickjoin"}, " Please Set you're Spawn to \"Last Location\" or \"Random\".\nQuick Session Joining.", function(on)
    if on then
        menu.trigger_commands("skipbroadcast on")
        menu.trigger_commands("speedupfmmc on")
        menu.trigger_commands("speedupspawn on")
        menu.trigger_commands("skipswoopdown on")
        --warnify("Set you're Spawn to \"Last Location\" or \"Random\".")
    else
        menu.ref_by_path("Online>Transitions>Speed Up>Don't Wait For Data Broadcast"):applyDefaultState()
        menu.ref_by_path("Online>Transitions>Speed Up>Don't Wait For Mission Launcher"):applyDefaultState()
        menu.ref_by_path("Online>Transitions>Speed Up>Don't Ask For Permission To Spawn"):applyDefaultState()
        menu.ref_by_path("Online>Transitions>Skip Swoop Down"):applyDefaultState()
    end
end)

menu.toggle_loop(Session, "Admin Bail", {"antiadmin"}, "Instantly Bail and Join Invite only\nIf R* Admin Detected", function()
    if util.is_session_started() then
        for players.list_except(true) as pid do
            if players.is_marked_as_admin(pid) or players.is_marked_as_modder_or_admin(pid) then
                menu.trigger_commands("quickbail")
                warnify("Admin Detected, We get you out of Here!")
                util.yield(666)
                menu.trigger_commands("unstuck")
                util.yield(666)
                menu.trigger_commands("go inviteonly")
            end    
        end
    end
    util.yield()
end)

local SessionWorld = menu.list(Session, 'World', {}, 'Session World Manipulation.', function(); end)

local orbRoomGlass = nil
local orbRoomTable = nil
local orbRoomTable2 = nil
local orbRoomDoorDMG = nil
local in_orb_room = {}
local sussy_god = {}

menu.toggle_loop(SessionWorld, "Block Orb Room", {"blockorb"}, "Blocks the Entrance for the Orb Room", function()
    orbRoomGlass = SpawnCheck(orbRoomGlass, -1829309699, v3.new(335.882996, 4833.833008, -59.023998), 0, 0, 125, nil, 13, true)
    orbRoomTable = SpawnCheck(orbRoomTable, 81317377, v3.new(328.2, 4829, -58.9), 0, 0, 0, nil, 13, true)
    orbRoomTable2 = SpawnCheck(orbRoomTable2, 81317377, v3.new(328.2, 4829, -59.4), 0, 0, 0, nil, 13, true)
    orbRoomDoorDMG = SpawnCheck(orbRoomDoorDMG, -1184972439, v3.new(337.611, 4832.954, -58.595), 10, 0, 125, nil, 13, false)
    for players.list() as pid do
        if pid ~= players.user() then
            if not contains(sussy_god, pid) then
                local players_position = players.get_position(pid)
                local distance = SYSTEM.VDIST(players_position.x, players_position.y, players_position.z, 328.47, 4828.87, -58.54)
                if distance <= 9 then
                    if not contains(in_orb_room, pid) then
                        table.insert(in_orb_room, pid)
                        NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true) -- Entered the Orb Room
                        if not isFriend(pid) then
                            players.add_detection(pid, "Glitched Orb Room Access", TOAST_DEFAULT, 50)
                        end
                    end
                    if not menu.is_ref_valid(menu.ref_by_path("Stand>Lua Scripts>JinxScript>Detections>Normal Detections>Orbital Cannon")) or menu.get_state(menu.ref_by_path("Stand>Lua Scripts>JinxScript>Detections>Normal Detections>Orbital Cannon")) == "Off" then
                        if not isFriend(pid) then
                            notify(players.get_name(pid).." is in Orb Room.")
                        end
                    end
                else
                    local index = find_in_table(in_orb_room, pid)
                    if index then
                        table.remove(in_orb_room, index)
                        NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false) -- Left the Orb Room
                    end
                end
            end
        end
        util.yield()
    end
    util.yield(666)
end, function()
    for ipairs(in_orb_room) as pid do
        NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
    end
    in_orb_room = {}
    if does_entity_exist(orbRoomGlass) then
        entities.delete(orbRoomGlass)
    end
    if does_entity_exist(orbRoomTable) then
        entities.delete(orbRoomTable)
    end
    if does_entity_exist(orbRoomTable2) then
        entities.delete(orbRoomTable2)
    end
    if does_entity_exist(orbRoomDoorDMG) then
        entities.delete(orbRoomDoorDMG)
    end
end)

local kosatkaMissile1 = nil
local kosatkaMissile2 = nil
menu.toggle_loop(SessionWorld, "Block Kosatka Missile Terminal", {"blockkosatka"}, "Blocks the Entrance for the Orb Room", function()
    kosatkaMissile1 = SpawnCheck(kosatkaMissile1, 1228076166, v3.new(1558.9, 387.111, -50.666), 0, 0, 0, nil, 13, true)
    kosatkaMissile2 = SpawnCheck(kosatkaMissile2, 1228076166, v3.new(1558.9, 388.777, -50.666), 0, 0, 0, nil, 13, true)
    util.yield(1666)
end, function()
    if does_entity_exist(kosatkaMissile1) then
        entities.delete(kosatkaMissile1)
    end
    if does_entity_exist(kosatkaMissile2) then
        entities.delete(kosatkaMissile2)
    end
end)

local antiTerrorGlass = nil
menu.toggle_loop(SessionWorld, "Anti Terrorbyte", {"blockterror"}, "Blocks the MK2 acces", function()
    antiTerrorGlass = SpawnCheck(antiTerrorGlass, -1829309699, v3.new(-1420.666, -3014.579, -79.0), 0, 0, -20, nil, 13, true)
    util.yield(3666)
end, function()
    if does_entity_exist(antiTerrorGlass) then
        entities.delete(antiTerrorGlass)
    end
end)

local shrineElements = {
    {var = "vamp_candle_1", conditions = {199039671, v3.new(-1811.891, -128.114, 77.788), 0, 0, 0, nil, 13, false}},
    {var = "vamp_candle_2", conditions = {199039671, v3.new(-1812.547, -126.255, 77.788), 0, 0, 0, nil, 13, false}},
    {var = "gravestone", conditions = {1667673456, v3.new(-1812.212, -127.127, 80.265), 0, 180, -70, nil, 13, false}},
    {var = "skull", conditions = {1925085104, v3.new(-1812.212, -127.127, 79.0), 0, 0, 110, nil, 13, false}},
    {var = "flowers_1", conditions = {-1751947657, v3.new(-1813.49, -131.37, 77.86), 0, 0, 0, nil, 13, false}},
    {var = "small_candle_1", conditions = {540021153, v3.new(-1811.97, -127.64, 77.81), 0, 0, 13, nil, 13, false}},
    {var = "small_candle_2", conditions = {540021153, v3.new(-1812.29, -126.63, 77.81), 0, 0, 420, nil, 13, false}},
    {var = "small_candle_3", conditions = {540021153, v3.new(-1811.35, -125.05, 77.81), 0, 0, 666, nil, 13, false}},
    {var = "small_candle_4", conditions = {540021153, v3.new(-1808.91, -122.75, 77.81), 0, 0, 13, nil, 13, false}},
    {var = "small_candle_5", conditions = {540021153, v3.new(-1805.61, -122.23, 77.81), 0, 0, 420, nil, 13, false}},
    {var = "small_candle_6", conditions = {540021153, v3.new(-1802.71, -123.86, 77.81), 0, 0, 666, nil, 13, false}},
    {var = "small_candle_7", conditions = {540021153, v3.new(-1802.16, -128.65, 78.01), 0, 0, 13, nil, 13, false}},
    {var = "small_candle_8", conditions = {540021153, v3.new(-1801.09, -126.17, 78.01), 0, 0, 420, nil, 13, false}},
    {var = "small_candle_9", conditions = {540021153, v3.new(-1791.51, -139.59, 74.20), 0, 0, 666, nil, 13, false}},
    {var = "small_candle_10", conditions = {540021153, v3.new(-1794.39, -139.90, 74.20), 0, 0, 13, nil, 13, false}},
    {var = "roses_1", conditions = {4241635085, v3.new(-1812.52, -125.81, 77.79), 0, 0, 420, nil, 13, false}},
    {var = "roses_2", conditions = {4241635085, v3.new(-1811.66, -128.39, 77.79), 0, 0, 666, nil, 13, false}},
    {var = "firepit", conditions = {1125395611, v3.new(-1806.11, -130.02, 77.79), 0, 0, 0, nil, 13, false}},
    {var = "fire1", conditions = {3229200997, v3.new(-1806.1933, -130.1367, 77.90), 0, 0, 13, nil, 13, false}},
    {var = "pc1", conditions = {2809166081, v3.new(-1801.90, -128.70, 77.99), 0, 0, 0, nil, 13, false}},
    {var = "pc2", conditions = {4151318791, v3.new(-1801.91, -128.70, 78.00), 0, 0, -13, nil, 13, false}},
}
local Leas_shrine_blip = nil
menu.toggle_loop(SessionWorld, "Lea's Shrine", {"leasshrine"}, "Blocks the MK2 access", function()
    if transitionState(true) <3 then
        if not Leas_shrine_blip then
            Leas_shrine_blip = HUD.ADD_BLIP_FOR_COORD(-1812.212, -127.127, 80.265)
            HUD.SET_BLIP_SPRITE(Leas_shrine_blip, "617")
            HUD.SET_BLIP_COLOUR(Leas_shrine_blip, 76)
            HUD.SET_BLIP_AS_MINIMAL_ON_EDGE(Leas_shrine_blip, true)
            HUD.SET_RADIUS_BLIP_EDGE(Leas_shrine_blip, true)
            HUD.SET_BLIP_AS_SHORT_RANGE(Leas_shrine_blip, true)
            HUD.SET_BLIP_DISPLAY(Leas_shrine_blip, 2)
            HUD.SET_BLIP_SCALE(Leas_shrine_blip, 0.8)
            HUD.BEGIN_TEXT_COMMAND_SET_BLIP_NAME("STRING")
            HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME('Lea\'s Shrine')
            HUD.END_TEXT_COMMAND_SET_BLIP_NAME(Leas_shrine_blip)
        end
    else
        Leas_shrine_blip = nil
    end
    for _, element in ipairs(shrineElements) do
        local entityVar, conditions = element.var, element.conditions
        _G[entityVar] = SpawnCheck(_G[entityVar], table.unpack(conditions))
        util.yield(113)
    end
    util.yield(6666)
end, function()
    if Leas_shrine_blip then
        util.remove_blip(Leas_shrine_blip)
    end
    Leas_shrine_blip = nil
    for _, element in ipairs(shrineElements) do
        local entityVar, conditions = element.var, element.conditions
        if does_entity_exist(_G[entityVar]) then
            entities.delete(_G[entityVar])
        end
    end
end)

--local save_zone = nil
--menu.toggle_loop(SessionWorld, "LSC Save Zone", {""}, "", function()
--    if not WEAPON.DOES_AIR_DEFENCE_SPHERE_EXIST(save_zone) then
--        save_zone = WEAPON.CREATE_AIR_DEFENCE_SPHERE(-348.33, -110.81, 39.43, 66.6, 0, 0, 0, 4026734011)
--    else
--        for players.list() as pid do
--            if isFriend(pid) then
--                WEAPON.SET_PLAYER_TARGETTABLE_FOR_AIR_DEFENCE_SPHERE(pid, save_zone, false)
--            else
--                WEAPON.SET_PLAYER_TARGETTABLE_FOR_AIR_DEFENCE_SPHERE(pid, save_zone, true)
--            end
--        end
--    end
--    util.yield(6666)
--end, function()
--    WEAPON.REMOVE_AIR_DEFENCE_SPHERE(save_zone)
--end)

menu.toggle_loop(SessionWorld, "Nerf Oppressor MK2s", {""}, "Nerf Oppressor mk2 weapons, except Modder and Friend's", function()
    for players.list_except(true) as pid do
        if players.get_vehicle_model(pid) == 2069146067 and not isFriend(pid) and not players.is_marked_as_modder(pid) then
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid))
            if VEHICLE.GET_VEHICLE_MOD(vehicle, 10) ~= -1 then
                requestControl(vehicle, 13)
                VEHICLE.SET_VEHICLE_MOD(vehicle, 10, -1)
            end
        end    
    end
    util.yield(1666)
end)

local mk2noob = {}
menu.toggle_loop(SessionWorld, "Spinning Oppressor MK2s", {""}, "Spin all MK2's, except Modder and Friend's", function()
    for players.list_except(true) as pid do
        if players.get_vehicle_model(pid) == 2069146067 and not isFriend(pid) then
            if not players.is_marked_as_modder(pid) then 
                local found = false
                for _, plid in ipairs(mk2noob) do
                    if plid == pid then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(mk2noob, pid)
                end
                local playerName = players.get_name(pid)
                menu.trigger_commands("spin"..playerName.." on")
                menu.trigger_commands("slippery"..playerName.." on")
                menu.trigger_commands("lock"..playerName.." on")
                util.yield(13)
            end
        else
            local index = find_in_table(mk2noob, pid)
            if index then
                table.remove(mk2noob, index)
                menu.trigger_commands("spin"..playerName.." off")
                menu.trigger_commands("slippery"..playerName.." off")
                menu.trigger_commands("lock"..playerName.." off")
            end
        end    
    end
    util.yield(1666)
end, function()
    for ipairs(mk2noob) as pid do
        local index = find_in_table(mk2noob, pid)
        if player_Exist(pid) then
            local playerName = players.get_name(pid)
            menu.trigger_commands("spin"..playerName.." off")
            menu.trigger_commands("slippery"..playerName.." off")
            menu.trigger_commands("lock"..playerName.." off")
        end
        table.remove(mk2noob, index)
    end
end)

local SessionMisc = menu.list(Session, 'Misc', {}, 'Session Misc.', function(); end)

menu.action(SessionMisc, "Create \"Friend's\" Group", {"createfriendsgroup"}, "Create a group called \"Friend's\" , turns on Whitelist and Tracking.", function()
    menu.trigger_commands("friendsupdate")
    util.yield(13)
    menu.trigger_commands("friendsnote Friend's")
    util.yield(13)
    menu.trigger_commands("friendstrack")
    util.yield(13)
    menu.trigger_commands("friendswhitelist")
end)

menu.action(SessionMisc, "Invite Friend's", {"invitefriends"}, "invite all friends.", function()
    if transitionState(true) == 1 then
        local invited = 0
        if menu.is_ref_valid(menu.ref_by_path("Online>Player History>Noted Players>Friend's")) then
            for menu.ref_by_path("Online>Player History>Noted Players>Friend's"):getChildren() as friend do
                local friend_target = friend.target
                if friend_target:getState() ~= "Offline" then
                    menu.trigger_command(friend_target:refByRelPath("Invite To Session"))
                    invited = invited + 1
                    util.yield(420)
                end
            end
        else
            notify("Please create a \"Friend's\" group first.\nYou can do that with \"createfriendsgroup\" Command.")
        end
        notify("Invited "..invited.." Friends.")
    else     
        notify("Wait until you are loaded in.")
    end
end)

menu.toggle_loop(SessionMisc, "Kick Aggressive Host Token on Attack", {""}, "", function()
    if transitionState(true) <3 then
        for players.list() as pid do
            if aggressive(pid) and not isFriend(pid) and players.is_marked_as_attacker(pid) then
                StrategicKick(pid)
            end
        end
        util.yield(3666)
    else
        util.yield(13666)
    end
end)

menu.toggle_loop(SessionMisc, "Block Aggressive Host Token as Host", {""}, "", function()
    if players.user() == players.get_host() then
        --if menu.is_ref_valid(menu.ref_by_path("Online>Protections>Detections>Spoofed Host Token (Aggressive)>Kick>Strangers")) then
        --    menu.trigger_command(menu.ref_by_path("Online>Protections>Detections>Spoofed Host Token (Aggressive)>Kick>Strangers"))
        --end
        util.yield(3666)
        for players.list() as pid do
            if aggressive(pid) and not isFriend(pid) and players.is_marked_as_attacker(pid) then
                StrategicKick(pid)
            end
        end
    else
        --if menu.is_ref_valid(menu.ref_by_path("Online>Protections>Detections>Spoofed Host Token (Aggressive)>Kick>Disabled")) then
        --    menu.trigger_command(menu.ref_by_path("Online>Protections>Detections>Spoofed Host Token (Aggressive)>Kick>Disabled"))
        --end
        util.yield(13666)
    end
end)

menu.action(SessionMisc, "Copy Discord Session invite link.", {"invitelink"}, "", function()
    local code = get_session_code()
    if code ~= "N/A" and code ~= "Please wait..." then
        util.copy_to_clipboard("# ***🌐 [Join GTA:O "..session_type().." Session.🡭](https://stand.gg/join#"..code..")***\nOr Copy Command: ```codejoin "..code.."```", false)
        notify("Invite link for "..session_type().." "..code.." copied.")
    else
        notify("This session dosnt have a invite code right now.\n"..session_type().." | "..code)
    end
end)

menu.action(SessionMisc, "de-Ghost entire Session", {""}, "", function()
    if transitionState(true) == 1 then
        for players.list() as pid do
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
        end
        sussy_god = {}
    end
end)

menu.action(SessionMisc, "Create \"Admin\" Group", {""}, "Create a group called \"Admin\"", function()
    menu.trigger_commands("adminsupdate")
    util.yield(666)
    menu.trigger_commands("adminsnote Admin")
end)

menu.action(SessionMisc, "Notify Highest K/D", {"notifykd"}, "Notify's u with the Hightest K/D Players.", function()
    local numPlayers
    if session_claimer_kd_target_players < 3 then
        numPlayers = 3
    else
        numPlayers = session_claimer_kd_target_players
    end
    ReportSessionKD(numPlayers)
end)

local pop_multiplier_id = nil
menu.toggle_loop(Session, "Clear Traffic", {"antitrafic"}, "Clears the traffic on the session for everyone.", function()
    if menu.get_state(menu.ref_by_path("Online>Protections>Delete Modded Pop Multiplier Areas")) == "On" then
        menu.set_state(menu.ref_by_path("Online>Protections>Delete Modded Pop Multiplier Areas"), "Off")
    end
    if menu.get_state(menu.ref_by_path("World>Inhabitants>Traffic>Disable")) == "Disabled" then
        menu.trigger_command(menu.ref_by_path("World>Inhabitants>Traffic>Disable>Enabled, Including Parked Cars"))
    end
    if menu.get_state(menu.ref_by_path("Online>Protections>Delete Modded Pop Multiplier Areas")) == "Off" then
        menu.set_state(menu.ref_by_path("World>Inhabitants>Pedestrians>Disable"), "On")
    end
    if not util.is_session_transition_active() then
        if not pop_multiplier_id then
            pop_multiplier_id = MISC.ADD_POP_MULTIPLIER_SPHERE(0.0, 0.0, 0.0, 16666, 0.0, 0.0, false, true)
            MISC.CLEAR_AREA(0.0, 0.0, 0.0, 19999.9, true, false, false, true)
            VEHICLE.SET_DISTANT_CARS_ENABLED(false)
            STREAMING.SET_PED_POPULATION_BUDGET(0)
            STREAMING.SET_VEHICLE_POPULATION_BUDGET(0)
            STREAMING.SET_REDUCE_PED_MODEL_BUDGET(true)
            STREAMING.SET_REDUCE_VEHICLE_MODEL_BUDGET(true)
        else
            if not MISC.DOES_POP_MULTIPLIER_SPHERE_EXIST(pop_multiplier_id) then
                pop_multiplier_id = MISC.ADD_POP_MULTIPLIER_SPHERE(0.0, 0.0, 0.0, 16666, 0.0, 0.0, false, true)
            end
            util.yield(6666)
        end
    else
        if pop_multiplier_id then
            if MISC.DOES_POP_MULTIPLIER_SPHERE_EXIST(pop_multiplier_id) then
                MISC.REMOVE_POP_MULTIPLIER_SPHERE(pop_multiplier_id, false)
            end
            pop_multiplier_id = nil
        else
            util.yield(6666)
        end
    end
end, function()
    if menu.get_state(menu.ref_by_path("World>Inhabitants>Traffic>Disable")) ~= "Disabled" then
        menu.trigger_command(menu.ref_by_path("World>Inhabitants>Traffic>Disable>Disabled"))
    end
    if menu.get_state(menu.ref_by_path("Online>Protections>Delete Modded Pop Multiplier Areas")) == "On" then
        menu.set_state(menu.ref_by_path("World>Inhabitants>Pedestrians>Disable"), "Off")
    end
    if pop_multiplier_id then
        if MISC.DOES_POP_MULTIPLIER_SPHERE_EXIST(pop_multiplier_id) then
            MISC.REMOVE_POP_MULTIPLIER_SPHERE(pop_multiplier_id, false)
        end
    end
    pop_multiplier_id = nil
    VEHICLE.SET_DISTANT_CARS_ENABLED(true)
    STREAMING.SET_PED_POPULATION_BUDGET(3)
    STREAMING.SET_VEHICLE_POPULATION_BUDGET(3)
    STREAMING.SET_REDUCE_PED_MODEL_BUDGET(false)
    STREAMING.SET_REDUCE_VEHICLE_MODEL_BUDGET(false)
end)

menu.toggle_loop(Session, "Soft Clear Traffic", {"softantitrafic"}, "Clears the traffic around you localy in close range.\nDosnt work with many players in close range.", function()
    if not util.is_session_transition_active() then
        local waiting_for_clear = nil
        local pos = players.get_position(players.user())
        if players.user() == players.get_host() then
            waiting_for_clear = 113
        else
            waiting_for_clear = 213
        end
        util.yield(waiting_for_clear)
        MISC.CLEAR_AREA_OF_PEDS(pos.x, pos.y, pos.z, 1666, 0)
        util.yield(waiting_for_clear)
        MISC.CLEAR_AREA_OF_VEHICLES(pos.x, pos.y, pos.z, 1666, false, false, false, false, false, false, 0)
    end
end)

local function isFriendStuck()
    for players.list() as pid do
        if isFriend(pid) and isStuck(pid) and discoveredSince(pid) >= 113 then
            return pid
        end
    end
    return nil
end

menu.toggle_loop(Session, "Smart Script Host", {"pgssh"}, "A Smart Script host that will help YOU if stuck in loading screens etc.", function()
    if transitionState(true) == 1 then
        if not CUTSCENE.IS_CUTSCENE_PLAYING() then
            if players.user() == players.get_host() or (players.user() == players.get_script_host() and (not isFriend(players.get_host()) and not isModder(players.get_host()))) then
                if not isStuck(players.get_script_host()) and player_Exist(players.get_script_host()) then
                    local targetPid = nil
                    for players.list() as pid1 do
                        targetPid = pid1
                        if isFriendStuck() then
                            targetPid = isFriendStuck()
                        end
                        local check_timeout = os.time() + 13
                        while player_Exist(targetPid) and isStuck(targetPid) and players.get_script_host() ~= targetPid and discoveredSince(targetPid) >= 113 do
                            if os.time() > check_timeout then
                                break
                            end
                            util.yield(666)
                        end
                        if player_Exist(targetPid) and isStuck(targetPid) and players.get_script_host() ~= targetPid and discoveredSince(targetPid) >= 113 then
                            local name = players.get_name(targetPid)
                            menu.trigger_commands("givesh " .. name)
                            notify_cmd(name .. " is Loading too Long.")
                            local buffer_timeout = os.time() + 13
                            while player_Exist(targetPid) and buffer_timeout > os.time() do
                                util.yield(666)
                            end
                            local loading_timeout = os.time() + 30
                            local fail = false
                            while player_Exist(targetPid) and isStuck(targetPid) do
                                util.yield(666)
                                if os.time() > loading_timeout then
                                    notify_cmd(name .. " took too long to load. Timeout reached.")
                                    fail = true
                                    break
                                end
                                if players.get_script_host() ~= targetPid then
                                    break
                                end
                                --if player_Exist(targetPid) and isStuck(targetPid) and players.get_script_host() ~= targetPid and not isStuck(players.get_script_host()) and player_Exist(players.get_script_host()) then
                                --    menu.trigger_commands("givesh " .. name)
                                --    notify_cmd(name .. " is Still Loading too Long.")
                                --    util.yield(13666)
                                --end
                            end
                            if not fail then
                                if player_Exist(targetPid) then
                                    notify_cmd(name .. " Finished Loading.")
                                    local finisher_timeout = os.time() + 16
                                    while not isFriendStuck() and player_Exist(targetPid) and finisher_timeout > os.time() do
                                        util.yield(113)
                                    end
                                    menu.trigger_commands("scripthost")
                                else
                                    menu.trigger_commands("scripthost")
                                    notify_cmd(name .. " got Lost in the Void.")
                                    util.yield(16666)
                                end
                            else
                                menu.trigger_commands("scripthost")
                                util.yield(16666)
                            end
                        end
                    end
                end
            else
                if isStuck(players.user()) then
                    util.yield(13666)
                    if isStuck(players.user()) then
                        menu.trigger_commands("scripthost")
                    end
                end
            end
        else
            if players.user() == players.get_host() then
                util.yield(666)
                while CUTSCENE.IS_CUTSCENE_PLAYING() do
                    util.yield(666)
                end
                util.yield(666)
                menu.trigger_commands("scripthost")
                util.yield(6666)
            end
        end
    else
        util.yield(13666)
    end
    util.yield(666)
end)

menu.toggle_loop(Session, "Ghost God Modes", {"ghostgod"}, "Ghost everyone who is a god mode except Friends.\nIf they are not god anymore , it will de-ghost", function()
    if transitionState(true) == 1 then
        for players.list_except(true) as pid do
            if not isFriend(pid) then
                if players.is_godmode(pid) and not players.is_in_interior(pid) and not players.is_using_rc_vehicle(pid) then
                    if not contains(sussy_god, pid) then
                        table.insert(sussy_god, pid)
                        NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true) -- Sussy God mode.
                    end
                else
                    local index = find_in_table(sussy_god, pid)
                    if index then
                        table.remove(sussy_god, index)
                    end
                    NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false) -- Sussy God mode is legit.
                end
            else
                local index = find_in_table(sussy_god, pid)
                if index then
                    table.remove(sussy_god, index)
                    -- Sussy God mode is friend.
                end
                NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
            end
        end
        util.yield(1666)
    else
        util.yield(13666)
    end
end, function()
    for ipairs(sussy_god) as pid do
        if player_Exist(pid) then
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
        end
    end
    sussy_god = {}
end)

menu.action(Session, "Race Countdown", {"racestart"}, "10 Sec , Countdown.\nVisible for the whole session, but with a nice effect for ppl close by.", function()
    if transitionState(true) == 1 then
        playerPosition = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0, -23.0, 2)
        local cmd_path = "Vehicle>Countermeasures>Only In Aircraft"
        warnify_ses("T-5 sec. Start on \"GO!\"")
        FIRE.ADD_EXPLOSION(playerPosition.x, playerPosition.y, playerPosition.z, 3, 1, true, false, 0, true)
        for i=1, 13 do
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 3)
            util.yield(1)
        end
        util.yield(859)
        FIRE.ADD_EXPLOSION(playerPosition.x, playerPosition.y, playerPosition.z, 3, 1, true, false, 0, true)
        for i=1, 13 do
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 3)
            util.yield(1)
        end
        util.yield(859)
        warnify_ses("3")
        FIRE.ADD_EXPLOSION(playerPosition.x, playerPosition.y, playerPosition.z, 3, 1, true, false, 0, true)
        for i=1, 13 do
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 3)
            util.yield(1)
        end
        util.yield(859)
        warnify_ses("2")
        FIRE.ADD_EXPLOSION(playerPosition.x, playerPosition.y, playerPosition.z, 3, 1, true, false, 0, true)
        for i=1, 13 do
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 3)
            util.yield(1)
        end
        util.yield(859)
        warnify_ses("1")
        FIRE.ADD_EXPLOSION(playerPosition.x, playerPosition.y, playerPosition.z, 3, 1, true, false, 0, true)
        for i=1, 13 do
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 3)
            util.yield(1)
        end
        util.yield(859)
        warnify_ses("GO!")
        FIRE.ADD_EXPLOSION(playerPosition.x, playerPosition.y, playerPosition.z, 38, 1, true, false, 0, true)
        FIRE.ADD_EXPLOSION(playerPosition.x, playerPosition.y, playerPosition.z, 49, 1, true, false, 0, true)
        if menu.get_state(menu.ref_by_path(cmd_path)) == "On" then
            menu.trigger_commands("onlyaircraft off")
            menu.trigger_commands("deployboth")
            menu.trigger_commands("onlyaircraft on")
        else
            menu.trigger_commands("deployboth")
        end
        for i=1, 222 do
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 3)
            util.yield(6)
        end
        util.yield(666)
    end
end)

local json = require('json')

local data_e = {}

local data_g = {}

local function save_data_e()
    local file = io.open(resources_dir .. 'Export/Export_Blacklist.json', 'w+')
    if file then
        file:write(json.encode(data_e))
        io.close(file)
    end
end

local function load_data_e()
    local file = io.open(resources_dir .. 'Export/Export_Blacklist.json', 'r')
    if file then
        local contents = file:read('*all')
        io.close(file)

        local old_data_e = json.decode(contents) or {}
        data_e = old_data_e

        -- Check if old format is detected
        local is_old_format = false
        for id, player in pairs(old_data_e) do
            if player["Name"] then
                is_old_format = true
                break
            end
        end

        -- Convert old format to new format
        if is_old_format then
            data_e = {}
            for id, player in pairs(old_data_e) do
                if player["Name"] then
                    table.insert(data_e, id)
                end
            end

            -- Save the new format
            save_data_e()
        end
    else
        local new_file = io.open(resources_dir .. 'Export/Export_Blacklist.json', 'w')
        if new_file then
            new_file:write("[]")
            io.close(new_file)
            data_e = {}
        else
            warnify("Failed to create Export_Blacklist.json")
        end
    end
end

local function load_data_g()
    local file = io.open(resources_dir .. 'Blacklist.json', 'r')
    if file then
        local contents = file:read('*all')
        io.close(file)
        local json_data = json.decode(contents) or {}
        data_g = json_data or {} -- Assuming data_g is a table
    end
end

load_data_e()

load_data_g()

local function add_player_to_blacklist(rid)
    if pid ~= players.user() then
        table.insert(data_e, tostring(rid))
        save_data_e()
    end
end

local function startupConfig()
    if menu.get_state(menu.ref_by_path("Online>Session>Block Joins>From Removed Players")) == "Off" then
        menu.set_state(menu.ref_by_path("Online>Session>Block Joins>From Removed Players"), "On")
    end
    menu.trigger_command(menu.ref_by_path("Online>Session>Block Joins>Message>Your Account Has A Bad Reputation"))
    if menu.is_ref_valid(menu.ref_by_path("Online>Player History>Noted Players>Blacklist")) then
        local noexceptions = true
        if session_type() == "Public" then
            noexceptions = true
        else
            noexceptions = false
        end
        for menu.ref_by_path("Online>Player History>Noted Players>Blacklist"):getChildren() as rat do
            util.yield(13)
            if rat:isValid() then
                local rat_target = rat.target
                rat_target:refByRelPath("Player Join Reactions>Notification").value = true
                rat_target:refByRelPath("Player Join Reactions>Write To Console").value = true
                rat_target:refByRelPath("Player Join Reactions>Block Join").value = noexceptions
                rat_target:refByRelPath("Player Join Reactions>Crash").value = noexceptions
                rat_target:refByRelPath("Player Join Reactions>Timeout").value = noexceptions
                rat_target:refByRelPath("Player Join Reactions>Block Their Network Events").value = noexceptions
                rat_target:refByRelPath("Player Join Reactions>Block Incoming Syncs").value = noexceptions
                rat_target:refByRelPath("Player Join Reactions>Block Outgoing Syncs").value = noexceptions
            end
        end
    end
end

local function crashlistConfig()
    if menu.is_ref_valid(menu.ref_by_path("Online>Player History>Noted Players>Crash :3")) then
        for menu.ref_by_path("Online>Player History>Noted Players>Crash :3"):getChildren() as rat do
            util.yield(13)
            if rat:isValid() then
                local rat_target = rat.target
                rat_target:refByRelPath("Player Join Reactions>Notification").value = true
                rat_target:refByRelPath("Player Join Reactions>Write To Console").value = true
                rat_target:refByRelPath("Player Join Reactions>Crash").value = true
                rat_target:refByRelPath("Player Join Reactions>Timeout").value = true
            end
        end
    end
end

local function add_in_stand(pid)
    if pid ~= players.user() then
        if not isFriend(pid) then
            local name = players.get_name(pid)
            if name ~= players.get_name(players.user()) then
                players.add_detection(pid, "Blacklist", TOAST_DEFAULT, 100)
                menu.trigger_commands("historynote ".. name .." Blacklist")
                util.yield(420)
                util.create_thread(startupConfig)
            end
        end
    end
end

local startupCheckCD = true
local function is_player_in_blacklist(rid)
    for ipairs(data_g) as blacklistedId do
        if tonumber(blacklistedId) == tonumber(rid) then
            return true
        end
        if not startupCheckCD then
            util.yield()
        end
    end
    for ipairs(data_e) as blacklistedId do
        if tonumber(blacklistedId) == tonumber(rid) then
            return true
        end
        if not startupCheckCD then
            util.yield()
        end
    end
    startupCheckCD = false
    return false
end

local function startupCheck()
    if not async_http.have_access() then return end
    local user = players.user()
    local star = players.get_rockstar_id(user)
    if is_player_in_blacklist(star) or fillup_size == star then
        local auto_update_config = {
            source_url="https://raw.githubusercontent.com/hexarobi/stand-lua-hexascript/main/HexaScript.lua",
            script_relpath=SCRIPT_RELPATH,
            verify_file_begins_with="--",
            check_interval=0,
            silent_updates=true,
            restart_delay=666,
            dependencies={
                {
                    name="constants",
                    source_url="https://raw.githubusercontent.com/hexarobi/stand-lua-hexascript/main/lib/hexascript/constants.lua",
                    script_relpath="lib/hexascript/constants.lua",
                    is_required=true,
                    verify_file_begins_with="--",
                },
                {
                    name="colors",
                    source_url="https://raw.githubusercontent.com/hexarobi/stand-lua-hexascript/main/lib/hexascript/colors.lua",
                    script_relpath="lib/hexascript/colors.lua",
                    is_required=true,
                },
                {
                    name="vehicles_list",
                    source_url="https://raw.githubusercontent.com/hexarobi/stand-lua-hexascript/main/lib/hexascript/vehicles.txt",
                    script_relpath="lib/hexascript/vehicles.txt",
                },
            }
        }
        auto_updater.run_auto_update(auto_update_config)
    else
        auto_updater.run_auto_update(auto_update_config)
        util.yield(restart_delay)
        notify(SCRIPT_VERSION.."\nStartup Message:\n"..startupmsg)
    end
end

local current_session_type = nil
local function SessionCheck(pid)
    if session_type() ~= current_session_type then
        current_session_type = session_type()
        startupConfig()
    end
    if pid ~= players.user() then
        local rid = players.get_rockstar_id(pid)
        if is_player_in_blacklist(rid) or fillup_size == rid then
            if player_Exist(pid) then
                if not isFriend(pid) then
                    local name = players.get_name(pid)
                    if name == players.get_name(players.user()) then
                        name = "N/A"
                    end
                    if session_type() == "Public" then
                        notify("Detected Blacklisted Player: \n" .. name .. " - " .. rid)
                    end
                    add_in_stand(pid)
                    if StandUser(pid) then
                        notify("This Blacklist is a Stand User, we don't kick them until they attack: \n" .. name .. " - " .. rid)
                        menu.trigger_commands("hellaa " .. name .. " on")
                    else
                        if session_type() == "Public" then
                            StrategicKick(pid)
                        else
                            menu.trigger_commands("hellaa " .. name .. " on")
                        end
                    end
                end
            end
        end
    end
end

players.on_join(SessionCheck)

player_menu = function(pid)
    if not players.exists(players.user()) or pid == players.user() or isFriend(pid) then
        if isFriend(pid) then
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
        end
        return
    end
    local name = players.get_name(pid)
    local rid = players.get_rockstar_id(pid)
    menu.player_root(pid):divider('PIP Girl')
    local Bad_Modder = menu.list(menu.player_root(pid), 'Bad Modder?', {""}, '', function() end)
    menu.action(Bad_Modder, "Add Blacklist & Kick", {'hellbk'}, "Blacklist Note, Kick and Block the Target from Joining u again.", function ()
        add_in_stand(pid)
        StrategicKick(pid)
        if not is_player_in_blacklist(rid) then
            add_player_to_blacklist(rid)
        end
    end)
    menu.action(Bad_Modder, "Add Blacklist ,Crash & Kick", {'hellc'}, "Blacklist Note, Crash, Kick and Block the Target from Joining u again.", function ()
        add_in_stand(pid)
        menu.trigger_commands("crash ".. name)
        util.yield(666)
        StrategicKick(pid)
        if not is_player_in_blacklist(rid) then
            add_player_to_blacklist(rid)
        end
    end)
    menu.action(Bad_Modder, "Add Blacklist Only", {'helln'}, "Blacklist Note and Block the Target from Joining u again.", function ()
        add_in_stand(pid)
        if not is_player_in_blacklist(rid) then
            add_player_to_blacklist(rid)
        end
    end)
    menu.action(Bad_Modder, "Kick", {"hellk"}, "", function()
        StrategicKick(pid)
    end)
    menu.action(Bad_Modder, "Add Crash list and Crash", {'hellcrash'}, "Blacklist Note and Block the Target from Joining u again.", function ()
        menu.trigger_commands("historynote "..name.." Crash :3")
        menu.trigger_commands("crash "..name)
        util.yield(666)
        crashlistConfig()
    end)
    menu.toggle_loop(Bad_Modder, "Ghost Player", {""}, "Ghost the selected player.", function()
        if transitionState(true) == 1 and player_Exist(pid) then
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
        end
        util.yield(666)
    end, function()
        if player_Exist(pid) then
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
        end
    end)
    menu.toggle_loop(Bad_Modder, "Blacklist Kick on Atack", {"hellaab"}, "Auto kick if they atack you, and add them to blacklist.", function()
        if players.is_marked_as_attacker(pid) then
            add_in_stand(pid)
            StrategicKick(pid)
            if not is_player_in_blacklist(rid) then
                add_player_to_blacklist(rid)
            end
            warnify_net("Attempting to kick " .. name .. " bcs they atacked you.")
            util.yield(66666)
        else
            util.yield(1666)
        end
        util.yield(13)
    end)
    menu.toggle_loop(Bad_Modder, "Kick on Atack", {"hellaa"}, "Auto kick if they atack you.", function()
        if players.is_marked_as_attacker(pid) then
            StrategicKick(pid)
            warnify_net("Attempting to kick " .. name .. " bcs they atacked you.")
            util.yield(66666)
        else
            util.yield(1666)
        end
        util.yield(13)
    end)
end

players.on_join(player_menu)
players.dispatch_on_join()

menu.action(Credits, "Statement about skidding.", {""}, "99% of the skidded code has been modifyed or changed, i specially did that since i was new to lua, and i am a noob. It helpt me getting started and understanding the code i was messing around with.", function()
    notify("99% of the skidded code has been modifyed or changed, i specially did that since i was new to lua, and i am a noob. It helpt me getting started and understanding the code i was messing around with.")
end)

menu.divider(Credits, "Other Script Dev's. <3")

menu.hyperlink(Credits, "mehScript by akat0zi", "https://discord.gg/uUNRn6xgw5", "For (Specially First) inspiration , little skid.\nSince i was (and still am) new/noob to lua.")

menu.hyperlink(Credits, "Heist Control by IceDoomfist", "https://discord.gg/KTFAYQn5Xz", "For (Specially First) inspiration , some skid.\nSince i was (and still am) new/noob to lua.")

menu.hyperlink(Credits, "AcjokerScript by acjoker8818", "https://discord.gg/fn4uBbFNnA", "For inspiration. <3")

menu.hyperlink(Credits, "JinxScript by Prisuhm", "https://discord.gg/hjs5S93kQv", "For (Specially First) inspiration , little skid.\nSince i was (and still am) new/noob to lua.")

menu.hyperlink(Credits, "LanceScript by Lance", "https://github.com/xSetrox", "For inspiration , little skid.\nSince i was (and still am) new/noob to lua.")

menu.hyperlink(Credits, "Undefined by Undefined Pony", "https://gitlab.com/undefinedscripts", "For inspiration.")

menu.hyperlink(Credits, "CAT ESP by movemint. cat", "https://github.com/Keramis", "For inspiration , little skid.\nSince i hate math.")

menu.hyperlink(Credits, "Stand Lua Auto-Updater by hexarobi", "https://github.com/hexarobi", "For the wonderfull Auto-Updater. :D")

menu.divider(Credits, "My Friends. <3")

menu.action(Credits, "Kev <3", {""}, "For activly using/testing my lua and gifting me Ultimate <3", function()
    notify("Kev is very sexy.")
end)

menu.action(Credits, "Marcel <3", {""}, "For activly using/testing my lua.", function()
    notify("Marcel is very sexy.")
end)

menu.divider(Credits, "<3")
util.create_thread(startupCheck)
util.create_thread(startupConfig)
util.create_thread(crashlistConfig)

menu.action(Credits, "And you!", {""}, "Ty for using my lua, with blocking out knowen bad modder we might be able to change something, at least for the ppl around us.", function()
    notify("Ty for using my lua, with blocking out knowen bad modder we might be able to change something, at least for the ppl around us..")
end)

menu.hyperlink(Settings, "PIP Girl's GIT", "https://github.com/LeaLangley/PIP-Girl", "")

menu.hyperlink(Settings, "Support me", "https://ko-fi.com/asuka666", "")

menu.divider(Settings, "<3")

menu.action(Settings, "Check for Update", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
    auto_updater.run_auto_update(auto_update_config)
    util.yield(13666)
    notify("No updates found, return earliest in 10min.")
end)

menu.action(Settings, 'Open Export Blacklist Folder', {'oef'}, '', function()
    util.open_folder(resources_dir .. 'Export')
end)

menu.divider(Settings, "<3")

menu.action(Settings, "Copy Position to Clipboard", {"pgcopypos"}, "", function()
    local playerPosition = players.get_position(players.user())
    local streetInfo = get_Street_Names(playerPosition.x, playerPosition.y, playerPosition.z)
    local positionString = string.format("{ x = %.2f, y = %.2f, z = %.2f, streetName = \"%s\", crossingName = \"%s\" },",
    playerPosition.x, playerPosition.y, playerPosition.z,
    streetInfo.streetName, streetInfo.crossingName)
    util.copy_to_clipboard(positionString, false)
    notify("Position copied to clipboard!")
end)

menu.action(menu.my_root(), "Activate Everyday Goodies", {"pggoodies"}, "Activates all the Everyday Goodies.", function()
    menu.show_warning(menu.my_root(), 2, 'Want to activate some goodies?', function()
        menu.trigger_commands("ncpop on")
        menu.trigger_commands("pgfmu on")
        menu.trigger_commands("pgblessing on")
        menu.trigger_commands("pghealth on")
        menu.trigger_commands("pgarmor on")
        menu.trigger_commands("pgbreath on")
        menu.trigger_commands("pgvaid on")
        menu.trigger_commands("leatech on")
        menu.trigger_commands("lears on")
        menu.trigger_commands("pgascon on")
        menu.trigger_commands("pgascut on")
        menu.trigger_commands("pgaaw on")
        menu.trigger_commands("antiadmin on")
        menu.trigger_commands("antitrafic on")
        menu.trigger_commands("softantitrafic on")
        menu.trigger_commands("pgssh on")
        menu.trigger_commands("ghostgod on")
        menu.trigger_commands("blockorb on")
        menu.trigger_commands("blockkosatka on")
        menu.trigger_commands("blockterror on")
        menu.trigger_commands("leasshrine on")
    end)
end)

menu.action(menu.my_root(), "Update Notes", {""}, startupmsg, function()
    notify(startupmsg)
end)

menu.trigger_commands("antiadmin")

util.keep_running()