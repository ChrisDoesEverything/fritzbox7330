<?lua
g_page_type = "all"
g_page_title = [[{?585:222?}]]
g_page_help = "hilfe_system_pushservice_ee.html"
dofile("../templates/global_lua.lua")
require"cmtable"
require"newval"
require"js"
require"html"
require"http"
require"general"
require"pushservice"
g_back_to_page = http.get_back_to_page( "/system/push_list.lua" )
g_menu_active_page = g_back_to_page
g_data = {}
g_data.enabled = false
g_data.interval = "weekly"
g_data.show_fonstat = true
g_data.show_kidsstat = true
g_data.show_onlinecntstat = true
g_data.show_eventlist = true
g_data.dsl_detail = true
g_data.To = ""
function extract_addr(str)
local name, addr = string.match(str, [[^"(.*)"%s*<(.*)>$]])
return addr or str
end
function read_box_values()
g_data.enabled = box.query("emailnotify:settings/infoenabled") == "1"
g_data.interval = box.query("emailnotify:settings/interval")
g_data.show_fonstat = box.query("emailnotify:settings/show_fonstat") == "1"
g_data.show_kidsstat = box.query("emailnotify:settings/show_kidsstat") == "1"
g_data.show_onlinecntstat = box.query("emailnotify:settings/show_onlinecntstat") == "1"
g_data.show_eventlist = box.query("emailnotify:settings/show_eventlist") == "1"
g_data.dsl_detail = box.query("emailnotify:settings/dsl_detail") == "1"
g_data.To = box.query("emailnotify:settings/To")
if g_data.To == "" then
g_data.To = extract_addr(box.query("emailnotify:settings/From"))
end
end
function refill_user_input()
g_data.enabled = box.post.enabled ~= nil
g_data.interval = box.post.interval
g_data.show_fonstat = box.post.show_fonstat ~= nil
g_data.show_kidsstat = box.post.show_kidsstat ~= nil
g_data.show_onlinecntstat = box.post.show_onlinecntstat ~= nil
g_data.show_eventlist = box.post.show_eventlist ~= nil
g_data.dsl_detail = box.post.dsl_detail ~= nil
g_data.To = general.clear_whitespace(box.post.mailto)
end
if box.post.validate == "apply" then
local valresult, answer = newval.validate(pushservice.mailto_validation)
box.out(js.table(answer))
box.end_page()
end
if box.post.cancel then
http.redirect(g_back_to_page)
elseif box.post.apply then
refill_user_input()
if newval.validate(pushservice.mailto_validation) == newval.ret.ok then
local saveset = {}
cmtable.save_checkbox(saveset, "emailnotify:settings/infoenabled", "enabled")
if box.post.enabled then
cmtable.add_var(saveset, "emailnotify:settings/interval", box.post.interval)
if config.FON then
cmtable.save_checkbox(saveset, "emailnotify:settings/show_fonstat", "show_fonstat")
end
if config.KIDS then
cmtable.save_checkbox(saveset, "emailnotify:settings/show_kidsstat", "show_kidsstat")
end
cmtable.save_checkbox(saveset, "emailnotify:settings/show_onlinecntstat", "show_onlinecntstat")
if config.DSL and not general.is_atamode() then
cmtable.save_checkbox(saveset, "emailnotify:settings/dsl_detail", "dsl_detail")
end
cmtable.save_checkbox(saveset, "emailnotify:settings/show_eventlist", "show_eventlist")
local mail_to = box.post.mailto
if mail_to == "" then
mail_to = g_data.addr
end
cmtable.add_var(saveset, "emailnotify:settings/To", general.clear_whitespace(box.post.mailto))
end
local err, msg = box.set_config(saveset)
if err == 0 then
http.redirect(g_back_to_page)
end
end
else
read_box_values()
end
function write_info_checkboxes()
local fritz_app_enabled = true
if config.FON and fritz_app_enabled then
html.input{type="checkbox", name="show_fonstat", id="uiShow_fonstat",
checked=g_data.show_fonstat
}.write()
html.label{['for']="uiShow_fonstat",
[[{?585:912?}]]
}.write()
html.br{}.write()
end
if config.KIDS then
html.input{type="checkbox", name="show_kidsstat", id="uiShow_kidsstat",
checked=g_data.show_kidsstat
}.write()
html.label{['for']="uiShow_kidsstat",
[[{?585:479?}]]
}.write()
html.br{}.write()
end
html.input{type="checkbox", name="show_onlinecntstat", id="uiShow_onlinecntstat",
checked=g_data.show_onlinecntstat
}.write()
html.label{['for']="uiShow_onlinecntstat",
[[{?585:125?}]]
}.write()
html.br{}.write()
html.input{type="checkbox", name="show_eventlist", id="uiShow_eventlist",
checked=g_data.show_eventlist
}.write()
html.label{['for']="uiShow_eventlist",
[[{?585:869?}]]
}.write()
if config.DSL and not general.is_atamode() then
html.br{}.write()
html.input{type="checkbox", name="dsl_detail", id="uiDsl_detail",
checked=g_data.dsl_detail
}.write()
html.label{['for']="uiDsl_detail",
[[{?585:481?}]]
}.write()
end
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript">
function init() {
enableOnClick({
inputName: "enabled",
classString: "enableif_enabled"
});
}
ready.onReady(init);
ready.onReady(ajaxValidation());
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua box.html(box.glob.script) ?>" name="main_form">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>" />
<p>
{?585:442?}
</p>
<hr>
<input type="checkbox" name="enabled" id="uiEnabled"
<?lua if g_data.enabled then box.out("checked") end ?>
>
<label for="uiEnabled">
{?585:959?}
</label>
<div class="enableif_enabled">
<div class="formular">
<p>{?585:942?}</p>
<div class="formular">
<?lua write_info_checkboxes() ?>
</div>
</div>
<div class="formular">
<p>{?585:64?}</p>
<div class="formular">
<input type="radio" name="interval" id="uiDaily" value="daily"
<?lua if g_data.interval=="daily" then box.out("checked") end ?>
>
<label for="uiDaily">{?585:721?}</label>
<br>
<input type="radio" name="interval" id="uiWeekly" value="weekly"
<?lua if g_data.interval=="weekly" then box.out("checked") end ?>
>
<label for="uiWeekly">{?585:884?}</label>
<br>
<input type="radio" name="interval" id="uiMonthly" value="monthly"
<?lua if g_data.interval=="monthly" then box.out("checked") end ?>
>
<label for="uiMonthly">{?585:509?}</label>
<br>
</div>
</div>
<div class="formular widetext">
<label for="uiMailto">{?585:515?}</label>
<input type="text" name="mailto" id="uiMailto" value="<?lua box.html(g_data.To) ?>">
</div>
</div>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtOK?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
