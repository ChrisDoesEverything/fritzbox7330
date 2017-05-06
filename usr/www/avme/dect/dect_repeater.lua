<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_dect_repeater.html"
dofile("../templates/global_lua.lua")
require"general"
require"cmtable"
require"val"
local dect = general.lazytable({}, box.query, {
DECTRepeaterEnabled = {"dect:settings/DECTRepeaterEnabled"},
enabled = {"dect:settings/enabled"}
})
function write_repeater_enabled_js()
box.js(tostring(dect.DECTRepeaterEnabled == "1"))
end
function write_checked()
if dect.DECTRepeaterEnabled == "1" then
box.out([[ checked]])
end
end
function ule_present()
if config.DECT_HOME then
local aha = require"libaha"
return #(aha.GetDeviceList() or {}) > 0
end
return false
end
local function save_values()
local saveset = {}
if box.post.enabled then
cmtable.add_var(saveset, "dect:settings/DECTRepeaterEnabled", "1")
cmtable.add_var(saveset, "dect:settings/enabled", "0")
if box.post.pin and box.post.pin ~= "****" then
cmtable.add_var(saveset, "dect:command/PIN" , box.post.pin)
end
else
cmtable.add_var(saveset, "dect:settings/DECTRepeaterEnabled", "0")
end
local err, msg = box.set_config(saveset)
end
g_val = {}
val.msg.pin_error_txt = {
[val.ret.outofrange] = [[{?8301:341?}]]
}
g_val.prog = [[
if __checked(uiEnabled/enabled) then
if __value_not_equal(uiPin/pin, ****) then
char_range_regex(uiPin/pin, dectpin, pin_error_txt)
end
end
]]
g_val_confirm = {}
g_val_confirm.confirm = true
g_val_confirm.prog = ""
if dect.enabled == "1" and ule_present() then
val.msg.ule_confirm = {
[val.ret.wrong] =
[[{?8301:211?}]]
.. "\\n\\n"
.. [[{?8301:513?}]]
}
g_val_confirm.prog = g_val_confirm.prog .. "\n"
.. " if __checked(uiEnabled/enabled) then "
.. " const_error(uiEnabled/enabled, wrong, ule_confirm) "
.. " end"
end
if box.post.apply then
if val.validate(g_val) == val.ret.ok then
save_values()
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
</style>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua val.write_js_error_strings() ?>
function doRepeaterPopup() {
var repeaterEnabled = <?lua write_repeater_enabled_js() ?>;
var toEnable = jxl.getChecked("uiEnabled");
if (!repeaterEnabled && toEnable) {
var url = encodeURI("<?lua href.write([[/dect/dect_repeater_info.lua]]) ?>");
var opts = "width=600,height=360,scrollbars=yes,resizable=yes";
var ppWindow = window.open(url, "Zweitfenster", opts);
if (ppWindow) {
ppWindow.focus();
}
}
}
function uiOnSubmit() {
var doConfirmChecks = val.active;
var valResult = (function() {
var ret;
<?lua val.write_js_checks(g_val) ?>
})();
if (doConfirmChecks && valResult !== false) {
var confirmResult = (function() {
var ret;
<?lua val.write_js_checks_no_active(g_val_confirm) ?>
})();
if (confirmResult === false) {
return false;
}
doRepeaterPopup();
}
return valResult;
}
ready.onReady(val.init(uiOnSubmit));
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.out(box.glob.script) ?>" class="close">
<?lua href.default_submit('apply') ?>
<p>
{?8301:577?}
</p>
<hr>
<input type="checkbox" name="enabled" id="uiEnabled" <?lua write_checked() ?>>
<label for="uiEnabled">
{?8301:505?}
</label>
<div class="formular">
<p>
{?8301:705?}
</p>
<p>
<strong>{?txtHinweis?}</strong>
</p>
<p>
{?8301:57?}
</p>
</div>
<hr>
<h4>{?8301:706?}</h4>
<div class="formular">
<p>
{?8301:807?}
</p>
<p>
{?8301:839?}
</p>
<label for="uiPin">
{?8301:593?}
</label>
<input type="text" maxlength="4" size="5" name="pin" id="uiPin" value="****" <?lua val.write_error_class(g_val, "uiPin") ?>>
<?lua val.write_html_msg(g_val, "uiPin") ?>
<p><strong>{?txtHinweis?}</strong></p>
<p>
{?8301:51?}
</p>
</div>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
<input type="hidden" name="sid" value="<?lua box.out(box.glob.sid) ?>">
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
