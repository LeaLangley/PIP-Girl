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
    source_url="https://raw.githubusercontent.com/LeaLangley/PIP-Girl/main/PIP-Girl.pluto",
    script_relpath=SCRIPT_RELPATH,
    verify_file_begins_with="--",
    check_interval=0,
}
auto_updater.run_auto_update(auto_update_config)