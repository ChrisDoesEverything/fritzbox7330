<?lua
g_page_type = "no_menu"
g_homelink_top = true
g_page_title = [[{?41:471?}]]
g_page_help = "hilfe_avm_dienste.html"
dofile("../templates/global_lua.lua")
require"cmtable"
require"http"
require"general"
require"html"
require"val"
g_back_to_page = http.get_back_to_page( "/menus/sitemap.lua" )
g_val = { prog = ""}
crashreport = {}
crashreport.show = config.ERR_FEEDBACK
function crashreport.validation()
val.msg.txt_email = {
[val.ret.empty] = [[{?41:179?}]],
[val.ret.outofrange] = [[{?41:363?}]]
}
return [[
if __value_not_empty(uiCrashreport_name/crashreport_name) then
char_range_regex(uiCrashreport_name/crashreport_name, email, txt_email)
end
]]
end
function crashreport.get_name()
return box.query("emailnotify:settings/crashreport_name")
end
function crashreport.checked(which)
local value = box.query("emailnotify:settings/crashreport_mode")
local checked = value == which
if value == "disable_mail" then
checked = which == "disabled_by_user"
end
if value == "to_user_and_support" then
checked = which == "to_support_only"
end
return checked
end
function crashreport.save(saveset)
if crashreport.show then
local new_value = box.post.crashreport_mode
if new_value == "to_support_only" then
local old_value = box.query("emailnotify:settings/crashreport_mode")
-- den hier nicht setzbaren "on"-Wert nicht überschreiben ...
if old_value == "to_user_and_support" then
new_value = old_value
end
end
cmtable.add_var(saveset, "emailnotify:settings/crashreport_mode", new_value)
cmtable.add_var(saveset, "emailnotify:settings/crashreport_name", box.post.crashreport_name)
end
end
allow_comm = {}
allow_comm.show = (not config.DOCSIS)
function allow_comm.save(saveset)
if (allow_comm.show) then
cmtable.add_var(saveset,
"box:settings/allow_background_comm_with_manufacturer",
box.post.background and "1" or "0"
)
cmtable.add_var(saveset,
"box:settings/allow_cross_domain_comm",
box.post.cross_domain and "1" or "0"
)
end
end
if crashreport.show then
g_val.prog = g_val.prog .. crashreport.validation()
end
g_err = {}
if box.post.cancel then
http.redirect(g_back_to_page)
end
if box.post.apply and val.validate(g_val) == val.ret.ok then
local saveset = {}
crashreport.save(saveset)
allow_comm.save(saveset)
g_err.code, g_err.msg = box.set_config(saveset)
if g_err.code == 0 then
http.redirect(g_back_to_page)
end
end
function write_saveerror()
if g_err.code and g_err.code ~= 0 then
require"general"
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua val.write_js_error_strings() ?>
function uiOnSubmit() {
var valResult = (function() {
var ret;
<?lua val.write_js_checks(g_val) ?>
})();
return valResult;
}
ready.onReady(val.init(uiOnSubmit));
</script>
<?include "templates/page_head.html" ?>
<form id="uiMainform" name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<?lua write_saveerror() ?>
<?lua if allow_comm.show then
html.h4(nil,
[[{?41:438?}]]
).write()
html.div({class="formular"},
html.input({
type="checkbox", name="background", id="uiBackground",
checked=box.query("box:settings/allow_background_comm_with_manufacturer") == "1"
}),
html.label({["for"]="uiBackground"},
[[{?41:352?}]]
),
html.p({class="form_input_explain"},
[[{?41:391?}]]
)
).write()
html.div({class="formular"},
html.input({
type="checkbox", name="cross_domain", id="uiCross_domain",
checked=box.query("box:settings/allow_cross_domain_comm") == "1"
}),
html.label({["for"]="uiCross_domain"},
[[{?41:616?}]]
),
html.p({class="form_input_explain"},
[[{?41:3134?}]]
)
).write()
end ?>
<?lua if crashreport.show then
html.hr().write()
html.h4(nil, [[{?41:362?}]]).write()
html.p(nil,
[[{?41:897?}]]
).write()
html.p(nil,
[[{?41:62?}]]
).write()
html.div({class="formular"},
html.input({
type="radio", name="crashreport_mode", id="uiCrashreportOn",
value="to_support_only", checked=crashreport.checked("to_support_only")
}),
html.label({['for']="uiCrashreportOn"}, [[{?41:40?}]]),
html.br(),
html.input({
type="radio", name="crashreport_mode", id="uiCrashreportOff",
value="disabled_by_user", checked=crashreport.checked("disabled_by_user")
}),
html.label({['for']="uiCrashreportOff"}, [[{?41:74?}]]),
html.br(),
html.label({['for']="uiCrashreport_name"}, [[{?41:213?}:]]),
html.input({
type="text", name="crashreport_name", id="uiCrashreport_name", value=crashreport.get_name(),
size="50", maxlength="128", class=val.get_error_class(g_val, "uiCrashreport_name")
}),
html.br(),
html.div(nil, html.raw(val.get_html_msg(g_val, "uiCrashreport_name")))
).write()
-- Ende crashreport.show
end ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtOK?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
