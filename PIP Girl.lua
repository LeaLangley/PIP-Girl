--[[
__________._____________    ________.__       .__   
\______   \   \______   \  /  _____/|__|______|  |  
 |     ___/   ||     ___/ /   \  ___|  \_  __ \  |  
 |    |   |   ||    |     \    \_\  \  ||  | \/  |__
 |____|   |___||____|      \________/__||__|  |____/                
]]--
local script_version = "666"
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
    check_interval=0,
    silent_updates=true,
    restart_delay=6666,
    dependencies={
        {
            name="logo",
            source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/resources/1%20PIP%20Girl/logo.png",
            script_relpath="resources/1 PIP Girl/logo.png",
            check_interval=0,
        },
        {
            name="blacklist",
            source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/resources/1%20PIP%20Girl/Blacklist.json",
            script_relpath="resources/1 PIP Girl/Blacklist.json",
            check_interval=0,
        },
        {
            name="read_me.txt",
            source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/resources/1%20PIP%20Girl/Export/read_me.txt",
            script_relpath="resources/1 PIP Girl/Export/read_me.txt",
            check_interval=0,
        },
    }
}
auto_updater.run_auto_update(auto_update_config)
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
util.require_natives("3095a")
local json = require('json')
resources_dir = filesystem.resources_dir() .. '/1 PIP Girl/'
store_dir = filesystem.store_dir() .. '/PIP Girl/'
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
local function warnify(msg)
    local formattedMsg = string.gsub(msg, "\n", " | ")
    chat.send_message("<[Pip Girl]>: " .. formattedMsg, true, true, false)
    util.toast("<[Pip Girl]>: " .. msg, TOAST_CONSOLE)
    util.toast("<[Pip Girl]>\n" .. msg)
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
local handle_ptr = memory.alloc(13*8)
local function pid_to_handle(pid)
    if pid then
        NETWORK.NETWORK_HANDLE_FROM_PLAYER(pid, handle_ptr, 13)
        return handle_ptr
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
        if STREAMING.HAS_MODEL_LOADED(hash) then
            return
        end
    end
    util.request_model(hash, timeout)
end
local requestControl = entities.request_control
local function does_entity_exist(entity)
    if entity then
        if ENTITY.DOES_ENTITY_EXIST(entity) then
            return true
        end
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
            requestControl(entity)
            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(entity, PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), false)
        end
    end
    local currentCoords = ENTITY.GET_ENTITY_COORDS(entity)
    coordinatesCorrect = (math.abs(currentCoords.x - locationV3.x) <= 1) and
                            (math.abs(currentCoords.y - locationV3.y) <= 1) and
                            (math.abs(currentCoords.z - locationV3.z) <= 1)
    if not coordinatesCorrect then
        requestControl(entity)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, locationV3.x, locationV3.y, locationV3.z, true, true, true)
        ENTITY.FREEZE_ENTITY_POSITION(entity, true)
    end
    local currentRotation = ENTITY.GET_ENTITY_ROTATION(entity, order)
    anglesCorrect = (math.abs(currentRotation.x - pitch) <= 1) and
                    (math.abs(currentRotation.y - roll) <= 1) and
                    (math.abs(currentRotation.z - yaw) <= 1)
    if not anglesCorrect then
        requestControl(entity)
        ENTITY.SET_ENTITY_ROTATION(entity, pitch, roll, yaw, order, true)
        ENTITY.FREEZE_ENTITY_POSITION(entity, true)
    end
end
local function SpawnCheck(entity, hash, locationV3, pitch, roll, yaw, order, timeout, anti_collision)
    if order == nil then order = 2 end
    local startTime = os.time()
    if not does_entity_exist(entity) then
        requestModel(hash)
        entity = entities.create_object(hash, locationV3)
        util.yield(13 + timeout)
        startTime = os.time()
        while not does_entity_exist(entity) do
            if os.time() - startTime > timeout or timeout == 0 then
                break
            end
            util.yield(13 + timeout)
        end
        requestControl(entity)
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
local function Wait_for_transitionState()
    local ses_cod = get_session_code()
    while transitionState(true) > 2 and ses_cod == get_session_code() do
        util.yield(666)
    end
    if ses_cod == get_session_code() then
        players.dispatch_on_join()
    end
end
local set_passive = {}
local allTables = {
    set_passive
}
local function set_as_illusion(pid, tbl, state)
    if state then
        if not contains(tbl, pid) then
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
            table.insert(tbl, pid)
        end
    else
        local index = find_in_table(tbl, pid)
        if index then
            table.remove(tbl, index)
            local playerInOtherTables = false
            for pairs(allTables) as otherTbl do
                if otherTbl ~= tbl then
                    if contains(otherTbl, pid) then
                        playerInOtherTables = true
                        break
                    end
                end
            end
            if not playerInOtherTables then
                NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
            end
        end
    end
end
local function StrategicKick(pid)
    if player_Exist(pid) and pid ~= players.user() then
        local name = players.get_name(pid)
        if name ~= players.get_name(players.user()) then
            if transitionState(true) ~= 1 then
                if menu.get_edition() > 1 then
                    if pid ~= players.get_host() then
                        menu.trigger_commands("loveletterkick " .. name)
                    end
                end
                menu.trigger_commands("kick " .. name)
                set_as_illusion(pid, set_passive, true)
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
                        if pid ~= players.get_host() then
                            menu.trigger_commands("loveletterkick " .. name)
                        end
                        menu.trigger_commands("kick " .. name)
                        menu.trigger_commands("ignore " .. name .. " on")
                        menu.trigger_commands("desync " .. name .. " on")
                        menu.trigger_commands("blocksync " .. name .. " on")
                        set_as_illusion(pid, set_passive, true)
                    end
                else
                    menu.trigger_commands("kick " .. name)
                    menu.trigger_commands("ignore " .. name .. " on")
                    menu.trigger_commands("desync " .. name .. " on")
                    menu.trigger_commands("blocksync " .. name .. " on")
                    set_as_illusion(pid, set_passive, true)
                end
            end
        end
    end
end
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
menu.toggle_loop(menu.my_root(), "Lea's Shrine", {"leasshrine"}, "Shows Lea's Shrine, Perfect for a hangout spot or Deep thinking.", function()
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
    for pairs(shrineElements) as element do
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
    for pairs(shrineElements) as element do
        local entityVar, conditions = element.var, element.conditions
        if does_entity_exist(_G[entityVar]) then
            entities.delete(_G[entityVar])
        end
    end
end)
local data_e = {}
local data_g = {}
if not filesystem.exists(resources_dir .. 'Export/Export_Blacklist.json') then
    local file = io.open(resources_dir .. 'Export/Export_Blacklist.json', "w")
    file:close()
end
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
        local is_old_format = false
        for id, player in pairs(old_data_e) do
            if player["Name"] then
                is_old_format = true
                break
            end
        end
        if is_old_format then
            data_e = {}
            for id, player in pairs(old_data_e) do
                if player["Name"] then
                    table.insert(data_e, id)
                end
            end
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
local PIP_Girl_Blacklist = {}
local function load_PIP_Girl_Blacklist()
    for pairs(data_g) as id do
        PIP_Girl_Blacklist[id] = true
    end

    for ipairs(data_e) as id do
        PIP_Girl_Blacklist[id] = true
    end
end
load_PIP_Girl_Blacklist()
local function add_player_to_blacklist(rid)
    if pid ~= players.user() then
        local id = tostring(rid)
        table.insert(data_e, id)
        PIP_Girl_Blacklist[id] = true
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
                rat_target:refByRelPath("Player Join Reactions>Timeout").value = noexceptions
                rat_target:refByRelPath("Player Join Reactions>Block Their Network Events").value = noexceptions
                rat_target:refByRelPath("Player Join Reactions>Block Incoming Syncs").value = noexceptions
                rat_target:refByRelPath("Player Join Reactions>Block Outgoing Syncs").value = noexceptions
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
local function is_player_in_blacklist(rid)
    local id = tostring(rid)
    return PIP_Girl_Blacklist[id] ~= nil
end
local function startupCheck()
    if not async_http.have_access() then return end
    local user = players.user()
    local star = players.get_rockstar_id(user)
    if is_player_in_blacklist(star) then
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
        if is_player_in_blacklist(rid) then
            if player_Exist(pid) then
                if not isFriend(pid) then
                    if rid == players.get_rockstar_id(pid) then
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
end
menu.toggle_loop(menu.my_root(), "Admin Bail", {"antiadmin"}, "Instantly Bail and Join Invite only\nIf R* Admin Detected", function()
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
    util.yield()
end)
players.on_join(SessionCheck)
menu.trigger_commands("leasshrine on")
menu.trigger_commands("antiadmin on")