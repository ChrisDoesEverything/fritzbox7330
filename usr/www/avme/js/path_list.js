var refreshlist = Array();
var breakrefresh = false;
var currentrefresh = null;
var defpath = Array();
var defpathidx = 0;
var defcurpath = "";
var http;
var gVarSid = "<?lua box.js(box.glob.sid) ?>";
function startRefresh()
{
if (!http) http = newXhr();
if (http && refreshlist.length > 0 && currentrefresh==null)
{
currentrefresh = refreshlist.pop();
var inp = currentrefresh.getElementsByTagName("input");
var i;
for (i=0; i<inp.length; i++)
{
if (inp[i].name=="dir")
{
currentrefreshpath = inp[i].value;
ajaxGet("/lua/verz_liste_async.lua?sid="+gVarSid+"&dir="+encodeURIComponent(inp[i].value), refreshcb);
break;
}
}
}
}
function refreshcb(p_http)
{
{
if (p_http)
{
if (p_http.responseXML)
{
if (p_http.responseXML.documentElement)
{
var resp = p_http.responseXML.documentElement;
var nodes = resp.getElementsByTagName("dir");
if (nodes.length > 0)
{
var list = document.createElement("ul");
if (defpathidx==0 || defpathidx==defpath.length-1 || defcurpath+"/"+defpath[defpathidx]!=currentrefreshpath)
list.style.display = "none";
var parentinp = currentrefresh.firstChild;
while (parentinp && parentinp.nodeName.toLowerCase()!="input") parentinp = parentinp.nextSibling;
var i;
for (i=0; i<nodes.length; i++)
{
var elem = document.createElement("li");
elem.className="incomplete";
elem.innerHTML = '<input type="radio" name="dir" id="'+parentinp.id + "_" + i+'" value="'+parentinp.value + "/" + nodes[i].childNodes[0].nodeValue+'" onclick="enableOk()"> '+
'<label for="'+parentinp.id + "_" + i+'">'+nodes[i].childNodes[0].nodeValue+'</label>';
list.appendChild(elem);
}
currentrefresh.appendChild(list);
addHideButton(currentrefresh, list);
}
else
{
nodes = resp.getElementsByTagName("error");
if (nodes.length > 0)
{
var tmp = '<p>'+nodes[0].childNodes[0].nodeValue+'</p><p>{?621:774?}</p><hr>';
jxl.setHtml("uiViewContentBox", tmp);
breakrefresh = true;
}
}
currentrefresh.className = currentrefresh.className.replace(/[ ]*incomplete[ ]*/g, "")
if (defpathidx!=0)
{
if (defpathidx==defpath.length-1)
{
if (currentrefreshpath == defcurpath+"/"+defpath[defpathidx])
{
checkByLi(currentrefresh);
defpathidx = 0;
}
}
else
{
var nextdef = findPathLi(currentrefresh, defcurpath+"/"+defpath[defpathidx]);
if (nextdef)
{
defcurpath = defcurpath+"/"+defpath[defpathidx];
defpathidx++;
var sub = nextdef.getElementsByTagName("ul");
if (sub!=null && sub.length>0)
{
sub[0].style.display = "block";
iefix();
checkIncomplete(sub[0]);
}
}
}
}
currentrefresh = null;
}
else
currentrefresh = null;
}
else
currentrefresh = null;
}
else
currentrefresh = null;
}
if (currentrefresh==null && !breakrefresh)
startRefresh();
}
function checkIncomplete(list)
{
var child = list.getElementsByTagName("li");
var i;
breakrefresh = true;
for (i=child.length-1; i>=0; i--)
{
if (child[i].className.indexOf("incomplete")!=-1)
{
refreshlist.push(child[i]);
}
}
breakrefresh = false;
startRefresh();
}
function iefix()
{
if (navigator.userAgent.indexOf("MSIE ")!=-1)
{
var i;
var save = "";
var inp = document.getElementsByName("dir");
for (i=0; inp && i < inp.length; i++)
{
if (inp[i].checked)
{
save = inp[i].value;
break
}
}
var div = document.getElementById("listwrapper");
var ul = div.removeChild(div.firstChild);
div.appendChild(ul);
var inp = document.getElementsByName("dir");
for (i=0; inp && i < inp.length; i++)
{
if (inp[i].value == save)
{
inp[i].checked = true;
enableOk();
break
}
}
}
}
function toggleSubTree(img, list)
{
if (list.style.display=="none")
{
list.style.display = "block";
img.src = "/css/default/images/schliessen.gif";
checkIncomplete(list);
}
else
{
list.style.display = "none";
img.src = "/css/default/images/oeffnen.gif";
}
iefix();
}
function addHideButton(item, list)
{
var img = document.createElement("img");
if (list.style.display=="none")
img.src = "/css/default/images/oeffnen.gif";
else
img.src = "/css/default/images/schliessen.gif";
img.style.position = "absolute";
img.onclick = function() { toggleSubTree(img, list); }
item.insertBefore(img, item.firstChild);
}
function checkByLi(li)
{
var inp = li.getElementsByTagName("input");
if (inp && inp.length > 0)
{
inp[0].checked =true;
enableOk();
}
}
function findPathLi(parent, path)
{
var radios = parent.getElementsByTagName("input");
var i;
for (i=0; i<radios.length; i++)
{
if (radios[i].value == path)
{
return radios[i].parentNode;
}
}
return null;
}
function addTreeCtrls()
{
var listitems = document.getElementsByTagName("li");
var i;
for (i=0; i<listitems.length; i++)
{
if (jxl.hasClass(listitems[i],"submenu"))
{
continue;
}
var sub = listitems[i].getElementsByTagName("ul");
if (sub!=null && sub.length>0)
{
addHideButton(listitems[i], sub[0]);
}
}
defpath = <?lua if box.get.inet_path == nil or box.get.inet_path == "" then box.out('""') else box.out('"'..box.tojs(box.get.inet_path)..'"') end ?>.split("/");
if (defpath.length>=2)
{
defcurpath = "/"+defpath[1];
var parentli = findPathLi(document, defcurpath);
if (defpath.length<=2)
{
if (parentli)
{
checkByLi(parentli);
}
}
else
{
defpathidx = 2;
var sub = parentli.getElementsByTagName("ul");
if (sub!=null && sub.length>0)
{
sub[0].style.display = "block";
var img = parentli.getElementsByTagName("img");
if (img && img.length > 0) img[0].src = "/css/default/images/schliessen.gif";
iefix();
checkIncomplete(sub[0]);
}
}
}
}
function enableOk()
{
jxl.enable('uiApply');
}
function stOk()
{
var selection = "";
if (jxl.getChecked("sharingAll"))
{
selection = jxl.getValue("sharingAll");
}
else
{
var radios = document.getElementsByName("dir");
var i;
for (i=0; i<radios.length; i++)
{
if (radios[i].checked)
{
selection = radios[i].value;
break;
}
}
if (selection == "")
{
alert("{?3111:252?}");
return false;
}
}
return true;
}
function onAllOrOne(val)
{
jxl.display("listwrapper", val);
jxl.disableNode('btn_ok', jxl.getChecked("sharingOne"));
}
