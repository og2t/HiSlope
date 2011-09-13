/*---------------------------------------------------------------------------------------------

	[AS3] StaticMirrorDemo
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
	v0.1	Born on 7/7/2010

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	import hislope.filters.inputs.WebCam;
	import hislope.filters.inputs.VideoPlayer;
	import hislope.filters.FilterBase;
	import hislope.filters.pixelbender.Levels
	import hislope.filters.motion.DirectionCapture;

	import hislope.display.MetaBitmapData;
	import hislope.events.HiSlopeEvent;
	import hislope.core.FilterChain;
	import hislope.gui.Output;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	[SWF(width='800', height='600', frameRate='60', backgroundColor='0x181818')]
	public class StaticMirrorDemo extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var processedBmpData:MetaBitmapData;
		private var filterChain:FilterChain;
				
		private const DEBUG:Boolean = true;
				
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function StaticMirrorDemo() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			
			const SCALE:Number = 1.4;
			filterChain = new FilterChain("Static Mirror Demo", 320 * SCALE, 240 * SCALE, DEBUG);

			processedBmpData = new MetaBitmapData(FilterBase.WIDTH, FilterBase.HEIGHT, false, 0);
			var output:Output = new Output(processedBmpData, "output", true, DEBUG);
			addChild(output);
			output.x = filterChain.width + 10;
			
			addChild(filterChain);
		
			/*var inputVP:VideoPlayer = new VideoPlayer();*/
			/*inputVP.addVideo("videos/black_or_white_sequence.mov", "B&W Full");*/
			/*inputVP.addVideo("videos/black_or_white.mov", "B&W Video");*/
			/*filterChain.addFilter(inputVP, false, false, false, false);*/
			/*inputVP.addEventListener(HiSlopeEvent.INPUT_RENDERED, render, false, 0, true);*/

			var inputWC:WebCam = new WebCam();
			filterChain.addFilter(inputWC, true);
			inputWC.addEventListener(HiSlopeEvent.INPUT_RENDERED, render, false, 0, true);
			
			filterChain.addFilter(new Levels(), false, false, false, false);
			filterChain.addFilter(new DirectionCapture());
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////

		private function render(event:Event):void
		{
			filterChain.process(processedBmpData);
		}
				
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}