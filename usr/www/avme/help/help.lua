<?lua
-- de-first -begin
g_page_type = "no_menu"
g_page_title = ""
dofile("../templates/global_lua.lua")
require"helpurl"
require"general"
require"http"
local function isboxonline()
local online = box.query('connection0:status/connect') == "5"
if not online and config.USB_GSM then
online = box.query("umts:settings/enabled") == "1" and box.query("gsm:settings/Established") == "1"
end
return online
end
g_helpurl = ""
if config.ONLINEHELP then
local topic = box.get.helppage or "hilfe_startseite.html"
topic = topic:gsub("%.html","")
g_helpurl = helpurl.get(topic, box.get.anchor)
if isboxonline() then http.redirect(g_helpurl) end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/help.css">
<script type="text/javascript" src="/js/onlinecheck.js"></script>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/help.js"></script>
<script type="text/javascript">
function onlineTestCallback(state) {
var helpurl = "<?lua box.js(g_helpurl) ?>";
if (state > 0) {
location.replace(helpurl);
}
else if (state == 0) {
jxl.setStyle("main_page_all_help", "cursor", "");
jxl.hide("uiWait");
jxl.show("uiOffline");
}
}
var offline = "<?lua box.js(box.get.offline) ?>";
ready.onReady(help.convertBoxlinks);
if (offline != 'yes') {
ready.onReady(function() {
jxl.hide("uiOffline");
jxl.show("uiWait");
jxl.setStyle("main_page_all_help", "cursor", "wait");
onlineTest(100, onlineTestCallback);
});
}
</script>
</head>
<body>
<?lua
local function check_file(filename)
local f, err = io.open("../".. filename)
if f then
f:close()
return true
else
return false
end
end
if box.get.helppage and helpurl.isonbox(box.get.helppage) then
g_helppage = "help/" .. box.get.helppage
else
g_helppage = "help/hilfe_startseite.html"
end
if not check_file(g_helppage) then
g_helppage = "help/hilfe_startseite.html"
end
function write_help_head(title)
box.out([[<div id="page_content_no_menu_box">]])
box.out([[<div class="blue_bar_back">]])
box.out([[<h2>]])
box.html(title or "")
box.out([[</h2>]])
box.out([[</div>]])
box.out([[<div id="page_content" class="page_content">]])
box.out([[<div id="uiWait" style="display:none;">]])
box.html([[{?5108:568?}]])
box.out([[</div>]])
box.out([[<div id="uiOffline"]])
if box.get.hide == "yes" then box.out([[ style="display:none;"]]) end
box.out([[>]])
end
?>
<div id="main_page_all_help">
<?include g_helppage ?>
<?include "help/rback.html" ?>
</div>
</div>
</div>
</div>
<div class="clear_float"></div>
</div>
<?include "templates/html_end.html" ?>
