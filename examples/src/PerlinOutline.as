/*---------------------------------------------------------------------------------------------

	[AS3] BlinkDetector
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

	import net.hires.util.Stats;
	
	import hislope.filters.basic.PosterizeOutline;
	import hislope.filters.generators.PerlinNoise;
	import hislope.filters.inputs.WebCam;
	import hislope.filters.inputs.VideoPlayer;
	import hislope.filters.FilterBase;
	import hislope.filters.pixelbender.Levels;
	import hislope.filters.pixelbender.fx.LittlePlanet;
	import hislope.filters.pixelbender.fx.RGBTone;
	import hislope.filters.color.ColorGrading;
	import hislope.filters.color.HSBC;

	import hislope.display.MetaBitmapData;
	import hislope.events.HiSlopeEvent;
	import hislope.core.FilterChain;
	import hislope.gui.Output;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	[SWF(width='800', height='600', frameRate='60', backgroundColor='0x181818')]
	public class PerlinOutline extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var processedBmpData:MetaBitmapData;
		private var filterChain:FilterChain;

		private var fpsRater:Stats = new Stats(true);
				
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function PerlinOutline() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			
			filterChain = new FilterChain("Perlin Outline", 320 * 1, 240 * 1, true);
			addChild(filterChain);

			processedBmpData = new MetaBitmapData(FilterBase.WIDTH, FilterBase.HEIGHT, false, 0);
			var output:Output = new Output(processedBmpData, "output");
			addChild(output);
			output.x = 320 + 30;
		
			addChild(fpsRater);
			fpsRater.x = 320 + 30;
			fpsRater.y = 240 + 10;

			/*var inputWC:WebCam = new WebCam();
			var inputVP:VideoPlayer = new VideoPlayer();
			inputVP.addVideo("videos/black_or_white.mov", "B&W Video");*/
			
			var inputPN:PerlinNoise = new PerlinNoise();
			filterChain.addFilter(inputPN, true);
			/*filterChain.addFilter(inputVP, false, false, false, false);
			filterChain.addFilter(inputWC, false, false, false, false);*/
			
			inputPN.addEventListener(HiSlopeEvent.INPUT_RENDERED, render, false, 0, true);
			/*inputVP.addEventListener(HiSlopeEvent.INPUT_RENDERED, render, false, 0, true);
			inputWC.addEventListener(HiSlopeEvent.INPUT_RENDERED, render, false, 0, true);*/
			
			/*filterChain.addFilter(new Levels(), false);*/
			filterChain.addFilter(new HSBC(), false);
			/*filterChain.addFilter(new LittlePlanet(), false, false, false, false);*/
			filterChain.addFilter(new PosterizeOutline());
			/*filterChain.addFilter(new ColorGrading());*/
			/*filterChain.addFilter(new RGBTone(), false, false, false, false);*/
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