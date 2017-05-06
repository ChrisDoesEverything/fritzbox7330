--<?lua
if not gl or not gl.logged_in then
box.end_page()
end
--?>
share_bib = {}
local _ = {}
function share_bib.get_link(filelink_node)
--https://<name-oder-public-ip-der-box>[:<https-port-der-box>]/filelink.lua?id=<filelinkid>
if not _.ext_boxip then
_.get_ext_boxip()
end
if not _.ext_boxip then
--Error wenn die IP immer noch leer ist dann gibt es keinen Zugriff. Es muss ein Fehler geworfen werden.
return ""
end
local port = box.query("remoteman:settings/https_port")
if port == "" or port == "443" then port = "" else port = ":"..port end
local linkid = box.query("filelinks:settings/"..filelink_node.."/id")
return [[https://]].._.ext_boxip..port..[[/nas/filelink.lua?id=]]..linkid
end
function _.get_ext_boxip()
if not _.ext_boxip and config.MYFRITZ then
local opmodes_to_lock = { opmode_usb_modem = true, opmode_eth_ipclient = true }
local opmode = box.query("box:settings/opmode")
local mf_enabled = box.query("jasonii:settings/enabled") == "1"
local mf_state = tonumber(box.query("jasonii:settings/myfritzstate")) or 0
if not opmodes_to_lock[opmode] and mf_enabled and mf_state >= 300 then
_.ext_boxip = box.query("jasonii:settings/dyndnsname",false)
end
end
if not _.ext_boxip and box.query("ddns:settings/account0/activated") == "1" then
_.ext_boxip = box.query("ddns:settings/account0/domain",false)
end
if not _.ext_boxip then
ipv4_ip = box.query("connection0:status/ip",false)
ipv4_internet = ipv4_ip and not(ipv4_ip == "-" or ipv4_ip == "0.0.0.0")
if config.IPV6 and box.query("ipv6:settings/enabled") == "1" then
if box.query("ipv6:settings/ipv4_active_mode") ~= "ipv4_normal" then
--Im ds lite Modus soll die ipv4 Adresse ignoriert werden.
ipv4_internet=false
end
ipv6_internet = box.query("ipv6:settings/state") == "5"
ipv6_ip = box.query("ipv6:settings/ip",false)
end
if ipv4_internet then
_.ext_boxip = ipv4_ip
elseif ipv6_internet then
_.ext_boxip = ipv6_ip
end
end
end
return share_bib
