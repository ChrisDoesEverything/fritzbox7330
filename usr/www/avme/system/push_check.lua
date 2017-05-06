<?lua
g_page_type = "all"
g_page_title = [[{?9703:8216?}]]
dofile("../templates/global_lua.lua")
require"http"
require"push_check_html"
require"html"
g_back_to_page = http.get_back_to_page( "/system/push_account.lua" )
g_menu_active_page = g_back_to_page
if box.get.back then
http.redirect(g_back_to_page)
end
function write_back_to_page()
if g_back_to_page then
html.input{type="hidden", name="back_to_page", value=g_back_to_page}.write()
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
<?lua
push_check_html.get_javascripts()
?>
</script>
<?include "templates/page_head.html" ?>
<?lua
push_check_html.get_html("refresh", "back", write_back_to_page, "hilfe_system_pushservice_test.html")
?>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
