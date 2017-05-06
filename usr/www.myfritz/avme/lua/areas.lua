--<?lua
if not gl or not gl.logged_in then
box.end_page()
end
--?>
require("textdb")
local show_nas = false
local show_phone = false
local show_tam = false
local show_homeauto = false
show_nas = config.NAS and gl.userrights.NAS > 0
local fritz_app_activ = false
show_phone = config.FON and (config.DECT or config.AB_COUNT > 0 or fritz_app_activ) and gl.userrights.Phone > 0
if show_phone and config.TAM and config.TAM_MODE > 0 then
for cnt = 0, 4 , 1 do
if box.query( "tam:settings/TAM" .. cnt .. "/Display" ) == "1" then
show_tam = true
break;
end
end
end
show_homeauto = config.HOME_AUTO and gl.userrights.HomeAuto > 0
gl.areas = { calls= { show=show_phone, open=show_phone and box.get.openCalls~=nil and box.get.openCalls=="true", pos=1, id="callsArea", jsObjName="callsJs", label=TXT([[{?960:27?}]]) },
answer= { show=show_tam, open=show_tam and box.get.openAnswer~=nil and box.get.openAnswer=="true", pos=2, id="answerArea", jsObjName="answerJs", label=TXT([[{?960:369?}]]) },
nas= { show=show_nas, open=show_nas and box.get.openNas~=nil and box.get.openNas=="true", pos=3, id="nasArea", jsObjName="nasJs", label=TXT([[{?960:181?}]]) },
homeauto={ show=show_homeauto,open=show_homeauto and box.get.openHomeAuto~=nil and box.get.openHomeAuto=="true",pos=4, id="homeautoArea",jsObjName="homeautoJs",label=TXT([[{?960:717?}]]) },
akt_open_area = "home" }
