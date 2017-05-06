var g_prozentProSeite = 95;
var g_textIndexArray = new Array();
var g_textArray = new Array();
var g_aktuellerIndex = 0;
var g_datum = "";
var g_fontname = "Arial";
var g_topPosNextPage = 0;
var g_pictureObjects = new Array();
var g_canvasArray = new Array();
var g_objImageData;
var textStringDinA4="01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678";
var textStringDinA4_1="012345678901234567890123456789012345678901234567890123456789012345678901";
var g_DINA4width=1;
var g_canvas_anchor="";
function getWeiteDINA4Metrik(nameCanvas)
{
var myCanvas = document.getElementById(nameCanvas);
if(myCanvas && myCanvas.getContext)
{
var ctx = myCanvas.getContext('2d');
ctx.save();
ctx.font = '12px Arial';
ctx.fillText(textStringDinA4,0, 10);
var metrics = ctx.measureText(textStringDinA4);
ctx.restore();
return (metrics.width);
}
return 0;
}
function init_txt2canvas(canvasName,CanvasAnchor)
{
g_DINA4width=getWeiteDINA4Metrik(canvasName);
g_canvasArray = new Array();
g_canvas_anchor=CanvasAnchor;
}
function OnChangeFileSel(e)
{
var files = e.target.files;
for (var i = 0, f; f = files[i]; i++)
{
if (!f.type.match('image.*'))
{
continue;
}
var reader = new FileReader();
reader.onload = (function(f){
return function(e)
{
var dataUri = e.target.result;
var span = document.createElement('span');
span.innerHTML = ['<img class="thumb" src="', dataUri,
'" title="', escape(f.name), '"/>'].join('');
document.getElementById('uiThumbList').innerHTML="";
g_pictureObjects=new Array();
document.getElementById('uiThumbList').insertBefore(span, null);
var imageSFF = new Image();
imageSFF.onload = function()
{
var scale=g_DINA4width;
poolPictureObject(scale,imageSFF,f.name);
}
imageSFF.src = dataUri;
}
})(f);
reader.readAsDataURL(f);
}
}
function poolPictureObject(scale,image,fname)
{
var topPosPicture = 15/210*scale;
var dinA4_h = 297/210*scale;
var w = Number(image.width);
var h = Number(image.height);
var x = 0;
var y = 0;
var a = new Array(0,0,0,0);
if( (image.width > scale) || (image.height > dinA4_h) )
{
var wd = image.width - scale;
var hd = image.height - dinA4_h;
var v = ( (wd*hd) < 0 ? 0 : wd);
if(hd > v)
{
image.height = dinA4_h;
image.width = w*dinA4_h/h;
}
else
{
image.width = scale-50;
image.height = image.width*h/w;
}
}
a = posPictureInCanvas(scale,image,topPosPicture);
x = a[0];
y = a[1];
w = a[2];
h = a[3];
var imgObj = new Object();
imgObj.picture = image;
imgObj.name = fname;
imgObj.x = x;
imgObj.y = y;
imgObj.w = w;
imgObj.h = h;
g_pictureObjects.push(imgObj);
}
function posPictureInCanvas(scale,image,TopPos)
{
var ret = new Array(0,0,0,0);
dinA4_h = 297/210*scale;
x = (scale - image.width)/2;
y = (dinA4_h - image.height)/2;
var w = image.width;
var h = image.height;
if( y < TopPos)
{
h = image.height - 2*(TopPos - y);
w = image.width/image.height*h;
x = (scale - w)/2;
y = TopPos;
}
ret[0] = x;
ret[1] = y;
ret[2] = w;
ret[3] = h;
return ret;
}
function CreateFaxPage(nameCanvas,data)
{
cleanCanvas(nameCanvas);
var scale = GetScaleFactor(nameCanvas);
cleanCanvas(nameCanvas);
if ( false === drawFaxPages(scale,data) )
{
return false;
}
for ( var n = 0; n < g_canvasArray.length; n++ )
{
var canvas = document.getElementById( g_canvasArray[n] );
if ( canvas.width != 1728 )
{
return false;
}
}
var sff = new SFF();
var SffFile = sff.Canvas2SFF(g_canvasArray);
return SffFile;
}
function GetScaleFactor(nameCanvas)
{
var myCanvas = document.getElementById(nameCanvas);
if(myCanvas.getContext)
{
var ctx = myCanvas.getContext('2d');
ctx.save();
ctx.font = '12px Arial';
ctx.fillText(textStringDinA4,0, 10);
var metrics = ctx.measureText(textStringDinA4);
ctx.restore();
return (myCanvas.width/metrics.width); //sollte myCanvas.width=1728 sein.
}
return 0;
}
function cleanCanvas(nameCanvas)
{
var myCanvas = document.getElementById(nameCanvas);
if(myCanvas.getContext)
{
var ctx = myCanvas.getContext('2d');
ctx.clearRect(0,0,ctx.canvas.width,ctx.canvas.height);
}
}
function splitWord(ctx,w,linelimit,a)
{
var s = "";
var m = 0;
var metrics = ctx.measureText(" ");
var spacebreite = metrics.width;
var w1 = w;
var i2 = w.length;
// Durch stetige Halbierung kleinste Stringlänge finden, um sich dann wieder hochzuarbeiten
do
{
i2 = Math.floor(i2/2);
s = w1.substring(0,i2);
m = ctx.measureText(s);
w1 = s;
}
while(m.width >= (linelimit-spacebreite))
w1 = w;
var s_prev = "";
// hier arbeiten wir uns wieder auf die passende Länge hoch
while(i2 < w.length)
{
s = w1.substring(0,i2);
m = ctx.measureText(s);
if(m.width > (linelimit-spacebreite)) break;
s_prev = s;
i2++;
}
i2--;
a.push.apply(a,[s_prev]);
var rest = w.substring(i2,w.length);
if(ctx.measureText(rest).width <= linelimit)
{
a.push(rest);
return;
}
// rekursiver Aufruf
splitWord(ctx,rest,linelimit,a);
}
function setLabelText(ctx,sLabel,sFont,x,y)
{
ctx.font = sFont;
ctx.fillText(sLabel,x, y);
}
function setLabelText1Zeile(ctx,skalierung,text1,text2,datum,sFont,x,y)
{
var marginLeft=10;
var marginRight=10;
ctx.font = sFont;
ctx.fillText(text1,(x+marginLeft)/skalierung, y);
ctx.save();
ctx.textAlign = "right";
ctx.fillText(datum,(ctx.canvas.width-marginRight)/skalierung, y);
ctx.restore();
ctx.save();
ctx.textAlign = "center";
ctx.fillText(text2,ctx.canvas.width/2/skalierung, y);
ctx.restore();
}
function wrapText(ctx,sText,loff)
{
var metrics = ctx.measureText(" ");
var spacebreite = metrics.width;
var linelimit = g_DINA4width - 2*loff;
var ca = sText.split("\n");
var sResult = "";
var calen = ca.length;
for(var j=0; j < calen; j++)
{
var cr = ca[j];
metrics = ctx.measureText(cr);
if(metrics.width > linelimit)
{
var words = cr.split(" ");
var len = 0;
var k = 0;
var textOverLine = new Array();
var indexObj = 0;
var offlen = 0;
var wlen = words.length;
var obj0;
while( k < wlen)
{
var wr = words[k];
metrics = ctx.measureText(wr);
if(metrics.width > linelimit)
{
var obj = new Object();
obj.index = (indexObj == 0 ? k : offlen + k - indexObj);
obj.splittedWords = new Array();
var a = new Array();
splitWord(ctx,wr,linelimit,a);
obj.splittedWords = a;
textOverLine[indexObj] = obj;
obj0 = obj;
offlen += obj.splittedWords.length;
indexObj++;
}
k++;
}
if(textOverLine.length > 0)
{
var t = 0;
while(t < textOverLine.length)
{
words.splice(textOverLine[t].index,1,textOverLine[t].splittedWords[0]);
for(var u=1; u<textOverLine[t].splittedWords.length; u++)
{
words.splice(textOverLine[t].index+u,0,textOverLine[t].splittedWords[u]);
}
t++;
}
}
len = 0;
k = 0;
var marker = new Array();
while( k < words.length)
{
metrics = ctx.measureText(words[k]);
len += (metrics.width + spacebreite);
marker.push(0);
if( len > linelimit)
{
words[k-1] += "\n";
len = 0;
k--;
marker.pop();
marker[k] = 1;
}
k++;
}
for(var m=0; m<words.length; m++)
{
sResult += (marker[m] == 1 ? words[m] : words[m] + " " );
}
sResult += "\n";
}
else
{
sResult += (ca[j] + "\n");
}
}
return sResult;
}
function createCanvasElements(nameCanvas)
{
var bn = document.getElementById(g_canvas_anchor);
var mydiv = document.createElement("div");
var mycanvas = document.createElement("canvas");
if ( !bn || !mydiv || !mycanvas )
{
return false;
}
mycanvas.setAttribute("Width","1728");
mycanvas.setAttribute("Height","2444");
mycanvas.id=nameCanvas;
mydiv.appendChild(mycanvas);
mydiv.className = "";
mydiv.id = nameCanvas + "_div";
bn.appendChild(mydiv);
return mycanvas;
}
function drawWrappedText(ctx,textArray,startIndex,lRand,topOffset,scale,fontname,bDraw)
{
var lineCount = 1;
var linespace = ctx.canvas.height/scale/61;
var i = startIndex;
var p = 0;
do
{
if(bDraw)setLabelText(ctx,textArray[i],"12px "+fontname,lRand, topOffset);
topOffset += linespace;
p = (topOffset == 0 ? 0 : (topOffset/(ctx.canvas.height/scale)*100) ) ;
i++;
}
while( (i < textArray.length) && (p <= g_prozentProSeite) )
return (i-1);
}
function drawRestFaxPages(nameCanvas,scale,n,posTitelLine,leftPosText,data)
{
var lRand = leftPosText;
var TopPos = posTitelLine;
var myCanvas = document.getElementById(nameCanvas);
if(myCanvas.getContext)
{
var ctx = myCanvas.getContext('2d');
ctx.save();
ctx.scale(scale,scale);
setLabelText1Zeile(ctx,scale, data.send_short+" ("+(n+1)+"/" + (g_textIndexArray.length+g_pictureObjects.length)+")",data.identifier,data.date,"10px "+g_fontname,0,TopPos);
ctx.restore();
}
}
function prepareCanvas_new(nameCanvas)
{
if( (typeof Uint32Array === "undefined") || (typeof Uint8ClampedArray === "undefined") )
{
prepareCanvas(nameCanvas);
return;
}
var myCanvas = document.getElementById(nameCanvas);
if(myCanvas.getContext)
{
var ctx = myCanvas.getContext('2d');
if(typeof ctx.getImageData != "function")
{
alert("CANVAS : getImageData ist nicht verfügbar");
return;
}
var objImageData = ctx.getImageData(0,0, myCanvas.width, myCanvas.height);
var pixels = new Uint32Array( objImageData.data.buffer );
var buf8 = new Uint8ClampedArray(objImageData.data.buffer);
var xnull = 0x00;
var xff = 0xff;
var sffBlack = (xff << 24) | ( xnull << 16 ) | ( xnull << 8) | xnull;
var sffWhite = (xff << 24) | ( xff << 16 ) | ( xff << 8) | xff;
for(var y=0; y < myCanvas.height; y++)
{
var index = y * myCanvas.width;
for(var x=0; x < myCanvas.width; x++)
{
pixels[index] = ( pixels[index] > 0 ? sffBlack : sffWhite );
index++;
}
}
objImageData.data.set(buf8);
ctx.putImageData(objImageData, 0, 0 );
}
}
function prepareCanvas(nameCanvas)
{
var myCanvas = document.getElementById(nameCanvas);
if(myCanvas.getContext)
{
var ctx = myCanvas.getContext('2d');
if(typeof ctx.getImageData != "function")
{
alert("CANVAS : getImageData ist nicht verfügbar");
return;
}
var objImageData = ctx.getImageData(0,0, myCanvas.width, myCanvas.height);
for(var y=0; y < myCanvas.height; y++)
{
var loff = y * 4 * myCanvas.width;
for(var x=0; x < myCanvas.width; x++,loff+=4)
{
objImageData.data[loff] = objImageData.data[loff+ 1] = objImageData.data[loff + 2] = ( objImageData.data[loff + 3] == 0 ? 255 : 0);
objImageData.data[loff + 3] = 255;
}
}
ctx.putImageData(objImageData, 0, 0 );
}
}
function prepareCanvasArray(limit)
{
for(var i = 0; i<limit; i++)
{
prepareCanvas_new(g_canvasArray[i]);
}
}
function drawScaledPicture(ctx,image,x,y,dw,dh)
{
ctx.save();
ctx.drawImage(image,x,y,dw,dh);
ctx.restore();
}
function toMonoChrome( pix, width, height )
{
for (var i = 0; i <= pix.length; i += 4)
pix[i] =
( pix[i] * 299 // rot
+ pix[i+1] * 587 // grün
+ pix[i+2] * 114 // blau
+ 500 ) / 1000;
w1 = Math.ceil(width);
h1 = Math.ceil(height);
var x, ci;
var lOff = 4 * w1; // lineOffset in Buffer
for( var y = 0; y < h1; y++)
{
ci = y * lOff;
for( x = 0; x < w1; x++, ci +=4 )
{
var cc = pix[ ci ]; // current color
var rc = cc < 128 ? 0 : 255; // real (rounded) color
var err = cc - rc; // error amount
pix[ ci ] = rc; // saving real color
if( x + 1 < w1 )
pix[ ci + 4 ] += (err*7)/16; // if right neighbour exists
if( y + 1 >= h1 ) continue;
if( x > 0 )
pix[ ci + lOff - 4]+= (err*3)/16; // bottom left neighbour
pix[ ci + lOff ] += (err*5)/16; // bottom neighbour
if( x + 1 < w1 )
pix[ ci + lOff + 4]+= (err*1)/16; // bottom right neighbour
}
}
for (var i = 0; i <= pix.length; i += 4) pix[i+1] = pix[i+2] = pix[i];
}
function toMonoChrome_new( pix, width, height )
{
if( (typeof Uint32Array === "undefined") || (typeof Uint8ClampedArray === "undefined") )
{
toMonoChrome( pix, width, height );
return;
}
var pixels = new Uint32Array( pix.buffer );
var buf8 = new Uint8ClampedArray(pix.buffer);
for (var i = 0; i <= pixels.length; i++)
{
var j = i*4;
buf8[j] = (buf8[j]*0.299 + buf8[j+1]*0.587 + buf8[j+2]*0.114 + 0.5);
}
w1 = Math.ceil(width);
h1 = Math.ceil(height);
var yoff_0 = 0;
var yoff_1 = w1;
for(var y = 0; y < (h1-1); y++,yoff_0 += w1 , yoff_1 += w1 )
{
var ci_0 = yoff_0*4;
var ci_1 = yoff_1*4;
for( x = 0; x < w1; x++, ci_0 += 4,ci_1 += 4)
{
var cc = buf8[ci_0]; //current color
var rc = (cc < 128 ? 0 : 255); // real (rounded) color
var err = (cc - rc)/16; // error amount
buf8[ ci_0 ] = rc; // saving real color
if( x + 1 < w1) buf8[ ci_0 + 4] += (err*7); // if right neighbour exists
if( x > 0 ) buf8[ ci_1 - 4] += (err*3); // bottom left neighbour
buf8[ ci_1 ] += (err*5); // bottom neighbour
buf8[ ci_1 + 4] += (err*1); // bottom right neighbour
buf8[ci_0+1] = buf8[ci_0+2] = buf8[ci_0];
buf8[ci_1+1] = buf8[ci_1+2] = buf8[ci_1];
}
}
pix.set(buf8);
}
function drawScaledPicture_new(ctx,scale,image,x,y,dw,dh)
{
ctx.save();
ctx.drawImage(image,x,y,dw,dh);
var imgd = ctx.getImageData( scale*x, scale*y, scale*dw, scale*dh);
toMonoChrome_new( imgd.data, scale*dw, scale*dh );
ctx.putImageData( imgd, scale*x, scale*y );
ctx.restore();
}
function draw_appendedPicture(index,scale,posTitelLine,data)
{
var pictureCanvas = document.getElementById(g_canvasArray[g_canvasArray.length-1]);
if(pictureCanvas.getContext)
{
var TopPos = posTitelLine;
var ctx = pictureCanvas.getContext("2d");
ctx.save();
ctx.scale(scale,scale);
cleanCanvas(g_canvasArray[g_canvasArray.length-1]);
setLabelText1Zeile(ctx,scale, data.send_short+" ("+(g_textIndexArray.length + index + 1)+"/" + (g_textIndexArray.length+g_pictureObjects.length)+")",data.identifier,data.date,"10px "+g_fontname,0,TopPos);
prepareCanvas(g_canvasArray[g_canvasArray.length-1]);
drawScaledPicture_new(ctx,scale,g_pictureObjects[index].picture,g_pictureObjects[index].x,g_pictureObjects[index].y,g_pictureObjects[index].w,g_pictureObjects[index].h);
ctx.restore();
}
}
function drawFaxPages(scale,data)
{
var border = 15*scale;
var border01 = 41*scale;
var border1 = 130*scale;
var border11 = 152*scale;
var TopPos = 20*scale;
var fontname = "Arial";
g_topPosNextPage = TopPos;
g_canvasArray.push("idSFFCanvas_0");
var myCanvas=createCanvasElements("idSFFCanvas_0");
if ( false === myCanvas )
{
return false;
}
cleanCanvas("idSFFCanvas_0");
if(myCanvas.getContext)
{
var ctx = myCanvas.getContext('2d');
ctx.save();
ctx.scale(scale,scale);
setLabelText(ctx,"{?2429:115?}","bold 20px "+fontname,border, TopPos);
setLabelText(ctx,"{?2429:883?}","bold 12px "+fontname,border, TopPos + 50);
setLabelText(ctx,data.dest_name,"12px "+fontname,border01, TopPos + 50);
setLabelText(ctx,"{?2429:648?}","bold 12px "+fontname,border, TopPos + 70);
setLabelText(ctx,data.dest_fax,"12px "+fontname,border01, TopPos + 70);
setLabelText(ctx,"{?2429:548?}","bold 12px "+fontname,border1, TopPos + 50);
var ca = data.from_name.split("\n");
var offset = 50;
for(var i=0; i<ca.length; i++)
{
setLabelText(ctx,ca[i],"12px "+fontname,border11, TopPos+offset);
offset += 14;
}
setLabelText(ctx,"{?2429:554?}","bold 12px",border1, TopPos + 130);
setLabelText(ctx,data.shortdate,"12px",border11, TopPos + 130);
setLabelText(ctx,"{?2429:805?}","bold 12px "+fontname,border, TopPos+200);
setLabelText(ctx,data.subject,"12px "+fontname,border01, TopPos+200);
//////////////////////////////
var linespace = ctx.canvas.height/scale/61;
var offset = g_topPosNextPage + 17*linespace;
g_textIndexArray = new Array();
g_textArray = new Array();
g_aktuellerIndex = 0;
var sResult = wrapText(ctx,data.text,border);
g_textArray = sResult.split("\n");
var aktuellerIndex = drawWrappedText(ctx,g_textArray,0,border,offset,scale,fontname,true);
g_textIndexArray.push( ((g_textArray.length - aktuellerIndex -1) == 0 ? -1 : 0) );
if( g_textIndexArray[0] != -1 )
{
g_textIndexArray.push(aktuellerIndex);
aktuellerIndex = g_textIndexArray[1];
var rest = g_textArray.length - aktuellerIndex -1;
var faxpage = 1;
while( rest > 0)
{
g_canvasArray.push("idSFFCanvas_"+ faxpage);
var tmpCanvas=createCanvasElements("idSFFCanvas_"+ faxpage)
if ( false === tmpCanvas )
{
return false;
}
var tmpctx=ctx;
if(tmpCanvas.getContext)
{
tmpctx = tmpCanvas.getContext('2d');
}
tmpctx.save();
tmpctx.scale(scale,scale);
faxpage++;
aktuellerIndex++;
aktuellerIndex = drawWrappedText(tmpctx,g_textArray,aktuellerIndex,border,g_topPosNextPage,scale,fontname,true);
tmpctx.restore();
if (faxpage>=2)
break;
rest = g_textArray.length - aktuellerIndex -1;
if(rest > 0) g_textIndexArray.push(aktuellerIndex);
}
//setLabelText1Zeile(ctx,scale, data.send_short+" (1/" + (faxpage + g_pictureObjects.length)+")",data.identifier,data.date,"10px "+fontname,0,TopPos-40);
//for(var c=1; c<g_canvasArray.length; c++)
}
ctx.restore();
for(var c=0; c<g_canvasArray.length; c++)
{
drawRestFaxPages(g_canvasArray[c],scale,c,(TopPos-40),border,data);
}
prepareCanvasArray(g_canvasArray.length);
var len = g_canvasArray.length;
for(var p=0; p<g_pictureObjects.length; p++)
{
g_canvasArray.push("idSFFCanvas_"+ (len+p));
createCanvasElements("idSFFCanvas_"+ (len+p));
draw_appendedPicture(p,scale,(TopPos-40),data);
}
}
}
