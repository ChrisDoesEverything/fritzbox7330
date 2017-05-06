/*
/*
** Created by: Jeff Todnem (http://www.todnem.com/)
** Created on: 2007-08-14
** Last modified: 2010-05-03
**
** License Information:
** -------------------------------------------------------------------------
** Copyright (C) 2007 Jeff Todnem
**
** This program is free software; you can redistribute it and/or modify it
** under the terms of the GNU General Public License as published by the
** Free Software Foundation; either version 2 of the License, or (at your
** option) any later version.
**
** This program is distributed in the hope that it will be useful, but
** WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
** General Public License for more details.
**
** You should have received a copy of the GNU General Public License along
** with this program; if not, write to the Free Software Foundation, Inc.,
** 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
**
*/
String.prototype.strReverse = function()
{
var newstring = "";
for ( var i = 0; i < this.length; i++ )
{
newstring = this.charAt( i ) + newstring;
}
return newstring;
};
function createPasswordChecker( id, minPasswordLength )
{
"use strict";
jxl.createStyleTag(' \
/****************** Password Checker *********************/ \
\
.password_check_box, \
.password_check_box.form_input_note { \
margin-top: 5px; \
} \
\
.password_check_bar, \
.password_check_txt { \
height: 11px; \
width: 170px; \
color: transparent; \
font-size: 11px; \
font-weight: bold; \
background-color: transparent; \
border-radius: 2px; \
overflow: hidden; \
margin: 0; \
padding: 0; \
transition: all 0.75s; \
} \
.password_check_bar { \
margin: 0 0 1px 0; \
width: 10%; \
height: 8px; \
} \
\
.good .password_check_bar { \
width: 100%; \
background-color: #81aa3d; \
} \
.medium .password_check_bar { \
width: 66%; \
background-color: #ffba01; \
} \
.bad .password_check_bar { \
width: 33%; \
background-color: #f44b00; \
} \
.short .password_check_bar { \
width: 33%; \
background-color: #bfbfbf; \
} \
\
.good .password_check_txt { \
color: #749937; \
} \
.medium .password_check_txt { \
color: #ce9601; \
} \
.bad .password_check_txt { \
color: #f44b00; \
} \
.short .password_check_txt { \
color: #7d7d7d; \
} \
/*################## ENDE Password Checker ################*/');
var lPasswordElem = null;
var lPasswordInfoBox = null;
var lMinPasswordLength = 0;
function checkPassword()
{
if ( 0 < lMinPasswordLength && lMinPasswordLength > lPasswordElem.value.length )
{
lPasswordInfoBox.setAttribute( 'class', 'form_input_note password_check_box short' );
lPasswordInfoBox.children[1].innerHTML = jxl.sprintf("{?199:923?}", lMinPasswordLength - lPasswordElem.value.length );
return;
}
var score = getScore( lPasswordElem.value );
if ( 66 <= score )
{
lPasswordInfoBox.setAttribute( 'class', 'form_input_note password_check_box good' );
lPasswordInfoBox.children[1].innerHTML = "{?199:444?}";
}
else if ( 33 <= score )
{
lPasswordInfoBox.setAttribute( 'class', 'form_input_note password_check_box medium' );
lPasswordInfoBox.children[1].innerHTML = "{?199:989?}";
}
else
{
lPasswordInfoBox.setAttribute( 'class', 'form_input_note password_check_box bad' );
lPasswordInfoBox.children[1].innerHTML = "{?199:688?}";
}
}
function getScore( pwd )
{
var nScore=0, passLen=0, nAlphaUC=0, nAlphaLC=0, nNumber=0, nSymbol=0;
var nMidChar=0, nUnqChar=0;
var nRepChar=0, nRepInc=0, nConsecAlphaUC=0, nConsecAlphaLC=0, nConsecNumber=0;
var nSeqAlpha=0, nSeqNumber=0, nSeqSymbol=0;
var nMultMidChar=2, nMultConsecAlphaUC=2, nMultConsecAlphaLC=2, nMultConsecNumber=2;
var nMultSeqAlpha=6, nMultSeqNumber=6, nMultSeqSymbol=6;
var nMultLength=3, nMultNumber=4, nMultSymbol=6;
var nTmpAlphaUC="", nTmpAlphaLC="", nTmpNumber="";
var sAlphas = "abcdefghijklmnopqrstuvwxyzäöü";
var keyboardLeftRight = "qertzuiopüasdfghjklöäyxcvbnm";
var keyboardUpDownLeftRight = "qaywsxedcrfvtgbzhnujmik,olik;ol.pöol:pö-üäpö_üä";
var keyboardUpDownRightLeft = "wa<eswa>eswa|esyrdxtfczgvuhbijnokmpl,üöpl;üö.üö:+ä-+ä_*ä-*ä_~ä-~ä_";
var sNumerics = "01234567890147258369159357";
var sSymbols = "^°!`\"§$%&/()=?`*'ß´+#,.-;:_";
if ( null != pwd && "string" == typeof pwd )
{
passLen = pwd.length;
nScore = parseInt( passLen * passLen / nMultLength );
var arrPwd = pwd.replace(/\s+/g,"").split(/\s*/);
var arrPwdLen = arrPwd.length;
for ( var a = 0; a < arrPwdLen; a++ )
{
if ( arrPwd[ a ].match( /[A-Z]/g ) )
{
if ( "" !== nTmpAlphaUC && a == ( nTmpAlphaUC + 1 ) )
{
nConsecAlphaUC++;
}
nTmpAlphaUC = a;
nAlphaUC++;
}
else if ( arrPwd[ a ].match( /[a-z]/g ) )
{
if ( "" !== nTmpAlphaLC && a == ( nTmpAlphaLC + 1 ) )
{
nConsecAlphaLC++;
}
nTmpAlphaLC = a;
nAlphaLC++;
}
else if ( arrPwd[ a ].match( /[0-9]/g ) )
{
if ( a > 0 && a < ( arrPwdLen - 1 ) )
{
nMidChar++;
}
if ( "" !== nTmpNumber && a == ( nTmpNumber + 1 ) )
{
nConsecNumber++;
}
nTmpNumber = a;
nNumber++;
}
else if ( arrPwd[ a ].match( /[^a-zA-Z0-9_]/g ) )
{
if ( a > 0 && a < ( arrPwdLen - 1 ) )
{
nMidChar++;
}
nSymbol++;
}
var bCharExists = false;
for ( var b = 0; b < arrPwdLen; b++ )
{
if ( arrPwd[ a ] == arrPwd[ b ] && a != b )
{
bCharExists = true;
nRepInc += Math.abs( arrPwdLen / ( b - a ) );
}
}
if ( bCharExists )
{
nRepChar++;
nUnqChar = arrPwdLen - nRepChar;
nRepInc = ( nUnqChar ) ? Math.ceil( nRepInc / nUnqChar ) : Math.ceil( nRepInc );
}
}
var searchWidth = 3;
for ( var i = 0; i < ( sAlphas.length - searchWidth ); i++ )
{
var sFwd = sAlphas.substring( i, parseInt( i + searchWidth ) );
var sRev = sFwd.strReverse();
if ( -1 != pwd.toLowerCase().indexOf( sFwd ) || -1 != pwd.toLowerCase().indexOf( sRev ) )
{
nSeqAlpha++;
}
}
for ( var i = 0; i < ( keyboardLeftRight.length - searchWidth ); i++ )
{
var sFwd = keyboardLeftRight.substring( i, parseInt( i + searchWidth ) );
var sRev = sFwd.strReverse();
if ( -1 != pwd.toLowerCase().indexOf( sFwd ) || -1 != pwd.toLowerCase().indexOf( sRev ) )
{
nSeqAlpha++;
}
}
for ( var i = 0; i < ( keyboardUpDownLeftRight.length - searchWidth ); i++ )
{
var sFwd = keyboardUpDownLeftRight.substring( i, parseInt( i + searchWidth ) );
var sRev = sFwd.strReverse();
if ( -1 != pwd.toLowerCase().indexOf( sFwd ) || -1 != pwd.toLowerCase().indexOf( sRev ) )
{
nSeqAlpha++;
}
}
for ( var i = 0; i < ( keyboardUpDownRightLeft.length - searchWidth ); i++ )
{
var sFwd = keyboardUpDownRightLeft.substring( i, parseInt( i + searchWidth ) );
var sRev = sFwd.strReverse();
if ( -1 != pwd.toLowerCase().indexOf( sFwd ) || -1 != pwd.toLowerCase().indexOf( sRev ) )
{
nSeqAlpha++;
}
}
for ( var i = 0; i < ( sNumerics.length - searchWidth ); i++ )
{
var sFwd = sNumerics.substring( i, parseInt( i + searchWidth ) );
var sRev = sFwd.strReverse();
var regex = new RegExp( sFwd + "|" + sRev, "g" );
var searchResult = pwd.match( regex );
if ( searchResult && 0 < searchResult.length )
{
nSeqNumber += searchResult.length;
}
}
for ( var i = 0; i < ( sSymbols - searchWidth ); i++ )
{
var sFwd = sSymbols.substring( i, parseInt( i + searchWidth ) );
var sRev = sFwd.strReverse();
if ( -1 != pwd.toLowerCase().indexOf( sFwd ) || -1 != pwd.toLowerCase().indexOf( sRev ) )
{
nSeqSymbol++;
}
}
if ( nAlphaUC > 0 && nAlphaUC < passLen )
{
nScore = parseInt( nScore + ( ( passLen - nAlphaUC ) * 2 ) );
}
if ( nAlphaLC > 0 && nAlphaLC < passLen )
{
nScore = parseInt( nScore + ( ( passLen - nAlphaLC ) * 2 ) );
}
if ( nNumber > 0 && nNumber < passLen )
{
nScore = parseInt( nScore + ( nNumber * nMultNumber ) );
}
if ( nSymbol > 0 )
{
nScore = parseInt( nScore + ( nSymbol * nMultSymbol ) );
}
if ( nMidChar > 0 )
{
nScore = parseInt( nScore + ( nMidChar * nMultMidChar ) );
}
if ( ( nAlphaLC > 0 || nAlphaUC > 0 ) && nSymbol === 0 && nNumber === 0 )
{
nScore = parseInt( nScore - passLen );
}
if ( nAlphaLC === 0 && nAlphaUC === 0 && nSymbol === 0 && nNumber > 0 )
{
nScore = parseInt( nScore - passLen );
}
if ( nRepChar > 0 )
{
nScore = parseInt( nScore - nRepInc );
}
if ( nConsecAlphaUC > 0 )
{
nScore = parseInt( nScore - ( nConsecAlphaUC * nMultConsecAlphaUC ) );
}
if ( nConsecAlphaLC > 0 )
{
nScore = parseInt( nScore - ( nConsecAlphaLC * nMultConsecAlphaLC ) );
}
if ( nConsecNumber > 0 )
{
nScore = parseInt( nScore - ( nConsecNumber * nMultConsecNumber ) );
}
if ( nSeqAlpha > 0 )
{
nScore = parseInt( nScore - ( nSeqAlpha * nMultSeqAlpha ) );
}
if ( nSeqNumber > 0 )
{
nScore = parseInt( nScore - ( nSeqNumber * nSeqNumber ) + 5 );
}
if ( nSeqSymbol > 0 )
{
nScore = parseInt( nScore - ( nSeqSymbol * nMultSeqSymbol ) );
}
return nScore;
}
else
{
return 0;
}
}
function createPasswordInfoBox()
{
lPasswordInfoBox = document.createElement( "div" );
lPasswordInfoBox.id = id + "PasswordChecker";
lPasswordInfoBox.setAttribute( 'class', 'form_input_note password_check_box' );
var width = "width:150px;";
if ( lPasswordElem && lPasswordElem.offsetWidth )
{
width = "width:" + lPasswordElem.offsetWidth + "px;";
}
lPasswordInfoBox.setAttribute( 'style', width );
var tmp = document.createElement( "div" );
lPasswordInfoBox.appendChild( tmp );
tmp.setAttribute( 'class', 'password_check_bar' );
tmp = document.createElement( "div" );
tmp.setAttribute( 'class', 'password_check_txt' );
lPasswordInfoBox.appendChild( tmp );
lPasswordElem.parentNode.appendChild( lPasswordInfoBox );
}
lPasswordElem = jxl.get( id );
if ( !lPasswordElem || !lPasswordElem.parentNode )
{
return null;
}
if ( null != minPasswordLength && "number" == typeof minPasswordLength && 0 < minPasswordLength )
{
lMinPasswordLength = minPasswordLength;
}
createPasswordInfoBox();
lPasswordElem.addEventListener( "keyup", checkPassword, false );
}
