--[[
__________._____________    ________.__       .__   
\______   \   \______   \  /  _____/|__|______|  |  
 |     ___/   ||     ___/ /   \  ___|  \_  __ \  |  
 |    |   |   ||    |     \    \_\  \  ||  | \/  |__
 |____|   |___||____|      \________/__||__|  |____/                
]]--

local SCRIPT_VERSION = "0.0.10"

-- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
local status, auto_updater = pcall(require, "auto-updater")
if not status then
    local auto_update_complete = nil util.toast("<[Pip Girl]>: Installing auto-updater...", TOAST_ALL)
    async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
        function(result, headers, status_code)
            local function parse_auto_update_result(result, headers, status_code)
                local error_prefix = "<[Pip Girl]>: Error downloading auto-updater: "
                if status_code ~= 200 then util.toast(error_prefix..status_code, TOAST_ALL) return false end
                if not result or result == "" then util.toast(error_prefix.."Found empty file.", TOAST_ALL) return false end
                filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                if file == nil then util.toast(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                file:write(result) file:close() util.toast("<[Pip Girl]>: Successfully installed auto-updater lib", TOAST_ALL) return true
            end
            auto_update_complete = parse_auto_update_result(result, headers, status_code)
        end, function() util.toast("<[Pip Girl]>: Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
    async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
    if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
    auto_updater = require("auto-updater")
end
if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end

--auto_updater.run_auto_update({
--    source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/1%20PIP%20Girl.lua",
--    script_relpath=SCRIPT_RELPATH,
--    verify_file_begins_with="--"
--})

local default_check_interval = 604800
local auto_update_config = {
    source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/1%20PIP%20Girl.lua",
    script_relpath=SCRIPT_RELPATH,
    switch_to_branch=selected_branch,
    verify_file_begins_with="--",
    check_interval=86400,
    silent_updates=true,
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
            check_interval=default_check_interval,
        },
        {
            name="read_me.txt",
            source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/resources/1%20PIP%20Girl/Export/read_me.txt",
            script_relpath="resources/1 PIP Girl/Export/read_me.txt",
            check_interval=default_check_interval,
        },
    }
}
auto_updater.run_auto_update(auto_update_config)

-- Load required dependencies into global namespace
for _, dependency in pairs(auto_update_config.dependencies) do
    if dependency.is_required then
        if dependency.loaded_lib == nil then
            util.toast("<[Pip Girl]>: Error loading lib "..dependency.name, TOAST_ALL)
        else
            local var_name = dependency.name
            _G[var_name] = dependency.loaded_lib
        end
    end
end

util.require_natives(1663599433)
local LOADING_START = util.current_time_millis()
LOADING_SCRIPT = true
Script = {}

resources_dir = filesystem.resources_dir() .. '/1 PIP Girl/'
logo = directx.create_texture(resources_dir .. 'logo.png')
if SCRIPT_MANUAL_START then
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
            if timepassed > 5 then
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
local lua_path = "Stand>Lua Scripts>"..string.gsub(string.gsub(SCRIPT_RELPATH,".lua",""),"\\",">")
local my = menu.my_root() 
local Int_PTR = memory.alloc_int()

local function getMPX()
    return 'MP'.. util.get_char_slot() ..'_'
end

local function STAT_GET_INT(Stat)
    STATS.STAT_GET_INT(util.joaat(getMPX() .. Stat), Int_PTR, -1)
    return memory.read_int(Int_PTR)
end

local function IsInSession()
    return util.is_session_started() and not util.is_session_transition_active()
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

local was_user_in_vehicle = false
function is_user_driving_vehicle()
    return (PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true))
end

local function notify(msg)
    util.toast("<[Pip Girl]>: " .. msg)
end

function START_SCRIPT(ceo_mc, name)
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

function IS_HELP_MSG_DISPLAYED(label)
    HUD.BEGIN_TEXT_COMMAND_IS_THIS_HELP_MESSAGE_BEING_DISPLAYED(label)
    return HUD.END_TEXT_COMMAND_IS_THIS_HELP_MESSAGE_BEING_DISPLAYED(0)
end

local PIP_Girl = menu.list(menu.my_root(), 'PIP Girl', {}, 'Personal Information Processor Girl', function(); end)
local PIP_Girl_APPS = menu.list(PIP_Girl, 'PIP Girl Apps', {}, 'Personal Information Processor Girl Apps', function(); end)
local Stimpak = menu.list(menu.my_root(), 'Stimpak', {}, 'Take a Breath', function(); end)
local Game = menu.list(menu.my_root(), 'Game', {}, '', function(); end)
local Session = menu.list(menu.my_root(), 'Session', {}, 'Session', function(); end)
local Protection = menu.list(menu.my_root(), 'Protection', {}, 'Protect yourself with our todays sponsor .....', function(); end)
local Settings = menu.list(menu.my_root(), 'Settings', {}, '', function(); end)

menu.action(PIP_Girl_APPS, "Master Control Terminal App", {}, "Your Master Control Terminal.", function()
    START_SCRIPT("CEO", "apparcadebusinesshub")
end)

menu.textslider(PIP_Girl_APPS, "Nightclub App", {}, "Your Nightclub Screen.", {
    "Open",
    "Close",
}, function()
    START_SCRIPT("CEO", "appbusinesshub")
end)

menu.textslider(PIP_Girl_APPS, "Bunker App", {}, "Your Bunker Screen.", {
    "Open",
    "Close",
}, function()
    START_SCRIPT("CEO", "appbunkerbusiness")
end)

menu.textslider(PIP_Girl_APPS, "Touchscreen Terminal App", {}, "Your Terrobyte Screen.", {
    "Open",
    "Close",
}, function()
    START_SCRIPT("CEO", "apphackertruck")
end)

menu.textslider(PIP_Girl_APPS, "Air Cargo App", {}, "Your Air Cargo Screen.", {
    "Open",
    "Close",
}, function()
    START_SCRIPT("CEO", "appsmuggler")
end)

menu.textslider(PIP_Girl_APPS, "The Open Road App", {}, "Your MC Management Screen.", {
    "Open",
    "Close",
}, function()
    START_SCRIPT("MC", "appbikerbusiness")
end)

menu.textslider(PIP_Girl_APPS, "The Agency App", {}, "Your Agnecy Screen", {
    "Open",
    "Close",
}, function()
    START_SCRIPT("CEO", "appfixersecurity")
end)

menu.action(PIP_Girl_APPS, "(Unstuck) Unstuck after start sell.", {}, "If you Use one of the screens above, And start a sell, You could get stuck.\nDo Suicide to Unstuck.", function()
    menu.trigger_commands('ewo')
end)

menu.toggle_loop(PIP_Girl, 'Nightclub Party Never Stops!', {'ncpop'}, 'The hottest NC in whole LS.\nKeeps you pop at 90-100%', function ()
    if IsInSession() then
        local ncpop = math.floor(STAT_GET_INT('CLUB_POPULARITY') / 10)
        if ncpop < 91 then
            menu.trigger_commands('clubpopularity 100')
            notify('New NC Gusts have Arived.')
            util.yield(666)
        end
        util.yield(666)
    end
    util.yield(6666)
end)

menu.toggle_loop(PIP_Girl, "Auto Become a CEO/MC", {}, "Auto Register youself as CEO and Auto Switches you to MC/CEO in most Situations needed.", function()
    if IsInSession() then
        if players.get_boss(players.user()) == -1 then
            menu.trigger_commands("ceostart")
            util.yield(6666)
            if players.get_org_type(players.user()) == 0 then
                notify("Turned you into CEO!")
            else
                notify("We could not turn u CEO :c\nWe wait 3min and try again.")
                util.yield(200000)
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
                notify("Turned you into CEO!")
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
                notify("Turned you into MC President!")
            end
        end
        util.yield(666)
    end
    util.yield(6666)
end)

menu.action(PIP_Girl, 'Cayo Preset (!)', {}, 'Set up the cayo heist with a Sweet Legit Like Preset.\nNOTE!: it will try to trigger a HC lua CMD to refreash the Planning screen.\nIf you have HC not active, go manually out and in again.\nNote that R* has implemented a limit that prevents you from earning more than $2.550.000 per run or more than $4.100.000 per hour from this heist per person.', function (click_type)
    menu.show_warning(PIP_Girl, click_type, 'Want to set up cayo?', function()
        if IsInSession() then
            STAT_SET_INT("H4_MISSIONS", -1)
            STAT_SET_INT("H4CNF_APPROACH", -1)
            STAT_SET_INT("H4CNF_BS_ENTR", 63)
            STAT_SET_INT("H4CNF_BS_GEN", 63)
            STAT_SET_INT("H4CNF_WEAPONS", 2)
            STAT_SET_INT("H4CNF_WEP_DISRP", 3)
            STAT_SET_INT("H4CNF_ARM_DISRP", 3)
            STAT_SET_INT("H4CNF_HEL_DISRP", 3)
            STAT_SET_INT("H4CNF_TARGET", 5)
            STAT_SET_INT("H4CNF_BOLTCUT", 4424)
            STAT_SET_INT("H4CNF_UNIFORM", 5256)
            STAT_SET_INT("H4CNF_GRAPPEL", 5156)
            STAT_SET_INT("H4CNF_TROJAN", 4)
            STAT_SET_INT("H4LOOT_CASH_I", 1835011)
            STAT_SET_INT("H4LOOT_CASH_I_SCOPED", 1835011)
            STAT_SET_INT("H4LOOT_CASH_C", 2)
            STAT_SET_INT("H4LOOT_CASH_C_SCOPED", 2)
            STAT_SET_INT("H4LOOT_COKE_I", 200716)
            STAT_SET_INT("H4LOOT_COKE_I_SCOPED", 200716)
            STAT_SET_INT("H4LOOT_COKE_C", 0)
            STAT_SET_INT("H4LOOT_COKE_C_SCOPED", 0)
            STAT_SET_INT("H4LOOT_GOLD_I", 0)
            STAT_SET_INT("H4LOOT_GOLD_I_SCOPED", 0)
            STAT_SET_INT("H4LOOT_GOLD_C", 221)
            STAT_SET_INT("H4LOOT_GOLD_C_SCOPED", 221)
            STAT_SET_INT("H4LOOT_WEED_I", 4203696)
            STAT_SET_INT("H4LOOT_WEED_I_SCOPED", 4203696)
            STAT_SET_INT("H4LOOT_WEED_C", 0)
            STAT_SET_INT("H4LOOT_WEED_C_SCOPED", 0)
            STAT_SET_INT("H4LOOT_PAINT", 24)
            STAT_SET_INT("H4LOOT_PAINT_SCOPED", 24)
            STAT_SET_INT("H4LOOT_CASH_V", 315681)
            STAT_SET_INT("H4LOOT_COKE_V", 631363)
            STAT_SET_INT("H4LOOT_GOLD_V", 841817)
            STAT_SET_INT("H4LOOT_PAINT_V", 631363)
            STAT_SET_INT("H4LOOT_WEED_V", 420908)
            STAT_SET_INT("H4_PROGRESS", 131055)
            util.yield(1)
            menu.trigger_commands("hccprefreshboard")
            util.yield(1)
            menu.trigger_commands("fillinventory")
            util.yield(1)
            notify("Cayo Has been setup!")
            util.yield(6000)
            notify("Note that R* has implemented a limit that prevents you from earning more than $2.550.000 per run or more than $4.100.000 per hour from this heist per person.")
            util.yield(2000)
            notify("Note that R* has implemented a limit that prevents you from earning more than $2.550.000 per run or more than $4.100.000 per hour from this heist per person.")
        end
    end, function()
        notify("Aborted.")
    end, true)
end)

menu.action(PIP_Girl, "Teleport Pickups To Me", {}, "Teleports all Pickups To You.\nNote this donst work in all Situations.", function(click_type)
    menu.show_warning(PIP_Girl, click_type, 'You r about to Teleport Pickups!', function()
        local counter = 0
        local pos = players.get_position(players.user())
        for _, pickup in entities.get_all_pickups_as_handles() do
            ENTITY.SET_ENTITY_COORDS(pickup, pos.x, pos.y, pos.z, false, false, false, false)
            counter = counter + 1
            util.yield(1)
        end
        if counter == 0 then
            notify("No Pickups Found. :c")
        else
            notify("Teleported ".. tostring(counter) .." Pickups. :D")
        end
    end)
end)

local regen_all = Stimpak:action("Refill Health & Armour",{"newborn"},"Regenerate to max your health and armour.",function()
    if IsInSession() then
        --ENTITY.SET_ENTITY_HEALTH(players.user_ped(),ENTITY.GET_ENTITY_MAX_HEALTH(players.user_ped()))
        --PED.SET_PED_ARMOUR(players.user_ped(),PLAYER.GET_PLAYER_MAX_ARMOUR(players.user()))
        menu.trigger_commands("refillhealth")
        menu.trigger_commands("refillarmour")
    end
end)

local dead = 0
menu.toggle(Stimpak, "Auto Armor after Death",{},"A body armor will be applied automatically when respawning.",function()
    if IsInSession() then
        menu.trigger_command(regen_all)
        local cmd_path = lua_path..">".."Stimpak"..">".."Auto Armor after Death"
        while menu.get_state(menu.ref_by_path(cmd_path)) == "On" do
            local health = ENTITY.GET_ENTITY_HEALTH(players.user_ped())
            if health == 0 and dead == 0 then
                dead = 1
            elseif health == ENTITY.GET_ENTITY_MAX_HEALTH(players.user_ped()) and dead == 1 then
                menu.trigger_command(regen_all)
                dead = 0
            end
            util.yield(500)
        end
    end
    util.yield(6666)
end)

menu.toggle_loop(Stimpak, "Recharge Health in Cover/Vehicle", {}, "Will Recharge Healt when in Cover or Vehicle quickly.\nBUT also slowly almost legit like otherwise to 100%.", function()
    local cmd_path = "Self>Regeneration Rate>Armour"
    if IsInSession() then
        local in_vehicle = is_user_driving_vehicle()
        local playerPed = players.user_ped()
        local isPlayerInCover = PED.IS_PED_IN_COVER(playerPed, false)
        if ENTITY.GET_ENTITY_HEALTH(players.user_ped()) == ENTITY.GET_ENTITY_MAX_HEALTH(players.user_ped()) then
            if menu.get_state(menu.ref_by_path(cmd_path)) ~= "0.00" then
                menu.trigger_commands("healthrate 0.00")
            end
        else
            if isPlayerInCover or in_vehicle then
                if menu.get_state(menu.ref_by_path(cmd_path)) ~= "6.66" then
                    menu.trigger_commands("healthrate 6.66")
                end
            else
                if menu.get_state(menu.ref_by_path(cmd_path)) ~= "0.01" then
                    menu.trigger_commands("healthrate 0.01")
                end
            end
        end
        util.yield(666)
    else
        if menu.get_state(menu.ref_by_path(cmd_path)) ~= "0.00" then
            menu.trigger_commands("healthrate 0.00")
        end
    end
    util.yield(6666)
end)

menu.toggle_loop(Stimpak, "Recharge Armor in Cover/Vehicle", {}, "Will Recharge Armor when in Cover or Vehicle quickly.\nBUT also slowly otherwise to 100%.", function()
    local cmd_path = "Self>Regeneration Rate>Armour"
    if IsInSession() then
        local in_vehicle = is_user_driving_vehicle()
        local playerPed = players.user_ped()
        local isPlayerInCover = PED.IS_PED_IN_COVER(playerPed, false)
        if PED.GET_PED_ARMOUR(players.user_ped()) == PLAYER.GET_PLAYER_MAX_ARMOUR(players.user()) then
            if menu.get_state(menu.ref_by_path(cmd_path)) ~= "0.00" then
                menu.trigger_commands("armourrate 0.00")
            end
        else
            if isPlayerInCover or in_vehicle then
                if menu.get_state(menu.ref_by_path(cmd_path)) ~= "0.90" then
                    menu.trigger_commands("armourrate 0.90")
                end
            else
                if menu.get_state(menu.ref_by_path(cmd_path)) ~= "0.13" then
                    menu.trigger_commands("armourrate 0.13")
                end
            end
        end
        util.yield(666)
    else
        if menu.get_state(menu.ref_by_path(cmd_path)) ~= "0.00" then
            menu.trigger_commands("armourrate 0.00")
        end
    end
    util.yield(6666)
end)

menu.toggle_loop(Stimpak, "Refill Health/Armor with Vehicle Interaction", {}, "Using your First Aid kit provided in you Vehicle.", function()
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
    end
    util.yield(6666)
end)

menu.action(Stimpak, "(DEBUG) Set Armor/Health to Low", {"dearmor"}, "This is for testing Purpose!\nTurn the options above on and Click this to test them out!", function()
    PED.SET_PED_ARMOUR(players.user_ped(), 0)
    local maxHealth = ENTITY.GET_ENTITY_MAX_HEALTH(players.user_ped())
    local newHealth = math.floor(maxHealth * 0.5)
    ENTITY.SET_ENTITY_HEALTH(players.user_ped(), newHealth)
end)

menu.action(Game, 'Super Cleanse No yacht fix', {"supercleanny"}, 'BCS R* is a mess.', function(click_type)
    menu.show_warning(Game, click_type, 'Really wanna do it huh?', function()
        local ct = 0
        for k,ent in pairs(entities.get_all_vehicles_as_handles()) do
            local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
            if not PED.IS_PED_A_PLAYER(driver) then
                entities.delete_by_handle(ent)
                ct += 1
            end
        end
        for k,ent in pairs(entities.get_all_peds_as_handles()) do
            if not PED.IS_PED_A_PLAYER(ent) then
                entities.delete_by_handle(ent)
            end
            ct += 1
        end
        for k,ent in pairs(entities.get_all_objects_as_handles()) do
            entities.delete_by_handle(ent)
            ct += 1
        end
        local rope_alloc = memory.alloc(4)
        for i=0, 100 do 
            memory.write_int(rope_alloc, i)
            if PHYSICS.DOES_ROPE_EXIST(rope_alloc) then
                PHYSICS.DELETE_ROPE(rope_alloc)
                ct += 1
            end
        end

        menu.trigger_commands("deleteropes")
        notify('Done ' .. ct .. ' entities removed!')
    end, function()
        notify("Aborted.")
    end, true)
end)

menu.action(Game, 'Super Cleanse', {"superclean"}, 'BCS R* is a mess.', function(click_type)
    menu.show_warning(Game, click_type, 'Really wanna do it huh?', function()
        local ct = 0
        for k,ent in pairs(entities.get_all_vehicles_as_handles()) do
            local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, -1)
            if not PED.IS_PED_A_PLAYER(driver) then
                entities.delete_by_handle(ent)
                ct += 1
            end
        end
        for k,ent in pairs(entities.get_all_peds_as_handles()) do
            if not PED.IS_PED_A_PLAYER(ent) then
                entities.delete_by_handle(ent)
            end
            ct += 1
        end
        for k,ent in pairs(entities.get_all_objects_as_handles()) do
            entities.delete_by_handle(ent)
            ct += 1
        end
        local rope_alloc = memory.alloc(4)
        for i=0, 100 do 
            memory.write_int(rope_alloc, i)
            if PHYSICS.DOES_ROPE_EXIST(rope_alloc) then
                PHYSICS.DELETE_ROPE(rope_alloc)
                ct += 1
            end
        end

        menu.trigger_commands("deleteropes")
        notify('Done ' .. ct .. ' entities removed!')
        util.yield(666)
        menu.trigger_commands("lockstreamingfocus on")
        util.yield(13)
        menu.trigger_commands("lockstreamingfocus off")
    end, function()
        notify("Aborted.")
    end, true)
end)

menu.toggle_loop(Game, "Auto Skip Conversation",{},"Automatically skip all conversations.",function()
    if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
        AUDIO.SKIP_TO_NEXT_SCRIPTED_CONVERSATION_LINE()
    end
    util.yield(1)
end)

menu.toggle_loop(Game, "Auto Skip Cutscene (!)",{},"Automatically skip all cutscenes.\nNOTE!: Turn This of if playing heists as it could make you fail.\nKnown Heist are Cayo for now.",function()
    if CUTSCENE.IS_CUTSCENE_PLAYING() then
        CUTSCENE.STOP_CUTSCENE_IMMEDIATELY()
    end
    util.yield(100)
end)

menu.toggle_loop(Game, "Auto Accept Warning",{},"Auto Accepts most Warnings in game, such as:\nFailed Session Join, Session Timeout, Already in Session, Transaction Error, Join Session, Leave Session, Leave Online and Session Full CEO/MC",function()
    local mess_hash = math.abs(HUD.GET_WARNING_SCREEN_MESSAGE_HASH())
    if mess_hash == 896436592 then
        notify("This player left the session.")
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 201, 1)
    elseif mess_hash == 1575023314 then
        notify("Session timeout.")
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 201, 1)
    elseif mess_hash == 1446064540 then
        notify("You are already in the session.")
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 201, 1)
    elseif mess_hash == 2053095241 then
        notify("Session may no longer exist.")
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 201, 1)
    elseif mess_hash == 1285618746 then
        notify("Starting Job.")
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 201, 1)
    elseif mess_hash == 379245697 then
        notify("Quiting Job.")
    elseif mess_hash == 2053786350 then
        notify("Unable to Connect.")
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 201, 1)
    --          transaction error         transaction error (mb)   join session             join session            leave session           leave online                 full of ceo                 cancel cayo               set up cayo
    elseif mess_hash == 991495373 or mess_hash == 675241754 or mess_hash == 587688989 or mess_hash == 15890625 or mess_hash == 99184332 or mess_hash == 1246147334 or mess_hash == 583244483 or mess_hash == 505844183 or mess_hash == 988273680 then
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 201, 1)
    elseif mess_hash ~= 0 then
        notify(mess_hash, TOAST_CONSOLE)
    end
    util.yield(50)
end)

local saved_vehicle_id = nil

menu.toggle_loop(Game, 'Auto Blinkers', {'blinkers'}, 'Set the blinkers when entering vehicle.', function ()
    local in_vehicle = is_user_driving_vehicle()
    local vehicle = entities.get_user_vehicle_as_handle()

    if in_vehicle and (saved_vehicle_id == nil or saved_vehicle_id ~= vehicle) then
        saved_vehicle_id = vehicle
        VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(saved_vehicle_id, 1, true)
        VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(saved_vehicle_id, 0, true)
    end
    if not in_vehicle then
        saved_vehicle_id = nil
    end
    util.yield(666)
end)

menu.toggle_loop(Session, "Admin Bail", {"antiadmin"}, "Instantly Bail and Join Invite only\nIf R* Admin Detected", function()
    if util.is_session_started() then
        for _, pid in players.list(false, true, true) do 
            if players.is_marked_as_admin(pid) or players.is_marked_as_modder_or_admin(pid) then 
                menu.trigger_commands("quickbail")
                notify("Admin Detected, We get you out of Here!")
                util.yield(13)
                menu.trigger_commands("go inviteonly")
            end    
        end
    end
    util.yield(13)
end)

menu.toggle_loop(Session, "Smart Script Host", {""}, "If the Script Host is not in your crew, friend list, or same CEO/MC, you will become Script Host.\nPrevent Atackers from obtaining script host.\nMakes u script host after a Cutscene if u are the host.", function()
    if IsInSession() then
        local script_host_id = players.get_script_host()
        local found = false
        for _, pid in ipairs(players.list(true, true, false, true)) do 
            if pid == script_host_id then
                found = true
                util.yield(6666)
                break
            end
        end
        if not found and not CUTSCENE.IS_CUTSCENE_PLAYING() then
            menu.trigger_commands("scripthost")
            util.yield(30013)
        end
        if script_host_id ~= players.user() then
            if CUTSCENE.IS_CUTSCENE_PLAYING() and players.user() == players.get_host() then
                util.yield(666)
                while CUTSCENE.IS_CUTSCENE_PLAYING() do
                    util.yield(666)
                end
                util.yield(666)
                menu.trigger_commands("scripthost")
                util.yield(6666)
            end
            if players.is_marked_as_attacker(script_host_id) and not CUTSCENE.IS_CUTSCENE_PLAYING() then
                menu.trigger_commands("scripthost")
            end
        end
        util.yield(666)
    end
    util.yield(6666)
end)

menu.toggle_loop(Session, '(Alpha) Smart CEO Money loop', {'sceom'}, '', function ()
    if IsInSession() then
        local player_you = players.user()
        for _, pid in ipairs(players.list(false, false, false, true)) do
            if pid ~= player_you then
                menu.trigger_commands("ceopay".. players.get_name(pid) .." on")
            end
        end
        util.yield(1666)
        for _, pid in ipairs(players.list(false, false, false, true)) do
            if pid ~= player_you then
                menu.trigger_commands("ceopay".. players.get_name(pid) .." off")
            end
        end
        util.yield(300000)
    end
    util.yield(6666)
end)

local max_players = 33
menu.slider(Session, '(Alpha) Session Player Limit', {'setmaxplayer'}, 'Let only up to a certain number of people join that are strangers.', 1, 32, max_players, 1, function (new_value)
    max_players = new_value
end)

local session_limit = 0
menu.toggle_loop(Session, '(Alpha) Activate Session Player Limit', {'maxplayer'}, 'Let only up to a certain number of people join that are strangers.', function (new_value)
    if IsInSession() then
        local numPlayers = 0
        local cmd_path = "Online>Session>Block Joins>From Strangers"
        for _, pid in pairs(players.list()) do
            numPlayers = numPlayers + 1
        end
        if numPlayers > max_players then
            if session_limit ~= 1 then
                if players.user() == players.get_host() then
                    menu.trigger_commands("setsessiontype inviteonly")
                    if menu.get_state(menu.ref_by_path(cmd_path)) == "On" then
                        menu.trigger_commands("blockjoinsstrangers off")
                    end
                else
                    if menu.get_state(menu.ref_by_path(cmd_path)) == "Off" then
                        menu.trigger_commands("blockjoinsstrangers on")
                    end
                end
                session_limit = 1
                notify("More than "..max_players.." players in session, closing joins now!")
                util.yield(666)
            end
        end
        if numPlayers < max_players then
            if session_limit ~= 2 then
                if players.user() == players.get_host() then
                    menu.trigger_commands("setsessiontype public")
                end
                if menu.get_state(menu.ref_by_path(cmd_path)) == "On" then
                    menu.trigger_commands("blockjoinsstrangers off")
                end
                session_limit = 2
                notify("Less than "..max_players.." players in session, open joins now!")
                util.yield(666)
            end
        end
        util.yield(666)    
    end
    util.yield(6666)
end)

local json = require('json')

local data_e = {}

local data_g = {}

local function load_data_e()
    local file = io.open(resources_dir .. 'Export/Export_Blacklist.json', 'r')
    if file then
        local contents = file:read('*all')
        io.close(file)
        data_e = json.decode(contents) or {}
    else
        -- Create a new JSON file with an empty table
        local new_file = io.open(resources_dir .. 'Export/Export_Blacklist.json', 'w')
        if new_file then
            new_file:write("{}")
            io.close(new_file)
            data_e = {}
        else
            -- Failed to create the file
            notify("Failed to create Blacklist.json")
        end
    end
end

local function load_data_g()
    local file = io.open(resources_dir .. 'Blacklist.json', 'r')
    if file then
        local contents = file:read('*all')
        io.close(file)
        local json_data = json.decode(contents) or {}
        data_g = json_data.Blacklist or {}
    end
end

local function save_data_e()
    local file = io.open(resources_dir .. 'Export/Export_Blacklist.json', 'w+')
    if file then
        file:write(json.encode(data_e))
        io.close(file)
    end
end

load_data_e()

load_data_g()

local function add_player_to_blacklist(player)
    local rid = players.get_rockstar_id(player)
    local name = players.get_name(player)
    if rid and name then
        data_e[tostring(rid)] = {
            ["Name"] = name
        }
        save_data_e()
    end
end

local function is_player_in_blacklist(player)
    local rid = players.get_rockstar_id(player)
    if rid then
        local player_data_g = data_g[tostring(rid)]
        if player_data_g then
            local name = players.get_player_name(player)
            if player_data_g.Name ~= name then
                update_player_name(player)
            end
            return true
        else
            local player_data_e = data_e[tostring(rid)]
            if player_data_e then
                return true
            else
                return false
            end
        end
    else
        return false
    end
end

local function update_player_name(player)
    local rid = players.get_rockstar_id(player)
    if rid then
        local player_data_g = data_g[tostring(rid)]
        if player_data_g then
            local name = players.get_player_name(player)
            if player_data_g.Name ~= name then
                player_data_g.Name = name
                data_e[tostring(rid)] = {
                    ["Name"] = name
                }
                save_data_e()
            end
        end
    end
end

menu.action(Protection, 'Import Global Blacklist', {'imp'}, 'Import the Global Blacklist.', function()
    for rid, player in pairs(data_g) do
        local name = player.Name
        menu.trigger_commands("historyaddrid ".. rid)
        util.yield(13)
        menu.trigger_commands("historynote ".. player.Name .." Blacklist")
        menu.trigger_commands("historyblock ".. player.Name .." on")
        notify("RID " .. rid .. ", Name: " .. name ..". Added")
        util.yield(13)
    end
end)

menu.action(Protection, 'Open Export Folder', {'oef'}, '', function()
    util.open_folder(resources_dir .. 'Export')
end)

local joined_session = false

menu.toggle_loop(Protection, 'Kick Blacklist on Join', {''}, 'Kick Blacklisted Modder if detected on Joining a Session.', function()
    if not joined_session and util.is_session_started() then
        joined_session = true
        local player_ids = players.list(false, false, true)
        
        for _, player_id in ipairs(player_ids) do
            local rsid = players.get_rockstar_id(player_id)
            for rid, player in pairs(data_g) do
                if tonumber(rid) == tonumber(rsid) then
                    update_player_name(pid)
                    notify("Matched Player ID: " .. rsid)
                    if players.user() == players.get_host() then
                        menu.trigger_commands("kick " .. players.get_name(player_id))
                    else
                        menu.trigger_commands("ban " .. players.get_name(player_id))
                    end
                end
            end
            for rid, player in pairs(data_e) do
                if tonumber(rid) == tonumber(rsid) then
                    -- update_player_name(player)
                    notify("Matched Player ID: " .. rsid)
                    if players.user() == players.get_host() then
                        menu.trigger_commands("kick " .. players.get_name(player_id))
                    else
                        menu.trigger_commands("ban " .. players.get_name(player_id))
                    end
                end
            end            
        end
    end
    if not util.is_session_started() or util.is_session_transition_active()then
        joined_session = false
        if util.is_session_transition_active() and not util.is_session_started() then
            util.yield(1666)
        else
            util.yield(6666)
        end
    else
        util.yield(20666)
    end
end)

players.add_command_hook(function(pid)
    local friendly_players = players.list(true, false, false, false, true)
    for _, id in ipairs(friendly_players) do
        if pid == id then
            return
        end
    end
    menu.divider(menu.player_root(pid), '1 PIP Girl')
    local Bad_Modder = menu.list(menu.player_root(pid), 'Bad Modder?', friendly_players, '', function() end)
    menu.action(Bad_Modder, "Add Blacklist & Kick", {'hellk'}, "Blacklist Note, Ban Kick and Block the Target from Joining u again.", function ()
        menu.trigger_commands("historynote ".. players.get_name(pid) .." Blacklist")
        menu.trigger_commands("historyblock ".. players.get_name(pid) .." on")
        if not is_player_in_blacklist(pid) then
            add_player_to_blacklist(pid)
        end
        if players.user() == players.get_host() then
            menu.trigger_commands("kick ".. players.get_name(pid))
        else
            menu.trigger_commands("ban ".. players.get_name(pid))
        end
    end)
    menu.action(Bad_Modder, "Add Blacklist ,Phone Call & Kick", {'hellp'}, "Blacklist Note, Crash, Ban Kick and Block the Target from Joining u again.", function ()
        menu.trigger_commands("historynote ".. players.get_name(pid) .." Blacklist")
        menu.trigger_commands("historyblock ".. players.get_name(pid) .." on")
        if not is_player_in_blacklist(pid) then
            add_player_to_blacklist(pid)
        end
        menu.trigger_commands("ring ".. players.get_name(pid))
        util.yield(666)
        if players.user() == players.get_host() then
            menu.trigger_commands("kick ".. players.get_name(pid))
        else
            menu.trigger_commands("ban ".. players.get_name(pid))
        end
    end)
    menu.action(Bad_Modder, "Add Blacklist ,Crash & Kick", {'hellc'}, "Blacklist Note, Crash, Ban Kick and Block the Target from Joining u again.", function ()
        menu.trigger_commands("historynote ".. players.get_name(pid) .." Blacklist")
        menu.trigger_commands("historyblock ".. players.get_name(pid) .." on")
        if not is_player_in_blacklist(pid) then
            add_player_to_blacklist(pid)
        end
        menu.trigger_commands("choke ".. players.get_name(pid))
        util.yield(666)
        if players.user() == players.get_host() then
            menu.trigger_commands("kick ".. players.get_name(pid))
        else
            menu.trigger_commands("ban ".. players.get_name(pid))
        end
    end)
    menu.action(Bad_Modder, "Add Blacklist Only", {'helln'}, "Blacklist Note and Block the Target from Joining u again.", function ()
        menu.trigger_commands("historynote ".. players.get_name(pid) .." Blacklist")
        menu.trigger_commands("historyblock ".. players.get_name(pid) .." on")
        if not is_player_in_blacklist(pid) then
            add_player_to_blacklist(pid)
        end
    end)
end)

menu.hyperlink(Settings, "PIP Girl's GIT", "https://github.com/LeaLangley/PIP-Girl", "")

menu.action(Settings, "Check for Update", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
    auto_updater.run_auto_update(auto_update_config)
end)
