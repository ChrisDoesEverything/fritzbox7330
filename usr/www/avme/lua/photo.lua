<?lua
dofile("../templates/global_lua.lua")
require "dbg"
local webusb = require"libwebusb"
local pic = box.get.photo
local myabfile = box.get.myabfile
local myfaxfile = box.get.myfaxfile
if gl.logged_in and box.glob.sid ~= "0000000000000000" then
if pic and pic ~= "" and pic ~= "er" then webusb.WebUsb_GetPhoto(pic) end
if myabfile and myabfile ~= "" and myabfile ~= "er" then webusb.WebUsb_GetTamFile(myabfile) end
if myfaxfile and myfaxfile ~= "" and myfaxfile ~= "er" then webusb.WebUsb_GetFaxFile(myfaxfile) end
end
?>
