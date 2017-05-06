<!-- MainMenu Login. -->
<?lua
local logo_class = ""
if config.oem == "ewetel" then logo_class = [[class="oemlogo_ewetel"]] end
box.out([[
<div id="mm_balken_box">
<div id="mm_balken">
<div id="mm_links" ]]..logo_class..[["></div>
]])
if gl and gl.logged_in and gl.var.site == "help" then
box.out([[<div id="mm_boxinfo"><p>]])
box.html(box.query("box:settings/hostname"))
box.out([[</p><p>]])
box.html(config.PRODUKT_NAME)
box.out([[</p></div>]])
end
box.out([[
<div id="mm_mitte"></div>
</div>
</div>
<div class="clear_float"></div>
]])
if gl.var.site == "help" then
box.out([[<div id="help_box_head">]])
elseif gl.var.site ~= "sso_editmyself" then
box.out([[<div id="login_head_box">]])
end
box.out([[<p>]])
if gl.var.site == "help" then
box.html([[{?txtHelp?}]])
elseif gl.var.site ~= "sso_editmyself" then
box.html([[{?833:125?}]])
end
box.out([[
<p>
</div>]])
?>
<!-- MainMenuEND. -->
