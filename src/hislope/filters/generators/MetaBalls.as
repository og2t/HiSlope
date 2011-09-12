/*---------------------------------------------------------------------------------------------

	[AS3] MetaBalls
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

	public class MetaBalls extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "MetaBalls";
		private static var PARAMETERS:Array = [
			{
				name: "fps",
				current: 60,
				min: 0.1,
				max: 60,
				type: "number",
				lock: true
			}, {
				name: "cutOffMin",
				label: "cutOff min",
				current: 0.55
			}, {
				name: "cutOffMax",
				label: "cutOff Max",
				current: 0.75
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		[Embed("../../pbj/generators/MetaBalls.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		private var canvas:Shape = new Shape();
		
		private var timer:Timer;
		private var rotation:Number = 0;
		private var i:int = 0;

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var fps:int;
		public var cutOffMin:Number;
		public var cutOffMax:Number;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function MetaBalls(OVERRIDE:Object = null)
		{
			super(pbjFile);

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
			
			shader.data.ball1.value = [
				50 + (rect.width - 100) * (Math.sin(6 * i * PI180) + 1) / 2,
				50 + (rect.height - 100) * (Math.cos(6 * i * PI180) + 1) / 2,
				50 + 50 * (Math.cos(3 * i * PI180) + 1) / 2
			];
			
			shader.data.ball2.value = [
				50 + (rect.width - 100) * (Math.sin(3 * (i + 45) * PI180) + 1) / 2,
				50 + (rect.height - 100) * (Math.cos(3 * (i + 5) * PI180) + 1) / 2,
				50 + 50 * (Math.cos(6 * (i + 12) * PI180) + 1) / 2
			];

			shader.data.ball3.value = [
				50 + (rect.width - 100) * (Math.cos(4 * (i + 25) * PI180) + 1) / 2,
				50 + (rect.height - 100) * (Math.sin(3 * (i - 5) * PI180) + 1) / 2,
				25 + 25 * (Math.cos(2 * (i - 22) * PI180) + 1) / 2
			];
			
			shader.data.ball4.value = [
				50 + (rect.width - 100) * (Math.cos(2 * (i + 75) * PI180) + 1) / 2,
				50 + (rect.height - 100) * (Math.sin(6 * (i + 25) * PI180) + 1) / 2,
				40 + 40 * (Math.sin(2 * (i + 44) * PI180) + 1) / 2
			];

			shader.data.ball5.value = [
				50 + (rect.width - 100) * (Math.sin(1 * (i + 3) * PI180) + 1) / 2,
				50 + (rect.height - 100) * (Math.cos(1 * (i - 3) * PI180) + 1) / 2,
				50 + 50 * (Math.cos(2 * (i * 2) * PI180) + 1) / 2
			];
			
			i++;
			
			postPreview(metaBmpData);
		}
		
		override public function updateParams():void
		{		
			/*if (timer) timer.delay = int(1000 / fps);*/
			
			shader.data.cutOff.value = [cutOffMin, cutOffMax];
			
			super.updateParams();
		}
		
		override public function start():void
		{
			trace("MetaBalls start");
			timer.start();
		}
		
		override public function stop():void
		{
			trace("MetaBalls stop");
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