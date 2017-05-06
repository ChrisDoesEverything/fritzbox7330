<?lua
g_page_type = "all"
g_page_title = [[{?603:513?}]]
g_page_help = "hilfe_usb_status.html"
g_menu_active_page = "/usb/show_usb_devices.lua"
dofile("../templates/global_lua.lua")
require("http")
require("cmtable")
require("general")
g_back_to_page = http.get_back_to_page( "/usb/show_usb_devices.lua" )
if box.get.ajax and box.get.ajax == "1" then
box.out('{"unplug_state":"'..box.query("ctlusb:settings/unplug-status")..'"}')
box.end_page()
end
ejected_device = false
if box.get.usbdev and (box.get.usbdev == "all" or (string.find(box.get.usbdev, "physmedium", 1, true) == 1 and string.len(box.get.usbdev) < 14)) then
ejected_device = box.tohtml(box.get.usbdev)
end
if ejected_device then
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "ctlusb:settings/unplug" , ejected_device)
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr=general.create_error_div(err,msg,[[{?603:321?}]])
box.out(criterr)
end
end
if next(box.post) and box.post.btn_ok then
http.redirect(href.get(g_back_to_page))
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
<?lua
if ejected_device == "all" then
box.out([[var g_stateText_fail = ']]..box.tojs([[{?603:53?}]])..[[';
var g_testText_success = ']]..box.tojs([[{?603:378?}]])..[[';
var g_stateText_success = ']]..box.tojs([[{?603:124?}]])..[[';]])
else
box.out([[var g_stateText_fail = ']]..box.tojs([[{?603:169?}]])..[[';
var g_testText_success = ']]..box.tojs([[{?603:77?}]])..[[';
var g_stateText_success = ']]..box.tojs([[{?603:163?}]])..[[';]])
end
?>
var json = makeJSONParser();
function show_error()
{
jxl.changeImage("uiView_TestPic", '/css/default/images/finished_error.gif', '');
jxl.removeClass("uiView_StateText", "txt_center");
jxl.setHtml("uiView_StateText", g_stateText_fail);
jxl.show("btnOk");
}
function callback_state(response)
{
if (response && response.status == 200)
{
var resp = json(response.responseText);
if (resp)
{
switch (resp.unplug_state)
{
case "3" :
jxl.changeImage("uiView_TestPic", '/css/default/images/finished_ok_green.gif', '');
jxl.removeClass("uiView_StateText", "txt_center");
jxl.setHtml("uiView_TestText", g_testText_success);
jxl.setHtml("uiView_StateText", g_stateText_success);
jxl.show("btnOk");
break;
case "0" :
case "1" :
case "4" :
show_error();
break;
default:
window.setTimeout("doRequest()", 5000);
break;
}
}
}
}
function doRequest()
{
ajaxGet("<?lua href.write(box.glob.script, 'ajax=1') ?>", callback_state);
}
function init()
{
<?lua
if ejected_device then
box.out([[window.setTimeout("doRequest()", 5000);]])
else
box.out([[show_error();]])
end
?>
}
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p id="uiView_TestText">
<?lua
if ejected_device == "all" then
box.html([[{?603:831?}]])
g_txt_eject_usb = [[{?603:288?}]]
else
box.html([[{?603:703?}]])
g_txt_eject_usb = [[{?603:19?}]]
end
?>
</p>
<p class="waitimg">
<img id="uiView_TestPic" src="/css/default/images/wait.gif" title="<?lua box.html(g_txt_eject_usb)?>">
</p>
<p id="uiView_StateText" class="txt_center">
<span >{?603:198?}
</p>
<div id="btn_form_foot">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>"/>
<button type="submit" name="btn_ok" id="btnOk" style="display:none;">{?txtApplyOk?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
