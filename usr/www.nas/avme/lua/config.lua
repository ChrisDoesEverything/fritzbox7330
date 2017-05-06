--[[Access denied<?lua
box.end_page()
?>]]
local function get_config_flag(self, flag)
local value = os.getenv("CONFIG_" .. flag)
if value == nil then
value = false
elseif value == 'y' or value == 'Y' then
value = true
elseif value == 'n' or value == 'N' then
value = false
elseif tonumber(value) then
value = tonumber(value)
end
self[flag] = value
return value
end
config = setmetatable({}, {__index = get_config_flag})
config.oem = os.getenv("OEM") or "avm"
config.language = os.getenv("Language") or "de"
config.country = os.getenv("Country") or "049"
function config.is_known_oem()
local oem = {"avm", "1und1", "otwo","avme", "ewetel"}
for a = 1, #oem do
if oem[a] == config.oem then
return true
end
end
return false
end
local function get_gu_type()
if config.RELEASE == 0 then return 'private' end
if config.RELEASE == 1 then
if config.BETA_RELEASE == 1 then
return "beta"
else
return 'release'
end
end
if config.RELEASE == 2 then return "labor" end
return "release"
end
config.gu_type = get_gu_type()
require("guiflags").import(config)
local function import_flag(bibliothek, flag)
if config[flag] then
config[flag] = require(bibliothek)
else
config[flag] = false
end
end
import_flag("wlanflags", "WLAN")
