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
	import hislope.filters.input.WebCam;
	import hislope.filters.basic.Blur;
	import hislope.gui.Output;
	import hislope.events.HiSlopeEvent;

	import net.hires.util.Stats;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	[SWF(width='800', height='600', frameRate='60', backgroundColor='0x333333')]
	public class HelloWorld extends Sprite
	{
		public function HelloWorld() 
		{
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			
			var filterChain:FilterChain = new FilterChain("hello world");
			addChild(filterChain);

			var processedBmpData:MetaBitmapData = new MetaBitmapData();

			var output:Output = new Output(processedBmpData, "output");
			addChild(output);
			output.x = 320 + 20;
			
			var stats:Stats = new Stats(true);
			addChild(stats);
			stats.x = 320 + 20;
			stats.y = 240 + 10;

			var input:WebCam = new WebCam();
			input.addEventListener(HiSlopeEvent.INPUT_RENDERED, render);

			filterChain.addFilter(input, true);
			filterChain.addFilter(new Blur(), true);

			function render(event:Event):void
			{
				filterChain.process(processedBmpData);
			}
		}
	}
}