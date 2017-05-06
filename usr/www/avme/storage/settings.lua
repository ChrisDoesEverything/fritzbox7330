<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_needs_js = true
g_page_help = "hilfe_speicher_einstellungen.html"
dofile("../templates/global_lua.lua")
require("webdav")
if config.NAS then
require("call_webusb")
end
require("store")
require("http")
require("cmtable")
require("val")
require("href")
require"general"
conv = require("convert_file_size")
g_aura_txt = general.sprintf(box.tohtml([[{?80:377?}]]),[[<a href="]]..href.get("/usb/usb_remote_settings.lua")..[[">]], [[</a>]])
g_err_addon=[[{?80:344?}]]
function get_scan_state(part_name)
if not part_name or part_name == "" then
part_name = "/var/media/ftp"
else
part_name = "/var/media/ftp/"..part_name
end
local str = box.tohtml([[{?80:111?}]])
local explain = box.tojs([[{?80:20?}]])
if g_scan_state < 2 then
explain = explain..[[\n\n]]..box.tojs([[{?80:300?}]])
end
if g_scan_state_err=="" and g_scan_state_table and g_scan_state_table[1] then
for i,v in ipairs(g_scan_state_table) do
if v.partition_path == part_name then
local cnt_audio = tonumber(v.partition_audio_count) or 0
local cnt_video = tonumber(v.partition_video_count) or 0
local cnt_image = tonumber(v.partition_image_count) or 0
local cnt_other = tonumber(v.partition_other_count) or 0
local cnt_doc = tonumber(v.partition_doc_count) or 0
local media_files = cnt_audio + cnt_video + cnt_image
local all_files = media_files + cnt_doc + cnt_other
if v.partition_scan_status == "complete" then
str = box.tohtml([[{?80:311?}]])
explain = box.tojs([[{?80:439?}]])..[[\n\n]]
explain = explain..box.tojs([[{?80:735?}]])..[[\n]]
if v.partition_scan_start_time ~= "" and v.partition_scan_end_time ~= "" then
explain = explain..box.tojs([[{?80:921?}: ]])..v.partition_scan_start_time..box.tojs([[ {?80:824?}]])..[[\n]]
explain = explain..box.tojs([[{?80:964?}: ]])..v.partition_scan_end_time..box.tojs([[ {?80:700?}]])..[[\n]]
end
explain = explain..box.tojs([[{?80:33?}: ]])..cnt_image..[[\n]]
explain = explain..box.tojs([[{?80:956?}: ]])..cnt_audio..[[\n]]
explain = explain..box.tojs([[{?80:358?}: ]])..cnt_video..[[\n]]
explain = explain..box.tojs([[{?80:726?}: ]])..cnt_doc..[[\n]]
explain = explain..box.tojs([[{?80:689?}: ]])..cnt_other..[[\n]]
explain = explain..box.tojs([[{?80:853?}: ]])..all_files
if g_scan_state < 2 then
explain = explain..[[\n\n]]..box.tojs([[{?80:596?}]])
end
elseif v.partition_scan_status == "scan running" then
str = box.tohtml([[{?80:7633?}]])
explain = box.tojs([[{?80:332?}]])
elseif v.partition_scan_status == "update running" then
str = box.tohtml([[{?80:177?}]])
explain = box.tojs([[{?80:651?}]])
elseif v.partition_scan_status == "failed" then
str = box.tohtml([[{?80:976?}]])
explain = box.tojs([[{?80:880?}]])
if g_scan_state < 2 then
explain = explain..[[\n\n]]..box.tojs([[{?80:4463?}]])
end
end
end
end
end
if part_name == "/var/media/ftp" and g_ctlmgr.internalflash_enabled ~= "1" then
return [[<a href="javascript:function(){return false;}" disabled>]]..str..[[</a>]]
elseif g_scan_state < 2 then
return [[<a href="javascript:if(confirm(']]..explain..[[')){jxl.setValue('startFnasDb', '1'); jxl.get('btnRefresh').click();}">]]..str..[[</a>]]
else
return [[<a href="javascript:alert(']]..explain..[[');">]]..str..[[</a>]]
end
end
if config.NAS and box.get.ajax and box.get.ajax == "scan" then
require("js")
g_ctlmgr = { internalflash_enabled = box.query("ctlusb:settings/internalflash_enabled") }
g_scan_state_table, g_scan_state_err, g_scan_state_err_txt, g_scan_state = call_webusb.call_webusb_func( "scan_info", 1 )
g_scan_state = tonumber(g_scan_state) or 0
g_usb_devices = store.get_usb_devices_list()
local scan_state_tab = {}
--Ermitteln der USB-Speicher links
if store.check_usb_available() then
local stor_count = 0
local stor_tab = {}
for i,v in ipairs(g_usb_devices) do
if v.devtype == "storage" then
if v.any_log and not(store.aura_for_storage_aktiv()) then
for j,logvol in ipairs(v.log_vol) do
stor_count = stor_count + 1
stor_tab[stor_count] = logvol
end
else
stor_count = stor_count + 1
stor_tab[stor_count] = v
end
end
end
for i,v in ipairs(stor_tab) do
if v.name and "" ~= v.name then
scan_state_tab[#scan_state_tab + 1] = { path="/var/media/ftp/"..tostring(v.name), link=tostring(get_scan_state(tostring(v.name))) }
end
end
end
box.out(js.table({ scan_state=tostring(g_scan_state), scan_state_table=scan_state_tab }))
box.end_page()
end
g_hint_txt = [[{?txtHinweis?}]]
function get_all_var()
g_ctlmgr =
{
expertmode_active = box.query("box:settings/expertmode/activated"),
ftp_server_enabled = box.query("ctlusb:settings/ftp-server-enabled"),
internalflash_enabled = box.query("ctlusb:settings/internalflash_enabled"),
internalflash_capacity = box.query("usbdevices:settings/internalflash/capacity"),
internalflash_usedspace = box.query("usbdevices:settings/internalflash/usedspace"),
samba_server_enabled = box.query("ctlusb:settings/samba-server-enabled"),
wlan_ap_enabled = box.query("wlan:settings/ap_enabled"),
wlan_bg_mode = box.query("wlan:settings/bg_mode"),
wlan_encryption = box.query("wlan:settings/encryption"),
ftp_portfw_activ = store.check_ftp_portfw_activ(),
share_name=box.query("ctlusb:settings/fritznas_share"),
workgroup=box.query("ctlusb:settings/samba-workgroup")
}
g_webdav_enabled = webdav.is_webdav_enabled()
end
function refill_user_input_from_post()
if box.post.nas_activ then
g_ctlmgr.samba_server_enabled="1"
g_ctlmgr.ftp_server_enabled="1"
else
g_ctlmgr.samba_server_enabled="0"
g_ctlmgr.ftp_server_enabled="0"
end
if box.post.share_name then
g_ctlmgr.share_name=box.post.share_name
end
if box.post.workgroup then
g_ctlmgr.workgroup=box.post.workgroup
end
if box.post.webdav_activ then
g_webdav_enabled = true
else
g_webdav_enabled = false
end
webdav.wd_data.host_url=box.post.webdav_url
webdav.wd_data.username=box.post.webdav_username
webdav.wd_data.password=box.post.webdav_password
end
g_val = {
prog = [[
if __checked(uiViewNasActiv/nas_activ) then
if __checked(uiViewWebdavActiv/webdav_activ) then
not_empty(uiViewWebdavUrl/webdav_url, webdav_url_error_txt)
not_empty(uiViewUsername/webdav_username, webdav_username_error_txt)
not_empty(uiViewWebdavPassword/webdav_password, webdav_pass_error_txt)
end
not_empty(uiViewShareName/share_name, sharname_error_txt)
char_range_regex(uiViewShareName/share_name, nassharename, sharname_error_txt)
not_empty(uiViewWorkgroup/workgroup, workgroup_error_txt)
length(uiViewWorkgroup/workgroup, 0, 15, workgroup_error_txt)
char_range_regex(uiViewWorkgroup/workgroup, workgroupname, workgroup_error_txt)
end
]]
}
val.msg.sharname_error_txt = {
[val.ret.empty] = [[{?80:394?}]],
[val.ret.outofrange] = [[{?80:460?}]]
}
val.msg.workgroup_error_txt = {
[val.ret.empty] = [[{?80:435?}]],
[val.ret.toolong] = [[{?80:948?}]],
[val.ret.outofrange] = [[{?80:806?}]]
}
val.msg.webdav_url_error_txt = {
[val.ret.empty] = [[{?80:6?}]]
}
val.msg.webdav_username_error_txt = {
[val.ret.empty] = [[{?80:541?}]]
}
val.msg.webdav_pass_error_txt = {
[val.ret.empty] = [[{?80:3?}]]
}
if next(box.post) and box.post.btn_refresh then
get_all_var()
if config.NAS and box.post.start_fnasdb == "1" then
local x,y = call_webusb.call_webusb_func("start_fnasdb")
end
refill_user_input_from_post()
elseif next(box.post) and box.post.btn_save then
local ctlmgr_save={}
local ctlmgr_del={}
get_all_var()
if box.post.usb_disconnect and box.post.usb_disconnect == "1" then
http.redirect(href.get('/usb/usb_diskcut.lua','usbdev=all', 'back_to_page='..box.glob.script))
end
if config.RAMDISK or config.NAND then
local reboot = false
if config.RAMDISK then
if box.post.nas_activ and ((box.post.internal_mem_activ and g_ctlmgr.internalflash_enabled == "0") or (not(box.post.internal_mem_activ) and g_ctlmgr.internalflash_enabled == "1")) then
cmtable.save_checkbox(ctlmgr_save, "ctlusb:settings/internalflash_enabled" , "internal_mem_activ")
reboot = true
else
if box.post.internal_mem_activ and g_ctlmgr.internalflash_enabled == "0" then
cmtable.add_var(ctlmgr_save, "ctlusb:settings/internalflash_enabled" , "1")
reboot = true
end
end
else
cmtable.add_var(ctlmgr_save, "ctlusb:settings/internalflash_enabled" , "1")
end
local err,msg = box.set_config(ctlmgr_save)
if err == 0 then
if reboot then
require("webuicookie")
local saveset = {}
webuicookie.set_action_allowed_time()
cmtable.add_var(saveset, webuicookie.vars())
box.set_config(saveset)
http.redirect(href.get("/reboot.lua"))
end
else
local criterr=general.create_error_div(err,msg,g_err_addon)
box.out(criterr)
end
end
ctlmgr_save={}
if val.validate(g_val) == val.ret.ok then
if box.post.nas_activ then
cmtable.save_checkbox(ctlmgr_save, "ctlusb:settings/samba-server-enabled" , "nas_activ")
cmtable.save_checkbox(ctlmgr_save, "ctlusb:settings/ftp-server-enabled" , "nas_activ")
cmtable.save_checkbox(ctlmgr_save, "webdavclient:settings/enabled" , "webdav_activ")
if box.post.webdav_activ then
cmtable.add_var(ctlmgr_save, "webdavclient:settings/host_url" , box.post.webdav_url)
cmtable.add_var(ctlmgr_save, "webdavclient:settings/username" , box.post.webdav_username)
if box.post.webdav_password and box.post.webdav_password~="****" then
cmtable.add_var(ctlmgr_save, "webdavclient:settings/password" , box.post.webdav_password)
end
end
cmtable.add_var(ctlmgr_save, "ctlusb:settings/fritznas_share",box.post.share_name)
cmtable.add_var(ctlmgr_save, "ctlusb:settings/samba-workgroup",box.post.workgroup)
else
cmtable.save_checkbox(ctlmgr_save, "ctlusb:settings/samba-server-enabled" , "nas_activ")
cmtable.save_checkbox(ctlmgr_save, "ctlusb:settings/ftp-server-enabled" , "nas_activ")
cmtable.save_checkbox(ctlmgr_save, "webdavclient:settings/enabled" , "nas_activ")
end
ctlmgr_save = array.cat(ctlmgr_save, ctlmgr_del)
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr=general.create_error_div(err,msg,g_err_addon)
box.out(criterr)
end
webdav.refresh_wd_data()
get_all_var()
else
refill_user_input_from_post()
end
else
get_all_var()
end
g_use_ftp_samba = g_ctlmgr.ftp_server_enabled == "1" and ((not config.SAMBA) or (config.SAMBA and g_ctlmgr.samba_server_enabled == "1"))
function retrieve_userdate(value)
if value then
return "1"
else
return "0"
end
end
g_usb_devices = store.get_usb_devices_list()
if webdav.wd_data.host_url == nil or webdav.wd_data.host_url == "" then
webdav.wd_data.host_url = "http://"
end
if config.NAS then
g_scan_state_table, g_scan_state_err, g_scan_state_err_txt, g_scan_state = call_webusb.call_webusb_func("scan_info", 1)
g_scan_state = tonumber(g_scan_state) or 0
end
function write_usb_device_line(cnt, vol, stor_cnt, ret_str)
local rev_class = [[]]
if (cnt % 2) == 0 then
rev_class = [[class="reverse"]]
end
if cnt == 1 then
ret_str = [[<tr id="devices_table_usb" ><td rowspan="]]..box.tohtml(stor_cnt)..[[" class="hint"><input type="checkbox" id="uiViewUSB" name="viewUsb" onclick="onUsbMem()" title="]]..box.tohtml([[{?80:451?}]])..[["]]
if store.check_usb_useable() then
ret_str = ret_str..[[ checked ]]
end
ret_str = ret_str..[[><input type="hidden" id="uiUsbDisconnect" name="usb_disconnect" value="0"></td>]]
else
ret_str = ret_str..[[<tr ]]..rev_class..[[>]]
end
ret_str = ret_str..[[<td ]]..rev_class..[[>]]
if not(vol.status == "Online" and vol.capacity == "0" and vol.usedspace == "0") and not(store.aura_for_storage_aktiv()) then
if config.NAS then
ret_str = ret_str..[[<a href="]]..href.get_zone_link("nas")..[[">{?80:164?}</a>]]
else
ret_str = ret_str..store.get_storage_link("ftp", [[{?80:859?}]], vol.name)
end
else
ret_str = ret_str..box.tohtml([[{?80:69?}]])
end
ret_str = ret_str..[[</td><td ]]..rev_class..[[>]]..box.tohtml(vol.name)..[[</td><td ]]..rev_class..[[>]]
if vol.phys_status == "Standby" then
ret_str = ret_str..box.tohtml([[ {?80:261?}]])
elseif store.aura_for_storage_aktiv() then
ret_str = ret_str..g_aura_txt
elseif vol.any_log then
ret_str = ret_str..conv.humanReadable(tonumber(vol.capacity)-tonumber(vol.usedspace), "byte", 2, true, true)..box.tohtml([[ {?80:707?} ]])..conv.humanReadable(tonumber(vol.capacity), "byte", 2, true, true)..box.tohtml([[ {?80:239?}]])..[[, ]]..box.tohtml([[{?80:640?}]])
if vol.readonly then
ret_str = ret_str..box.tohtml([[, {?80:10?}]])
end
elseif vol.phys_status == "Online" then
ret_str = ret_str..box.tohtml([[ {?80:831?}]])
else
ret_str = ret_str..box.tohtml([[ {?80:483?}]])
end
local scan_state = ""
if config.NAS then
scan_state = get_scan_state(vol.name)
end
ret_str = ret_str..[[</td><td id="/var/media/ftp/]]..box.tohtml(vol.name)..[["]]..rev_class..[[>]]..scan_state..[[</td></tr>]]
if cnt == stor_cnt and (stor_cnt % 2) == 0 then
ret_str = ret_str..[[<tr style="height: 0px;"><td colspan="5" style="padding: 0px;"></td></tr>]]
end
return ret_str
end
function get_usb_devices()
local ret_str = ""
local stor_count = 0
local stor_tab = {}
if not(store.check_usb_available()) then
return ""
end
for i,v in ipairs(g_usb_devices) do
if v.devtype == "storage" then
if v.any_log and not(store.aura_for_storage_aktiv()) then
for j,logvol in ipairs(v.log_vol) do
stor_count = stor_count + 1
stor_tab[stor_count] = logvol
stor_tab[stor_count].phys_status = v.status
stor_tab[stor_count].any_log = v.any_log
end
else
stor_count = stor_count + 1
stor_tab[stor_count] = v
stor_tab[stor_count].phys_status = v.status
end
end
end
for i,v in ipairs(stor_tab) do
ret_str = write_usb_device_line( i, v, stor_count, ret_str)
end
return ret_str
end
function webdav_state_all()
local tmp = ""
if tonumber(webdav.wd_data.storage_quota_avail) ~=nil and
tonumber(webdav.wd_data.storage_quota_used) ~= nil and
(tonumber(webdav.wd_data.storage_quota_avail)+tonumber(webdav.wd_data.storage_quota_used)) ~= 0 and
webdav.is_webdav_activ() then
tmp = conv.humanReadable((tonumber(webdav.wd_data.storage_quota_avail)-tonumber(webdav.wd_data.storage_quota_used)), "byte", 2, true, true)..box.tohtml([[ {?80:437?} ]])..conv.humanReadable(tonumber(webdav.wd_data.storage_quota_avail), "byte", 2, true, true)..box.tohtml([[ {?80:856?}, ]])
end
return tmp..webdav.get_webdav_state()
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>" class="narrow">
<div>
{?80:3239?}
</div>
<hr>
<h4>{?80:518?}</h4>
<div <?lua if not(store.aura_for_storage_aktiv()) or store.internal_memory_available() then box.out('style="display:none;"') end ?>>
<span class="hintMsg"><?lua box.html(g_hint_txt) ?></span>
<div class="hintMsg">
<span>{?80:811?} <a href="<?lua box.out(href.get("/usb/usb_remote_settings.lua")) ?>">{?80:959?}</a>.</span>
</div>
<br>
</div>
<div <?lua if store.aura_for_storage_aktiv() or store.internal_memory_available() or store.check_usb_useable() then box.out('style="display:none;"') end ?>>
<span class="hintMsg"><?lua box.html(g_hint_txt) ?></span>
<div class="hintMsg">
<span>{?80:761?}</span>
</div>
<br>
</div>
<div id="nasActivBox" class="formular">
<input type="checkbox" id="uiViewNasActiv" name="nas_activ" onclick="onNasActiv()" <?lua if g_use_ftp_samba then box.out('checked') end ?>>
<label for="uiViewNasActiv">{?80:388?}</label>
</div>
<div id="nas_settings">
<div class="formular" id="device_table_box" <?lua if not(g_use_ftp_samba) then box.out('style="display:none;"') end ?>>
<div class="formular">
<table id="device_table" class="zebra">
<tr>
<th class="hint">{?80:176?}</th>
<th>{?80:474?}</th>
<th>{?80:507?}</th>
<th>{?80:263?}</th>
<th><?lua if config.NAS then box.html([[{?80:755?}]]) else box.out("") end ?></th>
</tr>
<?lua box.out(get_usb_devices()) ?>
<tr id="devices_table_online">
<td class="hint"><input type="checkbox" id="uiViewWebdavActiv" name="webdav_activ" onclick="onWebDav()" title="{?80:249?}" <?lua if g_webdav_enabled and not store.aura_for_storage_aktiv() then box.out('checked') end ?>></td>
<td id="webdavName">
<?lua
if webdav.is_webdav_activ() then
if config.NAS then
box.out([[<a href="]]..href.get_zone_link("nas")..[[">{?80:385?}</a>]])
else
box.out(store.get_storage_link('ftp','{?80:638?}',webdav.wd_data.mountpoint))
end
else
box.html([[{?80:473?}]])
end
?>
</td>
<td id="webdavTyp">
<?lua
if g_webdav_enabled then
local key, val
for key,val in ipairs(webdav.wd_data.providerlist) do
if (webdav.wd_data.host_url == val.url or webdav.wd_data.host_url == val.url.."/") then
box.html(val.name)
break
end
end
elseif not store.aura_for_storage_aktiv() then
box.out([[<a href="javascript:onWebDav(1);" >]])
box.html([[{?80:543?}]])
box.out([[</a>]])
end
?>
</td>
<td id="webdavStatus">
<?lua
if store.aura_for_storage_aktiv() then
box.out(g_aura_txt)
elseif g_use_ftp_samba and g_webdav_enabled then
box.out(webdav_state_all())
end
?>
</td>
<td id="webdavIndexState">
</td>
</tr>
</table>
<div>
<?lua
require("boxusers")
local ftp_internet_user_avail = false
for idx,user in ipairs(boxusers.login_list) do
if user.enabled == "1" and user.name == "ftpuser-internet" then
ftp_internet_user_avail = true
break
end
end
if ftp_internet_user_avail then
box.out([[<span class="ShowPathLabel">]]..box.tohtml([[{?80:673?}]])..[[</span>
<span class="ShowPath">]]..box.tohtml([[ftpuser-internet]])..[[</span>
<p>]]..box.tohtml([[{?80:592?}]])..[[</p>
<h4 class="hintMsg">]]..box.tohtml(g_hint_txt)..[[</h4>
<p>]]..general.sprintf(box.tohtml([[{?80:52?}]]), [[<a href=']]..href.get("/system/boxuser_list.lua")..[['>]], [[</a>]])..[[</p>]])
else
box.out([[<h4 class="hintMsg">]]..box.tohtml(g_hint_txt)..[[</h4>
<p>]]..general.sprintf(box.tohtml([[{?80:73?}]]), [[<a href=']]..href.get("/system/boxuser_list.lua")..[['>]], [[</a>]])..[[</p>]])
end
?>
</div>
</div>
</div>
<div id="uiViewWebDav" <?lua if not(g_webdav_enabled) or not(store.memory_available()) then box.out('style="display:none;"') end ?>>
<hr>
<h4>{?80:443?}</h4>
<div id="uiViewWebDavForm" class="formular">
<p>{?80:6559?}</p>
<label for="uiViewWebdavProvider">{?80:4026?}</label>
<select id="uiViewWebdavProvider" name="webdav_provider" onchange="onChangeProvider(value)">
<?lua
local key, val
local not_selected = true
is_identified_webdav = true
local cur_url=webdav.wd_data.host_url
if (cur_url=="") then
cur_url=webdav.wd_data.providerlist[0].url
end
for key,val in ipairs(webdav.wd_data.providerlist) do
box.out('<option value="'..box.tohtml(val.id)..'" ')
if not_selected and (cur_url == val.url or cur_url == val.url.."/") then
not_selected = false
box.out('selected="selected"')
if val.id == "default" then
is_identified_webdav = false
end
end
box.out('>') box.html(val.name) box.out('</option>\n')
end
?>
</select>
<div id="webdav_url_box" <?lua if is_identified_webdav then box.out('style="display:none;"') end ?>>
<label for="uiViewWebdavUrl">{?80:2220?}</label>
<input type="text" size="30" maxlength="100" id="uiViewWebdavUrl" name="webdav_url" value="<?lua if webdav.wd_data.host_url ~= 'er' then box.html(webdav.wd_data.host_url) end ?>" <?lua val.write_attrs(g_val, "uiViewWebdavUrl") ?>>
<?lua val.write_html_msg(g_val, "uiViewWebdavUrl") ?>
</div>
<div>
<label for="uiViewUsername"><span id="uiUsername">{?txtUsername?}</span></label>
<input type="text" size="30" maxlength="100" id="uiViewUsername" name="webdav_username" onblur="onCompleteProvider(this.value)" value="<?lua box.html(webdav.wd_data.username) ?>" <?lua val.write_attrs(g_val, "uiViewUsername") ?>>
<?lua val.write_html_msg(g_val, "uiViewUsername") ?>
</div>
<div>
<label for="uiViewWebdavPassword"><span id="uiWebdavPassword">{?txtPasswort?}</span></label>
<input type="text" size="14" maxlength="128" id="uiViewWebdavPassword" name="webdav_password" value="<?lua box.html(webdav.wd_data.password) ?>" <?lua val.write_attrs(g_val, "uiViewWebdavPassword") ?> autocomplete="off">
<?lua val.write_html_msg(g_val, "uiViewWebdavPassword") ?>
</div>
<br>
<div>
<span class="hintMsg"><?lua box.html(g_hint_txt) ?></span>
<p>
{?80:4850?}
{?80:4489?}
</p>
</div>
</div>
</div>
<div id="page_bottom">
<div id="uiViewHomeSharing">
<hr>
<h4>{?80:513?}</h4>
<div id="share_name" class="formular">
<p>{?80:174?}</p>
<label for="uiViewShareName">{?80:7533?}</label>
<input type="text" size="30" maxlength="100" id="uiViewShareName" name="share_name" value="<?lua box.html(g_ctlmgr.share_name) ?>" <?lua val.write_attrs(g_val, "uiViewShareName") ?>>
<?lua val.write_html_msg(g_val, "uiViewShareName") ?>
<br>
<label for="uiViewWorkgroup">{?80:663?}</label>
<input type="text" size="30" maxlength="15" id="uiViewWorkgroup" name="workgroup" value="<?lua box.html(g_ctlmgr.workgroup) ?>" <?lua val.write_attrs(g_val, "uiViewWorkgroup") ?>>
<?lua val.write_html_msg(g_val, "uiViewWorkgroup") ?>
</div>
</div>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" id="startFnasDb" name="start_fnasdb" value="0">
<button type="submit" name="btn_save" id="btnSave">{?txtApply?}</button>
<button type="submit" name="btn_cancel" id="btnCancel">{?txtCancel?}</button>
<button type="submit" name="btn_refresh" id="btnRefresh">{?txtRefresh?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/convert_file_size.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript">
<?lua
function create_js_var(lua_table)
for key, value in pairs(lua_table) do
if value==nil then value="" end
if type(value) == "table" then
box.out(' ')
else
box.out('var '..box.tojs(key)..'="'..box.tojs(box.tohtml(tostring(value)))..'";')
end
end
end
create_js_var(g_ctlmgr)
box.out('gProvider = new Array();')
for i, value in ipairs(webdav.wd_data.providerlist) do
box.out('\
gProvider['..tostring(i-1)..'] = new Object();\
gProvider['..tostring(i-1)..']["id"] = "'..box.tojs(value.id)..'";\
gProvider['..tostring(i-1)..']["name"] = "'..box.tojs(value.name)..'";\
gProvider['..tostring(i-1)..']["url"] = "'..box.tojs(value.url)..'";')
end
val.write_js_error_strings()
?>
var gUseFtpSamba = <?lua box.js(g_use_ftp_samba) ?>;
var gAuraForStorageActiv = <?lua box.js(tostring(store.aura_for_storage_aktiv())) ?>;
function onWebDav(marker)
{
if (marker!=null) jxl.setChecked("uiViewWebdavActiv", true);
if (jxl.getChecked("uiViewWebdavActiv"))
{
if (!jxl.getChecked("uiViewUSB") || <?lua box.js(tostring(not store.check_any_usb_writeable())) ?>)
{
alert('{?80:397?}')
jxl.setChecked("uiViewWebdavActiv", false);
}
}
jxl.display("uiViewWebDav", jxl.getChecked("uiViewWebdavActiv"));
if (jxl.getChecked("uiViewWebdavActiv"))
{
jxl.setHtml("webdavName", '<?lua if webdav.is_webdav_activ() then box.js([[<a href="]]..href.get_zone_link("nas")..[[">{?80:893?}</a>]]) else box.js("{?80:396?}") end ?>');
jxl.setHtml("webdavTyp", "");
for (var i=0; i < gProvider.length; i++)
if (gProvider[i]["id"]==jxl.getValue("uiViewWebdavProvider"))
jxl.setHtml("webdavTyp", gProvider[i]["name"]);
if (jxl.getChecked("uiViewWebdavActiv"))
{
jxl.setHtml("webdavStatus", '<?lua box.js(webdav_state_all()) ?>');
jxl.setHtml("webdavIndexState", "");
}
else
{
jxl.setHtml("webdavStatus", "");
jxl.setHtml("webdavIndexState", "");
}
}
else
{
jxl.setChecked("uiViewWebdavActiv", false);
jxl.disableNode("uiViewWebdavActiv", !jxl.getChecked("uiViewUSB"));
jxl.setHtml("webdavName", "{?80:5156?}");
if (gAuraForStorageActiv)
{
jxl.setHtml("webdavTyp", "");
jxl.setHtml("webdavStatus", '<?lua box.out(g_aura_txt) ?>');
}
else
{
jxl.setHtml("webdavTyp", "<a href='javascript:onWebDav(1);' >{?80:302?}</a>");
jxl.setHtml("webdavStatus", "");
}
jxl.setHtml("webdavStatus", "");
jxl.setHtml("webdavIndexState", "");
}
}
function onCompleteProvider(username)
{
var id=jxl.getValue("uiViewWebdavProvider");
switch (id)
{
case "domainfactory":
jxl.setValue("uiViewWebdavUrl", "https://"+username.replace("@web.dav", "")+".livedisk.df.eu/webdav");
var index = username.lastIndexOf("@web.dav");
if (index == -1 || (username.length != index + 8))
jxl.setValue("uiViewUsername", username+"@web.dav");
break;
case "mydisk":
jxl.setValue("uiViewWebdavUrl", "https://mydisk.se/"+username);
break;
}
}
function onChangeProvider(id)
{
var emailUser = "{?80:3341?}";
var webUser = "{?80:5163?}";
var nameOfMember = "{?80:6906?}";
var email = "{?txtEmailAdr?}";
var user_eng = "{?80:815?}";
var user = "{?80:2518?}";
var username = "{?txtUsername_js?}";
var password = "{?txtPasswort?}";
var passwordConfirmation = "{?txtConfirmation?}";
var servicePassword = "{?80:5551?}";
var login_name = "{?80:120?}";
jxl.setText("uiUsername", email);
jxl.setText("uiWebdavPassword", password);
jxl.setText("uiWebdavPassword2", passwordConfirmation);
switch (id)
{
case "einsueins":
jxl.setText("uiWebdavPassword", servicePassword);
break;
case "alice":
jxl.setText("uiUsername", login_name);
break;
case "boxnet":
jxl.setText("uiUsername", emailUser);
break;
case "freenet":
jxl.setText("uiUsername", user);
break;
case "webde":
jxl.setText("uiUsername", webUser);
break;
case "strato":
jxl.setText("uiUsername", user_eng);
break;
case "tonline":
case "gmx":
case "humyo":
break;
case "domainfactory":
case "mydisk":
default:
jxl.setText("uiUsername", username);
break;
}
for (var i=0; i < gProvider.length; i++)
if (gProvider[i]["id"]==id)
jxl.setValue("uiViewWebdavUrl" , gProvider[i]["url"]);
jxl.display("webdav_url_box", (id=="default"));
}
function onUsbMem()
{
if (confirm("{?80:279?}"))
{
onUsbMemFunc();
jxl.setValue("uiUsbDisconnect", "1");
jxl.get("btnSave").click();
}
else
{
jxl.setChecked("uiViewUSB", true);
}
}
function onUsbMemFunc()
{
jxl.setChecked("uiViewUSB", (jxl.getChecked("uiViewNasActiv")&& <?lua box.js(store.check_usb_useable()) ?>));
jxl.disableNode("uiViewUSB", !(jxl.getChecked("uiViewNasActiv") && <?lua box.js(store.check_usb_useable()) ?>));
if (!jxl.getChecked("uiViewUSB"))
{
jxl.setChecked("uiViewWebdavActiv", <?lua box.js(tostring(g_webdav_enabled))?>);
jxl.disableNode("uiViewWebdavActiv", !<?lua box.js(tostring(g_webdav_enabled))?>);
}
}
function onInternalMem()
{
}
function checkMemoryAvailable()
{
<?lua box.out('return '..box.tojs(tostring(store.memory_available()))..';') ?>
}
function onNasActiv()
{
if (!jxl.getChecked("uiViewNasActiv"))
jxl.setChecked("uiViewWebdavActiv", false);
else
jxl.setChecked("uiViewWebdavActiv", <?lua box.js(tostring(g_webdav_enabled)) ?>);
onWebDav();
init();
}
function enable_nas_activ()
{
<?lua
val.write_js_checks(g_val)
?>
jxl.disableNode("uiViewNasActiv", false);
jxl.disableNode("uiViewWebdavActiv", false);
}
function refreshScanState(resp)
{
for (var idx in resp.scan_state_table)
{
var part = jxl.get(resp.scan_state_table[idx].path);
if (part)
{
part.innerHTML = resp.scan_state_table[idx].link.replace(/\n/g, "\\n");
}
}
}
var json = makeJSONParser();
function callback_state(response)
{
var nextScanTime = 30000
if (response && response.status == 200)
{
var resp = json(response.responseText);
if (resp)
{
switch (resp.scan_state)
{
case "2" :
case "3" :
nextScanTime = 10000
case "1" :
break;
}
refreshScanState(resp);
}
}
window.setTimeout(doRequest, nextScanTime);
}
function doRequest()
{
ajaxGet("<?lua href.write(box.glob.script, 'ajax=scan') ?>", callback_state);
}
function init()
{
window.setTimeout(doRequest, 5000);
var memAvail=checkMemoryAvailable();
if(!memAvail || !jxl.getChecked("uiViewNasActiv"))
{
jxl.disableNode("nas_settings", false);
jxl.disableNode("nasActivBox", !memAvail);
jxl.disableNode("page_bottom", true);
jxl.disableNode("devices_table_online", true);
jxl.disableNode("devices_table_usb", true);
return
}
jxl.disableNode("nasActivBox", false);
jxl.disableNode("page_bottom", false);
jxl.disableNode("devices_table_internal", false);
jxl.disableNode("devices_table_online", false);
jxl.disableNode("devices_table_usb", false);
jxl.disableNode("nas_settings", false);
jxl.display("device_table_box", jxl.getChecked("uiViewNasActiv"));
jxl.disableNode("uiViewInternalMemActiv", <?lua box.js(tostring(not(config.RAMDISK))) ?>);
onUsbMemFunc();
var id=jxl.getValue("uiViewWebdavProvider");
onChangeProvider(id);
}
ready.onReady(val.init(enable_nas_activ, "btn_save", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
