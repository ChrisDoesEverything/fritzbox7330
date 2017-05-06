<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_portfreigabe"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("boxvars2")
require("elem")
require("general")
local l_szUrl = [[/internet/port_fw_edit.lua?rule=]]
if (next(box.post) and box.post.new_rule) then
l_szUrl = l_szUrl..box.query( "forwardrules:settings/rule/newid")
l_szUrl = l_szUrl..[[&new=1]]
http.redirect( l_szUrl)
end
if (next(box.post) and (box.post.edit)) then
l_szUrl = l_szUrl..box.post.edit
http.redirect( l_szUrl)
end
g_sz_lan_device_ListQuery = [[landevice:settings/landevice/list(name,ip)]]
g_t_lan_device_List = {}
g_sz_port_fw_ListQuery = [[forwardrules:settings/rule/list(activated,description,protocol,port,fwip,fwport,endport)]]
g_t_port_fw_List = {}
g_port_is_exposed_host = boxvars2.c_boxvars:init( { sz_query = "forwardrules:settings/use_exposed_host"} )
g_port_exposed_host_ip = boxvars2.c_boxvars:init( { sz_query = "forwardrules:settings/exposed_host"} )
use_upnp_activated = boxvars2.c_boxvars:init( { sz_query = "box:settings/upnp/activated"} )
use_upnp_security_settings = boxvars2.c_boxvars:init( { sz_query = "box:settings/upnp/control_activated"} )
g_sz_idg_fw_ListQuery = [[igdforwardrules:settings/rule/list(protocol,port,fwname,fwip,fwport)]]
g_t_idg_fw_List = {}
g_errmsg=""
function init_page_vars()
g_t_lan_device_List = general.listquery( g_sz_lan_device_ListQuery)
g_t_port_fw_List = general.listquery( g_sz_port_fw_ListQuery)
g_t_idg_fw_List = general.listquery( g_sz_idg_fw_ListQuery)
end
function name_from_ip( sz_ip)
local l_szRet = ""
for i=1, #g_t_lan_device_List do
if ( tostring( g_t_lan_device_List[i].ip) == sz_ip) then
return tostring( g_t_lan_device_List[i].name)
end
end
return sz_ip
end
function port_range( sz_start_port, sz_end_port, sz_start_fw_port)
if ((sz_end_port == "") or (sz_end_port == "0") or (sz_start_port == sz_end_port)) then
return tostring(sz_start_fw_port)
end
local n_start_port = tonumber( sz_start_port, 10)
local n_end_port = tonumber( sz_end_port, 10)
local n_start_fw_port = tonumber( sz_start_fw_port, 10)
if ((n_start_port == nil) or (n_end_port == nil) or (n_start_fw_port == nil)) then
return [[]]
end
local l_szRet = tostring( n_start_fw_port)..[[-]]..tostring( n_start_fw_port+(n_end_port - n_start_port))
return l_szRet
end
function exposed_host_exist()
if ( g_port_exposed_host_ip:get_value() ~= "") then
return true
end
return false
end
local ftp_service =
{
description = "FTP-Server",
port = "21",
endport = "21",
fwport = "21",
protocol = "TCP"
}
function write_port_fw_table_content( t_content)
local l_szRet = ""
local ftp_from_internet = box.query("ctlusb:settings/storage-ftp-internet") == "1" or false
if (( #t_content > 0 ) or (exposed_host_exist() == true)) then
for i=1, #t_content do
local rule_change_listener = ""
local rule = g_t_port_fw_List[i]
if ftp_from_internet and rule.port == ftp_service.port and rule.endport == ftp_service.endport and rule.fwport == ftp_service.fwport and rule.protocol == ftp_service.protocol then
rule_change_listener = [[onclick="OnChange_RuleActive(this)"]]
end
local l_Str = [[<tr><td class="c1">]]..elem._checkbox("active_"..tostring(i),"ui_Active_"..tostring(i),"1",(tostring(g_t_port_fw_List[i].activated)=="1"), rule_change_listener)..[[</td>]]
l_Str = l_Str..[[<td class="c2">]]..elem._span(tostring(g_t_port_fw_List[i].description), true, true)..[[</td>]]
l_Str = l_Str..[[<td class="c3">]]..elem._span(tostring(g_t_port_fw_List[i].protocol), true, true)..[[</td>]]
local portValue = port_range( g_t_port_fw_List[i].port, g_t_port_fw_List[i].endport,g_t_port_fw_List[i].port)
l_Str = l_Str..[[<td class="c4">]]..elem._span( portValue, true, true)..[[</td>]]
l_Str = l_Str..[[<td class="c5">]]..elem._span(name_from_ip(tostring(g_t_port_fw_List[i].fwip)), true, true)..[[</td>]]
portValue = port_range( g_t_port_fw_List[i].port, g_t_port_fw_List[i].endport,g_t_port_fw_List[i].fwport)
l_Str = l_Str..[[<td class="c6">]]..elem._span( portValue, true, true)..[[</td>]]
l_Str = l_Str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..g_t_port_fw_List[i]._node, "edit", g_t_port_fw_List[i]._node, [[{?txtIconBtnEdit?}]])..[[</td>]]
l_Str = l_Str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..g_t_port_fw_List[i]._node, "delete_portrule", g_t_port_fw_List[i]._node, [[{?txtIconBtnDelete?}]], [[g_delete_Btn_Msg=true;]])..[[</td>]]
l_Str = l_Str..[[</tr>]]
l_szRet = l_szRet..l_Str
end
if ( exposed_host_exist() == true) then
local l_Str = [[<tr><td class="c1">]]..elem._checkbox("active_exposed","ui_Active_Exposed", "1",(tostring(g_port_is_exposed_host:get_value())=="1"))..[[</td>]]
l_Str = l_Str..[[<td class="c2">]]..elem._span( "Exposed Host", true, true)..[[</td>]]
l_Str = l_Str..[[<td colspan="2" style="text-align:center;">]]..elem._span( "{?4497:37?}", true, true)..[[</td>]]
l_Str = l_Str..[[<td class="c5">]]..elem._span( name_from_ip(tostring(g_port_exposed_host_ip:get_value())), true, true)..[[</td>]]
l_Str = l_Str..[[<td class="c6">]]..elem._span( "", true, true)..[[</td>]]
l_Str = l_Str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_exposed", "edit", "exposed", [[{?txtIconBtnEdit?}]])..[[</td>]]
l_Str = l_Str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_exposed", "delete_portrule", "exposed", [[{?txtIconBtnDelete?}]], [[g_delete_Btn_Msg=true;]])..[[</td>]]
l_Str = l_Str..[[</tr>]]
l_szRet = l_szRet..l_Str
end
else
l_szRet = [[<tr id ="ui_NoRuless"><td colspan="8" style="text-align:center;">{?4497:66?}</td></tr>]]
end
box.out( l_szRet)
end
function write_idg_table_content( t_content)
local l_szRet = ""
if ( #t_content > 0 ) then
for i=1, #t_content do
local l_Str = [[<td class="c1">]]..elem._span(tostring(g_t_idg_fw_List[i].protocol), true, true)..[[</td>]]
l_Str = l_Str..[[<td class="c2">]]..elem._span(tostring(g_t_idg_fw_List[i].port), true, true)..[[</td>]]
l_Str = l_Str..[[<td class="c3">]]..elem._span(tostring(g_t_idg_fw_List[i].fwname), true, true)..[[</td>]]
l_Str = l_Str..[[<td class="c4">]]..elem._span(tostring(g_t_idg_fw_List[i].fwip), true, true)..[[</td>]]
l_Str = l_Str..[[<td class="c5">]]..elem._span(tostring(g_t_idg_fw_List[i].fwport), true, true)..[[</td>]]
l_Str = l_Str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..g_t_idg_fw_List[i]._node, "delete_idg", g_t_idg_fw_List[i]._node, [[{?txtIconBtnDelete?}]], [[g_delete_Btn_Msg=true;]])..[[</td>]]
l_Str = l_Str..[[</tr>]]
l_szRet = l_szRet..l_Str
end
else
l_szRet = [[<tr id ="ui_NoIdgPorts"><td colspan="6" style="text-align:center;">{?4497:121?}</td></tr>]]
end
box.out( l_szRet)
end
if ( next(box.post)) then
local saveset = {}
if ( box.post.apply) then
local l_list_count = tonumber( box.querycount( g_sz_port_fw_ListQuery))
for i=1, l_list_count do
local l_value = "0"
if ((box.post["active_"..tostring(i)]) ~= nil ) then
l_value = "1"
end
cmtable.add_var( saveset, ("forwardrules:settings/rule"..tostring(i-1).."/activated"), l_value)
end
g_port_is_exposed_host:save_value( saveset, box.post.active_exposed and "1" or "0")
if use_upnp_activated:get_value() == "1" then
use_upnp_security_settings:save_check_value( saveset)
if ( use_upnp_security_settings:var_exist() ) then
use_upnp_security_settings:set_value( "1")
else
use_upnp_security_settings:set_value( "0")
end
end
end
if ( box.post.delete_portrule) then
if ( box.post.delete_portrule == "exposed") then
g_port_is_exposed_host:save_value( saveset, "0")
g_port_exposed_host_ip:save_value( saveset, "")
else
cmtable.add_var( saveset, ("forwardrules:command/"..box.post.delete_portrule), "delete")
end
end
if ( box.post.delete_idg) then
cmtable.add_var( saveset, ("igdforwardrules:command/"..box.post.delete_idg), "delete")
end
errcode, errmsg = box.set_config( saveset)
if errcode ~= 0 then
g_errmsg = general.create_error_div(errcode, errmsg)
end
end
init_page_vars()
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#uiPorts {margin: auto; width: 100%;}
#uiPorts td, #uiPorts th {padding: 1px 2px;}
#uiPorts .c1 {text-align: center;}
#uiPorts .c2 {text-align: left;}
#uiPorts .c3 {text-align: center;}
#uiPorts .c4 {text-align: center;}
#uiPorts .c5 {text-align: left;}
#uiPorts .c6 {text-align: center;}
#uiUpnp {margin: auto; width:100%}
#uiUpnp td, #uiUpnp th {padding: 1px 2px;}
#uiUpnp .c1 {text-align: center;}
#uiUpnp .c2 {text-align: center;}
#uiUpnp .c3 {text-align: left;}
#uiUpnp .c4 {text-align: center;}
#uiUpnp .c5 {text-align: center;}
</style>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var g_delete_Btn_Msg = false;
var sort_ports = sorter();
var sort_upnp = sorter();
function init() {
jxl.disableNode( "ui_ShowUpnpControl", "<?lua box.js( use_upnp_activated:get_value()) ?>" == "0");
jxl.display( "ui_ShowUpnpPorts", "<?lua box.js( use_upnp_security_settings:get_value()) ?>" == "1");
}
function OnChange_ChangeUpnpSecurityRules( bChecked) {
}
function OnChange_RuleActive(checkbox) {
alert('{?4497:969?}');
jxl.setChecked(checkbox, false);
}
function On_MainFormSubmit() {
if ( g_delete_Btn_Msg == true) {
if (!confirm( "{?4497:953?}")) {
g_delete_Btn_Msg = false;
return false;
}
}
return true;
}
function initTableSorter() {
sort_ports.init(uiPorts);
sort_ports.sort_table_again(1);
sort_upnp.init(uiUpnp);
sort_upnp.sort_table_again(1);
}
g_ValPage = false;
ready.onReady(initTableSorter);
ready.onReady(val.init(On_MainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="/internet/port_fw.lua" id="uiMainForm" name="main_form">
<p>
{?4497:542?}
</p>
<h4>{?4497:834?}</h4>
<table id="uiPorts" class="zebra">
<tr class="thead">
<th class="c1">{?4497:58?}</th>
<th class="c2 sortable">{?4497:826?}<span class="sort_no">&nbsp;</span></th>
<th class="c3 sortable">{?4497:929?}<span class="sort_no">&nbsp;</span></th>
<th class="c4 sortable">{?4497:266?}<span class="sort_no">&nbsp;</span></th>
<th class="c5 sortable">{?4497:704?}<span class="sort_no">&nbsp;</span></th>
<th class="c6 sortable">{?4497:567?}<span class="sort_no">&nbsp;</span></th>
<th class="buttonrow">&nbsp;</th>
<th class="buttonrow">&nbsp;</th>
</tr>
<?lua
write_port_fw_table_content(g_t_port_fw_List)
?>
</table>
<p class="innerbutton">
<button type="submit" name="new_rule">{?4497:867?}</button>
</p>
<p class="WarnMsgBold" <?lua if ( g_port_is_exposed_host:get_value() =="0") then box.out( [[style="display: none;"]]) end?>>
{?4497:378?}<br>
{?4497:342?}
</p>
<hr>
<?lua
box.out([[<div id="ui_ShowUpnpControl">]])
box.out( [[<div>]])
box.out( elem._checkbox( use_upnp_security_settings:get_var_name(), use_upnp_security_settings:get_var_name_js(), use_upnp_security_settings:get_value(), (use_upnp_security_settings:get_value() == "1"), [[onclick="OnChange_ChangeUpnpSecurityRules(this.checked)"]]))
box.out( [[&nbsp;]])
box.out( elem._label( use_upnp_security_settings:get_var_name_js(), "Label"..use_upnp_security_settings:get_var_name_js(), [[{?4497:925?}]]))
box.out([[<p class="formular">]])
box.html([[{?4497:807?}]])
box.out([[</p>]])
box.out( [[</div>]])
box.out([[</div>]])
if use_upnp_activated:get_value() == "0" then
box.out( [[<p>]])
box.out( [[<span class="hintMsg">]]..box.tohtml([[{?txtHinweis?}]])..[[</span>]])
box.out(general.sprintf(
[[{?4497:315?}]],
[[<a href=']]..href.get("/net/network_settings.lua")..[['>]], [[</a>]]
))
box.out( [[</p>]])
end
?>
<div id="ui_ShowUpnpPorts">
<p>{?4497:718?}</p>
<h4>{?4497:445?}</h4>
<table id="uiUpnp" class="zebra">
<tr class="thead">
<th class="c1 sortable">{?4497:149?}<span class="sort_no">&nbsp;</span></th>
<th class="c2 sortable">{?4497:407?}<span class="sort_no">&nbsp;</span></th>
<th class="c3 sortable">{?4497:908?}<span class="sort_no">&nbsp;</span></th>
<th class="c4 sortable">{?4497:281?}<span class="sort_no">&nbsp;</span></th>
<th class="c5 sortable">{?4497:350?}<span class="sort_no">&nbsp;</span></th>
<th class="buttonrow"> </th>
</tr>
<?lua
write_idg_table_content( g_t_idg_fw_List)
?>
</table>
</div>
<?lua
if (g_errmsg~="") then
box.out(g_errmsg)
end
?>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
<button type="submit" name="update">{?4497:395?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
