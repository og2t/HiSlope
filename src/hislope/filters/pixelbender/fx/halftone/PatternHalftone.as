/*---------------------------------------------------------------------------------------------

	[AS3] PatternHalftone
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
	import flash.display.BitmapData;
	import hislope.filters.PBFilterBase;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class PatternHalftone extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Pattern Halftone";
		private static const PARAMETERS:Array = [
			{
				name: "threshold",
				label: "threshold",
				current: 0.6,
				min: 0,
				max: 0.99,
				step: 0.01,
				type: "number"
			}, {
				name: "r",
				current: 1
			}, {
				name: "g",
				current: 1
			}, {
				name: "b",
				current: 1
			}/*, {
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
				label: "randomise colors",
				callback: "randomiseColors",
				type: "button"
			}*/
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		[Embed("../../../../pbj/GrayscaleMix.pbj", mimeType="application/octet-stream")]
		/*[Embed("../../../../pbj/ThresholdMix.pbj", mimeType="application/octet-stream")]*/
		private const pbjFile:Class;
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////

		public var angle:Number;
		public var threshold:Number;
		public var dotSize:Number;
		public var centerX:uint;
		public var centerY:uint;
		public var r:Number;
		public var g:Number;
		public var b:Number;
		/*public var foreground:uint;*/
		/*public var background:uint;*/
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function PatternHalftone(OVERRIDE:Object = null)
		{
			super(pbjFile);

			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			if (metaBmpData.rasterBmpData)
			{
				shader.data.rasterPixel.input = metaBmpData.rasterBmpData;
			} else {
				trace("metaBmpData.rasterBmpData has to be defined in order to use with PatternHalftone");
			}
			
			shader.data.srcPixel.input = metaBmpData;
			metaBmpData.applyShader(shaderFilter);
			
			postPreview(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		override public function updateParams():void
		{
			shader.data.threshold.value = [threshold];
			
			shader.data.rgb.value = [r, g, b];
			
			/*shader.data.foreground.value = [
				(foreground >> 16) / 256.0,
				(foreground >> 8 & 0xff) / 256.0,
				(foreground & 0xff) / 256.0,
				1.0
			];
					
			shader.data.background.value = [
				(background >> 16) / 256.0,
				(background >> 8 & 0xff) / 256.0,
				(background & 0xff) / 256.0,
				0.0
			];*/
			
			super.updateParams();
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}