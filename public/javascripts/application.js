// PlaFce your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function tbodyHasRowIds(tbodyId, rowIds){
  var obj = document.getElementById(tbodyId);
  if(obj){
    var nChildren = obj.rows.length;
    var nChildNames = rowIds.length;
    for(var i=0; i<nChildren; i++){
      for(var j=0; j<nChildNames; j++){
	    if(obj.rows[i].id.indexOf(rowIds[j]) >= 0){
		  return true;
		}
	  }
    }
  }
  return false;
}

//bsc affects
function lighten(bubbles){
  for(var i=0; i<bubbles.length; i++)
    document.getElementById('bubble'+bubbles[i]).className='bubbleopaque1';
}

function darken(bubbles){
  for(var i=0; i<bubbles.length; i++)
    document.getElementById('bubble'+bubbles[i]).className='bubble';
}

//manejo de posicionamiento
function getTop(obj){
  if(obj){
    if(obj.offsetParent){
      return obj.offsetTop + getTop(obj.offsetParent);
	}
	return obj.offsetTop;
  }
  return false;
}

function getLeft(obj){
  if(obj){
    if(obj.offsetParent){
      return obj.offsetLeft + getLeft(obj.offsetParent);
	}
	return obj.offsetLeft;
  }
  return false;
}

function getHeight(obj){
  if(obj){
	return obj.offsetHeight;
  }
  return false;
}

function getWidth(obj){
  if(obj){
	return obj.offsetWidth;
  }
  return false;
}

function getText(obj){
  return(obj.text? obj.text : (obj.innerText? obj.innerText: obj.innerHTML));
}

function setText(obj, txt){
  obj.text? obj.text = txt : (obj.innerText? obj.innerText = txt: obj.innerHTML = txt);
}

//dragNdrop de objetivos + Flyinburrito
var drag = null;
var dragType = null;
var dragText = null;

DRAG_OBJECTIVE = 1;
DRAG_PERSPECTIVE = 2;
DRAG_AFFECTS = 3;
DRAG_IS_AFFECTED = 4;

var fb = null;
var fbX = null;
var fbY = null;
var fbMsg = null;

//IE y FF
function getMouseObject(e) {
  return(e? e.target: window.event.srcElement);
}
function getMouseX(e) {
  return(e? e.clientX: window.event.clientX);
}
function getMouseY(e) {
  return(e? e.clientY: window.event.clientY);
}
function pxToNumber(s) {
  return( Number( s.substring(0, s.length - 2) ) );
}

//manejo del flyinburrito
function showFB(x,y,how){
  fb = document.getElementById('flyinburrito');
  if(fb){
    fb.style.visibility='visible';
	fb.style.top = x + 'px';
	fb.style.left = y + 'px';
	setText(fb, dragText);
  }
}

function moveFB(x,y){
  if(fb){
	fb.style.top = y + 'px';
	fb.style.left = x + 'px';
  }
}

function hideFB(){
  if(fb){
    fb.style.visibility='hidden';
  }
  fb = null;
}

//se comprueba al pinchar sobre un objeto HTML si es un objetivo (su título en concreto) mirando su clase CSS es "card"
//si lo es se inicializan las tres variables definidas anteriormente:
function onMouseDown(e) {
  var object = getMouseObject(e);
  if (object.className == "bubbletitle") {
    drag  = object;
	dragType = DRAG_OBJECTIVE;
	dragText = getText(drag);
    return(false);
  }
  else if (object.parentNode && object.parentNode.className == "bubbletitle") {
    drag  = object.parentNode;
	dragType = DRAG_OBJECTIVE;
	dragText = getText(object);
    return(false);
  }
  else if (object.className == "perspective-title") {
    drag  = object;
	dragType = DRAG_PERSPECTIVE;
	dragText = getText(object);
    return(false);
  }
  else if (object.parentNode && object.parentNode.className == "bubblefootright") {
    drag  = object.parentNode.parentNode; //bubbleXX
	if(getText(object) == 'afecta a'){
      dragType = DRAG_AFFECTS;
	}
	else{
      dragType = DRAG_IS_AFFECTED;
	}
	dragText = getText(object);
    return(false);
  }
}

//se limita a liberar la referencia al objeto siendo arrastrado
function onMouseMove(e) {
  if (drag){
    if(!fb){
	  showFB(getMouseX(e),getMouseY(e),null)
	}
	moveFB(getMouseX(e),getMouseY(e));
    return false;
  }  
}
 
//para ver dón estamos arrastrando las cositas
function getPByY(y){
  var bsc = document.getElementById('bsc');
  if(bsc){
    for(var i=0; i<bsc.childNodes.length; i++){
      if(bsc.childNodes[i].className == 'perspective'){
	    y1 = getTop(bsc.childNodes[i]) + getHeight(bsc.childNodes[i]);
	    if(y < y1){
          return bsc.childNodes[i].id.substr(11);
	    }
	  }
    }
  }
  return -1;
}

function getAbsolutePByY(y){
  var bsc = document.getElementById('bsc');
  if(bsc){
    for(var i=0; i<bsc.childNodes.length; i++){
      if(bsc.childNodes[i].className == 'perspective'){
	    y1 = getTop(bsc.childNodes[i]);
	    y2 = y1 + getHeight(bsc.childNodes[i]);
	    if(y >= y1 && y < y2){
          return bsc.childNodes[i].id.substr(11);
	    }
	  }
    }
  }
  return -1;
}

function getOByX(x, p){
  var persp = document.getElementById('perspective-content' + p);
  if(persp){
    for(var i=0; i<persp.childNodes.length; i++){
      if(persp.childNodes[i].className == 'bubble'){
	    x1 = getLeft(persp.childNodes[i]) + getWidth(persp.childNodes[i]);
	    if(x < x1){
          return persp.childNodes[i].id.substr(6);
	    }
	  }
    }
  }
  return -1;
}

//se limita a liberar la referencia al objeto siendo arrastrado
function onMouseUp(e) {
  var object = getMouseObject(e);
  if (drag){
	if(dragType == DRAG_OBJECTIVE) {
      var f = document.getElementById("dnd_objective_form");
      var o = document.getElementById("dnd_obj_objective_id");
      var p = document.getElementById("dnd_obj_perspective_id");
      var b = document.getElementById("dnd_obj_before");
      o.value = drag.id.substr(11);
	  p.value = getAbsolutePByY(getMouseY(e));
	  b.value = getOByX(getMouseX(e), p.value);
	  drag = null;
	  dragType = null;
	  if(p.value && p.value != -1 && b.value && o.value != b.value){
	    f.onsubmit();
	  }
      hideFB();
      return(false);
	}
	else if(dragType == DRAG_PERSPECTIVE) {
      var f = document.getElementById("dnd_perspective_form");
      var p = document.getElementById("dnd_persp_perspective_id");
      var b = document.getElementById("dnd_persp_before");
      b.value = getPByY(getMouseY(e));
	  p.value = drag.id.substr(17);
	  drag = null;
	  dragType = null;
	  if(b.value && p.value != b.value){
	    f.onsubmit();
	  }
      hideFB();
      return(false);
	}
	else if(dragType == DRAG_AFFECTS) {
      var f = document.getElementById("dnd_affects_form");
      var affects = document.getElementById("dnd_affects");
      var is_affected = document.getElementById("dnd_is_affected");
      affects.value = drag.id.substr(6);
	  var p = getAbsolutePByY(getMouseY(e));
	  is_affected.value = getOByX(getMouseX(e), p);
	  drag = null;
	  dragType = null;
	  if(affects.value != is_affected.value){
	    f.onsubmit();
	  }
      hideFB();
      return(false);
	}
	else if(dragType == DRAG_IS_AFFECTED) {
      var f = document.getElementById("dnd_affects_form");
      var affects = document.getElementById("dnd_affects");
      var is_affected = document.getElementById("dnd_is_affected");
      is_affected.value = drag.id.substr(6);
	  var p = getAbsolutePByY(getMouseY(e));
	  affects.value = getOByX(getMouseX(e), p);
	  drag = null;
	  dragType = null;
	  if(affects.value != is_affected.value){
	    f.onsubmit();
	  }
      hideFB();
      return(false);
	}
  }
}

//capturado los tres eventos de ratn
function registerDnD() {
  document.onmousedown = onMouseDown;
  document.onmousemove = onMouseMove;
  document.onmouseup  = onMouseUp;
}

registerDnD();

//bsc ajustes en popups
function makeItModal() {
  if (document.documentElement && document.documentElement.clientWidth)
  {
    theWidth = document.documentElement.clientWidth;
    theHeight = document.documentElement.clientHeight;
  }
  else if (document.body)
  {
    theWidth = document.body.clientWidth;
    theHeight = document.body.clientHeight;
  }
  else if (window.innerWidth) 
  {
    theWidth = window.innerWidth;
    theHeight = window.innerHeight;
  }

  myDiv = document.getElementById("bsc_detail_background");
  if(myDiv){
    myDiv.style.height = (theHeight - 5) + 'px';
    myDiv.style.width = (theWidth - 5) + 'px';
  }
}

//utils
function emptySelect(id){
  mySelect = document.getElementById(id);
  if(mySelect && mySelect.options){
    mySelect.options.length = 0;
  }
  mySelect.options[0] = new Option('', '');
}

//Upload de fichero
function handleResponse(documentObject,stringToEvaluate) {
	window.eval(stringToEvaluate);
}
