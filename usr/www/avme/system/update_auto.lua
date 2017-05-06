<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_system_autoupdate"
dofile("../templates/global_lua.lua")
require("general")
require("config")
require("menu")
if not menu.check_page( "system", "/system/update_auto.lua") then
require("http")
require("href")
http.redirect(href.get("/home/home.lua"))
end
if box.post.apply and box.post.autoupdate then
require("cmtable")
local saveset = {}
cmtable.add_var(saveset, "updatecheck:settings/auto_update_mode", box.post.autoupdate)
box.set_config(saveset)
end
g_update_mode = box.query("updatecheck:settings/auto_update_mode")
g_update_modes = {check=true,update_important=true,update_all=config.AUTOUPDATE}
if not g_update_modes[g_update_mode] then
g_update_mode = "update_important"
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<p>
{?10:61?}
</p>
<p>
{?10:861?}
</p>
<br>
<form method="POST" action="<?lua box.html(box.glob.script) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="radio" id="info" value="check" name="autoupdate" <?lua if "check" == g_update_mode then box.out([[checked]]) end ?>>
<label for="info" class="highlighted">{?10:9?}</label>
<p class="form_checkbox_explain">
<?lua
box.out( general.sprintf([[{?10:40?}]], [[<a href="]] .. href.get("/system/push_list.lua") .. [[">]],[[</a>]]) )
?>
</p>
<input type="radio" id="important" value="update_important" name="autoupdate" <?lua if "update_important" == g_update_mode then box.out([[checked]]) end ?>>
<label for="important" class="highlighted">{?10:925?}</label>
<p class="form_checkbox_explain">{?10:545?}</p>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
