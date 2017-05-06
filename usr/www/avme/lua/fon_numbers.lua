--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
require("general")
require("config")
require("lualib")
require("umts")
require("textdb")
require("cmtable")
local g_akt_num = {}
local g_num_countable = config.CAPI_TE or config.CAPI_POTS or (config.AB_COUNT > 0)
local g_rul_all = {}
local msn_cnt = 0
local mobile_msn_cnt = 0
local sip_cnt = 0
local pots_cnt = 0
local max_sip_accounts=20
local g_data = {}
local g_fixed_line_avail = nil
local g_sip_read_only = nil
local trunkarray = nil
function get_number_count(phone_type)
if not g_akt_num or not g_akt_num.number_count then
get_all_numbers()
end
local cnt = 0
if phone_type == "msn" then
cnt = msn_cnt
elseif phone_type == "sip" then
cnt = sip_cnt
elseif phone_type == "mobile_msn" then
cnt = mobile_msn_cnt
elseif phone_type == "pots" then
cnt = pots_cnt
elseif phone_type == "all" then
cnt = g_akt_num.number_count
end
return cnt
end
function get_active_registered_numbers(num_tab)
local numbers = {}
for i, num in pairs(num_tab.numbers) do
if num.active and num.registered then
numbers[#numbers + 1] = num.number
end
end
return numbers
end
function get_active_not_registered_numbers(num_tab)
local numbers = {}
for i, num in pairs(num_tab.numbers) do
if num.active and not num.registered then
numbers[#numbers + 1] = num.number
end
end
return numbers
end
function find_first_free_sipids()
local sipEntries = general.listquery("sip:settings/sip/list(displayname,ID)")
local cnt = 0
for i, elem in ipairs(sipEntries) do
if elem.displayname == "" then
return elem._node, "SIP"..elem.ID
end
end
return box.query("sip:settings/sip/newid"), "SIP"..box.query("sipextra:settings/sip/nextID")
end
function check_sip_nums_read_only()
if g_sip_read_only == nil then
g_sip_read_only = box.query("sipextra:settings/gui_readonly") == "1"
end
return g_sip_read_only
end
function check_create_new_number_possible()
return (use_PSTN()=="1" and (config.CAPI_TE or config.CAPI_POTS)) or ((not check_sip_nums_read_only()) and (get_number_count("sip")<max_sip_accounts))
end
function get_phonenumbers(provider_id, number, msnnum, username)
str_1 = ""
str_2 = ""
local bool_finish = false
if provider_id == "tonline" then
nPos = string.find(number, msnnum)
if nPos ~= nil then
str_1 = string.sub(number,0,nPos-1)
str_2 = msnnum
end
return str_1, str_2
end
if provider_id == "1und1" or provider_id == "gmx" then
if msnnum then
str_2 = tostring(msnnum)
if username and (string.len(username) > string.len(msnnum)) then
local area_code = string.gsub(username,"^49", "")
area_code = string.gsub(area_code, msnnum.."$", "")
str_1 = "0"..area_code or ""
end
end
return str_1, str_2
end
if provider_id == "vodafone_lte" or provider_id == "arcor" or provider_id == "qsc" then
if msnnum then
str_2 = tostring(msnnum)
if username and (string.len(username) > string.len(msnnum)) then
local area_code = string.gsub(username, msnnum.."$", "")
str_1 = area_code or ""
end
end
return str_1, str_2
end
if provider_id == "easybell" then
require("sip_providerlist")
local prefix=sip_providerlist.get_one_value_from_providerlist("uiNumberFirstSpan", provider_id, "userInterface")
if prefix then
local num=string.gsub(number, prefix,"") or ""
str_1 = num
str_2 = ""
end
return str_1, str_2
end
if provider_id == "sipkom" then
require("sip_providerlist")
local prefix=sip_providerlist.get_one_value_from_providerlist("uiNumberFirstSpan", provider_id, "userInterface")
if prefix then
local num=string.gsub(number, prefix,"") or ""
str_1 = num
str_2 = ""
end
return str_1, str_2
end
return number, ""
end
function get_serialnumber(msn, trunk)
local find_first = string.find(msn,trunk)
if find_first then
if find_first > 0 then
find_first = find_first - 1
else
find_first = 0
end
else
return g_num.fondata.Trunk
end
return string.sub(msn,1, find_first)..trunk
end
function get_username(provider, username)
require("sip_providerlist")
local userprefix = sip_providerlist.get_one_value_from_providerlist("uiUserprefix", provider, "userInterface")
if userprefix and userprefix ~="" then
return string.gsub(username, userprefix,"")
end
return username
end
function get_trunkcount(trunk_id, nums_data)
local count_trunk = 0
if trink_id ~= "" then
for i = 1, #nums_data, 1 do
if nums_data[i]["trunk_id"] == trunk_id then
count_trunk = count_trunk +1
end
end
end
return count_trunk
end
function getdata(uid,nums)
if uid ~= nil and uid~="" then
local data = get_sip_num(false,true)
local numberarray = {}
local trunk_id = [[]]
data= data["numbers"]
local count_trunk = 0
local mode ="normal"
if not nums.fondata then
nums.fondata = {}
end
for i = 1, #data, 1 do
if data[i]["uid"] == uid then
if data[i]["trunk_id"] and data[i].trunk_id ~= [[]] then
if string.find(data[i].trunk_id,"direct") then
mode = "directdialin"
else
mode ="differenttrunk"
end
trunk_id = data[i].trunk_id
break
else
data[i].number1, data[i].number2 = get_phonenumbers(data[i].provider_id, data[i].number, data[i].msnnum, data[i].dataValues.details.username)
data[i].dataValues.details.username = get_username(data[i].provider_id, data[i].dataValues.details.username)
data[i].mode = mode
data[i].count_trunk = 1
table.insert(nums.fondata, data[i])
return true
end
end
end
if mode ~="normal" then
local first_k = 0
local set_first = true
for k = 1, #data, 1 do
if data[k]["trunk_id"] == trunk_id then
if mode == "directdialin" and set_first then
data[k].number1 = get_serialnumber(data[k].msnnum,data[k].dataValues.details.Trunk)
data[k].number2 = data[k].dataValues.details.Reception
set_first = false
else
data[k].number1, data[k].number2 = get_phonenumbers(data[k].provider_id, data[k].number, data[k].msnnum, data[k].dataValues.details.username)
end
data[k].dataValues.details.username = get_username(data[k].provider_id, data[k].dataValues.details.username)
data[k].mode = mode
count_trunk = get_trunkcount(trunk_id,data)
data[k].count_trunk = count_trunk
table.insert(nums.fondata, data[k])
end
end
if nums.fondata[1] then
return true
end
end
end
return false
end
function get_sip_num(no_provider, details)
local sip_num_tab = {}
local sipEntries = ""
if details then
sipEntries = general.listquery("sip:settings/sip/list(activated,displayname,registrar,outboundproxy,providername,ID,gui_readonly,webui_trunk_id,username,password,stunserver,authname_needed,outboundproxy_without_route_header,read_p_asserted_identity_header,dditype,only_call_from_registrar,sipping_interval,tx_packetsize_in_ms,g726_via_3551rfc,ccbs_supported,dtmfcfg,clirtype,protocolprefer,route_always_over_internet,ExtensionLength,Reception,Trunk,use_internat_calling_numb,mwi_supported,clipnstype)")
else
sipEntries = general.listquery("sip:settings/sip/list(activated,displayname,registrar,outboundproxy,providername,ID,gui_readonly,webui_trunk_id)")
end
local sipEntriesState = general.listquery("sip:status/sip/list(connect)")
local tr069_url = box.query("tr069:settings/url")
sip_num_tab.numbers = {}
sip_num_tab.number_count = 0
sip_num_tab.activ_count = 0
sip_num_tab.activ_registered_count = 0
sip_num_tab.activ_not_registered_count = 0
if (sipEntries~=nil and sipEntriesState~=nil) then
for i, elem in ipairs(sipEntries) do
local msnnum = box.query("telcfg:settings/SIP"..elem.ID.."/MSN")
if elem.displayname ~= "" then
if msnnum == "" then
elem.activated = "0"
end
local sip_name = box.query("telcfg:settings/SIP"..elem.ID.."/Name")
elem.registered = sipEntriesState[i].connect
sip_num_tab.number_count = sip_num_tab.number_count + 1
sip_num_tab.numbers[sip_num_tab.number_count] = {}
sip_num_tab.numbers[sip_num_tab.number_count].uid = "sip:"..elem._node
sip_num_tab.numbers[sip_num_tab.number_count].number = elem.displayname
sip_num_tab.numbers[sip_num_tab.number_count].name = sip_name
sip_num_tab.numbers[sip_num_tab.number_count].msnnum = msnnum
sip_num_tab.numbers[sip_num_tab.number_count].gui_readonly = elem.gui_readonly
sip_num_tab.numbers[sip_num_tab.number_count].id = elem._node
sip_num_tab.numbers[sip_num_tab.number_count].telcfg_id = elem.ID
if (no_provider) then
sip_num_tab.numbers[sip_num_tab.number_count].provider = ""
sip_num_tab.numbers[sip_num_tab.number_count].provider_id = ""
else
require("sip_providerlist")
sip_num_tab.numbers[sip_num_tab.number_count].provider = sip_providerlist.get_sip_provider(elem.registrar, elem.outboundproxy, elem.providername,elem.webui_trunk_id~="")
sip_num_tab.numbers[sip_num_tab.number_count].provider_id = sip_providerlist.get_sip_provider_id(elem.registrar, elem.outboundproxy,elem.webui_trunk_id~="")
end
sip_num_tab.numbers[sip_num_tab.number_count].active = false
sip_num_tab.numbers[sip_num_tab.number_count].registered = false
sip_num_tab.numbers[sip_num_tab.number_count].type = "sip"
local deletable = not check_sip_nums_read_only() and elem.gui_readonly ~= "1"
sip_num_tab.numbers[sip_num_tab.number_count].deletable = deletable
if (elem.activated == "1") then
sip_num_tab.activ_count = sip_num_tab.activ_count + 1
sip_num_tab.numbers[sip_num_tab.number_count].active = true
if elem.registered == "2" or elem.registered == "3" then
sip_num_tab.activ_registered_count = sip_num_tab.activ_registered_count + 1
sip_num_tab.numbers[sip_num_tab.number_count].registered = true
else
sip_num_tab.activ_not_registered_count = sip_num_tab.activ_not_registered_count + 1
sip_num_tab.numbers[sip_num_tab.number_count].registered = false
end
end
sip_num_tab.numbers[sip_num_tab.number_count].trunk_id = elem.webui_trunk_id
if details then
sip_num_tab.numbers[sip_num_tab.number_count].dataValues = {}
sip_num_tab.numbers[sip_num_tab.number_count].dataValues.details = elem
sip_num_tab.numbers[sip_num_tab.number_count].dataValues.telcfg = {}
sip_num_tab.numbers[sip_num_tab.number_count].dataValues.telcfg.AKN = box.query([[telcfg:settings/SIP]]..tostring(elem.ID)..[[/AKN]])
sip_num_tab.numbers[sip_num_tab.number_count].dataValues.telcfg.EmergencyRule = box.query([[telcfg:settings/SIP]]..tostring(elem.ID)..[[/EmergencyRule]])
sip_num_tab.numbers[sip_num_tab.number_count].dataValues.telcfg.RegistryType = box.query([[telcfg:settings/SIP]]..tostring(elem.ID)..[[/RegistryType]])
sip_num_tab.numbers[sip_num_tab.number_count].dataValues.telcfg.UseOKZ = box.query([[telcfg:settings/SIP]]..tostring(elem.ID)..[[/UseOKZ]])
sip_num_tab.numbers[sip_num_tab.number_count].dataValues.telcfg.UseLKZ = box.query([[telcfg:settings/SIP]]..tostring(elem.ID)..[[/UseLKZ]])
sip_num_tab.numbers[sip_num_tab.number_count].dataValues.telcfg.KeepOKZPrefix = box.query([[telcfg:settings/SIP]]..tostring(elem.ID)..[[/KeepOKZPrefix]])
sip_num_tab.numbers[sip_num_tab.number_count].dataValues.telcfg.KeepLKZPrefix = box.query([[telcfg:settings/SIP]]..tostring(elem.ID)..[[/KeepLKZPrefix]])
sip_num_tab.numbers[sip_num_tab.number_count].dataValues.telcfg.Suffix = box.query([[telcfg:settings/SIP]]..tostring(elem.ID)..[[/Suffix]])
sip_num_tab.numbers[sip_num_tab.number_count].dataValues.telcfg.AlternatePrefix = box.query([[telcfg:settings/SIP]]..tostring(elem.ID)..[[/AlternatePrefix]])
end
end
end
end
sip_cnt = sip_num_tab.number_count
return sip_num_tab
end
function is_fixed_line_avail()
if g_fixed_line_avail == nil then
local tmp = box.query("telcfg:settings/PSTNMode")
g_fixed_line_avail = (tmp == "1" or tmp == "2")
end
return g_fixed_line_avail
end
function is_pots_configured()
return pots_cnt~=0
end
function get_pots_number()
local pots_list=get_pots()
if pots_list.number_count==0 then
return ""
end
return pots_list.numbers[1].msnnum
end
function is_fixed_line_only()
return sip_cnt==0 and mobile_msn_cnt==0 and(pots_cnt~=0 or msn_cnt~=0)
end
function use_PSTN()
return box.query("telcfg:settings/UsePSTN")
end
function get_pots()
local pots_num_tab = {}
local pots = box.query("telcfg:settings/MSN/POTS")
--local use_PSTN = box.query("telcfg:settings/UsePSTN")
pots_num_tab.number_count = 0
pots_num_tab.activ_count = 0
pots_num_tab.activ_registered_count = 0
pots_num_tab.activ_not_registered_count = 0
pots_num_tab.numbers = {}
--zählen der normalen Telefone.
if g_num_countable then
if pots ~= nil and pots ~= "" and pots ~= "er" and use_PSTN() == "1" then
local pots_name = box.query("telcfg:settings/MSN/POTSName")
pots_num_tab.number_count = 1
if is_fixed_line_avail() then
pots_num_tab.activ_count = 1
pots_num_tab.activ_registered_count = 1
end
pots_num_tab.numbers[pots_num_tab.number_count] = {}
pots_num_tab.numbers[pots_num_tab.number_count].uid = "pots:12345"
pots_num_tab.numbers[pots_num_tab.number_count].number = pots
pots_num_tab.numbers[pots_num_tab.number_count].msnnum = pots
pots_num_tab.numbers[pots_num_tab.number_count].name = pots_name
pots_num_tab.numbers[pots_num_tab.number_count].type = "pots"
pots_num_tab.numbers[pots_num_tab.number_count].id = "POTS"
pots_num_tab.numbers[pots_num_tab.number_count].telcfg_id = "POTS"
pots_num_tab.numbers[pots_num_tab.number_count].active = is_fixed_line_avail()
pots_num_tab.numbers[pots_num_tab.number_count].registered = true
end
end
pots_cnt = pots_num_tab.number_count
return pots_num_tab
end
function get_mobile_msn()
local mobile_msn_tab = {}
local mobile_msn = box.query("telcfg:settings/Mobile/MSN")
mobile_msn_tab.number_count = 0
mobile_msn_tab.numbers = {}
if umts.is_voice_modem() and mobile_msn ~= nil and mobile_msn ~= "" then
local mm_name = box.query("telcfg:settings/Mobile/Name")
mobile_msn_tab.number_count = 1
mobile_msn_tab.numbers[mobile_msn_tab.number_count] = {}
mobile_msn_tab.numbers[mobile_msn_tab.number_count].uid = "mobile_msn:SIP99"
mobile_msn_tab.numbers[mobile_msn_tab.number_count].number = mobile_msn
mobile_msn_tab.numbers[mobile_msn_tab.number_count].msnnum = mobile_msn
mobile_msn_tab.numbers[mobile_msn_tab.number_count].name = mm_name
mobile_msn_tab.numbers[mobile_msn_tab.number_count].type = "mobile_msn"
mobile_msn_tab.numbers[mobile_msn_tab.number_count].id = "sip99"
mobile_msn_tab.numbers[mobile_msn_tab.number_count].active = true
mobile_msn_tab.numbers[mobile_msn_tab.number_count].registered = true
mobile_msn_tab.numbers[mobile_msn_tab.number_count].telcfg_id = "99"
mobile_msn_tab.numbers[mobile_msn_tab.number_count].deletable = false
end
mobile_msn_cnt = mobile_msn_tab.number_count
return mobile_msn_tab
end
function get_msn()
local msn_tab = {}
--local use_PSTN = box.query("telcfg:settings/UsePSTN")
local msn_max = 9
msn_tab.number_count = 0
msn_tab.activ_count = 0
msn_tab.activ_registered_count = 0
msn_tab.activ_not_registered_count = 0
msn_tab.numbers = {}
if g_num_countable and use_PSTN() == "1" then
local tmp = ""
for k=0, msn_max, 1 do
tmp = box.query("telcfg:settings/MSN/MSN"..k)
if tmp ~= nil and tmp ~= "" then
tmp_name = box.query("telcfg:settings/MSN/Name"..k)
msn_tab.number_count = msn_tab.number_count + 1
if is_fixed_line_avail() then
msn_tab.activ_count = msn_tab.activ_count + 1
msn_tab.activ_registered_count = msn_tab.activ_registered_count + 1
end
msn_tab.numbers[msn_tab.number_count] = {}
msn_tab.numbers[msn_tab.number_count].uid = "msn:"..k
msn_tab.numbers[msn_tab.number_count].number = tmp
msn_tab.numbers[msn_tab.number_count].msnnum = tmp
msn_tab.numbers[msn_tab.number_count].name = tmp_name
msn_tab.numbers[msn_tab.number_count].type = "msn"
msn_tab.numbers[msn_tab.number_count].id = "MSN"..k
msn_tab.numbers[msn_tab.number_count].telcfg_id = k
msn_tab.numbers[msn_tab.number_count].active = is_fixed_line_avail()
msn_tab.numbers[msn_tab.number_count].registered = true
end
end
end
msn_cnt = msn_tab.number_count
return msn_tab
end
function add_numbers(dest_tab, source_tab)
for i, num in ipairs(source_tab) do
dest_tab[#dest_tab + 1] = num
end
return dest_tab
end
function merge_number_tables(sip_num, pots_num, mobile_msn_num, msn_num)
local all = {}
all.number_count = sip_num.number_count + pots_num.number_count + mobile_msn_num.number_count + msn_num.number_count
all.activ_count = sip_num.activ_count + pots_num.activ_count + msn_num.activ_count + mobile_msn_num.number_count
all.activ_registered_count = sip_num.activ_registered_count + pots_num.activ_registered_count + msn_num.activ_registered_count + mobile_msn_num.number_count
all.activ_not_registered_count = sip_num.activ_not_registered_count
all.numbers = {}
all.numbers = add_numbers(all.numbers, sip_num.numbers)
all.numbers = add_numbers(all.numbers, pots_num.numbers)
all.numbers = add_numbers(all.numbers, mobile_msn_num.numbers)
all.numbers = add_numbers(all.numbers, msn_num.numbers)
return all
end
function get_all_numbers()
g_akt_num = merge_number_tables(get_sip_num(), get_pots(), get_mobile_msn(), get_msn())
return g_akt_num
end
function find_by_msnnum(msn)
if not g_akt_num or not g_akt_num.number_count then
get_all_numbers()
end
return array.filter(g_akt_num.numbers, func.eq(msn, "msnnum"))
end
function get_all_avail_numbers()
function find_num_in_list(list,number)
for i,elem in ipairs(list) do
if number==elem.val then
return true
end
end
return false
end
--######
local num_list={}
if not g_akt_num or not g_akt_num.number_count then
get_all_numbers()
end
for i, num in pairs(g_akt_num.numbers) do
if not find_num_in_list(num_list,num.number) then
local elem={}
elem.val=num.msnnum
elem.key=num.msnnum
table.insert(num_list,elem)
end
end
return num_list
end
function find_num_by_UID(uid)
if not g_akt_num or not g_akt_num.number_count then
get_all_numbers()
end
for i, num in pairs(g_akt_num.numbers) do
if num.uid == uid then
return num
end
end
return nil
end
function del_diversity_callerAction(num, del_all, ctlmgr_del)
local num_id = num.id
if num.type == "sip" then
num_id = "SIP"..num.telcfg_id
elseif num.type == "msn" then
num_id = string.sub(num.id, 4)
end
local diversity = general.listquery("telcfg:settings/Diversity/list(MSN,Outgoing)")
for i, elem in ipairs(diversity) do
if elem.MSN == num_id or elem.Outgoing == num_id or del_all then
cmtable.add_var(ctlmgr_del, "telcfg:command/"..elem._node , "delete")
end
end
local caller_action = general.listquery("telcfg:settings/CallerIDActions/list(Outgoing)")
for i, elem in ipairs(caller_action) do
if elem.Outgoing == num_id or del_all then
cmtable.add_var(ctlmgr_del, "telcfg:command/"..elem._node , "delete")
end
end
return ctlmgr_del
end
function check_double_number(check_num)
if not g_akt_num or not g_akt_num.number_count then
get_all_numbers()
end
local last_double = nil
local check_num_cnt = 1
for i, num in pairs(g_akt_num.numbers) do
if num.number == check_num.number and num.uid ~= check_num.uid then
last_double = num
check_num_cnt = check_num_cnt + 1
end
end
return last_double, check_num_cnt
end
function check_double_number_diversity_callerAction(check_num)
if not g_akt_num or not g_akt_num.number_count then
get_all_numbers()
end
for i, num in pairs(g_akt_num.numbers) do
if ((check_num.type == "sip" and num.type == "sip") or (check_num.type ~= "sip" and num.type ~= "sip")) and
num.number == check_num.number and num.uid ~= check_num.uid then
return num
end
end
return nil
end
function add_route_uid(idx, elem)
elem.uid=elem._node
end
function get_dialruls()
local routs = general.listquery("telcfg:settings/Routing/Group/list(Number,Route,Provider)",add_route_uid)
return routs
end
function del_routing(num, del_all, ctlmgr_del)
local routs = get_dialruls()
for i, route in ipairs(routs) do
if del_all or
(route.Route == num.id) or (num.telcfg_id and route.Route == num.telcfg_id) or
((num.type == "pots" or (num.type == "msn" and msn_cnt == 1)) and route.Route == "f") or
(num.type == "sip" and sip_cnt == 1 and route.Route == "v") or
(num.type == "mobile_msn" and route.Route == "m") then
cmtable.add_var(ctlmgr_del, "telcfg:command/Routing/"..route._node , "delete")
end
end
return ctlmgr_del
end
function del_calltrough(num, del_all, ctlmgr_del)
local num_id = num.id
if num.type == "sip" then
num_id = "SIP"..num.telcfg_id
elseif num.type == "msn" then
num_id = string.sub(num.id, 4)
end
local number = box.query("telcfg:settings/CallThrough/MSN")
local number_out = box.query("telcfg:settings/CallThrough/OutgoingMSN")
if del_all or num_id == number or num_id == number_out or
((num.type == "pots" or (num.type == "msn" and msn_cnt == 1)) and (number == "POTS" or number_out == "POTS")) then
cmtable.add_var(ctlmgr_del, "telcfg:settings/CallThrough/Active" , "0")
end
return ctlmgr_del
end
function del_fon_device_nums(num, del_all, ctlmgr_del)
require("fon_devices")
local fon_devs = fon_devices.get_all_fon_devices()
local double_num, num_total_cnt = check_double_number(num)
for i, fon_dev in pairs(fon_devs) do
local use_double_num = true
local check_num = num.number
if fon_dev.src == "faxintern" and num.type == "pots" then
check_num = "POTS"
use_double_num = false
end
if fon_dev.src == "fon123" then
use_double_num = false
if num.type == "sip" then
check_num = "SIP"..num.telcfg_id
elseif num.type == "pots" then
check_num = "POTS"
elseif num.type == "mobile_msn" then
check_num = "SIP99"
else
use_double_num = true
end
end
local number_deleted = false
if del_all or not use_double_num or not double_num then
if del_all or fon_dev.number == check_num or fon_dev.outgoing == check_num then
cmtable.add_var(ctlmgr_del, fon_dev.number_query, "")
number_deleted = true
end
end
local found_num_cnt = 0
if not number_deleted then
for j, in_num in ipairs(fon_dev.incoming) do
if del_all or in_num == check_num then
found_num_cnt = found_num_cnt + 1
if del_all or not use_double_num or not double_num or (found_num_cnt == num_total_cnt and use_double_num and double_num) then
cmtable.add_var(ctlmgr_del, fon_dev.incoming_query[j], "")
end
end
end
end
end
return ctlmgr_del
end
function setNewTrunkId(uid)
local ctlmgr_new={}
local firstNumber = true;
if uid ~= nil then
local data = get_sip_num()
local old_trunk_id = [[]]
local new_trunk_id = [[]]
data= data["numbers"]
for i = 1, #data do
if data[i]["uid"] == uid then
if data[i]["trunk_id"] ~= [[]] then
if box.query("sip:settings/"..data[i].id.."/do_not_register") == "0" then
old_trunk_id = data[i]["trunk_id"]
else
return
end
else
return
end
end
end
if old_trunk_id ~= [[]] then
for i = 1, #data do
if data[i]["trunk_id"] == old_trunk_id and data[i]["uid"] ~= uid then
if firstNumber then
new_trunk_id = data[i].id
cmtable.add_var(ctlmgr_new, "sip:settings/"..data[i].id.."/do_not_register", "0")
firstNumber = false;
end
cmtable.add_var(ctlmgr_new, "sip:settings/"..data[i].id.."/webui_trunk_id", new_trunk_id)
end
end
general.show_all_data(ctlmgr_new)
box.set_config(ctlmgr_new)
end
end
end
function del_number_by_UID(uid)
local num = find_num_by_UID(uid)
local ctlmgr_del={}
if num then
local del_all = g_akt_num.number_count == 1
if not check_double_number_diversity_callerAction(num) or del_all then
ctlmgr_del = del_diversity_callerAction(num, del_all, ctlmgr_del)
ctlmgr_del = del_routing(num, del_all, ctlmgr_del)
ctlmgr_del = del_calltrough(num, del_all, ctlmgr_del)
end
if #find_by_msnnum(num.msnnum) < 2 then
require"pushservice"
ctlmgr_del = pushservice.calls_delete(num.msnnum, ctlmgr_del)
end
ctlmgr_del = del_fon_device_nums(num, del_all, ctlmgr_del)
if num.type == "sip" then
setNewTrunkId(uid)
if num.deletable then
if num.id == "sip0" then
cmtable.add_var(ctlmgr_del, "sip:settings/sip0/activated" , "0")
cmtable.add_var(ctlmgr_del, "sip:settings/sip0/displayname" , "")
cmtable.add_var(ctlmgr_del, "sip:settings/sip0/registrar" , "")
cmtable.add_var(ctlmgr_del, "sip:settings/sip0/username" , "")
cmtable.add_var(ctlmgr_del, "sip:settings/sip0/password" , "")
cmtable.add_var(ctlmgr_del, "sip:settings/sip0/stunserver" , "")
cmtable.add_var(ctlmgr_del, "sip:settings/sip0/providername" , "")
cmtable.add_var(ctlmgr_del, "sip:settings/sip0/outboundproxy" , "")
cmtable.add_var(ctlmgr_del, "sip:settings/sip0/do_not_register", "0")
elseif num.id == "sip1" then
cmtable.add_var(ctlmgr_del, "sip:settings/sip1/activated" , "0")
cmtable.add_var(ctlmgr_del, "sip:settings/sip1/displayname" , "")
cmtable.add_var(ctlmgr_del, "sip:settings/sip1/registrar" , "")
cmtable.add_var(ctlmgr_del, "sip:settings/sip1/username" , "")
cmtable.add_var(ctlmgr_del, "sip:settings/sip1/password" , "")
cmtable.add_var(ctlmgr_del, "sip:settings/sip1/stunserver" , "")
cmtable.add_var(ctlmgr_del, "sip:settings/sip1/providername" , "")
cmtable.add_var(ctlmgr_del, "sip:settings/sip1/outboundproxy" , "")
cmtable.add_var(ctlmgr_del, "sip:settings/sip1/do_not_register", "0")
else
cmtable.add_var(ctlmgr_del, "sip:command/"..num.id , "delete")
end
cmtable.add_var(ctlmgr_del, "telcfg:settings/SIP"..num.telcfg_id.."/MSN" , "")
cmtable.add_var(ctlmgr_del, "telcfg:settings/SIP"..num.telcfg_id.."/Name" , "")
end
elseif num.type == "msn" then
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/"..num.id , "")
elseif num.type == "pots" then
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/"..num.id , "")
elseif num.type == "mobile_msn" then
cmtable.add_var(ctlmgr_del, "telcfg:settings/Mobile/"..num.id , "")
end
return box.set_config(ctlmgr_del)
end
return -1, "Number '"..uid.."' not found."
end
function new_SipNode()
local id = ""
local telcfg = ""
local empty_found = false
for i, k in ipairs(general.listquery("sip:settings/sip/list(displayname,ID)")) do
if k["displayname"] == "" then
if not empty_found then
id = k["_node"]
telcfg = i-1
empty_found = true
break
end
end
end
if not empty_found then
id = box.query("sip:settings/sip/newid")
end
for i=0,max_sip_accounts-1 do
local msn=box.query("telcfg:settings/SIP"..i.."/MSN")
if (msn=="") then
telcfg = i
break
end
end
return id, telcfg
end
function new_Telcfg()
telcfg = ""
for i=0,max_sip_accounts-1 do
local msn=box.query("telcfg:settings/SIP"..i.."/MSN")
if (msn=="") then
telcfg="SIP"..i
break
end
end
return telcfg
end
function replaceNumbers(ctlmgr_save, OldNumber, NewNumber)
local num_tab = get_all_numbers()
for i,k in ipairs(num_tab["numbers"]) do
if k["number"] == OldNumber then
if k["type"] == "sip" then
cmtable.add_var(ctlmgr_save, "telcfg:settings/SIP"..k["telcfg_id"].."/MSN", NewNumber)
elseif k["type"] == "msn" then
cmtable.add_var(ctlmgr_save,"telcfg:settings/MSN"..k["id"], NewNumber)
elseif k["type"] == "pots" then
cmtable.add_var(ctlmgr_save,"telcfg:settings/MSN/POTS", NewNumber)
end
return ctlmgr_save
end
end
return ctlmgr_save
end
function isAnalog()
data = fon_numbers.get_msn()
if #data.numbers > 0 then
return false
end
return true
end
function get_elem_by_num(list,number)
if (list==nil) then
return false
end
for i,elem in ipairs(list.numbers) do
if number==elem.number then
return elem
end
end
return nil
end
function find_num_in_list(list,number)
if (list==nil or list.numbers==nil or number==nil) then
return false
end
for i,elem in ipairs(list.numbers) do
if number==elem.number then
return true
end
end
return false
end
function find_elem_in_list_by_telcfgid(list,telcfg_id)
if (list==nil) then
return nil
end
for i,elem in ipairs(list.numbers) do
if telcfg_id==elem.telcfg_id then
return elem
end
end
return nil
end
function find_elem_in_list_by_msnnum(list,msnnum)
if (list==nil) then
return nil
end
for i,elem in ipairs(list.numbers) do
if msnnum==elem.msnnum then
return elem
end
end
return nil
end
function find_elem_in_list_by_uid(list,uid)
if (list==nil or uid=="") then
return nil
end
for i,elem in ipairs(list) do
if uid==elem.uid then
return elem
end
end
return nil
end
function get_rul_port(idx)
if (config.AB_COUNT<idx) then
return nil
end
local rul={}
rul.idx = idx
idx=tostring(idx)
rul.uid = "port_"..idx
rul.type = "port"
rul.num_dest = box.query("telcfg:settings/MSN/Port"..idx.."/DiversionNumber")
rul.comment = ""
rul.name = box.query("telcfg:settings/MSN/Port"..idx.."/DiversionName")
rul.action = box.query("telcfg:settings/MSN/Port"..idx.."/Diversion")
rul.active = (rul.action~="0")
rul.num_out = box.query("telcfg:settings/MSN/Port"..idx.."/MSN0")
rul.portname = box.query("telcfg:settings/MSN/Port"..idx.."/Name")
if rul.portname=="" then
rul.portname="FON"..idx
end
if (rul.action == "0" and rul.num_dest == "") then
return nil
end
rul.caller_id = ""
rul.displaytxt=get_num_txt(nil,rul.portname)
return rul
end
function add_rul_port(idx)
local rul=get_rul_port(idx)
if (rul) then
table.insert(g_rul_all,rul)
end
end
function add_rul_div(idx, elem)
local rul={}
rul.active = elem.Active=="1"
rul.idx = idx-1
rul.uid = "rul_"..tostring(idx-1)
rul.type = "rul"
rul.num_dest = elem.Destination
rul.action = elem.Action
rul.num_out = elem.Outgoing
rul.caller_id = elem.MSN
rul.name = elem.Name
rul.comment = ""
rul.displaytxt,rul.spantxt=get_caller_id_txt(rul)
table.insert(g_rul_all,rul)
end
function add_rub_div(idx, elem)
local rul={}
rul.active = elem.Active=="1"
rul.idx = idx-1
rul.uid = "rub_"..tostring(idx-1)
rul.type = "rub"
rul.num_dest = elem.Destination
rul.action = elem.Action
rul.num_out = elem.Outgoing
rul.caller_id = elem.CallerID
rul.comment = ""
rul.name = elem.Name
rul.displaytxt,rul.spantxt=get_caller_id_txt(rul)
table.insert(g_rul_all,rul)
end
function get_rul_all()
if (#g_rul_all~=0) then
return g_rul_all
end
add_rul_port(0)
add_rul_port(1)
add_rul_port(2)
general.listquery("telcfg:settings/Diversity/list(MSN,Outgoing,Destination,Action,Active,Name)",add_rul_div)
general.listquery("telcfg:settings/CallerIDActions/list(CallerID,Outgoing,Destination,Action,Active,Name)",add_rub_div)
return g_rul_all
end
function get_num_of_active_ruls(list)
local count_active=0
if (list) then
for i,elem in ipairs(list) do
if not (elem.type=="rub" and elem.action=="1") and elem.active then
if (elem.type=="port" or elem.type=="rul" or (elem.type=="rub" and (elem.action=="0" or elem.action == "2"))) then
count_active=count_active+1
end
end
end
end
return count_active
end
function find_dial_rul(list,search)
if (list and search) then
for i,elem in ipairs(list) do
if (elem.Route=="s" and elem.Number==search) then
return elem
end
end
end
return nil
end
function is_num_of_tam(nr)
for i=0,4 do
if "60"..tostring(i)==nr then
return true
end
end
return false
end
function is_msn_in_siplist(data,number)
return find_num_in_list(data.siplist,number)
end
function is_sip_in_msnlist(data,number)
if find_num_in_list(data.msnlist,number) then
return true
end
return find_num_in_list(data.pots,number)
end
local txt_fixed_line=TXT([[{?gFestNetz?}]])
local txt_internet =TXT([[{?gInternet?}]])
function get_caller_id_txt(elem)
local spantxt=nil
local name=TXT([[{?3664:295?}]])
if (elem.caller_id~="") then
name=elem.caller_id
end
local txt=""
if (elem.caller_id=="*") then
txt=TXT([[{?3664:277?}]])
else
if string.find(name,"#")==1 then
local num=string.gsub(name,"#","")
txt=TXT([[{?3664:61?}]])..[[ ]]..get_num_txt(nil,num)
else
if elem.name~="" then
spantxt=name
name=elem.name
end
txt=TXT([[{?3664:388?}]])..[[ ]]..name
end
end
return txt,spantxt
end
function get_num_txt(data, num)
if (not data) then
data = g_data
if not data.pots then
data.pots=get_pots()
data.msnlist=get_msn()
data.siplist=get_sip_num()
end
end
if string.find(num,"#")==1 then
num=string.gsub(num,"#","")
end
if string.find(num,"#")==#num then
num=string.gsub(num,"#","")
end
local tmp_num=tonumber(num)
if tmp_num and tmp_num>=0 and tmp_num<=9 then
if data.msnlist and data.msnlist.numbers then
local msnnum=find_elem_in_list_by_telcfgid(data.msnlist,tmp_num)
if msnnum and is_msn_in_siplist(data, msnnum.number) then
return msnnum.number..[[ (]]..txt_fixed_line..[[)]]
end
return msnnum and msnnum.number or ""
end
end
if num=="POTS" then
if (data.pots.activ_count>0) then
return data.pots.numbers[1].number..[[ (]]..txt_fixed_line..[[)]]
end
num=[[(]]..txt_fixed_line..[[)]]
end
if string.find(num,"SIP") then
tmp_num=string.gsub(num,"SIP","")
local elem=find_elem_in_list_by_telcfgid(data.siplist,tmp_num)
if elem then
if is_sip_in_msnlist(data,elem.number) then
return elem.number..[[ (]]..txt_internet..[[)]]
end
return elem.number
end
end
if (num=="") then
return TXT([[{?3664:565?}]])
end
return num
end
function get_port_txt(action)
local g_txtDisplay_port={
["0"] = TXT("{?3664:729?}"),
["1"] = TXT("{?3664:843?}"),
["2"] = TXT("{?3664:759?}"),
["3"] = TXT("{?3664:228?}"),
["4"] = TXT("{?3664:121?}"),
["5"] = TXT("{?3664:939?}"),
["6"] = TXT("{?3664:45?}"),
["7"] = TXT("{?3664:110?}")
}
return g_txtDisplay_port[action]
end
function get_rul_txt(action)
local g_txtDisplay_rul={
["0"] = TXT("{?3664:125?}"),
["1"] = TXT("{?3664:560?}"),
["2"] = TXT("{?3664:1818?}"),
["3"] = TXT("{?3664:299?}"),
["4"] = TXT("{?3664:195?}")
}
return g_txtDisplay_rul[action]
end
function is_special_num(nr)
if use_PSTN()=="1" then
if (config.language=="en") then
if (nr == "999" or nr == "112") then
return true
end
else
if (nr == "110" or nr == "112" or nr == "19222") then
return true
end
end
end
return false
end
function get_prefix_list()
local prefix_table = {}
for i=0,9 do
table.insert(prefix_table, box.query("telcfg:settings/Routing/Provider"..tostring(i)))
end
return prefix_table
end
function get_list_of_numbers(data,filter,is_telecom)
if (not data) then
data={}
data.pots=get_pots()
data.msnlist=get_msn()
data.siplist=get_sip_num()
end
local list={}
local elem={}
if string.find(filter,"FON") then
local name=""
for i=0,2 do
elem={}
name=box.query("telcfg:settings/MSN/Port"..tostring(i).."/Name")
if name~="" then
elem.val="FON"..tostring(i+1)
elem.key=name
table.insert(list,elem)
end
end
end
if string.find(filter,"auto") then
elem={}
elem.val="*"
elem.key=TXT([[{?3664:936?}]])
table.insert(list,elem)
end
if string.find(filter,"all_nums") then
elem={}
elem.val="*"
elem.key=TXT([[{?3664:572?}]])
table.insert(list,elem)
end
if string.find(filter,"inet") then
elem={}
elem.val="INET"
elem.key=TXT([[{?3664:833?}]])
table.insert(list,elem)
end
if (config.CAPI_TE or config.CAPI_POTS) and (string.find(filter,"fixed") or is_telecom) then
if use_PSTN() == "1" or is_telecom then
local prefix_table=get_prefix_list()
local free=false
for i=1,10 do
local elem={}
if (prefix_table[i]~="") then
elem.val="FIXED"..tostring(i-1)
if is_telecom then
elem.key=TXT([[{?3664:982?}]])..[[ ]]..prefix_table[i]
else
elem.key=TXT([[{?3664:870?}]])..[[ ]]..prefix_table[i]
end
table.insert(list,elem)
else
if (not free) then
elem.val="FIXED"..tostring(i-1)
if is_telecom then
elem.key=TXT([[{?3664:599?}]])
else
elem.key=txt_fixed_line
end
table.insert(list,elem)
free=true
end
end
end
end
end
if (data.msnlist) then
for i,item in ipairs(data.msnlist.numbers) do
elem={}
--elem.val=tostring(i-1)
elem.val=tostring(item.telcfg_id)
if not is_msn_in_siplist(data,item.number) then
elem.key=item.number
else
elem.key=item.number..[[ (]]..txt_fixed_line..[[)]]
end
table.insert(list,elem)
end
end
if (data.pots and use_PSTN()=="1") then
if (pots_cnt > 0 and data.pots.numbers[1].number~="") then
elem={}
elem.val="POTS"
elem.key=data.pots.numbers[1].number..[[ (]]..txt_fixed_line..[[)]]
table.insert(list,elem)
else
local is_austria=box.query("box:settings/country")=="043"
if is_austria or general.is_expert() or data.msnlist.number_count==0 then
elem={}
elem.val="POTS"
elem.key=txt_fixed_line
table.insert(list,elem)
end
end
end
if (data.siplist) then
for i,item in ipairs(data.siplist.numbers) do
elem={}
elem.val="SIP"..item.telcfg_id
if not is_sip_in_msnlist(data,item.msnnum) then
elem.key=item.msnnum
else
elem.key=item.msnnum..[[ (]]..txt_internet..[[)]]
end
table.insert(list,elem)
end
end
if (data.mobile_msnlist) then
if (data.mobile_msnlist.numbers) then
for i,item in ipairs(data.mobile_msnlist.numbers) do
elem={}
elem.val="SIP99"
elem.key=item.msnnum
table.insert(list,elem)
end
end
end
return list
end
function find_rul(list,key,val,filter)
for i,elem in ipairs(list) do
if ( filter==nil or filter==elem.type) then
if elem[key]==val then
return true,elem
end
end
end
return false, nil
end
function create_id(elem,useactive)
local id=[[]]
if (elem) then
id=[[telcfg:settings/]]
if (elem.type=="port") then
id=id..[[MSN/Port]]..tostring(elem.idx)
elseif (elem.type=="rul") then
id=id..[[Diversity]]..tostring(elem.idx)
if useactive~=nil then
id=id.."/Active"
end
else
id=id..[[CallerIDActions]]..tostring(elem.idx)
if useactive~=nil then
id=id.."/Active"
end
end
end
id=id..[[/]]
return id
end
function find_all_ruls(list,key,val,filter)
local result={}
local found=false
for i,elem in ipairs(list) do
if ( filter==nil or filter==elem.type) then
if elem[key]==val then
found=true
table.insert(result,create_id(elem,true))
end
end
end
return found, result
end
function get_only_number(value)
local result = ""
if value then
for i = 1, #value do
if tonumber(string.sub(value, i,i)) ~= nil then
result = result..string.sub(value,i,i)
end
end
end
return result
end
function get_max_sip_accounts()
return max_sip_accounts
end
function get_available_sip_accounts()
local available_accounts = 0
available_accounts = get_max_sip_accounts()-tonumber(get_number_count("sip"))
return available_accounts
end
function is_trunkmode(mode)
if mode=="directdialin" or mode=="differenttrunk" then
return true
end
return false
end
