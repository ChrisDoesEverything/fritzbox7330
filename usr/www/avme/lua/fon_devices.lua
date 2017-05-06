--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
require("general")
require("textdb")
require("config")
require("bit")
require("val")
require("cmtable")
g_MsnPortnames = { box.query("telcfg:settings/MSN/Port0/Name"),
box.query("telcfg:settings/MSN/Port1/Name"),
box.query("telcfg:settings/MSN/Port2/Name")}
g_NTHotDialList = { box.query("telcfg:settings/NTHotDialList/Name1"),
box.query("telcfg:settings/NTHotDialList/Name2"),
box.query("telcfg:settings/NTHotDialList/Name3"),
box.query("telcfg:settings/NTHotDialList/Name4"),
box.query("telcfg:settings/NTHotDialList/Name5"),
box.query("telcfg:settings/NTHotDialList/Name6"),
box.query("telcfg:settings/NTHotDialList/Name7"),
box.query("telcfg:settings/NTHotDialList/Name8")}
g_IpPhones = {names={},enabled={}}
if config.FON_IPPHONE then
g_IpPhones.names = { box.query("telcfg:settings/VoipExtension0/Name"),
box.query("telcfg:settings/VoipExtension1/Name"),
box.query("telcfg:settings/VoipExtension2/Name"),
box.query("telcfg:settings/VoipExtension3/Name"),
box.query("telcfg:settings/VoipExtension4/Name"),
box.query("telcfg:settings/VoipExtension5/Name"),
box.query("telcfg:settings/VoipExtension6/Name"),
box.query("telcfg:settings/VoipExtension7/Name"),
box.query("telcfg:settings/VoipExtension9/Name") }
g_IpPhones.enabled = { box.query("telcfg:settings/VoipExtension0/enabled"),
box.query("telcfg:settings/VoipExtension1/enabled"),
box.query("telcfg:settings/VoipExtension2/enabled"),
box.query("telcfg:settings/VoipExtension3/enabled"),
box.query("telcfg:settings/VoipExtension4/enabled"),
box.query("telcfg:settings/VoipExtension5/enabled"),
box.query("telcfg:settings/VoipExtension6/enabled"),
box.query("telcfg:settings/VoipExtension7/enabled"),
box.query("telcfg:settings/VoipExtension9/enabled") }
end
g_init = box.query("telcfg:settings/Foncontrol")
local g_dev_list = {}
local g_txt_Integriert = TXT([[{?237:335?}]])
local g_txt_FaxInternDisplay = TXT([[{?237:167?}]])
local g_txtIpPhone = TXT([[{?237:870?}]])
local g_txtTamDefaultName = TXT([[{?237:548?}]])
local g_txtIsdnDefault = TXT([[{?237:899?}]])
function isIsdnDefault(fonDevice)
if (fonDevice==nil) then
return false;
end
return fonDevice.src == "nthotdiallist" and fonDevice.idx == 0
end
function isIsdn(fonDevice)
if (fonDevice==nil) then
return false;
end
return fonDevice.src == "nthotdiallist"
end
function filterList(list, filterFunc)
local result = {};
local len = #list
for i,elem in ipairs(list) do
if (filterFunc(elem)) then
table.insert(result,elem)
end
end
return result
end
local g_fon_dev_list
function read_fon_123(use_cache)
local dev_list = {}
local cnt = 0
if not use_cache then
g_fon_dev_list = nil
end
if g_fon_dev_list == nil then
if (config.AB_COUNT > 0) then
local analog_dev = general.listquery("telcfg:settings/MSN/Port/list(Name,Fax,GroupCall,AllIncomingCalls,OutDialing)")
for i,dev in pairs(analog_dev) do
if (dev.Name ~= "") then
local port_nums = {}
for k = 0, 9, 1 do
port_nums[k+1] = box.query("telcfg:settings/MSN/Port"..(i-1).."/MSN"..k)
end
cnt = cnt + 1
dev_list[cnt] = {}
dev_list[cnt].idx = i-1
dev_list[cnt].src = "fon123"
dev_list[cnt].name = dev.Name
dev_list[cnt].portname = "FON "..i
dev_list[cnt].port_id = tostring(i-1)
dev_list[cnt].intern = tostring(i)
dev_list[cnt].intern_id = i
dev_list[cnt].active = true
local numb = port_nums[1]
if string.sub(numb, #numb) == "#" then
numb = string.sub(numb, 1,#numb-1)
end
dev_list[cnt].number = numb
dev_list[cnt].number_query = "telcfg:settings/MSN/Port"..(i-1).."/MSN0"
dev_list[cnt].current_name_query = "telcfg:settings/MSN/Port"..(i-1).."/Name"
dev_list[cnt].ring_all_query = "telcfg:settings/MSN/Port"..(i-1).."/AllIncomingCalls"
dev_list[cnt].number_save_root = "telcfg:settings/MSN/Port"
dev_list[cnt].number_end_str = "MSN"
dev_list[cnt].outgoing = numb
dev_list[cnt].allin = dev.AllIncomingCalls == "1"
dev_list[cnt].internal = false
dev_list[cnt].incoming = {}
dev_list[cnt].incoming_query = {}
local num_cnt = 0
for j,num in ipairs(port_nums) do
if num ~= "" and string.sub(num, #num) ~= "#" then
num_cnt = num_cnt + 1
dev_list[cnt].incoming[num_cnt] = num
dev_list[cnt].incoming_query[num_cnt] = "telcfg:settings/MSN/Port"..(i-1).."/MSN"..(j-1)
end
end
if (dev.OutDialing == "2") then
dev_list[cnt].type = 'door'
elseif (dev.Fax == "1") then
dev_list[cnt].type = 'fax'
elseif (dev.GroupCall == "1") then
dev_list[cnt].type = 'fon'
else
dev_list[cnt].type = 'tam'
end
end
end
end
g_fon_dev_list = dev_list
else
dev_list = g_fon_dev_list
cnt = #dev_list
end
return dev_list, cnt
end
local g_isdn_dev_list
function get_isdn_default()
if (not g_isdn_dev_list) then
g_isdn_dev_list=read_nt_hotdiallist(true)
end
return g_isdn_dev_list[1]
end
function read_nt_hotdiallist(use_cache)
local dev_list = {}
local cnt = 0
if not use_cache then
g_isdn_dev_list = nil
end
if g_isdn_dev_list == nil then
if config.CAPI_NT then
cnt = 1
dev_list[cnt] = {}
dev_list[cnt].noDevice = true
dev_list[cnt].idx = 0
dev_list[cnt].src = "nthotdiallist"
dev_list[cnt].name = g_txtIsdnDefault
dev_list[cnt].portname = "FON S0"
dev_list[cnt].intern_id = 50
dev_list[cnt].type = "isdn"
dev_list[cnt].port_id = "3"
dev_list[cnt].intern = ""
dev_list[cnt].number = ""
dev_list[cnt].number_query = ""
dev_list[cnt].outgoing = box.query("telcfg:settings/MSN/NTDefault","")
dev_list[cnt].allin = false
dev_list[cnt].internal = false
dev_list[cnt].incoming = {}
dev_list[cnt].incoming_query = {}
for i=1, 9, 1 do
local num = box.query("telcfg:settings/NTHotDialList/Number"..i)
if (num ~= "") then
cnt = cnt + 1
dev_list[cnt] = {}
dev_list[cnt].idx = i
dev_list[cnt].src = "nthotdiallist"
dev_list[cnt].name = box.query("telcfg:settings/NTHotDialList/Name"..i)
dev_list[cnt].portname = "FON S0"
dev_list[cnt].port_id = "3"
dev_list[cnt].type = string.lower(box.query("telcfg:settings/NTHotDialList/Type"..i))
dev_list[cnt].intern = tostring("5"..i)
dev_list[cnt].intern_id = 50+i
dev_list[cnt].number = num
dev_list[cnt].number_query = "telcfg:settings/NTHotDialList/Number"..i
dev_list[cnt].current_name_query = "telcfg:settings/NTHotDialList/Name"..i
dev_list[cnt].ring_all_query = ""
dev_list[cnt].number_save_root = "telcfg:settings/NTHotDialList/Number"
dev_list[cnt].number_end_str = ""
dev_list[cnt].outgoing = ""
dev_list[cnt].allin = false
dev_list[cnt].internal = false
dev_list[cnt].incoming = {}
dev_list[cnt].incoming_query = {}
end
end
end
g_isdn_dev_list = dev_list
else
dev_list = g_isdn_dev_list
cnt = #g_isdn_dev_list
end
return dev_list, cnt
end
local g_fon_control_dev_list
function read_fon_control(use_cache)
local dev_list = {}
local cnt = 0
if not use_cache then
g_fon_control_dev_list = nil
end
if g_fon_control_dev_list == nil then
if config.DECT then
local fonlist = general.listquery("telcfg:settings/Foncontrol/User/list(Name,Type,Intern,Id,Phonebook)")
local dectUsers = general.listquery ("dect:settings/Handset/list(User,Manufacturer,Model,Subscribed,Codecs)")
local dectList = {}
for i,user in ipairs(dectUsers) do
dectList[user.User] = user
end
for i,dev in ipairs(fonlist) do
local n = i - 1
if (dev.Name ~= "" and dev.Id~="0") then
local user_nums = general.listquery("telcfg:settings/Foncontrol/User"..n.."/MSN/list(Number)")
cnt = cnt + 1
dev_list[cnt] = {}
dev_list[cnt].idx = n
dev_list[cnt].dectIdx = ""
dev_list[cnt].manufacturer = ""
dev_list[cnt].model = ""
dev_list[cnt].subscribed= ""
dev_list[cnt].codecs = ""
if dectList[dev.Id] then
dev_list[cnt].dectIdx = dectList[dev.Id]._node or ""
dev_list[cnt].manufacturer = dectList[dev.Id].Manufacturer or ""
dev_list[cnt].model = dectList[dev.Id].Model or ""
dev_list[cnt].subscribed = dectList[dev.Id].Subscribed or ""
dev_list[cnt].codecs = dectList[dev.Id].Codecs or ""
end
dev_list[cnt].src = "foncontrol"
dev_list[cnt].name = dev.Name
dev_list[cnt].portname = "DECT"
dev_list[cnt].type = "dect"
dev_list[cnt].phonebook = dev.Phonebook
dev_list[cnt].intern = tostring(dev.Intern)
dev_list[cnt].intern_id = tonumber(string.sub(dev.Intern,1,1)..string.sub(dev.Intern,3,3)) or 60
local numb = ""
if (user_nums[1]) then
numb = user_nums[1].Number
end
dev_list[cnt].out_only = false
if string.sub(numb, #numb) == "#" then
dev_list[cnt].out_only = true
numb = string.sub(numb, 1,#numb-1)
end
dev_list[cnt].number = numb
dev_list[cnt].number_query = "telcfg:settings/Foncontrol/User"..n.."/MSN0/Number"
dev_list[cnt].current_name_query = "telcfg:settings/Foncontrol/User"..n.."/Name"
dev_list[cnt].ring_all_query = "telcfg:settings/Foncontrol/User"..n.."/RingOnAllMSNs"
dev_list[cnt].number_save_root = "telcfg:settings/Foncontrol/User"
dev_list[cnt].number_end_str = "/MSN"
dev_list[cnt].outgoing = numb
dev_list[cnt].allin = box.query("telcfg:settings/Foncontrol/User"..n.."/RingOnAllMSNs") == "1"
dev_list[cnt].internal = false
dev_list[cnt].incoming = {}
dev_list[cnt].incoming_query = {}
local num_cnt = 0
for j,num in ipairs(user_nums) do
if num.Number ~= "" and string.sub(num.Number, #num.Number) ~= "#" then
num_cnt = num_cnt + 1
dev_list[cnt].incoming[num_cnt] = num.Number
dev_list[cnt].incoming_query[num_cnt] = "telcfg:settings/Foncontrol/User"..n.."/MSN"..(j-1).."/Number"
end
end
end
end
end
g_fon_control_dev_list = dev_list
else
dev_list = g_fon_control_dev_list
cnt = #g_fon_control_dev_list
end
return dev_list, cnt
end
local g_voip_dev_list
function read_voip_ext(use_cache)
local dev_list = {}
local cnt = 0
if not use_cache then
g_voip_dev_list = nil
end
if g_voip_dev_list == nil then
local add_ip_phones=true;
if config.FON_IPPHONE and add_ip_phones then
local ip_phones = general.listquery("telcfg:settings/VoipExtension/list(enabled,Name,RingOnAllMSNs)")
local voip_exts = general.listquery("voipextension:settings/extension/list(extension_number,reg_from_outside,clientid)")
for i,ip_phone in ipairs(ip_phones) do
if ip_phone.enabled == "1" then
local n = i - 1
for j,voip_ext in ipairs(voip_exts) do
if voip_ext.extension_number == "62"..n then
cnt = cnt + 1
local ip_nums = {}
for k = 0, 9, 1 do
ip_nums[k+1] = box.query("telcfg:settings/VoipExtension"..n.."/Number"..k)
end
dev_list[cnt] = {}
dev_list[cnt].idx = n
dev_list[cnt].src = "voipext"
dev_list[cnt].reg_from_outside = voip_ext.reg_from_outside == "1"
dev_list[cnt].clientid = voip_ext.clientid
if ip_phone.Name == "" then
ip_phone.Name = g_txtIpPhone.."62"..n
end
dev_list[cnt].name = ip_phone.Name
dev_list[cnt].portname = "LAN/WLAN"
dev_list[cnt].type = "ipphone"
dev_list[cnt].intern = tostring("62"..n)
dev_list[cnt].intern_id = 70+tonumber(n)
local numb = ip_nums[1]
if string.sub(numb, #numb) == "#" then
numb = string.sub(numb, 1,#numb-1)
end
dev_list[cnt].number = numb
dev_list[cnt].number_query = "telcfg:settings/VoipExtension"..n.."/Number0"
dev_list[cnt].current_name_query = "telcfg:settings/VoipExtension"..n.."/Name"
dev_list[cnt].ring_all_query = "telcfg:settings/VoipExtension"..n.."/RingOnAllMSNs"
dev_list[cnt].number_save_root = "telcfg:settings/VoipExtension"
dev_list[cnt].number_end_str = "/Number"
dev_list[cnt].outgoing = numb
dev_list[cnt].allin = ip_phone.RingOnAllMSNs == "1"
dev_list[cnt].internal = false
dev_list[cnt].incoming = {}
dev_list[cnt].incoming_query = {}
local num_cnt = 0
for m,num in ipairs(ip_nums) do
if num ~= "" and string.sub(num, #num) ~= "#" then
num_cnt = num_cnt + 1
dev_list[cnt].incoming[num_cnt] = num
dev_list[cnt].incoming_query[num_cnt] = "telcfg:settings/VoipExtension"..n.."/Number"..(m-1)
end
end
dev_list[cnt].netindex = j - 1
end
end
end
end
end
g_voip_dev_list = dev_list
else
dev_list = g_voip_dev_list
cnt = #g_voip_dev_list
end
return dev_list, cnt
end
local g_tam_dev_list
function is_valid_tam_nr(tamlist,cur_tam_idx)
for i,tam_elem in ipairs(tamlist) do
if (tam_elem.idx==cur_tam_idx) then
return true
end
end
return false
end
function get_tam_elem(tamlist,cur_tam_idx)
for i,tam_elem in ipairs(tamlist) do
if (tam_elem.idx==cur_tam_idx) then
return tam_elem
end
end
return nil
end
function read_tam(use_cache,get_all)
local dev_list = {}
local cnt = 0
if not use_cache then
g_tam_dev_list = nil
end
if g_tam_dev_list == nil then
if config.TAM_MODE and config.TAM_MODE > 0 then
local tams={}
if get_all~=nil and get_all==true then
tams = general.listquery("tam:settings/TAM/list(Active,Name,Display,MSNBitmap,NumNewMessages,NumOldMessages,RecordLength,RingCount,Mode,PushmailActive,PIN,MailAddress,PushmailServer,PushmailUser,PushmailPass,PushmailFrom,UserAnsVP,UserAnsRecVP,UserEndVP)")
else
tams = general.listquery("tam:settings/TAM/list(Active,Name,Display,MSNBitmap)")
end
local tam_nums = {}
for j = 0, 9, 1 do
tam_nums[j+1] = box.query("tam:settings/MSN"..j)
end
local use_stick=box.query("tam:settings/UseStick")
for i,tam in ipairs(tams) do
if tam.Display == "1" then
local n = i - 1
cnt = cnt + 1
dev_list[cnt] = {}
dev_list[cnt].incoming = {}
dev_list[cnt].incoming_query = {}
dev_list[cnt].idx = n
dev_list[cnt].src = "tam"
dev_list[cnt].name = ""
dev_list[cnt].use_stick = use_stick
dev_list[cnt].msn_bitmap = tonumber(tam.MSNBitmap)
local num_cnt = 0
local bitmask = bit.tobits(tam.MSNBitmap)
for k,num in ipairs(tam_nums) do
if num and num ~= "" and bitmask[k] == 1 then
num_cnt = num_cnt + 1
dev_list[cnt].incoming[num_cnt] = num
dev_list[cnt].incoming_query[num_cnt] = "tam:settings/MSN"..(k-1)
end
end
dev_list[cnt].all_tam_nums = tam_nums
if tam.Name == "" then
tam.Name = g_txtTamDefaultName.." "..tostring(i)
end
dev_list[cnt].name = tam.Name
dev_list[cnt].portname = g_txt_Integriert
dev_list[cnt].type = "tam"
dev_list[cnt].intern = tostring("60"..n)
dev_list[cnt].intern_id = 80+tonumber(n)
dev_list[cnt].number = num_cnt > 0 and dev_list[cnt].incoming[1] or ""
dev_list[cnt].number_query = num_cnt > 0 and "tam:settings/MSN0" or ""
dev_list[cnt].outgoing = ""
dev_list[cnt].allin = (n == 0 and num_cnt == 0)
dev_list[cnt].internal = true
dev_list[cnt].active = tam.Active == "1"
if get_all~=nil and get_all==true then
dev_list[cnt].num_newmessages = tam.NumNewMessages
dev_list[cnt].num_oldmessages = tam.NumOldMessages
dev_list[cnt].record_length = tonumber(tam.RecordLength)
dev_list[cnt].ring_count = tonumber(tam.RingCount)*5
dev_list[cnt].mode = tam.Mode
dev_list[cnt].pushmail_active = tam.PushmailActive
dev_list[cnt].pin = tam.PIN
dev_list[cnt].MailAddress = tam.MailAddress
if (tam.MailAddress~="") then
dev_list[cnt].mailaddress = tam.MailAddress
else
dev_list[cnt].mailaddress = box.query("emailnotify:settings/To")
end
dev_list[cnt].pushmail_server = tam.PushmailServer
dev_list[cnt].pushmail_user = tam.PushmailUser
dev_list[cnt].pushmail_pass = tam.PushmailPass
dev_list[cnt].pushmail_from = tam.PushmailFrom
dev_list[cnt].user_hint_msg = tam.UserAnsVP
dev_list[cnt].user_begin_msg = tam.UserAnsRecVP
dev_list[cnt].user_end_msg = tam.UserEndVP
end
end
end
g_tam_dev_list = dev_list
end
else
dev_list = g_tam_dev_list
cnt = #g_tam_dev_list
end
return dev_list, cnt
end
function is_any_faxmail_known(fax_elem)
for i=1,10,1 do
if (fax_elem.mail_addr~="") then
return true
end
end
return false
end
local g_fax_intern_dev_list
function read_fax_intern(use_cache)
local dev_list = {}
local cnt = 0
if not use_cache then
g_fax_intern_dev_list = nil
end
if g_fax_intern_dev_list == nil then
if config.FAX2MAIL then
if box.query("telcfg:settings/FaxMailActive") ~= "" then
cnt = 1
dev_list[cnt] = {}
dev_list[cnt].incoming = {}
dev_list[cnt].incoming_query = {}
dev_list[cnt].mail_addr = {}
local num_cnt = 0
for k = 0, 9, 1 do
local fax_num = box.query("telcfg:settings/FaxMSN"..k)
if fax_num and fax_num ~= "" then
num_cnt = num_cnt + 1
dev_list[cnt].incoming[num_cnt] = fax_num
dev_list[cnt].incoming_query[num_cnt] = "telcfg:settings/FaxMSN"..k
end
dev_list[cnt].mail_addr[k+1]=box.query("telcfg:settings/FaxMailAddress"..k)
end
dev_list[cnt].idx = 0
dev_list[cnt].src = "faxintern"
dev_list[cnt].name = g_txt_FaxInternDisplay
dev_list[cnt].portname = g_txt_Integriert
dev_list[cnt].type = "faxintern"
dev_list[cnt].intern = ""
dev_list[cnt].intern_id = 100
dev_list[cnt].number = num_cnt > 0 and dev_list[cnt].incoming[1] or ""
dev_list[cnt].number_query = num_cnt > 0 and "telcfg:settings/FaxMSN0" or ""
dev_list[cnt].outgoing = ""
dev_list[cnt].allin = false
dev_list[cnt].internal = true
dev_list[cnt].mode = box.query("telcfg:settings/FaxMailActive")
dev_list[cnt].active = dev_list[cnt].mode=="1" or dev_list[cnt].mode=="3" or dev_list[cnt].mode=="5"
dev_list[cnt].path = box.query("telcfg:settings/FaxSavePath")
end
end
g_fax_intern_dev_list = dev_list
else
dev_list = g_fax_intern_dev_list
cnt = #g_fax_intern_dev_list
end
return dev_list, cnt
end
function merge_dev_tab(dest_tab, source_tab)
for i, dev in ipairs(source_tab) do
dest_tab[#dest_tab + 1] = dev
end
return dest_tab
end
function exist_fon_device_name(name, cur_all_devices)
local all_devices = {}
if cur_all_devices then
all_devices = cur_all_devices
else
all_devices = get_all_fon_devices()
end
for i,elem in ipairs(all_devices) do
if (name == elem.name) then
return true
end
end
return false
end
function get_all_fon_devices(use_cache)
local all_dev = {}
local cnt = 0
local tmp_tab, tmp_cnt = read_fon_123(use_cache)
cnt = cnt + tmp_cnt
merge_dev_tab(all_dev, tmp_tab)
tmp_tab, tmp_cnt = read_nt_hotdiallist(use_cache)
cnt = cnt + tmp_cnt
merge_dev_tab(all_dev, tmp_tab)
tmp_tab, tmp_cnt = read_fon_control(use_cache)
cnt = cnt + tmp_cnt
merge_dev_tab(all_dev, tmp_tab)
tmp_tab, tmp_cnt = read_voip_ext(use_cache)
cnt = cnt + tmp_cnt
merge_dev_tab(all_dev, tmp_tab)
tmp_tab, tmp_cnt = read_tam(use_cache)
cnt = cnt + tmp_cnt
merge_dev_tab(all_dev, tmp_tab)
tmp_tab, tmp_cnt = read_fax_intern(use_cache)
cnt = cnt + tmp_cnt
merge_dev_tab(all_dev, tmp_tab)
g_dev_list = all_dev
return all_dev, cnt
end
function get_only_fon_devices(use_cache)
local all_dev = {}
local cnt = 0
local tmp_tab, tmp_cnt = read_fon_123(use_cache)
cnt = cnt + tmp_cnt
merge_dev_tab(all_dev, tmp_tab)
tmp_tab, tmp_cnt = read_nt_hotdiallist(use_cache)
cnt = cnt + tmp_cnt
merge_dev_tab(all_dev, tmp_tab)
tmp_tab, tmp_cnt = read_fon_control(use_cache)
cnt = cnt + tmp_cnt
merge_dev_tab(all_dev, tmp_tab)
g_dev_list = all_dev
return all_dev, cnt
end
function showIsdnDefault()
return false
end
function GetFonDeviceName(id)
return get_fonname(id, nil);
end
function get_fonname(Num,dataTable)
local fonname = "";
local fonnum=general.make_num(Num)
if (fonnum>=70 and fonnum<=79) then
local idx=fonnum-70+1
fonname=g_txtIpPhone
if (g_IpPhones.names[idx] and g_IpPhones.names[idx]~="") then
fonname=g_IpPhones.names[idx]
end
elseif (fonnum >= 60) then
return get_dect_name(Num,dataTable);
end
if (fonnum==1 or fonnum==2 or fonnum==3) then
fonname= g_MsnPortnames[fonnum]
elseif (fonnum==51 or fonnum==52 or fonnum==53 or
fonnum==54 or fonnum==55 or fonnum==56 or
fonnum==57 or fonnum==58) then
fonname=g_NTHotDialList[fonnum-50]
elseif (fonnum==9) then
fonname= TXT([[{?237:533?}]])
elseif (fonnum==50) then
if config.CAPI_NT and config.DECT and config.DECT2 then
fonname = TXT([[{?237:383?}]])
elseif config.CAPI_NT then
fonname = TXT([[{?237:875?}]])
elseif config.DECT and config.DECT2 then
fonname = TXT([[{?237:58?}]])
end
end
if (fonname=="") then
if (fonnum<4) then
fonname = "FON "..Num
else
fonname = TXT([[{?237:93?}]])
end
end
return fonname
end
function get_dect_name(Num,dataTable)
FonList = {}
if (dataTable == nil or dataTable.FonList==nil) then
Fonlist = general.listquery("telcfg:settings/Foncontrol/User/list(Id,Name,Intern)")
else
Fonlist = dataTable.FonList
end
local realNum = string.sub(Num,1,1).."1"..string.sub(Num,2,2)
for i,elem in ipairs(Fonlist) do
if (realNum == elem.Intern) then
return elem.Name
end
end
return Num
end
function get_ipphone(id)
local use_cache=false
tmp_tab, tmp_cnt = read_voip_ext(use_cache)
id=tonumber(id) or 0
local cnt, ip_phone = find_elem(tmp_tab, "voipext", "idx", id)
return ip_phone
end
function common_fon_default_values()
local fon_default_values = {}
fon_default_values["Fax"] = "0"
fon_default_values["GroupCall"] = "1"
fon_default_values["MSN0"] = "SIP0"
fon_default_values["OutDialing"] = "1"
fon_default_values["CLIR"] = "0"
fon_default_values["CLIP"] = "2"
fon_default_values["CallWaitingProt"] = "1"
fon_default_values["NoRingWithNightSetting"] = "1"
fon_default_values["COLR"] = "0"
fon_default_values["MWI_Voice"] = "0"
fon_default_values["MWI_Fax"] = "0"
fon_default_values["MWI_Mail"] = "0"
for i = 0, 9, 1 do
fon_default_values["MSN"..i] = ""
end
return fon_default_values
end
function delete_isdn_device(device)
local ctlmgr_del={}
local fax_port_list = {}
local isdn_dev_list = read_nt_hotdiallist()
local is_last_isdn_device = #isdn_dev_list < 2
local is_isdn_default = device.src == "nthotdiallist" and device.idx == "0"
if (is_isdn_default or is_last_isdn_device) then
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port3/RingAllowed", "1")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port3/NoRingTime", "")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port3/BusyOnBusy", "1")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port3/CallWaitingProt", "0")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port3/NoRingWithNightSetting", "1")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port3/COLR", "0")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port3/MWI_Voice", "0")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port3/MWI_Fax", "0")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port3/MWI_Mail", "0")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port3/MWI_Once", "0")
if (string.lower(box.query("telcfg:settings/NTHotDialList/Type0")) == "fax") then
table.insert(fax_port_list, 0)
end
end
if not is_isdn_default then
local port_no = device.idx;
cmtable.add_var(ctlmgr_del, "telcfg:settings/NTHotDialList/Name"..port_no, "")
cmtable.add_var(ctlmgr_del, "telcfg:settings/NTHotDialList/Number"..port_no, "")
cmtable.add_var(ctlmgr_del, "telcfg:settings/NTHotDialList/Type"..port_no, "")
if (string.lower(device.type) == "fax") then
table.insert(fax_port_list, port_no)
end
end
for i,port in ipairs(fax_port_list) do
local isdn_number = box.query("telcfg:settings/NTHotDialList/Number"..port)
for i = 2, 0, -1 do
if (box.query("telcfg:settings/FaxModem"..i.."/Type") == "0" and box.query("telcfg:settings/FaxModem"..i.."/Number") == isdn_number) then
local can_del=true
for index,isdn_device in ipairs(isdn_dev_list) do
if (isdn_device.idx ~= port and isdn_device.number == isdn_number and string.lower(isdn_device.type) == "fax") then
can_del=false
break
end
end
if can_del then
cmtable.add_var(ctlmgr_del, "telcfg:settings/FaxModem"..i.."/Type", "")
cmtable.add_var(ctlmgr_del, "telcfg:settings/FaxModem"..i.."/Number", "")
end
break
end
end
end
return box.set_config(ctlmgr_del)
end
function delete_faxintern_device()
local ctlmgr_del={}
cmtable.add_var(ctlmgr_del, "telcfg:settings/FaxMailActive", "")
for i = 0, 9, 1 do
cmtable.add_var(ctlmgr_del, "telcfg:settings/FaxMSN"..i, "")
end
for j = 0, 9, 1 do
cmtable.add_var(ctlmgr_del, "telcfg:settings/FaxMailAddress"..j, "")
end
cmtable.add_var(ctlmgr_del, "telcfg:settings/FaxSavePath", "")
return box.set_config(ctlmgr_del)
end
function delete_foncontrol_device(device)
if (device.type == "dect") then
local dect_idx = tonumber(string.sub(device.dectIdx, 8))
if (dect_idx) then
local ctlmgr_del={}
cmtable.add_var(ctlmgr_del, "dect:command/Unsubscribe", dect_idx)
local tam_nr = 0
local bits = 0
local bits_new = 0
local email_bitmap_list = general.listquery ("telcfg:settings/Foncontrol/Email/list(Bitmap)")
for index,bitmap in pairs(email_bitmap_list) do
bits = box.query("telcfg:settings/Foncontrol/"..bitmap._node.."/Bitmap")
for j = 0, 9, 1 do
if (j~=dect_idx and bit.isset(bits, j)) then
bit.set(bits_new, j)
end
end
cmtable.add_var(ctlmgr_del, "telcfg:settings/Foncontrol/"..bitmap._node.."/Bitmap", bits_new)
bits_new = 0
end
return box.set_config(ctlmgr_del)
end
end
end
function create_tam_empty_timeplans()
local errmsg=""
if config.TIMERCONTROL then
local cnt = tonumber(box.query("timer:settings/TamTimerXML/count"))
if cnt==0 then
require("cmtable")
local createtam={}
for tam_idx=0,4,1 do
cmtable.add_var(createtam,"timer:settings/TamTimerXML"..tostring(tam_idx),[[<rule id=]]..tostring(tam_idx)..[[ enabled="0"></rule>]])
end
local err, msg = box.set_config(createtam)
if err ~= 0 then
errmsg=general.create_error_div(err,msg)
end
end
end
return errmsg
end
function delete_tam_device(device)
require ("foncalls")
foncalls.ClearTam(device.idx)
local port_no = device.idx
local ctlmgr_del={}
cmtable.add_var(ctlmgr_del, "tam:settings/TAM"..port_no.."/Display", "0")
cmtable.add_var(ctlmgr_del, "tam:settings/TAM"..port_no.."/MSNBitmap", "0")
cmtable.add_var(ctlmgr_del, "tam:settings/TAM"..port_no.."/Active", "0")
cmtable.add_var(ctlmgr_del, "tam:settings/TAM"..port_no.."/PIN", "0000")
cmtable.add_var(ctlmgr_del, "tam:settings/TAM"..port_no.."/Name", "")
if config.TIMERCONTROL then
cmtable.add_var(ctlmgr_del, "timer:settings/TamTimerXML"..port_no,[[<rule id="]]..tostring(port_no)..[[" enabled="0"></rule>]])
end
return box.set_config(ctlmgr_del)
end
function delete_fon_device(port_no)
local ctlmgr_del={}
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port"..port_no.."/Name", "")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port"..port_no.."/MWI_Once", "0")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port"..port_no.."/AllIncomingCalls", "0")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port"..port_no.."/BusyOnBusy", "1")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port"..port_no.."/RingAllowed", "1")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port"..port_no.."/NoRingTime", "")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port"..port_no.."/OutDialing", "1")
for Index = 0, 3, 1 do
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port"..port_no.."/DoorlineNumOriginal"..Index, "")
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port"..port_no.."/DoorlineNumReplace"..Index, "")
end
for index,value in pairs(common_fon_default_values()) do
cmtable.add_var(ctlmgr_del, "telcfg:settings/MSN/Port"..port_no.."/"..index, value)
end
return box.set_config(ctlmgr_del)
end
function delete_voip_device(port_no)
local net_name = tonumber(port_no) + 620
local ctlmgr_del={}
local voip_list = general.listquery ("voipextension:settings/extension/list(enabled,extension_number,authname,passwd)")
for index,voip in pairs(voip_list) do
if (tonumber(voip.extension_number) == net_name) then
cmtable.add_var(ctlmgr_del, "voipextension:command/"..voip._node, "delete")
end
end
cmtable.add_var(ctlmgr_del, "telcfg:settings/VoipExtension"..port_no.."/enabled", 0)
return box.set_config(ctlmgr_del)
end
function delete_device(device)
if (device.src == "tam") then
return delete_tam_device(device)
elseif (device.src == "faxintern") then
return delete_faxintern_device()
elseif (device.src == "nthotdiallist") then
return delete_isdn_device(device)
elseif (device.src == "fon123") then
return delete_fon_device(device.idx)
elseif (device.src == "voipext") then
return delete_voip_device(device.idx)
elseif (device.src == "foncontrol") then
return delete_foncontrol_device(device)
end
end
function is_fon_port_configured(port_no)
if (box.query("telcfg:settings/MSN/Port"..port_no.."/Name") ~= "Fon ".. tonumber(port_no)+1) then
return false
end
if (box.query("telcfg:settings/MSN/Port"..port_no.."/AllIncomingCalls") ~= "1") then
return false
end
if (box.query("telcfg:settings/MSN/Port"..port_no.."/BusyOnBusy") ~= "0") then
return false
end
if box.query("telcfg:settings/MSN/Port"..port_no.."/MSN0") ~= "SIP0" and box.query("telcfg:settings/MSN/Port"..port_no.."/MSN0") ~= "" then
return false
end
for index,value in pairs(common_fon_default_values()) do
if box.query("telcfg:settings/MSN/Port"..port_no.."/"..index) ~= value then
return false
end
end
return true;
end
function all_fon_ports_configured()
local fon123_list = fon_devices.read_fon_123()
for i,dev in pairs(fon123_list) do
if (dev.number == "" or is_fon_port_configured(i)) then
return false
end
end
return true
end
function all_isdn_ports_configured()
return true
end
function get_connected_handset_count()
local count = 0
for k = 0, 5, 1 do
local dect_subscribe = box.query("dect:settings/Handset"..k.."/Subscribed")
if (dect_subscribe == "1" ) then
count = count + 1
end
end
return count
end
function all_dect_ports_configured()
for k = 0, 5, 1 do
local dect_subscribe = box.query("dect:settings/Handset"..k.."/Subscribed")
if (dect_subscribe == "0" ) then
return false
end
end
return true
end
function all_tam_ports_configured()
if (#read_tam(true) < 5) then
return false
end
return true
end
function all_ip_ports_configured()
if (#read_voip_ext(true) < 10) then
return false
end
return true
end
function all_ports_configured()
local ip_devices = read_voip_ext(true)
if not all_ip_ports_configured() then
return false
end
if not all_fon_ports_configured() then
return false
end
if not all_isdn_ports_configured() then
return false
end
if not all_dect_ports_configured() then
return false
end
local fax_mail_active = box.query("telcfg:settings/FaxMailActive")
if (fax_mail_active == "" ) then
return false
end
if not all_tam_ports_configured() then
return false
end
return true
end
function box_is_voip_only()
return false;
end
function no_fondevice_configured(fonlist)
if(fonlist==nil) then
return false
end
for i,elem in ipairs(fonlist) do
if (isIsdnDefault(elem)) or (elem.src=="fon123" and not elem.allin) then
else
return false
end
end
return true
end
function is_any_fondevice_configured(fonlist)
return not no_fondevice_configured(fonlist)
end
function find_elem(fonlist,src,key,content)
for i,elem in ipairs(fonlist) do
if (elem.src==src and elem[key]==content) then
return i,elem
end
end
return nil
end
function find_device(fonlist, intern_id)
local device = {}
for index,value in ipairs(fonlist) do
if (tostring(value.intern_id) == intern_id) then
device = value
break
end
end
return device
end
function get_tamname(tamindex)
local webvar = [[tam:settings/TAM%d/Name]]
local idx = tonumber(tamindex)
if idx then
return box.query(webvar:format(idx)) or ""
end
return ""
end
local enum_ring_allowed = setmetatable({
["0"] = 'Deactivated',
["1"] = 'All',
["2"] = 'NoMo_Fr_SetRingTimeSa_So',
["3"] = 'NoSa_So_SetRingTimeMo_Fr',
["4"] = 'EverMo_Fr_SetRingTimeSa_So',
["5"] = 'EverSa_So_SetRingTimeMo_Fr'
}, { __index = function(self, key) return 'dont_know' end}
)
local enum_state_allowed = table.transpose(enum_ring_allowed)
function twopartnumber(n)
if n > 9 then
return tostring(n)
end
return "0"..n
end
function splitnumber(str)
local strings = string.find(str, ":")
local part_a = string.sub(str,1,strings[1]-1)
local part_b = string.sub(str,strings[1]+1,string.len(str))
return tostring(twopartnumber(a)..twopartnumber(b))
end
function SplitStr( szOrg, szSep)
local n = 1
local ret = { "", "" }
local start = string.find(szOrg, szSep)
if start ~= nil then start = start - 1 end
while (start ~= nil) do
local ende = string.len( szOrg)
local szTmp = string.sub( szOrg, 0, start)
if ( szTmp ~= "") then
ret[n] = szTmp
n = n + 1
end
szOrg = string.sub( szOrg, (start+2), ende)
start = string.find( szOrg, szSep)
if start ~= nil then
start = start - 1
end
end
if ( string.len(szOrg) > 0) then
ret[n] = szOrg
end
return ret
end
function get_ring_device(device,id)
if (device == "fon123") then
return get_fon123_ring_data(id)
end
return nil
end
function get_fon123_phonedata(id)
for i,elem in ipairs(fon_devices.read_fon_123()) do
if tostring(elem["idx"]) == tostring(id) then
return elem
end
end
return nil
end
function get_fon123_ring_data(port)
return get_ring_data("telcfg:settings/MSN/"..port)
end
function get_dect_ring_data(idx)
local data = get_ring_data("telcfg:settings/Foncontrol/User"..idx)
data.flags = tonumber(box.query([[telcfg:settings/Foncontrol/User]]..idx..[[/NoRingTimeFlags]])) or 0
return data
end
function get_ring_data(query_lib)
local data = {}
data.id=query_lib
data.NightEnd_Values = {}
data.NightStart_Values = {}
local NightStart_Value = [[00:00]]
local NightEnd_Value = [[00:00]]
local RingState = box.query(query_lib..[[/RingAllowed]])
data.RingAllowed = enum_ring_allowed[RingState]
data.NoRingWithNightSetting = box.query(query_lib..[[/NoRingWithNightSetting]])
data.NoRingTime = box.query(query_lib..[[/NoRingTime]])
data.night_time_control_enabled = box.query([[box:settings/night_time_control_enabled]])
if data.night_time_control_enabled == "1" and data.NoRingWithNightSetting == "1" then
local L_NightStart = box.query([[box:settings/night_time_control_off_time]])
if string.len(L_NightStart) > 0 then
NightStart_Value = L_NightStart
end
local L_NightEnd = box.query([[box:settings/night_time_control_on_time]])
if string.len(L_NightEnd) > 0 then
NightEnd_Value = L_NightEnd
end
data.NightStart_Values = SplitStr(NightStart_Value, ":")
data.NightEnd_Values = SplitStr(NightEnd_Value, ":")
else
if data.NoRingTime ~= "" then
if get_locked(data.RingAllowed) then
table.insert(data.NightEnd_Values, string.sub(data.NoRingTime,1,2))
table.insert(data.NightEnd_Values, string.sub(data.NoRingTime,3,4))
table.insert(data.NightStart_Values, string.sub(data.NoRingTime,5,6))
table.insert(data.NightStart_Values, string.sub(data.NoRingTime,7,8))
else
table.insert(data.NightStart_Values, string.sub(data.NoRingTime,1,2))
table.insert(data.NightStart_Values, string.sub(data.NoRingTime,3,4))
table.insert(data.NightEnd_Values, string.sub(data.NoRingTime,5,6))
table.insert(data.NightEnd_Values, string.sub(data.NoRingTime,7,8))
end
else
data.NightStart_Values = SplitStr(NightStart_Value, ":")
data.NightEnd_Values = SplitStr(NightEnd_Value, ":")
end
end
if data.NightEnd_Values[1] == "00" and data.NightEnd_Values[2] == "00" then
data.NightEnd_Values[1] = "24"
end
return data
end
function get_locked(allowed)
if allowed == "NoMo_Fr_SetRingTimeSa_So" or allowed == "NoSa_So_SetRingTimeMo_Fr" then
return true
end
return false
end
function get_allow_state(allowed)
if allowed == "NoMo_Fr_SetRingTimeSa_So" or allowed == "EverMo_Fr_SetRingTimeSa_So" then
return "weekend"
elseif allowed == "NoSa_So_SetRingTimeMo_Fr" or allowed == "EverSa_So_SetRingTimeMo_Fr" then
return "workday"
end
return "everday"
end
