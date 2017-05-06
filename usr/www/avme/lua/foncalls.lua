--[[Access denied<?lua
    box.end_page()
?>?>]]
require"dbg"
require"lualib"
require"textdb"
require"general"
require"fon_book"
foncalls={}
local calllog=require("libcallloglua")
foncalls=setmetatable(foncalls,{__index=calllog})
local txt=general.lazytable({},TXT,{
unknown={[[{?8852:117?}]]}
})
txt.port=general.lazytable({},TXT,{
[0]={[[{?8852:693?}]]},
[1]={[[{?8852:874?}]]},
[2]={[[{?8852:616?}]]},
[3]={[[{?gCallthrough?}]]},
[4]={[[{?8852:562?}]]},
[5]={[[{?8852:564?}]]},
[6]={[[{?gTAM?}]]},
[36]={[[{?8852:171?}]]},
[37]={[[{?8852:309?}]]},
[-1]={""}
})
txt.msn_type=general.lazytable({},TXT,{
[0]={[[{?gFestNetz?}]]},
[1]={[[{?gFestNetz?}]]},
[2]={[[{?txtINet?}]]},
[3]={[[{?8852:866?}]]}
})
txt.month_short=general.lazytable({},TXT,{
["01"]={[[{?8852:955?}]]},
["02"]={[[{?8852:740?}]]},
["03"]={[[{?8852:581?}]]},
["04"]={[[{?8852:315?}]]},
["05"]={[[{?8852:194?}]]},
["06"]={[[{?8852:798?}]]},
["07"]={[[{?8852:301?}]]},
["08"]={[[{?8852:766?}]]},
["09"]={[[{?8852:223?}]]},
["10"]={[[{?8852:60?}]]},
["11"]={[[{?8852:997?}]]},
["12"]={[[{?8852:953?}]]}
})
txt.month_long=general.lazytable({},TXT,{
["01"]={[[{?8852:188?}]]},
["02"]={[[{?8852:455?}]]},
["03"]={[[{?8852:421?}]]},
["04"]={[[{?8852:800?}]]},
["05"]={[[{?8852:64?}]]},
["06"]={[[{?8852:833?}]]},
["07"]={[[{?8852:868?}]]},
["08"]={[[{?8852:519?}]]},
["09"]={[[{?8852:901?}]]},
["10"]={[[{?8852:608?}]]},
["11"]={[[{?8852:809?}]]},
["12"]={[[{?8852:748?}]]}
})
local function split_date(datestr)
local d,m,y,hm=datestr:match("(%d%d)%.(%d%d)%.(%d%d)%s+(%d%d:%d%d)")
return{day=d or"",month=m or"",year=y or"",time=hm or""}
end
function foncalls.date_shortdisplay(call)
local d=split_date(call.date or"")
return d.day.."."..(txt.month_short[d.month]or""),d.time
end
function foncalls.date_display(call)
local d=split_date(call.date or"")
return d.day.."."..(txt.month_long[d.month]or""),d.time
end
function foncalls.get_path(call)
local path=call.path or""
if path~=""then
local port=call.port or 0
if port==5 then
return"fax",path
elseif 40<=port and port<50 then
return"tam",path
end
end
end
function foncalls.addable_to_fonbook(call)
local num=call.number or""
if num==""or num:find("%*%*7")==1 then
return false
end
return call.name==""or call.inBook==0
end
function foncalls.msn_display(call)
local msn=call.msn or""
local msn_type=txt.msn_type[call.msn_type]
if msn_type then
return msn,msn.." ("..msn_type..")"
else
return msn
end
end
local msn_portname=general.lazytable({},box.query,{
[0]={"telcfg:settings/MSN/Port0/Name"},
[1]={"telcfg:settings/MSN/Port1/Name"},
[2]={"telcfg:settings/MSN/Port2/Name"}
})
function foncalls.port_display(call)
local pname=call.port_name or""
if pname==""then
local p=call.port
if p then
pname=msn_portname[p]or""
if pname==""then
pname=txt.port[p]or""
end
end
end
return pname
end
function foncalls.number_shortdisplay(call)
local name=call.name or""
local number=call.number or""
if name==""and number==""then
return txt.unknown
end
if name==""then
return number
end
return name
end
function foncalls.number_homedisplay(call)
local name=call.name or""
local number=call.number or""
if name==""and number==""then
return txt.unknown
end
local txt=name
if name==""then
txt=number
end
local num_type=call.number_type
if num_type and num_type~=""then
num_type=fon_book.type_shortdisplay(num_type)
end
if num_type and num_type==""then
txt=txt.." "..num_type
end
return txt
end
function foncalls.number_display(call)
local name=call.name or""
local number=call.number or""
if name==""and number==""then
return txt.unknown
end
if name==""then
return number,number
end
local num_type=call.number_type
if num_type and num_type~=""then
num_type=fon_book.type_shortdisplay(num_type)
name=name.." ("..num_type..")"
end
if number==""then
return name
else
return name,name.." = "..number
end
end
local call_types={
enum={'in','fail','rejected','out','in_active','out_active'},
bitmask={
["in"]=tonumber("0001",2),
fail=tonumber("0010",2),
rejected=tonumber("0010",2),
out=tonumber("0100",2),
all=tonumber("0111",2),
active=tonumber("1000",2)
}
}
local function typemask(...)
local mask=0
local params=array.truth{...}
if params.all then
mask=mask+call_types.bitmask.all
if params.active then
mask=mask+call_types.bitmask.active
end
else
for param in pairs(params)do
mask=mask+(call_types.bitmask[param]or 0)
end
end
return mask
end
txt.calltype=general.lazytable({},TXT,{
['in']={[[{?8852:510?}]]},
out={[[{?8852:489?}]]},
fail={[[{?8852:389?}]]},
rejected={[[{?8852:422?}]]},
in_active={[[{?8852:544?}]]},
out_active={[[{?8852:588?}]]}
})
local call_symbol=setmetatable({
['in']={
img="/css/default/images/callin.gif",
class="call_in",
txt=txt.calltype["in"]
},
out={
img="/css/default/images/callout.gif",
class="call_out",
txt=txt.calltype.out
},
fail={
img="/css/default/images/callinfailed.gif",
class="call_in_fail",
txt=txt.calltype.fail
},
rejected={
img="/css/default/images/callrejected.gif",
class="call_rejected",
txt=txt.calltype.rejected
},
in_active={
img="/css/default/images/call_current.gif",
class="call_current",
txt=txt.calltype.in_active,
dirclass="call_direction_in"
},
out_active={
img="/css/default/images/call_current.gif",
class="call_current",
txt=txt.calltype.out_active,
dirclass="call_direction_out"
}
},{
__index=func.const{
img="/css/default/images/callno.gif",
class="call_no",
txt=""
}
}
)
function foncalls.get_callsymbol(ctype)
if type(ctype)=='number'then
ctype=call_types.enum[ctype]or""
end
return call_symbol[ctype]
end
function foncalls.calltype(call)
return call_types.enum[call.call_type]or""
end
function foncalls.count_all()
return calllog.GetNumCalls(typemask('all'))
end
function foncalls.count(...)
return calllog.GetNumCalls(typemask(...))
end
function foncalls.count_today()
return calllog.GetNumCallsToday(typemask('all'))
end
function foncalls.is_used()
return calllog.GetActive()==1
end
function foncalls.get_all(n,flags)
if(not flags)then
flags=1
end
n=tonumber(n)
if n then
if n<=0 then
return{}
end
return calllog.GetFirstN(n,typemask('all'),flags)
else
return calllog.GetAll(typemask('all'),flags)
end
end
function foncalls.get_activecalls()
return calllog.GetAll(typemask('active','all'))
end
function foncalls.get_vcard(call)
if call.vcard_url then
return string.match(call.vcard_url,"<%s*(.+)%s*>")
end
end
function foncalls.get_photo(call)
if call.photo_url then
return string.match(call.photo_url,"<%s*(.+)%s*>")
end
end
return foncalls
