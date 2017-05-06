<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_erweitert.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("html")
require("http")
g_reverse_on_backtopage = true
g_cmnode = "box:settings/expertmode/activated"
g_expert = box.query(g_cmnode) == "1"
if g_reverse_on_backtopage then
if not (box.get.backtopage or box.post.backtopage or box.post.backtopage_expert) then
http.redirect("/home/home.lua")
end
end
if g_reverse_on_backtopage and box.get.backtopage then
local saveset = {}
cmtable.add_var(saveset, g_cmnode, g_expert and "0" or "1")
box.set_config(saveset)
g_expert = box.query(g_cmnode) == "1"
require"menu"
local backtopage, backtotab = box.get.backtopage, box.get.backtotab
local mode = g_expert and "expertmode" or "standardmode"
local p = href.get("/home/home.lua")
if backtopage then
p = menu.get_page(mode, backtopage, backtotab)
end
http.redirect(p)
end
function write_backtopage()
if box.get.backtopage then
local backtopage, backtotab = box.get.backtopage, box.get.backtotab
if backtopage then
require"menu"
local page_standard = menu.get_page('standardmode', backtopage, backtotab)
local page_expert = menu.get_page('expertmode', backtopage, backtotab)
if page_standard then
html.input{type="hidden", name="backtopage", value=page_standard}.write()
if page_expert and page_standard ~= page_expert then
html.input{type="hidden", name="backtopage_expert", value=page_expert}.write()
end
end
end
end
end
if box.post.apply then
local saveset = {}
cmtable.add_var(saveset, g_cmnode, box.post.expert)
box.set_config(saveset)
g_expert = box.query(g_cmnode) == "1"
end
if (box.post.apply or box.post.cancel) and box.post.backtopage then
local p = g_expert and box.post.backtopage_expert or box.post.backtopage
if p then http.redirect(p) end
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript">
ready.onReady(function() {
showOnClick({
inputName: "expert",
classString: "showif_expert_%1"
});
});
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="/system/expert.lua" name="mainform" id="uiMainform">
<p>
{?860:598?}
</p>
<hr>
<h4>{?860:350?}</h4>
<div class="formular">
<input type="radio" name="expert" value="0" id="uiExpert0" <?lua box.out(not g_expert and "checked" or "") ?>>
<label for="uiExpert0">{?860:340?}</label>
<p class="form_input_explain showif_expert_0">
{?860:591?}
</p>
</div>
<div class="formular">
<input type="radio" name="expert" value="1" id="uiExpert1" <?lua box.out(g_expert and "checked" or "") ?>>
<label for="uiExpert1">{?860:928?}</label>
<p class="form_input_explain showif_expert_1">
{?860:893?}
</p>
</div>
<div class="formular">
<p>
<strong>{?txtHinweis?}</strong>
</p>
<p>
{?860:971?}
</p>
</div>
<?lua write_backtopage() ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<div id="btn_form_foot">
<button type="submit" name="apply">
<?lua
if box.get.backtopage then
box.html([[{?txtApplyOk?}]])
else
box.html([[{?txtApply?}]])
end
?>
</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
