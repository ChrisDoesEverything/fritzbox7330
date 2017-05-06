<?lua
g_page_type = "all"
g_page_title = [[]]
dofile("../templates/global_lua.lua")
require("general")
require("cmtable")
require("val")
require("boxusers")
require("html")
if box.get.ajax or box.post.ajax then
local server_state = tonumber(box.query("jasonii:settings/result")) or 0
local mf_state = tonumber(box.query("jasonii:settings/myfritzstate")) or 0
box.out([[{"server_state":"]]..tostring(server_state)..[[", "mf_state":"]]..tostring(mf_state)..[["}]])
box.end_page()
end
function set_var(ctlmgr_save)
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr = general.create_error_div(err,msg)
box.out(criterr)
end
end
if box.get.register_box_again or box.post.register_box_again then
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "jasonii:settings/start_register_box", "1")
set_var(ctlmgr_save)
end
g_val_user = {
prog = [[
if __radio_check(uiViewMfNewAccount/mf_account_type, new_account) then
not_empty(uiViewMfAccountEmail_new/mf_account_email_new, user_error_txt)
char_range_regex(uiViewMfAccountEmail_new/mf_account_email_new, email, user_error_txt)
not_empty(uiViewMfAccountPassword_new/mf_account_password_new, pass_error_txt)
end
if __radio_check(uiViewMfRegisterBox/mf_account_type, register_box) then
not_empty(uiViewMfAccountEmail/mf_account_email, user_error_txt)
char_range_regex(uiViewMfAccountEmail/mf_account_email, email, user_error_txt)
not_empty(uiViewMfAccountPassword/mf_account_password, pass_error_txt)
end
]]
}
val.msg.user_error_txt = {
[val.ret.empty] = [[{?3110:133?}]],
[val.ret.outofrange] = [[{?3110:438?}]]
}
val.msg.pass_error_txt = {
[val.ret.empty] = [[{?3110:626?}]]
}
function boxuser_name_is_used(name)
local curr_uid = box.post.boxuseruid or ""
local used = boxusers.used_names(curr_uid)
local value = box.post[name] or ""
value = value:lower()
return used[value]
end
function write_boxuser_used_js()
local curr_uid = box.post.boxuseruid or ""
local result = boxusers.used_names(curr_uid)
box.out(js.table(result))
end
g_val_https = {
prog = [[
if __exists(uiBoxusername/boxusername) then
length(uiBoxusername/boxusername, 1, 32, boxuser_name_err)
no_end_char(uiBoxusername/boxusername, 32, boxuser_name_err)
char_range_regex(uiBoxusername/boxusername, boxusername, boxuser_name_err)
if __callfunc(uiBoxusername/boxusername, boxuser_name_is_used) then
const_error(uiBoxusername/boxusername, notdifferent, boxuser_name_used)
end
end
if __exists(uiBoxuserpassword/boxuserpassword) then
not_empty(uiBoxuserpassword/boxuserpassword, boxuser_pwd_required_internet)
length(uiBoxuserpassword/boxuserpassword, 0, 32, boxuser_pwd_err)
char_range_regex(uiBoxuserpassword/boxuserpassword, boxpassword, boxuser_pwd_err)
end
]]
}
val.msg.boxuser_name_err = {
[val.ret.outofrange] = [[{?3110:139?}]]
}
val.msg.boxuser_name_err[val.ret.tooshort] = val.msg.boxuser_name_err[val.ret.outofrange]
val.msg.boxuser_name_err[val.ret.toolong] = val.msg.boxuser_name_err[val.ret.outofrange]
val.msg.boxuser_name_err[val.ret.notfound] = val.msg.boxuser_name_err[val.ret.outofrange]
val.msg.boxuser_name_err[val.ret.endchar] = val.msg.boxuser_name_err[val.ret.outofrange]
val.msg.boxuser_name_used = {
[val.ret.notdifferent] = [[{?3110:270?}]]
}
val.msg.boxuser_pwd_required_internet = {
[val.ret.empty] = [[{?3110:946?}]]
}
val.msg.boxuser_pwd_err = {
[val.ret.outofrange] = [[{?3110:519?}]]
}
val.msg.boxuser_pwd_err[val.ret.tooshort] = val.msg.boxuser_pwd_err[val.ret.outofrange]
val.msg.boxuser_pwd_err[val.ret.toolong] = val.msg.boxuser_pwd_err[val.ret.outofrange]
val.msg.boxuser_pwd_err[val.ret.notfound] = val.msg.boxuser_pwd_err[val.ret.outofrange]
g_val_status = {
prog = [[]]
}
g_site_state = ""
g_comming_back = false
g_var = {}
function get_page_var()
local opmodes_to_lock = { opmode_eth_ipclient = true }
g_var.opmode = box.query("box:settings/opmode")
g_var.private_ip = box.query("connection0:status/ip_is_private") == "1"
g_var.page_locked = opmodes_to_lock[g_var.opmode] or false
g_var.enabled = box.query("jasonii:settings/enabled") == "1"
g_var.email = box.query("jasonii:settings/user_email")
g_var.old_email = ""
g_var.password = box.query("jasonii:settings/user_password")
g_var.old_password = ""
g_var.mf_state = tonumber(box.query("jasonii:settings/myfritzstate")) or 0
g_var.assi_mode = (box.post.assi_mode and box.post.assi_mode == "true") or false
g_var.https_enabled = box.query("remoteman:settings/enabled") == "1"
g_var.std_https_port = box.query("remoteman:settings/https_port") == "443"
g_var.boxuser_needed = not boxusers.any_admin_frominternet()
local old_state_not_status = (box.post.old_site_state and box.post.old_site_state ~= "show_status")
if g_var.email == "" then
g_var.assi_mode = true
end
if not g_var.enabled then
g_var.assi_mode = false
end
g_site_state = ""
if not g_var.assi_mode or g_var.page_locked then
g_site_state = "show_status"
g_var.assi_mode = false
else
if g_var.email == "" then
g_site_state = "new_user"
else
g_site_state = "register_box"
if (not g_var.https_enabled or g_var.boxuser_needed) and
old_state_not_status and box.post.old_site_state and
(box.post.old_site_state == "register_box" or box.post.old_site_state == "new_user") and
g_var.mf_state ~= 13 then
g_site_state = "https"
elseif old_state_not_status and g_var.mf_state == 1 then
g_site_state = "wait"
elseif old_state_not_status and (g_var.mf_state >= 10 and g_var.mf_state < 200 and g_var.mf_state ~= 17) then
g_site_state = "error"
elseif old_state_not_status and (g_var.mf_state >= 200 or g_var.mf_state == 17) then
g_site_state = "show_status"
g_var.assi_mode = false
end
end
end
if g_var.mf_state == 17 and g_var.email ~= "" and box.post.mf_activ then
g_val_status.prog = [[
if __checked(uiViewMfActiv/mf_activ) then
not_empty(uiViewMfAccountPasswordStatus/mf_account_password_status, pass_error_txt)
end
]]..g_val_status.prog
end
end
get_page_var()
function write_boxuser_inputs()
local i, boxuser
if g_var.email ~= "" then
i, boxuser = array.find(boxusers.list, func.eq(g_var.email, "email"))
end
local newuser = not i and not boxuser
boxuser = boxuser or {}
--Texte je nach newuser
html.div{class="formular",
html.p{
[[{?3110:9287?}]]
}
}.write()
if not newuser then
html.input{type="hidden", name="boxuseruid", value=boxuser.UID or ""}.write()
end
html.div{class="formular widetext",
html.label{['for']="uiBoxusername", [[{?3110:152?}]]},
newuser and html.input{type="text", name="boxusername", id="uiBoxusername", value=boxuser.name or ""}
or html.span{class="output", boxuser.name or ""}
}.write()
html.div{class="formular widetext",
html.label{['for']="uiBoxuseremail", [[{?3110:851?}]]},
html.span{class="output", g_var.email}
}.write()
if newuser or boxuser.password == "" then
html.div{class="formular widetext",
html.div{
html.label{['for']="uiBoxuserpassword", [[{?3110:728?}]]},
html.input{type="text", autocomplete="off", name="boxuserpassword", id="uiBoxuserpassword", value=boxuser.password or ""}
},
html.p{[[{?3110:634?}]]}
}.write()
end
local explain_txt
if newuser then
if not g_var.https_enabled then
explain_txt = [[{?3110:960?}]]
else
explain_txt = [[{?3110:181?}]]
end
else
if not g_var.https_enabled then
explain_txt = general.sprintf(
[[{?3110:397?}]],
boxuser.name
)
else
explain_txt = general.sprintf(
[[{?3110:279?}]],
boxuser.name
)
end
end
html.div{class="formular", html.p{explain_txt}}.write()
end
function save_boxuser( saveset )
local prefix
local uid = box.post.boxuseruid
local rights_value = boxusers.convert_right(true, true)
local check_nas = false
if uid and "" ~= uid and "new" ~= uid then
prefix = "boxusers:settings/user[" .. uid .. "]/"
if box.post.boxuserpassword then
cmtable.add_var(saveset, prefix .. "password", box.post.boxuserpassword)
end
for i, right in ipairs(boxusers.rights()) do
if right == "box_admin_rights" or right == "phone_rights" then
cmtable.add_var(saveset, prefix .. right, rights_value)
elseif box.query(prefix .. right) ~= "0" then
cmtable.add_var(saveset, prefix .. right, rights_value)
if right == "nas_rights" then
check_nas = true
end
end
end
if check_nas then
local webvar = "storagedirectories:settings/"
local curr_webvar
for i, dir in ipairs(boxusers.get_storagedirs()) do
local j, acc = array.find(dir.access, func.eq(uid, "boxusers_UID"))
if j and acc then
curr_webvar = webvar .. dir._node .. "/access/" .. acc._node
if acc.access_from_local == "1" then
cmtable.add_var(saveset, curr_webvar .. "/access_from_internet", "1")
end
if acc.write_access_from_local == "1" then
cmtable.add_var(saveset, curr_webvar .. "/write_access_from_internet", "1")
end
end
end
end
else
prefix = "boxusers:settings/" .. box.query("boxusers:settings/user/newid") .. "/"
cmtable.add_var(saveset, prefix .. "name", box.post.boxusername)
cmtable.add_var(saveset, prefix .. "email", g_var.email)
cmtable.add_var(saveset, prefix .. "password", box.post.boxuserpassword)
for i, right in ipairs(boxusers.rights()) do
if "vpn_access" == right then
cmtable.add_var(saveset, prefix .. right, "0")
else
cmtable.add_var(saveset, prefix .. right, rights_value)
if right == "nas_rights" then
check_nas = true
end
end
end
if check_nas then
local webvar = "storagedirectories:settings/"
local found, dir = array.find(boxusers.get_storagedirs(), func.eq("/", "path"))
if found then
webvar = webvar .. dir._node
else
webvar = webvar .. box.query(webvar .. "directory/newid")
cmtable.add_var(saveset, webvar .. "/path", "/")
end
webvar = webvar .. "/access/" .. box.query(webvar .. "/access/entry/newid")
cmtable.add_var(saveset, webvar .. "/username", box.post.boxusername)
cmtable.add_var(saveset, webvar .. "/access_from_local", "1")
cmtable.add_var(saveset, webvar .. "/write_access_from_local", "1")
cmtable.add_var(saveset, webvar .. "/access_from_internet", "1")
cmtable.add_var(saveset, webvar .. "/write_access_from_internet", "1")
end
end
cmtable.add_var(saveset, prefix .. "enabled", "1")
return saveset
end
if next(box.post) then
if box.post.btn_next or box.post.btn_save then
local ctlmgr_save={}
local reload_page = true
if box.post.old_site_state and (box.post.old_site_state == "new_user" or box.post.old_site_state == "register_box") then
if val.validate(g_val_user) == val.ret.ok then
if box.post.mf_account_type == "new_account" then
cmtable.add_var(ctlmgr_save, "jasonii:settings/user_email", box.post.mf_account_email_new)
cmtable.add_var(ctlmgr_save, "jasonii:settings/user_password", box.post.mf_account_password_new)
cmtable.add_var(ctlmgr_save, "jasonii:settings/start_register_user", "1")
box.post.old_site_state = "new_user"
else
if box.post.mf_account_password and box.post.mf_account_password ~= "****" then
cmtable.add_var(ctlmgr_save, "jasonii:settings/user_password", box.post.mf_account_password)
end
cmtable.add_var(ctlmgr_save, "jasonii:settings/user_email", box.post.mf_account_email)
cmtable.add_var(ctlmgr_save, "jasonii:settings/start_register_box", "1")
box.post.old_site_state = "register_box"
end
else
if box.post.mf_account_type == "new_account" then
g_site_state = "new_user"
else
g_site_state = "register_box"
end
local zusatz = ""
if g_site_state == "new_user" then
zusatz = "_new"
end
if box.post["mf_account_email"..zusatz] then
g_var.old_email = box.post["mf_account_email"..zusatz]
end
if box.post["mf_account_password"..zusatz] then
g_var.old_password = box.post["mf_account_password"..zusatz]
end
reload_page = false
end
end
if box.post.old_site_state and (box.post.old_site_state == "https" or box.post.old_site_state == "show_status") then
if box.post.old_site_state == "https" then
if not g_var.https_enabled then
if g_var.std_https_port then
cmtable.add_var(ctlmgr_save, "remoteman:settings/enabled_with_random_port", "1")
else
cmtable.add_var(ctlmgr_save, "remoteman:settings/enabled", "1")
end
end
if g_var.boxuser_needed then
val_prog = g_val_https
if val.validate(val_prog) == val.ret.ok then
ctlmgr_save = save_boxuser(ctlmgr_save)
end
end
else
val_prog = g_val_status
if val.validate(val_prog) == val.ret.ok then
cmtable.save_checkbox(ctlmgr_save, "remoteman:settings/enabled" , "https_activ")
if box.post.btn_save then
cmtable.save_checkbox(ctlmgr_save, "jasonii:settings/enabled" , "mf_activ")
if g_var.mf_state == 17 and g_var.email ~= "" and box.post.mf_account_password_status and box.post.mf_activ then
cmtable.add_var(ctlmgr_save, "jasonii:settings/user_password", box.post.mf_account_password_status)
cmtable.add_var(ctlmgr_save, "jasonii:settings/start_register_box", "1")
end
end
else
if box.post.https_activ then
g_var.https_enabled = true
else
g_var.https_enabled = false
end
if box.post.old_site_state == "show_status" then
if box.post.mf_activ then
g_var.enabled = true
else
g_var.enabled = false
end
end
if box.post.mf_account_password_status then
g_var.old_password = box.post.mf_account_password_status
end
g_site_state = box.post.old_site_state
reload_page = false
end
end
end
set_var(ctlmgr_save)
if reload_page then
get_page_var()
end
end
if box.post.btn_cancel then
box.post.assi_mode = "false"
get_page_var()
end
if box.post.btn_back and box.post.back_to_state then
g_site_state = box.post.back_to_state
if g_site_state == "new_user" then
g_comming_back = true
end
end
end
if g_site_state == "show_status" then
g_page_help = "hilfe_myfritz_konto.html"
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<?include "templates/page_head.html" ?>
<style>
.LedDesc {
padding-left:3px;
}
.LedSpan{
display: inline-block;
vertical-align: middle;
}
.MfActiveLabel {
padding-left:0px;
}
#uiViewMyFritzBox {
padding-left:20px;
}
.smaller {
padding-left:2px;
}
.smaller label{
padding-bottom:2px;
}
</style>
<form name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>
{?3110:861?}
</p>
<?lua
box.out([[<p>]]..general.sprintf([[{?3110:671?}]], [[<a href='https://www.myfritz.net' target='_blank'>]], [[</a>]])..[[</p>]])
if g_var.page_locked then
elseif g_var.private_ip then
box.out([[<div>
<span class="hintMsg">]]..box.tohtml([[{?txtHinweis?}]])..[[</span>
<p>]]..box.tohtml([[{?3110:487?}]])..[[</p>
</div>]])
end
box.out([[<hr>]])
if g_site_state=="show_status" or g_site_state=="new_user" or g_site_state=="register_box" then
box.out([[<h4>]]..box.tohtml([[{?3110:822?}]])..[[</h4>]])
end
?>
<div id="mfAccount" <?lua if g_site_state~="new_user" and g_site_state~="register_box" then box.out([[style="display:none;"]]) end ?>>
<div class="formular">
<p>{?3110:657?}</p>
<?lua
function get_account_inputs(new)
local new_txt = (new and "_new") or ""
local hide = ((g_site_state=="new_user" and not new) or (g_site_state=="register_box" and new))
local email = (new and not g_comming_back and "") or g_var.email
if g_var.old_email ~= "" then
email = g_var.old_email
end
local password = (new and "") or g_var.password
if g_var.old_password ~= "" then
password = g_var.old_password
end
box.out([[<div id="mf_input_box]]..new_txt..[[" class="formular widetext"]])
if hide then
box.out([[ style="display:none;"]])
end
box.out([[>]])
if new then
box.out([[<p>]]..box.tohtml([[{?3110:485?}]])..[[</p>]])
else
box.out([[<p>]]..box.tohtml([[{?3110:474?}]])..[[</p>]])
end
box.out([[<div class="formular">]])
box.out([[<label for="uiViewMfAccountEmail]]..new_txt..[[">]]..box.tohtml([[{?3110:695?}]])..[[</label>]])
box.out([[<input type="text" id="uiViewMfAccountEmail]]..new_txt..[[" name="mf_account_email]]..new_txt..[[" value="]]..box.tohtml(email)..[[" ]])
val.write_attrs(g_val_user, "uiViewMfAccountEmail"..new_txt)
box.out([[>]])
val.write_html_msg(g_val_user, "uiViewMfAccountEmail"..new_txt)
box.out([[<br><label for="uiViewMfAccountPassword]]..new_txt..[[">]]..box.tohtml([[{?3110:872?}]])..[[</label>]])
box.out([[<input type="text" id="uiViewMfAccountPassword]]..new_txt..[[" name="mf_account_password]]..new_txt..[[" value="]]..box.tohtml(password)..[[" ]])
val.write_attrs(g_val_user, "uiViewMfAccountPassword"..new_txt)
box.out([[autocomplete="off">]])
val.write_html_msg(g_val_user, "uiViewMfAccountPassword"..new_txt)
box.out([[</div></div>]])
end
box.out([[<div>]])
box.out([[<input type="radio" id="uiViewMfNewAccount" name="mf_account_type" value="new_account" onclick="on_mf_account_type(true)" ]])
if g_site_state=="new_user" then box.out([[checked]]) end
box.out([[> <label for="uiViewMfNewAccount">]]..box.tohtml([[{?3110:85?}]])..[[</label>]])
get_account_inputs(true)
box.out([[</div><div>]])
box.out([[<input type="radio" id="uiViewMfRegisterBox" name="mf_account_type" value="register_box" onclick="on_mf_account_type(false)" ]])
if g_site_state=="register_box" then box.out([[checked]]) end
box.out([[> <label for="uiViewMfRegisterBox">]]..box.tohtml([[{?3110:142?}]])..[[</label>]])
get_account_inputs(false)
box.out([[</div>]])
?>
</div>
</div>
<div id="mfWait" <?lua if g_site_state ~= "wait" then box.out([[style="display:none;"]]) end ?>>
<div class="wait">
<p>{?3110:915?}</p>
<p class='waitimg'>
<img alt="" src="/css/default/images/wait.gif">
</p>
</div>
</div>
<div id="mfRegistration" <?lua if g_site_state ~= "error" or (g_var.mf_state ~= 100 and g_var.mf_state ~= 11) then box.out([[style="display:none;"]]) end ?>>
<h4>{?3110:263?}</h4>
<div class="formular">
<ul>
<li>
{?3110:405?}
<br>
<?lua
box.out(general.sprintf([[{?3110:319?}]], box.tohtml(g_var.email)))
?>
</li>
<li>
{?3110:244?}
</li>
</ul>
</div>
</div>
<div id="mfState" <?lua if (g_site_state ~= "show_status" and g_site_state ~= "error") or (g_site_state == "error" and (g_var.mf_state == 100 or g_var.mf_state == 11)) then box.out([[style="display:none;"]]) end ?>>
<div class="formular">
<?lua
if g_site_state == "show_status" then
local is_checked = ((g_var.enabled and not g_var.page_locked) and "checked") or ""
local show_status = ((g_var.enabled and not g_var.page_locked) and "") or "style='display:none;'"
box.out([[<input type="checkbox" id="uiViewMfActiv" onclick="hide_show_myfritz(]]..tostring(g_var.enabled)..[[)" name="mf_activ" ]]..is_checked..[[> ]])
box.out([[<label class="MfActiveLabel" for="uiViewMfActiv">]]..box.tohtml([[{?3110:622?}]])..[[</label>]])
box.out([[<div id="uiViewMyFritzBox" class="formular" ]]..show_status..[[><br>]])
end
box.out([[<h4>]]..box.tohtml([[{?3110:878?}]])..[[</h4>]])
if g_site_state == "show_status" and (g_var.mf_state == 100 or g_var.mf_state == 11) then
box.out([[<span class="LedSpan"><img alt="" src="/css/default/images/led_red.gif"></span> <span class="LedDesc">]])
box.out(box.tohtml([[{?3110:721?}]])..[[</span>]])
box.out([[<a href="]]..href.get("/internet/myfritz.lua", "register_box_again=1")..[[" class="ShowLinkRight">]]..box.tohtml([[{?3110:707?}]])..[[</a>]])
box.out([[<p class="smaller">]]..general.sprintf([[{?3110:472?}]], box.tohtml(g_var.email))..[[</p>]])
elseif g_var.mf_state == 12 then
box.out([[<span class="LedSpan"><img alt="" src="/css/default/images/led_red.gif"></span> <span class="LedDesc">]])
box.out(box.tohtml([[{?3110:58?}]])..[[</span>]])
if g_site_state == "show_status" then
box.out([[<a href="]]..href.get("/internet/myfritz.lua")..[[" class="ShowLinkRight">]]..box.tohtml([[{?3110:7873?}]])..[[</a>]])
end
box.out([[<p class="smaller">]]..box.tohtml([[{?3110:195?}]])..[[</p>]])
box.out([[<p class="smaller">]]..box.tohtml([[{?3110:735?}]])..[[</p>]])
elseif g_var.mf_state == 13 then
box.out([[<span class="LedSpan"><img alt="" src="/css/default/images/led_red.gif"></span> <span class="LedDesc">]])
box.out(box.tohtml([[{?3110:278?}]])..[[</span>]])
if g_site_state == "show_status" then
box.out([[<a href="]]..href.get("/internet/myfritz.lua")..[[" class="ShowLinkRight">]]..box.tohtml([[{?3110:295?}]])..[[</a>]])
end
box.out([[<p class="smaller">]]..box.tohtml([[{?3110:624?}]])..[[</p>]])
box.out([[<p class="smaller">]]..box.tohtml([[{?3110:21?}]])..[[</p>]])
elseif g_var.mf_state == 10 or (g_var.mf_state >= 14 and g_var.mf_state <= 18 and g_var.mf_state ~= 17) then
box.out([[<span class="LedSpan"><img alt="" src="/css/default/images/led_red.gif"></span> <span class="LedDesc">]])
box.out(box.tohtml([[{?3110:834?}]])..[[</span>]])
if g_site_state == "show_status" then
box.out([[<a href="]]..href.get("/internet/myfritz.lua")..[[" class="ShowLinkRight">]]..box.tohtml([[{?3110:521?}]])..[[</a>]])
end
box.out([[<p class="smaller">]]..box.tohtml([[{?3110:20?}]])..[[</p>]])
box.out([[<p class="smaller">]]..box.tohtml([[{?3110:44?}]])..[[</p>]])
elseif g_var.mf_state == 17 and g_var.email ~= "" then
box.out([[<span class="LedSpan"><img alt="" src="/css/default/images/led_red.gif"></span> <span class="LedDesc">]])
box.out(box.tohtml([[{?3110:991?}]])..[[</span>]])
box.out([[<a href="]]..href.get("/internet/myfritz.lua")..[[" class="ShowLinkRight">]]..box.tohtml([[{?3110:951?}]])..[[</a>]])
box.out([[<p class="smaller">]]..box.tohtml([[{?3110:409?}]])..[[</p>]])
elseif g_site_state == "show_status" and g_var.mf_state >= 200 then
local refresh_str = [[{?3110:892?}]]
if g_var.mf_state >= 300 then
box.out([[<span class="LedSpan"><img alt="" src="/css/default/images/led_green.gif"></span>]])
box.out([[<span class="LedDesc">]]..box.tohtml([[{?3110:129?}]])..[[</span>]])
box.out([[<a href="]]..href.get("/internet/myfritz.lua")..[[" class="ShowLinkRight">]]..box.tohtml(refresh_str)..[[</a>]])
box.out([[<p class="smaller">]]..general.sprintf([[{?3110:727?}]], [[<a href='https://www.myfritz.net' target="_blank">]], [[</a>]])..[[</p>]])
else
if g_var.mf_state >= 253 and g_var.mf_state <= 255 then
box.out([[<span class="LedSpan"><img alt="" src="/css/default/images/led_gray.gif"></span>]])
else
box.out([[<span class="LedSpan"><img alt="" src="/css/default/images/led_red.gif"></span>]])
end
box.out([[<span class="LedDesc">]]..box.tohtml([[{?3110:473?}]])..[[</span>]])
box.out([[<a href="]]..href.get("/internet/myfritz.lua")..[[" class="ShowLinkRight">]]..box.tohtml(refresh_str)..[[</a>]])
box.out([[<p class="smaller">]])
if g_var.mf_state == 250 then
box.html([[{?3110:493?}]])
elseif g_var.mf_state == 251 then
box.html([[{?3110:888?}]])
elseif g_var.mf_state == 253 then
box.html([[{?3110:8?}]])
elseif g_var.mf_state == 254 then
box.html([[{?3110:596?}]])
elseif g_var.mf_state == 255 then
box.html([[{?3110:667?}]])
end
box.out([[</p>]])
end
else
box.out([[<span class="LedSpan"><img alt="" src="/css/default/images/led_red.gif"></span> <span class="LedDesc">]])
box.out(box.tohtml([[{?3110:817?}]])..[[</span>]])
if g_site_state == "show_status" then
box.out([[<a href="]]..href.get("/internet/myfritz.lua")..[[" class="ShowLinkRight">]]..box.tohtml([[{?3110:646?}]])..[[</a>]])
end
box.out([[<br><br>]])
end
if g_site_state == "show_status" then
box.out([[<div class="smaller">]])
box.out([[<label for="uiViewMfAccountEmail">]]..box.tohtml([[{?3110:814?}]])..[[</label><span class="ShowPathSmall" id="uiViewMfAccountEmail">]]..box.tohtml(g_var.email)..[[</span>]])
box.out([[<a href="javascript:myfritzEdit()" class="ShowLinkRight">]]..box.tohtml([[{?3110:368?}]])..[[</a>]])
if g_var.mf_state == 17 and g_var.email ~= "" then
local password = g_var.password
if g_var.old_password ~= "" then
password = g_var.old_password
end
box.out([[<br><label for="uiViewMfAccountPasswordStatus">]]..box.tohtml([[{?3110:896?}]])..[[</label>]])
box.out([[<input type="text" id="uiViewMfAccountPasswordStatus" name="mf_account_password_status" value="]]..box.tohtml(password)..[[" ]])
val.write_attrs(g_val_status, "uiViewMfAccountPasswordStatus")
box.out([[autocomplete="off">]])
val.write_html_msg(g_val_status, "uiViewMfAccountPasswordStatus")
end
box.out([[</div>]])
box.out([[</div>]])
end
?>
</div>
</div>
<?lua
if g_site_state == "show_status" then
local https_checked_str = (g_var.https_enabled and "checked") or ""
box.out([[<hr><h4>]]..box.tohtml([[{?3110:182?}]])..[[</h4>
<div class="formular">
<br>
<input type="checkbox" id="uiViewActivateRemoteHTTPS" onclick="onRemoteHttpsActiv()" name="https_activ" ]]..https_checked_str..[[>
<label for="uiViewActivateRemoteHTTPS">]]..box.tohtml([[{?3110:146?}]])..[[</label>]])
box.out([[</div>]])
box.out([[
<div class="formular">
<div><br>
<span class="hintMsg">]]..box.tohtml([[{?txtHinweis?}]])..[[</span>
<p>]]..box.tohtml([[{?3110:4644?}]])..[[</p>
</div>
</div>]]
)
val_prog = g_val_status
end
if g_site_state == "https" then
box.out([[<h4>]])
box.html([[{?3110:824?}]])
box.out([[</h4>]])
if g_var.boxuser_needed then
write_boxuser_inputs()
val_prog = g_val_https
elseif not g_var.https_enabled then
box.out([[<div class="formular">]])
box.out([[<p>]])
box.html([[{?3110:424?}]])
box.out([[</p>]])
box.out([[</div>]])
end
end
?>
<div id="btn_form_foot">
<?lua
function btn_apply()
box.out([[<button type="submit" name="btn_save" id="btnSave">]]..box.tohtml([[{?txtApply?}]])..[[</button>]])
end
function btn_back(state)
box.out([[<button type="submit" name="btn_back" id="btnBack">]]..box.tohtml([[{?txtBack?}]])..[[</button>]])
box.out([[<input type="hidden" name="back_to_state" value="]]..state..[[">]])
end
function btn_next()
box.out([[<button type="submit" name="btn_next" id="btnNext">]]..box.tohtml([[{?txtNext?}]])..[[</button>]])
end
function btn_end()
box.out([[<button type="submit" name="btn_cancel" id="btnCancel">]]..box.tohtml([[{?3110:4764?}]])..[[</button>]])
end
function btn_cancel()
box.out([[<button type="submit" name="btn_cancel" id="btnCancel">]]..box.tohtml([[{?txtCancel?}]])..[[</button>]])
end
if g_site_state == "new_user" then
btn_next()
btn_cancel()
elseif g_site_state == "register_box" then
btn_next()
btn_cancel()
elseif g_site_state == "https" then
btn_next()
btn_cancel()
elseif g_site_state == "error" and (g_var.mf_state == 100 or g_var.mf_state == 11) then
btn_end()
elseif g_site_state == "error" then
btn_back(box.post.start_assi_state)
btn_cancel()
elseif g_site_state == "show_status" then
btn_apply()
btn_cancel()
elseif g_site_state == "wait" then
btn_cancel()
end
if g_site_state == "wait" or g_site_state == "https" or g_site_state == "error" then
box.out([[<input type="hidden" id="startAssiState" name="start_assi_state" value="]]..box.post.start_assi_state..[[">]])
else
box.out([[<input type="hidden" id="startAssiState" name="start_assi_state" value="]]..g_site_state..[[">]])
end
box.out([[<input type="hidden" id="oldSiteState" name="old_site_state" value="]]..g_site_state..[[">]])
box.out([[<input type="hidden" id="assiMode" name="assi_mode" value="]]..tostring(g_var.assi_mode)..[[">]])
?>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/password_checker.js"></script>
<script type="text/javascript">
createPasswordChecker( "uiBoxuserpassword" );
function onRemoteHttpsActiv()
{
var activ = jxl.getChecked("uiViewActivateRemoteHTTPS");
}
function status_init()
{
onRemoteHttpsActiv();
}
function myfritzEdit()
{
jxl.setValue("assiMode", "true");
jxl.submitForm("main_form");
}
function hide_show_myfritz(myfritz_activ)
{
jxl.display("uiViewMyFritzBox", jxl.getChecked("uiViewMfActiv") && myfritz_activ);
}
function on_mf_account_type(is_new)
{
jxl.display("mf_input_box_new", is_new);
jxl.display("mf_input_box", !is_new);
if (is_new)
{
jxl.setValue("oldSiteState", "new_user");
jxl.setValue("startAssiState", "new_user");
}
else
{
jxl.setValue("oldSiteState", "register_box");
jxl.setValue("startAssiState", "register_box");
}
}
function onUserSubmit()
{
<?lua
val.write_js_checks(g_val_user)
?>
}
function onStatusSubmit()
{
<?lua
val.write_js_checks(g_val_status)
?>
}
function onHttpsSubmit()
{
<?lua
val.write_js_checks(g_val_https)
?>
}
<?lua
val.write_js_error_strings()
?>
function boxuserNameIsUsed(id) {
var used = <?lua write_boxuser_used_js() ?>;
var value = jxl.getValue(id);
value = value.toLowerCase();
return used[value];
}
var json_browse = makeJSONParser();
var g_retryCnt = 1;
function callback_state(response)
{
if (response && response.status == 200)
{
var resp = json_browse(response.responseText);
if (resp)
{
<?lua
if ((g_site_state == "error" and (g_var.mf_state == 100 or g_var.mf_state == 11)) or
(g_site_state == "show_status" and g_var.mf_state < 200)) then
box.out([[if (resp.server_state && (parseInt(resp.server_state) < 200))]])
elseif ( g_site_state == "wait" ) then
box.out([[if ( (resp.server_state && (resp.server_state == "0" || resp.server_state == "1")) || ( resp.mf_state && resp.mf_state >= 200 && resp.mf_state < 300 && 3 > g_retryCnt ) )]])
else
box.out([[if (resp.server_state && (resp.server_state == "0" || resp.server_state == "1"))]])
end
?>
{
window.setTimeout("doRequest()", 5000);
g_retryCnt++;
}
else
{
jxl.submitForm("main_form");
}
}
}
}
function doRequest()
{
var akt_url = "<?lua box.out(href.get(box.glob.script)..[[&ajax=1]]) ?>";
ajaxGet(akt_url, callback_state);
}
<?lua
if g_site_state == "wait" or
((g_site_state == "error" and (g_var.mf_state == 100 or g_var.mf_state == 11)) or
(g_site_state == "show_status" and g_var.mf_state < 200)) then
box.out([[ready.onReady( doRequest );]])
end
if g_site_state == "new_user" or g_site_state == "register_box" then
box.out([[ready.onReady(val.init(onUserSubmit, "btn_next", "main_form" ));]])
end
if g_site_state == "show_status" then
box.out([[ready.onReady(status_init);]])
box.out([[ready.onReady(val.init(onStatusSubmit, "btn_save", "main_form" ));]])
end
if g_site_state == "https" then
box.out([[ready.onReady(val.init(onHttpsSubmit, "btn_next", "main_form" ));]])
end
if g_var.page_locked then
box.out([[jxl.disableNode("mfState", true);]])
end
?>
</script>
<?include "templates/html_end.html" ?>
