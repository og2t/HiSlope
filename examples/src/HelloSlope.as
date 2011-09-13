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
	import hislope.filters.basic.Blur;
	import hislope.filters.color.HSBC;
	import hislope.gui.Output;
	import hislope.events.HiSlopeEvent;
	
	// CLASS //////////////////////////////////////////////////////////////////////////////////

	[SWF(width='800', height='600', frameRate='60', backgroundColor='0x181818')]
	public class HelloSlope extends Sprite
	{
		public function HelloSlope() 
		{
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			
			var filterChain:FilterChain = new FilterChain("Hello Slope!", 640 / 2, 480 / 2);
			addChild(filterChain);

			var processedBmpData:MetaBitmapData = new MetaBitmapData();

			var output:Output = new Output(processedBmpData, "output");
			addChild(output);
			output.x = filterChain.width + 10;
			
			var input:WebCam = new WebCam();
			input.addEventListener(HiSlopeEvent.INPUT_RENDERED, render);

			filterChain.addFilter(input, true);
			filterChain.addFilter(new HSBC({brightness: -43, contrast: 52}), true);
			filterChain.addFilter(new Blur({amount: 20, quality: 3}), true);
			
			function render(event:Event):void
			{
				filterChain.process(processedBmpData);
			}
		}
	}
}