var touch = touch || (function() {
"use strict";
var lib = {};
var gTouchElem = new Object();
document.addEventListener('touchstart', touchStart, true);
document.addEventListener('touchmove', touchMove, true);
document.addEventListener('touchend', touchEnd, true);
document.addEventListener('touchcancel', touchCancel, true);
document.addEventListener('touchleave', touchLeave, true);
function getRegisteredForTouch(evt)
{
if (evt != null && evt.targetTouches[0] != null && evt.targetTouches[0].target != null)
{
var target = evt.targetTouches[0].target;
var maxParents = 10;
while (target != null && typeof(target.id) == "string" && gTouchElem[target.id] == null && maxParents > 0) {
target = target.parentElement;
maxParents -= 1;
}
if (target != null && typeof(target.id) == "string" && gTouchElem[target.id] != null) return target.id;
}
return null;
};
function setTouchDefaults(touchElem)
{
touchElem.startX = -1;
touchElem.startY = -1;
touchElem.lastX = -1;
touchElem.lastY = -1;
touchElem.startDirection = "";
touchElem.direction = "";
touchElem.verticalScrollActiv = false;
touchElem.horizontalScrollActiv = false;
//um eine Aktion nach zu sperren
touchElem.allowed = true;
};
lib.registerElemForTouch = function(elemId, gesture, cbFunction)
{
if (gTouchElem[elemId] == null) gTouchElem[elemId] = new Object();
gTouchElem[elemId][gesture] = new Object();
gTouchElem[elemId][gesture].elemId = elemId;
gTouchElem[elemId][gesture].gesture = gesture;
gTouchElem[elemId][gesture].cbFunction = cbFunction;
setTouchDefaults(gTouchElem[elemId][gesture]);
};
function touchSideMove(evt, id)
{
if (id && gTouchElem[id]["side"] && gTouchElem[id]["side"].cbFunction)
{
if (evt.preventDefault) evt.preventDefault();
var deltaX = gTouchElem[id]["side"].lastX - evt.targetTouches[0].screenX;
if (gTouchElem[id]["side"].lastX > -1 && deltaX <= 0)
{
if (gTouchElem[id]["side"].startDirection == "") gTouchElem[id]["side"].startDirection = "right";
gTouchElem[id]["side"].direction = "right";
}
else if(gTouchElem[id]["side"].lastX > -1 && deltaX > 0)
{
if (gTouchElem[id]["side"].startDirection == "") gTouchElem[id]["side"].startDirection = "left";
gTouchElem[id]["side"].direction = "left";
}
gTouchElem[id]["side"].cbFunction(evt,id,gTouchElem[id]["side"]);
}
};
function touchUpDownMove(evt, id)
{
if (id && gTouchElem[id]["updown"] && gTouchElem[id]["updown"].cbFunction)
{
if (evt.preventDefault) evt.preventDefault();
var deltaY = gTouchElem[id]["updown"].lastY - evt.targetTouches[0].screenY;
if (gTouchElem[id]["updown"].lastY > -1 && deltaY <= 0)
{
if (gTouchElem[id]["updown"].startDirection == "") gTouchElem[id]["updown"].startDirection = "down";
gTouchElem[id]["updown"].direction = "down";
}
else if(gTouchElem[id]["updown"].lastY > -1 && deltaY > 0)
{
if (gTouchElem[id]["updown"].startDirection == "") gTouchElem[id]["updown"].startDirection = "up";
gTouchElem[id]["updown"].direction = "up";
}
gTouchElem[id]["updown"].cbFunction(evt,id,gTouchElem[id]["updown"]);
}
};
function touchMove(evt)
{
var id = getRegisteredForTouch(evt);
if (id)
{
var preventDefaultDelta = 12;
var preventDefaultDivi = 30;
if (screen.width < screen.height)
preventDefaultDelta = screen.width / preventDefaultDivi;
else
preventDefaultDelta = screen.height / preventDefaultDivi;
if (preventDefaultDelta < 12) preventDefaultDelta = 12;
for (var gesture in gTouchElem[id])
{
if (!gTouchElem[id][gesture].horizontalScrollActiv && !gTouchElem[id][gesture].verticalScrollActiv)
{
//Hier sollte eigentlich ein Prevent Default gemacht werden, Leider scrollt der Safarie unter IOS aber dann nicht mehr hoch und runter. Daher leider raus.
//evt.preventDefault();
var deltaX = gTouchElem[id][gesture].startX - evt.targetTouches[0].screenX;
var deltaY = gTouchElem[id][gesture].startY - evt.targetTouches[0].screenY;
if (deltaX < 0)
deltaX *= -1;
if (deltaY < 0)
deltaY *= -1;
gTouchElem[id][gesture].verticalScrollActiv = !gTouchElem[id][gesture].horizontalScrollActiv && deltaY > preventDefaultDelta;
gTouchElem[id][gesture].horizontalScrollActiv = !gTouchElem[id][gesture].verticalScrollActiv && deltaX > preventDefaultDelta;
}
if (gTouchElem[id][gesture].horizontalScrollActiv && !gTouchElem[id][gesture].verticalScrollActiv)
touchSideMove(evt, id);
else if (gTouchElem[id][gesture].verticalScrollActiv && !gTouchElem[id][gesture].horizontalScrollActiv)
touchUpDownMove(evt, id);
gTouchElem[id][gesture].lastX = evt.targetTouches[0].screenX;
gTouchElem[id][gesture].lastY = evt.targetTouches[0].screenY;
}
}
};
function touchStart(evt)
{
var id = getRegisteredForTouch(evt);
if (id)
{
for (var gesture in gTouchElem[id])
{
setTouchDefaults(gTouchElem[id][gesture]);
if (evt.targetTouches[0].screenX != null && evt.targetTouches[0].screenY != null)
{
gTouchElem[id][gesture].startX = evt.targetTouches[0].screenX;
gTouchElem[id][gesture].lastX = evt.targetTouches[0].screenX;
gTouchElem[id][gesture].startY = evt.targetTouches[0].screenY;
gTouchElem[id][gesture].lastY = evt.targetTouches[0].screenY;
}
}
}
};
function touchEnd(evt)
{
var id = getRegisteredForTouch(evt);
if (id)
{
for (var gesture in gTouchElem[id])
{
setTouchDefaults(gTouchElem[id][gesture]);
}
}
};
function touchCancel(evt)
{
var id = getRegisteredForTouch(evt);
if (id)
{
for (var gesture in gTouchElem[id])
{
setTouchDefaults(gTouchElem[id][gesture]);
}
}
};
function touchLeave(evt)
{
var id = getRegisteredForTouch(evt);
if (id)
{
for (var gesture in gTouchElem[id])
{
setTouchDefaults(gTouchElem[id][gesture]);
}
}
};
return lib;
})();
