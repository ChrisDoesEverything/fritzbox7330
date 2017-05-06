<?lua
--[[
Datei Name: imexport.lua
Datei Beschreibung: Assistentenseite um zu entscheiden ob der Nutzer Seine Einstellungen sichern oder wiederherstellen möchte.
Tags: avm@assi
]]
g_page_type = "wizard"
g_page_title = [[{?9320:927?}]]
dofile("../templates/global_lua.lua")
require("http")
require("href")
g_back_to_page = http.get_back_to_page( "/assis/home.lua" )
if next(box.post) then
if box.post.btnNext then
if box.post.imexport == "0" then
http.redirect(href.get("/system/export.lua", "back_to_page="..g_back_to_page, "exportmode=as"))
elseif box.post.imexport == "1" then
http.redirect(href.get("/system/import.lua", "back_to_page="..g_back_to_page, "importmode=as"))
else
http.redirect(href.get(g_back_to_page))
end
elseif box.post.cancel then
http.redirect(href.get(g_back_to_page))
end
end
?>
<?include "templates/html_head.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">]])
end
?>
<?include "templates/page_head.html" ?>
<form name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div>{?9320:606?}</div>
<hr>
<div class="formular">
<div>
<input type="radio" name="imexport" id="uiExport" value="0" checked>
<label for="uiExport">{?9320:47?}</label>
</div>
<div>
<input type="radio" name="imexport" id="uiImport" value="1">
<label for="uiImport">{?9320:645?}</label>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<button type="submit" name="btnNext" id="btnNext">{?txtNext?}</button>
<button type="submit" name="cancel" id="uiCancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<script type="text/javascript" src="/js/wizard.js?lang="]],config.language,[["></script>]])
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
end
?>
<?include "templates/html_end.html" ?>
