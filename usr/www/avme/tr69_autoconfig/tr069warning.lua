<?lua
g_page_type = "no_menu"
g_page_title = [[{?9698:74?}]]
dofile("../templates/global_lua.lua")
require"dbg"
require"tr069"
require"cmtable"
require"http"
require"href"
function write_explain_txt()
box.html(config.oem == '1und1' and
[[{?9698:617?}]]
or [[{?9698:508?}]]
)
end
function write_checked()
if tr069.FWdownload_enable == "1" then
box.out([[ checked]])
end
end
if box.post.apply then
local saveset = {}
cmtable.add_var(saveset, "tr069:settings/suppress_autoFWUpdate_notify", "1")
cmtable.add_var(saveset, "tr069:settings/FWdownload_enable", box.post.updatetr069 and "1" or "0")
local e, m = box.set_config(saveset)
http.redirect(href.get("/home/home.lua"))
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
</style>
<script type="text/javascript">
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.out(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<p>
{?9698:131?}
</p>
<p>
{?9698:778?}
</p>
<div class="formular">
<input type="checkbox" id="uiUpdatetr069" name="updatetr069" <?lua write_checked() ?>>
<label for="uiUpdatetr069">
{?9698:852?}
</label>
<p class="form_input_explain">
<?lua write_explain_txt() ?>
</p>
</div>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
</div>
<input type="hidden" name="sid" value="<?lua box.out(box.glob.sid) ?>">
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
