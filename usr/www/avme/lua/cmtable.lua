--[[Access denied<?lua
    box.end_page()
?>?>]]
module(...,package.seeall);
function add_var(saveset,ctlname,value)
if general and type(value)~="string"then
end
table.insert(saveset,{["name"]=ctlname,["value"]=tostring(value)})
end
function save_checkbox(saveset,ctlname,viewname,setvalue,unsetvalue)
setvalue=setvalue or"1"
unsetvalue=unsetvalue or"0"
if(box.post[viewname])then
add_var(saveset,ctlname,setvalue)
else
add_var(saveset,ctlname,unsetvalue)
end
end
function set_config_single_step(saveset)
local tmpset={}
local errcode,errmsg=0,nil
for i,elem in ipairs(saveset)do
tmpset=elem
errcode,errmsg=box.set_config(tmpset)
if(errcode>0)then
break
end
end
return errcode,errmsg
end