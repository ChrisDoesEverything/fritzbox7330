<?lua
package.path = "../lua/?.lua;" .. (package.path or "")
g_check_sid_zone = "all"
g_check_sid_cb = function() end
require("check_sid")
box.header("Content-Type: text/xml\n\n")
box.out([[<?xml version="1.0" encoding="utf-8"\?>]])
box.out([[<SessionInfo>]])
box.out([[<SID>]])
box.xml(box.glob.sid)
box.out([[</SID>]])
box.out([[<Challenge>]])
box.xml(box.query("security:status/challenge"))
box.out([[</Challenge>]])
box.out([[<BlockTime>]])
box.xml(gl.block_time or 0)
box.out([[</BlockTime>]])
box.out([[<Rights>]])
for right, value in pairs(gl.userrights) do
box.out([[<Name>]])
box.xml(right)
box.out([[</Name>]])
box.out([[<Access>]])
box.xml(value)
box.out([[</Access>]])
end
box.out([[</Rights>]])
box.out([[</SessionInfo>]])
?>
