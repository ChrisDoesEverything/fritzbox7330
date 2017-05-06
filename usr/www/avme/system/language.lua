<?lua
g_page_type = "all"
g_page_title = ""
dofile("../templates/global_lua.lua")
require"general"
require"html"
require"http"
require"cmtable"
local names = setmetatable({
de = [[{?267:998?}]],
en = [[{?267:251?}]],
fr = [[{?267:65?}]],
el = [[{?267:494?}]],
it = [[{?267:571?}]],
nl = [[{?267:970?}]],
pt = [[{?267:593?}]],
sp = [[{?267:451?}]],
es = [[{?267:348?}]],
tr = [[{?267:880?}]],
pl = [[{?267:97?}]]
}, {
__index = func.const([[{?267:507?}]])
})
local curr_lang = box.query("box:settings/language")
function write_select()
local list = general.listquery("language:settings/language/list(id,LocalName)")
local sel = html.select{name="language"}
local option
for i, lang in ipairs(list) do
option = html.option{value=lang.id, names[lang.id]}
option.selected = lang.id == curr_lang
sel.add(option)
end
sel.write()
end
if box.post.apply then
local saveset = {}
cmtable.add_var(saveset, "box:settings/language", box.post.language)
local err, msg = box.set_config(saveset)
if err == 0 and box.query("box:status/rebooting") ~= "0" then
http.redirect(href.get("/reboot.lua", http.url_param("extern_reboot", "1")))
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
</style>
<script type="text/javascript">
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>" class="narrow">
<?lua href.default_submit('apply') ?>
<p>{?267:70?}</p>
<div class="formular">
<label for="uiLanguage">{?267:346?}</label>
<?lua write_select() ?>
</div>
<br>
<strong>{?267:518?}</strong>
<p>{?267:248?}</p>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
