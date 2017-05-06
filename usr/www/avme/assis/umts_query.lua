<?lua
g_page_type = "all"
g_page_title = [[{?3920:661?}]]
------------------------------------------------------------------------------------------------------------>
dofile("../templates/global_lua.lua")
require("cmtable")
require("http")
if (next(box.post)) then
local target=href.get("/assis/home.lua")
if (box.post.apply) then
target=href.get("/internet/umts_settings.lua")
end
http.redirect(target)
return
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form method="POST" action="/assis/umts_query.lua">
<div class="formular">
<p>
{?3920:340?}
</p>
<p>
{?3920:250?}
</p>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="apply">{?g_txt_Weiter?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
