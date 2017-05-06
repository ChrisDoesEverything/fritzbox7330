--[[Access denied<?lua
    box.end_page()
?>?>]]
require"general"
require"isp"
tr069=general.lazytable({},box.query,{
enabled={"tr069:settings/enabled"},
url={"tr069:settings/url"},
username={"tr069:settings/username"},
password={"tr069:settings/password"},
provcode={"tr069:settings/provcode"},
serialnumber={"tr069:settings/serialnumber"},
FWdownload_enable={"tr069:settings/FWdownload_enable"},
ACSInitiation_enable={"tr069:settings/ACSInitiation_enable"},
suppress_autoFWUpdate_notify={"tr069:settings/suppress_autoFWUpdate_notify"},
litemode_disabled={"tr069:settings/litemode_disabled"},
ProvSucceededURL={"tr069:settings/ProvSucceededURL"},
fwupdate_available={"tr069:settings/fwupdate_available"},
UpgradesManaged={"tr069:settings/UpgradesManaged"},
upload_enable={"tr069:settings/upload_enable"},
gui_mode={"tr069:settings/gui_mode"},
dhcp43_support={"tr069:settings/dhcp43_support"}
})
function tr069.unprovisioned()
return tr069.provcode==""or tr069.provcode=="000.000.000.000"
end
function tr069.provisioned_by_kdg()
return string.find(tr069.url or"","kabel%-deutschland")~=nil
end
function tr069.provisioned_by_ui()
return not tr069.unprovisioned()and isp.is_ui()
end
function tr069.provsucceeded_url()
if config.oem=='1und1'then
local url=tr069.ProvSucceededURL
if url:trim()~=""and url:find("er")~=1 and url~="-"then
return url
end
end
end
function tr069.get_servicecenter_url()
local url=""
url=tr069.provsucceeded_url()
if not url and not config.LTE then
if isp.is_ui()then
url="http://www.1und1.de/dslstart/index.php?label="
url=url..isp.activeprovider()
end
end
return url
end
