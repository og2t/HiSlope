/*
	HiSlope toolkit copyright (c) 2010 Tomek 'Og2t' Augustyn
	http://play.blog2t.net/hislope

	You are free to use this source code in any project. 
	You are free to modify this source code in anyway you see fit.
	You are free to distribute this source code.

	You may NOT charge anything for this source code.
	This notice and the copyright information must be left intact in any distribution of this source code. 
	You are encouraged to release any improvements back to the ActionScript community.
*/

package
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;

	import hislope.core.FilterChain;
	import hislope.display.MetaBitmapData;
	import hislope.filters.inputs.WebCam;
	import hislope.filters.inputs.VideoPlayer;
	import hislope.filters.basic.Blur;
	import hislope.filters.color.HSBC;
	import hislope.filters.motion.MotionCapture;
	import hislope.filters.detectors.BlobDetector;
	import hislope.filters.displace.NoiseDitherer;
	import hislope.filters.pixelbender.fx.ASCIIMii;
	import hislope.filters.pixelbender.fx.halftone.AngledBWHalftone;
	import hislope.filters.pixelbender.fx.halftone.IA_Halftone;
	import hislope.filters.pixelbender.fx.halftone.DuoHalftone;
	import hislope.filters.pixelbender.fx.halftone.RGBHalftone;
	import hislope.filters.pixelbender.fx.halftone.PatternHalftone;
	import hislope.filters.pixelbender.fx.halftone.PlainHalftone;
	import hislope.filters.pixelbender.generators.Raytracer;
	import hislope.filters.generators.Starburst;
	import hislope.filters.color.Pointillize;

	import hislope.filters.pixelbender.fx.halftone.patterns.RasterPattern;
	import hislope.filters.pixelbender.fx.halftone.patterns.StripesPattern;
			/*import hislope.filters.pixelbender.fx.halftone.patterns.CircularDisksPattern;
			import hislope.filters.pixelbender.fx.halftone.patterns.StarburstPattern;*/
	import hislope.filters.pixelbender.fx.halftone.patterns.CirclesPattern;
	
	import hislope.gui.Output;
	import hislope.events.HiSlopeEvent;
	
	import com.greensock.TweenLite;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	[SWF(width='800', height='600', frameRate='60', backgroundColor='0x181818')]
	public class HalftoningDemo extends Sprite
	{
		private var counter:Number = 0;
		private var starburst:Starburst;
		
		public function HalftoningDemo() 
		{
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			
			var filterChain:FilterChain = new FilterChain("Halftoning Demo", 600, 338, true);
			addChild(filterChain);
			filterChain.x = 40;

			var processedBmpData:MetaBitmapData = new MetaBitmapData();

			var output:Output = new Output(processedBmpData, "output");
			addChild(output);
			output.x = filterChain.width + filterChain.x + 20;
			output.scale = 1.5;
			
			var input:VideoPlayer = new VideoPlayer();
			input.addVideo("videos_extra/halftone_video.mp4", "Video");
			input.addEventListener(HiSlopeEvent.INPUT_RENDERED, render);
			
			/*var input:WebCam = new WebCam();*/
			/*var input:Raytracer = new Raytracer();*/

			/*var blur:Blur = new Blur();*/

			filterChain.addFilter(input, false, false, true, false);
			
			starburst = new Starburst({fps: 60.000, period: 4.000, twist: 0.752, fill: 0.350, rotationSpeed: 0.320});
			starburst.addEventListener(HiSlopeEvent.INPUT_RENDERED, render, false, 0, true);
			filterChain.addFilter(starburst, false, false, false, false);
			
			/*filterChain.addFilter(blur, true);*/
			filterChain.addFilter(new HSBC(), false, false, false, false);
			/*filterChain.addFilter(new ASCIIMii());*/

					/*filterChain.addFilter(new CircularDisksPattern());*/
					/*filterChain.addFilter(new StarburstPattern());*/

			filterChain.addFilter(new StripesPattern(), false, false, false, false);
			filterChain.addFilter(new RasterPattern(), false, false, false, false);
			filterChain.addFilter(new CirclesPattern(), false, false, false, false);
			filterChain.addFilter(new PatternHalftone(), false, false, false, false);
			
			filterChain.addFilter(new DuoHalftone(), false, false, false, false);
			filterChain.addFilter(new RGBHalftone(), false, false, false, false);
			filterChain.addFilter(new PlainHalftone(), false, false, false, false);
			filterChain.addFilter(new AngledBWHalftone(), false, false, false, false);
			filterChain.addFilter(new IA_Halftone(), false, false, false, false);
			filterChain.addFilter(new Pointillize(), false, false, false, false);
			/*filterChain.addFilter(new NoiseDitherer());*/
			/*filterChain.addFilter(new MotionCapture());*/
			/*filterChain.addFilter(new BlobDetector());*/
			
			/*TweenLite.to(blur, 10,
			{
				onUpdate: blur.updatePanelUI,
				amount: 0
			});*/
			
			function render(event:Event):void
			{
				filterChain.process(processedBmpData);
				
				starburst.twist = Math.sin(counter);
				counter += 0.1;
				starburst.updateParams();
			}
		}
	}
}