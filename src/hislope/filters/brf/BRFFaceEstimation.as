/*---------------------------------------------------------------------------------------------

	[AS3] BRFFaceEstimation
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

package hislope.filters.brf
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;
	
	import flash.text.TextField;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.Shape;
	
	import com.tastenkunst.as3.brf.BRFStatus;
	import com.tastenkunst.as3.brf.BRFUtils;
	import com.tastenkunst.as3.brf.BeyondRealityFaceManager;
	import com.tastenkunst.as3.brf.container3d.BRFContainer3D;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class BRFFaceEstimation extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		public static const FACE_OVAL:Vector.<uint> = new <uint>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
		public static const EYE_LEFT:Vector.<uint> = new <uint>[32, 33, 34, 35, 32];
		public static const EYE_RIGHT:Vector.<uint> = new <uint>[27, 28, 29, 30, 27];
		/*public static const NOSE:Vector.<uint> = new <uint>[37, 38, 39, 40, 46, 41, 47, 42, 43, 44, 45];*/
		public static const NOSE:Vector.<uint> = new <uint>[37, 38, 39, 40, 41, 42, 43, 44, 45];
		public static const OUTER_LIP:Vector.<uint> = new <uint>[48, 59, 58, 57, 56, 55, 54, 53, 52, 51, 50, 49, 48];
		public static const INNER_LIP:Vector.<uint> = new <uint>[48, 65, 64, 63, 54, 62, 61, 60, 48];
		public static const BREW_LEFT:Vector.<uint> = new <uint>[21, 22, 23, 24, 25, 26, 21];
		public static const BREW_RIGHT:Vector.<uint> = new <uint>[15, 16, 17, 18, 19, 20, 15];
		
		private static const NAME:String = "BRF Face Est.";
		private static const PARAMETERS:Array = [
			{
				name: "showPoints",
				current: false,
				type: "boolean"
			}, {
				name: "showMesh",
				current: false,
				type: "boolean"
			}, {
				name: "estimationFace",
				current: true,
				type: "boolean"
			}, {
				name: "estimationPose",
				current: true,
				type: "boolean"
			}, {
				name: "showOnWhite",
				current: true,
				type: "boolean"
			}, {
				name: "trackingAccuracy",
				current: 0,
				min: 0,
				max: 3,
				type: "stepper"
			}
		];
		
		private static const DEBUG_VARS:Array = [
			"brfReady",
			"leftEyePoint",
			"rightEyePoint"
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		public var brfManager:BeyondRealityFaceManager;
		public var brfReady:Boolean = false;
		
		public var canvasShape:Shape = new Shape();
		public var canvas:Graphics;
		
		public var faceShapeVertices:Vector.<Number>;
		public var faceShapeTriangles:Vector.<int>;
		public var leftEyePoint:Point;
		public var rightEyePoint:Point;
		
		private var tfContainer:Sprite = new Sprite();
		private var pointsToShow:Vector.<Point>;
				
		public var container3D:BRFContainer3D;
		
		public var videoBmpData:BitmapData;
	
		// PARAMETERS /////////////////////////////////////////////////////////////////////////

		public var showPoints:Boolean;
		public var showMesh:Boolean;
		public var estimationFace:Boolean;
		public var estimationPose:Boolean;
		public var showOnWhite:Boolean;
		public var trackingAccuracy:int;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function BRFFaceEstimation(OVERRIDEN:Object = null)
		{
			initContainer3D();
			initBRF();
			
			canvas = canvasShape.graphics;
			videoBmpData = resultMetaBmpData.clone();
			
			init(NAME, PARAMETERS, OVERRIDEN, DEBUG_VARS);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			// TODO only process if frames had changed
			metaBmpData.copyTo(videoBmpData);
			
			if (brfReady)
			{
				brfManager.update();
				showResult();
				if (showOnWhite) metaBmpData.fillRect(rect, 0xFFFFFFFF);
				metaBmpData.draw(canvasShape);
				
				if (showPoints) metaBmpData.draw(tfContainer);
			}
			
			postPreview(metaBmpData);
		}
		
		
		override public function updateParams():void
		{
			if (brfReady)
			{
				/** Sets the tracking accuracy. 0 ist best, 3 is fastest. */
				brfManager.trackingAccuracy = trackingAccuracy;
				brfManager.isEstimatingPose = estimationPose;
				brfManager.isEstimatingFace = estimationFace;
			}
			
			super.updateParams();
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		/** override this function in order to use another IBRFContainer3D implementation. */
		public function initContainer3D():void
		{
			container3D = new BRFContainer3D(new Sprite());
		}


		/** Instantiates the Library and sets a listener to wait for the lib to be ready. */
		public function initBRF():void
		{
			brfManager = new BeyondRealityFaceManager();
			
			//onInitBRF();
			brfManager.addEventListener(Event.INIT, onInitBRF);
			leftEyePoint = new Point();
			rightEyePoint = new Point();
		}


		/** Initialzes the lib. Must again be waiting for the lib to be ready. */
		public function onInitBRF(event:Event = null):void
		{
			brfManager.removeEventListener(Event.INIT, onInitBRF);
			brfManager.addEventListener(BeyondRealityFaceManager.READY, onReadyBRF);
			brfManager.init(videoBmpData, container3D, stage, 1);
		}


		/** The tracking is now available. */
		public function onReadyBRF(event:Event = null):void
		{
			brfManager.setLogoPostition(320 + 20, 0);
			
			faceShapeVertices = BRFUtils.getFaceShapeVertices(brfManager.faceShape);
			faceShapeTriangles = BRFUtils.getFaceShapeTriangles();
			
			createPointTextFields();
			
			brfReady = true;
		}


		public function showResult():void
		{
			canvas.clear();
			
			canvas.lineStyle(0, 0xFF0000, 0.5);

			if (brfManager.task == BRFStatus.FACE_DETECTION)
			{
				drawLastDetectedFace(0x66ff00, 0.7, 0.5);
			}
			
			else if (brfManager.task == BRFStatus.FACE_ESTIMATION)
			{
				BRFUtils.getFaceShapeVertices(brfManager.faceShape);
				
				if (showMesh) drawMesh();
				
				drawOutline(FACE_OVAL);
				drawOutline(EYE_LEFT);
				drawOutline(EYE_RIGHT);
				drawOutline(NOSE);
				drawOutline(INNER_LIP);
				drawOutline(OUTER_LIP);
				drawOutline(BREW_RIGHT);
				drawOutline(BREW_LEFT);
			}
			
			if (showPoints) drawPoints();
		}
		
		
		private function createPointTextFields():void
		{
			pointsToShow = brfManager.faceShape.shapePoints;

			var tf:TextField;
			var i:int = 0;
			var l:int = pointsToShow.length;

			while (i < l)
			{
				tf = new TextField();
				tf.textColor = 0xFF0000;
				tf.text = i.toString();
				tf.width = tf.textWidth + 6;
				tfContainer.addChild(tf);

				i++;
			}
		}


		private function drawOutline(pointIds:Vector.<uint>):void
		{
			var i:int = 0;
			var l:int = pointIds.length;
			var point:Point;
			
			canvas.lineStyle(2, 0, 0.5);
			
			while (i < l)
			{
				point = pointsToShow[pointIds[i]];

				if (i == 0) canvas.moveTo(point.x, point.y);
				else canvas.lineTo(point.x, point.y);

				i++;
			}
			
			canvas.endFill();
		}


		private function drawPoints():void
		{
			var points:Vector.<Point> = pointsToShow;
			var point:Point;
			var tf:TextField;
			var i:int = 0;
			var l:int = tfContainer.numChildren;

			canvas.beginFill(0xb3f000);
			canvas.lineStyle(0, 0, 0);
			
			while (i < l)
			{
				point = points[i];
				canvas.drawCircle(point.x, point.y, 1);
				tf = tfContainer.getChildAt(i) as TextField;
				tf.x = point.x;
				tf.y = point.y;

				i++;
			}
			
			canvas.endFill();
		}


		/** Draws the resulting shape. */
		public function drawMesh():void
		{
			canvas.lineStyle(0, 0x000000, 0.25);
			canvas.beginFill(0x66ff00, 0.1);
			canvas.drawTriangles(faceShapeVertices, faceShapeTriangles);
			canvas.endFill();
		}


		/** Draws the last detected face. */
		public function drawLastDetectedFace(lineColor:Number = 0xff0000, lineThickness:Number = 0.5, lineAlpha:Number = 0.5):void
		{
			var rect:Rectangle = brfManager.lastDetectedFace;

			if (rect != null)
			{
				canvas.lineStyle(lineThickness, lineColor, lineAlpha);
				canvas.drawRect(rect.x, rect.y, rect.width, rect.height);

				var roi:Rectangle = brfManager.leftEyeDetectionROI;
				canvas.drawRect(roi.x, roi.y, roi.width, roi.height);
				
				roi = brfManager.rightEyeDetectionROI;
				canvas.drawRect(roi.x, roi.y, roi.width, roi.height);

				canvas.lineStyle();

				BRFUtils.estimateEyes(rect, leftEyePoint, rightEyePoint);

				if (BRFUtils.areEyesValid(leftEyePoint, rightEyePoint))
				{
					canvas.beginFill(0x12c326, 0.5);
				} else {
					canvas.beginFill(0xc32612, 0.5);
				}

				canvas.drawCircle(leftEyePoint.x, leftEyePoint.y, 5);
				canvas.drawCircle(rightEyePoint.x, rightEyePoint.y, 5);
				
				canvas.endFill();
			}
		}
	}
}