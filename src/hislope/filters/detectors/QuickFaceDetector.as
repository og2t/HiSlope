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
	import flash.utils.clearTimeout;
	import hislope.filters.FilterBase;
	import net.blog2t.util.BitmapUtils;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import net.blog2t.util.RectUtils;
	
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
				label: "detect interval",
				current: 0.2,
				min: 0.05,
				max: 10,
				step: 0.05
			}, {
				name: "scaleFactor",
				label: "scale Factor",
				current: 0.3,
				min: 0.1,
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
		private var faceRect:Rectangle;
		private var scaledBmpData:MetaBitmapData;
		private var detectedFaceRects:Vector.<Rectangle>;
		private var timeoutId:int;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function QuickFaceDetector(OVERRIDE:Object = null) 
		{
			scaledBmpData = resultMetaBmpData.cloneAsMeta();
			detector = new ObjectDetector();
			
			var options:ObjectDetectorOptions = new ObjectDetectorOptions();
			options.min_size = 30;
			detector.options = options;
			detector.addEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, detectionHandler);
			detectedFaceRects = new Vector.<Rectangle>();
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function dispose():void
		{
			super.dispose();
			clearTimeout(timeoutId);
		}

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
				
				if (faceRect)
				{
					metaBmpData.faceRect = faceRect;
					metaBmpData.faceRectNorm = RectUtils.normalize(faceRect, metaBmpData);
				}
				
				metaBmpData.faceRects = detectedFaceRects;
			}

			postPreview(scaledBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		private function enableDetection():void
		{
			detectionEnabled = true;
		}

		override public function updateParams():void
		{
			detectionBmpData = new BitmapData(width * scaleFactor, height * scaleFactor, false, 0);
			drawMatrixInv = new Matrix(scaleFactor, 0, 0, scaleFactor);
			drawMatrixUp = new Matrix(1 / scaleFactor, 0, 0, 1 / scaleFactor);
			scaledBmpData.fillRect(scaledBmpData.rect, 0x000000);
			
			super.updateParams();
		}

		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////

		private function detectionHandler(event:ObjectDetectorEvent):void
		{
			var g:Graphics = faceRectContainer.graphics;
			
			g.clear();
			
			if (event.rects)
			{
				detectedFaceRects.length = 0;
				
				g.lineStyle(1, 0x00FF00, 0.5);
				event.rects.forEach(
					function (r:Rectangle, idx:int, arr:Array):void
					{
						g.drawRect(r.x, r.y, r.width, r.height);
						faceRect = new Rectangle(r.x / scaleFactor, r.y / scaleFactor, r.width / scaleFactor, r.height / scaleFactor);
						detectedFaceRects.push(faceRect);
					}
				);
			}
			
			timeoutId = setTimeout(enableDetection, interval * 1000);
		}

		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		
		public function get faceRects():Vector.<Rectangle>
		{
			return detectedFaceRects;
		}
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}