<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_filter_zugangsprofile.html"
dofile("../templates/global_lua.lua")
require"general"
require"html"
require"http"
require"href"
require"filter"
require"cmtable"
require"js"
g_err = {code=0}
if box.post.edit then
local page = "internet/kids_profileedit.lua"
if not filter.editable{UID=box.post.edit} then
page = "internet/kids_profileinfo.lua"
end
http.redirect(
href.get(page,
http.url_param("edit", box.post.edit),
http.url_param("back_to_page", box.glob.script)
)
)
end
if box.post.delete then
local webvar = string.format("filter_profile:command/profile[%s]", box.post.delete)
local saveset = {}
cmtable.add_var(saveset, webvar, "delete")
g_err.code, g_err.msg = box.set_config(saveset)
if g_err.code == 0 then
http.redirect(box.glob.script)
end
end
function write_error()
if g_err.code and g_err.code ~= 0 then
require"general"
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
local function edit_delete_btns(profile)
return html.fragment(
html.button{
type="submit", class="icon", name="edit", value=profile.UID,
html.img{
src="/css/default/images/bearbeiten.gif",
title = [[{?txtIconBtnEdit?}]]
}
},
html.button{
type="submit", class="icon", name="delete", value=profile.UID,
disabled=filter.is_fixed(profile),
onclick = string.format([[return confirmDelete("%s");]], box.tojs(filter.profile_name(profile))),
html.img{
src = "/css/default/images/loeschen.gif",
title = [[{?txtIconBtnDelete?}]]
}
}
)
end
function write_list()
filter.sort_profiles()
local tbl = html.table{class="zebra",id="uiProfileList"}
tbl.add(html.tr{class="thead",
html.th{class="name sortable", [[{?7249:93?}]],html.span({class="sort_no",html.raw([[&nbsp;]])})},
html.th{class="sortable", [[{?7249:635?}]],html.span({class="sort_no",html.raw([[&nbsp;]])})},
html.th{class="sortable",[[{?7249:252?}]],html.span({class="sort_no",html.raw([[&nbsp;]])})},
html.th{class="sortable",[[{?7249:674?}]],html.span({class="sort_no",html.raw([[&nbsp;]])})},
html.th{class="sortable apps", [[{?7249:448?}]],html.span({class="sort_no",html.raw([[&nbsp;]])})},
html.th{class="btncolumn"}
})
for i, profile in ipairs(filter.profilelist()) do
local name = filter.profile_name(profile)
tbl.add(html.tr{
html.td{class="name", title=name, name},
html.td{filter.display_time_restriction(profile)},
html.td{filter.display_share_budget(profile)},
html.td{filter.display_filterlist(profile)},
html.td{class="apps", filter.display_apps(profile)},
html.td{class="btncolumn", edit_delete_btns(profile)}
})
end
tbl.write()
end
function write_apps_td_style()
local style = ""
if general.is_expert() then
style = "width: 200px;"
else
style = "display: none;"
end
box.out("th.apps, td.apps {", style, "}")
end
function write_delete_msg_js()
local msg = {
[[{?7249:377?}]],
general.sprintf(
[[{?7249:334?}]],
filter.fixed_profile_name("filtprof1")
)
}
box.out(js.array(msg))
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
table.zebra {
table-layout: fixed;
}
th.name, td.name {
overflow:hidden;
text-overflow: ellipsis;
width: 200px;
}
<?lua write_apps_td_style() ?>
</style>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=sorter();
function confirmDelete(name) {
var msg = [<?lua write_delete_msg_js() ?>];
msg[0] = jxl.sprintf(msg[0], name || "");
if (!confirm(msg.join("\n\n"))) {
return false;
}
}
function initTableSorter() {
sort.init("uiProfileList");
sort.setDirection(0,-1);
sort.sort_table(0);
}
ready.onReady(initTableSorter);
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua write_error() ?>
<p>
{?7249:390?}
</p>
<?lua write_list() ?>
<div class="btn_form">
<button type="submit" name="edit" value="">{?7249:996?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
