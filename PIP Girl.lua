--[[
__________._____________    ________.__       .__   
\______   \   \______   \  /  _____/|__|______|  |  
 |     ___/   ||     ___/ /   \  ___|  \_  __ \  |  
 |    |   |   ||    |     \    \_\  \  ||  | \/  |__
 |____|   |___||____|      \________/__||__|  |____/                
]]--

local SCRIPT_VERSION = "0.1.81"

local startupmsg = "Auto CEO color is very experimental!\nI love u."

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
if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end

local default_check_interval = 13666
local auto_update_config = {
    source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/PIP%20Girl.lua",
    script_relpath=SCRIPT_RELPATH,
    verify_file_begins_with="--",
    check_interval=6666,
    silent_updates=true,
    restart_delay=1666,
    dependencies={
        {
            name="logo",
            source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/resources/1%20PIP%20Girl/logo.png",
            script_relpath="resources/1 PIP Girl/logo.png",
            check_interval=default_check_interval,
        },
        {
            name="blacklist",
            source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/resources/1%20PIP%20Girl/Blacklist.json",
            script_relpath="resources/1 PIP Girl/Blacklist.json",
            check_interval=6666,
        },
        {
            name="read_me.txt",
            source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/resources/1%20PIP%20Girl/Export/read_me.txt",
            script_relpath="resources/1 PIP Girl/Export/read_me.txt",
            check_interval=default_check_interval,
        },
    }
}

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

util.require_natives(1663599433)

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

local function IsInSession()
    return util.is_session_started() and not util.is_session_transition_active()
end

local function is_user_driving_vehicle()
    return (PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true))
end

local function notify(msg)
    util.toast("<[Pip Girl]>: " .. msg, TOAST_CONSOLE)
    util.toast("<[Pip Girl]>\n" .. msg)
end

local function notify_cmd(msg)
    util.toast("<[Pip Girl]>: " .. msg, TOAST_CONSOLE)
end

local function warnify(msg)
    chat.send_message("<[Pip Girl]>:\n " .. msg, true, true, false)
    util.toast("<[Pip Girl]>: " .. msg, TOAST_CONSOLE)
    util.toast("<[Pip Girl]>\n" .. msg)
end

local function warnify_net(msg)
    chat.send_message("<[Pip Girl]>:\n " .. msg, true, true, true)
    util.toast("<[Pip Girl]>: " .. msg, TOAST_CONSOLE)
    util.toast("<[Pip Girl]>\n" .. msg)
end

local function warnify_ses(msg)
    chat.send_message(msg, false, true, true)
    util.toast("<[Pip Girl]>: " .. msg, TOAST_CONSOLE)
    util.toast(msg)
end

local function player_Exist(pid)
    if players.exists(pid) and players.get_name(pid) ~= "undiscoveredplayer" and players.get_name(pid) ~= "InvalidPlayer" then
        local Player_List = players.list()
        for _, plid in pairs(Player_List) do
            if plid == pid then
                return true
            end
        end
    end
    return false
end

local function StandUser(pid) -- credit to sapphire for this and jinx script
    if player_Exist(pid) and pid != players.user() then
        util.yield(666)
        if player_Exist(pid) and pid != players.user() then
            for menu.player_root(pid):getChildren() as cmd do
                if cmd:getType() == COMMAND_LIST_CUSTOM_SPECIAL_MEANING and cmd:refByRelPath("Stand User"):isValid() then
                    return true
                end
            end
        end
    end
    return false
end

local function wannabeGod(pid)
    if player_Exist(pid) and pid != players.user() then
        util.yield(666)
        if player_Exist(pid) and pid != players.user() then
            for menu.player_root(pid):getChildren() as cmd do
                if cmd:getType() == COMMAND_LIST_CUSTOM_SPECIAL_MEANING and cmd:refByRelPath("Attacking While Invulnerable"):isValid() then
                    return true
                end
                if cmd:getType() == COMMAND_LIST_CUSTOM_SPECIAL_MEANING and cmd:refByRelPath("Dead For Too Long"):isValid() then
                    return true
                end
            end
        end
    end
    return false
end

local function aggressive(pid)
    if player_Exist(pid) and pid != players.user() then
        util.yield(666)
        if player_Exist(pid) and pid != players.user() then
            for menu.player_root(pid):getChildren() as cmd do
                if cmd:getType() == COMMAND_LIST_CUSTOM_SPECIAL_MEANING and cmd:refByRelPath("Spoofed Host Token (Aggressive)"):isValid() then
                    return true
                end
            end
        end
    end
    return false
end

local function StandDetectionsRead(pid)
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

function START_SCRIPT(ceo_mc, name)
    if IsInSession() then
        if HUD.IS_PAUSE_MENU_ACTIVE() then
            notify("Close any open Game Menu first!")
            return
        end
        if players.get_boss(players.user()) ~= -1 then
            if players.get_org_type(players.user()) == 0 then -- NOTE: https://www.unknowncheats.me/forum/3683018-post106.html
                if ceo_mc == "MC" then
                    menu.trigger_commands("ceotomc")
                    notify("Turned you into MC President!")
                end
            else
                if ceo_mc == "CEO" then
                    menu.trigger_commands("ceotomc")
                    notify("Turned you into CEO!")
                end
            end
        else
            if ceo_mc == "CEO" then
                menu.trigger_commands("ceostart")
                notify("Turned you into CEO!")
            elseif ceo_mc == "MC" then
                menu.trigger_commands("mcstart")
                notify("Turned you into MC President!")
            end
        end

        SCRIPT.REQUEST_SCRIPT(name)
        repeat util.yield_once() until SCRIPT.HAS_SCRIPT_LOADED(name)
        SYSTEM.START_NEW_SCRIPT(name, 5000)
        SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(name)
    end
end

function IS_HELP_MSG_DISPLAYED(label)
    HUD.BEGIN_TEXT_COMMAND_IS_THIS_HELP_MESSAGE_BEING_DISPLAYED(label)
    return HUD.END_TEXT_COMMAND_IS_THIS_HELP_MESSAGE_BEING_DISPLAYED(0)
end

handle_ptr = memory.alloc(13*8)
local function pid_to_handle(pid)
    NETWORK.NETWORK_HANDLE_FROM_PLAYER(pid, handle_ptr, 13)
    return handle_ptr
end

local function isStuck(pid)
    if not IsInSession() then
        return false
    end
    if pid == players.user() then
        if ENTITY.GET_ENTITY_SPEED(pid) < 1 and HUD.BUSYSPINNER_IS_DISPLAYING() then
            return true
        end
    end
    if not players.is_visible(pid) and ENTITY.GET_ENTITY_SPEED(pid) < 1 then
        if players.get_money(pid) ~= 0 and players.get_rank(pid) ~= 0 then
            return true
        end
        if players.get_money(pid) ~= 0 and players.get_kd(pid) ~= 0 and players.get_rank(pid) ~= 0 then
            return true
        end
    end
    return false
end

local function isLoading(pid)
    if pid == players.user() and not IsInSession() then
        return true
    end
    if not IsInSession() then
        return false
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
        if players.get_money(pid) == 0 and players.get_kd(pid) == 0 then
            return true
        end
        if players.get_rank(pid) == 0 then
            return true
        end
        if not players.is_visible(pid) then
            return true
        end
    end
    if NETWORK.IS_PLAYER_IN_CUTSCENE(pid) then
        return true
    end
    return false
end

local function requestModel(hash, timeout)
    if not STREAMING.HAS_MODEL_LOADED(hash) then
        STREAMING.REQUEST_MODEL(hash)
        local startTime = os.time()
        while not STREAMING.HAS_MODEL_LOADED(entity) do
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
        local startTime = os.time()
        while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) do
            if os.time() - startTime > timeout or timeout == 0 then
                break
            end
            util.yield(13)
        end
    end
end

local function SpawnCheck(entity, hash, locationV3, heading, timeout)
    if not ENTITY.DOES_ENTITY_EXIST(entity) then
        requestModel(hash, 13)
        entity = entities.create_object(hash, locationV3)
        util.yield(13)
        if heading != 0 then
            local startTime = os.time()
            while math.abs(ENTITY.GET_ENTITY_HEADING(entity) - heading ) > 1 do
                ENTITY.SET_ENTITY_HEADING(entity, heading)
                if os.time() - startTime > timeout or timeout == 0 then
                    break
                end
                util.yield(13)
            end
        end
        ENTITY.FREEZE_ENTITY_POSITION(entity, true)
        local PlayerList = players.list()
        for _, pid in pairs(PlayerList) do
            local hdl = pid_to_handle(pid)
            if pid == players.user() or NETWORK.NETWORK_IS_FRIEND(hdl) then
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(entity, PLAYER.GET_PLAYER_PED(pid), false)
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(PLAYER.GET_PLAYER_PED(pid), entity, false)
            else
                util.yield(13)
            end
        end
        return entity
    else
        requestControl(entity, 13)
        local PlayerList = players.list()
        for _, pid in pairs(PlayerList) do
            local hdl = pid_to_handle(pid)
            if pid == players.user() or NETWORK.NETWORK_IS_FRIEND(hdl) then
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(entity, PLAYER.GET_PLAYER_PED(pid), false)
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(PLAYER.GET_PLAYER_PED(pid), entity, false)
                util.yield(666)
            else
                util.yield(13)
            end
        end
        return entity
    end
end

local function thunderForMin(min)
    if IsInSession() then
        menu.trigger_commands("scripthost")
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
        if IsInSession() then
            menu.trigger_commands("scripthost")
        end
        menu.trigger_commands("thunderoff")
    end
end

local function Wait_for_IsInSession()
    while not IsInSession() do
        util.yield(666)
    end
    players.dispatch_on_join()
end

local function StrategicKick(pid)
    local name = players.get_name(pid)
    if player_Exist(pid) then
        if not IsInSession() then
            Wait_for_IsInSession()
        else
            if players.user() == players.get_host() then
                if not isLoading(pid) and not isLoading(players.user()) then
                    menu.trigger_commands("ban " .. name)
                else
                    menu.trigger_commands("loveletterkick " .. name)
                end
            else
                menu.trigger_commands("kick " .. name)
                if IsInSession() then
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
local Vehicle_Light = menu.list(Vehicle, 'Vehicle Light Rhythm', {}, 'Flash the lights pretty and nice.', function(); end)
local Outfit = menu.list(menu.my_root(), 'Outfit', {}, 'Look pretty and nice.', function(); end)
local Game = menu.list(menu.my_root(), 'Game', {}, 'Very gaming today.', function(); end)
local Session = menu.list(menu.my_root(), 'Session', {}, '.noisseS', function(); end)
local SessionClaimer = menu.list(Session, 'Session Claimer Settings', {}, 'Session Claimer settings.', function(); end)
local Settings = menu.list(menu.my_root(), 'Settings/Misc', {}, 'Basement.', function(); end)
local Credits = menu.list(Settings, 'Credits', {}, '<3', function(); end)

menu.action(PIP_Girl_APPS, "Master Control Terminal App", {}, "Your master control terminal.", function()
    START_SCRIPT("CEO", "apparcadebusinesshub")
end)

menu.textslider(PIP_Girl_APPS, "Nightclub App", {}, "Your nightclub screen.", {
    "Open",
    "Close",
}, function()
    START_SCRIPT("CEO", "appbusinesshub")
end)

menu.textslider(PIP_Girl_APPS, "Bunker App", {}, "Your bunker screen.", {
    "Open",
    "Close",
}, function()
    START_SCRIPT("CEO", "appbunkerbusiness")
end)

menu.textslider(PIP_Girl_APPS, "Touchscreen Terminal App", {}, "Your Terrorbyte screen.", {
    "Open",
    "Close",
}, function()
    START_SCRIPT("CEO", "apphackertruck")
end)

menu.textslider(PIP_Girl_APPS, "Air Cargo App", {}, "Your air cargo screen.", {
    "Open",
    "Close",
}, function()
    START_SCRIPT("CEO", "appsmuggler")
end)

menu.textslider(PIP_Girl_APPS, "The Open Road App", {}, "Your MC management screen.", {
    "Open",
    "Close",
}, function()
    START_SCRIPT("MC", "appbikerbusiness")
end)

menu.textslider(PIP_Girl_APPS, "The Agency App", {}, "Your agency screen.", {
    "Open",
    "Close",
}, function()
    START_SCRIPT("CEO", "appfixersecurity")
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
        if IsInSession() then
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
        if IsInSession() then
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
        if IsInSession() then
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
        if IsInSession() then
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
    if IsInSession() then
        local ncpop = math.floor(STAT_GET_INT('CLUB_POPULARITY') / 10)
        if ncpop < 66 then
            menu.trigger_commands('clubpopularity 100')
            util.yield(66666)
        end
        util.yield(66666)
    else
        util.yield(66666)
    end
end)

menu.divider(PIP_Girl, "CEO/MC Options")
local ceo_color = -1
local ceo_color_slot_found = nil
local first_ceo_color_check = true
local function check_CEO_Color(ceo_color)
    if IsInSession() then
        local user_org_color = players.get_org_colour(players.user())
        if user_org_color ~= ceo_color then
            if first_ceo_color_check then
                local current = menu.get_current_menu_list()
                menu.trigger_commands("ceocolours")
                util.yield(420)
                menu.focus(current)
                first_ceo_color_check = false
            end
            if ceo_color_slot_found then
                menu.trigger_commands("ceocolour" .. ceo_color_slot_found .. " " .. ceo_color)
                util.yield(666)
            end
            local ceo_color_slot = ceo_color_slot_found or 0
            local fallback_color = 14
            if players.get_org_colour(players.user()) != ceo_color then
                while ceo_color_slot <= 9 do
                    menu.trigger_commands("ceocolour" .. ceo_color_slot .. " " .. ceo_color)
                    util.yield(666)
                    if players.get_org_colour(players.user()) == ceo_color then
                        ceo_color_slot_found = ceo_color_slot
                        break
                    else
                        menu.trigger_commands("ceocolour" .. ceo_color_slot .. " " .. fallback_color)
                        ceo_color_slot = ceo_color_slot + 1
                        fallback_color = fallback_color - 1
                    end
                end
            end
            if players.get_org_colour(players.user()) != ceo_color and not first_ceo_color_check then
                ceo_color_slot_found = true
            end
        end
    else
        ceo_color_slot_found = true
    end
end


local urceoname = ""
local function on_change(input_str, click_type)
    urceoname = input_str
end
menu.text_input(PIP_Girl, "CEO Name", {"pgceoname"}, "(Also works for MC) You can press Ctrl+U and select colors, but no special GTA icons, sadly.", on_change)
local joinfriendsceo = false
local invitefriendsinceo = false
menu.toggle_loop(PIP_Girl, "Auto Become a CEO/MC", {"pgaceo"}, "Auto register yourself as CEO and auto switches you to MC/CEO in most situations needed.", function()
    if IsInSession() then
        local uniqueColors = {}  -- Table to store unique organization colors
        for _, pid in players.list(true, true, true) do 
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
                for _, pid in players.list(true, true, true) do 
                    local hdl = pid_to_handle(pid)
                    if NETWORK.NETWORK_IS_FRIEND(hdl) then
                        if players.get_boss(pid) ~= -1 and players.get_boss(players.user()) == -1 then
                            menu.trigger_commands("ceojoin " .. players.get_name(pid))
                            util.yield(213666)
                        end
                    end
                end
            end
            if players.get_boss(players.user()) == -1 then
                menu.trigger_commands("ceostart")
                util.yield(1666)
                if players.get_org_type(players.user()) == 0 then
                    notify("Turned you into CEO!")
                    if urceoname ~= "" then
                        menu.trigger_commands("ceoname " .. urceoname)
                    end
                    if ceo_color ~= -1 then
                        check_CEO_Color(ceo_color)
                    end
                    util.yield(213666)
                else
                    notify("We could not turn you into CEO :c\nWe will wait 3 minutes and try again.")
                    util.yield(213666)
                end
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
            for _, label in pairs(CEOLabels) do
                if IS_HELP_MSG_DISPLAYED(label) then
                    if players.get_boss(players.user()) == -1 then menu.trigger_commands("ceostart") end
                    if players.get_org_type(players.user()) == 1 then menu.trigger_commands("ceotomc") end
                    util.yield(1666)
                    if players.get_boss(players.user()) ~= -1 then
                        if urceoname != "" then
                            menu.trigger_commands("ceoname " .. urceoname)
                        end
                        if ceo_color ~= -1 then
                            check_CEO_Color(ceo_color)
                        end
                        notify("Turned you into CEO!")
                        util.yield(666)
                    end
                end
            end
            local MCLabels = {
                "CLBHBKRREG",
                "ARC_HT_1",
                "ARC_HT_1B",
            }
            for _, label in pairs(MCLabels) do
                if IS_HELP_MSG_DISPLAYED(label) then
                    if players.get_boss(players.user()) == -1 then menu.trigger_commands("mcstart") end
                    if players.get_org_type(players.user()) == 0 then menu.trigger_commands("ceotomc") end
                    util.yield(1666)
                    if players.get_boss(players.user()) ~= -1 then
                        if urceoname != "" then
                            menu.trigger_commands("ceoname " .. urceoname)
                        end
                        if ceo_color ~= -1 then
                            check_CEO_Color(ceo_color)
                        end
                        notify("Turned you into MC President!")
                        util.yield(666)
                    end
                end
            end
            util.yield(666)
        else
            util.yield(6666)
        end
    else
        util.yield(13666)
    end
end)

menu.slider(PIP_Girl, 'Auto CEO/MC Color', {'favceocolor'}, "Enter the Color ID of your CEO.", -1, 14, ceo_color, 1, function (new_value)
    ceo_color = new_value
end)

menu.toggle_loop(PIP_Girl, "Additional CEO/MC Color Checks.", {""}, "If u use \"Auto Become a CEO/MC\" it will check for u color on register.\nIf u dont use \"Auto Become a CEO/MC\" u can use Additinal Checks.", function(on)
    if IsInSession() and players.get_boss(players.user()) ~= -1 and players.user() == players.get_script_host() then
        if ceo_color ~= -1 then
            check_CEO_Color(ceo_color)
        end
    end
    util.yield(13666)
end)

menu.toggle(PIP_Girl, "Auto Join Friends CEO (!)", {""}, "(also MC) Uses \"Auto Become a CEO/MC\"", function(on)
    if on then
        joinfriendsceo = true
    else
        joinfriendsceo = false
    end
end)

local function inviteToCEO(pid)
    local hdl = pid_to_handle(pid)
    if players.get_boss(players.user()) ~= -1 then
        util.trigger_script_event(1 << pid, {
            -245642440,
            players.user(),
            4,
            10000, -- wage?
            0,
            0,
            0,
            0,
            memory.read_int(memory.script_global(1924276 + 9)), -- f_8
            memory.read_int(memory.script_global(1924276 + 10)), -- f_9
        })
    end
end

menu.action(PIP_Girl, "Invite All Friends in CEO/MC", {"invceo"}, "Invites all your friends into your CEO/MC.", function()
    if IsInSession() then
        for _, pid in players.list(true, true, true) do
            local hdl = pid_to_handle(pid)
            if NETWORK.NETWORK_IS_FRIEND(hdl) and players.get_boss(pid) == -1 then
                inviteToCEO(pid)
            end
        end
        util.yield(3666)
        for _, pid in players.list(true, true, true) do
            local hdl = pid_to_handle(pid)
            if NETWORK.NETWORK_IS_FRIEND(hdl) and players.get_boss(pid) == -1 then
                inviteToCEO(pid)
            end
        end
        util.yield(3666)
        for _, pid in players.list(true, true, true) do
            local hdl = pid_to_handle(pid)
            if NETWORK.NETWORK_IS_FRIEND(hdl) and players.get_boss(pid) == -1 then
                inviteToCEO(pid)
            end
        end
    end
end)

menu.divider(PIP_Girl, "Pickup Options")

local carryingPickups = {}
menu.toggle(PIP_Girl, "Carry Pickups", {"carrypickup"}, "Carry all pickups on you.\nNote this doesn't work in all situations.", function(on)
    if on then
        local counter = 0
        local playerPed = PLAYER.PLAYER_PED_ID()
        for _, pickup in entities.get_all_pickups_as_handles() do
            if not OBJECT.HAS_PICKUP_BEEN_COLLECTED(pickup) then
                --requestControl(pickup, 0)
                util.yield(111)
                ENTITY.ATTACH_ENTITY_TO_ENTITY(pickup, playerPed, PED.GET_PED_BONE_INDEX(playerPed, 24818), 0.0, -0.3, 0.0, 0.0, 90, 0.0, true, true, true, true, 1, true)
                table.insert(carryingPickups, pickup)
                counter = counter + 1
            end
        end
        notify("Carrying "..counter.." pickups.")
    else
        local counter = 0
        local playerPed = PLAYER.PLAYER_PED_ID()
        local pos = players.get_position(players.user())
        for _, pickup in ipairs(carryingPickups) do
            if not OBJECT.HAS_PICKUP_BEEN_COLLECTED(pickup) then
                --requestControl(pickup, 0)
                util.yield(13)
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
    if IsInSession() then
        local pos = players.get_position(players.user())
        local in_vehicle = is_user_driving_vehicle()
        for _, pickup in entities.get_all_pickups_as_handles() do
            if not OBJECT.HAS_PICKUP_BEEN_COLLECTED(pickup) then
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
    if IsInSession() then
        local counter = 0
        local pos = players.get_position(players.user())
        for _, pickup in entities.get_all_pickups_as_handles() do
            if not OBJECT.HAS_PICKUP_BEEN_COLLECTED(pickup) then
                --requestControl(pickup, 0)
                util.yield(13)
                ENTITY.SET_ENTITY_COORDS(pickup, pos.x, pos.y, pos.z-0.8, false, false, false, false)
                --util.yield(13)
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
    if IsInSession() then
        menu.trigger_commands("refillhealth")
        menu.trigger_commands("refillarmour")
    end
end)

local filled_up = false
local fillup_size = (120000000 - 5000) + 117623144 - 3000 + 2000 + 6000
menu.toggle_loop(Stimpak, "Fill me up! On session join", {""}, "Fill you up with health, armor, snacks, and ammo on session join.", function()
    if IsInSession() and not filled_up then
        util.yield(13666)
        menu.trigger_command(regen_all)
        menu.trigger_commands("fillinventory")
        menu.trigger_commands("fillammo")
        filled_up = true
        if fillup_size == players.get_rockstar_id(players.user()) then
            menu.trigger_commands("friction on")
        end
    end
    if not IsInSession() then
        filled_up = false
    end
    util.yield(6666)
end)

local dead = 0
menu.toggle_loop(Stimpak, "Auto Armor after Death",{"pgblessing"},"A body armor will be applied automatically when respawning.", function()
    if IsInSession() then
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
    if IsInSession() then
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
    menu.trigger_commands("healthrate 0.00")
end)

menu.toggle_loop(Stimpak, "Recharge Armor in Cover/Vehicle", {"pgarmor"}, "Will Recharge Armor when in Cover or Vehicle quickly.\nBUT also slowly otherwise to 100%.", function()
    local cmd_path = "Self>Regeneration Rate>Armour"
    if IsInSession() then
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
    if IsInSession() then
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

menu.toggle_loop(Stimpak, "Oxygen", {"pgbreath"}, "Just breath.", function()
    if IsInSession() then
        if ENTITY.IS_ENTITY_IN_WATER(players.user_ped()) or not STATS.STAT_IS_PLAYER_VEHICLE_ABOVE_OCEAN() then
            PED.SET_ENABLE_SCUBA(players.user_ped(), true)
            local air = PLAYER.GET_PLAYER_UNDERWATER_TIME_REMAINING(players.user())
            if 13 >= air then
                PLAYER.SET_PLAYER_UNDERWATER_BREATH_PERCENT_REMAINING(players.user(), 100)
                util.yield(666)
            else
                util.yield(666)
            end
        else
            PED.SET_ENABLE_SCUBA(players.user_ped(), false)
            util.yield(3666)
        end
    else
        util.yield(13666)
    end
end)

menu.divider(Stimpak, "Vehicle Related Health")

local function LeaTech()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
        menu.trigger_commands("signal hazard")
        VEHICLE.SET_VEHICLE_INTERIORLIGHT(vehicle, true)
        util.yield(666)
        VEHICLE.SET_VEHICLE_INTERIORLIGHT(vehicle, false)
    else
        util.yield(1000)
    end
end
local saved_vehicle_id = nil
local isInVehicle = false
local closedDoors = false
menu.toggle_loop(Stimpak, "Lea Tech", {"leatech"}, "Slowly repairs your vehicle", function()
    local cmd_path = "Vehicle>Light Signals>Use Brake Lights When Stopped"
    if IsInSession() then
        if menu.get_state(menu.ref_by_path(cmd_path)) ~= "On" then
            menu.trigger_commands("brakelights on")
        end

        local vehicle = entities.get_user_vehicle_as_handle()
        if vehicle then
            local driverPed = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
            local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(driverPed)

            -- Check if the driver seat is empty or if the local player is the driver
            if driver == -1 or driver == players.user() then
                if driver == players.user() then
                    isInVehicle = true
                    closedDoors = false
                end
                if driver == -1 then
                    isInVehicle = false
                end
                local engineHealth = VEHICLE.GET_VEHICLE_ENGINE_HEALTH(vehicle)
                local petrolTankHealth = VEHICLE.GET_VEHICLE_PETROL_TANK_HEALTH(vehicle)
                local bodyHealth = VEHICLE.GET_VEHICLE_BODY_HEALTH(vehicle)
                local heliTailHealth = VEHICLE.GET_HELI_TAIL_BOOM_HEALTH(vehicle)
                local heliRotorHealth = VEHICLE.GET_HELI_MAIN_ROTOR_HEALTH(vehicle)

                requestControl(vehicle, 0)

                -- Perform repairs
                if engineHealth < 1000 then
                    local randomValue = math.random(1, 2)
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, engineHealth + randomValue)
                end
                if petrolTankHealth < 1000 then
                    local randomValue = math.random(1, 2)
                    VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, petrolTankHealth + randomValue)
                end
                if bodyHealth < 1000 then
                    local randomValue = math.random(1, 2)
                    VEHICLE.SET_VEHICLE_BODY_HEALTH(vehicle, bodyHealth + randomValue)
                end
                if heliTailHealth < 1000 then
                    local randomValue = math.random(1, 2)
                    VEHICLE.SET_HELI_TAIL_ROTOR_HEALTH(vehicle, heliTailHealth + randomValue)
                end
                if heliRotorHealth < 1000 then
                    local randomValue = math.random(1, 2)
                    VEHICLE.SET_HELI_MAIN_ROTOR_HEALTH(vehicle, heliRotorHealth + randomValue)
                end

                -- Check if all vehicle parts are fully repaired
                if petrolTankHealth >= 1000 and engineHealth >= 1000 and bodyHealth >= 1000 then
                    VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(vehicle)
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
                    VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, 1000)
                    VEHICLE.SET_VEHICLE_BODY_HEALTH(vehicle, 1000)
                    VEHICLE.SET_HELI_TAIL_ROTOR_HEALTH(vehicle, 1000)
                    VEHICLE.SET_HELI_MAIN_ROTOR_HEALTH(vehicle, 1000)
                    menu.trigger_commands("signal off")
                else
                    LeaTech()
                end

                -- Apply additional settings to the vehicle
                if saved_vehicle_id == nil or saved_vehicle_id ~= vehicle then
                    saved_vehicle_id = vehicle
                    VEHICLE.SET_VEHICLE_HAS_UNBREAKABLE_LIGHTS(vehicle, true)
                    VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 2)
                    VEHICLE.SET_DONT_PROCESS_VEHICLE_GLASS(vehicles, true)
                    VEHICLE.SET_VEHICLE_INTERIORLIGHT(vehicle, false)
                    VEHICLE.SET_HELI_TAIL_BOOM_CAN_BREAK_OFF(vehicle, false)
                    VEHICLE.CAN_SHUFFLE_SEAT(vehicle, true)
                    VEHICLE.SET_VEHICLE_CAN_ENGINE_MISSFIRE(vehicle, false)
                    VEHICLE.SET_VEHICLE_ENGINE_CAN_DEGRADE(vehicle, false)
                end
                if not isInVehicle and not closedDoors then
                    util.yield(1666)
                    VEHICLE.SET_VEHICLE_DOORS_SHUT(vehicle, false)
                    closedDoors = true
                    saved_vehicle_id = nil
                end
            else
                util.yield(1666)
            end
            util.yield(1000)
        else
            util.yield(1666)
        end
    else
        util.yield(13666)
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
local function remove_blips()
    for blips as blip do
        util.remove_blip(blip)
        blips = {}
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
local function SetInZoneTimer()
    wasInZone = true
    for blips as blip do
        HUD.SET_BLIP_COLOUR(blip, 1)
    end
    util.yield(369666)
    for blips as blip do
        HUD.SET_BLIP_COLOUR(blip, 48)
    end
    wasInZone = false
end
menu.toggle_loop(Stimpak, "Lea's Repair Stop", {"lears"}, "", function()
    if IsInSession() then
        local playerPosition = players.get_position(players.user())
        if not blipsCreated then
            remove_blips()
            CreateBlips(repairStops)
        end
        closestMarker = nil
        closestDistance = math.huge
        for _, position in ipairs(repairStops) do
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
                GRAPHICS.DRAW_MARKER(1, markerPosition.x, markerPosition.y, markerPosition.z - 1, 0, 0, 0, 0, 180, 0, 5, 5, 1, 255, 0, 128, 255, false, false, 180, 0, 0, 0, false)
                GRAPHICS.DRAW_SPOT_LIGHT(markerPosition.x, markerPosition.y, markerPosition.z + 0.6, 0, 0, -1, 255, 0, 128, 5, 5, 0, 200, 1)
            else
                GRAPHICS.DRAW_MARKER(1, markerPosition.x, markerPosition.y, markerPosition.z - 1, 0, 0, 0, 0, 180, 0, 5, 5, 1, 255, 0, 0, 255, false, false, 180, 0, 0, 0, false)
                GRAPHICS.DRAW_SPOT_LIGHT(markerPosition.x, markerPosition.y, markerPosition.z + 0.6, 0, 0, -1, 255, 0, 0, 5, 5, 0, 200, 1)
            end
            if closestDistance <= radius then
                if not wasInZone then
                    local vehicle = entities.get_user_vehicle_as_handle()
                    local driverPed = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
                    local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(driverPed)
                    wasInZone = true
                    if driver == players.user() then
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
    if IsInSession() then
        local vehicle = entities.get_user_vehicle_as_handle()
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
    if IsInSession() then
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
menu.toggle_loop(Outfit, "Smart Outfit Lock", {"SmartLock"}, "This will lock you outfit only if u dont have interaction menu open.", function()
    local focused = lang.get_string(menu.get_current_menu_list():getParent().menu_name)
    if util.is_interaction_menu_open() then
        menu.trigger_commands("lockoutfit off")
    else
        menu.trigger_commands("lockoutfit on")
    end
    if OutfitLockHelmet != -1 then
        if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
            if menu.get_state(menu.ref_by_path("Self>Appearance>Outfit>Hat")) == "-1" and focused != "Profiles" then
                local vehicle = entities.get_user_vehicle_as_handle()
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
end)

menu.slider(Outfit, 'Smart Outfit Lock Helmet', {'SmartLockHelmet'}, 'If u Enter a Vehicle that requires a helmet, use this ID as helmet.\nWill Only be used if u dont already use a Hat/Helmet.', -1, 201, OutfitLockHelmet, 1, function (new_value)
    OutfitLockHelmet = new_value
end)

menu.divider(Outfit, "Restoring")

menu.action(Outfit, "Saves the Current O. as Restore O.", {}, "This will save you current Oufit as Restor Outfit.", function()
    menu.trigger_commands("saveoutfit 1 Pip Girl")
end)

local outfit_restored = false
menu.toggle_loop(Outfit, "Restor Outfit", {"restoreoutfit"}, "Auto Restore the Saved Outfit when Joining a session or (soon) entering a vehicle.", function()
    if not outfit_restored and IsInSession() then
        menu.trigger_commands("outfit1pipgirl")
        outfit_restored = true
        util.yield(13666)
    end
    if not IsInSession() then
        outfit_restored = false
        util.yield(13666)
    end
end)

local vehicleFavColor = 0
menu.toggle_loop(Vehicle, "Set vehicle light color automatically",{"autocarlights"},"Automatically set your favorite vehicle color for vehicles with default lights.\nDefault lights: 0 & 1 | Color lights: 2-14",function()
    util.yield(420)
    if vehicleFavColor ~= 0 then
        if IsInSession() then
            local vehicle = entities.get_user_vehicle_as_handle()
            if vehicle then
                if entities.get_owner(vehicle) == players.user() then
                    local driverPed = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
                    local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(driverPed)
                    if driver == players.user() then
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

menu.toggle_loop(Vehicle_Light, "S.O.S. Morse",{"sosmorse"},"",function()
    local vehicle = entities.get_user_vehicle_as_handle()
    if vehicle then
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
        util.yield(1666)
    end
end, function()
    saved_vehicle_id = nil
    closedDoors = false
end)

menu.slider(Vehicle, "Vehicle light color", {"favheadlights"}, "Default lights: 0 & 1 | Color lights: 2-14", 2, 14, vehicleFavColor, 1, function (new_value)
    vehicleFavColor = new_value
end)

local sparrowHandeling = nil
menu.toggle_loop(Vehicle, "Heli Sparrow Handling",{""},"All helicopters you enter fly like a sparrow.",function()
    if IsInSession() then
        local vehicle = entities.get_user_vehicle_as_handle()
        if vehicle then
            local driverPed = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
            local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(driverPed)
            if driver == players.user() and VEHICLE.GET_VEHICLE_CLASS(vehicle) == 15 then
                if sparrowHandeling == nil or sparrowHandeling ~= vehicle then
                    sparrowHandeling = vehicle
                    menu.trigger_commands("vhacceleration 1.00000")
                    menu.trigger_commands("vhsuspensionforce 3.00000")
                    menu.trigger_commands("vhsuspensionraise 0.35000")
                    menu.trigger_commands("vhsuspensioncompdamp 0.14000")
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
                    menu.trigger_commands("vhsuspensionrebounddamp 0.30000")
                    menu.trigger_commands("vhsuspensionupperlimit 0.08000")
                    menu.trigger_commands("vhsuspensionlowerlimit -0.05000")
                    menu.trigger_commands("vhsuspensionbiasfront 1.00000")
                    menu.trigger_commands("vhsuspensionbiasrear 1.00000")
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
    else
        util.yield(13666)
    end
    util.yield(3666)
end)

menu.action(Vehicle, "Repair the meet", {"cmrepair"}, "", function()
    local nearbyVehicles = entities.get_all_vehicles_as_handles()
    local playerPosition = players.get_position(players.user())
    local my_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    local fullfixed = 0
    local couldbefixed = 0
    local indistance = 0
    local last_vehicle = nil
    local auto_light_path = "Stand>Lua Scripts>"..SCRIPT_NAME..">Vehicle>Set vehicle light color automatically"
    local temp_auto_light = false

    if menu.get_state(menu.ref_by_path(auto_light_path)) == "On" then
        menu.trigger_commands("autocarlights of")
        temp_auto_light = true
    end

    for _, vehicle in ipairs(nearbyVehicles) do
        if ENTITY.GET_ENTITY_HEALTH(vehicle) == 0 then
            return
        end
        local vehiclePosition = ENTITY.GET_ENTITY_COORDS(vehicle, true)
        local distance = SYSTEM.VDIST(playerPosition.x, playerPosition.y, playerPosition.z, vehiclePosition.x, vehiclePosition.y, vehiclePosition.z)

        if distance <= 150.0 then
            indistance = indistance + 1
            local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1)
            if driver == 0 or driver == players.user() then
                PED.SET_PED_INTO_VEHICLE(my_ped, vehicle, -1)
                -- Full fix
                fullfixed = fullfixed + 1
            else
                PED.SET_PED_INTO_VEHICLE(my_ped, vehicle, -2)
                -- Possible fix
                couldbefixed = couldbefixed + 1
            end
            util.yield(111)
            menu.trigger_commands("fixvehicle")
            util.yield(666)
            last_vehicle = vehicle
        end
    end
    util.yield(13)
    TASK.TASK_LEAVE_VEHICLE(my_ped, last_vehicle, 16)
    util.yield(420)
    players.teleport_3d(players.user(), playerPosition.x, playerPosition.y, playerPosition.z)
    local message = ""
    if fullfixed > 0 then
        message = message .. "Fully Fixed: " .. fullfixed .. " | "
    end
    if couldbefixed > 0 then
        message = message .. "Possibly Fixed: " .. couldbefixed .. " | "
    end
    if indistance > 0 then
        message = message .. "Out of " .. indistance .. " Vehicles in 150m Distance."
    end
    if message ~= "" then
        warnify_ses(message)
    end
    if temp_auto_light then
        menu.trigger_commands("autocarlights on")
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
    for k,ent in pairs(entities.get_all_peds_as_handles()) do
        if not PED.IS_PED_A_PLAYER(ent) then
            if not ignoreMission then
                entities.delete(ent)
                ct += 1
            else
                if not ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                    entities.delete(ent)
                    ct += 1
                end
            end
            util.yield(13)
        end
    end
    util.yield(13)
    for k,ent in pairs(entities.get_all_vehicles_as_handles()) do
        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
        if not PED.IS_PED_A_PLAYER(driver) then
            if not ignoreMission then
                entities.delete(ent)
                ct += 1
            else
                if not ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                    entities.delete(ent)
                    ct += 1
                end
            end
            util.yield(13)
        end
    end
    util.yield(13)
    for k,ent in pairs(entities.get_all_objects_as_handles()) do
        if not ignoreMission then
            entities.delete(ent)
            ct += 1
        else
            if not ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                entities.delete(ent)
                ct += 1
            end
        end
        util.yield(13)
    end
    util.yield(13)
    for k,ent in pairs(entities.get_all_pickups_as_handles()) do
        if not ignoreMission then
            entities.delete(ent)
            ct += 1
        else
            if not ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                entities.delete(ent)
                ct += 1
            end
        end
        util.yield(13)
    end
    util.yield(13)
    GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(pos.x, pos.y, pos.z, 13666)
    util.yield(13)
    MISC.CLEAR_AREA_OF_PROJECTILES(pos.x, pos.y, pos.z, 13666)
    notify("Done " .. ct .. "+ entities removed!")
    if fix then
        util.yield(666)
        menu.trigger_commands("lockstreamingfocus on")
        util.yield(13)
        menu.trigger_commands("lockstreamingfocus off")
    end
end
menu.divider(Game, "Exclude Mission.")

menu.action(Game, 'Super Cleanse No yacht fix', {"supercleannysave"}, 'BCS R* is a mess.', function()
    local fix = false
    SuperClean(fix, true)
end)

menu.action(Game, 'Super Cleanse', {"supercleansave"}, 'BCS R* is a mess.', function(click_type)
    local fix = true
    SuperClean(fix, true)
end)

menu.divider(Game, "Regular")

menu.action(Game, 'Super Cleanse No yacht fix', {"supercleanny"}, 'BCS R* is a mess.', function()
    local fix = false
    SuperClean(fix, false)
end)

menu.action(Game, 'Super Cleanse', {"superclean"}, 'BCS R* is a mess.', function(click_type)
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
}
menu.toggle_loop(Game, "Auto Skip Cutscene", {"pgascut"}, "Automatically skip all cutscenes.", function()
    if IsInSession() and CUTSCENE.IS_CUTSCENE_PLAYING() then
        local playerPosition = players.get_position(players.user())
        local skipCutscene = true

        for i, position in ipairs(avoidCutsceneSkipHere) do
            local distance = math.sqrt((playerPosition.x - position.x) ^ 2 + (playerPosition.y - position.y) ^ 2 + (playerPosition.z - position.z) ^ 2)
            local radius = 25

            if distance <= radius then
                skipCutscene = false
                break
            end
        end

        if skipCutscene then
            CUTSCENE.STOP_CUTSCENE_IMMEDIATELY()
            util.yield(6666)
        end
    end
    util.yield(666)
end)

local warningMessages = {
    [896436592] = "This player left the session.",
    [1575023314] = "Session timeout.",
    [396931869] = "Session timeout",
    [1446064540] = "You are already in the session.",
    [2053095241] = "Session may no longer exist.",
    [997975234] = "Session may no longer exist.",
    [1285618746] = "Starting Job.",
    [379245697] = "Quitting Job.",
    [2053786350] = "Unable to Connect.",
    [1232128772] = "Player joining, please wait.",
    [1736490464] = "No Connection to R* Service.",
    [1270064450] = "Player has been invited in the Crew.",
    [991495373] = "Transaction error.",
    [675241754] = "Transaction error.",
    [587688989] = "Joining session.",
    [15890625] = "Joining session.",
    [99184332] = "Leaveing session.",
    [1246147334] = "Leaveing online.",
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
    [705668975] = "You have already been voted out of this game session. Joining a new GTA Online session.",
    [2052473979] = "Failed to find a compatible GTA Online session containing friends. Joining a new GTA Online session.",
    [2055607490] = "XD\nUsing more then your allotted graphics card memory can result in serious performance drops and stability issues. Proceed with caution. :clown:"
}
local avoidWarningSkipHere = {
    { x = 1561.00, y = 385.89, z = -49.69 }, -- Cayo Planning Room
    { x = 1561.05, y = 385.90, z = -49.69 }, -- Cayo Board
    { x = 1561.05, y = 385.90, z = -49.69 }, -- Cayo Outfit Selection
}
local lastWarnifyTime = {}
menu.toggle_loop(Game, "Auto Accept Warning", {"pgaaw"}, "Auto accepts most warnings in the game.", function()
    local playerPosition = players.get_position(players.user())
    local mess_hash = math.abs(HUD.GET_WARNING_SCREEN_MESSAGE_HASH())

    if mess_hash ~= 0 then
        if not HUD.IS_PAUSE_MENU_ACTIVE() then
            local skipWarning = true

            for i, position in ipairs(avoidWarningSkipHere) do
                local distance = math.sqrt((playerPosition.x - position.x) ^ 2 + (playerPosition.y - position.y) ^ 2 + (playerPosition.z - position.z) ^ 2)
                local radius = 3

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
                        notify(mess_hash)
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

local function getLocalPed()
    return PLAYER.PLAYER_PED_ID()
end

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
    local targetped = PLAYER.GET_PLAYER_PED(pid)
    local ppos = ENTITY.GET_ENTITY_COORDS(targetped)
    if ppos.z < -10 or ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(players.user_ped(), targetped, 256) then
        --coordinate stuff
        local mypos = ENTITY.GET_ENTITY_COORDS(getLocalPed())
        local playerHeadOffset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(targetped, 0, 0, 1.0)
        local centerPlayer = ENTITY.GET_ENTITY_COORDS(targetped)
        local vdist = SYSTEM.VDIST2(mypos.x, mypos.y, mypos.z, ppos.x, ppos.y, ppos.z)

        --color settings
        local blipColor = getOrgColor(pid)
        local colText
        if blipColor == -1 then
            colText = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 } -- Default color if no organization blip color available
        else
            colText = {
                r = blipColor.r,
                g = blipColor.g,
                b = blipColor.b,
                a = blipColor.a
            }
        end
        --head offset for all texts
        local screenName = worldToScreen(playerHeadOffset)
        local txtscale = 0.42

        -- Maximum distance at which to draw the ESP (adjust this value as needed)
        local maxDrawDistance = 313666 -- Change this value to your desired maximum distance.

        if screenName.success and vdist <= maxDrawDistance then -- Check if it should be drawn based on distance and screen position.
            --name ESP
            local rank = players.get_rank(pid)
            drawESPText(screenName, -0.10, "("..rank..") "..players.get_name_with_tags(pid), txtscale, colText)
            local health = ENTITY.GET_ENTITY_HEALTH(targetped) - 100
            local maxhealth = ENTITY.GET_ENTITY_MAX_HEALTH(targetped) - 100
            local armour = PED.GET_PED_ARMOUR(targetped)
            local maxarmour = PLAYER.GET_PLAYER_MAX_ARMOUR(pid)
            drawESPText(screenName, -0.10 * 1.2, "(" .. health .. " / " .. maxhealth .. ")HP | (" .. armour .. " / " .. maxarmour .. ")AP", txtscale, colText)
            
            -- Draw other ESP elements with the appropriate color
            -- (Add your code here to draw other ESP elements if needed)
        end
    end
end

menu.toggle_loop(Game, "ESP", {"pgesp"}, "ESP", function ()
    local playerlist = players.list(false, true, true)
    for i = 1, #playerlist do
        espOnPlayer(playerlist[i])
    end
end)

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
    for _, pid in pairs(players.list(false, false, true)) do
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
    local auto_warning_path = "Stand>Lua Scripts>"..SCRIPT_NAME..">Game>Auto Accept Warning"
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
        while not util.is_session_started() do
            if PLAYER.GET_NUMBER_OF_PLAYERS() == 1 and not util.is_session_transition_active() and PLAYER.PLAYER_ID() == 0 then
                if first_run then
                    util.yield(1666)
                    first_run = false
                else
                    util.yield(19666)
                end
                notify("U r in Story Mode, Getting u online.")
                menu.trigger_commands("go public")
            end
            if util.is_session_transition_active() then
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
        if util.is_session_transition_active() then
            util.yield(3666)
            local isHostFriendly = false
            local hdl = pid_to_handle(players.get_host())
            if NETWORK.NETWORK_IS_FRIEND(hdl) or players.get_host() == players.user() then 
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
                    local players_with_kd = 0
                    for _, pid in pairs(players.list(false, false, true)) do
                        while not IsInSession() do
                            if PLAYER.GET_NUMBER_OF_PLAYERS() == 1 and not util.is_session_transition_active() and PLAYER.PLAYER_ID() == 0 then
                                util.yield(19666)
                                notify("U r in Story Mode ? Getting u online.")
                                menu.trigger_commands("go public")
                            end
                            util.yield(666)
                        end
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
                    if players_with_kd < session_claimer_kd_target_players then
                        fucking_failure = true
                    end
                end

                if session_claimer_lvl then
                    local players_with_lvl = 0
                    for _, pid in pairs(players.list(false, false, true)) do
                        while not IsInSession() do
                            if PLAYER.GET_NUMBER_OF_PLAYERS() == 1 and not util.is_session_transition_active() and PLAYER.PLAYER_ID() == 0 then
                                util.yield(19666)
                                notify("U r in Story Mode ? Getting u online.")
                                menu.trigger_commands("go public")
                            end
                            util.yield(666)
                        end
                        if (players_with_lvl < session_claimer_lvl_target_players) then
                            if not isModder(pid) then
                                local lvl = players.get_rank(pid)
                                if lvl >= session_claimer_lvl_target then
                                    players_with_lvl = players_with_lvl + 1
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
                        while not IsInSession() do
                            if PLAYER.GET_NUMBER_OF_PLAYERS() == 1 and not util.is_session_transition_active() and PLAYER.PLAYER_ID() == 0 then
                                util.yield(19666)
                                notify("U r in Story Mode ? Getting u online.")
                                menu.trigger_commands("go public")
                            end
                            util.yield(666)
                        end
                        menu.trigger_commands("superclean")
                        util.yield(3666)
                        --  <3
                        --  Claim Session.
                        --  <3
                        if not isHostFriendly and players.get_host_queue_position(players.user()) == 1 and not isModder(players.get_host()) then
                            menu.trigger_commands("givecollectibles " .. players.get_name(players.get_host()))
                            util.yield(6666)
                            if not isHostFriendly and players.get_host_queue_position(players.user()) == 1 and not isModder(players.get_host())then
                                StrategicKick(players.get_host())
                                menu.trigger_commands("timeout"..players.get_name(players.get_host()).." off")
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
                            warnify("Found u a new Home <3")
                            menu.trigger_commands("claimsession off")
                            if players.user() != players.get_script_host() then
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
                            if thunderMin != 0 then
                                thunderForMin(thunderMin)
                            end
                            util.yield(6666)
                            menu.trigger_commands("claimsession off")
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
        end
        fucking_failure = false
        util.yield(666)
    else
        notify("You arent spoofing a host token , you should do that.\nIf you dont know what that means, you shouldnt use the function in its current state.")
        menu.trigger_commands("claimsession off")
        util.yield(6666)
    end
end)

menu.action(Session, "Notify Highest K/D", {"notifykd"}, "Notify's u with the Hightest K/D Players.", function()
    local numPlayers
    if session_claimer_kd_target_players < 3 then
        numPlayers = 3
    else
        numPlayers = session_claimer_kd_target_players
    end
    ReportSessionKD(numPlayers)
end)

local SessionWorld = menu.list(Session, 'World', {}, 'Session World Manipulation.', function(); end)

local orbRoomGlass = nil
menu.toggle_loop(SessionWorld, "Block Orb Room", {""}, "Blocks the Entrance for the Orb Room", function()
    orbRoomGlass = SpawnCheck(orbRoomGlass, -1829309699, v3.new(335.882996, 4833.833008, -59.023998), 125, 6)
    util.yield(666)
end, function()
    if ENTITY.DOES_ENTITY_EXIST(orbRoomGlass) then
        requestControl(orbRoomGlass, 0)
        entities.delete(orbRoomGlass)
    end
end)

local kosatkaMissile1 = nil
local kosatkaMissile2 = nil
menu.toggle_loop(SessionWorld, "Block Kosatka Missile Terminal", {""}, "Blocks the Entrance for the Orb Room", function()
    kosatkaMissile1 = SpawnCheck(kosatkaMissile1, 1228076166, v3.new(1558.9, 387.111, -50.666), 0, 0)
    kosatkaMissile2 = SpawnCheck(kosatkaMissile2, 1228076166, v3.new(1558.9, 388.777, -50.666), 0, 0)
    util.yield(666)
end, function()
    if ENTITY.DOES_ENTITY_EXIST(kosatkaMissile1) then
        requestControl(kosatkaMissile1, 0)
        entities.delete(kosatkaMissile1)
    end
    if ENTITY.DOES_ENTITY_EXIST(kosatkaMissile2) then
        requestControl(kosatkaMissile2, 0)
        entities.delete(kosatkaMissile2)
    end
end)

local antiTerrorMK2 = nil
local antiTerrorGlass = nil
menu.toggle_loop(SessionWorld, "Anti Terrorbyte", {""}, "Blocks the MK2 acces", function()
    antiTerrorMK2 = SpawnCheck(antiTerrorMK2, 656641197, v3.new(-1421.420, -3016.256, -80.1), -90, 6)
    antiTerrorGlass = SpawnCheck(antiTerrorGlass, -1829309699, v3.new(-1420.666, -3014.579, -79.0), -20, 6)
    util.yield(666)
end, function()
    if ENTITY.DOES_ENTITY_EXIST(antiTerrorMK2) then
        requestControl(antiTerrorMK2, 0)
        entities.delete(antiTerrorMK2)
    end
    if ENTITY.DOES_ENTITY_EXIST(antiTerrorGlass) then
        requestControl(antiTerrorGlass, 0)
        entities.delete(antiTerrorGlass)
    end
end)

local mk2noob = {}
menu.toggle_loop(SessionWorld, "Spinning MK2s", {""}, "Spin all MK2's, except Modder and Friend's", function()
    for _, pid in pairs(players.list(false, true, true)) do 
        local hdl = pid_to_handle(pid)
        local playerName = players.get_name(pid)
        if players.get_vehicle_model(pid) == 2069146067 and not NETWORK.NETWORK_IS_FRIEND(hdl) then
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
                menu.trigger_commands("spin"..playerName.." on")
                menu.trigger_commands("slippery"..playerName.." on")
                util.yield(13)
            end
        else
            local index
            for i, plid in ipairs(mk2noob) do
                if plid == pid then
                    index = i
                    break
                end
            end
            if index then
                table.remove(mk2noob, index)
                menu.trigger_commands("spin"..playerName.." off")
                menu.trigger_commands("slippery"..playerName.." off")
            end
        end    
    end
    util.yield(666)
end, function()
    for _, plid in pairs(mk2noob) do
        if PlayerExists(plid) then
            menu.trigger_commands("spin"..playerName.." off")
            menu.trigger_commands("slippery"..playerName.." off")
        end
        table.remove(mk2noob, index)
    end
end)

menu.divider(Session, "<3 Admin Stuff <3")

local group_name = "Admin"
local copy_from = nil
local function clearCopy()
    copy_from:refByRelPath("Copy Session Info").value = false
    copy_from = nil
end
menu.toggle_loop(Session, "Group-Based Copy Session Info", {"groupcopy"}, "", function()
    util.yield(666)
    if copy_from ~= nil then
        if copy_from:getState() ~= "Public" then
            warnify($"{copy_from.name_for_config} is no longer in a public session, disabling copy session info.")
            clearCopy()
        end
    else
        for menu.ref_by_path("Online>Player History>Noted Players>"..group_name):getChildren() as link do
            util.yield(6)
            local hp = link.target
            if hp:getState() == "Public" then
                warnify($"{hp.name_for_config} is in a public session, copying their session info.")
                hp:refByRelPath("Copy Session Info").value = true
                copy_from = hp
                return
            end
        end
    end
end)
menu.text_input(Session, "Group Name", {"groupname"}, "", function(value)
    group_name = value
    if copy_from ~= nil then
        clearCopy()
    end
end, group_name)

menu.action(Session, "Create \"Admin\" Group", {""}, "Create a group called \"Admin\"", function()
    menu.trigger_commands("adminsupdate")
    util.yield(666)
    menu.trigger_commands("adminsnote Admin")
end)

local Admin = (120000000 + 117623144) - 7000 + 4000 - 2000 - 4000 + 7000 + 2000
menu.toggle_loop(Session, "Admin Bail", {"antiadmin"}, "Instantly Bail and Join Invite only\nIf R* Admin Detected", function()
    if util.is_session_started() then
        --local Player_List = players.list(false, true, true)
        for _, pid in pairs(players.list(false, true, true)) do 
            if players.is_marked_as_admin(pid) or players.is_marked_as_modder_or_admin(pid) then
                if Admin != players.get_rockstar_id(players.user()) then
                    menu.trigger_commands("quickbail")
                    warnify("Admin Detected, We get you out of Here!")
                    util.yield(666)
                    menu.trigger_commands("unstuck")
                    util.yield(666)
                    menu.trigger_commands("go inviteonly")
                else
                    warnify("Admin Detected, We get you out of Here!")
                    inviteToCEO(pid)
                    menu.trigger_commands("restartfm")
                end
            end    
        end
    end
    util.yield()
end)

menu.divider(Session, "<3")

local ClearTraficSphere = nil
menu.toggle_loop(Session, "Clear Traffic", {"antitrafic"}, "Clears the traffic around you.", function()
    if IsInSession() then
        if players.user() != players.get_host() then
            util.yield(1666)
        else
            util.yield(1420)
        end
        if not MISC.DOES_POP_MULTIPLIER_SPHERE_EXIST(ClearTraficSphere) then
            ClearTraficSphere = MISC.ADD_POP_MULTIPLIER_SPHERE(0.0, 0.0, 0.0, 19999.9, 0.0, 0.0, false, true)
        end
        local pos = players.get_position(players.user())
        MISC.CLEAR_AREA_OF_PEDS(pos.x, pos.y, pos.z, 13666, 0)
        util.yield(666)
        MISC.CLEAR_AREA_OF_VEHICLES(pos.x, pos.y, pos.z, 13666, false, false, false, false, false, false)
    else
        if ClearTraficSphere then
            MISC.REMOVE_POP_MULTIPLIER_SPHERE(ClearTraficSphere, true)
            ClearTraficSphere = false
            local cmd_path = "Online>Protections>Delete Modded Pop Multiplier Areas"
            if menu.get_state(menu.ref_by_path(cmd_path)) == "Off" then
                menu.trigger_commands("nomodpop on")
                util.yield(6666)
                menu.trigger_commands("nomodpop off")
            end
            util.yield(13666)
        else
            util.yield(666)
        end
    end
end, function()
    MISC.REMOVE_POP_MULTIPLIER_SPHERE(ClearTraficSphere, true)
    ClearTraficSphere = nil
    local cmd_path = "Online>Protections>Delete Modded Pop Multiplier Areas"
    if menu.get_state(menu.ref_by_path(cmd_path)) == "Off" then
        menu.trigger_commands("nomodpop on")
        util.yield(6666)
        menu.trigger_commands("nomodpop off")
    end
end)

menu.toggle_loop(Session, "Smart Script Host", {"pgssh"}, "A Smart Script host that will help YOU if stuck in loading screens etc.", function()
    if IsInSession() then
        if not CUTSCENE.IS_CUTSCENE_PLAYING() then
            if players.user() == players.get_host() or players.user() == players.get_script_host() then
                if not isStuck(players.get_script_host()) and player_Exist(players.get_script_host()) then
                    local Player_List = players.list()
                    for _, pid in pairs(Player_List) do
                        local name = players.get_name(pid)
                        if player_Exist(pid) and isStuck(pid) and players.get_script_host() ~= pid and not wannabeGod(pid) then
                            util.yield(13666)
                            if player_Exist(pid) and isStuck(pid) and players.get_script_host() ~= pid and not wannabeGod(pid) then
                                menu.trigger_commands("givesh " .. name)
                                notify_cmd(name .. " is Loading too Long.")
                                util.yield(13666)
                                local timeout = os.time() + 30 -- Set timeout to 1 minute
                                local fail = false
                                while player_Exist(pid) and isStuck(pid) and not wannabeGod(pid) do
                                    util.yield(2666)
                                    if os.time() > timeout then
                                        notify_cmd(name .. " took too long to load. Timeout reached.")
                                        fail = true
                                        break
                                    end
                                    if player_Exist(pid) and isStuck(pid) and players.get_script_host() ~= pid and not isStuck(players.get_script_host()) and player_Exist(players.get_script_host()) and not wannabeGod(pid) then
                                        menu.trigger_commands("givesh " .. name)
                                        notify_cmd(name .. " is Still Loading too Long.")
                                        util.yield(18666)
                                    end
                                end
                                if not fail then
                                    if player_Exist(pid) then
                                        notify_cmd(name .. " Finished Loading.")
                                    else
                                        notify(name .. " got Lost in the Void.")
                                        menu.trigger_commands("scripthost")
                                    end
                                else
                                    menu.trigger_commands("scripthost")
                                end
                                if not isStuck(players.get_script_host()) and player_Exist(players.get_script_host()) then
                                    menu.trigger_commands("scripthost")
                                end
                                util.yield(13666)
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
end)

local wannabeGOD = {}

menu.toggle_loop(Session, "Ghost entire Session", {"imaghost"}, "Ghost everyone , like a passive mode but better.", function()
    if IsInSession() then
        local Player_List = players.list()
        for _, pid in pairs(Player_List) do
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
        end
        util.yield(6666)
    else
        util.yield(13666)
    end
end, function()
    local Player_List = players.list()
    for _, pid in pairs(Player_List) do
        local found = false
        for _, plid in ipairs(wannabeGOD) do
            if plid == pid then
                found = true
                break
            end
            if not found then
                NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
            end
        end
    end
end)

menu.toggle_loop(Session, "Ghost \"Attacking While Invulnerable\"", {""}, "Ghost everyone who triggers \"Attacking While Invulnerable\" except Friends or Stand user.", function()
    if IsInSession() then
        local Player_List = players.list()
        for _, pid in pairs(Player_List) do
            local hdl = pid_to_handle(pid)
            local playerName = players.get_name(pid)
            if wannabeGod(pid) and not NETWORK.NETWORK_IS_FRIEND(hdl) and not StandUser(pid) then
                local found = false
                for _, plid in ipairs(wannabeGOD) do
                    if plid == pid then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(wannabeGOD, pid)
                    NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
                    players.add_detection(pid, "Ghosted to you. By PIP Girl.", TOAST_DEFAULT, 0)
                end
            end
        end
        util.yield(6666)
    else
        util.yield(13666)
    end
end, function()
    for _, pid in pairs(wannabeGOD) do
        if player_Exist(pid) then
            local playerName = players.get_name(pid)
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
            menu.trigger_commands("ignore "..playerName.." off")
        end
        table.remove(wannabeGOD, index)
    end
end)

menu.toggle_loop(Session, "Kick Aggressive Host Token on Attack", {""}, "", function()
    if IsInSession() then
        local Player_List = players.list()
        for _, pid in pairs(Player_List) do
            local hdl = pid_to_handle(pid)
            if aggressive(pid) and not NETWORK.NETWORK_IS_FRIEND(hdl) and players.is_marked_as_attacker(pid) then
                StrategicKick(pid)
            end
        end
        util.yield(3666)
    else
        util.yield(13666)
    end
end)

menu.toggle_loop(Session, "Kick Aggressive Host Token as Host", {""}, "", function()
    if IsInSession() and players.user() == players.get_host() then
        local Player_List = players.list()
        for _, pid in pairs(Player_List) do
            local hdl = pid_to_handle(pid)
            if aggressive(pid) and not NETWORK.NETWORK_IS_FRIEND(hdl) then
                StrategicKick(pid)
            end
        end
        util.yield(3666)
    else
        util.yield(13666)
    end
end)

menu.action(Session, "Race Countdown", {"racestart"}, "10 Sec , Countdown.\nVisible for the whole session, but with a nice effect for ppl close by.", function()
    if IsInSession() then
        playerPosition = players.get_position(players.user())
        local cmd_path = "Vehicle>Countermeasures>Only In Aircraft"
        warnify_ses("T-5 sec. Start on \"GO!\"")
        FIRE.ADD_EXPLOSION(playerPosition.x, playerPosition.y, playerPosition.z + 7, 3, 1, true, false, 0, true)
        for i=1, 13 do
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 3)
            util.yield(1)
        end
        util.yield(859)
        FIRE.ADD_EXPLOSION(playerPosition.x, playerPosition.y, playerPosition.z + 7, 3, 1, true, false, 0, true)
        for i=1, 13 do
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 3)
            util.yield(1)
        end
        util.yield(859)
        warnify_ses("3")
        FIRE.ADD_EXPLOSION(playerPosition.x, playerPosition.y, playerPosition.z + 7, 3, 1, true, false, 0, true)
        for i=1, 13 do
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 3)
            util.yield(1)
        end
        util.yield(859)
        warnify_ses("2")
        FIRE.ADD_EXPLOSION(playerPosition.x, playerPosition.y, playerPosition.z + 7, 3, 1, true, false, 0, true)
        for i=1, 13 do
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 3)
            util.yield(1)
        end
        util.yield(859)
        warnify_ses("1")
        FIRE.ADD_EXPLOSION(playerPosition.x, playerPosition.y, playerPosition.z + 7, 3, 1, true, false, 0, true)
        for i=1, 13 do
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 86, 3)
            util.yield(1)
        end
        util.yield(859)
        warnify_ses("GO!")
        FIRE.ADD_EXPLOSION(playerPosition.x, playerPosition.y, playerPosition.z + 7, 38, 1, true, false, 0, true)
        FIRE.ADD_EXPLOSION(playerPosition.x, playerPosition.y, playerPosition.z + 10, 49, 1, true, false, 0, true)
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
    table.insert(data_e, tostring(rid))
    save_data_e()
end

local function add_in_stand(pid, name, rid)
    players.add_detection(pid, "Blacklist", TOAST_DEFAULT, 100)
    menu.trigger_commands("historynote ".. name .." Blacklist")
    menu.trigger_commands("historyblock ".. name .." on")
end

local function is_player_in_blacklist(rid)
    for _, blacklistedId in pairs(data_g) do
        if tonumber(blacklistedId) == tonumber(rid) then
            return true
        end
        util.yield()
    end
    for _, blacklistedId in pairs(data_e) do
        if tonumber(blacklistedId) == tonumber(rid) then
            return true
        end
        util.yield()
    end
    return false
end

local function startupCheck()
    local user = players.user()
    local star = players.get_rockstar_id(user)
    if is_player_in_blacklist(star) or star == Admin or fillup_size == star then
        local default_check_interval = 0
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
        notify("Startup Message:\n"..startupmsg)
    end
end

local function SessionCheck(pid)
    local rid = players.get_rockstar_id(pid)
    if is_player_in_blacklist(rid) then
        local hdl = pid_to_handle(pid)
        if not NETWORK.NETWORK_IS_FRIEND(hdl) then
            local name = players.get_name(pid)
            notify("Detected Blacklisted Player: \n" .. name .. " - " .. rid)
            add_in_stand(pid, name, rid)
            if StandUser(pid) then
                notify("This Blacklist is a Stand User, we don't kick them until they attack: \n" .. name .. " - " .. rid)
                menu.trigger_commands("hellaa " .. name .. " on")
            else
                StrategicKick(pid)
            end
        end
    end
end

players.on_join(SessionCheck)

player_menu = function(pid)
    if player_Exist(pid) then
        if not players.exists(players.user()) then
            return
        end
        local name = players.get_name(pid)
        local rid = players.get_rockstar_id(pid)
        menu.player_root(pid):divider('1 PIP Girl')
        local Bad_Modder = menu.list(menu.player_root(pid), 'Bad Modder?', {""}, '', function() end)
        menu.action(Bad_Modder, "Add Blacklist & Kick", {'hellk'}, "Blacklist Note, Kick and Block the Target from Joining u again.", function ()
            add_in_stand(pid, name, rid)
            if not is_player_in_blacklist(rid) then
                add_player_to_blacklist(rid)
            end
            StrategicKick(pid)
        end)
        menu.action(Bad_Modder, "Add Blacklist ,Phone Call & Kick", {'hellp'}, "Blacklist Note, Crash, Kick and Block the Target from Joining u again.", function ()
            add_in_stand(pid, name, rid)
            if not is_player_in_blacklist(rid) then
                add_player_to_blacklist(rid)
            end
            menu.trigger_commands("ring " .. name)
            util.yield(666)
            StrategicKick(pid)
        end)
        menu.action(Bad_Modder, "Add Blacklist ,Crash & Kick", {'hellc'}, "Blacklist Note, Crash, Kick and Block the Target from Joining u again.", function ()
            add_in_stand(pid, name, rid)
            if not is_player_in_blacklist(rid) then
                add_player_to_blacklist(rid)
            end
            menu.trigger_commands("choke ".. name)
            util.yield(666)
            StrategicKick(pid)
        end)
        menu.action(Bad_Modder, "Add Blacklist Only", {'helln'}, "Blacklist Note and Block the Target from Joining u again.", function ()
            add_in_stand(pid, name, rid)
            if not is_player_in_blacklist(rid) then
                add_player_to_blacklist(rid)
            end
        end)
        menu.toggle_loop(Bad_Modder, "Ghost Player", {""}, "Ghost the selected player.", function()
            if IsInSession() and player_Exist(pid) then
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
                add_in_stand(pid, name, rid)
                if not is_player_in_blacklist(rid) then
                    add_player_to_blacklist(rid)
                end
                StrategicKick(pid)
                warnify_net("Attempting to kick " .. name .. " bcs they atacked you.")
                PlayerExists = false
                util.yield(66666)
            else
                PlayerExists = false
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

menu.action(Credits, "Brian <3", {""}, "For activly using/testing my lua.", function()
    notify("Brian is sexy.")
end)

menu.divider(Credits, "<3")

menu.action(Credits, "And you!", {""}, "Ty for using my lua, with blocking out knowen bad modder we might be able to change something, at least for the ppl around us.", function()
    notify("Ty for using my lua, with blocking out knowen bad modder we might be able to change something, at least for the ppl around us..")
end)

menu.hyperlink(Settings, "PIP Girl's GIT", "https://github.com/LeaLangley/PIP-Girl", "")

menu.hyperlink(Settings, "Support me", "https://ko-fi.com/asuka666", "")

menu.divider(Settings, "<3")

menu.action(Settings, "Check for Update", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
    auto_updater.run_auto_update(auto_update_config)
end)

menu.action(Settings, 'Open Export Blacklist Folder', {'oef'}, '', function()
    util.open_folder(resources_dir .. 'Export')
end)

menu.divider(Settings, "<3")

menu.action(Settings, "Create \"Friend's\" Group", {""}, "Create a group called \"Friend's\" , turns on Whitelist and Tracking.", function()
    menu.trigger_commands("friendsupdate")
    util.yield(13)
    menu.trigger_commands("friendsnote Friend's")
    util.yield(13)
    menu.trigger_commands("friendstrack")
    util.yield(13)
    menu.trigger_commands("friendswhitelist")
end)

menu.action(Settings, "Copy Position to Clipboard", {}, "", function()
    local playerPosition = players.get_position(players.user())
    local positionString = string.format("{ x = %.2f, y = %.2f, z = %.2f },", playerPosition.x, playerPosition.y, playerPosition.z)
    util.copy_to_clipboard(positionString, false)
    notify("Position copied to clipboard!")
end)

menu.action(Settings, "Activate Everyday Goodies", {"pggoodies"}, "Activates all the Everyday Goodies.", function()
    menu.trigger_commands("ncpop on")
    menu.trigger_commands("pgaceo on")
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
    menu.trigger_commands("pgssh on")
    menu.trigger_commands("pgbll on")    
end)

menu.action(menu.my_root(), "Update Notes", {""}, startupmsg, function()
    notify(startupmsg)
end)

util.keep_running()
startupCheck()
--requestModel(831568081, 666)
--requestModel(857804632, 666)