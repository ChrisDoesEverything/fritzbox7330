<?lua
g_page_type = "all"
g_page_title = [[{?4354:788?}]]
g_page_help = "hilfe_ipv6_settings.html"
g_menu_active_page = "/net/network_settings.lua"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("http")
require("href")
g_back_to_page = http.get_back_to_page( "/net/network_settings.lua" )
if next(box.post) and box.post.cancel then
http.redirect(href.get(g_back_to_page))
end
g_data = {}
function read_box_values()
g_data.ula = box.query("ipv6:settings/ula")
g_data.ula_mode = box.query("ipv6:settings/ulamode")
g_data.manu_ula = box.query("ipv6:settings/use_default_ula") == "0"
g_data.ula_override = box.query("ipv6:settings/ula_override")
g_data.dhcpv6_mode = box.query("ipv6:settings/dhcpv6d_mode")
end
read_box_values()
function create_ula_praefix_of_post()
local ulap = "fd"
for i=1, 4, 1 do
if i==1 and box.post["Ula_"..(i)] and string.len(box.post["Ula_"..(i)]) == 1 then
box.post["Ula_"..(i)] = box.post["Ula_"..(i)].."0"
end
if box.post["Ula_"..(i)] and box.post["Ula_"..(i)] == "" then
if i==1 then
box.post["Ula_"..(i)] = "00"
else
box.post["Ula_"..(i)] = "0"
end
end
ulap = ulap..box.post["Ula_"..(i)]..":"
end
return ulap..":"
end
function is_DHCPv6_Server_enabled()
if ( "dhcpv6lanmode_stateless" == g_data.dhcpv6_mode) or
( "dhcpv6lanmode_onlyprefixes" == g_data.dhcpv6_mode) or
( "dhcpv6lanmode_statefull" == g_data.dhcpv6_mode) then
return true
end
return false
end
function is_DHCPv6_Server_disabled()
if ( "dhcpv6lanmode_off" == g_data.dhcpv6_mode) or
( "dhcpv6lanmode_off_stateless" == g_data.dhcpv6_mode) or
( "dhcpv6lanmode_off_statefull" == g_data.dhcpv6_mode) then
return true
end
return false
end
function is_DHCPv6_Server_actived( szCompare)
if ( szCompare == g_data.dhcpv6_mode) then
return true
end
return false
end
function refill_user_input()
if box.post.ula_mode then
g_data.ula_mode = box.post.ula_mode
end
if box.post.ula_praefix_manuell then
g_data.manu_ula = true
else
g_data.manu_ula = false
end
if box.post.Ula_1 and box.post.Ula_2 and box.post.Ula_3 and box.post.Ula_4 then
g_data.ula_override = create_ula_praefix_of_post()
end
if box.post.dhcpv6_mode then
g_data.dhcpv6_mode = box.post.dhcpv6_mode
end
end
g_val = {
prog = [[
if __checked(uiViewManuUlaPraefix/ula_praefix_manuell) then
char_range_regex(uiUla_1/Ula_1, hexvalue, ip_txt)
char_range_regex(uiUla_2/Ula_2, hexvalue, ip_txt)
char_range_regex(uiUla_3/Ula_3, hexvalue, ip_txt)
char_range_regex(uiUla_4/Ula_4, hexvalue, ip_txt)
end
]]
}
val.msg.ip_txt = {
[val.ret.outofrange] = [[{?4354:985?}]]
}
if next(box.post) and box.post.apply then
if val.validate(g_val) == val.ret.ok then
local saveset = {}
cmtable.add_var(saveset, "ipv6:settings/ulamode", box.post.ula_mode)
if box.post.ula_mode ~= "ulamode_off" then
if box.post.ula_praefix_manuell then
cmtable.add_var(saveset, "ipv6:settings/use_default_ula", "0")
cmtable.add_var(saveset, "ipv6:settings/ula_override", create_ula_praefix_of_post())
else
cmtable.add_var(saveset, "ipv6:settings/use_default_ula", "1")
end
end
cmtable.add_var(saveset, "ipv6:settings/dhcpv6d_mode", box.post.dhcpv6_mode)
local err
err, g_errmsg = box.set_config(saveset)
if err==0 then
http.redirect(href.get(g_back_to_page))
else
refill_user_input()
end
else
refill_user_input()
end
else
read_box_values()
end
?>
<?lua
function get_man_ula_input()
local oula = string.split(g_data.ula_override, ":")
for i = 1, 4, 1 do
if not oula[i] then
oula[i] = ""
end
if i == 1 and oula[i]:find("fd", 0, true) == 1 then
oula[i] = oula[i]:sub(3)
end
end
return [[
<div id="ulabox">fd
<input type="text" size="2" maxlength="2" id="uiUla_1" name="Ula_1" value="]]..box.tohtml(oula[1])..[[" ]]..val.get_attrs(g_val, 'uiUla_1', 'Ula_')..[[ /> :
<input type="text" size="4" maxlength="4" id="uiUla_2" name="Ula_2" value="]]..box.tohtml(oula[2])..[[" ]]..val.get_attrs(g_val, 'uiUla_2', 'Ula_')..[[ /> :
<input type="text" size="4" maxlength="4" id="uiUla_3" name="Ula_3" value="]]..box.tohtml(oula[3])..[[" ]]..val.get_attrs(g_val, 'uiUla_3', 'Ula_')..[[ /> :
<input type="text" size="4" maxlength="4" id="uiUla_4" name="Ula_4" value="]]..box.tohtml(oula[4])..[[" ]]..val.get_attrs(g_val, 'uiUla_4', 'Ula_')..[[ /> /64
</div>
<div>]]..val.get_html_msg(g_val, "uiUla_1", "uiUla_2", "uiUla_3", "uiUla_4")..[[</div>]]
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form method="POST" action="/net/boxnet_ipv6.lua" name="main_form">
<p>
{?4354:77?}
</p>
<hr>
<h4>
{?4354:533?}
</h4>
<p>
{?4354:459?}
</p>
<div class="formular">
<div>
<input type="radio" id="uiViewUlaModeDynamic" name="ula_mode" value="ulamode_dynamic" onclick="OnChangeUlaSettings('ulamode_dynamic')" <?lua if g_data.ula_mode == "ulamode_dynamic" then box.out('checked') end?>>
<label for="uiViewUlaModeDynamic">{?4354:284?}</label>
<br>
<input type="radio" id="uiViewUlaModeOff" name="ula_mode" value="ulamode_off" onclick="OnChangeUlaSettings('ulamode_off')" <?lua if g_data.ula_mode == "ulamode_off" then box.out('checked') end?>>
<label for="uiViewUlaModeOff">{?4354:549?}</label>
<br>
<input type="radio" id="uiViewUlaModePersist" name="ula_mode" value="ulamode_persist" onclick="OnChangeUlaSettings('ulamode_persist')" <?lua if g_data.ula_mode == "ulamode_persist" then box.out('checked') end?>>
<label for="uiViewUlaModePersist">{?4354:710?}</label>
</div>
<br>
<div id="manuPraefixBox">
<p id="ulaFbox" <?lua if g_data.ula_mode == "ulamode_off" then box.out([[style="display:none;"]]) end ?>>
{?4354:202?}<?lua box.html(" "..tostring(g_data.ula)) ?>
</p>
<input type="checkbox" id="uiViewManuUlaPraefix" name="ula_praefix_manuell" onclick="OnChangeManuellPraefixAktiv()" <?lua if g_data.manu_ula then box.out('checked') end?>>
<label for="uiViewManuUlaPraefix">{?4354:167?}</label>
<div class="formular" id="manuPraefixInputBox">
<?lua box.out(get_man_ula_input()) ?>
</div>
</div>
</div>
<hr>
<h4>{?4354:891?}</h4>
<p>
<input type="radio" id="uiView_DHCPv6_Server_enabled" name="dhcpv6_server_enabled" value="1" onclick="OnChange_DHCPv6_Server('1')" <?lua if is_DHCPv6_Server_enabled() then box.out('checked') end?>>
<label for="uiView_DHCPv6_Server_enabled"><b>{?4354:505?}</b></label>
<div class="formular" id="DHCPv6_Server_enabled" style="display: none;">
<p>
<input type="radio" id="uiView_DHCPv6_Server_Mode_Stateless" name="dhcpv6_mode" value="dhcpv6lanmode_stateless" <?lua if is_DHCPv6_Server_actived([[dhcpv6lanmode_stateless]]) then box.out('checked') end?>>
<label for="uiView_DHCPv6_Server_Mode_Stateless"><b>{?4354:217?}</b></label>
<p class="formular">{?4354:641?}</p>
</p>
<p>
<input type="radio" id="uiView_DHCPv6_Server_Mode_OnlyPrefix" name="dhcpv6_mode" value="dhcpv6lanmode_onlyprefixes" <?lua if is_DHCPv6_Server_actived([[dhcpv6lanmode_onlyprefixes]]) then box.out('checked') end?>>
<label for="uiView_DHCPv6_Server_Mode_OnlyPrefix"><b>{?4354:286?}</b></label>
<p class="formular">{?4354:327?}</p>
</p>
<p>
<input type="radio" id="uiView_DHCPv6_Server_Mode_Statefull" name="dhcpv6_mode" value="dhcpv6lanmode_statefull" <?lua if is_DHCPv6_Server_actived([[dhcpv6lanmode_statefull]]) then box.out('checked') end?>>
<label for="uiView_DHCPv6_Server_Mode_Statefull"><b>{?4354:57?}</b></label>
<p class="formular">{?4354:431?}</p>
</p>
</div>
</p>
<p>
<input type="radio" id="uiView_DHCPv6_Server_disabled" name="dhcpv6_server_enabled" value="0" onclick="OnChange_DHCPv6_Server('0')" <?lua if is_DHCPv6_Server_disabled() then box.out('checked') end?>>
<label for="uiView_DHCPv6_Server_disabled"><b>{?4354:660?}</b></label>
<div class="formular" id="DHCPv6_Server_disabled" style="display: none;">
<p>
<input type="radio" id="uiView_DHCPv6_Server_Mode_Off" name="dhcpv6_mode" value="dhcpv6lanmode_off" <?lua if is_DHCPv6_Server_actived([[dhcpv6lanmode_off]]) then box.out('checked') end?>>
<label for="uiView_DHCPv6_Server_Mode_Off"><b>{?4354:966?}</b></label>
<p class="formular">{?4354:597?}</p>
</p>
<p>
<input type="radio" id="uiView_DHCPv6_Server_Mode_OffStateless" name="dhcpv6_mode" value="dhcpv6lanmode_off_stateless" <?lua if is_DHCPv6_Server_actived([[dhcpv6lanmode_off_stateless]]) then box.out('checked') end?>>
<label for="uiView_DHCPv6_Server_Mode_OffStateless"><b>{?4354:519?}</b></label>
<p class="formular">{?4354:169?}</p>
</p>
<p>
<input type="radio" id="uiView_DHCPv6_Server_Mode_OffStatefull" name="dhcpv6_mode" value="dhcpv6lanmode_off_statefull" <?lua if is_DHCPv6_Server_actived([[dhcpv6lanmode_off_statefull]]) then box.out('checked') end?>>
<label for="uiView_DHCPv6_Server_Mode_OffStatefull"><b>{?4354:301?}</b></label>
<p class="formular">{?4354:628?}</p>
</p>
</p>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>"/>
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>"/>
<button type="submit" name="apply" id="uiApply">{?txtApplyOk?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ip.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript">
<?lua
val.write_js_globals_for_ip_check()
val.write_js_error_strings()
?>
function OnChangeUlaSettings(mode)
{
jxl.display("ulaFbox", !(mode == "ulamode_off"));
jxl.disableNode("manuPraefixBox", mode == "ulamode_off");
}
function OnChangeManuellPraefixAktiv()
{
jxl.disableNode("manuPraefixInputBox", !jxl.getChecked("uiViewManuUlaPraefix"));
}
function OnChange_DHCPv6_Server( nValue)
{
jxl.setChecked( "uiView_DHCPv6_Server_Mode_Stateless", nValue == "1");
jxl.setChecked( "uiView_DHCPv6_Server_Mode_Off", nValue == "0");
jxl.setChecked( "uiView_DHCPv6_Server_enabled", nValue == "1");
jxl.setChecked( "uiView_DHCPv6_Server_disabled", nValue == "0");
jxl.display( "DHCPv6_Server_enabled", nValue == "1");
jxl.display( "DHCPv6_Server_disabled", nValue == "0");
}
function init()
{
fc.init("ulabox", 4);
OnChangeUlaSettings("<?lua box.js(g_data.ula_mode)?>");
var sz_DHCP_Mode = "<?lua box.js(g_data.dhcpv6_mode)?>";
if (( sz_DHCP_Mode == "dhcpv6lanmode_stateless") ||
( sz_DHCP_Mode == "dhcpv6lanmode_onlyprefixes") ||
( sz_DHCP_Mode == "dhcpv6lanmode_statefull")) {
jxl.display( "DHCPv6_Server_enabled", true);
} else {
jxl.display( "DHCPv6_Server_disabled", true);
}
OnChangeManuellPraefixAktiv();
}
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
