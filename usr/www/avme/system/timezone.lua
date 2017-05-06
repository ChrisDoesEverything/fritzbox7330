<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_system_timeZone.html"
dofile("../templates/global_lua.lua")
require"general"
require"html"
require"cmtable"
local timezone = general.lazytable({}, box.query, {
enabled = {"time:settings/tz_enabled"},
offset = {"time:settings/tz_offset"},
offset_minutes = {"time:settings/tz_offset_minutes"},
dst_enabled = {"time:settings/tz_dst_enabled"}
})
local offset_minutes = {
{id = "720", txt = [[{?9017:257?}]]},
{id = "660", txt = [[{?9017:110?}]]},
{id = "600", txt = [[{?9017:435?}]]},
{id = "570", txt = [[{?9017:994?}]]},
{id = "540", txt = [[{?9017:126?}]]},
{id = "480", txt = [[{?9017:492?}]]},
{id = "420", txt = [[{?9017:600?}]]},
{id = "360", txt = [[{?9017:470?}]]},
{id = "300", txt = [[{?9017:345?}]]},
{id = "270", txt = [[{?9017:398?}]]},
{id = "240", txt = [[{?9017:40?}]]},
{id = "210", txt = [[{?9017:227?}]]},
{id = "180", txt = [[{?9017:586?}]]},
{id = "150", txt = [[{?9017:907?}]]},
{id = "120", txt = [[{?9017:883?}]]},
{id = "60", txt = [[{?9017:923?}]]},
{id = "0", txt = [[{?9017:613?}]]},
{id = "-60", txt = [[{?9017:43?}]]},
{id = "-120", txt = [[{?9017:274?}]]},
{id = "-180", txt = [[{?9017:53?}]]},
{id = "-210", txt = [[{?9017:667?}]]},
{id = "-240", txt = [[{?9017:123?}]]},
{id = "-270", txt = [[{?9017:372?}]]},
{id = "-300", txt = [[{?9017:1866?}]]},
{id = "-330", txt = [[{?9017:233?}]]},
{id = "-345", txt = [[{?9017:203?}]]},
{id = "-360", txt = [[{?9017:229?}]]},
{id = "-390", txt = [[{?9017:616?}]]},
{id = "-420", txt = [[{?9017:655?}]]},
{id = "-480", txt = [[{?9017:559?}]]},
{id = "-525", txt = [[{?9017:909?}]]},
{id = "-540", txt = [[{?9017:554?}]]},
{id = "-570", txt = [[{?9017:879?}]]},
{id = "-585", txt = [[{?9017:926?}]]},
{id = "-600", txt = [[{?9017:812?}]]},
{id = "-630", txt = [[{?9017:341?}]]},
{id = "-660", txt = [[{?9017:713?}]]},
{id = "-690", txt = [[{?9017:938?}]]},
{id = "-720", txt = [[{?9017:185?}]]},
{id = "-765", txt = [[{?9017:313?}]]},
{id = "-780", txt = [[{?9017:760?}]]},
{id = "-825", txt = [[{?9017:882?}]]},
{id = "-840", txt = [[{?9017:706?}]]}
}
function write_options()
local default = "0"
if timezone.enabled then
default = timezone.offset_minutes
end
local option
for i, offset in ipairs(offset_minutes) do
option = html.option{value=offset.id, offset.txt}
option.selected = offset.id == default
option.write()
end
end
function write_checked(what)
if timezone[what] == "1" then
box.out([[ checked]])
end
end
if box.post.apply then
local saveset = {}
local anychange = false
local enabled = box.post.enabled and "1" or "0"
anychange = enabled ~= timezone.enabled
cmtable.add_var(saveset, "time:settings/tz_enabled", enabled)
local offset = box.post.offset or "0"
anychange = anychange or offset ~= timezone.offset_minutes
cmtable.add_var(saveset, "time:settings/tz_offset_minutes", offset)
local dst_enabled = box.post.dst_enabled and "1" or "0"
anychange = anychange or dst_enabled ~= timezone.dst_enabled
cmtable.add_var(saveset, "time:settings/tz_dst_enabled", dst_enabled)
local err, msg = box.set_config(saveset)
if err == 0 and anychange then
require("webuicookie")
saveset = {}
webuicookie.set_action_allowed_time()
cmtable.add_var(saveset, webuicookie.vars())
box.set_config(saveset)
http.redirect(href.get("/reboot.lua"))
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
</style>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript">
ready.onReady(function(){
enableOnClick({inputName: "enabled", classString: "enableif_tzenabled"});
});
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>" class="extremwide">
<?lua href.default_submit('apply') ?>
<p>
{?9017:699?}
</p>
<div>
<input type="checkbox" id="uiEnabled" name="enabled" <?lua write_checked('enabled') ?>>
<label for="uiEnabled">{?9017:765?}</label>
</div>
<div class="formular">
<label for="uiOffset">
{?9017:629?}
</label>
<select name="offset" id="uiOffset" class="enableif_tzenabled">
<?lua write_options() ?>
</select>
</div>
<div class="formular">
<input type="checkbox" id="uiDst_enabled" name="dst_enabled" class="enableif_tzenabled" <?lua write_checked('dst_enabled') ?>>
<label for="uiDst_enabled">
{?9017:214?}
</label>
</div>
<br>
<strong>{?9017:808?}</strong>
<p>{?9017:255?}</p>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
