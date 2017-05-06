--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
require("config")
local dataTable = {}
local query_tab = { samba_server_enabled = {query = "ctlusb:settings/samba-server-enabled"},
frominternet = box.frominternet(),
pppoe_ip = {query = "connection0:status/ip"},
interface_ip = {query = "interfaces:settings/lan0/ipaddr"},
ftp_server_enabled = {query = "ctlusb:settings/ftp-server-enabled"},
ftp_password = {query = "ctlusb:settings/ftp-password"},
ddns_activated = {query = "ddns:settings/account0/activated"},
ddns_password = {query = "ddns:settings/account0/password"},
ddns_username = {query = "ddns:settings/account0/username"},
ddns_provider = {query = "ddns:settings/account0/ddnsprovider"},
ddns_domain = {query = "ddns:settings/account0/domain"},
isAtaMode = {query = "box:settings/ata_mode"},
connectiontype = {query = "connection0:settings/type"},
share_name = {query = "ctlusb:settings/fritznas_share"},
opmode = {query = "box:settings/opmode"},
wds_enabled = {query = "wlan:settings/WDS_enabled"},
wds_mode = {query = "wlan:settings/WDS_hop"},
internal_flash_enabled = {query = "ctlusb:settings/internalflash_enabled"}}
local meta_dataTable = {}
meta_dataTable.__index = function(tab, key)
local result = nil
if query_tab[key]~=nil then
if type(query_tab[key])=="table" and query_tab[key].query then
result = box.query(query_tab[key].query)
tab[key] = result
return result
else
tab[key] = query_tab[key]
return tab[key]
end
elseif key == "storage_directories" or key == "storage_directories_cnt" then
require("general")
result = general.listquery("storagedirectories:settings/directory/list(path,status)")
for i, dir in ipairs(result) do
dir.access = general.listquery("storagedirectories:settings/"..dir._node.."/access0/entry/list(username,boxusers_UID,write_access_from_local,access_from_internet,write_access_from_internet,access_from_local)")
end
tab.storage_directories = result
tab.storage_directories_cnt = #tab.storage_directories
return result
elseif key == "forward_rules" then
require("general")
for i,v in pairs(general.listquery("forwardrules:settings/rule/list(description,activated)")) do
if v.description == "FTP-Server" and v.activated == "1" then
tab[key] = true
return tab[key]
end
end
tab[key] = false
return tab[key]
end
return nil
end
setmetatable(dataTable,meta_dataTable)
function get_storage_link(protocol, display_link_name, path_extension)
local link_body = ""
if path_extension == [[internal_memory]] then
path_extension = "/"
end
if string.find(protocol,"http")~=nil then
return '<a href="'..get_href_part_of_link("http", path_extension)..'" target="_blank">'..box.tohtml(display_link_name)..'</a>'
end
--[[Dies ist erstmal raus da der IE9 den Aufruf von Samba per Link nicht mehr gewährt.]]
link_body = ""
if string.find(protocol,"ftp")~=nil then
if dataTable.ftp_server_enabled == "1" then
link_body = get_href_part_of_link("ftp", path_extension)
if link_body == "" then
return box.tohtml(display_link_name)
else
return '<a href="'..link_body..'" target="_blank">'..box.tohtml(display_link_name)..'</a>'
end
else
return box.tohtml(display_link_name)
end
end
return ""
end
function lan_write_activ()
for i, dir in ipairs(dataTable.storage_directories) do
--Nur der root path interressiert da in ihm die rechte für den lokalen Zugriff enthalten sind
if dir.path=="/" and dir.status=="1" then
for j, access in ipairs(dir.access) do
if access.write_access_from_local=="1" then
return true
end
end
end
end
return false
end
function get_nas_user_dirs(userid)
local dir_tab = {}
if userid == "" then return dataTable.storage_directories end
--gehe alle directories durch
for i, dir in ipairs(dataTable.storage_directories) do
--gehe alle rechte für dieses directory durch
for j, access in ipairs(dir.access) do
--schaue ob boxusers_UID gleich der userid ist
if access.boxusers_UID == userid then
--wenn ja gebe das dir zurück
dir_tab[#dir_tab+1] = dir
end
end
end
return dir_tab
end
function check_ftp_portfw_activ()
return dataTable.forward_rules
end
function dir_is_available(search_dir)
--gehe alle directories durch
for i, dir in ipairs(dataTable.storage_directories) do
--gehe alle rechte für dieses directory durch
if dir.path == search_dir then
return dir.status == "1"
end
end
return false
end
g_usb_devices = nil
function get_usb_devices_list()
if g_usb_devices==nil then
require("usb_devices")
g_usb_devices = usb_devices.get_list_of_usb_mem_devices()
end
return g_usb_devices
end
function aura_for_storage_aktiv()
require("usb_devices")
return usb_devices.aura_for_storage_aktiv()
end
function check_usb_available()
for i, v in ipairs(get_usb_devices_list()) do
if v.name ~= nil and v.name ~= "" then
return true
end
end
return false
end
function check_any_usb_writeable()
for i, v in ipairs(get_usb_devices_list()) do
if v.devtype == "storage" and v.any_log then
for j,logvol in ipairs(v.log_vol) do
if not logvol.readonly then
return true
end
end
end
end
return false
end
function internal_memory_available()
if config.RAMDISK or config.NAND then
return dataTable.internal_flash_enabled == "1"
end
return false
end
function check_usb_useable()
for i, v in ipairs(get_usb_devices_list()) do
if v.any_log and tonumber(v.capacity) ~= nil and tonumber(v.capacity) > 0 then
return true
end
end
return false
end
function memory_available()
return (not(aura_for_storage_aktiv()) and check_usb_useable()) or internal_memory_available()
end
function speicher_nas_activ()
return ((not config.SAMBA) or (config.SAMBA and dataTable.samba_server_enabled == "1")) and dataTable.ftp_server_enabled == "1" and memory_available()
end
function internet_sharing_activ_for_storage(sharing_dir)
--schau nach ob das dir das freigabeverzeichniss ist oder sich das freigabe verzeichnis sich auf dem sharing_dir befindet
for i, dir in ipairs(dataTable.storage_directories) do
for j, access in ipairs(dir.access) do
if dir.path == '/' and access.access_from_internet == "1" then
return sharing_dir
elseif string.find(dir.path..'/', sharing_dir, 1, true) == 1 and access.access_from_internet == "1" then
return '/'
end
end
end
return ""
end
function get_href_part_of_link(protocol, path_extension)
local link_head = ""
local link_ip = ""
if path_extension~="" then
if string.sub(path_extension,1,1)~="/" then
path_extension = "/"..path_extension
end
local len=string.len(path_extension)
if string.sub(path_extension, len, len) ~= "/" then
path_extension = path_extension.."/"
end
end
if dataTable.frominternet == true then
path_extension = internet_sharing_activ_for_storage(path_extension)
if string.find(protocol,"http")~=nil or path_extension ~= "" then
if dataTable.pppoe_ip and (dataTable.pppoe_ip=="-" or dataTable.pppoe_ip=="er" or dataTable.pppoe_ip=="0.0.0.0") then
dataTable.pppoe_ip=""
end
if dataTable.ddns_activated=="1" and dataTable.ddns_password~="" and dataTable.ddns_username~="" and dataTable.ddns_provider~="" then
link_ip = dataTable.ddns_domain
else
link_ip = dataTable.pppoe_ip
end
else
link_ip = ""
end
else
if (dataTable.isAtaMode=="1" or not(config.DSL)) and dataTable.connectiontype=="bridge" then
link_ip = dataTable.pppoe_ip
else
link_ip = dataTable.interface_ip
end
end
if string.find(protocol,"http")~=nil then
--local prefix = "http://"
--if box.glob.secure then prefix = "https://" end
return path_extension
end
if string.find(protocol,"ftp")~=nil and link_ip ~= "" then
return 'ftp://'..link_head..link_ip..path_extension
end
return ""
end
