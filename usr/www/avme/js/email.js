var email = email || (function() {
var lib = {};
var global = this;
var doc = global.document;
lib.guessFromPppUser = function(username) {
/* AOL */
if (username.indexOf("@de.aol.com")>=0) {
var name = username.substr(0, username.indexOf("@de.aol.com"));
return name + "@aol.com";
}
/* T-Online */
if (username.indexOf("@t-online.de")>=0) {
var n1 = username.indexOf("#");
var n2 = username.indexOf("#", n1+1);
var n3 = username.indexOf("@t-online.de");
var nummer;
var suffix;
if (n1 != -1 && n2 !=-1 && n3 != -1) {
nummer = username.substring(n1+1, n2);
suffix = username.substring(n2+1, n3);
} else if (n3 != -1) {
var nummern = username.substring(0, n3);
if (n1 == -1) {
nummer = username.substring(12, 24);
suffix = username.substring(24, n3);
} else {
nummer = nummern.substring(12, n1);
suffix= nummern.substring(n1+1, n3);
}
}
return nummer + "-" + suffix + "@t-online.de";
}
/* 1&1 */
if (username.indexOf("@online.de")>=0) {
var name = username.substr(0, username.indexOf("@online.de"));
if (name.substring(0, 6) == "1und1/") {
return name.slice(6)+"@online.de";
}
}
return "";
};
function addr(mailaddr) {
return mailaddr;
}
function local(mailaddr) {
return mailaddr.substring(0, mailaddr.indexOf('@'));
}
lib.prov = {
"1und1": { name: "1&1 DSL", pattern: /@online(home)?\.de|@sofort-?start\.de|@sofort-?surf\.de|@go4more\.de/i,
pop3: "pop.1und1.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "smtp.1und1.de", smtpuser: addr, smtpssl: true },
"aolcom": { name: "AOL", pattern: /@aol\.com/i,
pop3: "pop.aol.com", pop3user: local, pop3ssl: false, poll: 10,
smtp: "smtp.de.aol.com:587", smtpuser: local, smtpssl: true },
"aolde": { name: "AOL", pattern: /@aol\.de|@aim.com/i,
pop3: "pop.aim.com", pop3user: local, pop3ssl: false, poll: 10,
smtp: "smtp.aim.com:587", smtpuser: local, smtpssl: true },
"arcor": { name: "Arcor", pattern: /@arcor\.de|@germanynet\.de/i,
pop3: "pop3.arcor.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "mail.arcor.de", smtpuser: addr, smtpssl: true },
"berlin": { name: "Berlin.de", pattern: /@(.*\.)?berlin\.de/i,
pop3: "pop3.berlin.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "mail.berlin.de", smtpuser: addr, smtpssl: true },
"congstar": { name: "congstar", pattern: /@congst(a|e)r\.de/i,
pop3: "popmail.congstar.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "smtpmail.congstar.de", smtpuser: addr, smtpssl: false },
"debitel": { name: "debitel", pattern: /@debitel\.net/i,
pop3: "pop3.pop.debitel.net", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "smtp.pop.debitel.net", smtpuser: addr, smtpssl: false },
"eplus": { name: "E-Plus", pattern: /@eplus\.de/i,
pop3: "mail.eplus-online.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "mail.eplus-online.de", smtpuser: addr, smtpssl: false },
"freenet": { name: "Freenet", pattern: /@freenet\.de/i,
pop3: "mx.freenet.de", pop3user: addr, pop3ssl: false, poll: 17,
smtp: "mx.freenet.de", smtpuser: addr, smtpssl: true },
"gmx": { name: "GMX", pattern: /@gmx\.[^\.]*$/i,
pop3: "pop.gmx.net", pop3user: addr, pop3ssl: false, poll: 17,
smtp: "mail.gmx.net", smtpuser: addr, smtpssl: true },
"google": { name: "Google", pattern: /@g(oogle)?mail\.com/i,
pop3: "pop.googlemail.com:995", pop3user: addr, pop3ssl: true, poll: 10,
smtp: "smtp.googlemail.com:465", smtpuser: addr, smtpssl: true },
"hansenet": { name: "Hansenet", pattern: /@hansenet\.de/i,
pop3: "pop3.hansenet.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "smtp.hansenet.de", smtpuser: addr, smtpssl: true },
"hanse.net": { name: "Hansenet", pattern: /@hanse\.net/i,
pop3: "webmail.hansenet.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "webmail.hansenet.de", smtpuser: addr, smtpssl: true },
"alice.dsl": { name: "Hansenet", pattern: /@alice-dsl\.de/i,
pop3: "mail.alice-dsl.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "mail.alice-dsl.de", smtpuser: addr, smtpssl: true },
"alice.net": { name: "Hansenet", pattern: /@alice-dsl\.net/i,
pop3: "pop3.alice-dsl.net", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "smtp.alice-dsl.net", smtpuser: addr, smtpssl: true },
"alice.de": { name: "Hansenet", pattern: /@alice\.de/i,
pop3: "pop3.alice.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "smtp.alice.de", smtpuser: addr, smtpssl: true },
"hotmail": { name: "Hotmail", pattern: /@live\.com/i,
pop3: "pop3.live.com:995", pop3user: addr, pop3ssl: true, poll: 10,
smtp: "smtp.live.com", smtpuser: addr, smtpssl: true },
/* "lycos": { name: "Lycos", pattern: /@lycos\.[^\.]*$/i,
pop3: "pop.lycos.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "smtp.lycos.de", smtpuser: addr, smtpssl: false },*/
"netcologne": { name: "NetCologne", pattern: /@netcologne\.de/i,
pop3: "pop3.netcologne.de", pop3user: local, pop3ssl: false, poll: 10,
smtp: "smtp.netcologne.de", smtpuser: local, smtpssl: false },
"o2": { name: "O2", pattern: /@o2online\.de/i,
pop3: "pop.o2online.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "mail.o2online.de", smtpuser: addr, smtpssl: true },
"genion": { name: "O2", pattern: /@genion\.de/i,
pop3: "pop.genion.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "mail.genion.de", smtpuser: addr, smtpssl: true },
"loop": { name: "O2", pattern: /@loop\.de/i,
pop3: "pop.loop.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "mail.loop.de", smtpuser: addr, smtpssl: true },
"rtl": { name: "RTL", pattern: /@rtl(world|net)\.de/i,
pop3: "POP3.rtl.um.mediaways.net", pop3user: local, pop3ssl: false, poll: 10,
smtp: "smtp.rtl.um.mediaways.net", smtpuser: local, smtpssl: false },
"snafu": { name: "snafu", pattern: /@snafu\.de/i,
pop3: "pop.snafu.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "mail.snafu.de", smtpuser: addr, smtpssl: true },
"tonline": { name: "T-Online", pattern: /@t-online\.de/i,
pop3: "popmail.t-online.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "smtpmail.t-online.de", smtpuser: addr, smtpssl: false },
"versatel": { name: "Versatel", pattern: /@versanet\.de/i,
pop3: "pop3.versatel.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "smtp.versatel.de", smtpuser: addr, smtpssl: false },
"vodafone": { name: "Vodafone", pattern: /@(vodafone|d2mail)\.de/i,
pop3: "pop.email.vodafone.de", pop3user: addr, pop3ssl: false, poll: 10,
smtp: "smtp.email.vodafone.de", smtpuser: addr, smtpssl: true },
"web": { name: "WEB.DE", pattern: /@(web|email)\.de/i,
pop3: "pop3.web.de", pop3user: local, pop3ssl: false, poll: 17,
smtp: "smtp.web.de", smtpuser: local, smtpssl: true },
"yahoo": { name: "Yahoo", pattern: /@yahoo\.[^\.]*$/i,
pop3: "pop.mail.yahoo.de", pop3user: local, pop3ssl: false, poll: 17,
smtp: "smtp.mail.yahoo.de", smtpuser: local, smtpssl: false }
};
lib.getProvider = function(addr) {
for (var p in lib.prov) {
if (addr.search(lib.prov[p].pattern)>=0)
{
return p;
}
}
return null;
};
return lib;
})();
