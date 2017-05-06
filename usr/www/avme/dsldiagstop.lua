<?lua
--[[
Datei Name: dsldiagstop.lua
Datei Beschreibung: DSL-Diagnose stoppen
]]
g_page_type = "no_menu"
g_page_title = [[{?1668:275?}]]
dofile("../templates/global_lua.lua")
if box.post.save_data then
require("http")
if config.LABOR_DSL then
http.redirect(href.get("/support.lua"))
else
require("cmtable")
local saveset = {}
cmtable.add_var(saveset, "sar:settings/DslDiagnosticStart", "0")
box.set_config(saveset)
end
end
if box.post.cancel then
http.redirect(href.get("/support.lua"))
end
require("general")
g_message = [[{?1668:438?}]]
if config.LABOR_DSL then
g_page_title = [[{?1668:411?}]]
else
g_message = g_message..[[ {?1668:318?}]]
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript">
function init() {
var form = jxl.get("uiMainForm");
if (form) { form.onsubmit = uiDoOnMainFormSubmit; }
<?lua
if box.post.save_data then
box.out([[download();]])
end
?>
}
function download() {
jxl.submitForm("download_form");
}
function uiDoOnMainFormSubmit() {
return true;
}
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<?lua
if box.post.save_data or box.query("sar:settings/DslDiagnosticStart") == "1" then
box.out([[
<p>]]..box.tohtml(g_message)..[[</p>
<form method="POST" action="]]..href.get(box.glob.script)..[[" id="uiMainForm">
<button type="submit" name="save_data">{?1668:990?}</button>
</form>
<form name="download_form" method="POST" action="/cgi-bin/firmwarecfg" enctype="multipart/form-data">
<input type="hidden" name="sid" value="]]..box.tohtml(box.glob.sid)..[[">
<input type="hidden" name="DSLData">
</form>
]])
else
box.out([[
<p>]]..general.sprintf([[{?1668:193?}]], [[<a href="]]..href.get("/support.lua")..[[">]], [[</a>]])..[[</p>
]])
end
?>
<form name="cancelform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<div id="btn_form_foot">
<button type="submit" name="cancel">{?txtOK?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
