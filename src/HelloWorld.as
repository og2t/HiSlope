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

	// CLASS //////////////////////////////////////////////////////////////////////////////////

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

			var input:WebCam = new WebCam();
			input.addEventListener(HiSlopeEvent.INPUT_RENDERED, render);

			filterChain.addFilter(input, true, false, false);
			filterChain.addFilter(new Blur(), true);

			function render(event:Event):void
			{
				filterChain.process(processedBmpData);
			}
		}
	}
}