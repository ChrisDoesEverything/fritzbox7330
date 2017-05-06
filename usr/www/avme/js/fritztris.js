function FRITZtris(anch) {
var that = this;
this.field = [];
this.preview = [];
this.pieces = [
{ className: "dect", p: [
[ {x:1,y:0}, {x:0,y:1}, {x:-1,y:0} ],
[ {x:0,y:-1}, {x:1,y:0}, {x:0,y:1} ],
[ {x:-1,y:0}, {x:0,y:-1}, {x:1,y:0} ],
[ {x:0,y:1}, {x:-1,y:0}, {x:0,y:-1} ]
] },
{ className: "lock", p: [
[ {x:1,y:0}, {x:1,y:1}, {x:0,y: 1} ]
] },
{ className: "out", p: [
[ {x:-1,y:0}, {x:0,y:1}, {x:1,y:1} ],
[ {x:0,y:-1}, {x:-1,y:0}, {x:-1,y:1} ]
] },
{ className: "in", p: [
[ {x:1,y:0}, {x:0,y:1}, {x:-1,y:1} ],
[ {x:0,y:-1}, {x:1,y:0}, {x:1,y:1} ]
] },
{ className: "failed", p: [
[ {x:1,y:0}, {x:-1,y:0}, {x:-2,y:0} ],
[ {x:0,y:1}, {x:0,y:-1}, {x:0,y:-2} ]
] },
{ className: "lan", p: [
[ {x:1,y:0}, {x:-1,y:0}, {x:-1,y:1} ],
[ {x:0,y:-1}, {x:0,y:1}, {x:1,y:1} ],
[ {x:-1,y:0}, {x:1,y:0}, {x:1,y:-1} ],
[ {x:0,y:1}, {x:0,y:-1}, {x:-1,y:-1} ]
] },
{ className: "wifi", p: [
[ {x:1,y:0}, {x:1,y:1}, {x:-1,y:0} ],
[ {x:0,y:-1}, {x:1,y:-1}, {x:0,y:1} ],
[ {x:-1,y:0}, {x:-1,y:-1}, {x:1,y:0} ],
[ {x:0,y:1}, {x:-1,y:1}, {x:0,y:-1} ]
] }
];
this.idx = 0;
this.pos = { x: 5, y: 0};
this.rot = 0;
this.nextIdx = 0;
this.nextRot = 0;
this.delay = [ 1000, 700, 600, 500, 400, 300, 250, 200, 150 ];
this.level = 1;
this.gmax = false;
this.lines = 0;
this.levelspan = null;
this.linespan = null;
this.pause = null;
this.gameOverCb = null;
function drawPiece(table, pos, piece, rot, show) {
var i;
if (pos.y >= 0) {
table[pos.y][pos.x].className = show ? piece.className : "";
}
for (i=0; i<3; i++) {
if (pos.y + piece.p[rot][i].y >= 0) {
table[pos.y + piece.p[rot][i].y][pos.x + piece.p[rot][i].x].className = show ? piece.className : "";
}
}
}
function nextPiece() {
that.idx = that.nextIdx;
that.rot = that.nextRot;
that.pos = {x:5, y:-1};
drawPiece(that.preview, { x:3,y:3 }, that.pieces[that.nextIdx], that.nextRot, false);
that.nextIdx = Math.floor(Math.random() * 7);
that.nextRot = Math.floor(Math.random() * that.pieces[that.nextIdx].p.length);
drawPiece(that.preview, { x:3,y:3 }, that.pieces[that.nextIdx], that.nextRot, true);
}
function petryfi() {
var piece = that.pieces[that.idx],
ret = true,
levelchange = false;
if (that.pos.y >= 0) {
that.field[that.pos.y][that.pos.x].className += " stoned";
} else {
ret = false;
}
for (i=0; i<3; i++) {
if (that.pos.y + piece.p[that.rot][i].y >= 0 && ret) {
that.field[that.pos.y + piece.p[that.rot][i].y][that.pos.x + piece.p[that.rot][i].x].className += " stoned";
} else {
ret = false;
}
}
for (j=19; j>=0; j--) {
do {
pling = false;
for (i=0; i<10; i++) {
if (that.field[j][i].className.indexOf("stoned") === -1)
break;
}
if (i==10) {
for (jj=j; jj>0; jj--) {
for (ii=0; ii<10; ii++) {
that.field[jj][ii].className = jj > 0 ? that.field[jj-1][ii].className : "";
}
}
pling = true;
that.lines++;
that.linespan.innerHTML = that.lines;
if (that.lines % 10 == 0 && that.level < that.delay.length - 1) {
that.level++;
that.levelspan.innerHTML = that.level;
levelchange = true;
}
}
} while(pling);
}
if (that.gmax || levelchange) {
window.clearInterval(that.handle);
that.handle = setInterval(that.geforce, that.delay[that.level]);
that.gmax = false;
}
return ret;
}
function checkField(pos) {
return pos.x >= 0 && pos.x < 10 && pos.y < 20 && (pos.y < 0 || that.field[pos.y][pos.x].className.indexOf("stoned") === -1 );
}
function tryMove(newPos, newRot) {
var piece = that.pieces[that.idx];
if (!checkField(newPos)) return false;
for (i=0; i<3; i++) {
if (!checkField({x:newPos.x + piece.p[newRot][i].x, y:newPos.y + piece.p[newRot][i].y})) return false;
}
drawPiece(that.field, that.pos, that.pieces[that.idx], that.rot, false);
that.pos = newPos;
that.rot = newRot;
drawPiece(that.field, that.pos, that.pieces[that.idx], that.rot, true);
return true;
}
function onKeyDown(ev) {
switch (ev.keyCode) {
case 27:
if (that.handle) {
window.clearInterval(that.handle);
that.handle = null;
that.pause.style.display = "block";
} else {
that.handle = setInterval(that.geforce, that.delay[that.level]);
that.pause.style.display = "none";
}
break;
case 37:
tryMove({x:that.pos.x-1,y:that.pos.y}, that.rot);
if (ev.preventDefault) ev.preventDefault();
break;
case 38:
tryMove(that.pos, (that.rot + 1) % that.pieces[that.idx].p.length);
if (ev.preventDefault) ev.preventDefault();
break;
case 39:
tryMove({x:that.pos.x+1,y:that.pos.y}, that.rot);
if (ev.preventDefault) ev.preventDefault();
break;
case 40:
tryMove({x:that.pos.x,y:that.pos.y+1}, that.rot);
if (ev.preventDefault) ev.preventDefault();
break;
case 32:
window.clearInterval(that.handle);
if (that.gmax) {
that.handle = setInterval(that.geforce, that.delay[that.level]);
that.gmax = false;
} else {
that.handle = setInterval(that.geforce, 1);
that.gmax = true;
}
if (ev.preventDefault) ev.preventDefault();
break;
}
}
function create(anch) {
var t,
r,
c,
ri,
ci;
anch.innerHTML = "";
t = document.createElement('table');
t.id = "field";
for (ri = 0; ri < 20; ri++) {
r = document.createElement('tr');
that.field[ri] = [];
for (ci = 0; ci < 10; ci++) {
c = document.createElement('td');
that.field[ri][ci] = c;
r.appendChild(c);
}
t.appendChild(r);
}
anch.appendChild(t);
t = document.createElement('table');
t.id = "preview";
for (ri = 0; ri < 6; ri++) {
r = document.createElement('tr');
that.preview[ri] = [];
for (ci = 0; ci < 6; ci++) {
c = document.createElement('td');
that.preview[ri][ci] = c;
r.appendChild(c);
}
t.appendChild(r);
}
anch.appendChild(t);
nextPiece();
t = document.createElement('p');
t.appendChild(document.createTextNode("Zeilen: "));
that.linespan = document.createElement('span');
that.linespan.innerHTML = that.lines;
t.appendChild(that.linespan);
t.appendChild(document.createTextNode(" - Level: "));
that.levelspan = document.createElement('span');
that.levelspan.innerHTML = that.level;
t.appendChild(that.levelspan);
anch.appendChild(t);
that.pause = document.createElement('p');
that.pause.id = "pause";
that.pause.innerHTML = "Pause";
anch.appendChild(that.pause);
window.addEventListener('keydown', onKeyDown, false);
}
this.geforce = function() {
if (!tryMove({x:that.pos.x, y:that.pos.y+1}, that.rot)) {
if (!petryfi()) {
window.clearInterval(that.handle);
if (that.gameOverCb && typeof that.gameOverCb == "function") {
that.gameOverCb();
} else {
alert("Das Spiel ist vorbei.");
}
}
nextPiece();
}
};
this.start = function() {
nextPiece();
this.handle = setInterval(this.geforce, that.delay[that.level]);
};
this.stop = function() {
window.clearInterval(this.handle);
this.handle = null;
this.field = null;
this.preview = null;
window.removeEventListener('keydown', onKeyDown, false);
}
create(anch);
}
var preload = [ ];
for (i = 0; i < 7; i++) {
preload[i] = new Image();
}
preload[0].src = "/css/default/images/icon_device.gif";
preload[1].src = "/css/default/images/icon_abmelden.gif";
preload[2].src = "/css/default/images/callout.gif";
preload[3].src = "/css/default/images/callin.gif";
preload[4].src = "/css/default/images/callinfailed.gif";
preload[5].src = "/css/default/images/clients_lan.png";
preload[6].src = "/css/default/images/clients_wlan05.png";
