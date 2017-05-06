<?lua
g_page_type = "all"
g_page_title = [[{?369:501?}]]
g_page_help = "hilfe_usb_fernanschluss.html"
dofile("../templates/global_lua.lua")
require("http")
if box.get.ajax and box.get.ajax == "1" then
box.out('{"aura_state":"'..box.query("aura:settings/status")..'"}')
box.end_page()
end
g_back_to_page = http.get_back_to_page( "/usb/usb_remote_settings.lua" )
g_menu_active_page = g_back_to_page
if next(box.post) and box.post.btn_ok then
http.redirect(href.get(g_back_to_page))
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
var g_testText1 = "{?369:69?}";
var g_stateText1 = "{?369:459?}";
var g_testText2 = '{?369:118?}';
var g_stateText2 = "{?369:174?}";
var json = makeJSONParser();
function callback_state(response)
{
if (response && response.status == 200) {
var resp = json(response.responseText);
if (resp)
{
switch (resp.aura_state)
{
case "1" : // AURA_STATUS_READY 1
jxl.setHtml("uiView_TestText", g_testText1);
jxl.changeImage("uiView_TestPic", '/css/default/images/finished_ok_green.gif');
jxl.setHtml("uiPleaseWaitP", g_stateText1);
break;
case "2" : // AURA_STATUS_ERROR 2
jxl.setHtml("uiView_TestText", g_testText2);
jxl.changeImage("uiView_TestPic", '/css/default/images/finished_error.gif');
jxl.setHtml("uiPleaseWaitP", g_stateText2);
break;
default: // AURA_STATUS_CHANGING 0
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
ready.onReady(doRequest);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p id="uiView_TestText">
{?369:216?}
</p>
<p class="waitimg">
<img id="uiView_TestPic" src="/css/default/images/wait.gif">
</p>
<p id="uiPleaseWaitP" class="txt_center">
{?369:117?}
</p>
<div id="btn_form_foot">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>"/>
<button type="submit" name="btn_ok" id="btnOk">{?txtOK?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
