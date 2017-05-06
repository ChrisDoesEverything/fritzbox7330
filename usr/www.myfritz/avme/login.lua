<?lua
-- de-first -begin
if not gl then
dofile("../templates/global_lua.lua")
end
if log then log.no_output() end
local security_zone_tab = { box={path_prefix="", form_action="/login.lua"}, myfritz={path_prefix="/myfritz", form_action="/myfritz"}, nas={path_prefix="/nas", form_action="/nas/index.lua"} }
g_path_prefix = security_zone_tab[gl.security_zone].path_prefix or ""
g_form_action = security_zone_tab[gl.security_zone].form_action or ""
g_page = ""
g_css_prefix = ""
if gl.security_zone == "box" then
local no_redirect_pages = { ["/logincheck.lua"] = true }
if box.get.page and box.get.page ~= "" then
g_page = box.get.page
end
if box.post.page and box.post.page ~= "" then
g_page = box.post.page
end
if no_redirect_pages[g_page] then
g_page = ""
end
if gl.logged_in then
if g_page=="" then
require("first")
first.go()
else
require("http")
http.redirect(g_page.."?sid="..box.glob.sid)
end
end
g_page_type = "no_menu"
g_page_title = [[{?598:6839?}]]
html_head = "templates/html_head.html"
page_head = "templates/page_head.html"
page_end = "templates/page_end.html"
html_end = "templates/html_end.html"
else
g_css_prefix = "/"..gl.security_zone
html_head = ""
page_head = ""
page_end = ""
html_end = ""
end
g_show_user = not gl.c_mode or (gl.c_mode and gl.from_internet)
function write_username_input()
if g_show_user then
box.out([[<label for="uiViewUser">]]..box.tohtml([[{?598:498?}]])..[[</label>]])
if gl.from_internet then
box.out([[<input type="text" id="uiViewUser" name="uiUser" tabindex="1" value="]]..box.tohtml(gl.username)..[["><br>]])
else
require("boxusers")
local activ_users = {}
for idx,user in ipairs(boxusers.login_list) do
if user.enabled == "1" and user.is_tr069_remote_access_user == "0" then
activ_users[#activ_users+1] = user
end
end
if #activ_users < 1 then
box.out([[<input type="text" id="uiViewUser" name="uiUser" tabindex="1" value="]]..box.tohtml(gl.username)..[["><br>]])
else
box.out([[<select id="uiViewUser" name="uiUser" tabindex="1">
<option value="">]]..box.tohtml([[{?txtPleaseSelect?}]])..[[</option>]])
for idx,user in ipairs(activ_users) do
box.out([[<option value="]]..box.tohtml(user.name)..[[" ]])
if gl.username == user.name or #activ_users == 1 then
box.out([[selected="selected"]])
gl.username = user.name
end
box.out([[>]]..box.tohtml(user.name)..[[</option>]])
end
box.out([[</select>]])
end
box.out([[<br>]])
end
box.out([[<p id="uiSelectUsername" class="form_input_note ErrorMsg" style="display:none;">]]..box.tohtml([[{?598:419?}]])..[[</p>]])
end
end
?>
<?include html_head ?>
<?lua
if gl.security_zone ~= "myfritz" then
box.out([[<link rel="stylesheet" type="text/css" href="]]..g_css_prefix..[[/css/default/login.css"/>]])
end
?>
<?include page_head ?>
<?lua
weclomeTxt = box.tohtml([[{?598:357?}]])
if gl.security_zone == "nas" and not gl.site_mobile then
box.out([[<div class="login_head_box"><p>]]..weclomeTxt..[[</p></div><div id="login_content">]])
end
?>
<div class="login_outer">
<div class="login_inner">
<?lua
if gl.security_zone == "myfritz" then
box.out([[<div class="login_head_box"><p>]]..weclomeTxt..[[</p></div><div class="login_content">]])
end
if gl.security_zone == "nas" or gl.security_zone == "myfritz" then
box.out([[<div id="js_error"><p>]])
box.html([[{?598:375?}]])
box.out([[</p></div><script type="text/javascript">jxl.setHtml("js_error", "");</script>]])
end
?>
<form id="uiMainForm" method="post" action="<?lua box.out(g_form_action) ?>" >
<div id="login_form_elements" style="display:none;">
<?lua
if gl.security_zone == "nas" and gl.login_errors_cnt > 0 and gl.login_errors.nas_not_activ then
if gl.login_errors.nas_not_activ then
if config.RAMDISK then
box.out('<br>'..box.tohtml([[{?598:146?}]]))
else
box.out('<br>'..box.tohtml([[{?598:62?}]]))
end
elseif gl.login_errors.no_internet_share then
box.out('<br>'..box.tohtml([[{?598:190?}]]))
end
else
box.out([[<div class="formular">]])
if gl.login_reason and gl.login_reason > 0 and gl.login_reason < 6 then
local reason_tab = {
[[{?598:289?}]],
[[{?598:447?}]],
[[{?598:902?}]],
[[{?598:971?}]],
[[{?598:166?}]]
}
box.out([[<p>]])
box.html(reason_tab[gl.login_reason])
box.out([[</p>]])
elseif gl.false_username then
box.out([[<p>]])
box.html([[{?598:540?}"]]..box.tohtml(gl.false_username)..[["{?598:397?}]])
box.out([[</p>]])
else
box.out([[<p>]])
if not g_show_user then
box.html([[{?598:16?}]])
else
if gl.from_internet then
box.html([[{?598:7715?}]])
else
box.html([[{?598:934?}]])
end
end
box.out([[</p>]])
end
write_username_input()
box.out([[<label for="uiPass">]]..box.tohtml([[{?598:669?}]])..[[</label>]])
box.out([[<input type="password" tabindex="2" id="uiPass" name="uiPass">]])
box.out([[<div id="uiLoginError" style="display:none;">]])
box.out([[<p class="error_text">]])
box.html([[{?598:621?}]])
box.out([[</p>]])
box.out([[<p class="error_text">]])
box.html([[{?598:834?}]])
box.out([[</p>]])
box.out([[<p id="uiWait" class="error_text"></p>]])
box.out([[</div>]])
box.out([[</div><div id="btn_form_foot">
<input type="hidden" name="response" id="uiResp" value="">
<input type="hidden" name="page" value="]]..box.tohtml(g_page)..[[">
<input type="hidden" id="username" name="username" value="]]..box.tohtml(gl.username)..[[">]])
if not gl.from_internet then
require("href")
box.out([[<div id="forgot_pass"><a href="]]..href.get_zone_link("box", "/vergessen.lua")..[[">]]..box.tohtml([[{?598:701?}]])..[[</a></div>]])
end
box.out([[<button type="submit" tabindex="3" id="uiSubmitLogin">]]..box.tohtml([[{?598:379?}]])..[[</button>
</div>]])
end
?>
</div>
</form>
<?lua
if gl.security_zone == "myfritz" then
box.out([[</div>]])
end
?>
</div>
</div>
<?lua
if gl.security_zone == "nas" and not gl.site_mobile then
box.out([[</div>]])
end
?>
<?include page_end ?>
<script type="text/javascript" src="<?lua box.js(g_path_prefix) ?>/js/md5.js"></script>
<script type="text/javascript" src="<?lua box.js(g_path_prefix) ?>/js/ready.js"></script>
<script type="text/javascript">
<?include "js/login.js" ?>
var g_pass_err_time = <?lua box.js(tonumber(gl.block_time)) ?>;
var g_PassErrInterval;
function local_init()
{
jxl.display("login_form_elements", true);
login_init(g_pass_err_time, <?lua box.js(tostring(g_show_user)) ?>);
}
ready.onReady(local_init);
</script>
<?include html_end ?>
