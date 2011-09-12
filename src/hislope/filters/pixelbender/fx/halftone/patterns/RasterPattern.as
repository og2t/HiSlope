/*---------------------------------------------------------------------------------------------

	[AS3] RasterPattern
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
	import flash.display.BitmapData;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class RasterPattern extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Raster Pattern";
		private static var PARAMETERS:Array = [
			{
				name: "angle",
				label: "raster angle",
				current: 45,
				min: -45,
				max: 90,
				type: "number"
			}, {
				name: "dotSize",
				label: "raster dot size",
				current: 2.5,
				min: 0.1,
				max: 60,
				step: 0.01,
				type: "number"
			}, {
				name: "centerX",
				label: "center rotation x",
				current: WIDTH / 2,
				min: 0,
				max: 320,
				type: "uint"
			}, {
				name: "centerY",
				label: "center rotation y",
				current: HEIGHT / 2,
				min: 0,
				max: 240,
				type: "uint"
			}
		];
		
		private static const DEBUG_VARS:Array = [];
		
		[Embed("../../../../../pbj/fx/halftone/patterns/RasterPattern.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var rasterBmpData:BitmapData;
		private var canvas:Shape = new Shape();
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var angle:Number;
		public var dotSize:Number;
		public var centerX:uint;
		public var centerY:uint;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function RasterPattern(OVERRIDE:Object = null)
		{
			super(pbjFile);
			
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
			shader.data.angle.value = [angle];
			shader.data.rotationCenter.value = [centerX, centerY];
			shader.data.dotSize.value = [dotSize];
			
			canvas.graphics.clear();
			canvas.graphics.beginShaderFill(shader);
			canvas.graphics.drawRect(0, 0, width, height);
			
			rasterBmpData.draw(canvas);
			
			super.updateParams();
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
	}
}