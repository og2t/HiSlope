/*---------------------------------------------------------------------------------------------

	[AS3] AllFilters
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
	
	import hislope.core.FilterChain;
	import hislope.display.MetaBitmapData;
	import hislope.events.HiSlopeEvent;
	import hislope.filters.FilterBase;
	
	import hislope.filters.basic.Blur;
	import hislope.filters.basic.Posterize;
	import hislope.filters.basic.PosterizeOutline;
	import hislope.filters.basic.Pixellize;
	
	import hislope.filters.color.ColorGrading;
	import hislope.filters.color.ColorRange;
	import hislope.filters.color.HSBC;
	import hislope.filters.color.Pointillize;
	
	import hislope.filters.detectors.AdaptiveThreshold;
	import hislope.filters.detectors.QuickFaceDetector;
	import hislope.filters.detectors.Sobel;
	
	import hislope.filters.displace.NoiseDitherer;
	
	import hislope.filters.generators.MetaBalls;
	import hislope.filters.generators.PerlinNoise;
	import hislope.filters.generators.Pins;
	import hislope.filters.generators.Starburst;
	
	import hislope.filters.inputs.VideoPlayer;
	import hislope.filters.inputs.WebCam;
	
	import hislope.filters.lk.LKTracker;
	
	import hislope.filters.motion.BackDropRemoval;
	import hislope.filters.motion.DirectionCapture;
	import hislope.filters.motion.MotionCapture;
	
	import hislope.filters.photo.Bloom;

	import hislope.filters.pixelbender.fx.ASCIIMii;
	import hislope.filters.pixelbender.fx.halftone.AngledBWHalftone;
	import hislope.filters.pixelbender.fx.halftone.DuoHalftone;
	import hislope.filters.pixelbender.fx.halftone.IA_Halftone;
	import hislope.filters.pixelbender.fx.halftone.PlainHalftone;
	import hislope.filters.pixelbender.fx.halftone.RandomDither;
	import hislope.filters.pixelbender.fx.halftone.RGBHalftone;
	
	import hislope.filters.pixelbender.fx.LittlePlanet;
	import hislope.filters.pixelbender.fx.OldLens;
	import hislope.filters.pixelbender.fx.Pencil;
	import hislope.filters.pixelbender.fx.Sepia;
	
	import hislope.filters.pixelbender.fx.Technicolor;
	import hislope.filters.pixelbender.fx.XProcess;
	
	import hislope.filters.pixelbender.Gamma;
	import hislope.filters.pixelbender.generators.Raytracer;
	import hislope.filters.pixelbender.Levels;

	
	import hislope.gui.Output;


	// CLASS //////////////////////////////////////////////////////////////////////////////////

	[SWF(width='1440', height='900', frameRate='60', backgroundColor='0x181818')]
	public class AllFilters extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var processedBmpData:MetaBitmapData;
		private var filterChain:FilterChain;
		private var input:*;

		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function AllFilters() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			
			filterChain = new FilterChain("All Filters", 400, 300, true);
			addChild(filterChain);

			FilterBase.stage = stage;

			processedBmpData = new MetaBitmapData(FilterBase.WIDTH, FilterBase.HEIGHT, false, 0);
			var output:Output = new Output(processedBmpData, "Output");
			addChild(output);
			output.x = filterChain.width + 10;
			/*output.scale = 2.0;*/
		
			/*var input:WebCam = new WebCam();*/

			var input:VideoPlayer = new VideoPlayer();
			input.addVideo("videos/black_or_white.mov", "B&W Video");
			
			var metaballs:MetaBalls = new MetaBalls();
			metaballs.addEventListener(HiSlopeEvent.INPUT_RENDERED, render, false, 0, true);
			filterChain.addFilter(metaballs);

			/*var pins:Pins = new Pins();
			pins.addEventListener(HiSlopeEvent.INPUT_RENDERED, render, false, 0, true);*/
			
			/*filterChain.addFilter(metaballs, true, false, true);*/
			/*filterChain.addFilter(pins, true, false, true);*/

			/*var input:PerlinNoise = new PerlinNoise();*/
			/*filterChain.addFilter(input, true);*/
			/*input.addEventListener(HiSlopeEvent.INPUT_RENDERED, render, false, 0, true);*/
			
			/*filterChain.addFilter(new AdaptiveThreshold());*/
			/*filterChain.addFilter(new Bloom());*/
			/*filterChain.addFilter(new Blur());*/
			/*filterChain.addFilter(new ColorGrading());*/
			/*filterChain.addFilter(new ColorRange());*/
			/*filterChain.addFilter(new Gamma());*/
			/*filterChain.addFilter(new HSBC());*/
			/*filterChain.addFilter(new Levels());*/
			/*filterChain.addFilter(new LittlePlanet());*/
			/*filterChain.addFilter(new OldLens());*/
			/*filterChain.addFilter(new Pointillize());*/
			/*filterChain.addFilter(new Posterize());*/
			/*filterChain.addFilter(new PosterizeOutline());*/
			/*filterChain.addFilter(new RGBHalftone());*/
			/*filterChain.addFilter(new Sepia());*/
			/*filterChain.addFilter(new ShapeDepth());*/
			/*filterChain.addFilter(new Sobel());*/
			/*filterChain.addFilter(new Technicolor());*/
			/*filterChain.addFilter(new XProcess());*/
			/*filterChain.addFilter(new QuickFaceDetector());*/
			/*filterChain.addFilter(new Pixellize());*/
			/*filterChain.addFilter(new NoiseDitherer());*/
			
			filterChain.addFilter(new Posterize(), false, false, false, false);
			filterChain.addFilter(new ColorGrading(), false, false, false, false);
			filterChain.addFilter(new Pixellize(), false, false, false, false);
			filterChain.addFilter(new NoiseDitherer(), false, false, false, false);
			
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