<?lua
package.path = "../lua/?.lua;" .. (package.path or "")
require"dbg"
require"cmtable"
--require"check_sid"
box.header("Content-type: text/plain\nExpires: -1\n\n")
local err, msg = -1, "?"
local saveset = {}
if box.post.xhr == "1" and box.post.settime then
cmtable.add_var(saveset, "time:settings/time", box.post.settime)
err, msg = box.set_config(saveset)
end
box.out(err, ",", msg or "ok")
box.end_page()
?>
