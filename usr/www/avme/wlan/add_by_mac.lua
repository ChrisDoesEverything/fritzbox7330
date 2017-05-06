<?lua
g_page_type = "all"
g_page_title = "{?7768:592?}"
g_page_help = "hilfe_wlan_macadresse.html"
dofile("../templates/global_lua.lua")
require("general")
require("http")
require("net_devices")
require("wlanscan")
require("cmtable")
require("val")
g_back_to_page = http.get_back_to_page( "/wlan/wds.lua" )
g_menu_active_page=g_back_to_page
if next(box.post) and box.post.cancel then
http.redirect(href.get(g_back_to_page))
end
g_CurrentMode=""
if (box.get and box.get.Mode) then
g_CurrentMode=box.get.Mode
end
g_mac = {}
g_macstr = ""
g_val = {
prog = [[
mac(uiMac/mac, mac)
]]
}
val.msg.mac = {
[val.ret.empty] = [[{?7768:65?}]],
[val.ret.format] = [[{?7768:760?}]],
[val.ret.group] = [[{?7768:999?}]]
}
?>
<?lua
function read_box_values()
g_mac = { "", "", "", "", "", "" }
end
function refill_user_input()
g_mac = { box.post.mac0, box.post.mac1, box.post.mac2, box.post.mac3, box.post.mac4, box.post.mac5 }
end
g_oldparams=""
g_errmsg = nil
if (box.get) then
local i=1
local tmpParams={}
for k,v in pairs(box.get) do
if (k~="sid") then
tmpParams[i] = http.url_param(k,v)
i=i+1
end
end
g_oldparams=table.concat(tmpParams,"&")
end
if next(box.post) and box.post.apply then
if val.validate(g_val) == val.ret.ok then
for i=0,5 do
g_macstr = g_macstr .. string.upper(box.post["mac"..tostring(i)])
if i < 5 then
g_macstr = g_macstr .. ":"
end
end
local params = box.post.oldparams..'&macstr='..g_macstr
local str=href.get(g_back_to_page, params)
http.redirect(str)
return
else
refill_user_input()
end
else
read_box_values()
end
function get_display_str(mode)
if mode==g_CurrentMode then
return ""
end
return "display:none;"
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
</style>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function init()
{
fc.init("macbox", 2, 'mac');
jxl.focus("uiMac0");
}
function uiDoOnMainFormSubmit()
{
var ret;
<?lua
val.write_js_checks(g_val)
?>
return true;
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" name="main_form">
<div id="content">
<div class="formular">
<p id="uiAddMacRep" style="<?lua box.out(get_display_str('basis')) ?>">{?7768:277?}</p>
<p id="uiAddMacBasis" style="<?lua box.out(get_display_str('repeater')) ?>">{?7768:562?}</p>
<div id="macbox">
<label for="uiMac0">{?7768:123?}</label>
<input type="text" size="2" maxlength="2" id="uiMac0" name="mac0" value="" <?lua val.write_attrs(g_val, 'uiMac0') ?> /> :
<input type="text" size="2" maxlength="2" id="uiMac1" name="mac1" value="" <?lua val.write_attrs(g_val, 'uiMac1') ?> /> :
<input type="text" size="2" maxlength="2" id="uiMac2" name="mac2" value="" <?lua val.write_attrs(g_val, 'uiMac2') ?> /> :
<input type="text" size="2" maxlength="2" id="uiMac3" name="mac3" value="" <?lua val.write_attrs(g_val, 'uiMac3') ?> /> :
<input type="text" size="2" maxlength="2" id="uiMac4" name="mac4" value="" <?lua val.write_attrs(g_val, 'uiMac4') ?> /> :
<input type="text" size="2" maxlength="2" id="uiMac5" name="mac5" value="" <?lua val.write_attrs(g_val, 'uiMac5') ?> />
</div>
<?lua val.write_html_msg(g_val, "uiMac0", "uiMac1", "uiMac2", "uiMac3", "uiMac4", "uiMac5") ?>
<p>{?7768:483?}</p>
<?lua
if g_errmsg and string.len(g_errmsg)>0 then
box.out([[<p class="form_input_note ErrorMsg">]])
box.html(g_errmsg)
box.out([[</p>]])
end
?>
</div>
<div id="btn_form_foot">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="oldparams" value="<?lua box.html(g_oldparams) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="apply" id="uiApply">{?txtApplyOk?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
