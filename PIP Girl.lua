--[[
__________._____________    ________.__       .__   
\______   \   \______   \  /  _____/|__|______|  |  
 |     ___/   ||     ___/ /   \  ___|  \_  __ \  |  
 |    |   |   ||    |     \    \_\  \  ||  | \/  |__
 |____|   |___||____|      \________/__||__|  |____/                
]]--
util.ensure_package_is_installed("lua/auto-updater")
local auto_updater = require("auto-updater")
if not async_http.have_access() then util.toast("U need to allow internet access to download all resources the script needs to work and receive cutting edge updates. <3"); return end
local auto_update_config = {
    source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/PIP%20Girl.pluto",
    script_relpath=SCRIPT_RELPATH,
    verify_file_begins_with="--",
    --auto_restart=false,
    check_interval=0,
    restart_delay=666,
    dependencies={
        {
            name="Asuka_Libiary",
            source_url="https://raw.githubusercontent.com/LeaLangley/Asuka_Library/main/Asuka_Lib.pluto",
            script_relpath="lib/Asuka_Library/Asuka_Lib.pluto",
            check_interval=0,
        },
        {
            name="logo",
            source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/resources/PIP-Girl/logo.png",
            script_relpath="resources/PIP Girl/logo.png",
            check_interval=13666,
        },
        {
            name="blacklist",
            source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/resources/PIP-Girl/Blacklist.json",
            script_relpath="resources/PIP Girl/Blacklist.json",
            check_interval=0,
        },
        {
            name="read_me.txt",
            source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/resources/PIP-Girl/Export/read_me.txt",
            script_relpath="resources/PIP Girl/Export/read_me.txt",
            check_interval=13666,
        },
    }
}
auto_updater.run_auto_update(auto_update_config)