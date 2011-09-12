/*
	HiSlope toolkit copyright (c) 2008-2011 Tomek 'Og2t' Augustyn
	http://play.blog2t.net/HiSlope

	You are free to use this source code in any non-commercial project. 
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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;

	import hislope.core.FilterChain;
	import hislope.filters.FilterBase;

	import hislope.display.MetaBitmapData;

	import hislope.filters.generators.Starburst;
	import hislope.filters.inputs.WebCam;
	import hislope.filters.motion.BackDropRemoval;
	import hislope.filters.motion.MotionCapture;

	import hislope.gui.Output;
	import hislope.events.HiSlopeEvent;
	
	// CLASS //////////////////////////////////////////////////////////////////////////////////

	[SWF(width='1200', height='600', frameRate='60', backgroundColor='0x181818')]
	public class DoubleChain extends Sprite
	{
		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var processedBmpData:MetaBitmapData;
		private var fxBmpData:MetaBitmapData;
		
		private var mergedBmpData:BitmapData;

		private var filterChain:FilterChain;
		private var fxChain:FilterChain;
		
		private var starburst:Starburst;
		private var counter:Number;

		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function DoubleChain() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

			FilterBase.stage = stage;

			filterChain = new FilterChain("Backdrop Removal", 320, 240, true);
			addChild(filterChain);
			filterChain.x = filterChain.width + 10;

			var input:WebCam = new WebCam();
			/*input.addEventListener(HiSlopeEvent.INPUT_RENDERED, render, false, 0, true);*/
			
			filterChain.addFilter(input, true, false, false);
			filterChain.addFilter(new BackDropRemoval());

			fxChain = new FilterChain("Starburst", 320, 240, true);
			addChild(fxChain);

			fxBmpData = new MetaBitmapData(FilterBase.WIDTH, FilterBase.HEIGHT, true, 0);
			processedBmpData = fxBmpData.cloneAsMeta();
			mergedBmpData = fxBmpData.clone();

			var fxOutput:Bitmap = new Bitmap(fxBmpData);
			addChild(fxOutput);
			fxOutput.x = 640 + 40;

			starburst = new Starburst({fps: 60.000, period: 4.000, twist: 0.752, fill: 0.350, rotationSpeed: 0.320, centerX: 160.000, centerY: 120.000, foreground: 0x48B5A9, background: 0xEBA205});
			starburst.addEventListener(HiSlopeEvent.INPUT_RENDERED, render, false, 0, true);

			fxChain.addFilter(starburst, true);
			
			var output:Output = new Output(mergedBmpData);
			addChild(output);
			output.x = 640 + 40;
			
			counter = 0;
		}

		private function render(event:Event):void
		{
			stage.quality = "low";
			fxChain.process(fxBmpData);
			filterChain.process(processedBmpData);
			stage.quality = "high";
			
			mergedBmpData.draw(fxBmpData);
			mergedBmpData.draw(processedBmpData);
			
			starburst.twist = Math.sin(counter);
			counter += 0.1;
			starburst.updateParams();
		}
	}
}