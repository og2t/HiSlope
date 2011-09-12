/*---------------------------------------------------------------------------------------------

	[AS3] Starburst
	=======================================================================================

	HiSlope toolkit copyright (c) 2010 Tomek 'Og2t' Augustyn
	http://play.blog2t.net/hislope

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
	import hislope.events.HiSlopeEvent;
	import flash.display.Shape;
	import flash.display.BitmapData;
	
	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class StarburstPattern extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Starburst Pattern";
		private static var PARAMETERS:Array = [
			{
				name: "period",
				type: "int",
				current: 5,
				min: 0,
				max: 50
			}, {
				name: "twist",
				type: "number",
				current: 0,
				min: -10,
				max: 1
			}, {
				name: "fill",
				type: "number",
				current: 0.25,
				min: 0,
				max: 1
			}, {
				name: "rotation",
				current: 0,
				min: 0,
				max: 360,
				type: "number"
			}, {
				name: "centerX",
				current: WIDTH / 2,
				max: 320,
				type: "uint"
			}, {
				name: "centerY",
				current: HEIGHT / 2,
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
				label: "randomise colors",
				callback: "randomiseColors",
				type: "button"
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		[Embed("../../../../../pbj/generators/Starburst.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		private var canvas:Shape = new Shape();
		private var rasterBmpData:BitmapData;

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var period:int;
		public var rotation:Number;
		public var centerX:Number;
		public var centerY:Number;
		public var twist:Number;
		public var fill:Number;
		public var foreground:uint;
		public var background:uint;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function StarburstPattern(OVERRIDE:Object = null)
		{
			super(pbjFile);
			
			fullShaderPrecision();
			
			rasterBmpData = resultMetaBmpData.clone();

			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.rasterBmpData = rasterBmpData;

			postPreview(rasterBmpData);
		}
		
		override public function updateParams():void
		{		
			shader.data.center.value = [centerX, centerY];
			shader.data.period.value = [period];
			shader.data.rotation.value = [rotation];
			shader.data.twist.value = [twist];
			shader.data.fill.value = [fill];
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
			
			canvas.graphics.clear();
			canvas.graphics.beginShaderFill(shader);
			canvas.graphics.drawRect(0, 0, rect.width, rect.height);
			
			canvas.graphics.clear();
			canvas.graphics.beginShaderFill(shader);
			canvas.graphics.drawRect(0, 0, rect.width, rect.height);
			
			rasterBmpData.fillRect(rasterBmpData.rect, 0x00000000);
			rasterBmpData.draw(canvas);
			
			super.updateParams();
		}

		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}