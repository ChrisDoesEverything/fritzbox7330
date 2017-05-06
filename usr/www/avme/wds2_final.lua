<?lua
g_page_type = "no_menu"
g_page_title = [[{?8734:707?}]]
dofile("../templates/global_lua.lua")
require"html"
function write_info()
html.table{class="zebra",
html.tr{
html.td{[[{?8734:626?}]]},
html.th{box.get.ssid or ""}
},
html.tr{
html.td{[[{?8734:246?}]]},
html.th{box.get.encryption or ""}
},
html.tr{
html.td{[[{?8734:286?}]]},
html.th{box.get.key or ""}
}
}.write()
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
div.okimage {
width: 100%;
text-align:center;
padding-top:10px;
padding-bottom:20px;
}
</style>
<script type="text/javascript">
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<p>
{?8734:827?}
</p>
<div class="okimage">
<img src="/css/default/images/ok.gif" alt="OK">
</div>
<p>
{?8734:668?}
</p>
<?lua write_info() ?>
<p>
{?8734:612?}
</p>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
