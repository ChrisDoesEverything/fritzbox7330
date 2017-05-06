<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_internet_dnsserver.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("boxvars2")
require("elem")
require"general"
if (next(box.post) and (box.post.cancel)) then
end
g_errcode = 0
g_errmsg = [[ERROR: Es ist ein Fehler beim Übernehmen der Daten aufgetreten. Die aktuellen Daten dieser Seite wurden nicht gespeichert.]]
g_ipv4_use_user_dns = nil
g_ipv4_user_firstdns = nil
g_ipv4_user_seconddns = nil
g_ipv6_use_user_dns = nil
g_ipv6_user_firstdns = nil
g_ipv6_user_seconddns = nil
g_t_ipv4_first_dns = {"", "", "", ""}
g_t_ipv4_second_dns = {"", "", "", ""}
g_ipv6_hidden_gui = nil
g_ipv6_enabled = nil
function init_page_vars()
g_ipv4_use_user_dns = boxvars2.c_boxvars:init( { sz_query = [[dnscfg:settings/ipv4_use_user_dns]]} )
g_ipv4_user_firstdns = boxvars2.c_boxvars:init( { sz_query = [[dnscfg:settings/ipv4_user_firstdns]]} )
g_ipv4_user_seconddns = boxvars2.c_boxvars:init( { sz_query = [[dnscfg:settings/ipv4_user_seconddns]]} )
g_ipv6_use_user_dns = boxvars2.c_boxvars:init( { sz_query = [[dnscfg:settings/ipv6_use_user_dns]]} )
g_ipv6_user_firstdns = boxvars2.c_boxvars:init( { sz_query = [[dnscfg:settings/ipv6_user_firstdns]]} )
g_ipv6_user_seconddns = boxvars2.c_boxvars:init( { sz_query = [[dnscfg:settings/ipv6_user_seconddns]]} )
g_ipv6_hidden_gui = boxvars2.c_boxvars:init( { sz_query = "ipv6:settings/gui_hidden"} )
g_ipv6_enabled = boxvars2.c_boxvars:init( { sz_query = "ipv6:settings/enabled"} )
end
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
function rewriteIPv4AlternativeDnsServer()
if ( box.post.ipv4_first_dns_0 ~= nil) then
local l_szTemp = box.tohtml(box.post.ipv4_first_dns_0).."."..box.tohtml(box.post.ipv4_first_dns_1).."."..box.tohtml(box.post.ipv4_first_dns_2).."."..box.tohtml(box.post.ipv4_first_dns_3)
g_ipv4_user_firstdns:set_value( l_szTemp)
end
if ( box.post.ipv4_second_dns_0 ~= nil) then
local l_szTemp2 = box.tohtml(box.post.ipv4_second_dns_0).."."..box.tohtml(box.post.ipv4_second_dns_1).."."..box.tohtml(box.post.ipv4_second_dns_2).."."..box.tohtml(box.post.ipv4_second_dns_3)
g_ipv4_user_seconddns:set_value( l_szTemp2)
end
end
function saveIPv4AlternativeDnsServer(_t_save_set)
if ( box.post.ipv4_first_dns_0 ~= nil) then
local l_szTemp = box.tohtml(box.post.ipv4_first_dns_0).."."..box.tohtml(box.post.ipv4_first_dns_1).."."..box.tohtml(box.post.ipv4_first_dns_2).."."..box.tohtml(box.post.ipv4_first_dns_3)
g_ipv4_user_firstdns:save_value( _t_save_set, l_szTemp)
end
if ( box.post.ipv4_second_dns_0 ~= nil) then
local l_szTemp2 = box.tohtml(box.post.ipv4_second_dns_0).."."..box.tohtml(box.post.ipv4_second_dns_1).."."..box.tohtml(box.post.ipv4_second_dns_2).."."..box.tohtml(box.post.ipv4_second_dns_3)
g_ipv4_user_seconddns:save_value( _t_save_set, l_szTemp2)
end
end
function rewriteIPv6AlternativeDnsServer()
g_ipv6_user_firstdns:set_value( box.post[g_ipv6_user_firstdns:get_var_name()])
g_ipv6_user_seconddns:set_value( box.post[g_ipv6_user_seconddns:get_var_name()])
end
function saveIPv6AlternativeDnsServer(_t_save_set)
g_ipv6_user_firstdns:save_value( _t_save_set)
g_ipv6_user_seconddns:save_value( _t_save_set)
end
function refill_user_input()
g_ipv4_use_user_dns:set_value( box.post[g_ipv4_use_user_dns:get_var_name()])
rewriteIPv4AlternativeDnsServer()
g_ipv6_use_user_dns:set_value( box.post[g_ipv6_use_user_dns:get_var_name()])
rewriteIPv6AlternativeDnsServer()
end
function ipv6_available()
if ( g_ipv6_enabled:get_value() == "0") then
return false
end
if ( g_ipv6_hidden_gui:get_value() == "1") then
return false
end
return true
end
init_page_vars()
g_val = {
prog = [[
if __radio_check(]]..g_ipv4_use_user_dns:get_var_name_js()..[[_1/]]..g_ipv4_use_user_dns:get_var_name()..[[, 1) then
ipv4(ui_IPv4_FirstDns_/ipv4_first_dns_, ipv4_first_dns_, zero_not_allowed, ipv4)
ipv4(ui_IPv4_SecondDns_/ipv4_second_dns_, ipv4_second_dns_, zero_not_allowed, ipv4)
end
if ipv6_available() then
if __radio_check(]]..g_ipv6_use_user_dns:get_var_name_js()..[[_1/]]..g_ipv6_use_user_dns:get_var_name()..[[, 1) then
ipv6(]]..g_ipv6_user_firstdns:get_val_names()..[[, ipv6)
ipv6(]]..g_ipv6_user_seconddns:get_val_names()..[[, ipv6)
end
end
]]
}
val.msg.ipv6 = {
[val.ret.empty] = [[{?364:828?}]],
[val.ret.format] = [[{?364:578?}]],
[val.ret.wrong] = [[{?364:591?}]],
[val.ret.toomuch] = [[{?364:991?}]],
[val.ret.notfound] = [[{?364:473?}]]
}
val.msg.ipv4 = {
[val.ret.empty] = [[{?364:24?}]],
[val.ret.format] = [[{?364:528?}]],
[val.ret.outofrange] = [[{?364:656?}]],
[val.ret.outofnet] = [[{?364:771?}]],
[val.ret.thenet] = [[{?364:835?}]],
[val.ret.broadcast] = [[{?364:384?}]],
[val.ret.thebox] = [[{?364:352?}]],
[val.ret.unsized] = [[{?364:577?}]],
[val.ret.allzero] = [[{?364:533?}]],
[val.ret.notzero] = [[{?364:844?}]]
}
if next(box.post) and (box.post.apply ) then
if val.validate(g_val) == val.ret.ok then
local saveset={}
g_ipv4_use_user_dns:save_value( saveset)
if ( g_ipv4_use_user_dns:get_value() == "1") then
saveIPv4AlternativeDnsServer( saveset)
end
if ( ipv6_available()) then
g_ipv6_use_user_dns:save_value( saveset)
if ( g_ipv6_use_user_dns:get_value() == "1") then
saveIPv6AlternativeDnsServer( saveset)
end
end
local err, msg = box.set_config( saveset)
if err ~= 0 then
box.out(general.create_error_div(err,msg))
refill_user_input()
end
else
refill_user_input()
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
function OnChange_IPv4UseUserDns( szValue) {
jxl.setDisabled( "uiShow_IPv4_Dns_Server", szValue == "0");
jxl.setDisabled( "Label_ui_IPv4_FirstDns_0", szValue == "0");
jxl.setDisabled( "ui_IPv4_FirstDns_0", szValue == "0");
jxl.setDisabled( "ui_IPv4_FirstDns_1", szValue == "0");
jxl.setDisabled( "ui_IPv4_FirstDns_2", szValue == "0");
jxl.setDisabled( "ui_IPv4_FirstDns_3", szValue == "0");
jxl.setDisabled( "Label_ui_IPv4_SecondDns_0", szValue == "0");
jxl.setDisabled( "ui_IPv4_SecondDns_0", szValue == "0");
jxl.setDisabled( "ui_IPv4_SecondDns_1", szValue == "0");
jxl.setDisabled( "ui_IPv4_SecondDns_2", szValue == "0");
jxl.setDisabled( "ui_IPv4_SecondDns_3", szValue == "0");
}
function OnChange_IPv6UseUserDns( szValue) {
jxl.setDisabled( <?lua box.out( [["]]..g_ipv6_user_firstdns:get_var_name_js()..[["]]) ?>, szValue == "0");
jxl.setDisabled( <?lua box.out( [["]]..g_ipv6_user_seconddns:get_var_name_js()..[["]]) ?>, szValue == "0");
}
function init() {
fc.init( "ui_IPv4_FirstDns_", 3, 'ip');
fc.init( "ui_IPv4_SecondDns_", 3, 'ip');
OnChange_IPv4UseUserDns( <?lua box.out( [["]]..box.tojs(g_ipv4_use_user_dns:get_value())..[["]]) ?> );
OnChange_IPv6UseUserDns( <?lua box.out( [["]]..box.tojs(g_ipv6_use_user_dns:get_value())..[["]]) ?> );
}
function On_MainFormSubmit() {
<?lua
val.write_js_checks( g_val)
?>
}
ready.onReady(val.init(On_MainFormSubmit, "apply", "mainform" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua href.write(box.glob.script) ?>" id="uiMainForm">
<p>{?364:707?}<br /></p>
<hr>
<p><b>{?364:784?}</b></p>
<div class="formular">
<?lua
box.out( [[<p>]])
box.out( elem._radio( g_ipv4_use_user_dns:get_var_name(), g_ipv4_use_user_dns:get_var_name_js()..[[_0]], "0", (g_ipv4_use_user_dns:get_value() == "0"), [[onclick="OnChange_IPv4UseUserDns('0')"]]))
box.out( [[&nbsp;]])
box.out( elem._label( g_ipv4_use_user_dns:get_var_name_js()..[[_0]], "Label_"..g_ipv4_use_user_dns:get_var_name_js()..[[_0]],[[{?364:575?}]]))
box.out( [[</p>]])
box.out( [[<p style="margin-bottom: 0px;">]])
box.out( elem._radio( g_ipv4_use_user_dns:get_var_name(), g_ipv4_use_user_dns:get_var_name_js()..[[_1]], "1", (g_ipv4_use_user_dns:get_value() == "1"), [[onclick="OnChange_IPv4UseUserDns('1')"]]))
box.out( [[&nbsp;]])
box.out( elem._label( g_ipv4_use_user_dns:get_var_name_js()..[[_1]], "Label_"..g_ipv4_use_user_dns:get_var_name_js()..[[_1]],[[{?364:198?}]]))
box.out( [[</p>]])
box.out( [[<div class="formular">]])
box.out( [[<div id="ui_IPv4_FirstDns_" class="group">]])
box.out( elem._label( "ui_IPv4_FirstDns_0", "Label_".."ui_IPv4_FirstDns_0", [[{?364:895?}:]]))
if ( g_ipv4_user_firstdns:get_value() ~= "0.0.0.0") then
g_t_ipv4_first_dns = split( g_ipv4_user_firstdns:get_value(), ".")
end
box.out( elem._input( "text", "ipv4_first_dns_0", "ui_IPv4_FirstDns_0", g_t_ipv4_first_dns[1], "3", "3", val.write_attrs(g_val, 'ui_IPv4_FirstDns_0')))
box.out( [[&nbsp;.&nbsp;]])
box.out( elem._input( "text", "ipv4_first_dns_1", "ui_IPv4_FirstDns_1", g_t_ipv4_first_dns[2], "3", "3", val.write_attrs(g_val, 'ui_IPv4_FirstDns_1')))
box.out( [[&nbsp;.&nbsp;]])
box.out( elem._input( "text", "ipv4_first_dns_2", "ui_IPv4_FirstDns_2", g_t_ipv4_first_dns[3], "3", "3", val.write_attrs(g_val, 'ui_IPv4_FirstDns_2')))
box.out( [[&nbsp;.&nbsp;]])
box.out( elem._input( "text", "ipv4_first_dns_3", "ui_IPv4_FirstDns_3", g_t_ipv4_first_dns[4], "3", "3", val.write_attrs(g_val, 'ui_IPv4_FirstDns_3')))
val.write_html_msg(g_val, "ui_IPv4_FirstDns_0", "ui_IPv4_FirstDns_1", "ui_IPv4_FirstDns_2", "ui_IPv4_FirstDns_3")
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[<div class="formular">]])
box.out( [[<div id="ui_IPv4_SecondDns_" class="group">]])
box.out( elem._label( "ui_IPv4_SecondDns_0", "Label_".."ui_IPv4_SecondDns_0", [[{?364:251?}:]]))
if ( g_ipv4_user_seconddns:get_value() ~= "0.0.0.0") then
g_t_ipv4_second_dns = split( g_ipv4_user_seconddns:get_value(), ".")
end
box.out( elem._input( "text", "ipv4_second_dns_0", "ui_IPv4_SecondDns_0", g_t_ipv4_second_dns[1], "3", "3", val.write_attrs(g_val, 'ui_IPv4_SecondDns_0')))
box.out( [[&nbsp;.&nbsp;]])
box.out( elem._input( "text", "ipv4_second_dns_1", "ui_IPv4_SecondDns_1", g_t_ipv4_second_dns[2], "3", "3", val.write_attrs(g_val, 'ui_IPv4_SecondDns_1')))
box.out( [[&nbsp;.&nbsp;]])
box.out( elem._input( "text", "ipv4_second_dns_2", "ui_IPv4_SecondDns_2", g_t_ipv4_second_dns[3], "3", "3", val.write_attrs(g_val, 'ui_IPv4_SecondDns_2')))
box.out( [[&nbsp;.&nbsp;]])
box.out( elem._input( "text", "ipv4_second_dns_3", "ui_IPv4_SecondDns_3", g_t_ipv4_second_dns[4], "3", "3", val.write_attrs(g_val, 'ui_IPv4_SecondDns_3')))
val.write_html_msg(g_val, "ui_IPv4_SecondDns_0", "ui_IPv4_SecondDns_1", "ui_IPv4_SecondDns_2", "ui_IPv4_SecondDns_3")
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[</div>]])
if ( ipv6_available()) then
box.out( [[<hr>]])
box.out( [[<p><b>{?364:395?}</b></p>]])
box.out( [[<div class="formular">]])
box.out( [[<p>]])
box.out( elem._radio( g_ipv6_use_user_dns:get_var_name(), g_ipv6_use_user_dns:get_var_name_js()..[[_0]], "0", (g_ipv6_use_user_dns:get_value() == "0"), [[onclick="OnChange_IPv6UseUserDns('0')"]]))
box.out( [[&nbsp;]])
box.out( elem._label( g_ipv6_use_user_dns:get_var_name_js()..[[_0]], "Label_"..g_ipv6_use_user_dns:get_var_name_js()..[[_0]],[[{?364:99?}]]))
box.out( [[</p>]])
box.out( [[<p style="margin-bottom: 0px;">]])
box.out( elem._radio( g_ipv6_use_user_dns:get_var_name(), g_ipv6_use_user_dns:get_var_name_js()..[[_1]], "1", (g_ipv6_use_user_dns:get_value() == "1"), [[onclick="OnChange_IPv6UseUserDns('1')"]]))
box.out( [[&nbsp;]])
box.out( elem._label( g_ipv6_use_user_dns:get_var_name_js()..[[_1]], "Label_"..g_ipv6_use_user_dns:get_var_name_js()..[[_1]],[[{?364:262?}]]))
box.out( [[</p>]])
box.out( [[<div class="formular">]])
box.out( elem._label( g_ipv6_user_firstdns:get_var_name_js(), "Label_".. g_ipv6_user_firstdns:get_var_name_js(), [[{?364:195?}]]))
l_ipv6_firstDns_Adresss = ""
if ( g_ipv6_user_firstdns:get_value() ~= "::") then
l_ipv6_firstDns_Adresss = g_ipv6_user_firstdns:get_value()
end
box.out( elem._input( "text", g_ipv6_user_firstdns:get_var_name(), g_ipv6_user_firstdns:get_var_name_js(), l_ipv6_firstDns_Adresss, "39", "50", val.get_attrs( g_val, g_ipv6_user_firstdns:get_var_name_js(), g_ipv6_user_firstdns:get_var_name())))
val.write_html_msg(g_val, g_ipv6_user_firstdns:get_var_name_js())
box.out( [[</div>]])
box.out( [[<div class="formular">]])
box.out( elem._label( g_ipv6_user_seconddns:get_var_name_js(), "Label_".. g_ipv6_user_seconddns:get_var_name_js(), [[{?364:981?}]]))
l_ipv6_secondDns_Adresss = ""
if ( g_ipv6_user_seconddns:get_value() ~= "::") then
l_ipv6_secondDns_Adresss = g_ipv6_user_seconddns:get_value()
end
box.out( elem._input( "text", g_ipv6_user_seconddns:get_var_name(), g_ipv6_user_seconddns:get_var_name_js(), l_ipv6_secondDns_Adresss, "39", "50", val.get_attrs( g_val, g_ipv6_user_seconddns:get_var_name_js(), g_ipv6_user_seconddns:get_var_name())))
val.write_html_msg(g_val, g_ipv6_user_seconddns:get_var_name_js())
box.out( [[</div>]])
box.out( [[</div>]])
end
?>
<div id="btn_form_foot">
<button type="submit" id="uiBtnApply" name="apply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
