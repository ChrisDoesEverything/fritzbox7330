--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
require("general")
require("href")
require("store")
require("convert_file_size")
require("textdb")
--Alle Daten werden geholt.
wd_data = {}
function refresh_wd_data()
wd_data.connection_state = box.query("webdavclient:status/connection_state")
wd_data.enabled = box.query("webdavclient:settings/enabled")
wd_data.host_url = box.query("webdavclient:settings/host_url")
wd_data.username = box.query("webdavclient:settings/username")
wd_data.password = box.query("webdavclient:settings/password")
wd_data.mountpoint = box.query("webdavclient:settings/mountpoint")
wd_data.is_running = box.query("webdavclient:status/is_running")
wd_data.storage_quota_avail = box.query("webdavclient:status/storage_quota_avail")
wd_data.storage_quota_used = box.query("webdavclient:status/storage_quota_used")
wd_data.traffic_quota_avail = box.query("webdavclient:status/traffic_quota_avail")
wd_data.traffic_quota_used = box.query("webdavclient:status/traffic_quota_used")
wd_data.dirty_files = box.query("webdavclient:status/dirty_files")
wd_data.finished_uploads = box.query("webdavclient:status/finished_uploads")
wd_data.failed_uploads = box.query("webdavclient:status/failed_uploads")
wd_data.sum_failed_uploads = box.query("webdavclient:settings/sum_failed_uploads")
wd_data.activ = wd_data.enabled=="1" and wd_data.is_running=="1" and wd_data.connection_state=="1"
wd_data.einsueins_url = "https://sd2dav.1und1.de"
wd_data.providerlist = {
{id="einsueins",name="1&1",url=wd_data.einsueins_url},
{id="alice",name="Alice SmartDisk",url="https://dav.disk.alice-dsl.de"},
{id="boxcom",name="box.com",url="https://dav.box.com/dav"},
{id="domainfactory",name="Domainfactory",url="https://"..wd_data.username:gsub("@web.dav", "")..".livedisk.df.eu/webdav"},
{id="freenet",name="Freenet",url="https://storage.freenet.de/dav"},
{id="gmx",name="GMX",url="https://webdav.mc.gmx.net"},
{id="humyo",name="humyo",url="https://dav.humyo.com"},
{id="mydisk",name="myDisk",url="https://mydisk.se/"..wd_data.username},
{id="strato",name="STRATO HiDrive",url="https://webdav.hidrive.strato.com"},
{id="tonline",name="Telekom",url="https://webdav.mediencenter.t-online.de"},
{id="webde",name="WEB.DE",url="https://webdav.smartdrive.web.de"},
{id="default",name=TXT("{?1218:864?}"),url=wd_data.host_url}
}
end
refresh_wd_data()
function log_link(strStor)
return '<a href="'..href.get("/system/syslog.lua", "tab=system")..'">'..strStor..'</a>'
end
function is_webdav_enabled()
-- webdav ist an und aura ist nicht aktiv oder zumindest nicht für Speicher aktiv
return (wd_data.enabled == "1" and not(store.aura_for_storage_aktiv()))
end
function is_webdav_activ()
-- webdav ist an und ein nutzbarer USB-Speicher ist vorhanden und aura ist nicht aktiv oder zumindest nicht für Speicher aktiv
return (wd_data.activ and store.check_usb_useable() and not(store.aura_for_storage_aktiv()))
end
function is_webdav_connected()
return is_webdav_activ() and wd_data.connection_state=="1"
end
function webdav_link()
local wdav_link = [[<a href="]]..href.get_zone_link('nas')..[[">]]..TXT([[{?3085:271?}]])..[[</a>]]
if( wdav_link == "" ) then
return TXT([[{?3085:944?}]])
end
return wdav_link
end
function onlinespeicher_mouse_over()
local tmp_string = ""
local storage_quota_avail = general.make_num(wd_data.storage_quota_avail)
local storage_quota_used = general.make_num(wd_data.storage_quota_used)
local traffic_quota_avail = general.make_num(wd_data.traffic_quota_avail)
local traffic_quota_used = general.make_num(wd_data.traffic_quota_used)
if(storage_quota_avail > 0) then
tmp_string = tmp_string..TXT([[{?3085:404?}]])..convert_file_size.humanReadable(storage_quota_avail-storage_quota_used,"byte",2,true,true)..", "
end
if(traffic_quota_avail > 0) then
tmp_string = tmp_string..TXT([[{?3085:931?}]])..convert_file_size.humanReadable(traffic_quota_avail-traffic_quota_used,"byte",2,true,true)
end
return box.tohtml(tmp_string)
end
function get_webdav_copystate()
local txtUploadStatus = ""
local txtUploadStatusTitle = ""
local files_to_upload = general.make_num(wd_data.dirty_files)
local finished_uploads = general.make_num(wd_data.finished_uploads)
local failed_uploads = general.make_num(wd_data.failed_uploads)
local sum_failed_uploads = general.make_num(wd_data.sum_failed_uploads)
local all_uploads = failed_uploads + finished_uploads + files_to_upload
if(files_to_upload > 0) then
local dat_txt = TXT([[{?3085:531?}]])
if all_uploads == 1 then
dat_txt = TXT([[{?1218:840?}]])
end
txtUploadStatus = ", "..finished_uploads.." "..TXT([[{?1218:867?}]]).." "..all_uploads.." "..dat_txt
else
if(finished_uploads > 0 or failed_uploads > 0) then
txtUploadStatus = ", "..TXT([[{?3085:959?}]])
end
end
if(sum_failed_uploads > 0) then
txtUploadStatus = txtUploadStatus..', '..sum_failed_uploads..' '..TXT([[{?3085:293?}]])
end
return '<span>'..box.tohtml(txtUploadStatus)..'</span>'
end
function get_webdav_state()
local success=false
--Die Informationen zum Onlinespeicher werden angezeigt
local strStor = ""--"<span>"
if (wd_data.connection_state=="1") then
--verbunden alles super
strStor = [[<span title="]]..onlinespeicher_mouse_over()..[["><a href="]]..href.get_zone_link('nas')..[[">]]..TXT([[{?3085:665?}]])..[[</a>]]..get_webdav_copystate().."</span> "
success = true
elseif (wd_data.connection_state=="2") then
--nicht verbunden server nicht erreichbar
strStor = strStor..box.tohtml(TXT([[{?3085:408?}]]))
elseif (wd_data.connection_state=="3") then
--nicht verbunden Nutzerdaten falsch
strStor = strStor..box.tohtml(TXT([[{?3085:771?}]]))
elseif (wd_data.connection_state=="4") then
--nicht verbunden Server URL ist Fehlerhaft.
strStor = strStor..box.tohtml(TXT([[{?3085:386?}]]))
elseif (wd_data.connection_state=="5") then
--nicht verbunden USB-Speicher nur read only
strStor = strStor..box.tohtml(TXT([[{?3085:33?}]]))
elseif (wd_data.connection_state=="6") then
--nicht verbunden USB-Speicher nicht vorhanden
strStor = strStor..box.tohtml(TXT([[{?3085:529?}]]))
elseif (wd_data.connection_state=="7") then
--nicht verbunden keine Onlineverbindung
strStor = strStor..box.tohtml(TXT([[{?3085:359?}]]))
elseif (wd_data.connection_state=="9") then
--ungenüd Speicherplatz auf dem USB-Speicher
strStor = strStor..box.tohtml(TXT([[{?3085:45?}]]))
elseif (wd_data.connection_state=="10") then
--Transfervolumen erreicht.
strStor = strStor..box.tohtml(TXT([[{?3085:858?}]]))
else
--wd_data.connection_state=="0": //nicht verbunden
--wd_data.connection_state=="8": //nicht verbunden
--wd_data.connection_state==default: //nicht verbunden
strStor = strStor..box.tohtml(TXT([[{?3085:79?}]]))
end
if (success==false) then
--Im Moment wird dieser Text nur als Link angezeigt sein.
strStor=log_link(strStor)
--strStor=strStor.."</span>";
end
return strStor
end
