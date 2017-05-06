<?lua
function error_msg(error_txt)
box.out([[
<!DOCTYPE html>
<html>
<head>
<meta http-equiv=content-type content="text/html; charset=utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width; initial-scale=1.1; maximum-scale=1.0; user-scalable=0;" />
<style type="text/css">
html {
background-color: #FFFEBD;
}
body {
font-family: Arial,serif,sans-serif,cursive;
color: #3f464c;
margin: 0;
padding: 1em 1.5em 2em 1.5em;
min-height: 35em;
background: -webkit-linear-gradient(bottom, #FFFEBD, #FFFFFA);
background: -moz-linear-gradient(bottom, #FFFEBD, #FFFFFA);
background: -ms-linear-gradient(bottom, #FFFEBD, #FFFFFA);
filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#FFFFFA', endColorstr='#FFFEBD', GradientType=0);
background: -o-linear-gradient(bottom, #FFFEBD, #FFFFFA);
outline: none;
}
h4 {
padding: 0;
padding-top: 0.5em;
margin: 0;
font-size: 0.95em;
}
#head {
width: 16em;
height: 2em;
padding: 0 0.8em 0 0.8em;
margin: auto;
margin-top: 5em;
border: 0.08em solid #8da4a3;
border-top-right-radius: 1em;
border-top-left-radius: 1em;
background-color: #add1f1;
background: -webkit-linear-gradient(top, #cee9ff, #add1f1 49%, #9ec8ed 51%, #96bcde 100%);
background: -moz-linear-gradient(top, #cee9ff, #add1f1 49%, #9ec8ed 51%, #96bcde 100%);
background: -ms-linear-gradient(top, #cee9ff, #add1f1 49%, #9ec8ed 51%, #96bcde 100%);
background: -o-linear-gradient(top, #cee9ff, #add1f1 49%, #9ec8ed 51%, #96bcde 100%);
}
#foot {
width: 16em;
background-color: #fbfaf7;
padding: 0;
padding: 0.8em 0.8em 1em 0.8em;
margin: auto;
border: 0.08em solid #8da4a3;
border-top: none;
border-bottom-right-radius: 1em;
border-bottom-left-radius: 1em;
}
#foot p {
font-size: 0.85em
}
</style>
</head>
<body>
]])
if not error_txt or error_txt == "" then
box.out([[<div id="head"><h4>{?8594:989?}</h4></div><div id="foot"><p>]])
box.html([[{?8594:377?}]])
else
box.out([[<div id="head"><h4>{?8594:47?}</h4></div><div id="foot"><p>]])
box.html(error_txt)
end
box.out([[</p></div></body></html>]])
box.end_page()
end
id = box.get.id
if not id then
error_msg()
end
path, is_dir = box.find_filelink(id)
if not path then
error_msg()
end
if is_dir ~= "0" then
box.login_user("@dir-"..id, "", { "NAS" } , "filelink-zone")
if box.query("rights:status/NAS") ~= "1" then error_msg() end
box.header("HTTP/1.0 302 Moved Temporarily\n"..
"Location: /nas?sid="..box.glob.sid.."\n"..
"\n")
box.end_page()
else
gl={}
gl.bib={}
gl.bib.wu = require("libwebusb")
gl.bib.wu.WebUsb_UseDB( false)
gl.bib.wu.WebUsb_Init( "<full-access>", true)
fail = gl.bib.wu.WebUsb_Get ("<full-access>", path)
if type(fail) == "number" then
if fail == 0 then
elseif fail > 0 then
if fail == 1 then
error_msg([[{?8594:141?}]])
elseif fail == 2 then
error_msg([[{?8594:831?}]])
elseif fail == 3 then
error_msg([[{?8594:730?}]])
else
error_msg([[{?8594:448?}]])
end
end
end
end
?>
