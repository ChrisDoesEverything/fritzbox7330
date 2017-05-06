var fc = fc || (function()
{
"use strict";
var lib = {};
var fields = new Object();
var last_event_char = -1;
var last_event_elem = null;
var last_event_content = "";
var last_coursor_startpos = -1;
var last_coursor_endpos = -1;
var keep_pressed_cnt = 0;
function setValue(elem, val)
{
var elemId = elem;
if (typeof elemId != 'string')
{
elemId = elem.id || "";
}
if (fields[elemId].fcType == 'mac')
{
val = (val || "").toUpperCase();
}
jxl.setValue(elem, val || "");
}
function check_lenght(content, level, lessthan)
{
var l = content.length;
if (l != null && ((l >= level && !lessthan) || (l <= level && lessthan)))
return true;
return false;
}
function ignore_char(cc)
{
if (cc==8 || cc==9 || (cc >= 13 && cc <= 46 ) || (cc >= 13 && cc <= 46 ) || cc==91 || cc==92 || cc==93 || cc >= 106)
return true;
return false;
}
function check_back_char(cc)
{
if (cc==8 || cc==37)
return true;
return false;
}
function check_foreward_char(cc)
{
if (cc==39)
return true;
return false;
}
function gotoNextID(akt_id, content, event_char, event_char_code, backward)
{
setValue(akt_id, content.substring(0, fields[akt_id]["max_char"] ));
var next = (backward) ? fields[akt_id]["prev"] : fields[akt_id]["next"];
if (!next && !backward)
{
if (fields[akt_id].jumpTo)
{
jxl.focus(fields[akt_id].jumpTo);
}
}
if (next == null)
return;
jxl.focus(next);
if (!backward && !check_foreward_char(event_char_code))
{
jxl.select(next);
if (content === last_event_content && keep_pressed_cnt < 2)
setValue(next, event_char);
}
jxl.focus(next);
}
function del_event_char(event)
{
last_event_char = -1;
}
function set_event_char(event)
{
event = (event == null) ? window.event : event;
var cc = event.keyCode;
if (ignore_char(cc) && !check_back_char(cc) && !check_foreward_char(cc))
return;
if (last_event_char === cc)
keep_pressed_cnt++;
last_event_elem = jxl.evtTarget(event);
last_event_content = jxl.getValue(last_event_elem);
if (typeof(last_event_elem.selectionStart) == "number")
last_coursor_startpos = last_event_elem.selectionStart;
if (typeof(last_event_elem.selectionEnd) == "number")
last_coursor_endpos = last_event_elem.selectionEnd;
last_event_char=cc;
}
function get_char_from_charcode(cc)
{
if (cc >= 96 && cc <= 105)
cc = cc - 48;
return String.fromCharCode(cc);
}
function jump(event)
{
event = (event == null) ? window.event : event;
var cc = event.keyCode;
var c = get_char_from_charcode(cc);
if (!event.shiftKey)
{
c = c.toLowerCase();
}
if (last_event_char!=cc)
return;
var elem = jxl.evtTarget(event);
if(typeof(elem.selectionStart) == "undefined" || typeof(elem.selectionEnd) == "undefined")
return;
var content = jxl.getValue(elem);
if (!ignore_char(cc))
setValue(elem, content);
var forward_char_jump = (check_foreward_char(cc) && elem.selectionStart === elem.selectionEnd && last_coursor_startpos === last_coursor_endpos &&
last_coursor_endpos === content.length);
var allowed_char_jump = (!check_foreward_char(cc) && check_lenght(content, fields[elem.id]["max_char"], false) && elem.selectionStart === elem.selectionEnd &&
last_coursor_startpos === last_coursor_endpos && elem.selectionStart === fields[elem.id]["max_char"]);
if ( (!ignore_char(cc) || check_foreward_char(cc)) && ( forward_char_jump || allowed_char_jump ))
gotoNextID(elem.id, content, c, cc);
else if (check_back_char(cc) && elem.selectionStart === elem.selectionEnd && last_coursor_startpos === last_coursor_endpos && last_coursor_endpos === 0)
gotoNextID(elem.id, content, c, cc, true);
keep_pressed_cnt = 0;
}
function create_event_handler(elem, max_char, fcType, jumpTo)
{
var nodes = jxl.walkDom(elem, "input");
for (var i = 0; i < nodes.length; i++)
{
fields[nodes[i].id] = new Object();
if (nodes[i-1])
fields[nodes[i].id]["prev"] = nodes[i-1].id;
else
fields[nodes[i].id]["prev"] = null;
if (nodes[i+1])
fields[nodes[i].id]["next"] = nodes[i+1].id;
else
fields[nodes[i].id]["next"] = null;
fields[nodes[i].id].fcType = fcType;
if (nodes[i].maxLength && nodes[i].maxLength > 0)
max_char = nodes[i].maxLength;
fields[nodes[i].id]["max_char"] = max_char;
jxl.addEventHandler(nodes[i], "keyup", jump);
jxl.addEventHandler(nodes[i], "keydown", set_event_char);
jxl.addEventHandler(nodes[i], "blur", del_event_char);
}
if (nodes.length && jumpTo)
{
fields[nodes[nodes.length-1].id].jumpTo = jxl.get(jumpTo);
}
}
lib.init = function (id, max_char, fcType, jumpTo)
{
var elem = jxl.get(id);
if (elem && max_char && max_char > 0)
{
create_event_handler(elem, max_char, fcType || "", jumpTo);
}
};
return lib;
})();
