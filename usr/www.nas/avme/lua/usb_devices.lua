--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
--[[Hier werden alle Funktionen gesammelt, welche mit usb devices zu tun haben. Dazu gehören im besonderen das besorgen der Geräteinformationen.]]
require("config")
require("lualib")
local usb_dev_tab = {}
local usb_properties = {}
if config.AURA then
usb_properties.aura_enabled = {query = "aura:settings/enabled"}
usb_properties.aura_status = {query = "aura:settings/status"}
usb_properties.aura_for_storage = {query = "aura:settings/aura4storage"}
usb_properties.aura_for_printer = {query = "aura:settings/aura4printer"}
usb_properties.aura_for_other = {query = "aura:settings/aura4other"}
usb_properties.aura_dev_list = {multiquery = "aura:settings/device/list(class,manufacturer,client)"}
end
if config.MORPHSTICK then
usb_properties.morph_enabled = {query = "morphstick:settings/enabled"}
usb_properties.morph_partition = {query = "morphstick:settings/partition"}
end
if config.USB_HOST or config.USB_HOST_AVM or config.USB_HOST_TI then
usb_properties.usb_device_count = {query = "ctlusb:settings/device/count"}
usb_properties.phys_dev_list = {multiquery = "usbdevices:settings/physmedium/list(name,vendor,serial,fw_version,conntype,capacity,status,usbspeed,model)"}
usb_properties.phys_dev_list_count = {query = "usbdevices:settings/physmediumcnt"}
usb_properties.log_dev_list = {multiquery = "usbdevices:settings/logvol/list(name,status,enable,phyref,filesystem,capacity,usedspace,readonly)"}
usb_properties.log_dev_list_count = {query = "usbdevices:settings/logvolcnt"}
usb_properties.part_count = {query = "ctlusb:settings/storage-part/count"}
else
usb_properties.usb_device_count = "0"
usb_properties.phys_dev_list = {}
usb_properties.phys_dev_list_count = "0"
usb_properties.log_dev_list = {}
usb_properties.log_dev_list_count = "0"
usb_properties.part_count = "0"
end
local meta_usb_dev = {}
meta_usb_dev.__index = function(tab, key)
local result = nil
if usb_properties[key]~=nil then
if type(usb_properties[key])=="table" and usb_properties[key].query then
result = box.query(usb_properties[key].query)
tab[key] = result
return result
elseif type(usb_properties[key])=="table" and usb_properties[key].multiquery then
result = box.multiquery(usb_properties[key].multiquery) or {}
tab[key] = result
return result
else
tab[key] = usb_properties[key]
return tab[key]
end
elseif key=="gsm" and config.USB_GSM then
gsm = {}
gsm.avail = box.query("gsm:settings/ModemPresent")
gsm.name = box.query("gsm:settings/Model")
gsm.vendor = box.query("gsm:settings/Manufacturer")
gsm.status = box.query("gsm:settings/NetworkState")
gsm.devtype = "modem"
gsm.aura_list = false
tab[key] = gsm
return gsm
elseif key=="pri" and (config.USB_HOST_TI or config.USB_HOST_AVM or config.USB_HOST) and config.USB_PRINT_SERV then
pri = {}
pri.avail = box.query("ctlusb:settings/printer-avail")
pri.name = box.query("ctlusb:settings/printer-name")
pri.vendor = box.query("ctlusb:settings/printer-manu")
pri.status = box.query("ctlusb:settings/printer-status")
pri.devtype = "printer"
pri.aura_list = false
tab[key] = pri
return pri
end
return nil
end
setmetatable(usb_dev_tab,meta_usb_dev)
function aura_for_storage_aktiv()
if config.AURA then
return (usb_dev_tab.aura_enabled == "1" and usb_dev_tab.aura_for_storage == "1")
end
return false
end
function aura_for_printer_aktiv()
if config.AURA then
return (usb_dev_tab.aura_enabled == "1" and usb_dev_tab.aura_for_printer == "1")
end
return false
end
function aura_for_other_aktiv()
if config.AURA then
return (usb_dev_tab.aura_enabled == "1" and usb_dev_tab.aura_for_other == "1")
end
return false
end
function get_aura_dev_list()
if config.AURA then
return usb_dev_tab.aura_dev_list
end
return nil
end
function get_phys_dev_list()
return usb_dev_tab.phys_dev_list
end
function get_log_dev_list()
return usb_dev_tab.log_dev_list
end
function get_usb_mem_devices_count(b_log_vol)
local count = 0
local tmp_tab = {}
--Im Fall das Aura activ ist werden alle Aura erkannten Speicher zurück geliefert.
if aura_for_storage_aktiv() then
tmp_tab = get_aura_dev_list()
if tmp_tab == nil then
count = 0
else
for i, v in ipairs(tmp_tab) do
if v[2]=="08" then
count = count + 1
end
end
end
else
if b_log_vol then
count = tonumber(usb_dev_tab.log_dev_list_count) or 0
--TODO: da die Liste die man hier nutzt ein wenig langsam ist wird zur Kontrolle noch die alte benutzt sollte die 0 sein so wird der count genullt.
--Wolfgang sagt ist schneller daher erstmal raus zum testen.
--if tonumber(usb_dev_tab.part_count) == 0 then
-- count = 0
--end
else
--in der Liste sind nur usb-Speicher enthalten.
count = tonumber(usb_dev_tab.phys_dev_list_count) or 0
end
end
return count
end
function get_total_usb_devices_count()
local cnt = tonumber(usb_dev_tab.usb_device_count)
if cnt == nil or cnt < 0 then
cnt = 0
end
return cnt
end
function get_not_usb_mem_devices_count()
return (get_total_usb_devices_count() - get_usb_mem_devices_count())
end
function get_list_aura_usb_devices()
local ret_tab = {}
if config.AURA and usb_dev_tab.aura_enabled =="1" then
tmp_tab = get_aura_dev_list()
if tmp_tab ~= nil then
for i, v in ipairs(tmp_tab) do
--(class,manufacturer,comment,client)
ret_tab[i] = {}
ret_tab[i].idx=""
ret_tab[i].name= box.query("aura:settings/"..v[1])
ret_tab[i].class=v[2]
ret_tab[i].vendor=v[3]
ret_tab[i].serial=""
ret_tab[i].fw_version=""
ret_tab[i].conntype="USB"
ret_tab[i].capacity="0"
ret_tab[i].usedspace = "0"
ret_tab[i].speed="0"
ret_tab[i].status="-"
ret_tab[i].any_log= false
ret_tab[i].log_vol = {}
if v[2] == "08" then
ret_tab[i].devtype = "storage"
else
ret_tab[i].devtype = "aura"
end
ret_tab[i].client=v[4]
ret_tab[i].aura_list= true
end
end
else
ret_tab = nil
end
return ret_tab
end
function get_list_of_usb_mem_devices()
local tmp_tab = {}
local tmp_tab2 = {}
local ret_tab = {}
if aura_for_storage_aktiv() then
ret_tab = get_list_aura_usb_devices()
else
tmp_tab = get_phys_dev_list()
tmp_tab2 = get_log_dev_list()
local count = 1;
if tmp_tab ~= nil then
for i, v in ipairs(tmp_tab) do
ret_tab[i] = {}
ret_tab[i].idx = v[1]
ret_tab[i].name = v[2]
ret_tab[i].model = v[10]
ret_tab[i].class = ""
ret_tab[i].vendor = v[3]
ret_tab[i].serial = v[4]
ret_tab[i].fw_version = v[5]
ret_tab[i].conntype = v[6]
ret_tab[i].capacity = v[7]
ret_tab[i].usedspace = "0"
ret_tab[i].speed = v[9]
ret_tab[i].status = v[8]
ret_tab[i].any_log = false
ret_tab[i].log_vol = {}
ret_tab[i].devtype = "storage"
ret_tab[i].comment = ""
ret_tab[i].client = ""
ret_tab[i].aura_list = false
count = 1
if tmp_tab2 ~= nil then
for j, val in ipairs(tmp_tab2) do
if v[1]==("physmedium"..tonumber(val[5])-1) then
ret_tab[i].any_log = true
--TODO: weil die Liste hier immer ein wenig langsam ist kann es sein, dass die Liste noch aufgebaut wird obwohl die leer sein sollte. deshalb hier der fix
--Wolfgang sagt ist schneller daher erstmal raus zum testen.
--if tonumber(usb_dev_tab.part_count) == 0 then
-- ret_tab[i].any_log = false
--end
ret_tab[i].log_vol[count] = {}
ret_tab[i].log_vol[count].idx = val[1]
ret_tab[i].log_vol[count].name = val[2]
ret_tab[i].log_vol[count].status = val[3]
ret_tab[i].log_vol[count].enabled = val[4]
ret_tab[i].log_vol[count].phyref = val[5]
ret_tab[i].log_vol[count].filesystem = val[6]
ret_tab[i].log_vol[count].capacity = val[7]
ret_tab[i].log_vol[count].usedspace = val[8]
ret_tab[i].log_vol[count].readonly = val[9] == "1"
ret_tab[i].usedspace = tostring(tonumber(ret_tab[i].usedspace) + tonumber(ret_tab[i].log_vol[count].usedspace))
if config.MORPHSTICK and usb_dev_tab.morph_enabled=="1" and usb_dev_tab.morph_partition==val[2] then
ret_tab[i].log_vol[count].used_by_morph = true
else
ret_tab[i].log_vol[count].used_by_morph = true
end
count = count+1
end
end --inner for
end --tmp_tab2 ~= nil
end --for
end --tmp_tab ~= nil
end
return ret_tab
end
function check_phys_disc(phys_tab)
local disconnect = false
local partition_accessable_error = false
local disc_accessable_error = false
if phys_tab~=nil then
if phys_tab.any_log then
for j, val in pairs(phys_tab.log_vol) do
if val.status == "Online" and val.enabled == "1" then
disconnect = true
else
partition_accessable_error = true
end
end
else
disc_accessable_error = true
end
end
return disconnect, disc_accessable_error, partition_accessable_error
end
function usb_mem_mount_check(phys_tab)
local disconnect = false
local partition_accessable_error = false
local disc_accessable_error = false
local multi_phys = false
--Im Fall das Aura activ ist kann keine Aussage getroffen werden.
if not(aura_for_storage_aktiv()) then
--sollte keine Tabelle übergeben worden sein dann entsprechende Daten holen
if phys_tab == nil then
phys_tab = get_list_of_usb_mem_devices()
multi_phys = true
elseif phys_tab~=nil and phys_tab.name == nil then
--prüfe ob ein konkretes laufwerk übergeben wurde oder mehrere wenn hier dann mehrere
multi_phys = true
end
--phys_tab enthält viele disks
if multi_phys then
for i,v in pairs(phys_tab) do
local disco,dacer,pacer = check_phys_disc(v)
if disco then
disconnect = true
end
if dacer then
disc_accessable_error = true
end
if pacer then
partition_accessable_error = true
end
end
else
--eine konkretes laufwerk wurde angegeben
disconnect, disc_accessable_error, partition_accessable_error = check_phys_disc(phys_tab)
end
end -- not aura if
return disconnect, disc_accessable_error, partition_accessable_error
end
function get_usb_printer()
local ret_tab = {}
if aura_for_printer_aktiv() then
ret_tab = get_list_aura_usb_devices()
else
ret_tab = usb_dev_tab.pri
end
return ret_tab
end
function get_usb_printer_count()
local printer=get_usb_printer()
if printer and printer.avail == "1" then
return 1
end
return 0
end
function get_list_of_usb_devices()
local ret_tab = {}
if usb_dev_tab.aura_enabled == "1" then
ret_tab.aur = get_list_aura_usb_devices()
end
if not(aura_for_storage_aktiv()) then
ret_tab.mem = get_list_of_usb_mem_devices()
end
if not(aura_for_printer_aktiv()) then
ret_tab.pri = get_usb_printer()
end
ret_tab.gsm = usb_dev_tab.gsm
return ret_tab
end
