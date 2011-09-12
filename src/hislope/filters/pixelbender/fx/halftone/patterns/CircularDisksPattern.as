/*---------------------------------------------------------------------------------------------

	[AS3] CircularDisksPattern
	=======================================================================================

	HiSlope toolkit copyright (c) 2008-2011 Tomek 'Og2t' Augustyn
	http://play.blog2t.net/HiSlope

	You are free to use this source code in any non-commercial project. 
	You are free to modify this source code in anyway you see fit.
	You are free to distribute this source code.

	You may NOT charge anything for this source code.
	This notice and the copyright information must be left intact in any distribution of this source code. 
	You are encouraged to release any improvements back to the ActionScript community.

	VERSION HISTORY:
	v0.1	Born on 09/07/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters.pixelbender.fx.halftone.patterns
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import hislope.filters.PBFilterBase;
	import flash.geom.Matrix;
	import flash.display.Shape;
	import flash.filters.BlurFilter;
	import flash.display.BitmapData;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class CircularDisksPattern extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Circular Disks";
		private static var PARAMETERS:Array = [
			{
				name: "size",
				current: 30,
				min: 1,
				max: 100,
				type: "float"
			}, {
				name: "radius",
				current: 0.42,
				type: "float"
			}, {
				name: "blur",
				current: 10,
				min: 0,
				max: 20,
				type: "number"
			}, {
				name: "centerX",
				current: WIDTH / 2,
				min: 0,
				max: 640,
				type: "uint"
			}, {
				name: "centerY",
				current: HEIGHT / 2,
				min: 0,
				max: 480,
				type: "uint"
			}
		];
		
		private static const DEBUG_VARS:Array = [];
		
		[Embed("../../../../../pbj/fx/halftone/patterns/CircularDisks.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var rasterBmpData:BitmapData;
		private var canvas:Shape = new Shape();
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var size:Number;
		public var radius:Number;
		public var blur:Number;
		public var centerX:uint;
		public var centerY:uint;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function CircularDisksPattern(OVERRIDE:Object = null)
		{
			super(pbjFile);
			
			fullShaderPrecision();
			rasterBmpData = resultMetaBmpData.clone();
			
			init(NAME, PARAMETERS, OVERRIDE, DEBUG_VARS);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.rasterBmpData = rasterBmpData;
			
			postPreview(rasterBmpData);
		}
		
		override public function updateParams():void
		{
			shader.data.size.value = [size];
			shader.data.base.value = [centerX, centerY];
			shader.data.radius.value = [radius];
			
			canvas.graphics.clear();
			canvas.graphics.beginShaderFill(shader);
			canvas.graphics.drawRect(0, 0, rect.width, rect.height);
			
			rasterBmpData.fillRect(rasterBmpData.rect, 0x00000000);
			rasterBmpData.draw(canvas);
			
			rasterBmpData.applyFilter(rasterBmpData, rasterBmpData.rect, rasterBmpData.rect.topLeft, new BlurFilter(blur, blur, 2));
			
			super.updateParams();
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
	}
}