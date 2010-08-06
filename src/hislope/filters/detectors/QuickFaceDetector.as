/*---------------------------------------------------------------------------------------------

	[AS3] QuickFaceDetector
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
	v0.1	Born on 09/07/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters.detectors
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.utils.setTimeout;
	import hislope.filters.FilterBase;
	import net.blog2t.util.BitmapUtils;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	
	import jp.maaash.ObjectDetection.ObjectDetector;
	import jp.maaash.ObjectDetection.ObjectDetectorEvent;
	import jp.maaash.ObjectDetection.ObjectDetectorOptions;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class QuickFaceDetector extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Face Detector";
		private static const PARAMETERS:Array = [
			{
				name: "interval",
				label: "time interval",
				current: 1.0,
				min: 0.1,
				max: 10,
				type: "number",
				step: 0.25
			}, {
				name: "scaleFactor",
				label: "scale Factor",
				current: 3.0,
				min: 1,
				max: 10,
				type: "number",
				step: 0.1
			}
		];

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var interval:Number;
		public var scaleFactor:Number;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var detector:ObjectDetector;
		private var options:ObjectDetectorOptions;
		private var faceRectContainer:Sprite = new Sprite();
		private var detectionBmpData:BitmapData;
		private var detectionEnabled:Boolean = true;
		private var drawMatrixInv:Matrix;
		private var drawMatrixUp:Matrix;
		private var motionRect:Rectangle;
		private var scaledBmpData:MetaBitmapData;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function QuickFaceDetector(OVERRIDE:Object = null) 
		{
			scaledBmpData = resultMetaBmpData.getClone();
			detector = new ObjectDetector();
			var options:ObjectDetectorOptions = new ObjectDetectorOptions();
			options.min_size = 30;
			detector.options = options;
			detector.addEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, detectionHandler);
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			if (detectionEnabled)
			{
				detectionBmpData.draw(metaBmpData, drawMatrixInv, null, "normal", null, true);
				detector.detect(detectionBmpData);
				detectionEnabled = false;
				scaledBmpData.draw(detectionBmpData);
				scaledBmpData.draw(faceRectContainer);
				metaBmpData.faceDetected = true;
				//motionRect.height -= 30;
				metaBmpData.activeRect = motionRect;
			}

			getPreviewFor(scaledBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		private function detectionHandler(e:ObjectDetectorEvent):void
		{
			var g:Graphics = faceRectContainer.graphics;
			
			g.clear();
			
			if (e.rects)
			{
				g.lineStyle(1, 0x00ff00, 0.5);
				e.rects.forEach(
					function(r:Rectangle, idx:int, arr:Array):void
					{
						g.drawRect(r.x, r.y, r.width, r.height);
						motionRect = new Rectangle(r.x * scaleFactor, r.y * scaleFactor, r.width * scaleFactor, r.height * scaleFactor);
					}
				);
			}
			
			setTimeout(enableDetection, interval * 1000);
		}

		private function enableDetection():void
		{
			detectionEnabled = true;
		}

		override public function updateParams():void
		{
			detectionBmpData = new BitmapData(width / scaleFactor, height / scaleFactor, false, 0);
			drawMatrixInv = new Matrix(1 / scaleFactor, 0, 0, 1 / scaleFactor);
			drawMatrixUp = new Matrix(scaleFactor, 0, 0, scaleFactor);
			scaledBmpData.fillRect(scaledBmpData.rect, 0x000000);
		}

		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}