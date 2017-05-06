<?lua
g_page_type = "all"
g_page_title = ""
g_page_needs_js = true
dofile("../templates/global_lua.lua")
require"general"
require"html"
require"http"
require"href"
require"filter"
require"newval"
require"cmtable"
require"utf8"
require"js"
g_back_to_page = http.get_back_to_page( "/internet/kids_profilelist.lua" )
g_menu_active_page = g_back_to_page
local function get_profile()
local uid = box.get.edit or box.post.edit or ""
return filter.get_profile(uid) or {UID=""}
end
g_profile = get_profile()
local function set_title()
local name = filter.profile_name(g_profile)
return general.sprintf(
[[{?3988:26?}]], name
)
end
g_page_title = set_title()
g_page_help = "hilfe_zugangsprofil_individuell.html"
function write_users_html()
filter.gethtml_list_by_profile(g_profile).write()
end
if box.post.cancel then
http.redirect(g_back_to_page)
end
--XX
-- if g_profile.UID == filter.fixed_profile_uid('unlimited') then
-- elseif g_profile.UID == filter.fixed_profile_uid('never') then
-- end
function write_filter()
if g_profile.UID == filter.fixed_profile_uid('unlimited') then
html.hr{}.write()
html.h4{
[[{?3988:850?}]]
}.write()
html.div{class="formular",
[[{?3988:853?}]]
}.write()
end
end
function write_netapps()
if g_profile.UID == filter.fixed_profile_uid('unlimited') then
html.hr{}.write()
html.h4{
[[{?3988:6?}]]
}.write()
html.div{class="formular",
[[{?3988:286?}]]
}.write()
end
end
function write_time()
local txt
local txt2
if g_profile.UID == filter.fixed_profile_uid('unlimited') then
txt = [[{?3988:811?}]]
elseif g_profile.UID == filter.fixed_profile_uid('never') then
txt = [[{?3988:640?}]]
txt2 = [[{?3988:495?}]]
end
if txt then
html.hr{}.write()
html.h4{
[[{?3988:280?}]]
}.write()
html.div{class="formular", txt}.write()
if txt2 then
html.div{class="formular", txt2}.write()
end
end
end
function write_name()
local txt = [[{?3988:513?}]]
local value = filter.profile_name(g_profile)
html.hr{}.write()
html.div{class="formular widetext",
html.span{class="label", txt},
html.span{class="output", value}
}.write()
end
function write_explain()
local txt = ""
if g_profile then
if g_profile.UID == filter.fixed_profile_uid('unlimited') then
txt = [[{?3988:803?}]]
elseif g_profile.UID == filter.fixed_profile_uid('never') then
txt = [[{?3988:660?}]]
end
end
html.p{txt}.write()
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/timer.css">
<style type="text/css">
.formular span.label {
display: inline-block;
width: 200px;
}
</style>
<script type="text/javascript">
</script>
<?include "templates/page_head.html" ?>
<form id="uiMainform" name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>" class="narrow">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<?lua write_explain() ?>
<?lua write_name() ?>
<?lua write_time() ?>
<?lua write_filter() ?>
<?lua write_netapps() ?>
<?lua write_users_html() ?>
<div id="btn_form_foot">
<button type="submit" name="cancel">
{?txtOK?}
</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
