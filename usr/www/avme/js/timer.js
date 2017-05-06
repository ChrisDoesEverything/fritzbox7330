/************************************************************************************************/
var g_daystr = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"];
var g_dayIDs = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
/************************************************************************************************/
function Moment(_d,_h,_m) {
this.d = _d;
this.h = _h;
this.m = _m;
this.isEqualTo = function(other) {
return (this.d==other.d && this.h==other.h && this.m==other.m);
};
this.isSmallerThan = function(other) {
return (this.d < other.d || (this.d == other.d && ( this.h < other.h || (this.h==other.h && this.m < other.m))));
};
this.isSmallerThanNoDay = function(other) {
return ( this.h < other.h || (this.h==other.h && this.m < other.m));
};
this.isSmallerOrEqualTo = function(other) {
return (this.d < other.d || (this.d == other.d && ( this.h < other.h || (this.h==other.h && this.m <= other.m))));
};
this.isGreaterThan = function(other) {
return (this.d > other.d || (this.d == other.d && ( this.h > other.h || (this.h==other.h && this.m > other.m))));
};
this.isGreaterThanNoDay = function(other) {
return ( this.h > other.h || (this.h==other.h && this.m > other.m));
};
this.isGreaterOrEqualTo = function(other) {
return (this.d > other.d || (this.d == other.d && ( this.h > other.h || (this.h==other.h && this.m >= other.m))));
};
this.toString = function() {
return "" + g_daystr[this.d] + " " + (this.h < 10 ? "0" : "") + this.h + ":" + (this.m < 10 ? "0" : "") + this.m;
};
this.toShortString = function() {
return "" + (this.h < 10 ? "0" : "") + this.h + ":" + (this.m < 10 ? "0" : "") + this.m;
};
this.toTimeStr = function() {
return "" + (this.h < 10 ? "0" : "") + this.h + (this.m < 10 ? "0" : "") + this.m;
};
this.nextQuarter = function() {
var ret = new Moment(this.d, this.h, this.m + 15);
if (ret.m > 45) {
ret.h++;
ret.m = 0;
}
if (ret.h >= 24) {
ret.h = 24;
ret.m = 0;
}
return ret;
};
this.prevQuarter = function() {
var ret = new Moment(this.d, this.h, this.m - 15);
if (ret.m < 0) {
ret.h--;
ret.m = 45;
}
if (ret.h < 0) {
ret.h = 0;
ret.m = 0;
}
return ret;
};
this.copy = function() {
return new Moment(this.d, this.h, this.m);
};
this.switchWith = function(other) {
var tmp = this.d; this.d = other.d; other.d = tmp;
tmp = this.h; this.h = other.h; other.h = tmp;
tmp = this.m; this.m = other.m; other.m = tmp;
};
}
/************************************************************************************************/
function Period(_start, _end) {
this.start = _start;
if (_end == null) {
this.end = _start.nextQuarter();
} else {
this.end = _end;
}
this.normalizedCopy = function() {
if (this.start.isGreaterThan(this.end)) {
return new Period(this.end, this.start);
}
if (this.start.isEqualTo(this.end)) {
return new Period(this.start, this.start.nextQuarter());
}
return new Period(this.start, this.end);
};
this.draw = function(dayDiv, leftReserved) {
var span = document.createElement('span'),
left = 5 * (this.start.h*4 + this.start.m/15) - leftReserved,
width = 5 * (((this.end.h - this.start.h) * 4) + ((this.end.m - this.start.m) / 15));
span.style.marginLeft = left + "px";
span.style.width = width + "px";
if (this.start.m!=0 || this.start.h%2==1) {
span.className = "b" + String(this.start.h%2) + String(this.start.m);
}
dayDiv.appendChild(span);
return leftReserved + left + width;
};
this.toTimeStr = function() {
return this.start.toTimeStr() + this.end.toTimeStr();
};
}
/************************************************************************************************/
function Timer(_idContainer, _data)
{
var that = this;
this.idContainer = _idContainer;
this.divContainer = jxl.get(_idContainer);
this.msgBox = jxl.get( _idContainer + "MsgBox" );
this.divWeek = jxl.get(_idContainer + "Week");
this.divDay = [];
this.selecting = false;
this.curpos = null;
this.dragPeriod = null;
this.dragmode = null;
this.wrapped = false;
this.blockMode = "block";
this.data = _data;
this.disabled = false;
this.callback = null;
/**
Es wird ein Div mit der Klasse touchDiv erzeugt. Dies wird vor die eigentlichen elemente Gelegt, um touch zu realisieren
Das wird gemacht, da beim demarkieren bzw. löschen einer gesetzten Zeit genau das Element gelöscht wird an den das TouchEvent
gebunden ist. Da dies dazu führt, dass keine weitern TouchEvents ausgelöst werden, wird das touchDiv vor alles andere gelegt
und somit sichergestellt, dass das Element auf das ich touche auch immer da ist.
*/
this.touchDiv = document.createElement("div");
this.touchDiv.setAttribute('class', 'touchDiv');
this.divContainer.appendChild(this.touchDiv);
/**
Zur anzeige der Zeit und der Tage die ich gerade bearbeite werden weiter Elemente geschaffen.
*/
this.editTimeDiv = document.createElement("div");
this.editTimeDiv.setAttribute('class', 'editTime');
this.editDaysSpan = document.createElement("span");
this.editTimeDiv.appendChild(this.editDaysSpan);
this.editTimeSpan = document.createElement("span");
this.editTimeDiv.appendChild(this.editTimeSpan);
this.divContainer.appendChild(this.editTimeDiv);
/**
Hier kann man eine Callback-Funktion anmelden, die immer bei Mouseup
bzw. ESC, also wenn der User eine Aktion beendet, aufgerufen wird.
Nützlich z.B. wenn irgendwas ausgeblendet werden soll, sobald die
momentanen Daten "immer gepserrt" sagen ....
**/
this.setOnChangeCallback = function(cbFunc) {
this.callback = cbFunc;
};
/******* Handler für Ereignisse des Dokumentes *****************************/
/**
* wird als dokumentweiter onkeypress Handler installiert.
*
* ESC während des Ziehens bricht die Auswahl ab.
*/
this.handleKeyPressed = function(evt)
{
evt = evt || window.event;
var code = evt.which ? evt.which : evt.keyCode;
switch (code) {
case 27:
if ( this.selecting ) {
this.drawData();
document.onmouseup = null;
document.onmousemove = null;
document.onkeypress = null;
this.selecting = false;
if (this.callback) {
this.callback();
}
this.unvisualiseMoment(evt);
}
break;
}
};
/**
* wird als dokumentweiter onmouseup Handler installiert.
*/
this.handleMouseUp = function(evt)
{
evt = evt || window.event;
if (evt.stopPropagation) evt.stopPropagation();
if (evt.preventDefault) evt.preventDefault();
if ( this.selecting )
{
if ( !evt.targetTouches )
{
var pos = this.toTime(evt);
this.dragPeriod.end = pos;
}
else
{
//bei Toch getriggerten Mouseup muss vor dem Merge selecting auf false gesetzt werden um nicht eine Zeiteinheit zu viel
//zu markieren oder demarkieren.
this.selecting = false;
}
this.mergeDrag("drawsave", this.dragMode, this.blockMode);
this.unvisualiseMoment(evt);
document.onmouseup = null;
document.onmousemove = null;
document.onkeypress = null;
this.selecting = false;
emtyChart();
if ( this.callback )
{
this.callback();
}
}
};
/**
* wird als dokumentweiter onmousemove Handler installiert.
*/
this.handleMouseMove = function(evt)
{
evt = evt || window.event;
if (evt.stopPropagation) evt.stopPropagation();
if (evt.preventDefault) evt.preventDefault();
if ( this.selecting )
{
var pos = this.toTime(evt);
if ( !pos.isEqualTo( this.curpos ) )
{
this.curpos = pos;
this.dragPeriod.end = this.curpos;
this.mergeDrag("draw", this.dragMode, this.blockMode);
this.visualiseMoment(evt);
}
}
};
/**
* wird als onmousedown Handler in den Tages-<div>s installiert.
*/
this.handleMouseDown = function(evt) {
evt = evt || window.event;
if (evt.stopPropagation) evt.stopPropagation();
if (evt.preventDefault) evt.preventDefault();
if (evt.button != 2 && !this.disabled) {
jxl.addClass( this.msgBox, "hide" );
var that = this;
this.curpos = this.toTime(evt);
this.dragPeriod = new Period(this.curpos);
this.dragMode = evt.shiftKey ? "add" : this.getDragMode(this.curpos);
this.blockMode = evt.ctrlKey ? "fill" : "block";
this.mergeDrag("draw", this.dragMode, this.blockMode);
this.visualiseMoment(evt);
this.selecting = true;
document.onmouseup = function(ev) { return that.handleMouseUp.call(that, ev); };
document.onmousemove = function(ev) { return that.handleMouseMove.call(that, ev); };
document.onkeypress = function(ev) { return that.handleKeyPressed.call(that, ev); };
}
};
/******* Control Hilfsfunktionen *******************************************/
this.unvisualiseMoment = function(evt)
{
if ( jxl.hasClass(this.editTimeDiv, "show") )
{
jxl.removeClass(this.editTimeDiv, "show");
}
}
/**
*
*/
this.visualiseMoment = function(evt)
{
if ( this.dragPeriod.start.d == this.dragPeriod.end.d )
{
this.editDaysSpan.innerHTML = g_daystr[this.dragPeriod.start.d];
}
else if ( this.dragPeriod.start.d > this.dragPeriod.end.d )
{
this.editDaysSpan.innerHTML = g_daystr[this.dragPeriod.end.d] + " bis " + g_daystr[this.dragPeriod.start.d];
}
else
{
this.editDaysSpan.innerHTML = g_daystr[this.dragPeriod.start.d] + " bis " + g_daystr[this.dragPeriod.end.d];
}
if ( this.dragPeriod.start.isEqualTo(this.dragPeriod.end) )
{
this.dragPeriod.end = this.dragPeriod.end.nextQuarter();
}
var startTime = (this.dragPeriod.start.h < 10 ? "0" : "") + this.dragPeriod.start.h + ":" + (this.dragPeriod.start.m < 10 ? "0" : "") + this.dragPeriod.start.m;
var endTime = (this.dragPeriod.end.h < 10 ? "0" : "") + this.dragPeriod.end.h + ":" + (this.dragPeriod.end.m < 10 ? "0" : "") + this.dragPeriod.end.m;
if ( this.dragPeriod.start.h > this.dragPeriod.end.h || (this.dragPeriod.start.h == this.dragPeriod.end.h && this.dragPeriod.start.m > this.dragPeriod.end.m) )
{
startTime = (this.dragPeriod.end.h < 10 ? "0" : "") + this.dragPeriod.end.h + ":" + (this.dragPeriod.end.m < 10 ? "0" : "") + this.dragPeriod.end.m;
endTime = (this.dragPeriod.start.h < 10 ? "0" : "") + this.dragPeriod.start.h + ":" + (this.dragPeriod.start.m < 10 ? "0" : "") + this.dragPeriod.start.m;
}
this.editTimeSpan.innerHTML = startTime + " bis " + endTime;
if ( !jxl.hasClass(this.editTimeDiv, "show") )
{
jxl.addClass(this.editTimeDiv, "show");
}
};
/**
* berechnet aus einem (Maus-)Event den passenden Zeitpunkt
*/
this.toTime = function(evt) {
evt = evt || window.event;
var t = this.divWeek,
x = 0,
y = 0;
if (evt.targetTouches && evt.targetTouches[0] && evt.targetTouches[0].clientX)
{
x = evt.targetTouches[0].clientX+(window.pageXOffset || document.documentElement.scrollLeft || 0);
y = evt.targetTouches[0].clientY+(window.pageYOffset || document.documentElement.scrollTop || 0);
}
else
{
x = evt.clientX+(window.pageXOffset || document.documentElement.scrollLeft || 0);
y = evt.clientY+(window.pageYOffset || document.documentElement.scrollTop || 0);
}
do
{
x-=t.offsetLeft+parseInt(t.style.borderLeftWidth || 0);
y-=t.offsetTop+parseInt(t.style.borderTopWidth || 0);
} while (t=t.offsetParent);
var nx = x > 0 ? x : 0;
nx = Math.floor(nx / 5);
var m = 15 * (nx % 4);
var h = Math.floor(nx / 4);
if ( h >= 24 )
{
h=23;
m=45;
}
var ny = y < 3 ? 0 : y;
/**
35 gleich 28px höhe und 7px Margin bottom
*/
ny = Math.floor((ny - 3) / 35);
var d = ny < 6 ? ny : 6;
d = d < 0 ? 0 : d;
return new Moment(d, h, m);
};
/**
* ermittelt den Zustand des geklickten Bereiches und gibt die dazu inverse Operation zurück.
*/
this.getDragMode = function(pos)
{
for (var day=0; day<7; day++) {
if (pos.d==day) {
for (var p=0; this.data[day] && p < this.data[day].length; p++) {
if (pos.h >= 24 && pos.isGreaterOrEqualTo(this.data[day][p].end)) return "remove";
if (pos.isGreaterOrEqualTo(this.data[day][p].end)) continue;
if (pos.isSmallerThan(this.data[day][p].start)) return "add";
return "remove";
}
return "add";
}
}
};
/**
* arbeitet die aktuelle Auswahl in den Datenbestand ein.
*/
this.mergeDrag = function(mergeMode, dragMode, blockMode)
{
/**
Zuerst wird die dragPeriod angepasst je nach dem ob wir nach links rechts oder auf dem Punkt sind.
Aber nur wenn this.selecting == true ist.
*/
if ( this.selecting )
{
/**Wenn man schon links draged muss man den start für den Vergleich wieder zurücksetzen.
Nötig da man immer vom original Zustand ausgeht. Nicht nötig für dragPeriod.end da dieser ja immer
neu gesetzt und somit automatisch resettet wird. */
if ( this.dragPeriod.direction && this.dragPeriod.direction == "left" )
{
this.dragPeriod.start = this.dragPeriod.start.prevQuarter();
}
/** Bei den Vergeleichen wird der Tag missachtet. Das ist wichtig da der Vergleich sonst für mehrere Tage nicht funktionieren würde.*/
if ( this.dragPeriod.start.isGreaterThanNoDay(this.dragPeriod.end) )
{
/**
Wir draggen nach links
*/
this.dragPeriod.start = this.dragPeriod.start.nextQuarter();
this.dragPeriod.direction = "left";
}
else if ( this.dragPeriod.start.isSmallerThanNoDay(this.dragPeriod.end) )
{
/**
Wir draggen nach rechts
*/
this.dragPeriod.end = this.dragPeriod.end.nextQuarter();
this.dragPeriod.direction = "right";
}
else
{
if ( this.dragPeriod.start.d != this.dragPeriod.end.d )
{
this.dragPeriod.end = this.dragPeriod.end.nextQuarter();
}
this.dragPeriod.direction = null;
}
}
var dragp = this.dragPeriod.normalizedCopy();
if (!blockMode) blockMode = "fill";
var wrapped = (dragp.start.d != dragp.end.d);
for ( var day = 0; day < 7; day++ )
{
if ( day >= dragp.start.d && day <= dragp.end.d )
{
var newp = new Period( dragp.start.copy(), dragp.end.copy() );
newp.start.d = day;
newp.end.d = day;
if ( blockMode=="block" )
{
if ( newp.end.isSmallerThan(newp.start) )
{
newp.end.switchWith( newp.start );
}
}
else
{
if ( day != dragp.start.d )
{
newp.start = new Moment(day, 0, 0);
}
if ( day != dragp.end.d )
{
newp.end = new Moment(day, 24, 0);
}
}
var daydata = [];
if (dragMode=="add")
{
var newpcomplete = false;
for (var i=0; this.data[day] && i<this.data[day].length; i++)
{
if (this.data[day][i].start.isSmallerThan(newp.start) || newpcomplete)
{
daydata.push(this.data[day][i]);
continue;
}
daydata.push(new Period(newp.start, newp.end));
newpcomplete = true;
daydata.push(this.data[day][i]);
}
if (!newpcomplete)
{
daydata.push(new Period(newp.start, newp.end));
}
if (daydata.length > 1)
{
var daydata2 = [];
var startindex = 0;
var endindex = 0;
for (var i=1; i<daydata.length; i++)
{
if (daydata[i].start.isGreaterThan(daydata[startindex].end) && daydata[i].start.isGreaterThan(daydata[endindex].end))
{
daydata2.push(new Period(daydata[startindex].start, daydata[endindex].end));
startindex = i;
}
if (daydata[i].end.isGreaterThan(daydata[endindex].end))
{
endindex = i;
}
}
daydata2.push(new Period(daydata[startindex].start, daydata[endindex].end));
daydata = daydata2;
}
}
else if (dragMode=="remove")
{
for (var i = 0; this.data[day] && i < this.data[day].length; i++)
{
if ( this.data[day][i].end.isSmallerThan(newp.start) || this.data[day][i].start.isGreaterThan(newp.end) )
{
daydata.push(this.data[day][i]);
}
else if ( newp.start.isSmallerOrEqualTo(this.data[day][i].start) )
{
if ( newp.end.isSmallerThan(this.data[day][i].end) )
{
daydata.push(new Period(newp.end, this.data[day][i].end));
}
}
else
{
daydata.push( new Period(this.data[day][i].start, newp.start) );
if ( newp.end.isSmallerThan(this.data[day][i].end) )
{
daydata.push( new Period(newp.end, this.data[day][i].end) );
}
}
}
}
if (mergeMode.indexOf("draw")!=-1) {
drawDay(this.divDay[day], daydata);
}
if (mergeMode.indexOf("save")!=-1) {
this.data[day] = daydata;
}
} else if (this.wrapped && mergeMode.indexOf("draw")!=-1) {
drawDay(this.divDay[day], this.data[day]);
}
}
this.wrapped = wrapped;
};
/**
* leert ein Tages-<div>
*/
function clearDay(dayDiv)
{
while (dayDiv.firstChild) dayDiv.removeChild(dayDiv.firstChild);
}
/**
* malt die Bereiche eines Tages neu.
*/
function drawDay(dayDiv, data)
{
var leftGap = 0;
clearDay(dayDiv);
for (var p=0; data && p<data.length; p++) {
leftGap = data[p].draw(dayDiv, leftGap);
}
}
/**
* malt das gesamte Control neu
*/
this.drawData = function()
{
for (var day=0; day<7; day++) {
drawDay(this.divDay[day], this.data[day]);
}
};
/**
* fügt das Bit für den Tag zur Bitmaske hinzu
*/
function addDayToBitmap(mask, day) {
mask |= 1<<day;
return mask;
}
/**
* Vergleicht zwei Actions (Callback für die Javascript Array.sort() Funktion)
*/
function compareActions(a, b) {
if (a.time < b.time) return -1;
if (a.time > b.time) return 1;
return a.action - b.action;
}
/**
* Schaut ob irgendeine Zeit eingestellt wurde. Wenn leer wird ein Hinweis eingeblendet.
*/
function emtyChart()
{
for ( var i = 0; i < that.data.length; i++ )
{
if ( that.data[i] && 0 < that.data[i].length )
{
jxl.addClass( that.msgBox, "hide" );
return;
}
}
jxl.removeClass( that.msgBox, "hide" );
return;
}
/**
* speichert die Zeiten im angegebenen Formular
*/
this.save = function(formId)
{
var complete = false;
/* Schaltpunkte sortieren*/
var nextAction = [];
for (var day=0; day<7; day++) {
for (var p=0; this.data[day] && p<this.data[day].length; p++)
{
nextAction.push( { day: day, action: 1, time: this.data[day][p].start.toTimeStr() } );
nextAction.push( { day: day, action: 0, time: this.data[day][p].end.toTimeStr() } );
}
}
nextAction.sort(compareActions);
/* Tage zusammenfassen */
var actions = [];
for (var i=0; i<nextAction.length; i++) {
var item = { action: nextAction[i].action, days: addDayToBitmap(0, nextAction[i].day), time: nextAction[i].time };
var j = i+1;
while (j < nextAction.length && nextAction[j].time==nextAction[i].time && nextAction[j].action==nextAction[i].action) {
item.days = addDayToBitmap(item.days, nextAction[j].day);
i = j;
j++;
}
actions.push(item);
}
if (actions.length > 1) {
/* unnötige Mitternachtsschaltzeiten entfernen */
if (actions[0].time=="0000" && actions[actions.length-1].time=="2400") {
for (var d=0; d<7; d++) {
if ((actions[actions.length-1].days & 1<<d) && (actions[0].days & 1<<((d+1)%7)) ) {
actions[actions.length-1].days ^= 1<<d;
actions[0].days ^= 1<<((d+1)%7);
}
}
if (actions.length == 2) {
complete = true;
}
if (actions[actions.length-1].days == 0) actions.pop();
if (actions[0].days == 0) actions.shift();
if (complete && actions.length != 0) {
complete = false;
}
}
}
/* Wenn keine formId, dann soll nur die Info berechnet werden */
if (formId) {
/* Schaltpunkte ins Formular schreiben */
var form = jxl.get(formId);
if (actions.length > 0) {
for (var a=0; form && a < actions.length; a++) {
var inp = document.createElement("input");
inp.type = "hidden";
inp.name = "timer_item_"+a;
inp.value = actions[a].time + ";" + actions[a].action + ";" + actions[a].days;
form.appendChild(inp);
}
}
else {
var inp = document.createElement("input");
inp.type = "hidden";
inp.name = "timer_complete";
inp.value = (complete ? "1" : "0");
form.appendChild(inp);
}
}
/**
return, ob das Ergebnis "alles gesperrt" lautet,
so kann im OnSubmit evtll. darauf reagiert werden.
*/
return (actions.length == 0 && !complete);
};
this.ha_save = function(formId)
{
var complete = false;
/* Schaltpunkte erstellen*/
var nextAction = [];
for (var day=0; day<7; day++) {
for (var p=0; this.data[day] && p<this.data[day].length; p++)
{
nextAction.push( { day: day, action: 1, time: this.data[day][p].start.toTimeStr() } );
nextAction.push( { day: day, action: 0, time: this.data[day][p].end.toTimeStr() } );
}
}
if ( nextAction.length < 1 ) {
return -1; // gibt keine AN-Schaltpunkte
}
/* Schaltpunkte zählen */
var nSwitchPoint = 1;
var curAction = nextAction[0].action;
for (var i=1; i<nextAction.length; i++) {
if ( curAction != nextAction[i].action) {
if ( nextAction[i].time != "2400") {
nSwitchPoint++;
curAction = nextAction[i].action;
} else {
if ( (i+1) == nextAction.length) {
if ( nextAction[0].time == "0000") {
if ( (nextAction[i].day - nextAction[0].day) != 6) {
nSwitchPoint++;
curAction = nextAction[i].action;
}
} else {
nSwitchPoint++;
curAction = nextAction[i].action;
}
} else {
if ( nextAction[(i+1)].time == "0000") {
if ( (nextAction[(i+1)].day - nextAction[i].day) != 1) {
nSwitchPoint++;
curAction = nextAction[i].action;
}
} else {
nSwitchPoint++;
curAction = nextAction[i].action;
}
}
}
}
}
if (( nSwitchPoint > 1) && ((nextAction[(nextAction.length-1)].day - nextAction[0].day) == 6) &&
( nextAction[0].time == "0000") && (nextAction[(nextAction.length-1)].time == "2400")) {
nSwitchPoint--;
}
if ( (nSwitchPoint == 1) || (nSwitchPoint > 100) ) {
return nSwitchPoint; // wenn 1, wenn komplett AN
} // wenn größer 40, zu viele Schaltpunkte
nextAction.sort(compareActions);
/* Tage zusammenfassen */
var actions = [];
for (var i=0; i<nextAction.length; i++) {
var item = { action: nextAction[i].action, days: addDayToBitmap(0, nextAction[i].day), time: nextAction[i].time };
var j = i+1;
while (j < nextAction.length && nextAction[j].time==nextAction[i].time && nextAction[j].action==nextAction[i].action) {
item.days = addDayToBitmap(item.days, nextAction[j].day);
i = j;
j++;
}
actions.push(item);
}
if (actions.length > 1) {
/* unnötige Mitternachtsschaltzeiten entfernen */
if (actions[0].time=="0000" && actions[actions.length-1].time=="2400") {
for (var d=0; d<7; d++) {
if ((actions[actions.length-1].days & 1<<d) && (actions[0].days & 1<<((d+1)%7)) ) {
actions[actions.length-1].days ^= 1<<d;
actions[0].days ^= 1<<((d+1)%7);
}
}
if (actions.length == 2) {
complete = true;
}
if (actions[actions.length-1].days == 0) actions.pop();
if (actions[0].days == 0) actions.shift();
if (complete && actions.length != 0) {
complete = false;
}
}
}
/* Wenn keine formId, dann soll nur die Info berechnet werden */
if (formId) {
/* Schaltpunkte ins Formular schreiben */
var form = jxl.get(formId);
if (actions.length > 0) {
for (var a=0; form && a < actions.length; a++) {
var inp = document.createElement("input");
inp.type = "hidden";
inp.name = "timer_item_"+a;
inp.value = actions[a].time + ";" + actions[a].action + ";" + actions[a].days;
form.appendChild(inp);
}
}
else {
var inp = document.createElement("input");
inp.type = "hidden";
inp.name = "timer_complete";
inp.value = (complete ? "1" : "0");
form.appendChild(inp);
}
}
/**
return, ob das Ergebnis "alles gesperrt" lautet,
so kann im OnSubmit evtll. darauf reagiert werden.
*/
return nSwitchPoint;
};
/**
* Initialisierung
*/
this.touchStartEv = function(evt)
{
evt = evt || window.event;
if (evt.stopPropagation) evt.stopPropagation();
if (evt.preventDefault) evt.preventDefault();
var that = this;
jxl.addEventHandler( evt.target, "touchmove", function(inevt) {
inevt = inevt || window.event;
if (inevt.stopPropagation) inevt.stopPropagation();
if (inevt.preventDefault) inevt.preventDefault();
that.handleMouseMove.call(that, inevt);
} );
jxl.addEventHandler( evt.target, "touchend", function(inevt) {
inevt = inevt || window.event;
if (inevt.stopPropagation) inevt.stopPropagation();
if (inevt.preventDefault) inevt.preventDefault();
emtyChart();
that.handleMouseUp.call(that, inevt);
} );
jxl.addEventHandler( evt.target, "touchcancel", function(inevt) {
inevt = inevt || window.event;
if (inevt.stopPropagation) inevt.stopPropagation();
if (inevt.preventDefault) inevt.preventDefault();
emtyChart();
that.handleMouseUp.call(that, inevt);
} );
this.handleMouseDown(evt);
};
jxl.addEventHandler( this.touchDiv, "touchstart", function(evt) {
jxl.addClass( that.msgBox, "hide" );
that.touchStartEv.call(that, evt);
} );
this.touchDiv.onmousedown = function(evt) { return that.handleMouseDown.call(that, evt); }
this.touchDiv.onselectstart = function() { return false; };
for (var i=0; i<7; i++) {
this.divDay[i] = jxl.get(this.idContainer + g_dayIDs[i]);
/** für alte IE, welche das touchDIV nicht richtig erzeugen können, muss leider die alte Art der Handler mit angelegt werden. */
this.divDay[i].onmousedown = function(evt) { return that.handleMouseDown.call(that, evt); }
this.divDay[i].onselectstart = function() { return false; };
}
emtyChart();
this.drawData();
}
