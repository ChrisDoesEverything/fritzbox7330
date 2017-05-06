<?lua
g_page_type = "all"
g_page_title = "{?9206:301?}"
dofile("../templates/global_lua.lua")
require"html"
require"http"
function write_info()
local info = html.div{}
local product_name = config.PRODUKT_NAME or ""
local f_name = box.query("box:settings/hostname")
if f_name and #f_name > 0 then
product_name = product_name .. ", " .. f_name
end
info.add(html.p{product_name})
local nspver = box.query("logic:status/nspver")
local fritz_os = {
[[{?9206:191?}]],
nspver:gsub("^(.-%.)", ""),
config.LABOR_ID_NAME or ""
}
info.add(html.p{table.concat(fritz_os, " ")})
info.write()
end
function write_iframe()
require("connection")
g_coninf_data = connection.get_conn_inf_part()
if ( connection.Ppp_Led() == "1" or connection.Ppp_Led_Ipv6() == "1" ) then
local src = config.ONLINEHELP_URL
if src then
html.hr{}.write()
src = src .. "&" .. http.url_param("set", "014")
src = src .. "&" .. http.url_param("action", "feature")
html.div{
html.iframe{src=src, style="height:330px;", seamless=true}
}.write()
end
else
box.out([[
<hr>
<p>]], box.tohtml([[{?9206:694?}]]), [[</p>
]])
end
end
?>
<?include "templates/html_head_popup.html" ?>
<?include "templates/page_head_popup.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" id="uiMainForm">
<?lua
write_info()
write_iframe()
?>
</form>
<?include "templates/page_end_popup.html" ?>
<?include "templates/html_end_popup.html" ?>
