<?lua
g_page_type = "all"
g_page_title = [[{?790:81?}]]
g_page_help = "hilfe_internet_edit_ipv6_freigabe.html"
g_menu_active_page = "/internet/ipv6_fw.lua"
dofile("../templates/global_lua.lua")
require"menu"
if not menu.check_page("internet", "/internet/ipv6_fw.lua") then
require"http"
http.redirect("/home/home.lua")
end
require("cmtable")
require("val")
require("boxvars2")
require("elem")
require("general")
require("http")
g_back_to_page = http.get_back_to_page([[/internet/ipv6_fw.lua]])
if (next(box.post) and (box.post.cancel)) then
http.redirect(g_back_to_page)
end
g_errcode = 0
g_errmsg = [[ERROR: Es ist ein Fehler beim Übernehmen der Daten aufgetreten. Die aktuellen Daten dieser Seite wurden nicht gespeichert.]]
g_sz_text_userdefined = [[{?790:534?}]]
g_current_ipv6_fw_enabled = nil
g_current_ipv6_fw_neighbour_name = nil
g_current_ipv6_fw_ifaceid = nil
g_current_ipv6_fw_exposed_host = nil
g_current_ipv6_fw_ping6_allowed = nil
g_b_is_new = false
g_current_device = ""
g_new_ruleid = ""
g_new_rule_value = ""
g_szListQuery = ""
g_t_portList = {}
g_t_newrule = { "", ""}
g_t_new_dev_list = {}
g_t_interfaceId = { "", "", "", ""}
function split(str, sep)
local result = {}
if not sep or sep == "" then
for i = 1, #str do
table.insert(result, str:sub(i,i))
end
return result
end
local curr = 1
local left, right = str:find(sep, curr, true)
while left do
table.insert(result, str:sub(curr, left-1))
curr = right + 1
left, right = str:find(sep, curr, true)
end
table.insert(result, str:sub(curr))
return result
end
function split_interfaceID()
local n_ende = 0
local l_sz_interface_id = g_current_ipv6_fw_ifaceid:get_value()
n_beginn, n_ende = string.find( l_sz_interface_id, "::")
if ( n_ende ~= nil) then
l_sz_interface_id = string.sub( l_sz_interface_id, (n_ende + 1), #l_sz_interface_id)
end
local l_t_interfaceId = split( l_sz_interface_id, ":")
if ( #l_t_interfaceId == 1) then
g_t_interfaceId[4] = l_t_interfaceId[1]
elseif ( #l_t_interfaceId == 2) then
g_t_interfaceId[3] = l_t_interfaceId[1]
g_t_interfaceId[4] = l_t_interfaceId[2]
elseif ( #l_t_interfaceId == 3) then
g_t_interfaceId[2] = l_t_interfaceId[1]
g_t_interfaceId[3] = l_t_interfaceId[2]
g_t_interfaceId[4] = l_t_interfaceId[3]
elseif ( #l_t_interfaceId == 4) then
g_t_interfaceId[1] = l_t_interfaceId[1]
g_t_interfaceId[2] = l_t_interfaceId[2]
g_t_interfaceId[3] = l_t_interfaceId[3]
g_t_interfaceId[4] = l_t_interfaceId[4]
end
end
function interfaceID_after_post( b_valid)
g_t_interfaceId[1] = box.post[ tostring(g_current_ipv6_fw_ifaceid:get_var_name()).."_1"]
g_t_interfaceId[2] = box.post[ tostring(g_current_ipv6_fw_ifaceid:get_var_name()).."_2"]
g_t_interfaceId[3] = box.post[ tostring(g_current_ipv6_fw_ifaceid:get_var_name()).."_3"]
g_t_interfaceId[4] = box.post[ tostring(g_current_ipv6_fw_ifaceid:get_var_name()).."_4"]
if ( b_valid) then
local l_sz_interface_id = "::"
for i=1, 4 do
if ( (g_t_interfaceId[i] == "") or (tonumber(g_t_interfaceId[i]) == 0)) then
g_t_interfaceId[i] = "0"
end
l_sz_interface_id = l_sz_interface_id .. g_t_interfaceId[i]
if ( i < 4 ) then
l_sz_interface_id = l_sz_interface_id .. ":"
end
end
return l_sz_interface_id
end
end
function devicename_after_post()
local sz_ret = ""
if ( g_b_is_new) then
local sz_value = ""
sz_value, sz_ret = get_select_devicename()
if ( sz_value == "userdefined" ) then
sz_ret = box.post["userdefined_name"]
end
else
sz_ret = box.post[tostring(g_current_ipv6_fw_neighbour_name:get_var_name())]
end
return sz_ret
end
function get_exposed_host()
local exposed_host = g_current_ipv6_fw_exposed_host:get_value()
if not exposed_host or exposed_host == "" then
exposed_host = "0"
end
return exposed_host
end
function get_select_devicename()
local sz_ret = box.post[g_current_ipv6_fw_neighbour_name:get_var_name()]
local l_t_dev_name = split( sz_ret, "#")
return l_t_dev_name[1], l_t_dev_name[2]
end
function init_page_vars( sz_device)
g_current_ipv6_fw_enabled = boxvars2.c_boxvars:init( { sz_query = [[ipv6firewall:settings/]]..sz_device..[[/enabled]]} )
g_current_ipv6_fw_neighbour_name = boxvars2.c_boxvars:init( { sz_query = [[ipv6firewall:settings/]]..sz_device..[[/neighbour_name]]} )
g_current_ipv6_fw_ifaceid = boxvars2.c_boxvars:init( { sz_query = [[ipv6firewall:settings/]]..sz_device..[[/ifaceid]]} )
g_current_ipv6_fw_exposed_host = boxvars2.c_boxvars:init( { sz_query = [[ipv6firewall:settings/]]..sz_device..[[/exposed_host]]} )
if (g_current_ipv6_fw_exposed_host:get_value()=="er") then
g_current_ipv6_fw_exposed_host:set_value("1")
end
g_current_ipv6_fw_ping6_allowed = boxvars2.c_boxvars:init( { sz_query = [[ipv6firewall:settings/]]..sz_device..[[/ping6_allowed]]} )
g_szListQuery = [[ipv6firewall:settings/]]..sz_device..[[/rules/entry/list(rule)]]
g_t_portList = general.listquery(g_szListQuery)
g_new_ruleid = box.query( [[ipv6firewall:settings/]]..sz_device..[[/rules/entry/newid]])
end
function get_new_dev_list()
local l_t_landevices = general.listquery( [[landevice:settings/landevice/list(name,neighbour_name,is_double_neighbour_name,ipv6_ifid)]])
for i=1, #l_t_landevices do
local l_cur_ipv6adr = box.query( [[landevice:settings/]]..l_t_landevices[i]._node..[[/ipv6addrs0/entry0/ipv6addr]])
if (( tostring( l_t_landevices[i].neighbour_name) ~= "" ) and
( tostring( l_t_landevices[i].is_double_neighbour_name) == "0") and
( tostring( l_t_landevices[i].ipv6_ifid) ~= "" ) ) then
local sz_neighbour_name = tostring( l_t_landevices[i].neighbour_name)
local sz_iface_id = tostring( l_t_landevices[i].ipv6_ifid)
if ( not(is_ipv6firewall_rule( sz_neighbour_name, sz_iface_id))) then
local l_t_select_entry = {}
local l_sz_firstentry = sz_iface_id.."#"..sz_neighbour_name
table.insert( l_t_select_entry, l_sz_firstentry)
table.insert( l_t_select_entry, sz_neighbour_name)
table.insert( g_t_new_dev_list, l_t_select_entry)
end
end
end
table.insert( g_t_new_dev_list, { ([[userdefined#]]..g_sz_text_userdefined), g_sz_text_userdefined } )
return g_t_new_dev_list
end
function is_ipv6firewall_rule( sz_neighbour_name, sz_iface_id)
local l_t_ipv6firewalls = general.listquery( [[ipv6firewall:settings/rule/list(enabled,neighbour_name,ifaceid)]])
for i=1, #l_t_ipv6firewalls do
if (( tostring( l_t_ipv6firewalls[i].neighbour_name) == sz_neighbour_name ) or
( tostring( l_t_ipv6firewalls[i].ifaceid) == sz_iface_id ) ) then
return true
end
end
return false
end
function write_table_content( t_content)
local l_szRet = ""
local l_szId = ""
local l_elem_value1, l_elem_value2, l_elem_value3 = "", "", ""
if g_b_is_new then
l_elem_value2, l_elem_value3 = "80", "80"
end
if ( #t_content > 0 ) then
local l_Str = ""
for i=1, #t_content do
local l_elem_value1, l_elem_value2, l_elem_value3 = get_rule_part( t_content[i].rule)
l_Str = [[<tr>]]
l_Str = l_Str..[[<td style="padding-left: 15px;">]]
l_Str = l_Str..elem._select( "proto_"..tostring(t_content[i]._node),
"ui_Proto_"..tostring(t_content[i]._node),
{"TCP", "UDP"},
l_elem_value1,
{"TCP", "UDP"} )
l_Str = l_Str..[[</td>]]
l_Str = l_Str..[[<td>]]
l_Str = l_Str..elem._label( "ui_Port_From_"..tostring(t_content[i]._node),
"ui_Label_Port_From_"..tostring(t_content[i]._node),
[[{?790:8360?}]],
"width: 50px; padding-left: 15px;" )
l_Str = l_Str..[[&nbsp;]]
l_szId = "ui_Port_From_"..tostring(t_content[i]._node)
l_Str = l_Str..elem._input( "text", "port_from_"..tostring(t_content[i]._node),
l_szId,
l_elem_value2, "5", "5",
val.get_attrs( g_val, l_szId))
l_Str = l_Str..[[&nbsp;]]
l_Str = l_Str..elem._label( "ui_Port_To_"..tostring(t_content[i]._node),
"ui_Label_Port_To_"..tostring(t_content[i]._node),
[[{?790:198?}]],
"width: 50px; padding-left: 15px;")
l_Str = l_Str..[[&nbsp;]]
l_szId = "ui_Port_To_"..tostring(t_content[i]._node)
l_Str = l_Str..elem._input( "text", "port_to_"..tostring(t_content[i]._node),
"ui_Port_To_"..tostring(t_content[i]._node),
l_elem_value3, "5", "5",
val.get_attrs( g_val, l_szId))
l_Str = l_Str..[[</td>]]
l_Str = l_Str..[[<td class="buttonrow">]]
l_Str = l_Str..general.get_icon_button( "/css/default/images/loeschen.gif",
"delete_"..t_content[i]._node,
"delete",
t_content[i]._node,
"{?txtIconBtnDelete?}")
l_Str = l_Str..[[</td>]]
l_Str = l_Str..[[</tr>]]
l_szRet = l_szRet..l_Str
end
end
if (g_new_rule_value ~= "") then
l_elem_value1, l_elem_value2, l_elem_value3 = get_rule_part( g_new_rule_value)
end
l_Str = [[<tr id="ui_NewRule">]]
l_Str = l_Str..[[<td style="padding-left: 15px;">]]
l_Str = l_Str..elem._select( "proto_"..tostring(g_new_ruleid),
"ui_Proto_"..tostring(g_new_ruleid),
{"TCP", "UDP"},
l_elem_value1,
{"TCP", "UDP"} )..[[</td>]]
l_Str = l_Str..[[<td>]]
l_Str = l_Str..elem._label( "ui_Port_From_"..tostring(g_new_ruleid),
"ui_Label_Port_From_"..tostring(g_new_ruleid),
[[{?790:425?}]],
"width: 50px; padding-left: 15px;" )
l_Str = l_Str..[[&nbsp;]]
l_szId = "ui_Port_From_"..tostring(g_new_ruleid)
l_Str = l_Str..elem._input( "text", "port_from_"..tostring(g_new_ruleid),
l_szId,
l_elem_value2, "5", "5",
val.get_attrs( g_val, l_szId))
l_Str = l_Str..[[&nbsp;]]
l_Str = l_Str..elem._label( "ui_Port_To_"..tostring(g_new_ruleid),
"ui_Label_Port_To_"..tostring(g_new_ruleid),
[[{?790:769?}]],
"width: 50px; padding-left: 15px;")
l_Str = l_Str..[[&nbsp;]]
l_szId = "ui_Port_To_"..tostring(g_new_ruleid)
l_Str = l_Str..elem._input( "text", "port_to_"..tostring(g_new_ruleid),
l_szId,
l_elem_value3, "5", "5",
val.get_attrs( g_val, l_szId))
l_Str = l_Str..[[</td>]]
l_Str = l_Str..[[<td class="buttonrow"></td>]]
l_Str = l_Str..[[</tr>]]
l_szRet = l_szRet..l_Str
box.out( l_szRet)
end
function get_rule_part( szValue)
local l_szRet1 = ""
local l_szRet2 = ""
local l_szRet3 = ""
local l_Pos = 0
l_Pos = string.find( szValue, " ")
if ( l_Pos ~= nil) then
l_szRet1 = string.sub( szValue, 1, (l_Pos-1))
local l_Pos2 = l_Pos
l_Pos = string.find( szValue, "-")
if ( l_Pos ~= nil) then
l_szRet2 = string.sub( szValue, (l_Pos2+1), (l_Pos-1))
l_szRet3 = string.sub( szValue, (l_Pos+1))
else
l_szRet2 = string.sub( szValue, (l_Pos2+1))
end
end
return l_szRet1, l_szRet2, l_szRet3
end
function get_entries_after_post( _t_content)
local l_list_count = tonumber( box.querycount( g_szListQuery))
for i=1, l_list_count do
local l_proto_value = box.post["proto_"..tostring(_t_content[i]._node)]
local l_from_value = box.post["port_from_"..tostring(_t_content[i]._node)]
local l_to_value = box.post["port_to_"..tostring(_t_content[i]._node)]
l_szValue = l_proto_value..[[ ]]..l_from_value
if ( l_to_value ~= "") then
l_szValue = l_szValue..[[-]]..l_to_value
end
_t_content[i].rule = l_szValue
end
end
function get_new_entry_after_post()
local l_bRet = false
local l_szRet = ""
local l_proto_value_new = box.post["proto_"..tostring(g_new_ruleid)]
local l_from_value_new = box.post["port_from_"..tostring(g_new_ruleid)]
local l_to_value_new = box.post["port_to_"..tostring(g_new_ruleid)]
l_szRet = l_proto_value_new..[[ ]]..l_from_value_new
l_szRet = l_szRet..[[-]]..l_to_value_new
if ( l_from_value_new ~= "") then
l_bRet = true
end
return l_bRet, l_szRet
end
if (next(box.get) and box.get.device) then
if ( box.get.new) then
g_b_is_new = true
end
g_current_device = box.get.device
init_page_vars( g_current_device)
if ( not(g_b_is_new)) then
split_interfaceID( g_current_ipv6_fw_ifaceid:get_value())
end
else
if ( next(box.post)) then
g_current_device = box.post.current_device
g_b_is_new = (box.post.is_new_device == tostring( true))
init_page_vars( g_current_device)
end
end
if (g_current_device=="") then
http.redirect(g_back_to_page)
end
function get_val_prog()
local l_list_count = tonumber( box.querycount( g_szListQuery))
g_val = {
prog = [[
char_range_regex(]]..g_current_ipv6_fw_ifaceid:get_var_name_js()..[[_1/]]..g_current_ipv6_fw_ifaceid:get_var_name()..[[_1, hexvalue, hexvalue)
char_range_regex(]]..g_current_ipv6_fw_ifaceid:get_var_name_js()..[[_2/]]..g_current_ipv6_fw_ifaceid:get_var_name()..[[_2, hexvalue, hexvalue)
char_range_regex(]]..g_current_ipv6_fw_ifaceid:get_var_name_js()..[[_3/]]..g_current_ipv6_fw_ifaceid:get_var_name()..[[_3, hexvalue, hexvalue)
char_range_regex(]]..g_current_ipv6_fw_ifaceid:get_var_name_js()..[[_4/]]..g_current_ipv6_fw_ifaceid:get_var_name()..[[_4, hexvalue, hexvalue)
interface_id(]]..g_current_ipv6_fw_ifaceid:get_var_name_js()..[[_/]]..g_current_ipv6_fw_ifaceid:get_var_name()..[[_,interface_id)
]]
}
local l_szToProg = ""
local l_szFromId = ""
local l_szToId = ""
local l_szFromName = ""
local l_szToName = ""
g_t_html_Error_IDs = {}
for i=1, l_list_count do
l_szFromId = [[ui_Port_From_entry]]..tostring((i-1))
l_szFromName = [[port_from_entry]]..tostring((i-1))
table.insert( g_t_html_Error_IDs, l_szFromId)
l_szToId = [[ui_Port_To_entry]]..tostring((i-1))
l_szToName = [[port_to_entry]]..tostring((i-1))
table.insert( g_t_html_Error_IDs, l_szToId)
l_szToProg =[[fw_port_range(]]..l_szFromId..[[/]]..l_szFromName..[[, ]]..l_szToId..[[/]]..l_szToName
l_szToProg = l_szToProg..[[, true, fw_port_range)]]
l_szToProg = l_szToProg..[[num_range(]]..l_szFromId..[[/]]..l_szFromName..[[, 0, 65535, true, num_range)]]
l_szToProg = l_szToProg..[[num_range(]]..l_szToId..[[/]]..l_szToName..[[, 0, 65535, false, num_range)]]
g_val.prog = g_val.prog..l_szToProg
end
l_szFromId = [[ui_Port_From_]]..tostring(g_new_ruleid)
l_szFromName = [[port_from_]]..tostring(g_new_ruleid)
l_szToId = [[ui_Port_To_]]..tostring(g_new_ruleid)
l_szToName = [[port_to_]]..tostring(g_new_ruleid)
table.insert( g_t_html_Error_IDs, l_szFromId)
table.insert( g_t_html_Error_IDs, l_szToId)
l_szToProg = [[num_range(]]..l_szFromId..[[/]]..l_szFromName..[[, 0, 65535, false, num_range)]]
l_szToProg = l_szToProg..[[num_range(]]..l_szToId..[[/]]..l_szToName..[[, 0, 65535, false, num_range)]]
l_szToProg = l_szToProg..[[fw_port_range(]]..l_szFromId..[[/]]..l_szFromName..[[, ]]..l_szToId..[[/]]..l_szToName
l_szToProg = l_szToProg..[[, false, fw_port_range)]]
g_val.prog = g_val.prog..l_szToProg
end
get_val_prog()
val.msg.hexvalue = {
[val.ret.outofrange] = [[{?790:298?}]]
}
val.msg.interface_id = {
[val.ret.empty] = [[{?790:102?}]],
[val.ret.wrong] = [[{?790:772?}]]
}
val.msg.num_range = {
[val.ret.notfound] = [[{?790:0?}]],
[val.ret.empty] = [[{?790:718?}]],
[val.ret.format] = [[{?790:339?}]],
[val.ret.outofrange] = [[{?790:130?}]],
}
val.msg.fw_port_range = {
[val.ret.notfound] = [[{?790:422?}]],
[val.ret.empty] = [[{?790:148?}]],
[val.ret.format] = [[{?790:195?}]],
[val.ret.outofrange] = [[{?790:266?}]],
[val.ret.wrong] = [[{?790:507?}]],
[val.ret.missing] = [[{?790:375?}]]
}
if ( next(box.post)) then
local l_val_result = val.ret.ok
local saveset = {}
if ( box.post.apply) then
local l_bSave = false
if ( box.post.is_new_device ~= nil) then
if ( box.post.is_new_device == "true") then
g_b_is_new = true
else
g_b_is_new = false
end
end
get_entries_after_post(g_t_portList)
l_bSave, g_new_rule_value = get_new_entry_after_post()
l_val_result = val.validate(g_val)
if ( l_val_result == val.ret.ok) then
g_current_ipv6_fw_enabled:save_check_value( saveset)
local l_devicename = devicename_after_post()
cmtable.add_var( saveset, g_current_ipv6_fw_neighbour_name:get_query_str(), l_devicename)
local l_interfaceId = interfaceID_after_post( true)
cmtable.add_var( saveset, g_current_ipv6_fw_ifaceid:get_query_str(), l_interfaceId)
g_current_ipv6_fw_exposed_host:save_value( saveset)
g_current_ipv6_fw_ping6_allowed:save_check_value( saveset)
for i=1, #g_t_portList do
local l_var_string = [[ipv6firewall:settings/]]..g_current_device..[[/rules/]]..tostring(g_t_portList[i]._node)..[[/rule]]
cmtable.add_var( saveset, l_var_string, g_t_portList[i].rule)
end
if ( l_bSave) then
local l_var_string_new = [[ipv6firewall:settings/]]..g_current_device..[[/rules/]]..tostring(g_new_ruleid)..[[/rule]]
cmtable.add_var( saveset, l_var_string_new, g_new_rule_value)
end
else
if g_current_ipv6_fw_enabled:var_exist() then
g_current_ipv6_fw_enabled:set_value( "1")
else
g_current_ipv6_fw_enabled:set_value( "0")
end
g_current_ipv6_fw_exposed_host:set_value( box.post[g_current_ipv6_fw_exposed_host:get_var_name()])
if g_current_ipv6_fw_ping6_allowed:var_exist() then
g_current_ipv6_fw_ping6_allowed:set_value( "1")
else
g_current_ipv6_fw_ping6_allowed:set_value( "0")
end
g_current_ipv6_fw_neighbour_name:set_value( devicename_after_post())
interfaceID_after_post( false)
end
end
if ( box.post.delete) then
cmtable.add_var( saveset, ("ipv6firewall:command/"..g_current_device.."/rules/"..box.post.delete), "delete")
interfaceID_after_post( false)
end
if ( l_val_result == val.ret.ok) then
g_errcode, g_errmsg = box.set_config( saveset)
if g_errcode ~= 0 then
g_val.errmsg = errmsg
else
if ( box.post.apply) then
http.redirect( [[/internet/ipv6_fw.lua]])
end
if ( box.post.delete) then
init_page_vars( g_current_device)
get_val_prog()
end
end
end
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function init()
{
fc.init("idbox", 4);
if (<?lua if (g_b_is_new) then box.out( false) else box.out( true) end?> ) {
jxl.display( "ui_NewRule", false);
jxl.display( "ui_ShowNewRule", true);
}
if (<?lua if (g_b_is_new) then box.out( true) else box.out( false) end?> ) {
var select_elem = jxl.get( <?lua box.out( [["]]..g_current_ipv6_fw_neighbour_name:get_var_name_js()..[["]]) ?>);
if ( select_elem)
select_elem.onchange = OnChangeNewEntry;
OnChangeNewEntry();
}
OnChange_Exposed_Host( <?lua box.out( [["]]..box.tojs(get_exposed_host())..[["]]) ?>);
}
function OnShowNewRule() {
jxl.display( "ui_ShowNewRule", false);
jxl.display( "ui_NewRule", true);
}
function OnChange_Exposed_Host( szValue) {
jxl.display( "uiShow_Rules", szValue == "0");
}
function On_MainFormSubmit() {
<?lua
val.write_js_checks( g_val)
?>
}
function OnChangeNewEntry() {
var szValue = uiGetSelectDevice();
if ( szValue == "userdefined") {
jxl.display( "ui_ShowUserdefined", true);
jxl.enable( "ui_UserdefinedName")
uiSetIfaceid( "");
} else {
jxl.display( "ui_ShowUserdefined", false);
jxl.disable( "ui_UserdefinedName");
uiSetIfaceid( szValue);
}
}
function uiSetIfaceid( szValue) {
var arIfaceId = new Array( "", "", "", "");
var szIfaceId = String( szValue);
if ( szIfaceId != "::") {
if ( szIfaceId.indexOf( "::") != -1) {
szIfaceId = szIfaceId.substr(2);
}
arIfaceId = uiParseIfaceId( szIfaceId);
}
for ( var nIdx=1; nIdx<=4; nIdx++) {
jxl.setValue( <?lua box.out( [["]]..g_current_ipv6_fw_ifaceid:get_var_name_js()..[[_"]]) ?>+(nIdx), arIfaceId[(nIdx-1)]);
}
}
function uiParseIfaceId( szToParse) {
var retAry = new Array();
var tmpAry = szToParse.split( ":");
if ( tmpAry.length == 4 ) {
retAry = tmpAry;
} else if ( tmpAry.length == 3) {
retAry.push( "", tmpAry[0], tmpAry[1], tmpAry[2]);
} else if ( tmpAry.length == 2) {
retAry.push( "", "", tmpAry[0], tmpAry[1]);
} else if ( tmpAry.length == 1) {
retAry.push( "", "", "",tmpAry[0]);
}
return retAry;
}
function uiGetSelectDevice() {
var szToParse = jxl.getValue( <?lua box.out( [["]]..g_current_ipv6_fw_neighbour_name:get_var_name_js()..[["]]) ?>);
var tmpAry = szToParse.split( "#");
return tmpAry[0];
}
ready.onReady(val.init(On_MainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form name="main_form" method="POST" action="/internet/ipv6_fw_edit.lua" id="uiMainForm">
<input type="hidden" name="current_device" value="<?lua box.html( g_current_device) ?>">
<input type="hidden" name="is_new_device" value="<?lua box.html( tostring(g_b_is_new)) ?>">
<h4>{?790:240?}</h4>
<div class="formular">
<?lua
if (g_b_is_new) then
box.out( elem._checkbox( g_current_ipv6_fw_enabled:get_var_name(), g_current_ipv6_fw_enabled:get_var_name_js(), g_current_ipv6_fw_enabled:get_value(), true))
box.out(" ", elem._label( g_current_ipv6_fw_enabled:get_var_name_js(), "Label"..g_current_ipv6_fw_enabled:get_var_name_js(), [[{?790:873?}]]))
else
l_LabelText = [[{?790:554?}]]..tostring(g_current_ipv6_fw_neighbour_name:get_value())
box.out( elem._checkbox( g_current_ipv6_fw_enabled:get_var_name(), g_current_ipv6_fw_enabled:get_var_name_js(), g_current_ipv6_fw_enabled:get_value(), (g_current_ipv6_fw_enabled:get_value() == "1")))
box.out(" ", elem._label( g_current_ipv6_fw_enabled:get_var_name_js(), "Label"..g_current_ipv6_fw_enabled:get_var_name_js(), l_LabelText))
end
box.out( [[<div class="formular">]] )
box.out( [[<p>]])
if (g_b_is_new) then
g_t_new_dev_list = get_new_dev_list()
box.out( elem._label( g_current_ipv6_fw_neighbour_name:get_var_name_js(), "Label"..g_current_ipv6_fw_neighbour_name:get_var_name_js(),[[{?790:1420?}]]))
local sz_selected = ""---[[userdefined#]]..g_sz_text_userdefined
box.out( elem._select( g_current_ipv6_fw_neighbour_name:get_var_name(), g_current_ipv6_fw_neighbour_name:get_var_name_js(), g_t_new_dev_list, sz_selected))
box.out( [[</p><p id="ui_ShowUserdefined">]])
box.out( elem._label( "ui_UserdefinedName", "ui_Label_UserdefinedName",""))
box.out( elem._input( "text", "userdefined_name", "ui_UserdefinedName", "", "24", "50", val.get_attrs(g_val, 'ui_DeviceName')))
else
box.out( elem._label( g_current_ipv6_fw_neighbour_name:get_var_name_js(), "Label"..g_current_ipv6_fw_neighbour_name:get_var_name_js(),[[{?790:128?}]]))
box.out( elem._input( "text", g_current_ipv6_fw_neighbour_name:get_var_name(), g_current_ipv6_fw_neighbour_name:get_var_name_js(), g_current_ipv6_fw_neighbour_name:get_value(), "24", "50", val.get_attrs( g_val, g_current_ipv6_fw_neighbour_name:get_var_name_js() )))
end
box.out( [[</p><div id="idbox">]])
box.out( elem._label( g_current_ipv6_fw_ifaceid:get_var_name_js().."_1", "Label_"..g_current_ipv6_fw_ifaceid:get_var_name_js(),[[{?790:2540?}]]))
box.out( elem._input( "text", g_current_ipv6_fw_ifaceid:get_var_name().."_1", g_current_ipv6_fw_ifaceid:get_var_name_js().."_1", g_t_interfaceId[1], "4", "4", val.get_attrs( g_val,g_current_ipv6_fw_ifaceid:get_var_name_js().."_1", g_current_ipv6_fw_ifaceid:get_var_name_js().."_")))
box.out( [[ : ]])
box.out( elem._input( "text", g_current_ipv6_fw_ifaceid:get_var_name().."_2", g_current_ipv6_fw_ifaceid:get_var_name_js().."_2", g_t_interfaceId[2], "4", "4", val.get_attrs( g_val,g_current_ipv6_fw_ifaceid:get_var_name_js().."_2")))
box.out( [[ : ]])
box.out( elem._input( "text", g_current_ipv6_fw_ifaceid:get_var_name().."_3", g_current_ipv6_fw_ifaceid:get_var_name_js().."_3", g_t_interfaceId[3], "4", "4", val.get_attrs( g_val,g_current_ipv6_fw_ifaceid:get_var_name_js().."_3")))
box.out( [[ : ]])
box.out( elem._input( "text", g_current_ipv6_fw_ifaceid:get_var_name().."_4", g_current_ipv6_fw_ifaceid:get_var_name_js().."_4", g_t_interfaceId[4], "4", "4", val.get_attrs( g_val,g_current_ipv6_fw_ifaceid:get_var_name_js().."_4")))
box.out( [[</div>]])
val.write_html_msg( g_val, g_current_ipv6_fw_ifaceid:get_var_name_js().."_1",g_current_ipv6_fw_ifaceid:get_var_name_js().."_2", g_current_ipv6_fw_ifaceid:get_var_name_js().."_3", g_current_ipv6_fw_ifaceid:get_var_name_js().."_4", g_current_ipv6_fw_ifaceid:get_var_name_js().."_" )
box.out( [[<p>]])
box.out( elem._radio( g_current_ipv6_fw_exposed_host:get_var_name(), g_current_ipv6_fw_exposed_host:get_var_name_js()..[[_1]], "1", (get_exposed_host() == "1"), [[onclick="OnChange_Exposed_Host('1')"]]))
box.out(" ", elem._label( g_current_ipv6_fw_exposed_host:get_var_name_js()..[[_1]], "Label"..g_current_ipv6_fw_exposed_host:get_var_name_js(), [[{?790:787?}]]))
box.out( [[</p>]])
box.out( [[<p class="formular">{?790:781?}</p>]])
box.out( [[<p>]])
box.out( elem._radio( g_current_ipv6_fw_exposed_host:get_var_name(), g_current_ipv6_fw_exposed_host:get_var_name_js()..[[_0]], "0", (get_exposed_host() == "0"), [[onclick="OnChange_Exposed_Host('0')"]]))
box.out(" ", elem._label( g_current_ipv6_fw_exposed_host:get_var_name_js()..[[_0]], "Label"..g_current_ipv6_fw_exposed_host:get_var_name_js(), [[{?790:629?}]]))
box.out( [[</p>]])
box.out( [[<div class="formular" id="uiShow_Rules">]])
box.out( elem._checkbox( g_current_ipv6_fw_ping6_allowed:get_var_name(), g_current_ipv6_fw_ping6_allowed:get_var_name_js(), g_current_ipv6_fw_ping6_allowed:get_value(), (g_current_ipv6_fw_ping6_allowed:get_value() == "1")))
box.out(" ", elem._label( g_current_ipv6_fw_ping6_allowed:get_var_name_js(), "Label"..g_current_ipv6_fw_ping6_allowed:get_var_name_js(), [[{?790:813?}]]))
box.out( [[<table class="zebra"><tr>]])
box.out( [[<th style="padding-left: 15px;">{?790:937?}</th>]])
box.out( [[<th style="padding-left: 15px;">{?790:522?}</th>]])
box.out( [[<th class="buttonrow">&nbsp;</th></tr>]])
write_table_content( g_t_portList)
box.out( [[</table>]])
box.out( [[<div>]])
if ( g_errcode ~= 0) then
box.out( [[<p class="form_input_note ErrorMsg" style="text-align: center; margin: 10px 0px 10px 0px;">]]..tostring( g_errmsg)..[[</p>]])
else
val.write_html_msg( g_val, g_t_html_Error_IDs)
end
box.out( [[</div>]])
?>
<div style="text-align:right;display: none;" id="ui_ShowNewRule">
<button id="ui_BtnNewRule" type="button" name="new_rule" onclick="OnShowNewRule()">{?790:54?}</button>
</div>
</div>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<button type="submit" name="apply" id="uiApply">{?790:169?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
