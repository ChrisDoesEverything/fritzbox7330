<?lua
package.path = "../?/?.lua;../lua/?.lua;../?.lua"
require("nas_init")
if gl.var.site == "help" then
local function isboxonline()
local online = box.query('connection0:status/connect') == "5"
if not online and config.USB_GSM then
online = box.query("umts:settings/enabled") == "1" and box.query("gsm:settings/Established") == "1"
end
return online
end
if config.ONLINEHELP and isboxonline() then
gl.bib.helpurl = require("helpurl")
local topic = gl.helppage or "hilfe_startseite.html"
topic = topic:gsub("%.html","")
local str_helpurl = ""
str_helpurl = gl.bib.helpurl.get(topic)
gl.bib.http.redirect(str_helpurl)
end
end
?>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv=content-type content="text/html; charset=utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta name="format-detection" content="telephone=no" />
<meta http-equiv="x-rim-auto-match" content="none" />
<meta name="mobile-web-app-capable" content="no" />
<meta name="apple-mobile-web-app-capable" content="no" />
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no" />
<?lua
if gl.var.site == "help" then
box.out([[<title>]]..box.tohtml([[{?6777:861?}]])..[[</title>]])
else
box.out([[<title>]]..box.tohtml([[{?6777:968?}]])..[[</title>]])
end
box.out([[<link rel="shortcut icon" type="image/x-icon" href="/nas/css/]]..box.tohtml(gl.var.style)..[[/images/favicon.ico">]])
box.out([[
<link rel="stylesheet" type="text/css" href="/nas/css/]]..box.tohtml(gl.var.style)..[[/main.css"/>
<link rel="stylesheet" type="text/css" href="/nas/css/]]..box.tohtml(gl.var.style)..[[/disable_page.css"/>
]])
if gl.show_logout and not gl.filelink_mode then
box.out([[
<link rel="stylesheet" type="text/css" href="/nas/css/]]..box.tohtml(gl.var.style)..[[/sso_dropdown.css"/>
]])
end
if not gl.logged_in or gl.var.site == "sso_editmyself" then
box.out([[
<link rel="stylesheet" type="text/css" href="/nas/css/]]..box.tohtml(gl.var.style)..[[/login.css"/>
]])
end
box.out([[<script type="text/javascript" src="/nas/js/jxl.js"></script>
<script type="text/javascript" src="/nas/js/ready.js"></script>]])
if gl.logged_in and gl.var.site ~= "sso_editmyself" then
gl.bib.jsinit.write_gl_as_js_with_script_tags(gl)
box.out([[<script type="text/javascript" src="/nas/js/disable_page.js"></script>
<script type="text/javascript" src="/nas/js/history.js"></script>
<script type="text/javascript" src="/nas/js/drag_and_drop.js"></script>
<script type="text/javascript" src="/nas/js/ajax.js"></script>]])
if gl.show_logout and not gl.filelink_mode then
box.out([[<script type="text/javascript" src="/nas/js/sso_dropdown.js"></script>]])
end
end
box.out([[
<script type="text/javascript">
var gJsStyle = "]]..box.tojs(gl.var.style)..[[";]])
if gl.logged_in and gl.var.site ~= "help" and gl.var.site ~= "sso_editmyself" and not gl.from_internet then
box.out([[
function preloadImages()
{
var imgArray = ["/nas/css/"+gJsStyle+"/images/suchfeld_loeschen_down.png",
"/nas/css/"+gJsStyle+"/images/suchfeld_loeschen_normal.png",
"/nas/css/"+gJsStyle+"/images/suchfeld_loeschen_over.png",
"/nas/css/"+gJsStyle+"/images/suchfeld_lupe_disabled.png",
"/nas/css/"+gJsStyle+"/images/suchfeld_lupe_down.png",
"/nas/css/"+gJsStyle+"/images/suchfeld_lupe_normal.png",
"/nas/css/"+gJsStyle+"/images/suchfeld_lupe_over.png",
"/nas/css/"+gJsStyle+"/images/please_wait_bright.gif",
"/nas/css/"+gJsStyle+"/images/download.png",
"/nas/css/"+gJsStyle+"/images/download_dis.png",
"/nas/css/"+gJsStyle+"/images/share.png",
"/nas/css/"+gJsStyle+"/images/share_dis.png",
"/nas/css/"+gJsStyle+"/images/icon_umbenennen.png",
"/nas/css/"+gJsStyle+"/images/icon_umbenennen_dis.png",
"/nas/css/"+gJsStyle+"/images/papierkorb.png",
"/nas/css/"+gJsStyle+"/images/papierkorb_dis.png",
"/nas/css/"+gJsStyle+"/images/icon_ausschneiden.png",
"/nas/css/"+gJsStyle+"/images/icon_ausschneiden_dis.png",
"/nas/css/"+gJsStyle+"/images/icon_einfuegen.png",
"/nas/css/"+gJsStyle+"/images/icon_einfuegen_dis.png",
"/nas/css/"+gJsStyle+"/images/icon_ordner_neu.png",
"/nas/css/"+gJsStyle+"/images/icon_ordner_neu_dis.png",
"/nas/css/"+gJsStyle+"/images/icon_ordner_nach_oben.png",
"/nas/css/"+gJsStyle+"/images/ordner.png",
"/nas/css/"+gJsStyle+"/images/ordner_dokument.gif",
"/nas/css/"+gJsStyle+"/images/ordner_online_speicher.png",
"/nas/css/"+gJsStyle+"/images/ordner_usb_speicher.png",
"/nas/css/"+gJsStyle+"/images/icon_andere_datei_20x20px.png",
"/nas/css/"+gJsStyle+"/images/icon_bild_20x20px.png",
"/nas/css/"+gJsStyle+"/images/icon_dokument_20x20px.png",
"/nas/css/"+gJsStyle+"/images/icon_film_20x20px.png",
"/nas/css/"+gJsStyle+"/images/icon_musik_20x20px.png"];
imgPreload = new Array();
for(var i=0; i < imgArray.length; i++)
{
imgPreload[i] = new Image();
imgPreload[i].src = imgArray[i];
}
}]])
end
box.out([[function init() {]])
if gl.logged_in and gl.var.site ~= "help" and gl.var.site ~= "sso_editmyself" and not gl.from_internet then
box.out([[
preloadImages();
]])
end
box.out([[
if (typeof(local_init)=="function")
local_init();
}
ready.onReady(init);
</script>]])
?>
</head>
<body>
<?lua
if gl.logged_in and gl.show_logout and gl.var.site ~= "sso_editmyself" and not gl.filelink_mode then
require"sso_dropdown"
sso_dropdown.init{
logout_link = "/nas/index.lua"..gl.bib.gpl.get_parameter_line_for_link({logout="1"}),
email_link = gl.bib.href.get("/nas/index.lua", "own_email=", "back_to_page=/nas/index.lua"),
password_link = gl.bib.href.get("/nas/index.lua", "own_password=", "back_to_page=/nas/index.lua")
}
sso_dropdown.write_list()
end
?>
<div id="main_page_main_menu">
<?lua
mainmenu = ""
if not gl.logged_in or (gl.logged_in and (gl.var.site == "help" or gl.var.site == "sso_editmyself")) then
mainmenu = "main_menu/main_menu_login.lua"
else
mainmenu = "main_menu/main_menu.lua"
end
?>
<?include mainmenu ?>
</div>
<div id="page_middle_box">
<div id="main_page_sub_menu_box" <?lua if not gl.logged_in or (gl.logged_in and (gl.var.site == "help" or gl.var.site == "sso_editmyself")) then box.out([[style="display: none;"]]) end ?>>
<?lua
sub_menu_middle = ""
if gl.logged_in and gl.var.site ~= "help" and gl.var.site ~= "sso_editmyself" then
sub_menu_middle = "sub_menu/sub_menu.lua"
end
?>
<?include sub_menu_middle ?>
</div>
<?lua
if gl.var.site == "help" then
box.out([[<div>]])
else
box.out([[<div id="main_page_content">]])
end
if not gl.logged_in then
content = "login.lua"
elseif gl.logged_in and (gl.var.site == "help") then
content = "help/help.lua"
elseif gl.logged_in and (gl.var.site == "share") then
content = "share/share.lua"
elseif gl.logged_in and (gl.var.site == "pictures") then
content = "pimumodo.lua"
elseif gl.logged_in and gl.var.site == "sso_editmyself" then
content = "sso_editmyself.lua"
else
content = [[files/files.lua]]
end
?>
<?include content ?>
</div>
</div>
<div id="main_page_sub_menu_foot" <?lua if not gl.logged_in or gl.var.site == "help" or gl.var.site == "sso_editmyself" then box.out([[style="display: none;"]]) end ?>>
<?lua
foot_menu = ""
if gl.logged_in and gl.var.site ~= "help" and gl.var.site ~= "sso_editmyself" then
foot_menu = "sub_menu/foot_menu.lua"
end
?>
<?include foot_menu ?>
</div>
<?lua if log then log.output{only_errors=true} end ?>
</body>
</html>
