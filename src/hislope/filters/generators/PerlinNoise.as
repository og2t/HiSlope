/*---------------------------------------------------------------------------------------------

	[AS3] PerlinNoise
	=======================================================================================

	HiSlope toolkit copyright (c) 2010 Tomek 'Og2t' Augustyn
	http://play.blog2t.net/hislope

	You are free to use this source code in any project. 
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
	import hislope.filters.FilterBase;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.geom.Point;
	import hislope.events.HiSlopeEvent;
	
	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class PerlinNoise extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Perlin Noise";
		private static const PARAMETERS:Array = [
			{
				name: "fps",
				label: "fps",
				current: 40,
				min: 0.1,
				max: 60,
				type: "number"
			}, {
				name: "numOctaves",
				label: "octaves",
				type: "int",
				current: 2,
				min: 1,
				max:34
			}, {
				name: "base",
				label: "base",
				current: 100,
				max: 640
			}, {
				name: "stitch",
				current: true
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var pointsArray:Array = [new Point(1, 1), new Point(3, 3), new Point(2, 2)];
		private var timer:Timer;

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var numOctaves:int;
		public var base:Number;
		public var stitch:Boolean;
		public var fps:int;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function PerlinNoise(OVERRIDE:Object = null)
		{
			init(NAME, PARAMETERS, OVERRIDE);
			
			timer = new Timer(int(1000 / fps));
			timer.addEventListener(TimerEvent.TIMER, render);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			pointsArray[0].x += 1;
			pointsArray[0].y += 1;
			pointsArray[1].x += 2;
			pointsArray[1].y += 0;
			pointsArray[2].x -= 1;
			pointsArray[2].y -= 1;
			
			metaBmpData.perlinNoise(base, base, numOctaves, 0, stitch, true, 7, true, pointsArray);
			
			postPreview(metaBmpData);
		}
		
		override public function updateParams():void
		{		
			if (timer) timer.delay = int(1000 / fps);
			
			super.updateParams();
		}
		
		override public function start():void
		{
			trace("perlinNoise start");
			timer.start();
		}
		
		override public function stop():void
		{
			trace("perlinNoise stop");
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