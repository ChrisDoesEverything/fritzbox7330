<?lua
package.path = "../lua/?.lua"
require("check_sid")
-- box.html("sid=", box.glob.sid)
-- box.out("<br>")
-- box.html("landevice_uid=", box.get.landevice_uid)
-- box.out("<br>")
-- box.html("proto=", box.get.proto)
-- box.out("<br>")
set = {}
set[1] = {}
if (box.get.proto ~= "ipv6") then
set[1].name = "landevice:settings/landevice[" .. box.get.landevice_uid .. "]/ondemand_ipv4_port_open"
set[1].value = box.get.port
err, errmsg = box.set_config(set)
if (err ~= 0) then
box.out("<html>")
box.html("Error ", err, " at set_config ", set[1].name, " :", errmsg)
box.out("</html>")
else
public_port = box.query(set[1].name)
if (0 ~= public_port) then
public_ip = box.query("connection0:status/ip")
loc = box.get.scheme .. "://" .. public_ip .. ":" .. public_port .. box.get.urlpath
box.header("HTTP/1.0 303 See Other\nContent-Length: 0\nLocation: ".. loc .. "\n\n")
box.end_page()
else
box.out("<html>")
box.html("port open ondemand failed")
box.out("</html>")
end
end
else
set[1].name = "landevice:settings/landevice[" .. box.get.landevice_uid .. "]/ondemand_ipv6_port_open"
set[1].value = box.get.port
err, errmsg = box.set_config(set)
if (err ~= 0) then
box.out("<html>")
box.html("Error ", err, " at set_config ", set[1].name, " :", errmsg)
box.out("</html>")
else
gua_webvar = "landevice:settings/landevice[" .. box.get.landevice_uid .. "]/ipv6_gua"
gua = box.query(gua_webvar)
if (gua == "") then
box.out("<html>")
box.html("Error no GUA")
box.out("</html>")
else
loc = box.get.scheme .. "://[" .. gua .. "]:" .. box.get.port .. box.get.urlpath
box.header("HTTP/1.0 303 See Other\nContent-Length: 0\nLocation: ".. loc .. "\n\n")
box.end_page()
end
end
end
?>
