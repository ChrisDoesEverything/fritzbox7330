<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_system_neustart.html"
dofile("../templates/global_lua.lua")
require("http")
if next(box.post) and box.post.reboot then
require("cmtable")
require("webuicookie")
local savecookie = {}
webuicookie.set_action_allowed_time()
cmtable.add_var(savecookie, webuicookie.vars())
box.set_config(savecookie)
http.redirect(href.get("/reboot.lua"))
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<p>{?6729:135?}</p>
<h4>{?6729:753?}</h4>
<?lua
if config.RAMDISK and box.query("ctlusb:settings/internalflash_enabled") == "1" then
box.out('<p>'..[[{?6729:203?}]]..'</p>')
else
box.out('<p>'..[[{?6729:620?}]]..'</p>')
end
?>
<form action="/system/reboot.lua" method="POST">
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="reboot">{?6729:911?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
