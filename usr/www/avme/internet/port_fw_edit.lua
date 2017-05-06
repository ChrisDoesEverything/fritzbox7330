<?lua
g_page_type = "all"
g_page_title = [[{?4959:832?}]]
g_page_help = "hilfe_neueportfreigabe"
g_menu_active_page = "/internet/port_fw.lua"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("boxvars2")
require("elem")
require("general")
g_page_needs_js = true
g_back_to_page = [[/internet/port_fw.lua]]
if (next(box.post) and (box.post.cancel)) then
http.redirect(g_back_to_page)
end
g_errcode = 0
g_errmsg = [[ERROR: Es ist ein Fehler beim Übernehmen der Daten aufgetreten. Die aktuellen Daten dieser Seite wurden nicht gespeichert.]]
g_sz_text_userdefined = [[{?4959:110?}]]
g_b_is_new = false
g_b_was_exposed_host = false
g_current_rule = nil
g_rule_active = nil
g_rule_description = nil
g_rule_protocol = nil
g_rule_port = nil
g_rule_endport = nil
g_rule_fw_port = nil
g_rule_fw_ip = nil
g_ftp_from_internet = false
g_rule_exposed_host = nil
g_t_app_names_list = {}
g_t_service_settings = { {description=[[HTTP-Server]], protocol=[[TCP]], port=[[80]], endport=[[80]], fwport=[[80]]},
{description=[[eMule TCP]], protocol=[[TCP]], port=[[4662]], endport=[[4662]], fwport=[[4662]]},
{description=[[eMule UDP]], protocol=[[UDP]], port=[[4672]], endport=[[4672]], fwport=[[4672]]},
{description=[[MS Remotedesktop]], protocol=[[UDP]], port=[[3389]], endport=[[3389]], fwport=[[3389]]}
}
g_t_protocol_list = { {[[TCP]], [[TCP]]},
{[[UDP]], [[UDP]]},
{[[ESP]], [[ESP]]},
{[[GRE]], [[GRE]]}
}
g_t_lan_device_list = {}
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
function get_app_name_list()
table.insert( g_t_app_names_list, { [[HTTP-Server]], [[{?4959:855?}]]} )
table.insert( g_t_app_names_list, { [[eMule TCP]], [[{?4959:255?}]]} )
table.insert( g_t_app_names_list, { [[eMule UDP]], [[{?4959:218?}]]} )
table.insert( g_t_app_names_list, { [[MS Remotedesktop]], [[{?4959:889?}]]} )
table.insert( g_t_app_names_list, { [[other]], [[{?4959:771?}]]} )
if ( ( not( exposed_host_exist())) or ( ( exposed_host_exist()) and ( g_b_was_exposed_host == true))) then
table.insert( g_t_app_names_list, { [[exposed]], [[{?4959:38?}]]} )
end
end
function get_lan_device_list()
local l_t_landevices = general.listquery( [[landevice:settings/landevice/list(name,ip,ipv6addrs,guest)]])
for i=1, #l_t_landevices do
if l_t_landevices[i].ip and l_t_landevices[i].ip ~= "" and l_t_landevices[i].guest=="0" then
local l_t_entry = {}
local l_sz_firstentry = l_t_landevices[i].ip.."#"..l_t_landevices[i].ipv6addrs
table.insert( l_t_entry, l_sz_firstentry)
table.insert( l_t_entry, l_t_landevices[i].name)
table.insert( g_t_lan_device_list, l_t_entry)
end
end
table.insert( g_t_lan_device_list, {[[manuell#manuell]],[[{?4959:278?}]]})
end
function exposed_host_exist()
if ( g_rule_exposed_host:get_value() ~= "") then
return true
end
return false
end
function get_selected_value(description, port, endport, fwport, protocol)
local sz_value = "other"
if ( g_b_was_exposed_host == true) then
sz_value = [[exposed]]
else
for i, elem in ipairs(g_t_service_settings) do
if (elem.description == description and elem.port == port and elem.endport == endport and elem.fwport == fwport and elem.protocol == protocol) then
sz_value = description
end
end
end
return sz_value
end
function get_selected_lan_device( sz_value)
if ( g_b_was_exposed_host == true) then
sz_value = g_rule_exposed_host:get_value()
end
for i=1, #g_t_lan_device_list do
local option_value = g_t_lan_device_list[i][1]
if (option_value) then
local nPos = string.find( option_value, "#")
local ipv4 = string.sub( option_value, 1, (nPos-1))
local ipv6 = string.sub( option_value, (nPos+1), #option_value)
if (ipv4 == sz_value) then
return option_value
end
end
end
return "manuell#manuell"
end
function get_ip_from_lan_device( sz_value)
if sz_value then
local nPos = string.find( sz_value, "#")
local ipv4 = string.sub( sz_value, 1, (nPos-1))
local ipv6 = string.sub( sz_value, (nPos+1), #sz_value)
if ( ipv4 ~= "") then
return ipv4
end
end
return ""
end
function get_current_ip_address( sz_ip_value)
if ( g_b_was_exposed_host == true) then
sz_ip_value = g_rule_exposed_host:get_value()
end
return sz_ip_value
end
function init_page_vars( sz_rule)
g_ftp_from_internet = box.query("ctlusb:settings/storage-ftp-internet") == "1"
if not g_ftp_from_internet then
table.insert(g_t_service_settings, 1, {description=[[FTP-Server]], protocol=[[TCP]], port=[[21]], endport=[[21]], fwport=[[21]]})
table.insert( g_t_app_names_list, 1, { [[FTP-Server]], [[{?4959:145?}]]} )
end
g_rule_active = boxvars2.c_boxvars:init( { sz_query = "forwardrules:settings/"..sz_rule.."/activated"} )
if (g_b_was_exposed_host) then
g_rule_active = boxvars2.c_boxvars:init( { sz_query = "forwardrules:settings/use_exposed_host"} )
end
g_rule_description = boxvars2.c_boxvars:init( { sz_query = "forwardrules:settings/"..sz_rule.."/description"} )
g_rule_protocol = boxvars2.c_boxvars:init( { sz_query = "forwardrules:settings/"..sz_rule.."/protocol"} )
g_rule_port = boxvars2.c_boxvars:init( { sz_query = "forwardrules:settings/"..sz_rule.."/port"} )
g_rule_endport = boxvars2.c_boxvars:init( { sz_query = "forwardrules:settings/"..sz_rule.."/endport"} )
g_rule_fw_port = boxvars2.c_boxvars:init( { sz_query = "forwardrules:settings/"..sz_rule.."/fwport"} )
g_rule_fw_ip = boxvars2.c_boxvars:init( { sz_query = "forwardrules:settings/"..sz_rule.."/fwip"} )
g_rule_exposed_host = boxvars2.c_boxvars:init( { sz_query = "forwardrules:settings/exposed_host"} )
if ( g_b_is_new == true)then
g_rule_active:set_value( '1')
end
if ((g_rule_protocol:get_value() =="GRE") or (g_rule_protocol:get_value() =="ESP")) then
g_rule_port:set_value( "80")
g_rule_endport:set_value( "80")
g_rule_fw_port:set_value( "80")
end
if ( g_b_is_new == true) or (g_b_was_exposed_host == true) then
g_rule_description:set_value( 'HTTP-Server')
g_rule_protocol:set_value( 'TCP')
g_rule_port:set_value( '80')
g_rule_endport:set_value( '80')
g_rule_fw_port:set_value( '80')
if string.find(tostring(box.glob.clientipaddress), val.pr.ipv4.pat) then
g_rule_fw_ip:set_value(tostring(box.glob.clientipaddress))
else
g_rule_fw_ip:set_value("")
end
end
get_app_name_list()
get_lan_device_list()
end
function get_value_of_rule_end_port()
local n_start_port = g_rule_port:get_value()
local n_end_port = g_rule_endport:get_value()
if ( tostring(n_end_port) == "" or tostring(n_end_port) == "0") then
return n_start_port
else
return n_end_port
end
end
function get_value_of_fw_end_port()
local n_start_port = tonumber( g_rule_port:get_value())
local n_end_port = tonumber( g_rule_endport:get_value()) or n_start_port
local n_start_fw_port = tonumber( g_rule_fw_port:get_value())
if ( n_start_fw_port == n_end_port or tostring(n_end_port) == "0") then
return ""
else
return ( n_start_fw_port +(n_end_port-n_start_port))
end
end
function get_host_ip_adress()
if ( box.post.selected_lan_device ~= "manuell#manuell" ) then
local sz_IpAdr = get_ip_from_lan_device( box.post.selected_lan_device)
g_rule_fw_ip:save_value( saveset, sz_IpAdr)
else
g_rule_fw_ip:save_value( saveset)
end
end
if (next(box.get)) then
if ( box.get.new) then
g_b_is_new = true
end
if ( tostring(box.get.rule) == "exposed" ) then
g_current_rule = box.query( "forwardrules:settings/rule/newid")
g_b_was_exposed_host = true
else
if box.get.rule ~= nil and box.get.rule~="" then
g_current_rule = box.get.rule
elseif box.post.rule ~= nil and box.post.rule~="" then
g_current_rule = box.post.rule
end
end
end
if ( next(box.post)) then
g_current_rule = box.post.current_rule
g_b_was_exposed_host = (tostring( box.post.was_exposed_host) == "true")
end
if (g_current_rule==nil) then
http.redirect(g_back_to_page)
return
end
init_page_vars( g_current_rule)
function are_relevant_protocols()
g_rule_protocol:update_value()
if ( g_rule_protocol:get_value() == "GRE" or g_rule_protocol:get_value() == "ESP" ) then
return false
end
return true
end
function get_val_prog()
g_val = {
prog = [[
if __value_equal(uiView_SelectedApp/selected_app,other) then
not_empty(]]..g_rule_description:get_val_names()..[[, description_empty)
end
if __value_equal(uiView_SelectedLanDevice/selected_lan_device,manuell#manuell) then
port_fw_ip_adr(]]..g_rule_fw_ip:get_val_names()..[[, portfw_ipadr)
end
if __value_not_equal(]]..g_rule_protocol:get_val_names()..[[,GRE) then
if __value_not_equal(]]..g_rule_protocol:get_val_names()..[[,ESP) then
port_fw_port_values(]]..g_rule_port:get_val_names()..[[,]]..g_rule_endport:get_val_names()..[[,]]..g_rule_fw_port:get_val_names()..[[, portfw_portvalues)
end
end
]]
}
end
get_val_prog()
val.msg.description_empty = {
[val.ret.empty] = [[{?4959:511?}]],
[val.ret.notfound] = [[{?4959:820?}]]
}
val.msg.portfw_ipadr = {
[val.ret.notfound] = [[{?4959:24?}]],
[val.ret.empty] = [[{?4959:569?}]],
[val.ret.format] = [[{?4959:646?}]],
[val.ret.outofrange] = [[{?4959:305?}]],
[val.ret.allzero] = [[{?4959:781?}]],
[val.ret.zero] = [[{?4959:9342?}]],
[val.ret.broadcast] = [[{?4959:90?}]]
}
val.msg.portfw_portvalues = {
[val.ret.notfound] = [[{?4959:187?}]],
[val.ret.empty] = [[{?4959:703?}]],
[val.ret.format] = [[{?4959:224?}]],
[val.ret.outofrange] = [[{?4959:663?}]],
[val.ret.wrong] = [[{?4959:406?}]]
}
if ( next(box.post)) then
local l_val_result = val.ret.ok
local saveset = {}
if ( box.post.apply) then
local l_bSave = false
l_val_result = val.validate(g_val)
if ( l_val_result == val.ret.ok) then
if ( tostring(box.post.selected_app) == "exposed") then
local name=g_rule_active:get_var_name()
if (box.post[name]) then
cmtable.add_var( saveset, "forwardrules:settings/use_exposed_host", "1")
else
cmtable.add_var( saveset, "forwardrules:settings/use_exposed_host", "0")
end
if ( box.post.selected_lan_device and box.post.selected_lan_device ~= "manuell#manuell" ) then
g_rule_exposed_host:save_value( saveset, get_ip_from_lan_device( box.post.selected_lan_device))
else
g_rule_exposed_host:save_value( saveset, tostring(box.post[g_rule_fw_ip:get_var_name()]))
end
else
g_rule_active:save_check_value( saveset)
g_rule_description:save_value( saveset)
g_rule_protocol:save_value( saveset)
if ( box.post.selected_lan_device and box.post.selected_lan_device ~= "manuell#manuell" ) then
local sz_IpAdr = get_ip_from_lan_device( box.post.selected_lan_device)
g_rule_fw_ip:save_value( saveset, sz_IpAdr)
else
g_rule_fw_ip:save_value( saveset)
end
if ((g_rule_protocol:get_value() =="GRE") or (g_rule_protocol:get_value() =="ESP")) then
g_rule_port:save_value( saveset, "")
g_rule_endport:save_value( saveset,"")
g_rule_fw_port:save_value( saveset, "")
else
g_rule_port:save_value( saveset)
g_rule_endport:save_value( saveset)
g_rule_fw_port:save_value( saveset)
end
if ( g_b_was_exposed_host == true) then
g_rule_exposed_host:save_value( saveset, "")
cmtable.add_var( saveset, "forwardrules:settings/use_exposed_host", "0")
end
end
else
g_rule_active:set_value( box.post[g_rule_active:get_var_name()])
g_rule_description:set_value( box.post[g_rule_description:get_var_name()])
g_rule_protocol:set_value( box.post[g_rule_protocol:get_var_name()])
g_rule_port:set_value( box.post[g_rule_port:get_var_name()])
g_rule_endport:set_value( box.post[g_rule_endport:get_var_name()])
g_rule_fw_ip:set_value( box.post[g_rule_fw_ip:get_var_name()])
g_rule_fw_port:set_value( box.post[g_rule_fw_port:get_var_name()])
end
end
if ( l_val_result == val.ret.ok) then
g_errcode, g_errmsg = box.set_config( saveset)
if g_errcode ~= 0 then
g_val.errmsg = errmsg
else
http.redirect( g_back_to_page )
end
end
end
?>
<?include "templates/html_head.html" ?>
<!-- <link rel="stylesheet" type="text/css" href="/css/default/port_fw_edit.css"> -->
<style type="text/css">
.achtung {color: #CC0000; font-weight: bold;}
</style>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
var g_service = new Array(
<?lua if not g_ftp_from_internet then box.out("new Array('FTP-Server','TCP',21,21,21),") end ?>
new Array('HTTP-Server','TCP',80,80,80),
new Array('eMule TCP','TCP',4662,4662,4662),
new Array('eMule UDP','UDP',4672,4672,4672),
new Array('MS Remotedesktop','TCP',3389,3389,3389)
);
function InitEventHandler () {
var select_elem_app = jxl.get( "uiView_SelectedApp");
if ( select_elem_app)
select_elem_app.onchange = OnChange_SelectedApp;
var select_elem_protocol = jxl.get( "<?lua box.out( g_rule_protocol:get_var_name_js()) ?>");
if ( select_elem_protocol)
select_elem_protocol.onchange = OnChange_SelectedProtocol;
var select_elem_landevice= jxl.get( "uiView_SelectedLanDevice");
if ( select_elem_landevice)
select_elem_landevice.onchange = OnChange_SelectedLanDevice;
}
function init() {
InitEventHandler();
OnChange_SelectedApp();
}
function OnChange_SelectedApp() {
var szValue = "|----|";
var select_elem = jxl.get( "uiView_SelectedApp");
if ( select_elem) {
var b = (select_elem.value == "other");
SetSelectedAppValues( select_elem.value)
OnChange_SelectedProtocol()
OnChange_SelectedLanDevice()
OnChange_PortValues( "");
jxl.display( "uiShow_Description", b);
jxl.display( "uiShow_Protocol", b);
jxl.display( "uiShow_Ports", b);
jxl.display( "uiShow_FwPorts", b);
jxl.display( "uiShow_ExposedMsg", (select_elem.value == "exposed"));
}
}
function OnChange_SelectedProtocol() {
var szValue = "|----|";
var select_elem = jxl.get( "<?lua box.out( g_rule_protocol:get_var_name_js()) ?>");
if ( select_elem) {
var b = (select_elem.value == "GRE") || (select_elem.value == "ESP");
jxl.setDisabled( "<?lua box.out( g_rule_port:get_var_name_js()) ?>", b);
jxl.setDisabled( "<?lua box.out( g_rule_endport:get_var_name_js()) ?>", b);
jxl.setDisabled( "<?lua box.out( g_rule_fw_port:get_var_name_js()) ?>", b);
}
}
function SetSelectedAppValues( szValue) {
if ( szValue != "other") {
for ( var i=0; i <g_service.length; i++) {
if (g_service[i][0] == szValue) {
jxl.setValue( "<?lua box.out( g_rule_description:get_var_name_js()) ?>", g_service[i][0]);
jxl.setValue( "<?lua box.out( g_rule_protocol:get_var_name_js()) ?>", g_service[i][1]);
jxl.setValue( "<?lua box.out( g_rule_port:get_var_name_js()) ?>", g_service[i][2]);
jxl.setValue( "<?lua box.out( g_rule_endport:get_var_name_js()) ?>", g_service[i][3]);
jxl.setValue( "<?lua box.out( g_rule_fw_port:get_var_name_js()) ?>", g_service[i][4]);
}
}
}
}
function OnChange_SelectedLanDevice() {
var szValue = "|----|";
var select_elem = jxl.getValue("uiView_SelectedLanDevice");
if (select_elem) {
var manualSelected = (select_elem == "manuell#manuell");
if (!manualSelected)
{
var hashInd = select_elem.indexOf("#");
if (hashInd >= 0)
{
var value = select_elem.substring(0, hashInd);
jxl.setValue("<?lua box.out( g_rule_fw_ip:get_var_name_js()) ?>", value);
}
}
jxl.setDisabled( "<?lua box.out( g_rule_fw_ip:get_var_name_js()) ?>", !manualSelected);
}
}
function OnChange_PortValues(szId) {
var nFromPort = Number( jxl.getValue( "<?lua box.out( g_rule_port:get_var_name_js()) ?>"));
var nToPort = Number( jxl.getValue( "<?lua box.out( g_rule_endport:get_var_name_js()) ?>"));
var nFromFwPort = Number( jxl.getValue( "<?lua box.out( g_rule_fw_port:get_var_name_js()) ?>"));
var bShow = (!isNaN(nFromPort) && !isNaN(nToPort) && nFromPort < nToPort);
if ( bShow == true) {
jxl.setText( "uiView_FwPortEnd", String( nFromFwPort + (nToPort-nFromPort)));
}
jxl.display( "uiView_FwPortEndText", bShow);
jxl.display( "uiView_FwPortEnd", bShow);
}
function On_MainFormSubmit() {
<?lua
val.write_js_checks( g_val)
?>
}
ready.onReady(val.init(On_MainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form name="main_form" method="POST" action="/internet/port_fw_edit.lua" id="uiMainForm">
<input type="hidden" name="current_rule" value="<?lua box.html( g_current_rule) ?>">
<input type="hidden" name="is_new_rule" value="<?lua box.html( tostring(g_b_is_new)) ?>">
<input type="hidden" name="was_exposed_host" value="<?lua box.out( tostring(g_b_was_exposed_host)) ?>">
<?lua
if ( g_b_is_new == true) then
box.out( [[<h4>{?4959:124?}</h4>]])
else
box.out( [[<h4>{?4959:425?}</h4>]])
end
box.out( [[<div class="narrow">]] )
box.out( [[<p>]])
box.out( elem._checkbox( g_rule_active:get_var_name(), g_rule_active:get_var_name_js(), g_rule_active:get_value(), (g_rule_active:get_value() == "1")))
box.out( [[&nbsp;]])
box.out( elem._label( g_rule_active:get_var_name_js(), "Label"..g_rule_active:get_var_name_js(), [[{?4959:533?}]]))
box.out( [[&nbsp;]])
local sz_selected_app = get_selected_value( g_rule_description:get_value(),g_rule_port:get_value(), g_rule_endport:get_value(), g_rule_fw_port:get_value(), g_rule_protocol:get_value())
box.out( elem._select( "selected_app", "uiView_SelectedApp", g_t_app_names_list, sz_selected_app))
box.out( [[</p>]])
box.out( [[<div class="formular" id="uiShow_Description">]])
box.out( elem._label( g_rule_description:get_var_name_js().."_2", "Label"..g_rule_description:get_var_name_js().."_2", [[{?4959:531?}]]))
box.out( elem._input( "text", g_rule_description:get_var_name(), g_rule_description:get_var_name_js(), g_rule_description:get_value(), "24", "50", val.get_attrs( g_val, g_rule_description:get_var_name_js() )))
val.write_html_msg(g_val, g_rule_description:get_var_name_js())
box.out( [[</div>]])
box.out( [[<div class="formular" id="uiShow_Protocol">]])
box.out( elem._label( g_rule_protocol:get_var_name_js(), "Label"..g_rule_protocol:get_var_name_js(), [[{?4959:333?}]]))
box.out( elem._select( g_rule_protocol:get_var_name(), g_rule_protocol:get_var_name_js(), g_t_protocol_list, g_rule_protocol:get_value()))
box.out( [[</div>]])
box.out( [[<div class="formular" id="uiShow_Ports">]])
box.out( elem._label( g_rule_port:get_var_name_js(), "Label"..g_rule_port:get_var_name_js(), [[{?4959:166?}]]))
box.out( elem._input_plus( "text", g_rule_port:get_var_name(), g_rule_port:get_var_name_js(), g_rule_port:get_value(), "6", "5", [[onkeyup="OnChange_PortValues( this.id)" ]], val.get_attrs( g_val, g_rule_port:get_var_name_js() )))
box.out( elem._label( g_rule_endport:get_var_name_js(), "Label"..g_rule_endport:get_var_name_js(), [[{?4959:881?}]]))
box.out( elem._input_plus( "text", g_rule_endport:get_var_name(), g_rule_endport:get_var_name_js(), get_value_of_rule_end_port(), "6", "5", [[onkeyup="OnChange_PortValues(this.id)" ]], val.get_attrs( g_val, g_rule_endport:get_var_name_js() )))
val.write_html_msg(g_val, g_rule_port:get_var_name_js())
val.write_html_msg(g_val, g_rule_endport:get_var_name_js())
box.out( [[</div>]])
box.out( [[<div class="formular" id="uiShow_LanDevices">]])
box.out( elem._label( "uiView_SelectedLanDevice", "Label_SelectedLanDevice", [[{?4959:2998?}]]))
local sz_selected_lan_device = get_selected_lan_device( g_rule_fw_ip:get_value())
box.out( elem._select( "selected_lan_device", "uiView_SelectedLanDevice", g_t_lan_device_list, sz_selected_lan_device))
box.out( [[</div>]])
box.out( [[<div class="formular" id="uiShow_IpAddress">]])
box.out( elem._label( g_rule_fw_ip:get_var_name_js().."_2", "Label"..g_rule_fw_ip:get_var_name_js(), [[{?4959:343?}]]))
local l_current_ip = get_current_ip_address( g_rule_fw_ip:get_value())
box.out( elem._input( "text", g_rule_fw_ip:get_var_name(), g_rule_fw_ip:get_var_name_js(), l_current_ip, "24", "50", val.get_attrs( g_val, g_rule_fw_ip:get_var_name_js() )))
val.write_html_msg(g_val, g_rule_fw_ip:get_var_name_js())
box.out( [[</div>]])
box.out( [[<div class="formular" id="uiShow_FwPorts">]])
box.out( elem._label( g_rule_fw_port:get_var_name_js(), "Label"..g_rule_fw_port:get_var_name_js(), [[{?4959:578?}]]))
box.out( elem._input_plus( "text", g_rule_fw_port:get_var_name(), g_rule_fw_port:get_var_name_js(), g_rule_fw_port:get_value(), "6", "5", [[onkeyup="OnChange_PortValues(this.id)"]], val.get_attrs( g_val, g_rule_fw_port:get_var_name_js() )))
box.out( elem._span_plus( "uiView_FwPortEndText",[[ {?4959:205?} ]], "", true))
box.out( elem._span_plus( "uiView_FwPortEnd", get_value_of_fw_end_port(), "", true))
val.write_html_msg(g_val, g_rule_fw_port:get_var_name_js())
box.out( [[</div>]])
box.out( [[<p class="achtung" id="uiShow_ExposedMsg" style="display:none">]])
box.out( [[{?4959:951?}]])
box.out( [[</p>]] )
box.out( [[<div>]])
if ( g_errcode ~= 0) then
box.out( [[<p class="form_input_note ErrorMsg" style="text-align: center; margin: 10px 0px 10px 0px;">]]..tostring( g_errmsg)..[[</p>]])
end
box.out( [[</div>]])
box.out( [[</div>]])
?>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="rule" value="<?lua box.html(g_current_rule) ?>">
<button type="submit" name="apply" id="uiApply">{?4959:797?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
