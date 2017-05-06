<?lua
g_page_type = "all"
g_page_help = "hilfe_system_kennwort.html"
dofile("../templates/global_lua.lua")
g_page_title = ""
require"http"
require"href"
require"general"
require"html"
require"cmtable"
require"newval"
require"js"
require"boxusers"
g_err = {}
g_auth_mode = boxusers.auth_mode()
g_password = boxusers.password
local function admin_needed()
return not boxusers.any_admin()
end
local function valprog()
newval.msg.no_admin = {
[newval.ret.wrong] = [[{?2437:529?}]]
}
newval.msg.pwd_err = {
[newval.ret.empty] = [[{?2437:398?}]],
[newval.ret.tooshort] = [[]],
[newval.ret.notfound] = [[]],
[newval.ret.toolong] = [[{?2437:152?}]],
[newval.ret.outofrange] = [[{?2437:513?}]]
}
if admin_needed() then
if newval.radio_check("auth_mode", "user") then
newval.const_error("auth_mode", "wrong", "no_admin")
end
end
if newval.radio_check("auth_mode", "compat") then
if not newval.value_equal("password", "****") then
newval.not_empty("password", "pwd_err")
newval.length("password", 0, 32, "pwd_err")
newval.char_range_regex("password", "boxpassword", "pwd_err")
end
end
end
if box.post.cancel then
http.redirect(box.glob.script)
end
if box.post.validate == "apply" then
local valresult, answer = newval.validate(valprog)
box.out(js.table(answer))
box.end_page()
end
if box.post.apply then
g_auth_mode = box.post.auth_mode
g_password = box.post.password
if newval.validate(valprog) == newval.ret.ok then
local saveset = {}
if g_auth_mode == "skip" then
cmtable.add_var(saveset, "boxusers:settings/skip_auth_from_homenetwork", "1")
elseif g_auth_mode == "compat" then
if g_password ~= "****" then
cmtable.add_var(saveset, "security:settings/password", g_password)
else
cmtable.add_var(saveset, "boxusers:settings/compatibility_mode", "1")
end
elseif boxusers.any_admin() then
if boxusers.compatibility_mode == "1" then
cmtable.add_var(saveset, "boxusers:settings/compatibility_mode", "0")
elseif boxusers.skip_auth_from_homenetwork == "1" then
cmtable.add_var(saveset, "boxusers:settings/skip_auth_from_homenetwork", "0")
end
end
g_err.code, g_err.msg = box.set_config(saveset)
if g_err.code == 0 then
http.redirect(box.glob.script)
end
end
end
function write_save_error()
if g_err.code and g_err.code ~= 0 then
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
local function get_why_link()
require"helpurl"
return html.a{
href=helpurl.get("hilfe_system_kennwort_konzept"), target="_blank",
[[{?2437:85?}]]
}
end
local function write_radio_skip()
html.div{class="formular",
html.input{type="radio", name="auth_mode", id="uiAuth_mode:skip",
value="skip", checked=g_auth_mode == "skip"
},
html.label{["for"]="uiAuth_mode:skip",
[[{?2437:359?}]]
},
html.div{class="form_input_explain showif_skip",
[[{?2437:70?}]],
},
html.p{class="form_input_explain showif_skip", get_why_link()}
}.write()
end
local function get_password_input()
return html.div{class="formular showif_compat",
html.label{["for"]="uiPassword", [[{?2437:433?}]]},
html.input{type="text", name="password", id="uiPassword",
value=g_password or "", autocomplete="off", maxlength="32"
}
}
end
local function write_radio_compat()
local is_checked = g_auth_mode == "compat"
html.div{class="formular",
html.input{type="radio", name="auth_mode", id="uiAuth_mode:compat",
value="compat", checked=is_checked
},
html.label{["for"]="uiAuth_mode:compat", [[{?2437:553?}]]},
html.div{class="showif_compat",
html.p{class="form_input_explain",
[[{?2437:333?}]]
},
get_password_input(),
html.div{class="form_input_explain",
html.strong{
[[{?txtHinweis?}]]
},
html.p{class="form_input_explain",
[[{?2437:90?}]]
},
html.p{class="form_input_explain",
[[{?2437:406?}]]
}
}
}
}.write()
end
local function write_radio_user()
html.div{class="formular",
html.input{type="radio", name="auth_mode", id="uiAuth_mode:user", value="user",
checked=g_auth_mode == "user"
},
html.label{["for"]="uiAuth_mode:user", [[{?2437:977?}]]},
html.p{class="form_input_explain showif_user",
[[{?2437:175?}]]
},
html.p{class="form_input_explain showif_user",
[[{?2437:6697?}]]
}
}.write()
end
function write_mode_radios()
write_radio_user()
write_radio_compat()
write_radio_skip()
end
function write_admin_needed_js()
box.js(admin_needed())
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua write_save_error() ?>
<p>
{?2437:695?}
</p>
<hr>
<h4>{?2437:131?}</h4>
<?lua write_mode_radios() ?>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/password_checker.js"></script>
<script type="text/javascript">
function initClickHandler() {
var adminNeeded = <?lua write_admin_needed_js() ?>;
var classString = "showif_%1";
var radio = jxl.getFormElements("auth_mode");
var dest = {};
var i = radio.length;
while (i--) {
var val = radio[i].value || "";
if (val) {
dest[val] = jxl.getByClass(jxl.sprintf(classString, val));
}
jxl.addEventHandler(radio[i], "click", onClick);
}
doShowHide();
function onClick(evt) {
if (adminNeeded) {
var tgt = jxl.evtTarget(evt);
if (tgt.value == "user") {
alert("{?2437:67?}");
return jxl.cancelEvent(evt);
}
}
doShowHide();
}
function doShowHide() {
var i = radio.length;
while (i--) {
var d = dest[radio[i].value || "on"];
if (d && d.length) {
for (var k = 0; k < d.length; k++) {
jxl.display(d[k], radio[i].checked);
}
}
}
}
}
ready.onReady(initClickHandler);
ready.onReady(ajaxValidation());
createPasswordChecker( "uiPassword" );
</script>
<?include "templates/html_end.html" ?>
