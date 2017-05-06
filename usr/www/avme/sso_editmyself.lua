<?lua
-- de-first -begin
if not gl then
dofile("../templates/global_lua.lua")
end
require"html"
require"http"
require"sso_dropdown"
local security_zone_tab = {
box={path_prefix="", form_action="/sso_editmyself.lua"},
myfritz={path_prefix="/myfritz", form_action="/myfritz/index.lua"},
nas={path_prefix="/nas", form_action="/nas/index.lua"}
}
g_page = ""
g_path_prefix = security_zone_tab[gl.security_zone].path_prefix or ""
g_form_action = security_zone_tab[gl.security_zone].form_action or ""
g_css_prefix = ""
g_back_to_page = http.get_back_to_page( "/" )
if ( gl.security_zone == "box" and box.post.cancel ) or ( not box.get.own_email and not box.post.own_email and
not box.get.own_password and not box.post.own_password ) then
http.redirect( g_back_to_page )
end
g_page_title = [[]]
if box.get.own_email or box.post.own_email then
g_page_title = [[{?8177:888?}]]
elseif box.get.own_password or box.post.own_password then
g_page_title = [[{?8177:163?}]]
end
if gl.security_zone == "box" then
g_page_type = "no_menu"
html_head = "templates/html_head.html"
page_head = "templates/page_head.html"
page_end = "templates/page_end.html"
html_end = "templates/html_end.html"
elseif gl.security_zone == "myfritz" then
g_page_type = "no_menu"
g_content_id = "content_parent"
g_css_prefix = "/myfritz"
html_head = ""
page_head = ""
page_end = ""
html_end = ""
else
html_head = ""
page_head = ""
page_end = ""
html_end = ""
end
local function write_own_email()
html.div{class="formular",
html.label{["for"]="uiOwn_email", [[{?8177:189?}]]},
html.input{
type="text", name="own_email", id="uiOwn_email", autocomplete="off",
value=sso_dropdown.get_data("own_email")
}
}.write()
end
local function write_own_password()
html.div{class="formular",
html.label{["for"]="uiOwnpassword", [[{?8177:806?}]]},
html.input{
type="text", name="own_password", id="uiOwn_password", autocomplete="off", maxlength="32",
value=sso_dropdown.get_data("own_password")
}
}.write()
end
function write_inputs()
if box.get.own_password or box.post.own_password then
write_own_password()
elseif box.get.own_email or box.post.own_email then
write_own_email()
end
end
if gl.security_zone == "box" and box.post.apply and sso_dropdown.save_values() then
http.redirect(g_back_to_page)
end
?>
<?include html_head ?>
<?lua
if gl.security_zone == "box" then
box.out([[<link rel="stylesheet" type="text/css" href="]]..g_css_prefix..[[/css/default/login.css"/>]])
end
?>
<style type="text/css">
div.saveerr {
color: #ff0000;
border: 1px solid #ff0000;
padding: 5px; width: 90%;
margin: 10px 0px 20px 0px;
text-align: left;
}
div.saveerr p {
color: #ff0000;
text-align: left;
}
</style>
<?include page_head ?>
<?lua
if not gl.site_mobile then
if gl.security_zone == "nas" then
box.out([[<div class="login_head_box"><p>]])
box.html(g_page_title)
box.out([[</p></div><div id="login_content">]])
end
end
?>
<div class="login_outer">
<div class="login_inner">
<?lua
if gl.security_zone == "myfritz" then
box.out([[<div class="login_head_box"><p>]])
box.html(g_page_title)
box.out([[</p></div><div class="login_content">]])
end
?>
<?lua sso_dropdown.write_saveerror() ?>
<form name="mainform" method="POST" action="<?lua box.html(g_form_action) ?>">
<?lua href.default_submit('apply') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<div>
<?lua write_inputs() ?>
</div>
<div id="btn_form_foot">
<button type="submit" name="apply">{?txtOK?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
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
if not gl.site_mobile then
if gl.security_zone == "nas" then
box.out([[</div>]])
end
end
?>
<?include page_end ?>
<script type="text/javascript" src="/js/password_checker.js"></script>
<script type="text/javascript">
createPasswordChecker( "uiOwn_password" );
</script>
<?include html_end ?>
