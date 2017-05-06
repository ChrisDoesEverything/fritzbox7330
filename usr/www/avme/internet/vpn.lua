<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_vpn.html"
dofile("../templates/global_lua.lua")
g_page_needs_js=true
require("cmtable")
require("val")
require("boxvars2")
require("elem")
require("general")
require("http")
g_back_to_page = http.get_back_to_page( "/internet/vpn.lua" )
g_oem = box.query("env:status/OEM")
wlan_enabled = boxvars2.c_boxvars:init( { sz_query = "wlan:settings/ap_enabled"} )
wlan_encryption = boxvars2.c_boxvars:init( { sz_query = "wlan:settings/encryption"} )
vpn_file = boxvars2.c_boxvars:init( { sz_query = "", sz_value = "", sz_var_name = "VpnImportFile", sz_var_name_js = "uiView_VpnImportFile"} )
vpn_use_pw = boxvars2.c_boxvars:init( { sz_query = "", sz_value = "0", sz_var_name = "vpn_use_pw", sz_var_name_js = "uiView_VpnUsePw"} )
vpn_pw = boxvars2.c_boxvars:init( { sz_query = "", sz_value = "", sz_var_name = "vpn_pw", sz_var_name_js = "uiView_VpnPw"} )
local szListQuery_VpnValues = [[vpn:settings/connection/list(activated,name,deletable,editable,state,remote_ip,src,dst,connected_since,settings)]]
g_t_vpn_list = general.listquery(szListQuery_VpnValues)
function init_page_vars()
end
function split(_str, _sep)
local result = {}
if not _sep or _sep == "" then
for i = 1, #str do
table.insert(result, _str:sub(i,i))
end
return result
end
local curr = 1
local left, right = _str:find(_sep, curr, true)
while left do
table.insert(result, _str:sub(curr, left-1))
curr = right + 1
left, right = _str:find(_sep, curr, true)
end
table.insert(result, _str:sub(curr))
return result
end
function is_not_safe()
if (config.WLAN) then
if (( wlan_enabled:get_value() == "0") or
(( wlan_enabled:get_value() == "1") and
(( wlan_encryption:get_value() == "2") or (wlan_encryption:get_value() == "3") or (wlan_encryption:get_value() == "4")))) then
return false
end
return true
end
return false
end
function is_safe()
return not is_not_safe()
end
function write_table_header()
local l_szRet = [[<tr class="thead">]]
l_szRet = l_szRet..[[<th class="active">{?352:926?}</th>]]
l_szRet = l_szRet..[[<th class="name sortable">{?352:164?}<span class="sort_no">&nbsp;</span></th>]]
l_szRet = l_szRet..[[<th class="remote_ip sortable">{?352:713?}<br />{?352:887?}<span class="sort_no">&nbsp;</span></th>]]
l_szRet = l_szRet..[[<th class="src sortable">{?352:95?}<span class="sort_no">&nbsp;</span></th>]]
l_szRet = l_szRet..[[<th class="dst sortable">{?352:388?}<span class="sort_no">&nbsp;</span></th>]]
l_szRet = l_szRet..[[<th class="state sortable sort_by_class">{?352:477?}<span class="sort_no">&nbsp;</span></th>]]
l_szRet = l_szRet..[[<th class="button_row">&nbsp;</th>]]
l_szRet = l_szRet..[[<th class="button_row">&nbsp;</th>]]
l_szRet = l_szRet..[[</tr>]]
box.out( l_szRet)
end
function write_table_content( _t_content)
local l_szRet = ""
if ( #_t_content > 0 ) then
for i=1, #_t_content do
local l_Str = [[<tr><td class="active">]]..elem._checkbox("active_"..tostring(i),"ui_Active_"..tostring(i),"1",(tostring(_t_content[i].activated)=="1"))..[[</td>]]
l_Str = l_Str..[[<td class="name">]]..elem._span(tostring(_t_content[i].name), true, true)..[[</td>]]
l_Str = l_Str..[[<td class="remote_ip">]]..elem._span(tostring(_t_content[i].remote_ip), true, true)..[[</td>]]
l_Str = l_Str..[[<td class="src">]]..elem._span(tostring(_t_content[i].src), true, true)..[[</td>]]
l_Str = l_Str..[[<td class="dst">]]..elem._span(tostring(_t_content[i].dst), true, true)..[[</td>]]
l_Str = l_Str..led_state(_t_content[i].state)
l_Str = l_Str..[[<td class="button_row">]]
l_Str = l_Str..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_".._t_content[i]._node, "edit", _t_content[i]._node, [[{?txtIconBtnEdit?}]],"",_t_content[i].editable == "0")
l_Str = l_Str..[[</td>]]
l_Str = l_Str..[[<td class="button_row">]]
if (_t_content[i].deletable == "1") then
l_Str = l_Str..general.get_icon_button("/css/default/images/loeschen.gif", "delete_".._t_content[i]._node, "delete", _t_content[i]._node, [[{?txtIconBtnDelete?}]],"OnDelete(this.value)",_t_content[i].deletable == "0")
end
l_Str = l_Str..[[</td>]]
l_Str = l_Str..[[</tr>]]
l_szRet = l_szRet..l_Str
end
else
l_szRet = [[<tr><td colspan="8" style="text-align:center;">{?352:752?}</td></tr>]]
end
box.out( l_szRet)
end
function write_no_vpn_msg()
local l_szRet = ""
l_szRet = l_szRet..[[<p>{?352:921?}</p>]]
box.out( l_szRet)
end
function led_state( _sz_state)
if ( _sz_state == "ready") then
return [[<td class="led_green"></td>]]
end
return [[<td class="led_gray"></td>]]
end
g_val = {}
if ( next(box.post)) then
local saveset = {}
if (box.post.create_new_vpn) then
http.redirect(href.get("/internet/vpn_edit.lua", http.url_param("id", "new")))
end
if ( box.post.apply) then
for i=1, #g_t_vpn_list do
local l_value = "0"
if ((box.post["active_"..tostring(i)]) ~= nil ) then
l_value = "1"
end
cmtable.add_var( saveset, ("vpn:settings/"..tostring(g_t_vpn_list[i]._node).."/activated"), l_value)
g_t_vpn_list[i].activated = l_value
end
errcode, errmsg = box.set_config( saveset)
if errcode ~= 0 then
g_val.errmsg = errmsg
end
end
if (box.post.edit) then
http.redirect(href.get("/internet/vpn_edit.lua", http.url_param("id", box.post.edit)))
end
if ( box.post.delete) then
cmtable.add_var( saveset, ("vpn:command/"..box.post.delete), "delete")
errcode, errmsg = box.set_config( saveset)
if errcode == 0 then
http.redirect(href.get(g_back_to_page))
else
g_val.errmsg = errmsg
end
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/vpn.css">
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var g_msgTextNoFile = "{?352:428?}";
var g_mldPfad = "{?352:594?}";
var g_mldImport = "{?352:864?}";
var g_txtDelete1 = "{?352:114?}";
var g_mldLeeresKennwort = "{?352:57?}";
var g_mldKennwortCheck = "{?352:209?}";
var sort = sorter();
var g_is_safe = <?lua box.js(is_safe()) ?>
<?lua
val.write_js_error_strings()
?>
function init() {
var form = jxl.get("uiMainForm");
if (form)
{
form.onsubmit = On_MainFormSubmit;
}
jxl.addEventHandler( "uiApply", "click", function(){ val.active = true; });
jxl.addEventHandler( "ui_DoImport_Vpn", "click", function(){ val.active = true; });
}
function OnDelete(val)
{
if (!confirm("{?352:849?}"))
{
return false;
}
return true;
}
function On_MainFormSubmit()
{
}
function initTableSorter() {
if (g_is_safe)
{
sort.init("uiVpnList");
sort.sort_table_again(1);
}
}
g_ValPage = false;
ready.onReady(initTableSorter);
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<p>
<?lua
if config.language_is_de then
box.out( [[{?352:872?}]])
else
box.out( [[{?352:861?}]])
end
?>
</p>
<?lua
box.out( [[<form method="POST" action="/internet/vpn.lua" id="uiMainForm">]])
if is_not_safe() then
write_no_vpn_msg()
else
box.out( [[<h4>{?352:322?}</h4>]])
box.out( [[<table id="uiVpnList" class="zebra">]])
write_table_header()
write_table_content(g_t_vpn_list)
box.out( [[</table>]])
box.out( [[<p class="innerbutton"><button type="submit" id="ui_Create_New_Vpn" type="button" name="create_new_vpn" >{?352:211?}</button></p>]])
end
?>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button type="submit" name="refresh">{?txtRefresh?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
