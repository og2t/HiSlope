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

	import hislope.events.HiSlopeEvent;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	
	import hislope.core.FilterChain;
	import hislope.display.MetaBitmapData;
	import hislope.filters.inputs.WebCam;
	import hislope.filters.inputs.VideoPlayer;
	import hislope.filters.FilterBase;
	import hislope.display.HiSlopeLogo;
	
	import hislope.gui.Output;
	import hislope.filters.brf.BRFFaceEstimation;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	[SWF(width='1024', height='768', frameRate='60', backgroundColor='0x181818')]
	public class BRFFaceEstimationDemo extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var filterChain:FilterChain;
		private var processedBmpData:MetaBitmapData;
		private var output:Output;

		private var faceDetection:BRFFaceEstimation = new BRFFaceEstimation();
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function BRFFaceEstimationDemo() 
		{
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			
			var hiSlopeLogo:HiSlopeLogo = new HiSlopeLogo();
			addChild(hiSlopeLogo);
			hiSlopeLogo.setPosition(600, 26);
			
			
			FilterBase.stage = stage;
			
			filterChain = new FilterChain("Face Detection", 640 / 1, 480 / 1);
			processedBmpData = new MetaBitmapData();
			output = new Output(processedBmpData, "output");
			
			addChild(filterChain);
			addChild(output);
			output.x = 320 + 20;
			output.y = 120;
			
			var webcam:WebCam = new WebCam({scale: filterChain.width / WebCam.MAX_WIDTH});
			webcam.addEventListener(HiSlopeEvent.INPUT_RENDERED, render);

			var video:VideoPlayer = new VideoPlayer();
			video.addEventListener(HiSlopeEvent.INPUT_RENDERED, render);
			video.addVideo("videos_extra/face_gestures.mov", "Face Fun");
			
			filterChain.addFilter(video);
			filterChain.addFilter(webcam, false, false, false, false);
			
			filterChain.addFilter(faceDetection, true);
		}
		
		
		private function render(event:Event):void
		{
			filterChain.process(processedBmpData);
		}
	}
}