<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_system_wiederherstellen.html"
dofile("../templates/global_lua.lua")
if next(box.post) and box.post.defaults then
require("http")
require("href")
require("cmtable")
require("webuicookie")
webuicookie.set_action_allowed_time()
local savecookie = {}
cmtable.add_var(savecookie, webuicookie.vars())
box.set_config(savecookie)
http.redirect(href.get("/restore.lua", "restore=full"))
end
g_text1 = [[{?3506:778?}]]
g_text3 = [[{?3506:615?}]]
g_text1 = string.gsub(g_text1, "%%1", href.get("/system/export.lua"))
if config.NAND or config.RAMDISK then
g_txt_warning = [[{?3506:706?}]].."\\n\\n"..[[{?3506:245?}]].."\\n "..[[{?3506:536?}]].."\\n\\n"..[[{?3506:200?}]]
else
g_txt_warning = [[{?3506:425?}]].."\\n\\n"..[[{?3506:988?}]].."\\n "
g_txt_warning = g_txt_warning..[[{?3506:23?}]].."\\n\\n"..[[{?3506:306?}]]
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#uiInfo {
padding:0px 0px 0px 15px;
margin:0px;
}
#uiInfo li{
margin:5px;
}
</style>
<script type="text/javascript">
function init() {
var form = jxl.get("uiMainForm");
if (form) {
form.onsubmit = function() {
return confirm("<?lua box.out(g_txt_warning) ?>");
}
}
}
window.onload = init;
</script>
<?include "templates/page_head.html" ?>
<p>
{?3506:590?}
</p>
<h4>{?3506:50?}</h4>
<ul id="uiInfo">
<li><?lua box.out(g_text1) ?></li>
<li><?lua box.out(g_text3) ?></li>
</ul>
<form action="/system/defaults.lua" method="POST" id="uiMainForm">
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="defaults">{?3506:214?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
