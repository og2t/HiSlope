/*---------------------------------------------------------------------------------------------

	[AS3] PosterizeOutlineDemo
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

	import hislope.filters.basic.PosterizeOutline;
	import hislope.filters.generators.PerlinNoise;
	import hislope.filters.inputs.WebCam;
	import hislope.filters.inputs.VideoPlayer;
	import hislope.filters.FilterBase;
	import hislope.filters.pixelbender.Levels;
	import hislope.filters.pixelbender.fx.LittlePlanet;
	import hislope.filters.pixelbender.fx.halftone.RGBHalftone;
	import hislope.filters.pixelbender.fx.halftone.DuoHalftone;
	
	import hislope.filters.color.ColorGrading;
	import hislope.filters.color.HSBC;

	import hislope.display.MetaBitmapData;
	import hislope.events.HiSlopeEvent;
	import hislope.core.FilterChain;
	import hislope.gui.Output;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	[SWF(width='1440', height='900', frameRate='60', backgroundColor='0x181818')]
	public class PosterizeOutlineDemo extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var processedBmpData:MetaBitmapData;
		private var filterChain:FilterChain;
		private var input:*;

		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function PosterizeOutlineDemo() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			
			filterChain = new FilterChain("Posterize Outline", 400, 300, true);
			addChild(filterChain);

			FilterBase.stage = stage;

			processedBmpData = new MetaBitmapData(FilterBase.WIDTH, FilterBase.HEIGHT, false, 0);
			var output:Output = new Output(processedBmpData, "Output");
			addChild(output);
			output.x = filterChain.width + 10;
		
			/*var input:WebCam = new WebCam();*/

			/*var input:VideoPlayer = new VideoPlayer();*/
			/*input.addVideo("videos/black_or_white.mov", "B&W Video");*/
			
			var input:PerlinNoise = new PerlinNoise();
			filterChain.addFilter(input, true);
			input.addEventListener(HiSlopeEvent.INPUT_RENDERED, render, false, 0, true);
			
			filterChain.addFilter(new Levels(), false);
			/*filterChain.addFilter(new HSBC(), false);*/
			filterChain.addFilter(new PosterizeOutline());
			filterChain.addFilter(new ColorGrading());
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