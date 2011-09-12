/*---------------------------------------------------------------------------------------------

	[AS3] BRFPointTracker
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
	v0.1	Born on 09/07/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters.brf
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.Event;

	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;
	import hislope.geom.FeaturePoint;
	
	import com.beyondrealityface.pointtracking.BRFPointTrackingManager;
	import com.beyondrealityface.pointtracking.IBRFPointTracking;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class BRFPointTracker extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		public static const INFO:String = "Click the preview to add tracking points.<br/>Use addFeaturePoint(point:FeaturePoint) to add points manually.";
		
		private static const NAME:String = "BRF Point Tracker";
		private static const PARAMETERS:Array = [
			/*{
				name: "patchSizeEachSide",
				current: 10,
				min: 1,
				max: 10,
				type: "int"
			}, {
				name: "level",
				current: 3,
				min: 0,
				max: 3,
				type: "int"
			}, {
				name: "maxIterations",
				current: 50,
				min: 10,
				max: 50,
				type: "int"
			}, {
				name: "trackingEnabled",
				type: "boolean",
				current: true
			}, */{
				type: "button",
				label: "clear points",
				callback: "clearPoints"
			}/*, {
				type: "button",
				label: "refresh tracker",
				callback: "initPointTracking"
			}*/
		];
		
		private static const DEBUG_VARS:Array = [
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var scaleFactor:Number = 1;
	
		private var pointTrackingManager:IBRFPointTracking;
		private var _tmpVector:Vector.<Point> = new Vector.<Point>();
		private var points:Vector.<Point> = new Vector.<Point>();
		
		private var canvasShape:Shape = new Shape();
		private const canvas:Graphics = canvasShape.graphics;

		private var sourceBmpData:BitmapData;
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var patchSizeEachSide:int = 10;
		public var level:int = 3;
		public var maxIterations:int = 50;
		public var trackingEnabled:Boolean = true;
		
		public const epsilonSquare:Number = 0.0006;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function BRFPointTracker(OVERRIDE:Object = null)
		{
			sourceBmpData = resultMetaBmpData.clone();

			initPointTracking();
			
			init(NAME, PARAMETERS, OVERRIDE, DEBUG_VARS);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			sourceBmpData.draw(metaBmpData);
			
			if (points.length > 0)
			{
				pointTrackingManager.update();
				
				checkPoints();
				drawPoints();
				
				metaBmpData.trackedPoints = points;
			}
			
			sourceBmpData.draw(canvasShape);
			
			postPreview(sourceBmpData);
		}
		
		
		public function clearPoints(event:Event = null):void
		{
			points.length = 0;
			canvas.clear();
		}
		
		
		override public function mouseDownPoint(normPoint:Point):void
		{
			addNormPoint(normPoint);
		}

		
		public function addNormPoint(normPoint:Point):void
		{
			addTrackingPoint(new Point(normPoint.x * width, normPoint.y * height));
		}
		
		
		public function addTrackingPoint(point:Point, id:String = ""):void
		{
			if (id != "")
			{
				var featurePoint:FeaturePoint = new FeaturePoint(point.x, point.y, id);
				points.push(featurePoint);
			} else {
				points.push(point);
			}

			// you can pause the analysis by passing false
			// but keep in mind, that by pausing the algorithm 
			// may not be able to track the points if they moved on the image
			pointTrackingManager.setTrackingEnabled(trackingEnabled);

			if (points.length == 1)
			{
				pointTrackingManager.prepareBitmapData();
			}
		}
		
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		public function initPointTracking():void
		{
			if (!stage) throw new Error("BRFPointTracker requires access to the stage. Use FilterBase.stage = stage; before instantiating.")
			
			pointTrackingManager = new BRFPointTrackingManager();
			pointTrackingManager.addEventListener(Event.INIT, onInitPointTracking);
		}


		private function checkPoints():void
		{
			// helper vector
			var tmpPoints:Vector.<Point> = _tmpVector;
			// point states
			var pointStates:Vector.<Boolean> = pointTrackingManager.getPointStates();
			// old helper vector length
			var lt:int = tmpPoints.length;
			// current point vector length
			var l:int = points.length;
			
			var i:int = -1;
			var k:int = 0;
			var point:Point;

			while (++i < l)
			{
				point = points[i];
				
				if (
					// maybe you want to check against boundaries
					(point.x > 5 && point.x < width - 5 && point.y > 5 && point.y < height - 5) && 
					//or you just let optical flow tell you, which points were not trackable
					pointStates[i]
				){
					// store point for future use
					tmpPoints[k++] = point;	
				}
			}	
			
			// we don't need the rest of the helper vector, so delete it
			tmpPoints.splice(k, lt - k);
			
			// empty the point vector before refill
			points.length = 0;
			l = tmpPoints.length;
			i = -1;
			
			// fill the point vector for the next round
			while (++i < l)
			{
				points[i] = tmpPoints[i];
			}
		}


		private function drawPoints():void
		{
			const numPoints:int = points.length;
			var i:int = -1;
			var point:Point;

			canvas.clear();

			while (++i < numPoints)
			{
				point = points[i];
				canvas.beginFill(0xff0000);
				canvas.drawCircle(point.x * scaleFactor, point.y * scaleFactor, 2 * scaleFactor);
				canvas.endFill();
			}
		}

		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		private function onInitPointTracking(event:Event = null):void
		{
			pointTrackingManager.removeEventListener(Event.INIT, onInitPointTracking);
			pointTrackingManager.init(sourceBmpData, stage, points, patchSizeEachSide, level, maxIterations, epsilonSquare);
			pointTrackingManager.setLogoPostition(320 + 20, 0);
		}
		
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}