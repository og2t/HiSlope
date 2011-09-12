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
	import hislope.filters.color.HSBC;
	import hislope.filters.displace.FaceGoo;
	
	import hislope.gui.Output;
	
	import hislope.filters.brf.BRFPointTracker;
	import hislope.filters.services.FaceAPIDetect;

	import hislope.vo.faceapi.FaceFeatures;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	[SWF(width='1024', height='768', frameRate='60', backgroundColor='0x181818')]
	public class PointTrackerDemo extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var filterChain:FilterChain;
		private var processedBmpData:MetaBitmapData;
		private var output1:Output;
		private var output2:Output;

		private var input:*;

		private var pointTracker:BRFPointTracker;
		private var faceAPIDetect:FaceAPIDetect;
		
		private var faceGoo:FaceGoo;
		private var hsbc:HSBC;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function PointTrackerDemo() 
		{
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			
			var hiSlopeLogo:HiSlopeLogo = new HiSlopeLogo();
			addChild(hiSlopeLogo);
			hiSlopeLogo.setPosition(600, 26);
			
			FilterBase.stage = stage;

			filterChain = new FilterChain("Point Tracker", 640 / 2, 480 / 2);
			addChild(filterChain);
			filterChain.x = 0;
			
			processedBmpData = new MetaBitmapData();
			
			pointTracker = new BRFPointTracker();
			faceAPIDetect = new FaceAPIDetect();
			faceAPIDetect.addEventListener(FaceAPIDetect.FEATURES_DETECTED, featuresDetected, false, 0, true);

			input = new WebCam();
			/*input = new VideoPlayer();*/
			/*input.addVideo("videos/black_or_white_sequence.mov", "B&W Video");*/
			/*input.addVideo("videos/squint.mov", "Squint");*/
			/*input.addVideo("videos/face_gestures.mov", "Face Fun");*/
			/*input.addVideo("videos/eye_track_b1.mov", "Eye Tracking");*/
			input.addEventListener(HiSlopeEvent.INPUT_RENDERED, render);

			// stack filters
			filterChain.addFilter(input, true, false, false);
			filterChain.addFilter(faceAPIDetect, true);
			/*filterChain.addFilter(new HSBC({hue: 0.000, saturation: -100.000, brightness: 31.000, contrast: 100.000}), false, false, false, false);*/
			faceGoo = new FaceGoo();
			hsbc = new HSBC();
			
			filterChain.addFilter(pointTracker, true);
			filterChain.addFilter(faceGoo);
			filterChain.addFilter(hsbc, true, false, false);
			
			output1 = new Output(processedBmpData, "output");
			output2 = new Output(pointTracker, "pointTracker");
			/*output = new Output(faceAPIDetect, "faceAPIDetect");*/
			addChild(output1);
			addChild(output2);
			output1.scale = 2.0;
			
			output1.x = filterChain.width + filterChain.x + 10;
			output2.x = output1.x + output1.width + 10;
			output1.y = output2.y = 120;
		}
		
		
		private function render(event:Event):void
		{
			filterChain.process(processedBmpData);
		}
		
		
		private function gooify():void
		{
			TweenLite.to(faceGoo, 4,
			{
				scale: 127,
				onUpdate: faceGoo.updatePanelUI,
				ease: Sine.easeInOut
			});
			
			TweenLite.to(hsbc, 4,
			{
				hue: 147,
				saturation: 25,
				brightness: 20,
				contrast: 20,
				onUpdate: hsbc.updatePanelUI,
				ease: Sine.easeInOut
			});
		}
		
		
		private function featuresDetected(event:Event):void
		{
			var faceFeatures:FaceFeatures = faceAPIDetect.faceFeatures[0];
			
			pointTracker.clearPoints();
			pointTracker.addTrackingPoint(faceFeatures.eye_left);
			pointTracker.addTrackingPoint(faceFeatures.eye_right);
			pointTracker.addTrackingPoint(faceFeatures.nose);
			pointTracker.addTrackingPoint(faceFeatures.mouth_right);
			pointTracker.addTrackingPoint(faceFeatures.mouth_center);
			pointTracker.addTrackingPoint(faceFeatures.mouth_left);
			pointTracker.addTrackingPoint(faceFeatures.mouth_midleft);
			pointTracker.addTrackingPoint(faceFeatures.mouth_midright);
			
			gooify();
		}
	}
}