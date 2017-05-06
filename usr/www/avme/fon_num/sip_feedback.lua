<?lua
g_page_type = "all"
g_page_title = "{?4446:239?}"
g_menu_active_page = "/fon_num/fon_num_list.lua"
g_page_help = "hilfe_fon_gespraechsqualitaet.html"
dofile("../templates/global_lua.lua")
require("http")
require("val")
require("fon_numbers")
require("general")
require("js")
g_val = {
prog = [[
if __value_equal(uiNoise/noise,choose) then
const_error(uiNoise/noise, wrong, error_noise_txt)
end
if __value_equal(uiCrack/crack,choose) then
const_error(uiCrack/crack, wrong, error_crack_txt)
end
if __value_equal(uiEcho/echo,choose) then
const_error(uiEcho/echo, wrong, error_echo_txt)
end
if __value_equal(uiTotal/total,choose) then
const_error(uiTotal/total, wrong, error_feedbackall_txt)
end
if __checked(uiOtherProblem/otherproblem) then
not_empty(uiOtherProblemTxt/otherproblemtxt, error_otherproblem_txt)
end
]]
}
val.msg.error_noise_txt = {
[val.ret.wrong] = [[{?4446:486?}]]
}
val.msg.error_crack_txt = {
[val.ret.wrong] = [[{?4446:798?}]]
}
val.msg.error_echo_txt = {
[val.ret.wrong] = [[{?4446:612?}]]
}
val.msg.error_feedbackall_txt = {
[val.ret.wrong] = [[{?4446:927?}]]
}
val.msg.error_otherproblem_txt = {
[val.ret.empty] = [[{?4446:488?}]]
}
function write_input(select)
local choose = [[{?4446:737?}]]
local option0 = [[{?4446:754?}]]
local option1 = [[{?4446:112?}]]
local option2 = [[{?4446:84?}]]
if select == "choose" then
box.out([[<option value="choose" selected>]]..choose..[[</option><option value="0">]]..option0..[[</option><option value="1">]]..option1..[[</option><option value="2">]]..option2..[[</option>]])
elseif select == "0" then
box.out([[<option value="choose">]]..choose..[[</option><option value="0" selected>]]..option0..[[</option><option value="1">]]..option1..[[</option><option value="2">]]..option2..[[</option>]])
elseif select == "1" then
box.out([[<option value="choose">]]..choose..[[</option><option value="0">]]..option0..[[</option><option value="1" selected>]]..option1..[[</option><option value="2">]]..option2..[[</option>]])
elseif select == "2" then
box.out([[<option value="choose">]]..choose..[[</option><option value="0">]]..option0..[[</option><option value="1">]]..option1..[[</option><option value="2" selected>]]..option2..[[</option>]])
end
end
local ctlmgr_save={}
local localname = nil
local started = nil
local remotename = nil
local duration = nil
local noise = nil
local crack = nil
local echo = nil
local total = nil
g_errormsg = nil
if box.get.localname ~= nil and box.get.started ~= nil and box.get.remotename ~= nil and box.get.duration ~= nil then
localname = box.tohtml(box.get.localname)
started = box.tohtml(box.get.started)
remotename = box.tohtml(box.get.remotename)
duration = box.tohtml(box.get.duration)
elseif box.post.localname ~= nil and box.post.started ~= nil and box.post.remotename ~= nil and box.post.duration ~= nil then
started = box.tohtml(box.post.started)
localname = box.tohtml(box.post.localname)
remotename = box.tohtml(box.post.remotename)
duration = box.tohtml(box.post.duration)
end
if box.post.apply then
if val.validate(g_val) == val.ret.ok then
require("cmtable")
cmtable.add_var(ctlmgr_save, "voipjournal:settings/feedback_localname", localname)
cmtable.add_var(ctlmgr_save, "voipjournal:settings/feedback_started", started)
cmtable.add_var(ctlmgr_save, "voipjournal:settings/feedback_remotename", remotename)
cmtable.add_var(ctlmgr_save, "voipjournal:settings/feedback_duration", duration)
cmtable.add_var(ctlmgr_save, "voipjournal:settings/feedback_noise", box.post.noise)
cmtable.add_var(ctlmgr_save, "voipjournal:settings/feedback_crack", box.post.crack)
cmtable.add_var(ctlmgr_save, "voipjournal:settings/feedback_echo", box.post.echo)
cmtable.add_var(ctlmgr_save, "voipjournal:settings/feedback_total", box.post.total)
if box.post.cutoff then
cmtable.add_var(ctlmgr_save, "voipjournal:settings/feedback_cutoff", "1")
else
cmtable.add_var(ctlmgr_save, "voipjournal:settings/feedback_cutoff", "0")
end
if box.post.silentlocal then
cmtable.add_var(ctlmgr_save, "voipjournal:settings/feedback_silent_local", "1")
else
cmtable.add_var(ctlmgr_save, "voipjournal:settings/feedback_silent_local", "0")
end
if box.post.silentremote then
cmtable.add_var(ctlmgr_save, "voipjournal:settings/feedback_silent_remote", "1")
else
cmtable.add_var(ctlmgr_save, "voipjournal:settings/feedback_silent_remote", "0")
end
if (box.post.otherproblemtxt) then
cmtable.add_var(ctlmgr_save, "voipjournal:settings/feedback_other", box.tohtml(box.post.otherproblemtxt))
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
g_errormsg = general.create_error_div(err,msg)
else
http.redirect("/fon_num/sip_quality.lua")
end
end
end
if box.post.cancel then
http.redirect("/fon_num/sip_quality.lua")
end
if box.post.noise ~= nil then
noise = box.post.noise
else
noise = [[choose]]
end
function get_noise()
return noise
end
if box.post.echo ~= nil then
echo = box.post.echo
else
echo = [[choose]]
end
function get_echo()
return echo
end
if box.post.crack ~= nil then
crack = box.post.crack
else
crack = [[choose]]
end
function get_crack()
return crack
end
if box.post.total ~= nil then
total = box.post.total
else
total = [[choose]]
end
function get_total()
return total
end
function set_selected(value, select)
if value == select then
box.html([[selected]])
end
end
function writecalldata()
require("string_op")
local t=string_op.split2table(started," ",0)
if (not t) then
t={"-","-"}
elseif not t[2] then
t[2]="-"
end
return remotename, t[1], t[2]
end
function get_started()
return started
end
function get_localname()
return localname
end
function get_remotename()
return remotename
end
function get_duration()
return duration
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form id="MainForm" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p><?lua
box.out(general.sprintf([[{?4446:7?}]],writecalldata()))
?>
</p>
<hr>
<div class="formular">
<div>
<label for="uiNoise">{?4446:690?}</label></td>
<select size="1" id="uiNoise" name="noise">
<?lua
write_input(get_noise())
?>
</select>
</div>
<div>
<label for="uiCrack">{?4446:365?}</label>
<select size="1" id="uiCrack" name="crack">
<?lua
write_input(get_crack())
?>
</select>
</div>
<div>
<label for="uiEcho">{?4446:623?}</label>
<select size="1" id="uiEcho" name="echo">
<?lua
write_input(get_echo())
?>
</select>
</div>
</div>
<hr>
<div class="formular">
<div><input type="checkbox" id="uiSilentRemote" name="silentremote" /><label for="uiSilentRemote">{?4446:95?}</label></div>
<div><input type="checkbox" id="uiSilentLocal" name="silentlocal" /><label for="uiSilentLocal">{?4446:595?}</label></div>
<div><input type="checkbox" id="uiInterrupted" name="cutoff"><label for="uiInterrupted">{?4446:542?}</label></div>
<div><input type="checkbox" onclick="ActivateInput()" id="uiOtherProblem" name="otherproblem"><label for="uiOtherProblem">{?4446:119?}</label></div>
<div class="formular"><textarea cols="63" rows="3" id="uiOtherProblemTxt" name="otherproblemtxt" disabled></textarea></div>
</div>
<hr>
<div class="formular">
<label for="uiTotal">{?4446:79?}</label>
<select size="1" id="uiTotal" name="total" style="width:130px;">
<option value="choose" <?lua set_selected([[choose]],get_total()) ?>>{?4446:159?}</option>
<option value="1" <?lua set_selected([[1]],get_total()) ?>>{?4446:117?}</option>
<option value="2" <?lua set_selected([[2]],get_total()) ?>>{?4446:762?}</option>
<option value="3" <?lua set_selected([[3]],get_total()) ?>>{?4446:260?}</option>
<option value="4" <?lua set_selected([[4]],get_total()) ?>>{?4446:589?}</option>
<option value="5" <?lua set_selected([[5]],get_total()) ?>>{?4446:140?}</option>
<option value="6" <?lua set_selected([[6]],get_total()) ?>>{?4446:421?}</option>
</select>
</div>
<p>
<?lua
box.out([[{?4446:577?}]])
?>
{?4446:525?}
</p>
<input type="hidden" name="localname" value="<?lua box.html(get_localname())?>">
<input type="hidden" name="started" value="<?lua box.html(get_started())?>">
<input type="hidden" name="remotename" value="<?lua box.html(get_remotename())?>">
<input type="hidden" name="duration" value="<?lua box.html(get_duration())?>">
<?lua
if g_errormsg ~= nil then
box.out([[<div>]]..g_errormsg..[[</div>]])
end
?>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?4446:816?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript" src="/js/ip.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function onFeedbackSubmit()
{
var isactive = val.active;
<?lua
val.write_js_checks(g_val)
?>
if (isactive)
{
alert("{?4446:667?}");
}
}
function init()
{
ActivateInput();
}
function ActivateInput()
{
jxl.setDisabled("uiOtherProblemTxt", !jxl.getChecked("uiOtherProblem"));
}
ready.onReady(val.init(onFeedbackSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
