<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_system_anzeige.html"
dofile("../templates/global_lua.lua")
require("general")
require("href")
require("http")
require("cmtable")
require("date")
require("val")
require("bit")
g_back_to_page = http.get_back_to_page( "/system/led_display.lua" )
g_errmsg = nil
g_val = {
prog = [[
]]
}
g_led_display="0"
function read_box_values()
g_led_display =box.query("box:settings/led_display")
end
function refill_user_input_from_post()
g_led_display =box.post.led_display
end
function refill_user_input_from_get()
g_led_display =box.get.led_display
end
if next(box.post) then
if box.post.apply then
read_box_values()
refill_user_input_from_post()
local saveset = {}
cmtable.add_var(saveset, "box:settings/led_display" ,tostring(g_led_display))
local err=0
err, g_errmsg = box.set_config(saveset)
if err==0 then
http.redirect(href.get(g_back_to_page))
else
refill_user_input_from_post()
end
elseif box.post.cancel or box.post.refresh_list then
http.redirect(href.get(g_back_to_page))
return
end
else
read_box_values()
end
function write_led_selected(current)
if (g_led_display==current) then
box.out([[checked="checked"]])
end
return
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<style type="text/css">
</style>
<script type="text/javascript">
<?lua
val.write_js_globals_for_ip_check()
val.write_js_error_strings()
?>
function uiDoOnMainFormSubmit()
{
var ret;
<?lua
val.write_js_checks(g_val)
?>
return true;
}
function init()
{
return true;
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" name="main_form">
<div id="content">
<div>
<h4>{?9839:403?}</h4>
<p>
{?9839:698?}
</p>
<div class="formular">
<p>
<input type="radio" name="led_display" id="uiViewLedDisplay0" value="0" <?lua write_led_selected("0")?>><label for="uiViewLedDisplay0">{?9839:27?}</label>
</p>
<p>
<input type="radio" name="led_display" id="uiViewLedDisplay2" value="2" <?lua write_led_selected("2")?>><label for="uiViewLedDisplay2">{?9839:655?}</label>
<p class="form_input_explain">
{?9839:649?}
</p>
</p>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" id="uiApply" name="apply" >{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
