<?lua
-- de-first -begin
--[[
Datei Name: /reboot.lua
Datei Beschreibung: Zwischenseite zur Anzeige während eines Box-Reboots
]]
g_page_type = "no_menu"
g_page_title = [[{?txtFBoxRestart?}]]
g_page_needs_js = true
dofile("../templates/global_lua.lua")
g_extern_reboot = false;
if box.get.extern_reboot then
g_extern_reboot = box.get.extern_reboot=="1"
end
if g_extern_reboot then
g_allowed = true
else
require("webuicookie")
require("cmtable")
g_allowed = webuicookie.check_action_allowed_by_time()
reset_allowed_time = function()
webuicookie.reset("action_allowed")
saveset = {}
cmtable.add_var(saveset, webuicookie.vars())
box.set_config(saveset)
end
if not g_allowed then
reset_allowed_time()
end
g_restart_delay = 0;
if next(box.get) and box.get.delay then
g_restart_delay = tonumber(box.get.delay) or 0
end
end
if box.get.ajax then
if g_allowed then
err = box.set_config({{name="logic:command/reboot", value="1"}})
else
err = "extern"
end
box.out([[{"reboot_state":"]]..box.tohtml(err)..[["}]])
reset_allowed_time()
box.end_page()
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<?include "templates/page_head.html" ?>
<div id="reboot" <?lua if not g_allowed then box.out([[style="display:none;"]]) end?>>
<p>{?2605:716?}</p>
<div>
<div class="wait">
<p class="waitimg"><img src="/css/default/images/wait.gif"></p>
</div>
<p>{?2605:628?}</p>
</div>
</div>
<div id="rebooterror" <?lua if g_allowed then box.out([[style="display:none;"]]) end?>>
<h4>{?2605:286?}</h4>
<p class="ErrorMsg">{?2605:5414?}</p>
</div>
<form action="<?lua href.write([[/home/home.lua]]) ?>" method="GET">
<div id="btn_form_foot" <?lua if g_allowed then box.out([[style="display:none;"]]) end?>>
<button type="submit">{?txtToOverview?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
function default_error()
{
jxl.display("reboot", false);
jxl.display("rebooterror", true);
jxl.display("btn_form_foot", true);
}
function callback_state(response)
{
var json = makeJSONParser();
if (response && response.status == 200)
{
var resp = json(response.responseText);
if (resp)
{
switch (resp.reboot_state)
{
case "0" :
jxl.display("reboot", true);
jxl.display("rebooterror", false);
jxl.display("btn_form_foot", false);
ajaxWaitForBox();
break;
default:
default_error();
break;
}
}
else
{
default_error();
}
}
else
{
default_error();
}
}
var g_Timer;
function doRequest()
{
ajaxGet("<?lua href.write(box.glob.script, 'ajax=1') ?>", callback_state);
window.clearTimeout(g_Timer);
g_Timer = null;
}
function init()
{
if (<?lua box.js(g_extern_reboot) ?>) {
ajaxWaitForBox();
}
else {
var delay = <?lua box.js(g_restart_delay) ?>;
g_Timer = window.setTimeout(doRequest, delay * 1000);
}
}
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
