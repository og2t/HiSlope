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

package hislope.filters.generators
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import hislope.filters.PBFilterBase;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.geom.Point;
	import hislope.events.HiSlopeEvent;
	import flash.display.Shape;
	import flash.utils.ByteArray;
	
	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Starburst extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Starburst";
		private static var PARAMETERS:Array = [
			{
				name: "fps",
				current: 60,
				min: 0.1,
				max: 60,
				type: "number",
				lock: true
			}, {
				name: "period",
				type: "int",
				current: 5,
				min: 0,
				max: 50
			}, {
				name: "twist",
				type: "number",
				current: 0,
				min: -1,
				max: 1
			}, {
				name: "fill",
				type: "number",
				current: 0.25,
				min: 0,
				max: 1
			}, {
				name: "rotationSpeed",
				current: 0.35,
				max: 5,
				type: "number"
			}, {
				name: "centerX",
				current: 160,
				max: 320,
				type: "uint"
			}, {
				name: "centerY",
				current: 120,
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

		[Embed("../../pbj/Starburst.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		private var canvas:Shape = new Shape();
		
		private var timer:Timer;
		private var rotation:Number = 0;

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var fps:int;
		public var period:int;
		public var rotationSpeed:Number;
		public var centerX:Number;
		public var centerY:Number;
		public var twist:Number;
		public var fill:Number;
		public var foreground:uint;
		public var background:uint;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Starburst(OVERRIDE:Object = null)
		{
			super(pbjFile, PARAMETERS);

			timer = new Timer(int(1000 / fps));
			timer.addEventListener(TimerEvent.TIMER, render);
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			canvas.graphics.clear();
			canvas.graphics.beginShaderFill(shader);
			canvas.graphics.drawRect(0, 0, rect.width, rect.height);
			metaBmpData.draw(canvas);
			
			rotation += rotationSpeed;
			shader.data.rotation.value = [rotation];

			getPreviewFor(metaBmpData);
		}
		
		override public function updateParams():void
		{		
			/*if (timer) timer.delay = int(1000 / fps);*/
			
			shader.data.center.value = [centerX, centerY];
			shader.data.period.value = [period];
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
			
			super.updateParams();
		}
		
		override public function start():void
		{
			trace("Starburst start");
			timer.start();
		}
		
		override public function stop():void
		{
			trace("Starburst stop");
			timer.stop();
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		private function render(event:TimerEvent):void
		{
			dispatchEvent(new Event(HiSlopeEvent.INPUT_RENDERED));
		}
		
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}