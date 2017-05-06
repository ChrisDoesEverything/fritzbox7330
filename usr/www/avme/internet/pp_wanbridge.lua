<?lua
g_page_type = "all"
g_page_title = "{?8745:180?}"
dofile("../templates/global_lua.lua")
require"html"
function write_ips()
local tbl = html.table({class="zebra"})
tbl.add(html.tr({},
html.td({}, [[{?8745:866?}:]]),
html.td({}, box.get.ipaddr or "")
))
tbl.add(html.tr({},
html.td({}, [[{?8745:404?}:]]),
html.td({}, box.get.netmask or "")
))
if box.get.dhcp then
tbl.add(html.tr({},
html.td({}, [[{?8745:920?}:]]),
html.td({}, [[{?8745:937?}]])
))
tbl.add(html.tr({},
html.td({}, [[{?8745:7?}:]]),
html.td({}, box.get.dhcpstart or "")
))
tbl.add(html.tr({},
html.td({}, [[{?8745:244?}:]]),
html.td({}, box.get.dhcpend or "")
))
end
tbl.write()
end
function write_hints()
if box.get.oma then
html.strong({}, [[{?txtHinweis?}]]).write()
html.p({}, [[{?8745:299?}]]).write()
else
html.p({}, [[{?8745:63?}]]).write()
end
end
?>
<?include "templates/html_head_popup.html" ?>
<?include "templates/page_head_popup.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" id="uiMainForm">
<div id="content">
<div class="formular">
<p>{?8745:863?}</p>
<?lua write_ips() ?>
<?lua write_hints() ?>
<p>{?8745:912?}</p>
</div>
</div>
</form>
<?include "templates/page_end_popup.html" ?>
<?include "templates/html_end_popup.html" ?>
