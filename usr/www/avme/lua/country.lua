--[[Access denied<?lua
    box.end_page()
?>?>]]
-- de-first -begin
module(...,package.seeall);
require("textdb")
local countries={
{code="48",name=TXT([[{?286:772?}]]),types="OTC",annex="A",areacode_prefix="0",okz=true},
{code="54",name=TXT([[{?286:922?}]]),types="OTC",annex="A",areacode_prefix="0",okz=true},
{code="61",name=TXT([[{?286:482?}]]),types="OTC",annex="A",areacode_prefix="",okz=true},
{code="32",name=TXT([[{?286:381?}]]),types="OTC",annex="AB",areacode_prefix="0",okz=true},
{code="45",name=TXT([[{?286:933?}]]),types="OTC",annex="AB",areacode_prefix="",okz=false},
{code="49",name=TXT([[{?286:946?}]]),types="GER",annex="B",areacode_prefix="0",okz=true},
{code="372",name=TXT([[{?286:148?}]]),types="OTC",annex="A",areacode_prefix="",okz=true},
{code="358",name=TXT([[{?286:880?}]]),types="OTC",annex="A",areacode_prefix="",okz=true},
{code="33",name=TXT([[{?286:28?}]]),types="OTC",annex="A",areacode_prefix="0",okz=true},
{code="30",name=TXT([[{?286:66?}]]),types="OTC",annex="AB",areacode_prefix="0",okz=false},
{code="44",name=TXT([[{?286:514?}]]),types="OTC",annex="A",areacode_prefix="0",okz=true},
{code="972",name=TXT([[{?286:912?}]]),types="OTC",annex="A",areacode_prefix="",okz=true},
{code="39",name=TXT([[{?286:249?}]]),types="OTC",annex="A",areacode_prefix="0",okz=false},
{code="385",name=TXT([[{?286:443?}]]),types="OTC",annex="B",areacode_prefix="",okz=true},
{code="371",name=TXT([[{?286:356?}]]),types="OTC",annex="AB",areacode_prefix="",okz=true},
{code="352",name=TXT([[{?286:467?}]]),types="OTC",annex="AB",areacode_prefix="",okz=false},
{code="389",name=TXT([[{?286:305?}]]),types="OTC",annex="B",areacode_prefix="",okz=false},
{code="264",name=TXT([[{?286:696?}]]),types="OTC",annex="A",areacode_prefix="",okz=false},
{code="64",name=TXT([[{?286:282?}]]),types="OTC",annex="A",areacode_prefix="",okz=true},
{code="31",name=TXT([[{?286:420?}]]),types="OTC",annex="AB",areacode_prefix="0",okz=true},
{code="234",name=TXT([[{?286:87?}]]),types="OTC",annex="AB",areacode_prefix="0",okz=true},
{code="47",name=TXT([[{?286:3881?}]]),types="OTC",annex="AB",areacode_prefix="",okz=false},
{code="43",name=TXT([[{?286:2?}]]),types="GER",annex="A",areacode_prefix="0",okz=true},
{code="351",name=TXT([[{?286:191?}]]),types="OTC",annex="AB",areacode_prefix="",okz=false},
{code="46",name=TXT([[{?286:604?}]]),types="OTC",annex="AB",areacode_prefix="0",okz=true},
{code="41",name=TXT([[{?286:845?}]]),types="GER",annex="AB",areacode_prefix="0",okz=true},
{code="386",name=TXT([[{?286:737?}]]),types="OTC",annex="AB",areacode_prefix="",okz=true},
{code="34",name=TXT([[{?286:719?}]]),types="OTC",annex="AB",areacode_prefix="",okz=false},
{code="27",name=TXT([[{?286:859?}]]),types="OTC",annex="A",areacode_prefix="",okz=true},
{code="255",name=TXT([[{?286:255?}]]),types="OTC",annex="A",areacode_prefix="0",okz=true},
{code="420",name=TXT([[{?286:510?}]]),types="OTC",annex="B",areacode_prefix="",okz=true},
{code="256",name=TXT([[{?286:672?}]]),types="OTC",annex="AB",areacode_prefix="",okz=true},
{code="36",name=TXT([[{?286:876?}]]),types="OTC",annex="B",areacode_prefix="0",okz=true},
{code="353",name=TXT([[{?286:826?}]]),types="OTC",annex="A",areacode_prefix="0",okz=true},
{code="382",name=TXT([[{?286:411?}]]),types="OTC",annex="B",areacode_prefix="0",okz=false},
{code="421",name=TXT([[{?286:570?}]]),types="OTC",annex="B",areacode_prefix="0",okz=true},
{code="357",name=TXT([[{?286:468?}]]),types="OTC",annex="A",areacode_prefix="",okz=true},
{code="376",name=TXT([[{?286:833?}]]),types="OTC",annex="A",areacode_prefix="",okz=false},
{code="382",name=TXT([[{?286:764?}]]),types="OTC",annex="B",areacode_prefix="",okz=false},
{code="66",name=TXT([[{?286:106?}]]),types="OTC",annex="A",areacode_prefix="",okz=false},
{code="99",name=TXT([[{?286:655?}]]),types="UNI",annex="AB",areacode_prefix="",okz=true}
}
function get_countryname(code)
for i,country in ipairs(countries)do
if country.code==code or"0"..country.code==code then
if not country.name:find(code,1,true)then
return country.name
end
end
end
return TXT([[{?286:586?} (]]..code..[[)]])
end
function get_annex(code)
for i,country in ipairs(countries)do
if country.code==code then
return country.annex
end
if"0"..country.code==code then
return country.annex
end
end
return""
end
function get_areacode_prefix(code)
for i,country in ipairs(countries)do
if country.code==code then
return country.areacode_prefix
end
if"0"..country.code==code then
return country.areacode_prefix
end
end
return""
end
function is_okz_in_country(code)
for i,country in ipairs(countries)do
if country.code==code then
return country.okz
end
if"0"..country.code==code then
return country.okz
end
end
return false
end
function get_countrylist(types)
local countrieslist={}
if(types=="KNOWN")then
require("general")
countrieslist=general.listquery("country:settings/country/list(id,name)")
for i,country in ipairs(countrieslist)do
country.code=(country.id or""):gsub("^0","")
country.areacode_prefix=get_areacode_prefix(country.id)
country.clearname=get_countryname(country.id)
end
elseif types~="UNI"then
for i,country in ipairs(countries)do
if country.types==types or country.types=="UNI"then
country.clearname=country.name
table.insert(countrieslist,country)
end
end
else
for i,country in ipairs(countries)do
country.clearname=country.name
table.insert(countrieslist,country)
end
end
return countrieslist
end
