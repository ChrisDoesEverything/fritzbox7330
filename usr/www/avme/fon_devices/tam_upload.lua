<?lua
g_page_type = "all"
g_page_title = "{?3841:908?}"
dofile("../templates/global_lua.lua")
require("http")
require("val")
require("general")
require("fon_devices")
require("foncalls")
require("cmtable")
if config.TIMERCONTROL then
require("timer")
g_timer_id = "uiTimer"
end
g_back_to_page = http.get_back_to_page( "/fon_devices/tam_list.lua" )
g_menu_active_page = g_back_to_page
g_val = {
prog = [[
]]
}
g_max_tam_cnt=5
g_data={}
g_errmsg=[[]]
local function get_download_link(tam_idx,tam_type, path)
return href.get([[/lua/photo.lua]],
http.url_param("TAMIndex", tam_idx),
http.url_param("TAMAnnounceType", tam_type),
http.url_param("TAMAnnounceFile", path)
)
end
function get_mode_txt(is_standard)
if (is_standard) then
return "standard"
end
return "userdef"
end
function get_mode()
local tam_elem=g_data.tamlist[g_data.cur_tam_idx+1]
if (tam_elem==nil) then
return ""
end
if (g_data.cur_type=="hint") then
return get_mode_txt(tam_elem.user_hint_msg=="0")
elseif (g_data.cur_type=="begin") then
return get_mode_txt(tam_elem.user_begin_msg=="0")
elseif (g_data.cur_type=="end") then
return get_mode_txt(tam_elem.user_end_msg=="0")
end
return ""
end
function get_mapped_type()
if (g_data.cur_type=="begin") then
return "0"
elseif (g_data.cur_type=="end") then
return "2"
elseif (g_data.cur_type=="hint") then
return "1"
end
return "0"
end
function get_var()
g_data.tamlist, g_data.cnt=fon_devices.read_tam(true,true)
g_data.cur_tam_idx=0
g_data.cur_type=""
if (next(box.get)) then
g_data.cur_tam_idx=(tonumber(box.get["TamNr"])or 0)
g_data.cur_type=box.get["which"]
elseif(next(box.post)) then
g_data.cur_tam_idx=(tonumber(box.post["TamNr"])or 0)
g_data.cur_type=box.post["which"]
end
g_data.cur_mode=get_mode()
end
get_var()
if next(box.post) then
if (box.post.apply and box.post.apply=="1") then
local result=val.validate(g_val)
if ( result== val.ret.ok) then
local tampath="tam:settings/TAM"..g_data.cur_tam_idx.."/"
local saveset={}
if (g_data.cur_type=="begin") then
tampath=tampath.."UserAnsRecVP"
elseif (g_data.cur_type=="hint") then
tampath=tampath.."UserAnsVP"
elseif (g_data.cur_type=="end") then
tampath=tampath.."UserEndVP"
end
cmtable.add_var( saveset,tampath,"0")
local err, msg = box.set_config( saveset)
if err == 0 then
http.redirect(href.get([[/fon_devices/edit_tam.lua]],[[TamNr=]]..g_data.cur_tam_idx))
else
g_errmsg=general.create_error_div(err,msg)
end
end
elseif (box.post.cancel or box.post.is_canceled=="1") then
http.redirect(href.get([[/fon_devices/edit_tam.lua]],[[TamNr=]]..g_data.cur_tam_idx))
end
end
function is_checked(cur)
if (get_mode()==cur) then
box.out([[checked]])
end
end
function get_subtitle_txt()
if (g_data.cur_type=="hint") then
return [[{?3841:22?}]]
elseif (g_data.cur_type=="begin") then
return [[{?3841:532?}]]
elseif (g_data.cur_type=="end") then
return [[{?3841:683?}]]
else
return [[{?3841:93?}]]
end
end
function write_cookie_js()
box.js(g_back_to_page, [[?TamNr=]], g_data.cur_tam_idx)
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
</style>
<?lua
if config.TIMERCONTROL then
box.out([[
<link rel="stylesheet" type="text/css" href="/css/default/timer.css"/>
<script type="text/javascript" src="/js/timer.js"></script>
]])
end
?>
<?include "templates/page_head.html" ?>
<div>
<div>{?3841:131?}</div>
<h4><?lua box.html(get_subtitle_txt())?></h4>
<form id="main_form" name="main" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div class="formular">
<input type="radio" name="msgtype" value="standard" id="uiTypeStandard" onclick="onChange('standard')" <?lua is_checked("standard")?>><label for="uiTypeStandard">{?3841:772?}</label><br>
<input type="radio" name="msgtype" value="userdef" id="uiTypeUserdef" onclick="onChange('userdef')" <?lua is_checked("userdef")?>><label for="uiTypeUserdef">{?3841:567?}</label>
</div>
<input type="hidden" name="apply" id="uiNext" value="0">
<input type="hidden" name="is_canceled" id="uiIsCanceled" value="0">
<input type="hidden" name="TamNr" value="<?lua box.html(tostring(g_data.cur_tam_idx))?>">
<input type="hidden" name="which" value="<?lua box.html(g_data.cur_type)?>">
</form>
<form name="uploadform" method="POST" action="../cgi-bin/firmwarecfg" target="_self" enctype="multipart/form-data">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="TAMIndex" value="<?lua box.html(tostring(g_data.cur_tam_idx))?>">
<input type="hidden" name="TAMAnnounceType" value="<?lua box.html(get_mapped_type())?>">
<div class="formular" id="uiChooseFile">
<input name="TAMAnnounceFile" type="file" id="uiUploadFile" size="50" accept="audio/*">
</div>
</form>
<?lua
if (g_errmsg~="") then
box.out(g_errmsg)
end
?>
<div id="btn_form_foot">
<button type="button" name="apply" id="uiApply" onclick="OnOk()" style="">{?txtOK?}</button>
<button type="button" name="cancel" onclick="OnCancel()">{?txtCancel?}</button>
</div>
</div>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/cookie.js"></script>
<script type="text/javascript">
var g_filetype="<?lua box.out(g_data.cur_mode)?>";
function OnCancel()
{
jxl.setValue("uiIsCanceled","1");
jxl.submitForm("main");
return;
}
function OnOk()
{
if (jxl.getChecked("uiTypeStandard"))
{
jxl.setValue("uiNext","1");
jxl.submitForm("main");
return;
}
jxl.submitForm("uploadform");
}
function onChange(msgtype)
{
jxl.display("uiChooseFile",msgtype=="userdef");
}
function check_uploadfile(filename) {
var lastindex = filename.lastIndexOf("/");
var lastindex2 = filename.lastIndexOf("\\");
index=lastindex;
if(lastindex2>lastindex){index=lastindex2}
var titlename = filename.substring(index+1, filename.lastIndexOf("."));
var lowerext = filename.substr(filename.length-3, 3);
if(lowerext.toLowerCase() != "mp3" && lowerext.toLowerCase() != "wav"){
alert("{?3841:514?}");
jxl.disable("uiApply");
jslSetValue("uiUploadFile","");
return false;
}else{
jxl.enable("uiApply");
}
return true;
}
function init()
{
jxl.addEventHandler("uiUploadFile", "click", function(evt){
var str = "<?lua write_cookie_js() ?>";
storeCookie("backtopage", str, 1);
});
onChange(g_filetype)
}
function onNumEditSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
}
ready.onReady(val.init(onNumEditSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
