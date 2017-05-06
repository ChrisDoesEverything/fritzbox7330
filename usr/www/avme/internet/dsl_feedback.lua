<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_dsl_informationen_feedback.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("newval")
require"general"
require"js"
if (next(box.post) and (box.post.cancel)) then
http.redirect([[/internet/dsl_feedback.lua]])
end
g_errcode = 0
g_errmsg = [[Fehler: Es ist ein Fehler beim Übernehmen der Daten aufgetreten. Die aktuellen Daten dieser Seite wurden nicht gespeichert.]]
g_data={}
g_data.sync =""
g_data.splitter =true
g_data.email =""
g_data.region_code =""
g_data.auto_send =false
g_data.comment =""
g_data.connection_status=""
function convert_enum_to_sync(sync)
if sync=="stable" then
return "0"
elseif sync=="some_disturb" then
return "1"
elseif sync=="often_disturb" then
return "2"
elseif sync=="no_sync" then
return "3"
end
return ""
end
function convert_sync_to_enum(sync)
if sync=="0" then
return "stable"
elseif sync=="1" then
return "some_disturb"
elseif sync=="2" then
return "often_disturb"
elseif sync=="3" then
return "no_sync"
end
return ""
end
function get_var()
g_data.sync = convert_sync_to_enum(box.query("dslmail:settings/sync"))
g_data.splitter = box.query("dslmail:settings/dslSplitter") == "1"
g_data.email = box.query("dslmail:settings/email")
g_data.region_code = box.query("dslmail:settings/PLZ")
g_data.auto_send = box.query("dslmail:settings/sendRepeatedly")=="1"
g_data.comment = box.query("dslmail:settings/comment")
g_data.connection_status = box.query("connection0:status/connect")
end
get_var()
function refill_user_input()
g_data.sync =box.post.sync
g_data.splitter =box.post.splitter ~= nil
g_data.email =box.post.email
g_data.region_code=box.post.region_code
g_data.auto_send =box.post.auto_send~=nil
g_data.comment =box.post.comment
end
function valprog()
newval.msg.no_choice = {
[newval.ret.empty] = [[{?9540:551?}]],
[newval.ret.notfound] = [[{?9540:277?}]]
}
newval.msg.region = {
[newval.ret.empty] = [[{?9540:199?}]],
[newval.ret.outofrange] = [[{?9540:107?}]]
}
newval.msg.err_len = {
[newval.ret.toolong] = [[{?9540:936?}]],
}
newval.msg.txt_email = {
[newval.ret.empty] = [[{?9540:196?}]],
[newval.ret.outofrange] = [[{?9540:866?}]]
}
if newval.value_equal("sync", "no") then
newval.const_error("sync", "empty", "no_choice")
end
newval.length("region_code", 0, 128, "err_len")
newval.length("comment", 0, 250, "err_len")
if not newval.value_empty("email") then
newval.char_range_regex("email", "email", "txt_email")
end
end
if box.post.validate == 'send' then
local valresult, answer = newval.validate(valprog)
box.out(js.table(answer))
box.end_page()
end
if box.post.send then
if newval.validate(valprog) == newval.ret.ok then
local saveset={}
cmtable.add_var (saveset, "dslmail:settings/sync",convert_enum_to_sync(box.post.sync))
cmtable.add_var (saveset, "dslmail:settings/dslSplitter", box.post.splitter and "1" or "0")
cmtable.add_var (saveset, "dslmail:settings/email", box.post.email)
cmtable.add_var (saveset, "dslmail:settings/PLZ" ,box.post.region_code)
cmtable.add_var(saveset, "dslmail:settings/sendRepeatedly", "0")
cmtable.add_var (saveset, "dslmail:settings/comment", box.post.comment)
cmtable.add_var (saveset, "dslmail:settings/send", "1")
local err, msg = box.set_config( saveset)
if err == 0 then
http.redirect( [[/internet/dsl_feedback.lua]])
else
local criterr = general.create_error_div(err,msg,[[{?9540:440?}]])
box.out(criterr)
refill_user_input()
end
else
refill_user_input()
end
end
function write_sync(cur)
if (g_data.sync==cur) then
box.out([[selected="y"]])
end
end
function write_splitter_checked()
box.out(g_data.splitter and [[ checked]] or "")
end
function write_splitter_txt()
local txt = {
["A"] = [[{?9540:216?}]],
["B"] = [[{?9540:856?}]]
}
local ind = box.query("sar:settings/Annex")
if ind ~= "A" and ind ~= "B" then
ind = "B"
end
box.html(txt[ind])
end
function write_email()
box.html(g_data.email)
end
function write_region_code()
box.html(g_data.region_code)
end
function write_auto_send()
if g_data.auto_send then
box.out([[checked='checked']])
end
end
function write_comment()
box.html(g_data.comment)
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript">
function uiDoOnMainFormSubmit() {
if (<?lua box.out(tostring(g_data.connection_status == "5")) ?>)
alert("{?9540:587?}");
else
alert("{?9540:844?}");
}
ready.onReady(ajaxValidation({
applyNames: "send",
okCallback: uiDoOnMainFormSubmit
}));
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>{?9540:913?}</p>
<hr>
<p>{?9540:915?}</p>
<div class="formular">
<p>
<label for="uiSelSync">{?9540:444?}</label>
<select id="uiSelSync" name="sync" >
<option value="no" <?lua write_sync("no")?>>{?9540:813?}</option>
<option value="stable" <?lua write_sync("stable")?>>{?9540:683?}</option>
<option value="some_disturb" <?lua write_sync("some_disturb")?>>{?9540:789?}</option>
<option value="often_disturb" <?lua write_sync("often_disturb")?>>{?9540:491?}</option>
<option value="no_sync" <?lua write_sync("no_sync")?>>{?9540:999?}</option>
</select>
</p>
<p>
<input type="checkbox" name="splitter" id="uiSplitter" <?lua write_splitter_checked() ?>>
<label for="uiSplitter"><?lua write_splitter_txt() ?></label>
</p>
<p>
<label for="uiEmail">{?9540:428?}*</label>
<input type="text" size="50" maxlength="128" id="uiViewEmail" name="email" value="<?lua write_email() ?>">
</p>
<p>
<label for="uiRegionCode">{?9540:372?}*</label>
<input type="text" size="50" maxlength="128" id="uiRegionCode" name="region_code" value="<?lua write_region_code() ?>">
</p>
<p>
<label for="uiComment" style="vertical-align: top;">{?9540:843?}*</label>
<textarea cols="63" rows="3" size="50" maxlength="250" id="uiComment" name="comment"><?lua write_comment() ?></textarea>
<span class="form_input_note">*{?9540:367?}</span>
</p>
</div>
<div id="btn_form_foot">
<button type="submit" id="uiBtnSend" name="send">{?9540:202?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
