--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
require("general")
require("textdb")
require("config")
require("bit")
require("fon_numbers")
require("fon_devices")
require"pushservice"
require("cmtable")
require("http")
function ports_exist()
return true
end
function no_free_ports()
if ports_exist() then
return fon_devices.all_ports_configured()
else
return true
end
end
function get_delete_msg_table(fon_list)
local del_msgs = {}
for index,device in ipairs(fon_list) do
local msg = ""
del_msgs[tostring(device.intern_id)] = get_delete_msg(device.type, device.src, device.idx)
end
return del_msgs
end
function get_delete_msg(fon_type, src, idx)
if (fon_type == "ab") then
return TXT([[{?4255:742?}]])..[[\n\n]]..TXT([[{?4255:874?}]])
elseif (fon_type == "fax") then
return TXT([[{?4255:578?}]])..[[\n\n]]..TXT([[{?4255:51?}]])
elseif (fon_type == "faxintern") then
return TXT([[{?4255:11?}]])..[[\n\n]]..TXT([[{?4255:696?}]])
elseif (fon_type == "isdn") then
if (src == "nthotdiallist" and idx == "0") then
return TXT([[{?4255:700?}]])
else
return TXT([[{?4255:581?}]])..[[\n\n]]..TXT([[{?4255:755?}]])
end
elseif (fon_type == "ipphone") then
return TXT([[{?4255:6503?}]])..[[\n\n]]..TXT([[{?4255:870?}]])
elseif (fon_type == "fon") then
return TXT([[{?4255:895?}]])..[[\n\n]]..TXT([[{?4255:493?}]])
elseif (fon_type == "tam") then
return TXT([[{?4255:523?}]])
elseif (fon_type == "dect") then
return TXT([[{?4255:181?}]])..[[\n\n]]..TXT([[{?4255:777?}]])
else
return TXT([[{?4255:672?}]])
end
end
function new_device_button_disabled()
if (no_free_ports()) then
box.out("disabled")
end
end
function write_no_unconfigurable_devices()
if (ports_exist() and fon_devices.all_ports_configured()) then
box.out([[
<p>]]..
TXT([[{?4255:915?}]])
..[[</p>
]])
end
end
function get_in_out_table(device)
local in_out_table = {}
in_out_table.incoming = {}
if (device.type == "tam" and not device.active) then
in_out_table.incoming[1] = TXT([[{?4255:4?}]])
elseif (device.allin) then
in_out_table.incoming[1] = TXT([[{?4255:837?}]])
elseif (device.number == "") then
if (device.src == "tam") then
if(device.idx==0) then
in_out_table.incoming[1] = TXT([[{?4255:142?}]])
end
else
if #device.incoming > 0 then
in_out_table.incoming = device.incoming
else
in_out_table.incoming[1] = "-"
end
end
else
in_out_table.incoming = device.incoming
end
local sip_numbers = fon_numbers.get_sip_num()
in_out_table.outgoing = device.outgoing
for index,value in ipairs(sip_numbers.numbers) do
if (value.id == string.lower(device.outgoing)) then
in_out_table.outgoing = value.msnnum
end
for j,inc_number in ipairs(in_out_table.incoming ) do
if (not device.allin and value.id == string.lower(inc_number)) then
in_out_table.incoming[j] = value.msnnum
end
end
end
local mobile_numbers = fon_numbers.get_mobile_msn()
for index,value in ipairs(mobile_numbers.numbers) do
if (value.id == string.lower(device.outgoing)) then
in_out_table.outgoing = value.number
end
for j,inc_number in ipairs(in_out_table.incoming ) do
if (not device.allin and value.id == string.lower(inc_number)) then
in_out_table.incoming[j] = value.number
end
end
end
local pots = fon_numbers.get_pots()
for index,value in ipairs(pots.numbers) do
if (string.lower(value.id) == string.lower(device.outgoing)) then
in_out_table.outgoing = value.number
end
for j,inc_number in ipairs(in_out_table.incoming) do
if (not device.allin and string.lower(value.id) == string.lower(inc_number)) then
in_out_table.incoming[j] = value.number
end
end
end
if (device.src == "faxintern") then
if (device.outgoing == "**329" or not device.outgoing) then
device.outgoing = TXT([[{?4255:656?}]])
end
end
if (in_out_table.outgoing == "") then
in_out_table.outgoing = "-"
elseif (in_out_table.outgoing == "POTS") then
in_out_table.outgoing = TXT([[{?4255:981?}]])
end
return in_out_table
end
function write_fon_table(fon_devices)
local str_class=[[]]
local str_span =[[]]
if not g_print_mode then
str_class=[[sortable]]
str_span =[[<span class="sort_no">&nbsp;</span>]]
end
box.out([[
<table id="uiFondevicesTbl" class="zebra">
<tr class="thead">
<th class="]]..str_class..[[">]]..TXT([[{?4255:70?}]])..str_span..[[</th>
<th class="]]..str_class..[[">]]..TXT([[{?4255:180?}]])..str_span..[[</th>
<th class="]]..str_class..[[">]]..TXT([[{?4255:873?}]])..[[<br>]]..TXT([[{?4255:352?}]])..str_span..[[</th>
<th class="]]..str_class..[["><br>]]..TXT([[{?4255:856?}]])..str_span..[[</th>
<th class="]]..str_class..[["><br>]]..TXT([[{?4255:312?}]])..str_span..[[</th>
<th class="buttonrow"></th>
<th class="buttonrow"></th>
<th class="buttonrow"></th>
</tr>
]])
local no_rule_txt = TXT([[{?4255:702?}]])
local no_rule = true
for index,value in ipairs(fon_devices) do
if (value.intern_id ~= 50 and not(value.src=="tam" and value.enabled==false)) then
no_rule = false
local onclick = "onDeleteClick(value)"
local internal = "0"
local profile_name = TXT([[{?6501:49?}]])
local in_out_table = get_in_out_table(value)
box.out([[<tr>
<td title="]]..box.tohtml(value.name)..[[">]]..box.tohtml(value.name)..[[</td>
<td>]]..box.tohtml(value.portname)..[[</td>]]
)
if (value.src == "nthotdiallist") then
box.out([[<td colspan="2">]]..box.tohtml(TXT([[{?4255:242?}]]))..[[</td>]])
else
local incoming_string = ""
for i, inc_numer in ipairs(in_out_table.incoming) do
if (i == 1) then
incoming_string = box.tohtml(inc_numer)
else
incoming_string = incoming_string.."<br>"..box.tohtml(inc_numer)
end
end
box.out(
[[<td>]]..box.tohtml(in_out_table.outgoing)..[[</td>
<td><div class="incomingnumbers" id="uiIncommingNumbers]]..value.src..value.idx..[[">]]..incoming_string..[[</div></td>]]
)
end
if not value.intern or value.intern=="" then
box.out([[<td></td>]])
else
box.out([[<td>**]]..box.tohtml(value.intern)..[[</td>]])
end
if value.src=="tam" then
local switch_class = "switch_off"
if value.active then
switch_class = "switch_on"
end
box.out([[<td class="buttonrow"><a href="javascript:abSwitch.toggle(']]..value.idx..[[', ']]..box.glob.sid..[[')"><div id="uiSwitch]]..value.idx..[[" class="]]..switch_class..[["></div></a></td>]])
else
box.out([[<td class="buttonrow"></td>]])
end
write_button_td(value, "/css/default/images/bearbeiten.gif", "edit_protocol", "edit", TXT([[{?txtIconBtnEdit?}]]), "", internal == "1")
write_button_td(value, "/css/default/images/loeschen.gif", "delete_protocol", "delete", TXT([[{?txtIconBtnDelete?}]]), onclick)
box.out("</tr>")
end
end
if (no_rule) then
box.out([[<tr><td colspan="7" class="txt_center">]]..no_rule_txt)
local react_on_all_numbers=false;
for i = 0, config.AB_COUNT-1, 1 do
if box.query("telcfg:settings/MSN/Port"..i.."/AllIncomingCalls") == "1" then
react_on_all_numbers=true;
break
end
end
if (react_on_all_numbers) then
box.out([[<br>]]..TXT([[{?4255:75?}]]))
else
box.out([[<br>]]..TXT([[{?4255:760?}]]))
end
box.out([[</td></tr>]])
end
box.out([[</table>]])
end
function write_button_td(value, icon, id, name, label, handler, empty)
box.out([[<td class="buttonrow">]])
if not (empty) then
box.out(general.get_icon_button(icon, id, name, value.intern_id, label, handler))
end
box.out([[</td>]])
end
function get_full_page_name(page_name)
if (page_name=="fondevices_list") then
return "/fon_devices/fondevices_list.lua"
elseif (page_name=="dect_list") then
return "/dect/dect_list.lua"
elseif (page_name=="assi_fondevices_list") then
return "/assis/assi_fondevices_list.lua"
end
end
function get_fondevices_option_html(number, id_key)
if not id_key then
id_key = "intern_id"
end
local str_html = [[]]
local fondevs=fon_devices.get_all_fon_devices()
local sel=""
local no_selected=true
if (fon_devices.is_any_fondevice_configured(fondevs)) then
for i,elem in ipairs(fondevs) do
sel=""
if (number==tostring(elem[id_key])) then
no_selected=false
sel=[[selected]]
end
if (elem.intern_id==50) then
elem.name = TXT([[{?4255:630?}]])
end
if (elem.type~="door" and elem.type~="tam" and elem.type~="fax" and elem.type~="faxintern") then
if elem[id_key] and elem[id_key] ~= "" then
str_html = str_html..[[<option value="]]..box.tohtml(elem[id_key])..[[" ]]..sel..[[>]]..box.tohtml(elem.name)..[[</option>]]
end
end
end
else
local fon = {
TXT([[{?4255:1443?}]]),
TXT([[{?4255:344?}]]),
TXT([[{?4255:231?}]])
}
for i=1,config.AB_COUNT do
sel=""
if (number==tostring(i)) then
no_selected=false
sel=[[selected]]
end
local x,elem=fon_devices.find_elem(fondevs,"fon123","intern_id",tostring(i))
if (elem and elem.name~="") then
fon[i]=elem.name
end
str_html = str_html..[[<option value="]]..tostring(i)..[[" ]]..sel..[[>]]..box.tohtml(fon[i])..[[</option>]]
end
sel=""
if (number=="50") then
no_selected=false
sel=[[selected]]
end
if config.CAPI_NT then
str_html = str_html..[[<option value="50" ]]..sel..[[>]]..box.tohtml(TXT([[{?4255:268?}]]))..[[</option>]]
end
end
sel=""
if (number=="9" or no_selected) then
sel=[[selected]]
end
str_html = str_html..[[<option value="9" ]]..sel..[[>]]..box.tohtml(TXT([[{?4255:156?}]]))..[[</option>]]
return str_html, no_selected
end
function write_fondevices(number)
box.out(get_fondevices_option_html(number, "intern"))
end
function show_device(device, menu, page_name, popup_url)
local param = {}
menu = "fon_devices"
local luapage = "isdn"
if (device.src == "tam") then
param={}
table.insert(param, http.url_param('TamNr', device.idx))
table.insert(param, http.url_param('back_to_page', get_full_page_name(page_name)))
table.insert(param, http.url_param('popup_url', popup_url))
http.redirect(href.get("/fon_devices/edit_tam.lua", unpack(param)))
return
elseif (device.src == "faxintern") then
param={}
table.insert(param, http.url_param('back_to_page', get_full_page_name(page_name)))
table.insert(param, http.url_param('popup_url', popup_url))
http.redirect(href.get("/fon_devices/edit_fax_num.lua", unpack(param)))
return
elseif (device.src == "nthotdiallist") then
luapage = "edit_isdn_name"
if (device.type == "isdn") then
luapage = "edit_isdn_num"
end
table.insert(param, http.url_param('idx', device.idx))
table.insert(param, http.url_param('back_to_page', get_full_page_name(page_name)))
table.insert(param, http.url_param('popup_url', popup_url))
elseif (device.src == "fon123") then
luapage = "edit_fon_num"
local device_kind = TXT([[{?4255:919?}]])
local device_type = "Fon"
if (device.type == "tam") then
device_kind = TXT([[{?4255:505?}]])
device_type = "Tam"
elseif (device.type == "fax") then
device_kind = TXT([[{?4255:468?}]])
device_type = "Fax"
elseif (device.type == "door") then
device_type = "Door"
luapage = "edit_doorline_num"
end
table.insert(param, http.url_param('type', device_type))
table.insert(param, http.url_param('idx', device.idx))
table.insert(param, http.url_param('back_to_page', get_full_page_name(page_name)))
table.insert(param, http.url_param('popup_url', popup_url))
elseif (device.src == "voipext") then
param={}
table.insert(param, http.url_param('ip_idx', device.idx))
table.insert(param, http.url_param('back_to_page', get_full_page_name(page_name)))
table.insert(param, http.url_param('popup_url', popup_url))
http.redirect(href.get("/fon_devices/edit_ipfon_num.lua", unpack(param)))
elseif (device.src == "foncontrol") then
menu = "fon_devices"
luapage = "edit_dect_num"
local idx = device.idx;
if (device.idx == "0") then
local new_user = box.query("telcfg:settings/Foncontrol/User/newid")
idx = string.sub(new_user, #new_user)
end
table.insert(param, http.url_param('idx', idx))
table.insert(param, http.url_param('back_to_page', get_full_page_name(page_name)))
table.insert(param, http.url_param('popup_url', popup_url))
end
http.redirect(href.get("/"..menu.."/"..luapage..'.lua', unpack(param)))
end
function do_new_device(param, luaassiPage, assiPage)
if param == nil then
param = {}
end
if assiPage==nil then
assiPage = "fon_config_Start"
end
if luaassiPage==nil then
luaassiPage = "/assis/assi_telefon_start.lua"
end
if (fon_numbers.get_number_count("all")==0) then
table.insert(param, http.url_param('back_to_page', luaassiPage))
http.redirect(href.get("/assis/assi_fon_nums.lua", unpack(param)))
return
else
table.insert(param, http.url_param('HTMLConfigAssiTyp', "FonOnly"))
end
http.redirect(href.get(luaassiPage, unpack(param)))
end
function get_edit_dect_tabs(idx, params)
local param = http.url_param("idx", idx)
for name, value in pairs(params) do
param = param .. "&" .. http.url_param(name, value)
end
return {
{ page = [[/fon_devices/edit_dect_num.lua]], text = [[{?2575:433?}]], param = param },
{ page = [[/fon_devices/edit_dect_ring_tone.lua]], text = [[{?2575:50?}]], param = param },
{ page = [[/fon_devices/edit_dect_ring_block.lua]], text = [[{?2575:267?}]], param = param },
{ page = [[/fon_devices/edit_dect_option.lua]], text = [[{?2575:679?}]], param = param }
}
end
function no_number_configured()
return not fon_devices.box_is_voip_only() and fon_numbers.get_number_count("all")==0
end
function all_fon123_ports_configured_and_unequal()
for i = 0, config.AB_COUNT-1, 1 do
local rule_port = fon_numbers.get_rul_port(i)
if (not rule_port or rule_port.name ~= "" or rule_port.num_out == "") then
return false
end
end
return true;
end
function all_fon123_ports_empty()
for i = 0, config.AB_COUNT-1, 1 do
local name = box.query("telcfg:settings/MSN/Port"..i.."/Name")
if (name ~= "") then
return false
end
for j = 0, 10, 1 do
local number = box.query("telcfg:settings/MSN/Port"..i.."/MSN"..j)
if ( number ~= "") then
return false
end
end
local all_in = box.query("telcfg:settings/MSN/Port"..i.."/AllIncomingCalls")
if (all_in ~= "1") then
return false
end
end
return true;
end
if config.TIMERCONTROL then
require("timer")
g_timer_id = "uiTimer"
end
local is_usb_host = function()
return config.USB_HOST or config.USB_HOST_AVM or config.USB_HOST_TI
end
local function get_checked(val)
if val then
return [[checked]]
end
return ""
end
local function get_disabled(val)
if val then
return [[disabled]]
end
return ""
end
local function get_visible(val)
if not val then
return [[hide]]
end
return ""
end
function is_num_configured(elem, num)
if (not elem) then
return false
end
function get_sipnum(sipid)
sipid = string.lower(sipid)
require("fon_numbers")
local sip_numbers = fon_numbers.get_sip_num()
for index,value in ipairs(sip_numbers.numbers) do
if value.id == sipid then
--return value.number
return value.msnnum
end
end
return ""
end
for i,configured_num in ipairs(elem.incoming) do
if string.find(configured_num,"SIP") ~= nil then
configured_num = get_sipnum(configured_num)
elseif string.find(configured_num,"POTS") ~= nil then
if (num~="POTS") then
configured_num = box.query("telcfg:settings/MSN/POTS")
end
end
if (configured_num==num) then
return true
end
end
return false
end
function has_internal_mem()
require("bit")
local internal_mem= not bit.isset(tonumber(box.query("tam:settings/Status")) or 0, 2)
return internal_mem
end
function tam_usb_usable()
local use_stick=box.query("tam:settings/UseStick")
local is_usbstick_present=use_stick=="1" or use_stick=="2"
return (not has_internal_mem() and is_usbstick_present) or has_internal_mem()
end
function tam_usb_possible()
if not config.FON or (not config.TAM_MODE or config.TAM_MODE==0) or not is_usb_host() then return false end
return tam_usb_usable()
end
function is_num_already_used(tam_list,num,cur_idx)
for i,tam_elem in ipairs(tam_list) do
if (cur_idx~=tam_elem.idx and is_num_configured(tam_elem,num)) then
return true
end
end
return false
end
function react_on_all(elem)
return elem.allin
end
g_numbers={}
g_count_checked=0
function get_query_for_all_or_one(elem)
local is_all_checked=[[]]
local is_sel_checked=[[checked]]
local is_sel_options_visible=[[]]
if (react_on_all(elem)) then
is_all_checked=[[checked]]
is_sel_checked=[[]]
is_sel_options_visible=[[display:none]]
end
local str=
[[
<input type="radio" id="uiAllNums" name="num_selection" value="all_nums" ]]..is_all_checked..[[ onclick="OnSelNum('all_nums');"><label for="uiAllNums">]]..TXT([[{?4255:34?}]])..[[</label><br>
<input type="radio" id="uiSelNums" name="num_selection" value="sel_nums" ]]..is_sel_checked..[[ onclick="OnSelNum('sel_nums');"><label for="uiSelNums">]]..TXT([[{?4255:22?}]])..[[</label>
]]
return str,is_sel_options_visible
end
function get_optional_numbers(elem,is_sel_options_visible)
local str=[[<div id="uiOptionalNums" class="formular" style="]]..is_sel_options_visible..[[">]]
local num_list=fon_numbers.get_all_numbers()
local sip_list=fon_numbers.get_sip_num()
local num_str=[[]]
local any_num_used=false
g_numbers={}
g_count_checked=0
for i,num_data in ipairs(num_list.numbers) do
local onlycheck = true
if num_data.type ~= "sip" then
for i, elem in ipairs(sip_list.numbers) do
if tostring(num_data.msnnum) == tostring(elem.msnnum) then
onlycheck = false
break
end
end
end
if onlycheck then
local is_checked=[[]]
if (is_num_configured(elem,num_data.msnnum)) then
is_checked=[[checked]]
any_num_used=true
g_count_checked=g_count_checked+1
end
num_str=num_str..[[<input type="checkbox" id="uiNum_]]..i..[[" name="num_]]..i..[[" value="]]..box.tohtml(num_data.msnnum)..[[" ]]..is_checked..[[ onclick="return OnCheckNum(this);"><label for="uiNum_]]..i..[[">]]..box.tohtml(num_data.msnnum)..[[</label><span id="uiNumInfo_]]..i..[["></span><br>]]
table.insert(g_numbers,{id=[[uiNum_]]..i,num=num_data.msnnum,checked=is_checked==[[checked]]})
end
end
str=str..num_str
str=str..[[</div>]]
return str
end
function get_outgoing_numbers(num_to_select, isdn_num)
if string.find(num_to_select, "SIP") then
local sip_num_list = fon_numbers.get_sip_num()
local telcfg_id = string.gsub(num_to_select,"SIP","")
local num_elem = fon_numbers.find_elem_in_list_by_telcfgid(sip_num_list, telcfg_id)
if (num_elem) then
--num_to_select = num_elem.number
num_to_select = num_elem.msnnum
else
num_to_select = ""
end
end
if num_to_select == "POTS" then
num_to_select = box.query("telcfg:settings/MSN/POTS")
end
local str=[[<select size="1" id="uiOutNum" name="out_num" onchange="OnChangeTo(this.value)">]]
local list=fon_numbers.get_all_avail_numbers()
if list then
str=str..[[<option value="tochoose">]]..TXT([[{?txtPleaseSelect?}]])..[[</option>]]
for i,elem in ipairs(list) do
str=str..[[<option value="]]..elem.val..[["]]
if (num_to_select==elem.val) then
str=str..[[ selected ]]
end
str=str..[[>]]..box.tohtml(elem.key)..[[</option>]]
end
end
if isdn_num ~= nil and isdn_num ~= "" then
isdn_num = tostring(isdn_num)
str=str..[[<option value="]]..isdn_num..[[" ]]
if (num_to_select==isdn_num) then
str=str..[[ selected ]]
end
str=str..[[>]]..isdn_num..[[</option>]]
else
str=str..[[<option value="" ]]
if (num_to_select=="") then
str=str..[[ selected ]]
end
str=str..[[></option>]]
end
str=str..[[</select>]]
return str
end
function get_numbers(num_to_select,numbers,restriction)
local str=""
local list=fon_numbers.get_list_of_numbers(numbers,restriction)
if list then
str=str..[[<option value="tochoose">]]..TXT([[{?txtPleaseSelect?}]])..[[</option>]]
for i,elem in ipairs(list) do
str=str..[[<option value="]]..elem.val..[["]]
if (num_to_select==elem.val) then
str=str..[[ selected ]]
end
str=str..[[>]]..box.tohtml(elem.key)..[[</option>]]
end
end
return str
end
function get_avail_numbers(elem)
if elem.type=="tam" then
return get_avail_numbers_for_tam(elem)
elseif elem.type=="isdn" then
return get_avail_numbers_for_isdn_default(elem)
end
local str,is_sel_options_visible=get_query_for_all_or_one(elem)
str=str..get_optional_numbers(elem,is_sel_options_visible)
return str
end
function get_avail_numbers_for_tam(tam_elem)
local has_all=(tam_elem.idx==0)
local str=[[]]
local is_sel_options_visible=[[]]
if (has_all) then
str=str..[[<div class="formular" id="uiSel">]]
local check_nums=""
check_nums,is_sel_options_visible=get_query_for_all_or_one(tam_elem)
str=str..check_nums
end
str=str..[[<div id="uiOptionalNums" class="formular" style="]]..is_sel_options_visible..[[">]]
local tam_list, cnt=fon_devices.read_tam(true,true)
local num_list=fon_numbers.get_all_numbers()
local num_str=[[]]
local any_num_used=false
g_numbers={}
g_count_checked=0
for i,num_data in ipairs(num_list.numbers) do
if not is_num_already_used(tam_list,num_data.msnnum,tam_elem.idx) then
local is_checked=[[]]
if (is_num_configured(tam_elem,num_data.msnnum)) then
is_checked=[[checked]]
any_num_used=true
g_count_checked=g_count_checked+1
end
num_str=num_str..[[<input type="checkbox" id="uiNum_]]..i..[[" name="num_]]..i..[[" value="]]..box.tohtml(num_data.msnnum)..[[" ]]..is_checked..[[ onclick="return OnCheckNum(this);"><label for="uiNum_]]..i..[[">]]..box.tohtml(num_data.msnnum)..[[</label><br>]]
table.insert(g_numbers,{id=[[uiNum_]]..i,num=num_data.msnnum})
end
end
local show_warning=(num_str==[[]] or not any_num_used)
if (num_str==[[]]) then
num_str=[[<p>]]..TXT([[{?4255:530?}]])..[[</p>]]
end
str=str..num_str
local warntext = TXT([[{?4255:8472?}]])
if tam_elem.idx > 0 then
str=str..get_warning(show_warning, warntext)
end
str=str..[[</div>]]
if (has_all) then
str=str..[[</div>]]
end
return str
end
function is_mailer_configured()
if pushservice.account_configured() then
return true
end
local teststr = box.query("emailnotify:settings/From")
if (teststr == "") then
return false
end
teststr = box.query("emailnotify:settings/SMTPServer")
if (teststr == "") then
return false
end
return (teststr ~= "");
end
function extract_addr_name(str)
local name, addr = string.match(str, '^"(.*)"%s+<(.*)>$')
if not name or name == "" then
name = box.query("box:settings/hostname")
if name == "" then
name = [[FRITZ!Box]]
end
end
if addr and type(addr) == "string" then
return addr, name
end
return str, name
end
function save_email_config(saveset,data)
local do_save=box.post.email_send
if (not do_save) then
do_save=box.post.New_ActivateEMail or box.post.Old_ActivateEMail =="on"
end
if not do_save then
return
end
cmtable.add_var(saveset, "emailnotify:settings/enabled", "1")
local sendername = data.fboxname or ""
if sendername == "" then
cmtable.add_var(saveset, "emailnotify:settings/From", box.post.email or "")
else
cmtable.add_var(saveset, "emailnotify:settings/From",
string.format([["%s" <%s>]], sendername, box.post.email or "")
)
end
local addr=""
if box.post.emailto and box.post.emailto ~= "" then
addr=box.post.emailto:gsub(" ","")
cmtable.add_var(saveset, "emailnotify:settings/To", addr)
elseif box.query("emailnotify:settings/To") == "" then
addr=box.post.email:gsub(" ","") or ""
cmtable.add_var(saveset, "emailnotify:settings/To", addr)
end
if (box.post.pass~="****") then
cmtable.add_var(saveset, "emailnotify:settings/passwd", box.post.pass)
else
end
cmtable.add_var(saveset, "emailnotify:settings/accountname", box.post.username)
local srv_url = table.concat({box.post.server, box.post.port}, ":")
cmtable.add_var(saveset, "emailnotify:settings/SMTPServer", srv_url)
cmtable.save_checkbox(saveset, "emailnotify:settings/starttls", "use_ssl")
if box.post.test then
cmtable.add_var(saveset, "emailnotify:settings/TestMail", "1")
end
end
function get_email_config_validation(checkbox)
require"val"
local noemail = TXT([[{?4255:558?}]])
val.msg.email = {
[val.ret.notfound] = noemail,
[val.ret.empty] = noemail,
[val.ret.format] = TXT([[{?4255:7896?}]])
}
local noserver = TXT([[{?4255:628?}]])
val.msg.server = {
[val.ret.notfound] = noserver,
[val.ret.empty] = noserver,
[val.ret.format] = TXT([[{?4255:447?}]])
}
local str=[[]]
if checkbox then
str=str..[[
if __checked(]]..checkbox..[[) then
]]
end
str=str..[[
email_list(uiEmail/email, email)
server(uiServer/server, server)
]]
if checkbox then
str=str..[[
end
]]
end
return str
end
function email_config_newvalidation(checkbox)
require"newval"
if not checkbox or newval.checked(checkbox) then
pushservice.account_validation()
end
end
function get_email_config_js_include()
local str=[[
<script type="text/javascript" src="/js/onlinecheck.js"></script>
]]
return str
end
function get_email_config_js(data)
require("email_data")
local str=[[
var g_txtProvider = "]]..box.tojs(TXT([[{?4255:4643?}]]))..[[ ";
var g_txtTOnlineWarn = "]]..box.tojs(TXT([[{?4255:528?}]]))..[[";
var g_data =]]..js.table(data)..[[;
var gEmailData = ]].. email_data.get_edata_as_js_arraystr() .. [[;
var gDefaultPorts = ]] .. email_data.get_default_ports_js() .. [[;
var gProvider;
function showDetails(open) {
var div = jxl.get("uiDetails");
if (div) {
var img = jxl.get("uiDetailsLinkImg");
jxl.display(div, open);
if (img) {
img.src = open ? "/css/default/images/link_closed.gif" : "/css/default/images/link_open.gif";
}
}
}
function onDetailsClicked(evt) {
var div = jxl.get("uiDetails");
if (div) {
showDetails(div.style.display == "none");
}
return jxl.cancelEvent(evt);
}
function init_email()
{
var emailAddr = g_data.last_mail;
if (emailAddr=="")
{
emailAddr=g_data.email;
}
getProvider(emailAddr);
if (emailAddr=="") {
emailAddr = guessFromPppUser(g_data.pppuser);
if (emailAddr!="") {
jxl.setValue("uiEmail", emailAddr);
uiDoOnEmailChanged();
}
else
{
//jxl.hide("uiDetails");
showDetails(false);
}
}
else {
if (gProvider.name != "") {
//jxl.hide("uiDetails");
showDetails(false);
setNote(g_txtProvider+gProvider.name);
setProviderDetails(emailAddr);
}
}
uiDoOnActivateChecked();
var pppoe_online = (g_data.connection_state == "5");
if (!pppoe_online && g_data.hastime)
{
jxl.disable("uiTest");
onlineTest(100, function(state) { if (state>0) jxl.enable("uiTest"); });
}
toggleTOnlineWarning();
jxl.show("uiDetailsLink");
jxl.addEventHandler("uiDetailsLink", "click", onDetailsClicked);
jxl.addEventHandler("uiEmail", "change", uiDoOnEmailChanged);
jxl.addEventHandler("uiMainForm", "mousemove", uiDoOnEmailChanged);
jxl.addEventHandler("uiActivate", "click", uiDoOnActivateChecked);
jxl.addEventHandler("uiTls", "click", onClickSsl);
}
function onClickSsl() {
if (jxl.getChecked("uiTls")) {
if (gProvider.smtpssl) {
jxl.setValue("uiPort", gProvider.smtpport);
}
else {
jxl.setValue("uiPort", gDefaultPorts.smtpssl);
}
}
else {
if (gProvider.smtpssl) {
jxl.setValue("uiPort", gDefaultPorts.smtp);
}
else {
jxl.setValue("uiPort", gProvider.smtpport);
}
}
}
function setProviderDetails(user)
{
if (gProvider.smtpuser=="user")
user = user.substring(0, user.indexOf('@'));
else if(gProvider.smtpuser=="")
user = ""
jxl.setValue("uiUsername", user);
jxl.setValue("uiServer", gProvider.smtpsrv);
jxl.removeClass("uiServer", "error");
jxl.setChecked("uiTls", gProvider.smtpssl);
onClickSsl();
setNote(g_txtProvider+gProvider.name);
}
function uiDoOnEmailChanged(event)
{
var newMail = jxl.getValue("uiEmail");
if (newMail!="" && g_data.last_mail != newMail)
{
g_data.last_mail = newMail;
getProvider(newMail);
var user = newMail;
if (gProvider.name != "") {
setProviderDetails(user);
}
else {
setNote("");
jxl.setValue("uiUsername", "");
jxl.setValue("uiServer", "");
onClickSsl();
//jxl.show("uiDetails");
showDetails(true);
}
jxl.setValue("uiPass","");
toggleTOnlineWarning();
}
}
function toggleTOnlineWarning()
{
if (g_data.is_tonline && gProvider.name == "T-Online") {
var warn = jxl.get("uiTOnlineWarning");
if (warn == null)
{
var div = jxl.get("uiEmail").parentNode;
var par = div.parentNode;
warn = document.createElement("p");
warn.id = "uiTOnlineWarning";
jxl.setHtml(warn, g_txtTOnlineWarn);
par.insertBefore(warn, div.nextSibling);
}
jxl.show(warn);
} else {
jxl.hide("uiTOnlineWarning");
}
}
function findProviderByAddr(addr)
{
if (!addr)
return null;
for (var p in gEmailData)
{
if (addr.search(gEmailData[p].pattern)>=0)
return gEmailData[p];
}
return null;
}
function setNote(str)
{
var note = jxl.get("uiProvNote");
if (note == null)
{
var div = jxl.get("uiEmail").parentNode;
var note = document.createElement("span");
note.className = "provnote";
note.id = "uiProvNote";
div.appendChild(note);
}
jxl.setHtml(note, str);
}
function getProvider(addr)
{
var provider = findProviderByAddr(addr);
if (provider == null)
provider = gEmailData["default"];
gProvider = provider
return gProvider;
}
function guessFromPppUser(username)
{
/* AOL */
if (username.indexOf("@de.aol.com")>=0) {
var name = username.substr(0, username.indexOf("@de.aol.com"));
return name + "@aol.com";
}
/* T-Online */
if (username.indexOf("@t-online.de")>=0) {
var n1 = username.indexOf("#");
var n2 = username.indexOf("#", n1+1);
var n3 = username.indexOf("@t-online.de");
var nummer;
var suffix;
if (n1 != -1 && n2 !=-1 && n3 != -1) {
nummer = username.substring(n1+1, n2);
suffix = username.substring(n2+1, n3);
} else if (n3 != -1) {
var nummern = username.substring(0, n3);
if (n1 == -1) {
nummer = username.substring(12, 24);
suffix = username.substring(24, n3);
} else {
nummer = nummern.substring(12, n1);
suffix= nummern.substring(n1+1, n3);
}
}
return nummer + "-" + suffix + "@t-online.de";
}
/* 1&1 */
if (username.indexOf("@online.de")>=0) {
var name = username.substr(0, username.indexOf("@online.de"));
if (name.substring(0, 6) == "1und1/") {
return name.slice(6)+"@online.de";
}
}
return "";
}
function check()
{
var g_txtEmptyPass = "]]..box.tojs(TXT([[{?4255:735?}]]))..[[\n]]..box.tojs(TXT([[{?4255:58?}]]))..[[";
var g_txtEmptyUser = "]]..box.tojs(TXT([[{?4255:9?}]]))..[[\x0d\x0a]]..box.tojs(TXT([[{?4255:970?}]]))..[[";
var g_txtEmptyUserAndPass = "]]..box.tojs(TXT([[{?4255:986?}]]))..[[\n]]..box.tojs(TXT([[{?4255:536?}]]))..[[";
var g_txtPasswortEnterNew = "]]..box.tojs(TXT([[{?4255:272?}]]))..[[\n]]..box.tojs(TXT([[{?4255:277?}]]))..[[";
var g_txtAolKennwortMin = "]]..box.tojs(TXT([[{?4255:478?}]]))..[[";
var g_txtAolKennwortMax = "]]..box.tojs(TXT([[{?4255:922?}]]))..[[";
var g_txtAolKennwort = "]]..box.tojs(TXT([[{?4255:472?}]]))..[[";
getProvider(jxl.getValue("uiEmail"));
var bTonline = (]].. box.tojs(g_data.is_tonline) ..[[) && gProvider.name == "T-Online";
var bUserEmptyDone = false;
if (!jxl.get("uiActivate") || jxl.getChecked("uiActivate")) {
if (!jxl.get("uiEmailSend") || jxl.getChecked("uiEmailSend"))
{
if (!bTonline && jxl.getValue("uiPass")=="")
{
var quest = g_txtEmptyPass;
if (jxl.getValue("uiUsername")=="") {
quest = g_txtEmptyUserAndPass;
bUserEmptyDone = true;
}
if (!confirm(quest))
return false;
}
if (!bTonline && jxl.getValue("uiUsername")=="" && !bUserEmptyDone)
{
if (!confirm(g_txtEmptyUser))
return false;
}
if (jxl.getValue("uiUsername")!="]]..box.tojs(g_data.user)..[[" && jxl.getValue("uiPass")=="****")
{
alert(g_txtPasswortEnterNew );
return false;
}
}
}
if (gProvider.name == "AOL") {
var pass = jxl.getValue("uiPass");
if (pass!="****") {
if (pass.length < 6) { alert(g_txtAolKennwortMin); return false; }
if (pass.length > 16) { alert(g_txtAolKennwortMax); return false; }
//if (pass.match("[^0-9a-zA-Z]")!=null) { alert(g_txtAolKennwort); return false; }
}
}
return true;
}
]]
return str
end
function get_email_config_html(data, options)
options = options or {}
if not data then
data={}
data.email, data.fboxname = extract_addr_name(box.query("emailnotify:settings/From"))
data.pass = box.query("emailnotify:settings/passwd")
data.user = box.query("emailnotify:settings/accountname")
local ssl = box.query("emailnotify:settings/starttls") == "1"
data.use_ssl = ssl and "checked" or ""
data.server, data.port = email_data.split_server(box.query("emailnotify:settings/SMTPServer"))
data.port = data.port or email_data.get_default_port("smtp", ssl)
data.has_test_btn=false
end
local str=[[
<div id='uiViewEmailConfig'>
<div class="formular">
]]
if not options.noheading then
str = str .. [[
<h4>]]..box.tohtml(TXT([[{?4255:713?}]]))..[[</h4>
]]
end
str = str .. [[
<div class="widetext">
<div>
]]
str = str .. [[
<p>]]..box.tohtml(TXT([[{?4255:28?}]]))..[[</p>
]]
str = str .. [[
<label for="uiEmail">]]..box.tohtml(TXT([[{?4255:84?}]]))..[[</label>
<input type="text" name="email" id="uiEmail" value="]].. box.tohtml(data.email)..[[">
</div>
<div>
<label for="uiPass">]]..box.tohtml(TXT([[{?4255:380?}]]))..[[</label>
<input type="text" name="pass" id="uiPass" value="]].. box.tohtml(data.pass)..[[" autocomplete="off"/>
</div>
</div>
</div> <!-- Kontodaten -->
<div class="formular">
<a id="uiDetailsLink" class="textlink nocancel" href=" " style="display:none;">]]
.. box.tohtml(TXT([[{?4255:804?}]])) .. [[
<img id="uiDetailsLinkImg" src="/css/default/images/link_open.gif" height="12">
</a>
</div>
<div id="uiDetails" class="formular">
<div class="widetext">
<label for="uiUsername">]]..box.tohtml(TXT([[{?4255:8682?}]]))..[[</label>
<input type="text" name="username" id="uiUsername" value="]].. box.tohtml(data.user) ..[["/>
<br>
<label for="uiServer">]]..box.tohtml(TXT([[{?4255:173?}]]))..[[</label>
<input type="text" name="server" id="uiServer" value="]].. box.tohtml(data.server)..[[">
<label class="sameline" for="uiPort">]]..box.tohtml(TXT([[{?4255:707?}:]]))..[[</label>
<input type="text" size="5" id="uiPort" name="port" value="]]..box.tohtml(data.port)..[[">
<br>
<input type="checkbox" name="use_ssl" id="uiTls" ]].. data.use_ssl..[[ />
<label for="uiTls">]]..box.tohtml(TXT([[{?4255:143?}]]))..[[</label>
</div>
</div> <!-- uiDetails -->]]
if data.has_test_btn then
str=str..[[
<br>
<div id="uiTestArea" class="formular">
<div>]]..
box.tohtml(TXT([[{?4255:1858?}]]))..[[
</div>
<div class='ShowBtnRight'>
<button type='submit' name='test' onclick="g_testclicked=true;" id='uiTest'>]]..box.tohtml(TXT([[{?4255:738?}]]))..[[</button>
</div>
</div> <!-- test -->
]]
end
str=str..[[
<div class="clear_float"></div>
</div>
]]
return str
end
function get_save_path()
local g_txtFaxNoUsb = TXT([[{?4255:446?}]])
local g_txtFaxAuraAn = TXT([[{?4255:125?}]])
local path=TXT([[{?4255:184?}]])
local usb_disk_missing = box.query([[ctlusb:settings/storage-part/count]]) == "0"
if (usb_disk_missing) then
if (box.query("aura:settings/aura4storage") == "1") then
path=g_txtFaxAuraAn
else
path=g_txtFaxNoUsb
end
end
return path
end
function get_isdn_tabs(device, params)
local param = ""
if device and device.idx and device.idx ~= "" then
param = http.url_param("idx", device.idx)
end
for name, value in pairs(params) do
param = param .. "&" .. http.url_param(name, value)
end
local isdn_tabs = {
{ page = [[/fon_devices/edit_isdn_num.lua]], text = [[{?4255:666?}]], param = param},
{ page = [[/fon_devices/edit_isdn_ring_block.lua]], text = [[{?4255:365?}]], param = param},
{ page = [[/fon_devices/edit_isdn_option.lua]], text = [[{?4255:716?}]], param = param}
}
if device.type ~= "isdn" then
table.insert(isdn_tabs, 1,
{ page = [[/fon_devices/edit_isdn_name.lua]], text = [[{?4255:570?}]], param = param})
end
return isdn_tabs
end
function get_configured_numbers_as_table(elem)
local str=[[]]
local num_list=fon_numbers.get_all_numbers()
function is_default_num(elem,num)
if elem.outgoing==num then
return box.tohtml(TXT([[{?4255:367?}]]))
end
return [[]]
end
if (#num_list.numbers==0) then
return [[<tr><td colspan="2">]]..box.tohtml(TXT([[{?4255:423?}]]))..[[</td></tr>]]
end
g_numbers = {}
for i,num_data in ipairs(num_list.numbers) do
table.insert(g_numbers,{id=[[uiNum_]]..i,num=num_data.msnnum})
str=str..[[<tr><td>]]..box.tohtml(num_data.msnnum)..[[</td><td><span id="uiNum_]]..i..[[">]]..is_default_num(elem,num_data.msnnum)..[[</span></td></tr>]]
end
return str
end
function get_avail_numbers_for_isdn_default(elem)
if not elem then
return ""
end
local str=[[
<p>]]..
box.tohtml(TXT([[{?4255:871?}]]))..[[
</p>
<div class="formular">
<h4>]]..box.tohtml(TXT([[{?4255:281?}]]))..[[</h4>
<table class="zebra">
<colgroup>
<col width="100px">
<col width="auto">
</colgroup>
<tr>
<th>]]..box.tohtml(TXT([[{?4255:80?}]]))..[[</th>
<th>&nbsp;</th>
</tr>
]]
str=str..get_configured_numbers_as_table(elem)
str=str..[[
</table>
</div>
]]
return str
end
function get_ipfon_tabs(ipphone_id, params)
local param = http.url_param("ip_idx", tostring(ipphone_id))
for name, value in pairs(params) do
param = param .. "&" .. http.url_param(name, value)
end
return {
{ page = [[/fon_devices/edit_ipfon_num.lua]], text = [[{?4255:276?}]], param = param},
{ page = [[/fon_devices/edit_ipfon_option.lua]], text = [[{?4255:965?}]], param = param}
}
end
function get_options(elem)
local has_clir = true
local has_clip = true
local has_knock = true
local has_busy = true
local has_busy_delayed = false
local has_colr = true
local has_mwi = true
local id=elem.idx
if (elem.src == "nthotdiallist") then
has_knock = false
has_clir = false
has_clip = false
has_busy_delayed = true
id=3
end
local clir = box.query("telcfg:settings/MSN/Port"..id.."/CLIR")== "1"
local clip0 = (tonumber(box.query("telcfg:settings/MSN/Port"..id.."/CLIP"))or 0)>= 1
local clip1 = box.query("telcfg:settings/MSN/Port"..id.."/CLIP")== "1"
local clip2 = box.query("telcfg:settings/MSN/Port"..id.."/CLIP")== "2" or not clip0
local knock = box.query("telcfg:settings/MSN/Port"..id.."/CallWaitingProt")=="0"
local busy = box.query("telcfg:settings/MSN/Port"..id.."/BusyOnBusy")=="1"
local busy_delayed = box.query("telcfg:settings/MSN/Port"..id.."/CallWaitingProt")=="0"
local colr = box.query("telcfg:settings/MSN/Port"..id.."/COLR")=="1"
local singluar = box.query("telcfg:settings/MSN/Port"..id.."/MWI_Once")== "0"
local ever = box.query("telcfg:settings/MSN/Port"..id.."/MWI_Once")== "1"
local voice = box.query("telcfg:settings/MSN/Port"..id.."/MWI_Voice")== "1"
local mail = box.query("telcfg:settings/MSN/Port"..id.."/MWI_Mail")== "1"
local fax = box.query("telcfg:settings/MSN/Port"..id.."/MWI_Fax")== "1"
local mwi = fax or mail or voice
local str=[[
<div>
<p>]]..box.tohtml(TXT([[{?4255:927?}]]))..[[</p>]]
if has_clir then
str=str..[[<div class="formular">
<input type="checkbox" id="uiClir" name="clir" ]]..is_checked(clir)..[[ onclick="OnClickClir(this.checked)">
<label for="uiClir">]]..box.tohtml(TXT([[{?4255:8093?}]]))..[[</label>
<div class="form_checkbox_explain">]]..box.tohtml(TXT([[{?4255:540?}]]))..[[</div>
</div>]]
end
if has_clip then
str=str..[[<div class="formular">
<input type="checkbox" id="uiClip0" name ="clip0" ]]..is_checked(clip0)..[[ onclick="OnClickClip(this.checked)">
<label for="uiClip0">]]..box.tohtml(TXT([[{?4255:972?}]]))..[[</label>
<div class="form_checkbox_explain">]]..box.tohtml(TXT([[{?4255:1?}]]))..[[</div>
<div id="uiClipMode" class="formular">
<p><input type="radio" name="clip" id="uiClip1" value="1" ]]..is_checked(clip1)..[[ ><label for="uiClip1">]]..box.tohtml(TXT([[{?4255:599?}]]))..[[</label></p>
<p><input type="radio" name="clip" id="uiClip2" value="2" ]]..is_checked(clip2)..[[ ><label for="uiClip2">]]..box.tohtml(TXT([[{?4255:877?}]]))..[[</label></p>
</div>
</div>]]
end
if has_knock then
str=str..[[<div class="formular" id="ShowKnock0">
<input type="checkbox" id="uiKnock" name="knock" ]]..is_checked(knock)..[[>
<label for="uiKnock">]]..box.tohtml(TXT([[{?4255:584?}]]))..[[</label>
<div class="form_checkbox_explain">]]..box.tohtml(TXT([[{?4255:848?}]]))..[[</div>
</div>]]
end
if has_busy then
str=str..[[<div class="formular">
<input type="checkbox" id="uiBusy" name="busy" onclick="OnClickBusy(this.checked)" ]]..is_checked(busy)..[[>
<label for="uiBusy">]]..box.tohtml(TXT([[{?4255:149?}]]))..[[</label>
<div class="form_checkbox_explain">]]..box.tohtml(TXT([[{?4255:787?}]]))..[[</div>]]
if has_busy_delayed then
str=str..[[<div class="formular" id="uiBusyOption">
<input type="checkbox" id="uiBusyDelayed" name="busy_delayed" ]]..is_checked(busy_delayed)..[[>
<label for="uiBusyDelayed">]]..box.tohtml(TXT([[{?4255:2536?}]]))..[[</label>
</div>]]
end
str=str..[[</div>]]
end
if has_colr then
str=str..[[
<div class="formular">
<input type="checkbox" id="uiColr" name="colr" ]]..is_checked(colr)..[[>
<label for="uiColr">]]..box.tohtml(TXT([[{?4255:907?}]]))..[[</label>
<div class="form_checkbox_explain">]]..box.tohtml(TXT([[{?4255:900?}]]))..[[</div>
</div>]]
end
if has_mwi then
str=str..[[<div id="uiShowMWI" class="formular">
<input type="checkbox" id="uiMwi" name="mwi" onclick="OnClickMwi(this.checked)" ]]..is_checked(mwi)..[[>
<label for="uiMwi">]]..box.tohtml(TXT([[{?4255:2118?}]]))..[[</label>
<div class="form_checkbox_explain">]]..box.tohtml(TXT([[{?4255:85?}]]))..[[</div>
<div class="formular" id="uiMwiOptions">
<p>]]..box.tohtml(TXT([[{?4255:286?}]]))..[[</p>
<div class="formular"><input type="radio" name="mwionce" value="0" id="uiSingular" ]]..is_checked(singluar)..[[ ><label for="uiSingular">]]..box.tohtml(TXT([[{?4255:7701?}]]))..[[</label></div>
<div class="formular"><input type="radio" name="mwionce" value="1" id="uiEver" ]]..is_checked(ever)..[[ ><label for="uiEver">]]..box.tohtml(TXT([[{?4255:906?}]]))..[[</label></div>
<div>]]..box.tohtml(TXT([[{?4255:3066?}]]))..[[</div>
<div class="formular"><input type="checkbox" id="uiMwiVoice" name="mwivoice" ]]..is_checked(voice)..[[ ><label for="uiMwiVoice">]]..box.tohtml(TXT([[{?4255:974?}]]))..[[</label></div>
<div class="formular"><input type="checkbox" id="uiMwiMail" name="mwimail" ]]..is_checked(mail) ..[[ ><label for="uiMwiMail">]]..box.tohtml(TXT([[{?4255:2841?}]]))..[[</label></div>
<div class="formular"><input type="checkbox" id="uiMwiFax" name="mwifax" ]]..is_checked(fax) ..[[ ><label for="uiMwiFax">]]..box.tohtml(TXT([[{?4255:846?}]]))..[[</label></div>
</div>
</div>]]
end
str=str..[[</div>]]
return str
end
function get_other_options(elem)
if (elem.type=="ipphone") then
return get_register_data_ipphone(elem)
end
return get_options(elem)
end
function get_register_data_ipphone(elem)
if (not elem) then
return ""
end
local checked=""
if (elem.reg_from_outside) then
checked="checked"
end
local username=tostring(elem.intern)
local str=
[[
<div><label for="uiRegistrar">]]..box.tohtml(TXT([[{?4255:506?}]]))..[[</label><span id="uiRegistrar">fritz.box</span></div>
<div><label for="uiUsername">]]..box.tohtml(TXT([[{?4255:587?}]]))..[[</label><span id="uiUsername">]]..box.tohtml(username)..[[</span></div>]]
if g_data.cur_ipphone.clientid == "" then
str = str..[[
<div><label for="uiPassword">]]..box.tohtml(TXT([[{?4255:586?}]]))..[[</label><input type="text" id="uiPassword" name="password" value="****" size="15" maxlength="32" /></div>]]
end
str = str..[[
<div><input type="checkbox" id="uiFromInet" name="from_inet" ]]..checked..[[><label for="uiFromInet">]]..box.tohtml(TXT([[{?4255:449?}]]))..[[</div>
<p class="form_checkbox_explain">]]..box.tohtml(TXT([[{?4255:678?}]]))..[[</p>
]]
return str
end
function get_ipphone_name(elem)
if (not elem) then
return ""
end
local str=
[[
<div><label for="uiName">]]..box.tohtml(TXT([[{?4255:308?}]]))..[[</label><input type="text" id="uiName" name="name" maxlength="30" value="]]..box.tohtml(elem.name)..[["/></div>
]]
return str
end
function get_other_options_save_data(elem)
local ctlmgr_save={}
if box.query("telcfg:settings/UsePSTN") == "1" then
cmtable.save_checkbox(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/COLR", "colr")
end
cmtable.save_checkbox(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/BusyOnBusy", "busy")
if (elem.src ~= "nthotdiallist") then
cmtable.save_checkbox(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/CLIR", "clir")
if box.post.clip0 then
local clip=box.post.clip=="2" and "2" or "1"
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/CLIP", clip)
else
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/CLIP", "0")
end
end
local mwionce = box.post.mwionce=="1" and "1" or "0"
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/MWI_Once", mwionce)
if elem.type ~= "tam" then
if box.post.mwi then
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/MWI_Voice", box.post.mwivoice and "1" or "0")
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/MWI_Mail", box.post.mwimail and "1" or "0")
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/MWI_Fax", box.post.mwifax and "1" or "0")
else
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/MWI_Voice", "0")
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/MWI_Mail", "0")
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/MWI_Fax", "0")
end
end
if elem.src~="nthotdiallist" then
local fax, callWaitingProt, groupCall = "0","0","0"
if elem.type == "fax" then
fax = "1"
callWaitingProt = "1"
end
if elem.type == "fon" then
groupCall = "1"
if not box.post.knock then
callWaitingProt = "1"
end
end
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/Fax", fax )
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/GroupCall", groupCall)
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/CallWaitingProt", callWaitingProt)
else
if box.post.busy then
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/Port"..elem.port_id.."/CallWaitingProt", box.post.busy_delayed and "0" or "1")
end
end
return ctlmgr_save
end
local g_pots_configuered=false
function is_pots_configured_fax()
return g_pots_configuered
end
function get_fax_tabs(params)
local param = ""
for name, value in pairs(params) do
param = param .. "&" .. http.url_param(name, value)
end
return {
{ page = [[/fon_devices/edit_fax_num.lua]], text = [[{?4255:673?}]], param = param},
{ page = [[/fon_devices/edit_fax_option.lua]], text = [[{?4255:610?}]], param = param}
}
end
function get_avail_numbers_fax(fax_elem)
local num_list=fon_numbers.get_all_numbers()
local num_str=[[]]
local any_num_used=false
g_numbers={}
g_count_checked=0
for i,num_data in ipairs(num_list.numbers) do
local is_checked=[[]]
local num=num_data.msnnum
if (num_data.type=="pots") then
num="POTS"
end
if (is_num_configured(fax_elem,num)) then
if (num_data.type=="pots") then
g_pots_configuered=true
end
is_checked=[[checked]]
any_num_used=true
g_count_checked=g_count_checked+1
end
num_str=num_str..[[<input type="checkbox" id="uiNum_]]..i..[[" name="num_]]..i..[[" value="]]..box.tohtml(num)..[[" ]]..is_checked..[[ onclick="return OnCheckNum(this);"><label for="uiNum_]]..i..[[">]]..box.tohtml(num_data.msnnum)..[[</label><br>]]
table.insert(g_numbers,{id=[[uiNum_]]..i,num=num_data.msnnum,type=num_data.type})
end
if (num_str==[[]]) then
num_str=TXT([[{?4255:410?}]])
end
return num_str
end
function get_call_delay(tam_elem,id)
function get_selected(sec)
local str=[[value="]]..tostring(sec)..[[" ]]
if (tam_elem.ring_count==sec) then
str=str..[[selected]]
end
str=str..[[>]]
return str
end
local str=[[<label for="]]..id..[[">]]..TXT([[{?4255:388?}]])..[[</label><select id="]]..id..[[" name="call_delay">
<option value="tochoose">]]..TXT([[{?4255:201?}]])..[[</option>
<option ]]..get_selected(0 )..TXT([[{?4255:105?}]])..[[</option>
<option ]]..get_selected(5 )..TXT([[{?4255:323?}]])..[[</option>
<option ]]..get_selected(10)..TXT([[{?4255:278?}]])..[[</option>
<option ]]..get_selected(15)..TXT([[{?4255:384?}]])..[[</option>
<option ]]..get_selected(20)..TXT([[{?4255:211?}]])..[[</option>
<option ]]..get_selected(25)..TXT([[{?4255:583?}]])..[[</option>
<option ]]..get_selected(30)..TXT([[{?4255:806?}]])..[[</option>
<option ]]..get_selected(35)..TXT([[{?4255:625?}]])..[[</option>
<option ]]..get_selected(40)..TXT([[{?4255:759?}]])..[[</option>
<option ]]..get_selected(45)..TXT([[{?4255:208?}]])..[[</option>
<option ]]..get_selected(50)..TXT([[{?4255:548?}]])..[[</option>
<option ]]..get_selected(55)..TXT([[{?4255:641?}]])..[[</option>
<option ]]..get_selected(60)..TXT([[{?4255:203?}]])..[[</option>
</select>]]
return str
end
function get_call_reclen(tam_elem)
function get_selected(sec)
local str=[[value="]]..tostring(sec)..[[" ]]
if (tam_elem.record_length==sec) then
str=str..[[selected]]
end
str=str..[[>]]
return str
end
local str=[[<label for="uiRecLen">]]..TXT([[{?4255:748?}]])..[[</label><select id="uiRecLen" name="rec_len">
<option value="tochoose">]]..TXT([[{?4255:617?}]])..[[</option>
<option ]]..get_selected(0 )..TXT([[{?4255:166?}]])..[[</option>
<option ]]..get_selected(60 )..TXT([[{?4255:921?}]])..[[</option>
<option ]]..get_selected(120)..TXT([[{?4255:982?}]])..[[</option>
<option ]]..get_selected(180)..TXT([[{?4255:657?}]])..[[</option>
</select>]]
return str
end
local function get_upload_btn(tam_elem, html_id, html_name)
return general.get_icon_button("/css/default/images/bearbeiten.gif", html_id, html_name, tam_elem.id, TXT([[{?txtIconBtnEdit?}]]))..
[[<span>]]..TXT([[ {?4255:229?}]])..[[</span>]]
end
function get_operation_mode(tam_elem)
local only_msg=(tam_elem.mode=="0")
local begin_msg=TXT([[{?4255:0?}]])
if (tam_elem.user_begin_msg=="1") then
begin_msg=TXT([[{?4255:9091?}]])
end
local end_msg=TXT([[{?4255:12?}]])
if (tam_elem.user_end_msg=="1") then
end_msg=TXT([[{?4255:481?}]])
end
local only_msg_txt=TXT([[{?4255:501?}]])
if (tam_elem.user_hint_msg=="1") then
only_msg_txt=TXT([[{?4255:347?}]])
end
local str=[[]]
str=str..[[<div><input type="radio" name="operation_mode" value="rec" id="uiOperationModeRecord" onchange="return OnOperationMode(value);" ]]..get_checked(not only_msg)..[[><label for="uiOperationModeRecord">]]..TXT([[{?4255:868?}]])..[[</label>]]..
[[<div id="uiRecording" class="formular grid ]]..get_visible(not only_msg)..[[">]]..
[[<div id="begin">
<label for="uiRecFileBegin">]]..TXT([[{?4255:875?}]])..[[</label><span class="ShowPathSmaller">]]..box.tohtml(begin_msg)..[[</span>]]..
get_upload_btn(tam_elem, "uiEditBegin", "edit_begin") ..
[[</div>]]..
[[<div id="end">
<label for="uiRecFileEnd">]]..TXT([[{?4255:256?}]])..[[</label><span class="ShowPathSmaller">]]..box.tohtml(end_msg)..[[</span>]]..
get_upload_btn(tam_elem, "uiEditEnd", "edit_end") ..
[[</div>]]..
get_call_delay(tam_elem,[[uiCallDelay1]])..[[<br>]]..
get_call_reclen(tam_elem)..[[<br>]]..
[[</div></div>
<div>
<input type="radio" name="operation_mode" value="only_msg" id="uiOperationModeOnlyMsg" onchange="return OnOperationMode(value);" ]]..get_checked(only_msg)..[[><label for="uiOperationModeOnlyMsg">]]..TXT([[{?4255:686?}]])..[[</label>
<div id="uiOnlyMsg" class="formular grid ]]..get_visible(only_msg)..[[">]]..
[[<div id="hint">
<label for="uiRecFileHint">]]..TXT([[{?4255:931?}]])..[[</label><span class="ShowPathSmaller">]]..box.tohtml(only_msg_txt)..[[</span>]]..
get_upload_btn(tam_elem, "uiEditEnd", "edit_hint") ..
[[</div>]]..
get_call_delay(tam_elem,[[uiCallDelay2]])..
[[</div>
</div>]]
return str
end
function create_tam_name(tam_elem)
local str=[[<div class="formular small_indent narrow">
<label for="uiTamName">]]..TXT([[{?4255:8494?}]])..[[</label><input type="text" id="uiTamName" name="tam_name" value="]]..box.tohtml(tam_elem.name)..[[">
</div>]]
return str
end
function get_warning(is_visible, warntext)
local display=[[display:none]]
if is_visible then
display=[[]]
end
return [[<div id="uiAllNumsConfigured" style="]]..display..[[">
<p class="hint_msg" >]]..TXT([[{?4255:290?}]])..[[</p>
<p>]]..
warntext..[[
</p></div>]]
end
function create_tam_intern_base(tam_elem)
local str=[[<hr><div id="uiTamBase">
<h4>]]..TXT([[{?4255:49?}]])..[[</h4>
<div class="formular">
<p>]]..TXT([[{?4255:437?}]])..[[</p>]]..
get_avail_numbers(tam_elem)..
[[</div>
<hr><h4>]]..TXT([[{?4255:20?}]])..[[</h4>
<div class="formular">]]..
get_operation_mode(tam_elem)..
[[</div></div>]]
return str
end
function create_tam_Email(tam_elem)
local is_checked =tam_elem.pushmail_active=="1" or tam_elem.pushmail_active=="2"
local is_checked_del_call=tam_elem.pushmail_active=="2"
local is_disabled=[[]]
if (tam_elem.mode=="0") then
is_disabled=[[disabled]]
end
local str=[[<br><h4>]]..TXT([[{?4255:42?}]])..[[</h4>
<div class="formular wide" id="uiEmailOptions">
<input type="checkbox" id="uiEmailSend" name="email_send" onclick="OnEmailSend(this.checked);"]]..get_checked(is_checked)..[[ ]]..is_disabled..[[><label for="uiEmailSend">]]..TXT([[{?4255:640?}]])..[[</label>
<div class="formular" id="uiEmailSendOptions">
<div><input type="checkbox" id="uiEmailSendDelCall" name="email_send_del_call" ]]..get_checked(is_checked_del_call)..[[ ]]..is_disabled..[[><label for="uiEmailSendDelCall">]]..TXT([[{?4255:120?}]])..[[</label></div>
<div><label for="uiEmailAddr">]]..TXT([[{?4255:1158?}]])..[[</label><input type="text" id="uiEmailAddr" name="email_addr" value="]]..box.tohtml(tam_elem.mailaddress)..[["></div>
</div>]]
if (not is_mailer_configured()) then
str=str..get_email_config_html()
end
str=str..[[</div>]]
return str
end
function aura_4_storage()
return box.query("aura:settings/enabled")=="1" and box.query("aura:settings/aura4storage")=="1"
end
function create_tam_usb(tam_elem)
if not is_usb_host() then
return ""
end
local is_checked_usb =tam_elem.use_stick=="1"
local is_usbstick_present=tam_elem.use_stick=="1" or tam_elem.use_stick=="2"
local is_disabled=[[]]
local disable_usb=[[]]
if (tam_elem.mode=="0" or not is_usbstick_present) then
is_disabled=[[disabled]]
disable_usb=[[disableNode]]
end
local str=[[]]
local txt1=TXT([[{?4255:993?}]])
local txt2=TXT([[{?4255:816?}]])
if (aura_4_storage()) then
str=str.. [[<div class="formular disableNode" >
<input type="checkbox" disabled><label for="">]]..txt1..[[</label><br>
<div class="formular widetext">
<span class="as_label">]]..txt2..[[</span><span class="ShowPath">]]..TXT([[{?g_txt_FritzVoiceBox?}]])..[[</span>
</div>
</div>
<div class="formular"><div class="formular"><p>]]..general.sprintf( TXT([[{?4255:393?}]]),
"<a href=\'"..href.get('/usb/usb_remote_settings.lua').."\'>", "</a>"
)..
[[</p></div></div>]]
else
if not tam_usb_usable() then
str=str..[[<p>]]..TXT([[{?4255:490?}]])..[[</p>]]
else
if not has_internal_mem() then
str=str.. [[<div class="formular disableNode" >
<input type="checkbox" ]]..get_checked(is_checked_usb)..[[ disabled><label for="">]]..txt1..[[</label><br>
<div class="formular widetext">
<span class="as_label">]]..txt2..[[</span><span class="ShowPath">]]..TXT([[{?g_txt_FritzVoiceBox?}]])..[[</span>
</div>
</div>]]
else
str=str.. [[<div class="formular ]].. disable_usb..[[" id="uiUsbOptions">
<input type="checkbox" id="uiUsbUseage" name="usb_usage" onclick="return onUseUsb(this.checked);" ]]..get_checked(is_checked_usb).." "..is_disabled..[[><label for="uiUsbUseage">]]..txt1..[[</label><br>
<div class="formular widetext">
<span class="as_label">]]..txt2..[[</span><span class="ShowPath">]]..TXT([[{?g_txt_FritzVoiceBox?}]])..[[</span>
</div>
</div>]]
end
end
end
return str
end
function create_tam_remote(tam_elem)
local is_checked_remote = (tam_elem.pin ~= "0000")
local pin=""
if (tam_elem.pin~="0000" and tam_elem.pin~="") then
pin=tam_elem.pin
end
local str=[[
<hr>
<h4>]]..TXT([[{?4255:6876?}]])..[[</h4>
<div class="formular close" id="uiRemoteOptions">
<p>]]..TXT([[{?4255:259?}]])..[[</p>
<input type="checkbox" id="uiUseRemote" name="use_remote" ]]..get_checked(is_checked_remote)..[[ onclick="OnRemote(this.checked)"><label for="uiUseRemote">]]..TXT([[{?4255:757?}]])..[[</label>
<div class="formular" id="uiPinBlock">
<label for="uiPin">]]..TXT([[{?4255:709?}]])..[[</label><input type="text" size="12" maxlength="4" id="uiPin" name="pin" onfocus="jxl.select(id);" value="]]..box.tohtml(pin)..[[" ]]..get_disabled(not is_checked_remote)..[[/>
</div>
</div>]]
return str
end
function create_tam_timectrl(tam_elem)
if not(config.TIMERCONTROL) then
return ""
end
local is_checked_timectrl=timer.is_tam_timeplan_enabled(g_timer_id)
local str=[[
<hr>
<h4>]]..TXT([[{?4255:113?}]])..[[</h4>
<div class="formular" id="uiTimeCtrlOptions">
<p>]]..TXT([[{?4255:104?}]])..[[</p>
<input type="checkbox" id="uiUseTimeCtrl" name="use_timectrl" ]]..get_checked(is_checked_timectrl)..[[ onclick="return OnActiveTimeCtrl(this.checked);"><label for="uiUseTimeCtrl">]]..TXT([[{?4255:577?}]])..[[</label><br>
<div class="formular" id="uiTimerArea" style="]]..get_visible(is_checked_timectrl)..[[">]]..
timer.get_html(g_timer_id, {
active = TXT([[{?4255:988?}]]),
inactive = TXT([[{?4255:685?}]])
}) .. [[
</div>
</div>]]
return str
end
function create_tam_delete(tam_elem)
local str=[[
<hr>
<h4>]]..TXT([[{?4255:186?}]])..[[</h4>
<div class="formular">
<p>]]..TXT([[{?4255:769?}]])..[[</p>
<div class="ShowBtnRight"><button type="submit" name="delete" onclick="return onDelete();" value="]]..tam_elem.idx..[[">]]..box.tohtml(TXT([[{?4255:371?}]]))..[[</button></div>
</div>
]]
return str
end
function create_more_link(tam_elem)
return [[<hr><div><a id="uiMoreOptionsLink" href="javascript:OnMoreOptions();" class="textlink nocancel">]]..box.tohtml(TXT([[{?4255:117?}]]))..[[<img id="uiMoreOptionsLinkImg" src="/css/default/images/link_open.gif" height="12"></a></div>]]
end
function create_tam_intern_more_options(tam_elem)
end
function any_suboption_active(tam_elem)
local remote=(tam_elem.pin ~= "0000")
if (timer.is_tam_timeplan_enabled(g_timer_id) or
(tam_elem.pushmail_active=="1" or tam_elem.pushmail_active=="2") or
(tam_elem.use_stick=="1") or
remote) then
return true
end
return false
end
function create_tam_html(tam_elem)
local str=create_tam_name(tam_elem)
str=str..create_tam_intern_base(tam_elem)
str=str..create_more_link(tam_elem)
local display=[[display:none;]]
if (any_suboption_active(tam_elem)) then
display=[[]]
end
str=str..[[<div id="uiModeData" style="]]..display..[[">]]
str=str..create_tam_Email(tam_elem)
str=str..create_tam_usb(tam_elem)
str=str..create_tam_remote(tam_elem)
str=str..create_tam_timectrl(tam_elem)
str=str..create_tam_delete(tam_elem)
str=str..[[</div>]]
return str
end
function write_tam_js(tamlist,cur_elem)
local tam_elem=cur_elem
local str=[[]]
local react_on="sel_nums"
if (react_on_all(tam_elem)) then
react_on="all_nums"
end
local cur_mode="only_msg"
if (tam_elem.mode=="1") then
cur_mode="rec"
end
str=str..[[
var g_show_more=]]..tostring(any_suboption_active(tam_elem))..[[;
var g_cur_mode="]]..cur_mode..[[";
var g_is_timeplan_enabled=]]..tostring(timer.is_tam_timeplan_enabled(g_timer_id))..[[;
var g_remote=]]..tostring(tam_elem.pin ~= "0000")..[[;
var g_email=]]..tostring(tam_elem.pushmail_active=="1" or tam_elem.pushmail_active=="2")..[[;
var g_has_all=]]..tostring(tam_elem.idx==0)..[[;
var g_reactOn="]]..react_on..[[";
var g_is_stickpresent=]]..tostring(tam_elem.use_stick=="1" or tam_elem.use_stick=="2")..[[;
var g_useStick=]]..tostring(tam_elem.use_stick=="1")..[[;
function OnMoreOptions()
{
g_show_more=!g_show_more;
jxl.display('uiModeData',g_show_more);
var img=jxl.get('uiMoreOptionsLinkImg')
if (img)
{
img.src=g_show_more ? '/css/default/images/link_closed.gif' : '/css/default/images/link_open.gif';
}
}
function OnOperationMode(value)
{
g_cur_mode=value;
jxl.removeClass('uiRecording','hide');
jxl.removeClass('uiOnlyMsg','hide');
jxl.disableNode('uiRecording', value!='rec');
jxl.display('uiRecording',value=='rec');
jxl.disableNode('uiOnlyMsg', value!='only_msg');
jxl.display('uiOnlyMsg',value=='only_msg');
jxl.disableNode('uiEmailOptions',value=='only_msg');
jxl.disableNode("uiUsbOptions",value=='only_msg' || !g_is_stickpresent);
jxl.disableNode("uiRemoteOptions",value=='only_msg');
OnEmailSend(g_email);
return true;
}
function OnActiveTimeCtrl(checked)
{
jxl.disableNode("uiTimerArea", !checked);
jxl.display("uiTimerArea",checked);
}
function OnRemote(checked)
{
jxl.disableNode("uiPinBlock", !checked);
}
function OnEmailSend(checked)
{
g_email=checked;
jxl.disableNode("uiEmailSendOptions",!checked || g_cur_mode=="only_msg");
if (jxl.get("uiViewEmailConfig"))
{
jxl.display("uiViewEmailConfig",checked);
jxl.disableNode("uiViewEmailConfig",!checked);
}
}
function onUseUsb(checked)
{
if (!checked && g_useStick)
{
if (!confirm("]]..box.tojs(TXT([[{?4255:476?}]]))..[["))
{
return false;
}
}
return true;
}
]]
box.out(str)
write_incoming_nr_js(tamlist,cur_elem)
end
function get_sel_handler()
return
[[
function OnSelNum(reactOn)
{
var showNums=(reactOn=="sel_nums")
jxl.disableNode("uiOptionalNums",!showNums);
jxl.display("uiOptionalNums",showNums);
}
]]
end
function write_sel_handler()
box.out(get_sel_handler())
end
function write_incoming_nr_js(tamlist,cur_elem)
local str=[[]]
str=str..[[
var g_max_selectable_nums=]]..tostring(get_max_of_selectable_nums(tamlist,cur_elem))..[[;
]]..get_sel_handler()..[[
function isAnyNumConfigured()
{ var all_ids=]]..js.table(g_numbers)..[[;
for (var i=0;i<all_ids.length;i++)
{
var obj=jxl.get(all_ids[i].id);
if (!obj){
continue;
}
if (obj.checked){
return true;
}
}
return false;
}
function getNumOfSelected()
{ var all_ids=]]..js.table(g_numbers)..[[;
var count=0;
for (var i=0;i<all_ids.length;i++)
{
var obj=jxl.get(all_ids[i].id);
if (!obj){
continue;
}
if (obj.checked){
count++;
}
}
return count;
}
function OnCheckNum(obj)
{
var msg=jxl.sprintf("]]..box.tojs(TXT([[{?4255:441?}]]))..[[\x0d\x0a\x0d\x0a]]..box.tojs(TXT([[{?4255:964?}]]))..[[",g_max_selectable_nums);
if (g_max_selectable_nums<getNumOfSelected())
{
alert(msg);
return false;
}
jxl.display("uiAllNumsConfigured",!isAnyNumConfigured());
return true;
}
]]
box.out(str)
end
function write_js_init()
local str=[[]]
str=str..[[
if (g_cur_mode=="only_msg")
{
OnOperationMode("only_msg");
}
else
{
OnOperationMode("rec");
}
OnActiveTimeCtrl(g_is_timeplan_enabled);
OnRemote(g_remote);
OnEmailSend(g_email && g_cur_mode=="rec");
if (g_has_all)
{
OnSelNum(g_reactOn);
}
]]
box.out(str)
end
function find_msn_in_tam_list(tam_elem,selected_num)
for i,num in ipairs(tam_elem.all_tam_nums) do
if (num==selected_num) then
return true,i-1
end
end
return false,-1
end
function add_msn_in_tam_list(tam_elem,selected_num)
for i,num in ipairs(tam_elem.all_tam_nums) do
if (num=="") then
tam_elem.all_tam_nums[i]=selected_num
return true,i-1
end
end
return false,-1
end
function get_bitmap_without_current(tamlist,cur_elem)
local bitmap=0
for i,tam_elem in ipairs(tamlist) do
if (tam_elem.idx~=cur_elem.idx) then
bitmap=bit.maskor(bitmap,tam_elem.msn_bitmap)
end
end
return bitmap
end
function get_bitmap(tamlist)
local bitmap=0
for i,tam_elem in ipairs(tamlist) do
bitmap=bit.maskor(bitmap,tam_elem.msn_bitmap)
end
return bitmap
end
function delete_unused_nums(tamlist,cur_elem, bitmap_cur)
local bitmap_old=get_bitmap(tamlist)
local bitmap_new=get_bitmap_without_current(tamlist,cur_elem)
bitmap_new=bit.maskor(bitmap_new,bitmap_cur)
local msn_table=cur_elem.all_tam_nums
for i,msn in ipairs(msn_table) do
if (not bit.isset(bitmap_new,i-1)) then
msn_table[i] = ""
end
end
end
function save_active_nums(saveset,tamlist,cur_elem,cnt_nums)
local tam_elem=cur_elem
local msn_bitmap=0
local msn_count=0
delete_unused_nums(tamlist,cur_elem,msn_bitmap)
for i=1,cnt_nums,1 do
if (box.post["num_"..tostring(i)]) then
local found,bit_pos=find_msn_in_tam_list(tam_elem, box.post["num_"..tostring(i)])
if (not found) then
found,bit_pos=add_msn_in_tam_list(tam_elem, box.post["num_"..tostring(i)])
end
msn_bitmap=bit.set(msn_bitmap,bit_pos)
end
end
cur_elem.msn_bitmap=msn_bitmap
for i,num in ipairs(cur_elem.all_tam_nums) do
cmtable.add_var(saveset,"tam:settings/MSN"..tostring(i-1),num)
end
local idx=tostring(cur_elem.idx)
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/MSNBitmap",tostring(msn_bitmap))
end
function get_max_of_selectable_nums(tamlist,cur_elem)
local bitmap=get_bitmap_without_current(tamlist,cur_elem)
local bittable=bit.issetlist(bitmap)
return 10-#bittable
end
function get_fon_tabs(id, params)
local param = http.url_param("idx", tostring(id))
for name, value in pairs(params) do
param = param .. "&" .. http.url_param(name, value)
end
local data = fon_devices.get_fon123_phonedata(id)
local first_head = ""
if data.type == "fax" then
first_head = TXT([[{?4255:9241?}]])
elseif data.type == "fon" then
first_head = TXT([[{?4255:694?}]])
elseif data.type == "tam" then
first_head = TXT([[{?4255:772?}]])
end
return {
{ page = [[/fon_devices/edit_fon_num.lua]], text = first_head, param = param},
{ page = [[/fon_devices/edit_fon_ring_block.lua]], text = TXT([[{?4255:264?}]]), param = param},
{ page = [[/fon_devices/edit_fon_option.lua]], text = TXT([[{?4255:488?}]]), param = param}
}
end
function is_checked(check)
if check then
return[[ checked="checked" ]]
end
return ""
end
function get_doorline_bell(bell_number, org_num, rep_num)
str_html = [[
<tr>
<td class="width">]]..general.sprintf(TXT([[{?4255:611?}]]), (bell_number + 1))..[[</td>
<td class="width"><input id="Id_Num_Org]]..bell_number..[[" type="text" onchange="" value="]]..org_num..[[" maxlength="5" size="5" name="Num_Org]]..bell_number..[["></td>
<td>
<select id="id_Signal]]..bell_number..[[" onchange="onSignalChange(this, 'Id_Num_Rep]]..bell_number..[[')" name="Signal]]..bell_number..[[">
]]
local devices_options, not_selected = get_fondevices_option_html(rep_num, "intern")
local sel = ""
local num_rep_style = [[style="display:none;"]]
if rep_num ~= "9" and not_selected then
sel=[[selected]]
num_rep_style = ""
else
rep_num = ""
end
str_html = str_html..devices_options..[[
<option value='outNum' ]]..sel..[[>]]..TXT("{?4255:234?}")..[[</option>
</select>
<input id="Id_Num_Rep]]..bell_number..[[" type="text" ]]..num_rep_style..[[ name="Num_Rep]]..bell_number..[[" value="]]..rep_num..[[" maxlength="20">
</td>
</tr>]]
return str_html
end
function get_block_html(data)
str_html = [[
<div>
<p>]]..TXT([[{?4255:6612?}]])..[[</p>
<div class="formular">
<p><input type="checkbox" name="nightsetting" id="uiMyLocking" ]]..is_checked(tostring(data.NoRingWithNightSetting) == "0")..[[ value="1" onclick="jxl.disableNode('uiRingDiv',!this.checked)">
<label for="uiMyLocking">]]..TXT([[{?4255:89?}]])..[[</label></p>
</div>
]]
str_html = str_html..[[
<div id="uiRingDiv" class="formular">
<div class="formular">]]
if general.is_expert() then
str_html = str_html..[[
<p><input type="radio" name="lockmode" id="uiRing" ]]..is_checked(fon_devices.get_locked(data.RingAllowed) == false)..[[ value="0"><label for="uiRing">]]..TXT([[{?4255:178?}]])..[[</label></p>
<p><input type="radio" name="lockmode" id="uiLocked" ]]..is_checked(fon_devices.get_locked(data.RingAllowed))..[[ value="1"><label for="uiLocked">]]..TXT([[{?4255:947?}]])..[[</label></p>
<p>]]..TXT([[{?4255:30?}]])..[[</p>
<div class="formular">]]
end
str_html = str_html..[[
<p><input type="radio" name="lockday" id="uiLockAll" ]]..is_checked(fon_devices.get_allow_state(data.RingAllowed) == "everday")..[[ value="everday"><label for="uiLockAll">]]..TXT([[{?4255:27?}]])..[[</label></p>
<p><input type="radio" name="lockday" id="uiLockWeekend" ]]..is_checked(fon_devices.get_allow_state(data.RingAllowed) == "weekend")..[[ value="weekend"><label for="uiLockWeekend">]]..TXT([[{?4255:683?}]])..[[</label></p>
<p><input type="radio" name="lockday" id="uiLockWorkday" ]]..is_checked(fon_devices.get_allow_state(data.RingAllowed) == "workday")..[[ value="workday"><label for="uiLockWorkday">]]..TXT([[{?4255:826?}]])..[[</label></p>
<div>
<label for="uiStartHH">]]..TXT([[{?4255:19?}]])..[[</label>
<input type="text" name="starthh" id="uiStartHH" size="3" maxlength="2" value="]]..box.tohtml(tostring(data.NightStart_Values[1]))..[[" ]].."g_StartTime_Attributs"..[[ /> :
<input type="text" name="startmm" id="uiStartMM" size="3" maxlength="2" value="]]..box.tohtml(tostring(data.NightStart_Values[2]))..[[" ]].."g_StartTime_Attributs"..[[ />
<label for="uiEndHH">&nbsp;]]..TXT([[{?4255:320?}]])..[[</label>
<input type="text" name="endhh" id="uiEndHH" size="3" maxlength="2" value="]]..box.tohtml(tostring(data.NightEnd_Values[1]))..[[" ]].."g_EndTime_Attributs"..[[ /> :
<input type="text" name="endmm" id="uiEndMM" size="3" maxlength="2" value="]]..box.tohtml(tostring(data.NightEnd_Values[2]))..[[" ]].."g_EndTime_Attributs"..[[ />
</div>]]
if general.is_expert() then
str_html = str_html..[[
</div>]]
end
str_html = str_html..[[
</div>
</div>
]]
str_html = str_html..[[</div>]]
return str_html
end
function get_fon123_name(data)
local name = ""
return [[<label for="uiName">]]..TXT([[{?4255:766?}]])..[[</label><input type="text" id="uiName" name="name" size="21" maxlength="20" value="]]..data.name..[[">]]
end
function write_fon_js(OutNum)
local str=[[
var g_OutNum="]]..OutNum..[[";
var g_txt_NumForOutCall="]]..TXT([[{?4255:392?}]])..[[";
]]..get_sel_handler()..[[
function GetIndex(num)
{
for (var i=0;i<g_all_ids.length;i++)
{
if (g_all_ids[i].num==num)
{
return i;
}
}
return 0;
}
function GetIndexForCheckBox(num)
{
return "uiNum_"+(GetIndex(num)+1);
}
function GetIndexForSpan(num)
{
return "uiNumInfo_"+(GetIndex(num)+1);
}
function NumWasChecked(ToNum)
{
var idx=GetIndex(ToNum);
if (idx>=0 && idx<g_all_ids.length)
{
return g_all_ids[idx].checked;
}
return false;
}
function OnCheckNum (obj)
{
var idx=GetIndex(obj.value);
if (idx>=0 && idx<g_all_ids.length)
{
g_all_ids[idx].checked=obj.checked;
}
}
function OnChangeTo (ToNum)
{
if (ToNum!=g_OutNum)
{
jxl.setText(GetIndexForSpan(g_OutNum),"");
jxl.setChecked(GetIndexForCheckBox(g_OutNum),NumWasChecked(g_OutNum));
g_OutNum=ToNum;
if (g_OutNum != "") {
jxl.setText(GetIndexForSpan(ToNum),g_txt_NumForOutCall);
jxl.setChecked(GetIndexForCheckBox(ToNum),true);
}
}
}
function OnSelNum(reactOn)
{
var showNums=(reactOn=="sel_nums")
jxl.disableNode("uiOptionalNums",!showNums);
jxl.display("uiOptionalNums",showNums);
}
function init()
{
jxl.setText(GetIndexForSpan(g_OutNum),g_txt_NumForOutCall);
}
ready.onReady(init)
]]
return str
end
function twopartnumber(n)
n = tostring(n)
if #n == 2 then
return tostring(n)
elseif #n > 2 then
return "00"
end
return "0"..tostring(n)
end
function splitnumber(str)
local strings = string.split(str, ":")
local part_a = strings[1] or "0"
local part_b = strings[2] or "0"
return tostring(twopartnumber(part_a)..twopartnumber(part_b))
end
function get_num_by_id(id)
if id ~= "" and id == "POTS" then
id = box.query("telcfg:settings/MSN/POTS")
elseif string.find(id, "SIP") then
local sip_num_list = fon_numbers.get_sip_num()
local telcfg_id = string.gsub(id,"SIP","")
local num_elem = fon_numbers.find_elem_in_list_by_telcfgid(sip_num_list, telcfg_id)
if (num_elem) then
id = string.upper(num_elem.msnnum)
end
else
local mobile_num_list = fon_numbers.get_mobile_msn()
local num_elem = fon_numbers.find_elem_in_list_by_telcfgid(mobile_num_list, id)
if num_elem then
id = string.upper(num_elem.number)
end
local sip_num_list = fon_numbers.get_sip_num()
num_elem = fon_numbers.find_elem_in_list_by_telcfgid(sip_num_list, id)
if num_elem then
id = string.upper(num_elem.number)
end
end
return id
end
function get_num_sip_pots(number)
if number ~= "" and number == box.query("telcfg:settings/MSN/POTS") then
number = "POTS"
else
local mobile_num_list = fon_numbers.get_mobile_msn()
local num_elem = fon_numbers.get_elem_by_num(mobile_num_list, number)
if num_elem then
number = string.upper(num_elem.id)
end
local sip_num_list = fon_numbers.get_sip_num()
num_elem = fon_numbers.get_elem_by_num(sip_num_list, number)
if num_elem then
number = string.upper(num_elem.id)
end
end
return number
end
function get_num_sip_pots_msnnum(number)
if number ~= "" and number == box.query("telcfg:settings/MSN/POTS") then
number = "POTS"
else
local mobile_num_list = fon_numbers.get_mobile_msn()
local num_elem = fon_numbers.find_elem_in_list_by_msnnum(mobile_num_list, number)
if num_elem then
number = string.upper(num_elem.id)
end
local sip_num_list = fon_numbers.get_sip_num()
num_elem = fon_numbers.find_elem_in_list_by_msnnum(sip_num_list, number)
if num_elem then
number = string.upper(num_elem.id)
end
end
return number
end
function get_num_save_data(data)
if data == nil then
return ""
end
local ctlmgr_save={}
local number=""
local out_num_checked=false
local out_num = get_num_sip_pots_msnnum(box.post.out_num)
cmtable.add_var(ctlmgr_save, data.current_name_query, box.post.name)
if (box.post.num_selection=="all_nums") then
cmtable.add_var(ctlmgr_save, data.ring_all_query ,"1")
for i=1,9,1 do
local number=data.incoming[i] or ""
if (number== out_num) then
out_num_checked=true
end
end
else
cmtable.add_var(ctlmgr_save, data.ring_all_query ,"0")
local save_pos = 1
for i=1, fon_numbers.get_number_count("all"), 1 do
local number=box.post["num_"..tostring(i)] or ""
number = get_num_sip_pots_msnnum(number)
if number~="" then
if (number~=out_num) then
cmtable.add_var(ctlmgr_save, data.number_save_root..data.idx.."/"..data.number_end_str..tostring(save_pos), number)
save_pos = save_pos + 1
if save_pos>9 then
break
end
else
out_num_checked=true
end
end
end
for j=save_pos,9,1 do
cmtable.add_var(ctlmgr_save, data.number_save_root..data.idx.."/"..data.number_end_str..tostring(j), "")
end
end
number = out_num
if not out_num_checked then
number=number.."#"
end
cmtable.add_var(ctlmgr_save, data.number_query, number)
return ctlmgr_save
end
function get_ring_block_validation()
return {
prog = [[
if __value_equal(uiMyLocking/nightsetting, 1) then
clock_time(uiStartHH/starthh, uiStartMM/startmm, starthh)
clock_time(uiEndHH/endhh, uiEndMM/endmm, endhh)
end
]]
}
end
function get_ring_block_validation_msg()
local val_msg = {}
val_msg.starthh = {
[val.ret.notfound] = TXT([[{?4255:46?}]]),
[val.ret.empty] = TXT([[{?4255:202?}]]),
[val.ret.format] = TXT([[{?4255:238?}]]),
[val.ret.outofrange] = TXT([[{?4255:1238?}]])
}
val_msg.endhh = {
[val.ret.notfound] = TXT([[{?4255:552?}]]),
[val.ret.empty] = TXT([[{?4255:923?}]]),
[val.ret.format] = TXT([[{?4255:761?}]]),
[val.ret.outofrange] = TXT([[{?4255:938?}]])
}
return val_msg
end
function set_start_end_time( startTime, endTime )
if "2400" == startTime then
startTime = "0000"
end
if "0000" == endTime then
endTime = "2400"
end
return startTime .. endTime
end
function get_save_block_data(save_lib)
local ctlmgr_save={}
local ring_allowed = "1"
if box.post.lockmode == "1" then
if box.post.lockday == "weekend" then
ring_allowed = "2"
elseif box.post.lockday == "workday" then
ring_allowed = "3"
end
else
if box.post.lockday == "weekend" then
ring_allowed = "4"
elseif box.post.lockday == "workday" then
ring_allowed = "5"
end
end
local no_nightsetting = "1"
if box.post.nightsetting then
no_nightsetting = "0"
end
cmtable.add_var(ctlmgr_save, save_lib..[[/NoRingWithNightSetting]], no_nightsetting)
if no_nightsetting == "1" then
ring_allowed = "1"
if box.query("box:settings/night_time_control_enabled") == "1" and box.query("box:settings/night_time_control_ring_blocked") == "1" then
local part_a = box.query([[box:settings/night_time_control_off_time]])
local part_b = box.query([[box:settings/night_time_control_on_time]])
noringtime = set_start_end_time( splitnumber(part_a), splitnumber(part_b) )
cmtable.add_var(ctlmgr_save, save_lib..[[/NoRingTime]], noringtime)
else
cmtable.add_var(ctlmgr_save, save_lib..[[/NoRingTime]], "")
end
else
if box.post.lockmode == "1" then
cmtable.add_var(ctlmgr_save, save_lib..[[/NoRingTime]], set_start_end_time( twopartnumber( box.post.endhh )..twopartnumber( box.post.endmm ), twopartnumber( box.post.starthh )..twopartnumber( box.post.startmm ) ) )
else
cmtable.add_var(ctlmgr_save, save_lib..[[/NoRingTime]], set_start_end_time( twopartnumber( box.post.starthh )..twopartnumber( box.post.startmm ), twopartnumber( box.post.endhh )..twopartnumber( box.post.endmm ) ) )
end
end
cmtable.add_var(ctlmgr_save, save_lib..[[/RingAllowed]], ring_allowed)
return ctlmgr_save
end
