/*---------------------------------------------------------------------------------------------

	[AS3] Halftone
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

package hislope.filters.pixelbender.fx.halftone
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import hislope.filters.PBFilterBase;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class DuoHalftone extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Duo Halftone";
		private static const PARAMETERS:Array = [
			{
				name: "angle",
				label: "raster angle",
				current: 45,
				min: -45,
				max: 90,
				type: "number"
			}, {
				name: "threshold",
				label: "threshold",
				current: 0.6,
				min: 0,
				max: 0.99,
				step: 0.01,
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
			}, {
				name: "foreground",
				current: 0xFFFFFF,
				type: "rgb",
				lock: true
			}, {
				name: "background",
				current: 0x000000,
				type: "rgb",
				lock: true
			}, {
				callback: "randomiseColors",
				type: "button"
			}
		];

		[Embed("../../../../pbj/fx/halftone/DuoHalftone.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		// PARAMETERS /////////////////////////////////////////////////////////////////////////

		public var angle:Number;
		public var threshold:Number;
		public var dotSize:Number;
		public var centerX:uint;
		public var centerY:uint;
		public var foreground:uint;
		public var background:uint;
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function DuoHalftone(OVERRIDE:Object = null)
		{
			super(pbjFile);
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.applyShader(shaderFilter);

			postPreview(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		override public function updateParams():void
		{
			shader.data.rotationCenter.value = [centerX, centerY];
			shader.data.angle.value = [angle];
			shader.data.threshold.value = [threshold];
			shader.data.dotSize.value = [dotSize];
			shader.data.foreground.value = [
				(foreground >> 16) / 256.0,
				(foreground >> 8 & 0xff) / 256.0,
				(foreground & 0xff) / 256.0
			];
			shader.data.background.value = [
				(background >> 16) / 256.0,
				(background >> 8 & 0xff) / 256.0,
				(background & 0xff) / 256.0
			];
			
			super.updateParams();
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}