<?lua
package.path = "../lua/?.lua;../menus/?.lua;../files/?.lua;../help/?.lua;../?.lua;" .. (package.path or "")
g_check_sid_cb = function()
if not gl.logged_in then
if (box.glob.inputsid and box.glob.inputsid ~= "0000000000000000") and not box.get.logout and not box.post.logout then
require ("http")
http.redirect("/myfritz?logout=2")
end
end
end
require("check_sid")
require("href")
if gl.logged_in and (box.get.own_email or box.get.own_password) then
gl.sso_edit = true
end
local app_allowed = { ["1"]=true, noaudio=true }
if box.get.app and not app_allowed[box.get.app] then
box.get.app = nil
end
if gl.logged_in and box.get.help then
local function isboxonline()
local online = box.query('connection0:status/connect') == "5"
if not online and config.USB_GSM then
online = box.query("umts:settings/enabled") == "1" and box.query("gsm:settings/Established") == "1"
end
return online
end
if config.ONLINEHELP then
local topic = "hilfe_was_ist_myfritz"
require"helpurl"
local url = helpurl.get(topic)
if isboxonline() then
require("http")
http.redirect(url)
end
end
gl.help = true
end
if gl.logged_in and box.post.apply and
((box.post.own_password and box.post.own_password ~= "" and box.post.own_password ~= "****") or
(box.post.own_email)) then
require("sso_dropdown")
sso_dropdown.save_values()
end
if gl.logged_in and not gl.sso_edit and not gl.help then
require("areas")
end
?>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv=content-type content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta name="format-detection" content="telephone=no" />
<meta http-equiv="x-rim-auto-match" content="none" />
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
<meta name="mobile-web-app-capable" content="yes" />
<meta name="apple-mobile-web-app-capable" content="yes" />
<meta name="apple-mobile-web-app-status-bar-style" content="black" />
<title>MyFRITZ!</title>
<link rel="shortcut icon" href="/myfritz/css/default/images/app_icon.png" />
<link rel="apple-touch-icon" href="/myfritz/css/default/images/homeScreenIcon.png" />
<link rel="stylesheet" type="text/css" href="/myfritz/css/default/main.css"/>
<?lua
if not gl.logged_in then
box.out([[<link rel="stylesheet" type="text/css" href="/myfritz/css/default/login.css"/>]])
elseif gl.sso_edit then
box.out([[<link rel="stylesheet" type="text/css" href="/myfritz/css/default/sso_edit.css"/>]])
elseif gl.help then
box.out([[<link rel="stylesheet" type="text/css" href="/myfritz/css/default/help.css"/>]])
else
box.out([[<link rel="stylesheet" type="text/css" href="/myfritz/css/default/sso_dropdown.css"/>]])
if box.get.app then
box.out([[<link rel="stylesheet" type="text/css" href="/myfritz/css/default/app.css"/>]])
end
end
?>
<script type="text/javascript" src="/myfritz/js/jxl.js"></script>
</head>
<body>
<?lua
if not box.get.app then
box.out([[
<div id="intro_box">
<div id="intro_bar">
<div id="intro_title_box" >
<div id="intro_logo_link" title="]], box.tohtml([[{?861:140?}]]), [[">
<svg id="intro_logo" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 47 37" preserveAspectRatio="xMidYMid meet" version="1.1">
<path id="path2" d="m 20.05232,0.89159561 c 0.53556,-0.29663 1.02358,0.20450899 1.48785,0.40901799 0.93036,0.421914 1.6688,1.145986 2.45293,1.781622 2.70336,2.321453 5.29155,4.77556 7.91447,7.1909764 2.97021,-0.02027 5.94042,0.08659 8.90698,0.221091 -0.19923,0.374012 -0.40029,0.746181 -0.60318,1.116508 0.3875,0.01474 0.77682,0.03317 1.16615,0.04974 -1.30506,2.409889 -2.58271,4.832675 -3.87315,7.249933 0.95047,-0.02395 1.90093,-0.06449 2.84774,-0.145551 0.007,0.442181 0.0219,0.884363 0.0274,1.328387 0.011,-0.07738 0.0347,-0.232146 0.0457,-0.309527 0.75672,-0.403491 1.34711,-1.042812 2.04899,-1.527369 -0.37105,0.0018 -0.74027,-0.0037 -1.10766,-0.01106 0.12247,-2.080096 0.2431,-4.160191 0.38019,-6.240286 1.07293,0.103176 2.15134,0.149236 3.22245,0.276363 -0.0494,0.23583 -0.095,0.471661 -0.14074,0.709333 0.25589,0.01474 0.51361,0.02948 0.77133,0.04238 -0.29976,1.84058 -0.57941,3.684845 -0.84628,5.530953 -0.42954,-0.01658 -0.8609,-0.02764 -1.29044,-0.04974 0.56114,0.655903 1.09487,1.335757 1.63042,2.015611 -0.54835,0.456921 -1.09852,0.910157 -1.65235,1.356023 -0.16451,-0.191612 -0.32718,-0.385066 -0.48986,-0.576678 -0.19192,0.180557 -0.38567,0.361114 -0.57759,0.541672 -0.41675,-0.556412 -0.86456,-1.08703 -1.29592,-1.628702 0.0183,0.858569 0.009,1.718981 0.0164,2.57755 -1.59386,-0.0018 -3.18772,0.0037 -4.78341,-0.0037 -4.15464,3.998057 -8.2654,8.049545 -12.64487,11.797033 -0.64522,0.506666 -1.25754,1.092557 -2.02523,1.405768 -0.28148,0.01843 -0.49168,-0.206351 -0.73661,-0.307684 -0.41491,-0.221091 -0.92487,-0.211879 -1.27581,-0.561939 -2.20253,-1.750302 -4.22776,-3.71064 -6.32061,-5.589911 -2.66497,-2.503852 -5.37198,-4.965329 -7.94554,-7.56683 0.002,0.619054 0,1.239951 0.002,1.860847 -1.09669,-0.0055 -2.19338,-0.01106 -3.29007,0.0037 0,-0.221091 0,-0.442182 0,-0.66143 -0.42589,0 -0.84994,0.0018 -1.274,0.0018 0,-4.217306 0,-8.432769 0,-12.650075 2.36338,-0.110545 4.72858,-0.11423 7.09378,-0.125284 0.0146,0.405333 0.0219,0.808823 0.0329,1.214156 0.27965,-0.07554 0.54469,-0.195297 0.74209,-0.416387 3.01957,-2.9257684 6.07386,-5.8202144 9.2104,-8.6188544 0.71285,-0.576678 1.36904,-1.23995 2.17328,-1.68950099 z" style="fill:#000000"></path>
<path id="path3" d="m 15.86296,4.7938466 c 1.48967,-1.289696 2.87333,-2.724943 4.54213,-3.788021 1.54634,0.89726 2.80388,2.199853 4.15464,3.355052 2.35423,2.111416 4.65912,4.276263 6.96948,6.4355824 0.32353,0.237673 0.14806,0.689066 0.19376,1.02623 -1.44398,-1.282326 -2.69422,-2.7746894 -4.19851,-3.9925304 -1.15701,-0.948848 -2.28112,-1.952968 -3.54597,-2.758107 0.59038,0.993066 1.43301,1.798204 2.20983,2.640192 1.7675,1.742932 3.47835,3.5448214 5.25499,5.2766984 -2.92086,0.07554 -5.8472,0.01658 -8.76989,0.02948 0.007,-0.329794 0.0128,-0.659587 0.0201,-0.989381 -0.18096,0.0073 -0.54287,0.02211 -0.72382,0.03132 0,-0.409018 0,-0.818035 -0.002,-1.227053 -0.96509,-0.0037 -1.92835,0 -2.89344,-0.0037 0.15354,0.574836 0.29428,1.153357 0.42953,1.73372 -0.44233,0.103176 -0.88283,0.215563 -1.32334,0.324266 0.007,3.11738 0.0219,6.236601 0.0183,9.355823 0.42954,0.0055 0.85908,0.0092 1.28862,0.0129 0.002,0.211879 0.004,0.4256 0.005,0.637478 1.0638,0 2.12759,-0.0018 3.19138,0.0018 -0.002,-2.161162 0.003,-4.322324 -0.004,-6.483486 0.20655,-0.01474 0.41491,-0.02948 0.62329,-0.04238 -0.002,0.149237 -0.002,0.449551 -0.002,0.60063 0.60135,0 1.20271,0 1.80406,-0.0037 0.002,2.658616 0,5.317232 0.002,7.975848 0.42588,-0.0055 0.85177,-0.0073 1.27764,-0.01106 0,0.154764 0.002,0.464291 0.002,0.619054 0.65254,0 1.30507,0 1.9576,0 -2.29391,2.177744 -4.78158,4.12887 -7.24731,6.09842 -0.3546,0.298472 -0.75672,0.572993 -0.98886,0.985696 -0.1846,0.843829 -0.0183,1.720823 0.12978,2.559125 -2.69238,-2.015611 -5.06489,-4.423657 -7.57266,-6.656673 -1.25389,-1.206787 -2.55712,-2.360144 -3.80187,-3.576143 0.3217,0.0092 0.64339,0.01658 0.96692,0.02395 -0.005,0.149237 -0.0183,0.447709 -0.0238,0.596945 1.06013,0 2.12209,0.0073 3.18223,0.0037 -0.0293,-1.527369 0.0311,-3.054737 -0.0384,-4.578421 0.80424,1.472096 1.71632,2.879707 2.54981,4.335221 0.17364,-0.149236 0.34729,-0.300315 0.52275,-0.447709 0.15537,0.268994 0.31073,0.537988 0.46793,0.808824 0.9066,-0.733284 1.7145,-1.578956 2.60099,-2.336192 -0.9066,-1.07229 -1.83514,-2.124313 -2.72711,-3.205816 0.71102,-0.565623 1.37635,-1.284168 1.58289,-2.199852 0.11699,-0.757236 0.0439,-1.613963 -0.47523,-2.216435 -0.56297,-0.66143 -0.92488,-1.549477 -1.77481,-1.903223 -1.96674,-0.937793 -4.21313,-0.663272 -6.32061,-0.655902 2.49497,-2.533331 5.15811,-4.8934754 7.94737,-7.0933284 1.0583,-0.812508 2.00329,-1.77978 3.15847,-2.457792 -0.66898,-0.222933 -0.29611,-1.090714 -0.39664,-1.623174 -0.0914,0.01106 -0.27234,0.03685 -0.36373,0.04791 -2.1349,2.157477 -4.50376,4.062542 -6.7008,6.153692 -1.56644,1.29338 -2.89527,2.8447004 -4.3758,4.2338874 -0.004,-0.274521 -0.004,-0.550884 -0.002,-0.827248 2.3652,-2.3196104 4.79986,-4.5636814 7.21807,-6.8261764 z" style="fill:#f8ec17"></path>
<path id="path4" d="m 19.72332,2.0596916 c 0.0914,-0.01106 0.27234,-0.03685 0.36373,-0.04791 0.10053,0.53246 -0.27234,1.400241 0.39664,1.623174 -1.15519,0.678012 -2.10017,1.645284 -3.15847,2.457792 -2.78926,2.199853 -5.4524,4.5599974 -7.94738,7.0933284 -0.24675,0.0018 -0.49168,0.0055 -0.73844,0.01106 0,-0.246885 0,-0.495612 0,-0.742496 l 0.007,-0.0073 c 1.48053,-1.389187 2.80936,-2.9405074 4.3758,-4.2338874 2.19704,-2.09115 4.5659,-3.996215 6.7008,-6.153692 z" style="fill:#ffffff"></path>
<path id="path5" d="m 26.18832,7.7122446 c -0.77682,-0.841988 -1.61945,-1.647126 -2.20983,-2.640192 1.26485,0.805139 2.38896,1.809259 3.54597,2.758107 1.50429,1.217841 2.75453,2.7102044 4.19851,3.9925304 -0.007,0.425599 -0.009,0.851199 -0.0146,1.276799 -0.0658,-0.02764 -0.19923,-0.08291 -0.26504,-0.110546 -1.77664,-1.731877 -3.48748,-3.5337664 -5.25499,-5.2766984 z" style="fill:#fcd307"></path>
<path id="path6" d="m 1.05212,10.807515 c 2.19155,-0.05159 4.38311,-0.09397 6.57284,-0.165818 0.004,0.917526 0.002,1.83321 0.004,2.748895 -1.11132,0 -2.22264,0 -3.33395,0.0018 0,0.843829 0,1.687659 0.002,2.531489 1.0254,-0.02027 2.05264,-0.02211 3.07804,-0.01658 -0.002,0.873308 -0.002,1.746616 -0.002,2.619925 -1.00897,0.0018 -2.01792,-0.0018 -3.02871,0.0055 0.009,1.464726 0.011,2.931295 0,4.396021 -1.09486,-0.0129 -2.18972,-0.0073 -3.28459,-0.0055 -0.004,-4.03859 0.009,-8.077181 -0.007,-12.115772 z" style="fill:#e2001a"></path>
<path id="path7" d="m 31.95693,13.396119 c 0.0164,-0.941478 0.0146,-1.882956 0.011,-2.822592 2.79656,0.02395 5.59679,-0.0092 8.38787,0.197139 -1.48967,2.791271 -2.96107,5.591753 -4.4745,8.370127 1.40742,0.03869 2.81119,-0.0037 4.21678,-0.05343 0,0.934109 0,1.868217 0,2.802325 -2.91538,-0.0018 -5.83075,0 -8.7443,-0.0037 1.48419,-2.848386 2.93731,-5.713353 4.41236,-8.565423 -1.27034,0.0129 -2.53884,0.04421 -3.80918,0.07554 z" style="fill:#e2001a"></path>
<path id="path8" d="m 19.42355,11.142836 c 0.74393,0.0055 1.48785,0.0055 2.23177,0.0018 0.007,3.620361 0.004,7.240721 0.004,10.862924 -1.04917,-0.01106 -2.09834,-0.01106 -3.14751,-0.0018 -0.0146,-2.97367 -0.0146,-5.949183 -0.0146,-8.924695 0.44965,-0.09949 0.89746,-0.204509 1.34711,-0.305843 -0.13343,-0.547199 -0.26869,-1.090714 -0.4204,-1.632386 z" style="fill:#e2001a"></path>
<path id="path9" d="m 41.99349,12.292508 c 0.88101,0.09949 1.76568,0.171345 2.65218,0.211878 -0.29245,1.842423 -0.55749,3.690373 -0.8536,5.532796 -0.70737,-0.02579 -1.41473,-0.04053 -2.12393,-0.04422 0.0877,-1.903222 0.23579,-3.799075 0.32535,-5.700456 z" style="fill:#e2001a"></path>
<path id="path10" d="m 8.83132,13.471658 c 1.96126,-0.07001 3.96455,-0.237672 5.88559,0.272679 0.77134,0.208193 1.54999,0.620896 1.94846,1.350496 0.47706,0.88989 0.45147,2.050616 -0.10784,2.898131 -0.34729,0.51772 -0.82252,0.928581 -1.27034,1.35418 0.95778,1.081502 1.87718,2.196168 2.80388,3.305307 -0.81155,0.790399 -1.63225,1.577113 -2.53336,2.268022 -1.10218,-1.870059 -2.22629,-3.729064 -3.3376,-5.595438 0.81703,-0.683539 1.83147,-1.60475 1.53902,-2.800482 -0.23944,-0.766448 -1.06562,-1.044654 -1.79492,-0.96543 -0.003,3.039998 0,6.081838 -0.002,9.123677 -1.04368,-0.0037 -2.0892,-0.0055 -3.13289,-0.0055 0,-3.734591 -0.003,-7.469182 0.002,-11.205615 z" style="fill:#e2001a"></path>
<path id="path11" d="m 22.31699,13.294786 c 3.12558,0.0073 6.24933,0.0037 9.37307,0.0018 0,0.952532 0,1.905065 0,2.857597 -1.02906,-0.02211 -2.05813,-0.05343 -3.08536,-0.08106 0.003,2.855755 -0.002,5.713352 0.002,8.569108 -1.08024,0 -2.16232,0.0037 -3.24439,-0.0037 0.0164,-2.855755 0.002,-5.71151 0.009,-8.567265 -1.0181,0.03132 -2.0362,0.05712 -3.05429,0.08659 0.002,-0.954375 0,-1.908749 0,-2.863124 z" style="fill:#e2001a"></path>
<path id="path12" d="m 5.3219,15.601499 c 0,-0.434812 -0.002,-0.869624 -0.007,-1.304435 0.48072,0 0.95961,0 1.44032,0.01842 -0.0146,0.08659 -0.0402,0.257939 -0.053,0.344533 -0.37836,0.237672 -0.71467,0.536145 -1.02906,0.854884 0.41857,0.0073 0.83714,0.01106 1.25389,0.0092 0.26503,-0.294788 0.53555,-0.58589 0.80789,-0.873308 0.223,-0.108703 0.44416,-0.217406 0.66533,-0.326109 0.0383,-0.01842 0.11698,-0.05712 0.15537,-0.07554 0.0183,3.487706 -0.0293,6.975412 0.0201,10.461276 -1.04552,-1.066763 -2.16597,-2.054301 -3.20783,-3.124749 -0.005,-0.718545 -0.005,-1.435247 -0.004,-2.153792 0.99251,0.0055 1.98684,-0.0018 2.98118,0.0092 0.002,-0.88252 0.002,-1.763199 0,-2.645719 -0.24127,0.0018 -0.48255,0.0037 -0.72199,0.0055 0.002,-0.407176 0.005,-0.812509 0.007,-1.219684 -0.76951,-0.0073 -1.53903,0 -2.30854,0.02027 z" style="fill:#f8ec17"></path>
<path id="path13" d="m 6.75492,14.315488 c 0.54835,0.01474 1.09669,0.01474 1.64504,0.0092 -0.22117,0.108703 -0.44233,0.217406 -0.66533,0.326109 -0.27234,0.287418 -0.54286,0.57852 -0.8079,0.873308 -0.41674,0.0018 -0.83531,-0.0018 -1.25388,-0.0092 0.31439,-0.318739 0.6507,-0.617212 1.02906,-0.854884 0.0128,-0.08659 0.0384,-0.257939 0.053,-0.344533 z" style="fill:#ffffff"></path>
<path id="path14" d="m 32.68806,14.254688 0.0621,0.06264 c 0.48254,0.482715 0.9724,0.95806 1.43301,1.464726 -1.08207,2.142738 -2.19521,4.270736 -3.28459,6.409789 0.34363,-0.0037 0.68908,-0.0055 1.03272,-0.0073 -0.77317,0.720388 -1.50978,1.483151 -2.30123,2.183271 -0.002,-2.467004 0.002,-4.934008 -0.002,-7.401012 1.0181,0.0073 2.03619,0.0018 3.05612,0.0055 -0.002,-0.906472 -0.007,-1.811102 0.003,-2.717574 z" style="fill:#f8ec17"></path>
<path id="path15" d="m 32.7502,14.31733 c 0.75124,-0.0092 1.50247,-0.04238 2.25371,-0.07738 -0.28149,0.512194 -0.552,1.029915 -0.8079,1.556848 l -0.0128,-0.01474 C 33.7226,15.275392 33.23274,14.800047 32.7502,14.317332 z" style="fill:#fcd307"></path>
<path id="path16" d="m 12.98231,16.437959 c 0.1773,0.03685 0.35459,0.07001 0.52641,0.127127 0.21203,0.657745 -0.23031,1.24732 -0.552,1.776095 0.0256,-0.635635 0.0311,-1.269429 0.0256,-1.903222 z" style="fill:#f8ec17"></path>
<path id="path17" d="m 42.73011,18.383557 c 0.44416,0.565624 0.8938,1.127563 1.33979,1.693187 -0.55566,0.455078 -1.11131,0.906472 -1.66515,1.36155 -0.45878,-0.561939 -0.91208,-1.127563 -1.36538,-1.693186 0.56663,-0.451394 1.12411,-0.912 1.69074,-1.361551 z" style="fill:#e2001a"></path>
<path id="path18" d="m 31.93134,22.184475 c 0.25224,-0.0018 0.5063,-0.0073 0.75854,-0.01106 -0.10784,0.210036 -0.21568,0.420072 -0.32352,0.630108 0.65253,-0.0037 1.30506,-0.0092 1.95942,-0.01658 -2.46207,2.465162 -5.02102,4.825306 -7.54342,7.225982 -1.84427,1.637914 -3.61543,3.367949 -5.5913,4.849257 -0.28514,0.147394 -0.61415,0.519563 -0.9523,0.331636 -0.14806,-0.838302 -0.31438,-1.715295 -0.12978,-2.559125 0.23214,-0.412703 0.63426,-0.687224 0.98886,-0.985696 2.46573,-1.96955 4.95339,-3.920676 7.24731,-6.098419 0.42954,0 0.86091,0 1.29227,0 -0.005,-0.394279 -0.007,-0.788557 -0.007,-1.182836 0.79145,-0.70012 1.52806,-1.462883 2.30123,-2.183271 z" style="fill:#fcd307"></path>
</svg>
<div id="intro_app_logo"></div>
</div>
]])
if gl.logged_in then
box.out([[<div id="intro_boxinfo">]])
if not gl.filelink_mode then
box.out([[<p>]], box.tohtml(box.query("box:settings/hostname")), [[</p>
<p>]], box.tohtml(config.PRODUKT_NAME), [[</p>
]])
end
box.out([[
</div>]])
if not gl.help then
box.out([[
<div id="intro_menu_box">
<div></div>
<div></div>
<div></div>
</div>
]])
end
end
box.out([[
</div>
</div>
</div>
<div class="clear_float"></div>
]])
if gl.logged_in and not gl.sso_edit and not gl.help then
box.out([[
<div id="nav_box">
<div id="nav_link_box">
]])
if gl.show_logout then
require("sso_dropdown")
sso_dropdown.init {
logout_link = href.get_zone_link([[myfritz]])..[[&logout=1]],
logout_onclick = "logoutLocal()",
email_link = href.get("/myfritz/index.lua", "own_email=", "back_to_page=/myfritz/index.lua"),
password_link = href.get("/myfritz/index.lua", "own_password=", "back_to_page=/myfritz/index.lua")
}
sso_dropdown.write_list()
box.out([[<span id="sso_logout">]])
sso_dropdown.write_head()
box.out([[<span class="link_divider_vertical"> | </span><span class="link_divider_horizontal"><hr></span></span>]])
box.out([[
<span id="old_logout" style="display:none"><a id="plainLogoutLink" href=']], href.get_zone_link([[myfritz]]), [[&logout=1' onclick='logoutLocal()'>]], box.tohtml([[{?861:911?}]]), [[</a><span class="link_divider_vertical"> | </span><span class="link_divider_horizontal"><hr></span></span>
]])
end
box.out([[
<a href="]], href.get_zone_link([[box]]), [[">FRITZ!Box</a>
]])
if config.NAS then
box.out([[
<span class="link_divider_vertical"> | </span><span class="link_divider_horizontal"><hr></span><a href="]], href.get_zone_link([[nas]]), [[">FRITZ!NAS</a>
]])
end
box.out([[
<span class="link_divider_vertical"> | </span><span class="link_divider_horizontal"><hr></span><a class="nav_link_selected" id="myfritzLink" href="]], href.get_zone_link([[myfritz]]), [[">MyFRITZ!</a>
</div>
</div>
]])
end
end
content = "login.lua"
if gl.logged_in then
if gl.sso_edit then
content = "sso_editmyself.lua"
elseif gl.help then
content = "help/help.lua"
else
content = "content.lua"
end
end
?>
<?include content ?>
<?lua
if gl.logged_in and not gl.sso_edit and not gl.help then
box.out([[<div id="foot_box">]])
if not box.get.app then
local avmHref = [[http://www.avm.de]]
if config.language~="de" then
avmHref = [[http://www.avm.de/en]]
end
box.out([[
<div id="foot_link_box">
<span class="del_link"><span class="link_divider_horizontal"><hr></span><a href=']], href.get_zone_link([[myfritz]])..[[&help=1]], [[' target='_blank'>]], box.tohtml([[{?861:611?}]]), [[</a><span class="link_divider_vertical"> | </span></span>
<span class="link_divider_horizontal"><hr></span><a href=']], avmHref, [[' target='_blank'>avm.de</a>
</div>
]])
end
box.out([[</div>]])
end
if gl.logged_in and not gl.sso_edit and not gl.help then
box.out([[
<script type="text/javascript" src="/myfritz/js/history.js"></script>
<script type="text/javascript" src="/myfritz/js/cookie.js"></script>
<script type="text/javascript" src="/myfritz/js/ready.js"></script>
<script type="text/javascript" src="/myfritz/js/touch.js"></script>
<script type="text/javascript" src="/myfritz/js/sso_dropdown.js"></script>
<script type="text/javascript" src="/myfritz/js/responsive.js"></script>
<script type="text/javascript">
var gAppAutoLogoutHint = true;
</script>
]])
local any_area = false;
if gl.areas then
for idx, area in pairs(gl.areas) do
if area.show then
if not any_area then
box.out([[
<script type="text/javascript" src="/myfritz/js/ajax.js"></script>
<script type="text/javascript" src="/myfritz/js/get_data.js"></script>
]])
end
any_area = true
if 'nas' == idx then
box.out([[
<script type="text/javascript" src="/myfritz/js/audio.js"></script>
<script type="text/javascript" src="/myfritz/js/galery.js"></script>
]])
end
box.out([[
<script type="text/javascript" src="/myfritz/areas/]], box.tohtml(idx), [[.js"></script>
]])
end
end
end
box.out([[
<script type="text/javascript">
var headlines = {};
]])
if gl.areas then
for idx, area in pairs(gl.areas) do
if area.show then
box.out("headlines['", box.tojs(idx), "Area'] = '", box.tojs(area.label), "';")
end
end
end
box.out([[
var gSid = "]], box.tojs(box.glob.sid), [[";
var gApp = ]], tostring(type(box.get.app) == "string"), [[;
var gAppMode = "]], box.tojs(tostring(box.get.app)), [[";
var gUserId = "]], box.tojs(tostring(gl.userid)), [[";
]])
box.out([[
var gPageContentDiv = null;
var gAreas = null;
var gAreasIdx = null;
var gOpenAreaIdx = null;
var gAreaHeadIdx = 0;
var gAreaContentIdx = 1;
var gAreaFootIdx = 2;
]])
box.out([[
var gEmInPx = 18;
var gScreenWidth = 0;
var gScreenHeight = 0;
var gSmallScreen = false;
var gMediumScreen = false;
var gBigScreen = false;
var gScrollLoadDelta = 600;
var gScrollFactor = 10000000;
var gIosDevices = { 'iPad':true, 'iPhone':true, 'iPod':true };
var gIosHttps = ( ("https:" == window.location.protocol || "https:" == document.location.protocol) && gIosDevices[navigator.platform] );
var gDataRefreshTimer = null;
]])
box.out([[
function logoutLocal()
{
do {
document.body.removeChild(jxl.get("page_content"));
}while(jxl.get("page_content"));
return true;
}
]])
box.out([[
function setScreenSize()
{
if(typeof(window.innerWidth) == 'number')
{
gScreenWidth = window.innerWidth;
}
else if(document.documentElement && document.documentElement.clientWidth)
{
gScreenWidth = document.documentElement.clientWidth;
}
else if(document.body && document.body.clientWidth)
{
gScreenWidth = document.body.clientWidth;
}
if(typeof(window.innerHeight) == 'number')
{
gScreenHeight = window.innerHeight;
}
else if(document.documentElement && document.documentElement.clientHeight)
{
gScreenHeight = document.documentElement.clientHeight;
}
else if(document.body && document.body.clientHeight)
{
gScreenHeight = document.body.clientHeight;
}
gSmallScreen = gScreenWidth < 760;
gMediumScreen = gScreenWidth >= 760 && gScreenWidth < 1025;
gBigScreen = gScreenWidth >= 1025;
}
]])
box.out([[
function getEmInPx()
{
var div = document.createElement("div");
div.style.width = "1em";
gPageContentDiv.appendChild(div);
gEmInPx = div.offsetWidth;
gPageContentDiv.removeChild(div);
}
]])
box.out([[
function convertWebAppLinks()
{
var webAppLinks = [ "myfritzLink","plainLogoutLink","ssoChangeEmailLink","ssoChangePasswordLink","ssoLogoutLink" ];
for(var i=0; i < webAppLinks.length; i++)
{
var a = jxl.get(webAppLinks[i]);
if (a && "object" == typeof a)
{
a.onclick=function()
{
window.location = this.getAttribute("href");
return false
};
}
}
}
]])
box.out([[
function init()
{
convertWebAppLinks();
setScreenSize();
gPageContentDiv = jxl.get("page_content");
gAreas = jxl.getByClass("area_box", gPageContentDiv, "div");
if (!gAreas) gAreas = [];
gOpenAreaIdx = null;
getEmInPx();
gScrollLoadDelta = 33 * gEmInPx;
gAreasIdx = {};
for (var i = 0; i < gAreas.length; i++)
{
gAreasIdx[gAreas[i].id] = i;
gAreas[i].lastScrollPos = 0;
gAreas[i].headline = headlines[gAreas[i].id];
if (gAreas[i].children[gAreaContentIdx])
{
gAreas[i].children[gAreaContentIdx].innerHTML = "";
if (!jxl.hasClass(gAreas[i].children[gAreaContentIdx], "wait_state")) jxl.addClass(gAreas[i].children[gAreaContentIdx], "wait_state");
}
}
]])
if gl.areas then
for idx, area in pairs(gl.areas) do
if area.show then
box.out(box.tojs(area.jsObjName), [[.init();]])
end
end
end
box.out([[
responsive.init();
gDataRefreshTimer = setInterval(checkAreaDataRefresh, 1000);
}
ready.onReady(init);
</script>
]])
end
?>
</body>
</html>
