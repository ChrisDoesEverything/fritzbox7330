<?lua
g_page_type = "all"
g_page_title = box.tohtml([[{?290:28?}]])
g_menu_active_page = "/storage/settings.lua"
dofile("../templates/global_lua.lua")
require("http")
require("config")
require("store")
require("cmtable")
require("href")
g_back_to_page = http.get_back_to_page( "/storage/settings.lua" )
if next(box.post) and box.post.cancel then
local params = box.post.oldparams..'&mediapath='..box.post.oldpath
target = g_back_to_page
local str=href.get(target, params)
http.redirect(str)
return
end
g_CurrentPath=""
g_usb_devices = store.get_usb_devices_list()
g_oldparams=""
g_errmsg = nil
if (box.get) then
if (box.get.media_srv_path) then
g_CurrentPath=box.get.media_srv_path
end
local i=1
local tmpParams={}
for k,v in pairs(box.get) do
if (k~="sid") then
tmpParams[i] = k.."="..v
i=i+1
end
end
g_oldparams=table.concat(tmpParams,"&")
end
if next(box.post) and box.post.apply then
local params = box.post.oldparams..'&mediapath='..box.post.path
target = "/storage/settings.lua"
local str=href.get(target, params)
http.redirect(str)
return
end
function write_usb_devices()
if not(store.check_usb_available()) then
return [[<p>]]..box.tohtml(TXT([[{?290:43?}]]))..[[</p>]]
end
local count = 1
local ret_str=""
for i,v in ipairs(g_usb_devices) do
if v.devtype == "storage" then
if v.any_log and not(store.aura_for_storage_aktiv()) then
local checked=""
for j,logvol in ipairs(v.log_vol) do
checked=""
if (g_CurrentPath==logvol.name) then
checked=[[checked="checked"]]
end
ret_str = [[<p><input type="radio" name="path" id="uipath]]..count..[[" value="]]..box.tohtml(logvol.name)..[[" ]]..checked..[[>&nbsp;<label for="uipath]]..count..[[">]]..box.tohtml(logvol.name)..[[</label></p>]]
box.out(ret_str)
count = count + 1
end
end
end
end
end
function write_checked()
if g_CurrentPath=="" then
box.out("checked")
end
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" id="uiMainForm">
<div id="content">
<div class="formular">
<p>{?290:529?}</p>
<p><input type="radio" name="path" id="uipath0" value="" <?lua write_checked()?>>&nbsp;<label for="uipath0">{?290:760?}</label></p>
<?lua write_usb_devices()?>
</div>
<div id="btn_form_foot">
<input type="hidden" name="oldparams" value="<?lua box.html(g_oldparams) ?>">
<input type="hidden" name="oldpath" value="<?lua box.html(g_CurrentPath) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="apply" id="uiApply">{?txtOk?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
function init()
{
var form = jxl.get("uiMainForm");
if (form) form.onsubmit = uiDoOnMainFormSubmit;
jxl.addEventHandler("uiApply", "click", function(){ });
jxl.focus("uiMac0");
}
function uiDoOnMainFormSubmit()
{
var ret;
return true;
}
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
