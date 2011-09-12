/*---------------------------------------------------------------------------------------------

	[AS3] Raytracer
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

package hislope.filters.pixelbender.generators
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import hislope.filters.PBFilterBase;
	import hislope.events.HiSlopeEvent;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.display.Shape;
	import flash.utils.Timer;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Raytracer extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Raytracer";
		private static const PARAMETERS:Array = [
			{
				name: "fps",
				current: 60,
				min: 0.1,
				max: 60,
				type: "number",
				lock: true
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		[Embed("../../../pbj/generators/Raytracer.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		private var canvas:Shape = new Shape();
		private var i:int = 0;
		private var timer:Timer;
		
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////

		public var fps:Number;
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Raytracer(OVERRIDE:Object = null)
		{
			super(pbjFile);
			
			timer = new Timer(int(1000 / fps));
			timer.addEventListener(TimerEvent.TIMER, render);

			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			shader.data.sphere1.value = [
				-.5,
				0,
				Math.cos(i * PI180) * 2 + 5
			];
			
			shader.data.sphere2.value = [
				.5,
				0,
				Math.sin(i * PI180) * 2 + 5
			];
			
			i++;
			
			canvas.graphics.clear();
			canvas.graphics.beginShaderFill(shader);
			canvas.graphics.drawRect(0, 0, rect.width, rect.height);
			metaBmpData.draw(canvas);
			
			postPreview(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		override public function updateParams():void
		{
			super.updateParams();
		}
		
		override public function start():void
		{
			trace("Pins start");
			timer.start();
		}
		
		override public function stop():void
		{
			trace("Pins stop");
			timer.stop();
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		private function render(event:TimerEvent):void
		{
			dispatchEvent(new Event(HiSlopeEvent.INPUT_RENDERED));
		}
		
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}