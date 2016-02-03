/*
	ColorMatrix Class v1.0 Demo
	
	Author: Mario Klingemann
			http://www.quasimondo.com
			mario@quasimondo.com

*/

import flash.display.*;
import flash.geom.*;
import flash.filters.*;
import com.quasimondo.geom.ColorMatrix;

var saturation:MovieClip;
var brightness:MovieClip;
var contrast:MovieClip;
var alpha:MovieClip;

var hue:MovieClip;
var threshold:MovieClip;
var enableThreshold:MovieClip;


var grid:Array=Array();

for (var y:Number=0;y<4;y++){
	for (var x:Number=0;x<4;x++){
		var n=grid.push(this["cb_"+y+""+x]);
		grid[n-1].addEventListener("click",this);
	}
	
}



saturation.addEventListener("change",this);
brightness.addEventListener("change",this);
contrast.addEventListener("change",this);
alpha.addEventListener("change",this);
hue.addEventListener("change",this);
threshold.addEventListener("change",this);
enableThreshold.addEventListener("click",this);
threshold.enabled=false;



var image_in:BitmapData = BitmapData.loadBitmap("demo");
var image:BitmapData = new BitmapData(image_in.width,image_in.height,true);

attachBitmap(image,1);


var fillMap:BitmapData = new BitmapData(10,10,false,0xffffff);
fillMap.fillRect(new Rectangle(0,0,5,5),0xcccccc);
fillMap.fillRect(new Rectangle(5,5,5,5),0xcccccc);

lineStyle();
beginBitmapFill(fillMap);
lineTo(image_in.width,0);
lineTo(image_in.width,image_in.height);
lineTo(0,image_in.height);
lineTo(0,0);
endFill();

show();



function show():Void
{
	image.draw(image_in);
	
	var mat:ColorMatrix = new ColorMatrix();

	mat.adjustHue(hue.value);
	
	mat.adjustSaturation(saturation.value/100);

	
	
	mat.adjustContrast(contrast.value/100);
    
	mat.adjustBrightness(255*brightness.value/100);
	
	mat.setAlpha(alpha.value/100);
	
	
	threshold.enabled=enableThreshold.selected;
	if(enableThreshold.selected){
		mat.threshold(threshold.value);
	}

	var cr:Number = (grid[0].selected ? 1:0) | (grid[1].selected ? 2:0) | (grid[2].selected ? 4:0) | (grid[3].selected ? 8:0);
	var cg:Number = (grid[4].selected ? 1:0) | (grid[5].selected ? 2:0) | (grid[6].selected ? 4:0) | (grid[7].selected ? 8:0);
	var cb:Number = (grid[8].selected ? 1:0) | (grid[9].selected ? 2:0) | (grid[10].selected ? 4:0) | (grid[11].selected ? 8:0);
	var ca:Number = (grid[12].selected ? 1:0) | (grid[13].selected ? 2:0) | (grid[14].selected ? 4:0) | (grid[15].selected ? 8:0);
	
	mat.setChannels(cr,cg,cb,ca);
	
	var cm:ColorMatrixFilter = new ColorMatrixFilter(mat.matrix);
	image.applyFilter(image,image.rectangle,new Point(0,0),cm);
}

function click(evt:Object):Void
{
	show();
}

function change(evt:Object):Void
{
	show();
}
