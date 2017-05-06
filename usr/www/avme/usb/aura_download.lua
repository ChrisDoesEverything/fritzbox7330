<?lua
g_page_type = "all"
g_page_title = [[{?745:607?}]]
dofile("../templates/global_lua.lua")
?>
<?include "templates/html_head_popup.html" ?>
<!-- <link rel="stylesheet" type="text/css" href="/css/default/static.css"/> -->
<script type="text/javascript">
</script>
<?include "templates/page_head_popup.html" ?>
<div id="content">
<?lua
function get_feature_part()
local fp = ""
if config.FON then fp = fp..[[FON,]] end
if config.AURA then fp = fp..[[AURA,]] end
if config.VPN then fp = fp..[[VPN,]] end
if config.KIDS then fp = fp..[[KIDS,]] end
return fp
end
if box.query("connection0:status/connect")=="5" then
box.out([[
<iframe src="]]..config.ACCESSORY_URL..[[&features=]]..get_feature_part()..[[&kontext=aura"
name="software" width="100%" height="420" frameborder="0" style="border: 1px solid #C6C7BE;">
{?745:772?}
</iframe>
]])
else
box.out([[
<p>
{?745:245?}
<br>
{?745:713?}
</p>
]])
end
?>
</div>
<?include "templates/page_end_popup.html" ?>
<?include "templates/html_end_popup.html" ?>
