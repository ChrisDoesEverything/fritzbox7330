/* $Id: wt_tree.js,v 1.2 2010-11-24 14:53:23 sebastian Exp $ */
"use strict";

function iefix()
{
	/* work around a nasty IE drawing bug */
	if (navigator.userAgent.indexOf("MSIE ") !== -1)
	{
		/* save state */
		var i;
		var save = "";
		var inp = document.getElementsByName("dir");
		for (i = 0; inp && i < inp.length; i++)
		{
			if (inp[i].checked)
			{
				save = inp[i].value;
				break;
			}
		}
		/* reinsert tree */
		var div = document.getElementById("listwrapper");
		var ul = div.removeChild(div.firstChild);
		div.appendChild(ul);
		/* restore state */
		var inp_restore = document.getElementsByName("dir");
		for (i = 0; inp_restore && i < inp_restore.length; i++)
		{
			if (inp_restore[i].value === save)
			{
				inp_restore[i].checked = true;
				break;
			}
		}
	}
}

function toggleSubTree(img, list)
{
	if (list.style.display === "none")
	{
		list.style.display = "block";
		img.src = "/css/default/images/schliessen.gif";
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
	if (list.style.display === "none")
	{
		img.src = "/css/default/images/oeffnen.gif";
	}
	else
	{
		img.src = "/css/default/images/schliessen.gif";
	}
	img.style.position = "absolute";
	img.onclick = function ()
	{
		toggleSubTree(img, list);
	};
	item.insertBefore(img, item.firstChild);
}

function addOpenButton(item, list)
{
	var img = document.createElement("img");
	img.src = "/css/default/images/oeffnen.gif";
	img.style.position = "absolute";
	img.onclick = function ()
	{
		toggleSubTree(img, list);
	};
	item.insertBefore(img, item.firstChild);
	list.style.display = "none";
}

function addTreeCtrls()
{
	var listitems = document.getElementsByTagName("li");
	var i;

	for (i = 0; i < listitems.length; i++)
	{
		var sub = listitems[i].getElementsByTagName("ul");

		if (sub !== null && sub.length > 0)
		{
			/* if the div-tag has the class "fast" close the subtree */
			var sub_div = listitems[i].getElementsByTagName("div");

			if (sub_div[0].className === "fast")
			{
				addOpenButton(listitems[i], sub[0]);
			}
			else
			{
				/* every li with a ul child gets a [-] button */
				addHideButton(listitems[i], sub[0]);
			}
		}
	}
}

function updateColors()
{
	var num = document.getElementById('txtLevel').value - 0;
	var max = document.getElementById('maxDuration').value - 0;
	var nr = 0;
	var arrayClassElements = [];
	var border1 = 20 * num / 100;
	var border2 = 40 * num / 100;
	var border3 = 60 * num / 100;
	var border4 = 80 * num / 100;
	var border5 = 100 * num / 100;
	var border6 = 200 * num / 100;
	var border7 = 500 * num / 100;
	var border8 = 1000 * num / 100;
	var border9 = 2000 * num / 100;
	var border10 = 5000 * num / 100;

	while (nr < max)
	{
		var classname = '00';

		if (nr < border1)
		{
			classname = '00';
		}
		else
		if (nr < border2)
		{
			classname = '01';
		}
		else
		if (nr < border3)
		{
			classname = '02';
		}
		else
		if (nr < border4)
		{
			classname = '03';
		}
		else
		if (nr < border5)
		{
			classname = '04';
		}
		else
		if (nr < border6)
		{
			classname = '05';
		}
		else
		if (nr < border7)
		{
			classname = '06';
		}
		else
		if (nr < border8)
		{
			classname = '07';
		}
		else
		if (nr < border9)
		{
			classname = '08';
		}
		else
		if (nr < border10)
		{
			classname = '09';
		}
		else
		{
			classname = '10';
		}

		arrayClassElements = document.getElementsByClassName('elem_' + nr, document.body);

		for (var i = 0; i < arrayClassElements.length; i++)
		{
			var my_string = arrayClassElements[i].className;

			my_string = my_string.replace(/color\d+/, "");

			arrayClassElements[i].className = my_string + " color" + classname;
		}

		nr = nr + 1;
	}
}

function disableForm (enable_)
{
	document.getElementById('btnPlus').disabled = enable_;
	document.getElementById('btnMinus').disabled = enable_;
	document.getElementById('txtLevel').disabled = enable_;
}

function clickButtonPlus()
{
	disableForm(true);

	var num = document.getElementById('txtLevel').value - 0;
	num += 1;
	document.getElementById('txtLevel').value = num;
	updateColors();

	disableForm(false);
}

function clickButtonMinus()
{
	disableForm(true);

	var num = document.getElementById('txtLevel').value - 0;
	num -= 1;
	document.getElementById('txtLevel').value = num;
	updateColors();

	disableForm(false);
}

function init()
{
	disableForm(true);

	addTreeCtrls();
	updateColors();

	disableForm(false);
}

window.onload = init;
