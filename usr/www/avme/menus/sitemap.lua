<?lua
g_page_type = "all"
g_page_title = [[{?71:46?}]]
g_menu_active_page = "/home/home.lua"
dofile("../templates/global_lua.lua")
require"http"
?>
<?include "templates/html_head.html" ?>
<title>{?71:708?}</title>
<link rel="stylesheet" type="text/css" href="/css/default/twocolumns.css">
<?include "templates/page_head.html" ?>
<div id="uiSitemap" class="twocolumns">
<?lua menu.write_sitemap() ?>
<div style="clear:both;float:left;">*</div>
<div style="float:left; width:98%;">
{?71:315?}
</div>
<div style="clear:both;"></div>
<div>
<hr>
<?lua
box.out([[
<a style="padding-left: 5px;" href="]]..href.get("/support.lua", http.url_param("back_to_page", box.glob.script or ""))..[[">]]
)
box.html([[{?71:68?}]])
box.out('</a>')
box.out('<a style="padding-left: 15px;" href="'..href.get("/services.lua")..'">')
box.html([[{?71:325?}]])
box.out('</a>')
?>
</div>
</div>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
