<?lua
-- de-first -begin
g_page_type = "no_menu"
g_page_title = [[{?207:32?}]]
g_fallback_redirect_url = [[http://192.168.178.1/]]
g_page_needs_js = true
------------------------------------------------------------------------------------------------------------>
dofile("../templates/global_lua.lua")
require("webuicookie")
require("cmtable")
g_allowed = webuicookie.check_action_allowed_by_time()
function reset_allowed_time()
webuicookie.reset("action_allowed")
saveset = {}
cmtable.add_var(saveset, webuicookie.vars())
box.set_config(saveset)
end
if not g_allowed then
reset_allowed_time()
end
if box.get.ajax and box.get.restore and (box.get.restore == "login" or box.get.restore == "full") then
local saveset = {}
local err = -1
if g_allowed then
local command = "login:command/defaults"
if box.get.restore == "full" then
command = "logic:command/defaults"
end
cmtable.add_var(saveset, command, "1")
if box.get.restore == "full" and (config.RAMDISK or config.NAND) then
cmtable.add_var(saveset, "logic:command/defaults_init_internal_flash", "1")
end
err = box.set_config(saveset)
else
err = "extern"
end
box.out([[{"restore_state":"]]..box.tohtml(err)..[["}]])
reset_allowed_time()
box.end_page()
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<?include "templates/page_head.html" ?>
<div id="restore" <?lua if not g_allowed then box.out([[style="display:none;"]]) end?>>
<p>{?207:425?}</p>
<p>{?207:183?}</p>
<div>
<div class="wait">
<p class="waitimg"><img src="/css/default/images/wait.gif"></p>
</div>
<p>{?207:995?}</p>
</div>
</div>
<div id="restoreerror" <?lua if g_allowed then box.out([[style="display:none;"]]) end?>>
<h4>{?207:351?}</h4>
<div id="restoreerror1" style="display:none;">
<p class="ErrorMsg">{?207:992?}</p>
<p>{?207:699?}</p>
</div>
<div id="restoreerror2" <?lua if g_allowed then box.out([[style="display:none;"]]) end?>>
<p class="ErrorMsg">{?207:998?}</p>
<p>{?207:884?}</p>
<p>{?207:311?}</p>
<p>{?207:680?}</p>
</div>
</div>
<form action="<?lua href.write([[/home/home.lua]]) ?>" method="GET">
<div id="btn_form_foot" <?lua if g_allowed then box.out([[style="display:none;"]]) end?>>
<button type="submit">{?txtToOverview?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
var json = makeJSONParser();
var g_allowed = <?lua box.js(g_allowed) ?>;
function default_error()
{
jxl.display("restore", false);
jxl.display("restoreerror", true);
jxl.display("restoreerror1", false);
jxl.display("restoreerror2", true);
jxl.display("btn_form_foot", true);
}
function doRedirectToStartpage()
{
top.location.href = "<?lua box.js(g_fallback_redirect_url) ?>";
}
function callback_state(response)
{
if (response && response.status == 200)
{
var resp = json(response.responseText);
if (resp)
{
switch (resp.restore_state)
{
case "0" :
jxl.display("restore", true);
jxl.display("restoreerror", false);
jxl.display("restoreerror1", false);
jxl.display("restoreerror2", false);
jxl.display("btn_form_foot", false);
ajaxWaitForBox();
window.setTimeout(doRedirectToStartpage, 300000);
break;
case "2" :
jxl.display("restore", false);
jxl.display("restoreerror", true);
jxl.display("restoreerror1", true);
jxl.display("restoreerror2", false);
jxl.display("btn_form_foot", true);
break;
case "extern" :
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
function doRequest()
{
if (g_allowed)
{
ajaxGet("<?lua href.write(box.glob.script, 'ajax=1', 'restore='..box.get.restore) ?>", callback_state);
}
}
ready.onReady(doRequest);
</script>
<?include "templates/html_end.html" ?>
