<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_fritz_box_name.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("newval")
require"general"
function get_all_var()
g_ctlmgr = {}
g_ctlmgr.fb_name = box.query("box:settings/hostname")
g_ctlmgr.fb_name_activ = g_ctlmgr.fb_name ~= ""
end
get_all_var()
function refill_user_input()
if box.post.box_name then
g_ctlmgr.fb_name = box.post.box_name
else
g_ctlmgr.fb_name = ""
end
end
local function val_prog()
newval.msg.error_txt = {
[newval.ret.empty] = [[{?3598:294?}]],
[newval.ret.toolong] = [[{?3598:884?}]],
[newval.ret.outofrange] = [[{?3598:1?}]]
}
newval.not_empty("box_name", "error_txt")
newval.length("box_name", 0, 17, "error_txt")
newval.allowed_devicename("box_name", "fbname", "error_txt")
end
if next(box.post) then
if box.post.validate == "btn_save" then
require"js"
local valresult, answer = newval.validate(val_prog)
box.out(js.table(answer))
box.end_page()
elseif box.post.btn_save then
ctlmgr_save={}
local save = false
if newval.validate(val_prog) == newval.ret.ok then
save = true
cmtable.add_var(ctlmgr_save, "box:settings/hostname" , box.post.box_name)
cmtable.add_var(ctlmgr_save, "ctlusb:settings/fritznas_share" , box.post.box_name)
cmtable.add_var(ctlmgr_save, "ctlusb:settings/samba-server-string" , box.post.box_name)
cmtable.add_var(ctlmgr_save, "ctlusb:settings/samba-workgroup" , box.post.box_name)
if config.WLAN then
if config.WLAN_GUEST then
cmtable.add_var(ctlmgr_save, "wlan:settings/guest_ssid" , box.post.box_name..[[ {?3598:158?}]])
end
cmtable.add_var(ctlmgr_save, "wlan:settings/ssid" , box.post.box_name)
if config.WLAN.is_double_wlan then
cmtable.add_var(ctlmgr_save, "wlan:settings/ssid_scnd" , box.post.box_name)
end
end
local str = box.query("emailnotify:settings/From")
local name, addr = "", ""
if str and str ~= "" then
name, addr = string.match(str, '^"(.*)"%s+<(.*)>$')
if not name or name == "" then
addr = str
end
end
cmtable.add_var(ctlmgr_save, "emailnotify:settings/From" , '"'..box.post.box_name..'" <'..addr..'>')
if config.MEDIASRV then
cmtable.add_var(ctlmgr_save, "mediasrv:settings/name" , box.post.box_name..[[ {?3598:424?}]])
end
else
refill_user_input()
end
if save then
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr = general.create_error_div(err,msg)
box.out(criterr)
end
get_all_var()
end
end
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<style type="text/css">
li {
font-size: 13px;
}
</style>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div>
<p>
{?3598:479?}
{?3598:23?}
</p>
<ul>
<?lua
if config.WLAN then
box.out([[<li>{?3598:323?}</li>]])
end
box.out([[<li>{?3598:961?}</li>]])
if config.MEDIASRV then
box.out([[<li>{?3598:957?}</li>]])
end
if config.MYFRITZ then
box.out([[<li>{?3598:110?}</li>]])
end
if config.WLAN_GUEST then
box.out([[<li>{?3598:192?}</li>]])
end
if config.DECT or config.DECT2 then
box.out([[<li>{?3598:618?}</li>]])
end
?>
</ul>
</div>
<hr>
<p>
{?3598:8754?}
</p>
<div class="formular">
<label for="uiViewName">{?3598:762?}</label>
<input type="text" size="23" maxlength="17" id="uiViewName" name="box_name" value="<?lua box.html(g_ctlmgr.fb_name) ?>">
</div>
<div>
<br>
<span class="hintMsg">{?3598:947?}:</span>
<p>
{?3598:267?}
</p>
</div>
<div id="btn_form_foot">
<button type="submit" name="btn_save" id="btnSave">{?txtApply?}</button>
<button type="submit" name="btn_cancel" id="btnCancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript">
function doConfirm() {
if (!confirm("{?3598:668?}"))
return false;
}
ready.onReady(ajaxValidation({
applyNames: "btn_save",
okCallback: doConfirm
}));
</script>
<?include "templates/html_end.html" ?>
