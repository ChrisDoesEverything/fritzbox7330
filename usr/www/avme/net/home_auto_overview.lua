<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_smart_home_overview.html"
g_page_needs_js=true
dofile("../templates/global_lua.lua")
require("cmtable")
require("general")
require("elem")
require("bit")
require("string")
require("ha_func_lib")
require("libaha")
require("http")
require("href")
g_t_home_automation_list = {}
g_t_group_name_list = {}
g_use_broadcast = false
g_show_broadcast = false
g_max_group_count=0
function init_page_vars()
g_t_home_automation_list = aha.GetDeviceList()
g_t_group_name_list = ha_func_lib.initialize_group_name_list( g_t_home_automation_list, false)
end
function get_class(switch_on)
if (switch_on=="1") then
return "on"
end
return "off"
end
function write_table_content_entry_of( device_entry)
local l_Str = [[<tr id="uiView_SHDevice_]]..tostring(device_entry.ID)..[[" >]]
local szImageSource, szTitelText, szAltText = ha_func_lib.get_connect_state( (tostring(device_entry.Valid) == "2"))
l_Str = l_Str..[[<td class="c1">]]..elem._image( "uiDeviceConnectState_"..tostring(device_entry.ID), szImageSource, szTitelText, szAltText, [[]],true)..[[</td>]]
l_Str = l_Str..[[<td class="c2">]]..elem._span( tostring(device_entry.Name),true,true)..[[</td>]]
if ( ha_func_lib.can_temperature( device_entry.FunctionBitMask)) then
local l_temperature = aha.GetTemperature( tonumber(device_entry.ID))
local n_temperature = l_temperature.Celsius/10
local sz_temperature = ha_func_lib.value_as_float( n_temperature, 1)
if(l_temperature.Celsius == -9999) then
sz_temperature = ""
else
sz_temperature = sz_temperature..[[ °C]]
end
l_Str = l_Str..[[<td class="c3">]]..elem._span_plusplus( [[uiView_Temperature_]]..tostring(device_entry.ID), sz_temperature, true, true, [[pd_r10]])..[[</td>]]
else
l_Str = l_Str..[[<td class="c3">]]..elem._span( [[]], false, true)..[[</td>]]
end
l_timer_mode = [[ ]]
if ( ha_func_lib.is_outlet( device_entry.FunctionBitMask)) then
local l_device_timer_state = aha.GetSwitchTimer( tonumber(device_entry.ID))
local l_b_value, l_sz_name, l_sz_value = ha_func_lib.is_timer_active( l_device_timer_state)
local l_b_value_standby, l_n_power,l_n_duration= ha_func_lib.get_standby_state( tonumber(device_entry.ID))
l_timer_mode = [[{?645:892?}]]
if ((l_b_value == true) or ( l_b_value_standby == true)) then
l_timer_mode = [[{?645:657?}]]
end
end
l_Str = l_Str..[[<td class="c4">]]..elem._span( l_timer_mode, true, true)..[[</td>]]
if ( ha_func_lib.is_outlet( device_entry.FunctionBitMask)) then
local l_switch = ha_func_lib.get_switch( device_entry.ID)
l_Str = l_Str..[[<td class="c5 ]]..get_class(l_switch.SwitchOn)..[[">]]..ha_func_lib.get_clickable_image(device_entry.ID, i, l_switch.SwitchOn, l_switch.SwitchLock)..[[</td>]]
else
l_Str = l_Str..[[<td class="c5"> </td>]]
-- l_Str = l_Str..[[<td class="c5">]]..elem._span(tostring(device_entry.Manufacturer), true, true)..[[</td>]]
end
l_Str = l_Str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/schraubschluessel.png", "edit_"..device_entry.ID, "edit", device_entry.ID, [[{?645:365?}]])..[[</td>]]
if ( ha_func_lib.is_outlet( device_entry.FunctionBitMask)) then
l_Str = l_Str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/uhr.png", "date_"..device_entry.ID, "timer", device_entry.ID, [[{?645:323?}]])..[[</td>]]
else
l_Str = l_Str..[[<td class="buttonrow" style="display:inline-block; height:24px;">&nbsp;</td>]]
end
if ( ha_func_lib.has_energy_monitor( device_entry.FunctionBitMask)) then
l_Str = l_Str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/energie.png", "power_"..device_entry.ID, "power", device_entry.ID, [[{?645:572?}]])..[[</td>]]
else
l_Str = l_Str..[[<td class="buttonrow" style="height:24px;">&nbsp;</td>]]
end
if ( ha_func_lib.is_unerasable_device( device_entry.ID, device_entry.Valid ) == false) then
local l_onclick = [[onClick_EntryDelConfirmation(']]..box.tojs(box.tohtml(tostring(device_entry.Name)))..[[');]]
l_Str = l_Str..[[<td id="uiView_SHDevice_BtnDelete_]]..tostring(i)..[[" class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..device_entry.ID, "delete_device", device_entry.ID, [[{?645:954?}]], l_onclick)..[[</td>]]
else
l_Str = l_Str..[[<td class="buttonrow" style="height:24px;">&nbsp;</td>]]
end
l_Str = l_Str..[[</tr>]]
return l_Str
end
function write_group_switch_of( group_id)
local l_group = aha.GetGroup( tonumber( group_id))
local l_szRet = [[<tr class="separator">]]
l_szRet = l_szRet..[[<td class="c1">{?645:716?}</td>]]
l_szRet = l_szRet..[[<td class="c2">{?645:772?}</td>]]
l_szRet = l_szRet..[[<td class="c3">{?645:765?}</td>]]
l_szRet = l_szRet..[[<td class="c4">{?645:625?}</td>]]
local l_SwitchState = ha_func_lib.get_switch_state( tonumber(l_group.ID))
l_szRet = l_szRet..[[<td class="c5 ]]..get_class(l_SwitchState)..[[">]]..ha_func_lib.get_clickable_image( l_group.ID, l_group.ID, l_SwitchState)..[[</td>]]
l_szRet = l_szRet..[[<td class="buttonrow">&nbsp;</td>]]
l_szRet = l_szRet..[[<td class="buttonrow" style="height:24px;">&nbsp;</td>]]
l_szRet = l_szRet..[[<td class="buttonrow" style="height:24px;">&nbsp;</td>]]
l_szRet = l_szRet..[[<td class="buttonrow" style="height:24px;">&nbsp;</td>]]
l_szRet = l_szRet..[[</tr>]]
return l_szRet
end
function write_table_header()
local l_szRet = [[<tr class="thead">]]
l_szRet = l_szRet..[[<th class="sortable sort_by_class c1">{?645:530?}<span class="sort_no">&nbsp;</span></th>]]
l_szRet = l_szRet..[[<th class="sortable c2">{?645:190?}<span class="sort_no">&nbsp;</span></th>]]
l_szRet = l_szRet..[[<th class="sortable c3">{?645:620?}<span class="sort_no">&nbsp;</span></th>]]
l_szRet = l_szRet..[[<th class="sortable c4">{?645:195?}<span class="sort_no">&nbsp;</span></th>]]
l_szRet = l_szRet..[[<th class="sortable sort_by_class c5">{?645:910?}<span class="sort_no">&nbsp;</span></th>]]
l_szRet = l_szRet..[[<th class="buttonrow">&nbsp;</th>]]
l_szRet = l_szRet..[[<th class="buttonrow">&nbsp;</th>]]
l_szRet = l_szRet..[[<th class="buttonrow">&nbsp;</th>]]
l_szRet = l_szRet..[[<th class="buttonrow">&nbsp;</th>]]
l_szRet = l_szRet..[[</tr>]]
return l_szRet
end
function write_table_content( t_content, t_group_list)
local l_szRet = ""
if ( t_content ~= nil and #t_content > 0 ) then
local l_no_devices_shown = true
for i=1, #t_content do
if ( not(( ha_func_lib.is_repeater_only(t_content[i].FunctionBitMask)) or
( ha_func_lib.is_group_member( g_t_group_name_list, t_content[i].GroupHash)) or
( ha_func_lib.is_virtual_group_device(t_content[i].DeviceType, t_content[i].FunctionBitMask))) ) then
l_no_devices_shown = false
l_szRet = l_szRet..write_table_content_entry_of( t_content[i])
end
end
if ( l_no_devices_shown == true) then
if ((t_group_list ~= nil) and ( #t_group_list > 0)) then
l_szRet = [[<tr id="ui_NoDevices"><td colspan="9" class="ta_c">{?645:736?}</td></tr>]]
else
l_szRet = [[<tr id="ui_NoDevices"><td colspan="9" class="ta_c">{?645:735?}</td></tr>]]
end
end
else
l_szRet = [[<tr id="ui_NoDevices"><td colspan="9" class="ta_c">{?645:296?}</td></tr>]]
end
return l_szRet
end
function write_group_table_content_of( sz_current_group_hash, t_content)
local l_szRet = ""
if ((t_content ~= nil) and (#t_content > 0 )) then
for i=1, #t_content do
if ( ( ha_func_lib.is_group_member_of( sz_current_group_hash, t_content[i].GroupHash)) and
( not( ha_func_lib.is_virtual_group_device(t_content[i].DeviceType, t_content[i].FunctionBitMask)))) then
l_szRet = l_szRet..write_table_content_entry_of( t_content[i])
end
end
end
return l_szRet
end
function is_dect_repeater_enabled()
return (box.query("dect:settings/DECTRepeaterEnabled") == "1")
end
function reorg_device_list( deleted_device)
if ( g_t_home_automation_list~=nil and #g_t_home_automation_list > 0 ) then
for i=1, #g_t_home_automation_list do
if ( tostring( deleted_device) == tostring(g_t_home_automation_list[i].ID) ) then
table.remove( g_t_home_automation_list, i)
break;
end
end
g_t_group_name_list = ha_func_lib.initialize_group_name_list( g_t_home_automation_list, false)
end
end
init_page_vars()
if next(box.post) then
if box.post.new_group then
local l_szUrl = [[/net/home_auto_group_config.lua?device=&state=new]]
http.redirect( l_szUrl)
end
if box.post.edit then
local l_szUrl = [[/net/home_auto_edit_view.lua?device=]]..box.post.edit
http.redirect( l_szUrl)
end
if box.post.timer then
local l_szUrl = [[/net/home_auto_timer_view.lua?device=]]..box.post.timer
http.redirect( l_szUrl)
end
if box.post.power then
local l_szUrl = [[/net/home_auto_energy_view.lua?device=]]..box.post.power..[[&sub_tab=watt]]
http.redirect( l_szUrl)
end
end
function does_ipui_rfpi_match(rfpi, ipui)
if ( rfpi == nil or ipui == nil or
rfpi == "" or ipui == "") then
return false
end
local iss = string.split(ipui, " ")
local ipui1 = tonumber(iss[1])
local ipui2basic = tonumber(iss[2])
local ipui2 = 0
if ipui2basic >= 1047808 then
ipui2 = bit.maskand(ipui2basic * 8, tonumber("0x07FFFF"))
else
ipui2 = bit.maskand(ipui2basic * 8, tonumber("0x0FFFFF"))
end
local rfpi1 = tonumber("0x" .. string.sub(rfpi, 0,5))
local rfpi2 = tonumber("0x" .. string.sub(rfpi, -5))
return (ipui1 == rfpi1 and ipui2 == rfpi2)
end
if ( next(box.post)) then
local saveset = {}
if ( box.post.apply) then
local l_bSave = false
end
if ( box.post.delete_device) then
local l_t_timer_state = aha.GetSwitchTimer( tonumber( box.post.delete_device) )
local l_b_value, l_sz_name, l_sz_value = ha_func_lib.is_timer_active( l_t_timer_state )
if ((l_b_value == true) and (l_sz_name == "calendar")) then
local l_calender_name = ha_func_lib.get_calendar_name( tonumber( box.post.delete_device) )
local l_b_exist, l_node, l_devices = ha_func_lib.calendar_always_exist( tostring(l_calender_name) )
if ( l_b_exist == true ) then
local sz_to_find = tostring(box.post.delete_device)..[[;]]
local l_newer_devices, n_how_many = string.gsub( l_devices, sz_to_find, [[]])
if ( l_newer_devices == [[]] ) then
cmtable.add_var( saveset, [[oncal:settings/]]..l_node..[[/enabled]], tonumber(0))
end
cmtable.add_var( saveset, [[oncal:settings/]]..l_node..[[/deviceid]], l_newer_devices)
end
end
local device = aha.GetDevice(tonumber(box.post.delete_device))
if (device~=nil and ha_func_lib.is_valid_uleid(device.ID)) then
if (ha_func_lib.is_repeater(device.FunctionBitMask)) then
local ctlmgr_save = {}
local repeater_list = general.listquery("dect:settings/Repeater/list(RFPI)")
if ((repeater_list ~= nil) and (#repeater_list > 0)) then
for i,elem in ipairs(repeater_list) do
if "" ~= elem.RFPI and does_ipui_rfpi_match(elem.RFPI, device.Identifyer) then
cmtable.add_var(ctlmgr_save, "dect:command/UnsubscribeRepeater", tonumber(i))
end
end
end
local err,msg = box.set_config(ctlmgr_save)
end
aha.DeleteDevice(tonumber(device.ID))
end
end
if ( box.post.new_device) then
cmtable.add_var( saveset, [[dect:command/StartULESubscription]], "1")
end
g_errcode, g_errmsg = box.set_config( saveset)
if g_errcode == 0 then
if ( box.post.delete_device) then
reorg_device_list( box.post.delete_device)
end
if ( box.post.new_device) then
http.redirect( [[/net/home_auto_registering.lua]])
end
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
table {
margin: auto;
width: 100%;
margin-bottom:10px;
table-layout:fixed
}
td, th {
padding: 1px 2px;
overflow: hidden;
}
tr.separator td.c2 {
text-align: left;
width: 200px;
}
.c1 {
text-align: center; width: 76px;
}
.c2 {
text-align: left; width: 200px;
}
.c3 {
text-align: right; width: 105px;
}
.c4 {
text-align: left; width: 77px;
}
.c5 {
text-align: center;
width: 60px;
}
.c6 {
text-align: center;
}
.mt20 {
margin-top: 20px;
}
.ta_c {
text-align: center;
}
.pd_r10 {
padding-right: 20px;
}
</style>
<?include "templates/page_head.html" ?>
<form name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<?lua
if ( is_dect_repeater_enabled()) then
box.out( [[<h4>{?645:19?}</h4>]])
box.out( [[<p>{?645:192?}</p>]])
end
box.out( [[<div id="uiShow_SmartHome_View">]])
box.out( [[<p>{?645:642?}</p>]])
box.out( [[<hr>]])
box.out( [[<h4>{?645:603?}</h4>]] )
if ( (g_t_group_name_list ~= nil ) and ( #g_t_group_name_list > 0)) then
box.out( [[<p>{?645:7331?}</p>]] )
end
box.out( [[<table id="tHAdevices" name="new_paired_devices" class="zebra">]])
box.out( write_table_header())
box.out( write_table_content( g_t_home_automation_list, g_t_group_name_list))
box.out( [[</table>]])
if ( (g_t_group_name_list ~= nil ) and ( #g_t_group_name_list > 0)) then
for i=1, #g_t_group_name_list do
if ( g_t_group_name_list[i].GroupCount > 0) then
g_max_group_count=g_max_group_count+1
box.out( [[<p>{?645:996?}]]..tostring(g_t_group_name_list[i].GroupName)..[["</p>]] )
box.out( [[<table id="tHAdevicesGroup]]..tostring(i)..[[" name="paired_group_devices_]]..tostring(g_t_group_name_list[i].GroupName)..[[" class="zebra">]])
box.out( write_table_header())
box.out( write_group_switch_of( g_t_group_name_list[i].ID))
box.out( write_group_table_content_of( g_t_group_name_list[i].GroupHash, g_t_home_automation_list))
box.out( [[</table>]])
end
end
end
if ( not(is_dect_repeater_enabled())) then
box.out( [[<div class="btn_form">]])
box.out( [[<button type="submit" name="new_device">{?645:8?}</button>]])
box.out( [[</div>]])
end
box.out( [[</div>]])
if (g_show_broadcast) then
box.out( [[<hr>]])
box.out( [[<h4>{?645:699?}</h4>]])
box.out( [[<div class="formular">]])
box.out( elem._checkbox( "use_broadcast", "uiView_UseBroadcast", "1", (g_use_broadcast)))
box.out( [[&nbsp;]])
box.out(elem._label("uiView_UseBroadcast", "uiView_UseBroadcastLabel",[[{?645:432?}]]))
box.out( [[<p class="form_checkbox_explain">{?645:436?}</p>]])
box.out( [[</div>]])
end
box.out([[<input type="hidden" name="sid" value="]], box.tohtml(box.glob.sid), [[">]])
if (g_show_broadcast) then
box.out([[<div id="btn_form_foot">]])
box.out([[<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>]])
box.out([[<button type="submit" name="cancel" id="uiCancel">{?txtCancel?}</button>]])
box.out([[</div>]])
end
?>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ha_sets.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=[]
var g_n_TO_All_States = 37000; // alle 37 sec.
var g_n_ReceiveCount = 0;
var g_request_Counter = 0;
var g_b_LockOutletSwitch = false;
var g_TO_Switch_Outlet = 1000; // alle 1 sec.
var json = makeJSONParser();
var sidParam = buildUrlParam( "sid", "<?lua box.js(box.glob.sid) ?>");
function GetAllOutletStates() {
var url = encodeURI("/net/home_auto_query.lua");
url += "?" + sidParam;
url += "&" + buildUrlParam( "command", "AllOutletStates");
ajaxGet( url, cb_Receive_All_Outlet_States)
}
function cb_Receive_All_Outlet_States(xhr) {
var response = json(xhr.responseText || "null");
if ( response && (response.RequestResult != "0")) {
var nOutletCount = response.Outlet_count;
for ( var i = 1; i <= nOutletCount; i++) {
if ( response["DeviceConnectState_"+String(i)] != "") {
ha_sets.setConnectStateOf( response["DeviceID_"+String(i)], response["DeviceConnectState_"+String(i)] );
}
if ( response["DeviceSwitchState_"+String(i)] != "") {
ha_sets.setOutletSwitchOf( response["DeviceID_"+String(i)], response["DeviceSwitchState_"+String(i)], response["DeviceSwitchLock_"+String(i)] );
}
if ( response["DeviceTemp_"+String(i)] != "") {
ha_sets.setTemperature( response["DeviceID_"+String(i)], Number( response["DeviceTemp_"+String(i)]) );
}
}
if ( g_n_ReceiveCount > 0) {
g_n_TO_All_States = g_n_TO_All_States + 5000;
g_n_ReceiveCount--;
if ( g_n_ReceiveCount < 3) {
g_b_LockOutletSwitch = false;
}
} else {
g_n_TO_All_States = 37000;
g_n_ReceiveCount = 0;
g_b_LockOutletSwitch = false;
}
}
setTimeout( "GetAllOutletStates()", g_n_TO_All_States);
}
function OnClick_ImageSwitch( szID, nIdx, szLock) {
if ( true == g_b_LockOutletSwitch || "7" == szLock ) {
return;
}
var szValueToSet = "1";
if ( jxl.getValue( "uiView_ImageSwitch_"+szID) == "1") {
szValueToSet = "0";
}
var url = encodeURI("/net/home_auto_query.lua");
var szData = sidParam;
szData += "&" + buildUrlParam( "command", "SwitchOnOff");
szData += "&" + buildUrlParam( "id", szID);
szData += "&" + buildUrlParam( "value_to_set", szValueToSet);
ajaxPost( url, szData, cb_SwitchChanging)
g_b_LockOutletSwitch = true;
}
function cb_SwitchChanging(xhr) {
var response = json(xhr.responseText || "null");
if ( response && (response.RequestResult != "0")) {
if ( g_request_Counter == 0) {
ha_sets.setOutletSwitchOf( response.DeviceID, response.ValueToSet);
}
if ( g_request_Counter > 10) {
ha_sets.setOutletSwitchOf( response.DeviceID, response.Value);
g_request_Counter = 0;
g_b_LockOutletSwitch = false;
} else {
if ( response.Value != response.ValueToSet) {
setTimeout( "VerifySwitchState("+response.DeviceID+", "+response.ValueToSet+")", g_TO_Switch_Outlet);
g_request_Counter++;
} else {
g_request_Counter = 0;
g_b_LockOutletSwitch = false;
}
}
if ((Number( response.DeviceID) >= 900) && ( Number( response.DeviceID) <= 999)) {
g_n_TO_All_States = 5000;
g_n_ReceiveCount = 5;
GetAllOutletStates();
}
}
}
function VerifySwitchState( szDeviceID, szValueToSet) {
var url = encodeURI("/net/home_auto_query.lua");
url += "?" + sidParam;
url += "&" + buildUrlParam( "command", "SwitchOnOff");
url += "&" + buildUrlParam( "value_to_set", String(szValueToSet));
url += "&" + buildUrlParam( "id", szDeviceID);
ajaxGet( url, cb_SwitchChanging)
}
function onEditDevSubmit() {
}
function onClick_EntryDelConfirmation( name) {
return confirm('{?645:905?} "'+name+'" {?645:141?}');
}
function init() {
<?lua
if ( g_t_home_automation_list~=nil and #g_t_home_automation_list > 0 ) then
for i=1, #g_t_home_automation_list do
if ( is_dect_repeater_enabled() and
( not( ha_func_lib.is_repeater_only( g_t_home_automation_list[i].FunctionBitMask)) ) and
( ha_func_lib.is_local( g_t_home_automation_list[i].ID)) ) then
box.out( [[ jxl.disableNode( "uiView_SHDevice_]]..tostring(i)..[[", true); ]])
box.out( [[ jxl.disableNode( "uiView_SHDevice_BtnDelete_]]..tostring(i)..[[", false); ]])
end
end
end
?>
setTimeout( "GetAllOutletStates()", g_n_TO_All_States);
}
function initTableSorter() {
var max_groups=<?lua box.js(g_max_group_count) ?>;
sort[0]=sorter();
sort[0].init(tHAdevices);
sort[0].sort_table(0);
for (var i=1;i<=max_groups;i++)
{
var obj=jxl.get("tHAdevicesGroup"+i)
if (obj)
{
sort[i]=sorter();
sort[i].init(obj);
sort[i].sort_table(0);
}
}
}
ready.onReady(initTableSorter);
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
