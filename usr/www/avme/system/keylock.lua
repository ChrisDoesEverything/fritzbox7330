<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_system_tastensperre.html"
dofile("../templates/global_lua.lua")
require("general")
require("href")
require("cmtable")
require("date")
require("val")
require("bit")
g_errmsg = nil
g_val = {
prog = [[
]]
}
if next(box.post) then
if box.post.apply then
local saveset = {}
cmtable.add_var(saveset, "box:settings/button_events_disable", box.post.keylock_enabled and "1" or "0")
local err, msg = box.set_config(saveset)
if err~=0 then
g_errmsg = general.create_error_div(err,msg)
end
end
end
function write_keylock_selected()
if (box.query("box:settings/button_events_disable") == "1") then
box.out([[checked="checked" ]])
end
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<style type="text/css">
</style>
<script type="text/javascript">
<?lua
val.write_js_globals_for_ip_check()
val.write_js_error_strings()
?>
function uiDoOnMainFormSubmit()
{
var ret;
<?lua
val.write_js_checks(g_val)
?>
return true;
}
function init()
{
return true;
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" name="main_form">
<div>
<p>
{?274:66?}
</p>
<br>
<input type="checkbox" name="keylock_enabled" id="keylockEnabled" value="1" <?lua write_keylock_selected()?>>
<label for="keylockEnabled">{?274:688?}</label>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" id="uiApply" name="apply" >{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
