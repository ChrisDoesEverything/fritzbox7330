<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = 'hilfe_dslinfo_ATM.html'
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("http")
g_back_to_page = http.get_back_to_page( "/internet/vdsl_profile.lua" )
if (next(box.post) and (box.post.cancel)) then
http.redirect([[/internet/vdsl_profile.lua]])
end
g_errcode = 0
g_errmsg = [[Fehler: Es ist ein Fehler beim Übernehmen der Daten aufgetreten. Die aktuellen Daten dieser Seite wurden nicht gespeichert.]]
g_data={}
g_val = {
prog = [[
]]
}
if next(box.post) then
local saveset={}
if (box.post.send_profile ) then
cmtable.add_var(saveset,"vdsl:settings/vdsl_profile",box.post.vdsl_profile)
elseif next(box.post) and (box.post.send_profile ) then
cmtable.add_var(saveset,"vdsl:settings/vdsl_filter",box.post.vdsl_filter)
end
local err=0
err, g_errmsg = box.set_config(saveset)
if err==0 then
http.redirect(href.get(g_back_to_page))
end
end
function write_selected_profile(val)
local profile=box.query("vdsl:settings/vdsl_profile")
if (val==profile) then
box.out([[selected]])
end
end
function write_selected_filter(val)
local filter=box.query("vdsl:settings/vdsl_filter")
if (val==filter) then
box.out([[selected]])
end
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
function uiDoOnMainFormSubmit()
{
}
function init()
{
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "send", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div class="formular">
<span>{?5005:327?}</span>
<select name="vdsl_profile" id="vdsl_profile_box">
<option value="0" <?lua write_selected_profile("0")?>>{?5005:184?}</option>
<option value="1" <?lua write_selected_profile("1")?>>{?5005:424?}</option>
<option value="2" <?lua write_selected_profile("2")?>>{?5005:535?}</option>
<option value="3" <?lua write_selected_profile("3")?>>{?5005:546?}</option>
<option value="4" <?lua write_selected_profile("4")?>>{?5005:421?}</option>
<option value="5" <?lua write_selected_profile("5")?>>{?5005:695?}</option>
<option value="6" <?lua write_selected_profile("6")?>>{?5005:120?}</option>
<option value="7" <?lua write_selected_profile("7")?>>{?5005:428?}</option>
</select>
<button type="submit" name="send_profile">{?5005:226?}</button>
</div>
<hr>
<div class="formular">
<span>{?5005:114?}</span>
<select name="vdsl_filter" id="vdsl_filter_box">
<option value="0" <?lua write_selected_filter("0")?>>{?5005:894?}</option>
<option value="1" <?lua write_selected_filter("1")?>>{?5005:374?}</option>
<option value="2" <?lua write_selected_filter("2")?>>{?5005:822?}</option>
</select>
<button type="submit" name="send_filter">{?5005:682?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
