--[[Access denied<?lua
    box.end_page()
?>?>]]
require"general"
require"lualib"
opmode=general.lazytable({},box.query,{
value={"box:settings/opmode"}
})
local flags={}
function opmode.is_ppp(value)
return flags.ppp[value or opmode.value]
end
flags.ppp=array.truth{
'opmode_standard','opmode_pppoe','opmode_pppoa','opmode_pppoa_llc'
}
