/*---------------------------------------------------------------------------------------------

	[AS3] CamShift
	=======================================================================================

	HiSlope toolkit copyright (c) 2008-2011 Tomek 'Og2t' Augustyn
	http://play.blog2t.net/HiSlope

	You are free to use this source code in any non-commercial project. 
	You are free to modify this source code in anyway you see fit.
	You are free to distribute this source code.

	You may NOT charge anything for this source code.
	This notice and the copyright information must be left intact in any distribution of this source code. 
	You are encouraged to release any improvements back to the ActionScript community.

	VERSION HISTORY:
	v0.1	Born on 19/09/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters.detectors
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.Sprite;
	import flash.events.Event;
	import hislope.display.MetaBitmapData;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.utils.setTimeout;
	import hislope.filters.FilterBase;
	import net.blog2t.util.BitmapUtils;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.geom.Point;

	import org.libspark.faceit.camshift.Tracker;
	import org.libspark.faceit.camshift.TrackObj;
	import org.libspark.faceit.utils.bitmap.ImgData;


	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class CamShift extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		private static const NAME:String = "Camshift Detector";
		private static const PARAMETERS:Array = [
			{
				name: "scaleFactor",
				label: "scale Factor",
				current: 0.25,
				min: 0.1,
				max: 1
			}, {
				name: "stabilise",
				current: false
			}
		];
		
		private static const DEBUG_VARS:Array = [
		];
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var scaleFactor:Number;
		public var stabilise:Boolean;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var detectionBmpData:BitmapData;
		private var originalBmpData:BitmapData;
		private var scaledDownBmpData:MetaBitmapData;
		private var scaleMatrix:Matrix;
		private var stabiliseMatrix:Matrix = new Matrix();
		private var rotateMatrix:Matrix = new Matrix();
		private var _backProj:BitmapData;
		private var faceCenter:TrackObj;
		
		public var faceRotation:Number = 0;
		public var faceX:Number = 0;
		public var faceY:Number = 0;

		private var _tracker:Tracker = new Tracker();
		private var _searchWindow:Sprite = new Sprite();
		private var _trackObj:Sprite = new Sprite();
		private var cross:Sprite = new Sprite();
		private var _output:Sprite = new Sprite();
		
		private var startPoint:Point;
		private var endPoint:Point;
		private var mouseDown:Boolean = false;

		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function CamShift(OVERRIDE:Object = null) 
		{
			scaledDownBmpData = resultMetaBmpData.cloneAsMeta();
			originalBmpData = resultMetaBmpData.clone();
			_backProj = resultMetaBmpData.clone();
			
			_trackObj.addChild(cross);
			
			init(NAME, PARAMETERS, OVERRIDE, DEBUG_VARS);
		}

		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		override public function process(metaBmpData:MetaBitmapData):void
		{
			detectionBmpData.draw(metaBmpData, scaleMatrix, null, "normal", null, true);
			
			if (metaBmpData.faceRect)
			{
				if (metaBmpData.faceDetected)
				{
					metaBmpData.faceDetected = false;
					
					var zoneRect:Rectangle = new Rectangle(
						metaBmpData.faceRect.x * scaleFactor,
						metaBmpData.faceRect.y * scaleFactor,
						metaBmpData.faceRect.width * scaleFactor,
						metaBmpData.faceRect.height * scaleFactor
					);
					
					_tracker.initTracker(detectionBmpData, zoneRect, scaleFactor);
				}
				
				_tracker.track(detectionBmpData);
				drawSearchWindow();
				
				faceCenter = _tracker.getTrackObj();

				drawTrackObj();
				_backProj = _tracker.getBackProjectionBmp();
			}

			scaledDownBmpData.copyPixels(_backProj, _backProj.rect, _backProj.rect.topLeft);
			scaledDownBmpData.draw(_searchWindow);
			scaledDownBmpData.draw(_trackObj, scaleMatrix);
			
			/*stabiliseMatrix.identity();
			
			if (stabilise && faceCenter)
			{
				faceX += (faceCenter.x / scaleFactor - faceX) * 0.2;
				faceY += (faceCenter.y / scaleFactor - faceY) * 0.2;
				faceRotation += (faceCenter.angle - faceRotation) * 0.2;

				stabiliseMatrix.translate(-faceX, -faceY);
				stabiliseMatrix.rotate(-faceRotation + Math.PI / 2);
				stabiliseMatrix.translate(metaBmpData.width * scaleFactor, metaBmpData.height * scaleFactor);
			}*/

			originalBmpData.draw(_trackObj);
			/*metaBmpData.draw(metaBmpData.fullSizeBmpData, stabiliseMatrix, null, null, null, true);*/

			postPreview(scaledDownBmpData);
		}
		
		private function drawSearchWindow():void
		{
			var window:Rectangle = _tracker.getSearchWindow();

			var w:Number = window.width / scaleFactor;
			var h:Number = window.height / scaleFactor;
			var x:Number = window.x / scaleFactor;
			var y:Number = window.y / scaleFactor;
			
			with (_searchWindow.graphics)
			{
				clear();
				lineStyle(0, 0x0000FF);
				drawRect(window.x, window.y, window.width, window.height);
			}
		}
		
		private function drawTrackObj():void
		{
			var axisMin:Number = (faceCenter.width / 2) / scaleFactor;
			var axisMax:Number = (faceCenter.height / 2) / scaleFactor; 
			
			with (cross.graphics)
			{
				clear();
				lineStyle(0, 0x00FF00);
				moveTo(-axisMax, 0);
				lineTo(axisMax, 0 );
				lineStyle(0, 0xFF0000);
				moveTo(0, -axisMin);
				lineTo(0, axisMin);
			}
			
			cross.x = faceCenter.x / scaleFactor;
			cross.y = faceCenter.y / scaleFactor;
			cross.rotation = faceCenter.angle * 180 / Math.PI;
		}
		
		override public function updateParams():void
		{
			detectionBmpData = new BitmapData(width * scaleFactor, height * scaleFactor, false, 0);
			scaleMatrix = new Matrix(scaleFactor, 0, 0, scaleFactor);
			scaledDownBmpData.fillRect(scaledDownBmpData.rect, 0x000000);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		/*override public function mouseDownPoint(normPoint:Point):void
		{
			mouseDown = true;
			startPoint = getPoint(normPoint);
		}
		
		
		override public function mouseMovePoint(normPoint:Point):void
		{
			if (!mouseDown) return;
			
			endPoint = getPoint(normPoint);
			
			_trackObj.graphics.clear();
			_trackObj.graphics.lineStyle(1, 0x00ff00, 1);
			_trackObj.graphics.drawRect(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
		}
		
		
		override public function mouseUpPoint(normPoint:Point):void
		{
			mouseDown = false;
			endPoint = getPoint(normPoint);
			
			var zoneRect:Rectangle = new Rectangle(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
			_tracker.initTracker(detectionBmpData, zoneRect, scaleFactor);
		}*/
		
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
		
		public function getPoint(normPoint:Point):Point
		{
			return new Point(normPoint.x * width / scaleFactor, normPoint.y * height / scaleFactor);
		}
	}
}