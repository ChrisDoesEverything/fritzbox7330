<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_speicherfreigaben.html"
dofile("../templates/global_lua.lua")
require("general")
function write_myfritz_li()
local opmode = box.query("box:settings/opmode")
if opmode ~= 'opmode_eth_ipclient' and opmode ~= 'opmode_modem' then
box.out(
[[<li>]],
general.sprintf(
[[{?275:792?}]],
[[<a href=']]..href.get("/internet/myfritz.lua")..[['>]], [[</a>]]
),
[[</li>]]
)
end
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form id="uiMainForm" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>
{?275:173?}
</p>
<div>
<ul>
<li>
<?lua
box.out(general.sprintf( [[{?275:579?}]], [[<a href=']]..href.get("/storage/settings.lua")..[['>]], [[</a>]]))
?>
</li>
<?lua
write_myfritz_li()
?>
<li>
<?lua
box.out(general.sprintf( [[{?275:635?}]], [[<a href=']]..href.get("/internet/remote_https.lua")..[['>]], [[</a>]]))
?>
</li>
<li>
<?lua
box.out(general.sprintf( [[{?275:233?}]], [[<a href=']]..href.get("/system/boxuser_list.lua")..[['>]], [[</a>]]))
?>
</li>
</ul>
</div>
<div <?lua if box.query("connection0:status/ip_is_private") == "0" then box.out([[style="display:none;"]]) end ?>>
<span class="hintMsg">{?txtHinweis?}</span>
<p>{?275:945?}</p>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
