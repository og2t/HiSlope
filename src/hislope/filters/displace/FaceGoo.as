/*---------------------------------------------------------------------------------------------

	[AS3] FaceGoo
	=======================================================================================

	$Id$

	Copyright (c) 2009 Og2t.
	All Rights Reserved. Or out robots will find you ;)

	VERSION HISTORY:
	v0.1	Born on 07/07/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters.displace
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.Shape;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.BlendMode;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.geom.ColorTransform;
	import flash.utils.setTimeout;

	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;
	import net.blog2t.util.BitmapUtils;
	
	import hislope.vo.faceapi.FaceFeatures;
	
	import net.blog2t.util.print_r;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class FaceGoo extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////
		
		public static const SHRINK:String = "shrink";
		public static const GROW:String = "grow";
		public static const SMUDGE:String = "smudge";
		
		private static const NAME:String = "Face Goo";
		private static const PARAMETERS:Array = [
			{
				name: "scale",
				label: "scale",
				current: 0.0,
				min: -127,
				max: 127,
				type: "number"
			}, {
				name: "brushScale",
				label: "brush scale",
				current: 0.6,
				type: "number"
			}/*, {
				label: "clear",
				type: "button",
				callback: "clear"
			}, {
				name: "mode",
				label: "Smudge",
				type: "combo",
				current: FaceGoo.SMUDGE,
				items: [
					{
						label: "Smudge", value: FaceGoo.SMUDGE
					}, {
						label: "Grow", value: FaceGoo.GROW
					}, {
						label: "Shrink", value: FaceGoo.SHRINK
					}
				]
			}*/
		];
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		[Embed(source="../../../../assets/assets.swf", symbol="Grow")]
		private var Grow:Class;
		
		[Embed(source="../../../../assets/assets.swf", symbol="Shrink")]
		private var Shrink:Class;
		

		private var componentX:uint = BitmapDataChannel.GREEN;
		private var componentY:uint = BitmapDataChannel.BLUE;
		private var displacementFilterMode:String = DisplacementMapFilterMode.CLAMP;
		private var canvasBmpData:BitmapData;
		private var displaceBmpData:BitmapData;
		private var mergedBmpData:BitmapData;
		
		private var displacementFilter:DisplacementMapFilter;
		private var displacementAlpha:Number = 0;
		private var color:uint = 0;

		/*private var distortion:DistortImage;*/
		
		private var showGrid:Boolean = true;

		private var growBrush:Sprite = new Grow();
		private var shrinkBrush:Sprite = new Shrink();
		private var smudgeBrush:Sprite;

		private var brush:Sprite;
		private var last:Point = new Point();
		private var click:Point = new Point();
		
		private var shape:Shape = new Shape();
		
		private var blurFilter:BlurFilter = new BlurFilter(30 / 2, 30 / 2, 2);
		
		private var faceFeatures:FaceFeatures;
		
		private var mouseDown:Boolean = false;
		private var cleared:Boolean = false;
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var scale:Number;
		public var brushScale:Number;
		public var offsetX:Number;
		public var offsetY:Number;
		public var mode:String;
		public var steps:int;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////

		public function FaceGoo(OVERRIDE:Object = null) 
		{
			canvasBmpData = resultMetaBmpData.cloneAsMeta();
			displaceBmpData = resultMetaBmpData.cloneAsMeta();
			mergedBmpData = resultMetaBmpData.cloneAsMeta();

			displacementFilter = new DisplacementMapFilter(displaceBmpData, displaceBmpData.rect.topLeft, componentX, componentY, scale, scale, displacementFilterMode, color, displacementAlpha);
			
			/*distortion = new DistortImage(640, 480, 1, 1);*/
			
			smudgeBrush = buildSmudgeBrush(100);
			
			/*brush = smudgeBrush;*/
			brush = growBrush;
			
			clear();
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		override public function process(metaBmpData:MetaBitmapData):void
		{
			if (metaBmpData.faceFeatures)
			{
				// at least one face is in metaBmpData.faceFeatures
				if (metaBmpData.faceFeatures.length > 0)
				{
					// take the first face
					faceFeatures = metaBmpData.faceFeatures[0];
					drawDisplacementMap();
					
					if (cleared)
					{
						// clear features
						metaBmpData.faceFeatures = null;
						cleared = false;
					}
				}
			}
			
			metaBmpData.applyFilter(metaBmpData, rect, point, displacementFilter);
			
			/*postPreview(mergedBmpData);*/
			/*postPreview(metaBmpData);*/
			postPreview(displaceBmpData);
		}
		
		private function drawDisplacementMap():void
		{
			clear();
			
			/*halloween();*/
			/*et();*/
			sqish();
			smooth();
		}
		
		
		private function setBrush(instance:Sprite, normPoint:Point, scale:Number):void
		{
			brush = instance;
			brush.scaleX = brush.scaleY = scale;
			brush.x = normPoint.x * width;
			brush.y = normPoint.y * height;
		}
		
		
		public function grow():void
		{
			var strength:Number = 0.5;
			var colorTransform:ColorTransform = new ColorTransform(1, 1, 1, strength, 0, 0, 0, 0);
			canvasBmpData.draw(brush, brush.transform.matrix, colorTransform, BlendMode.LAYER);
		}
		
		
		public function shrink():void
		{
			var colorTransform:ColorTransform = new ColorTransform(1, 1, 1, 0.05, 0, 0, 0, 0);
			canvasBmpData.draw(brush, brush.transform.matrix, colorTransform, BlendMode.LAYER);
		}
		
		
		public function smudge():void
		{
			var greenChannel:Number = 128 + Math.min(121, -(brush.x - last.x) * 2);
			var blueChannel:Number = 128 + Math.min(121, -(brush.y - last.y) * 2);
			
			var colorTransform:ColorTransform = new ColorTransform(0, 0, 0, 1, 128, greenChannel, blueChannel, 0);
			canvasBmpData.draw(brush, brush.transform.matrix, colorTransform, BlendMode.HARDLIGHT);

			last.x = brush.x;
			last.y = brush.y;
		}
		
		
		public function clear(event:Event = null):void
		{
			displaceBmpData.fillRect(canvasBmpData.rect, 0xFF7F7F7F);
			canvasBmpData.fillRect(canvasBmpData.rect, 0xFF7F7F7F);
			
			if (event) cleared = true;
		}
		
		
		private function smooth():void
		{
			displaceBmpData.applyFilter(canvasBmpData, rect, point, blurFilter);
		}
		
		
		override public function updateParams():void
		{
			displacementFilter.scaleX = scale;
			displacementFilter.scaleY = scale;
			
			// update parameters if changed
			super.updateParams();
		}

		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		private function halloween():void
		{
			var scale:Number = faceFeatures ? faceFeatures.faceScale : 0.5;
			
			var times:int = 3;
			
			brushScale = 0.2 * scale;
			if (faceFeatures.nose) smudgePoint(times, faceFeatures.nose, -10 * scale, 40 * scale);
			if (faceFeatures.mouth_center) smudgePoint(times, faceFeatures.mouth_center, 0, -20 * scale);
			
			brushScale = 0.5 ;
			if (faceFeatures.mouth_left) smudgePoint(times, faceFeatures.mouth_left, -25 * scale, -5 * scale);
			if (faceFeatures.mouth_right) smudgePoint(times, faceFeatures.mouth_right, 25 * scale, -5 * scale);
			
			brushScale = 0.7 * scale;
			if (faceFeatures.mouth_midleft) smudgePoint(times, faceFeatures.mouth_midleft, -10 * scale, -10 * scale);
			if (faceFeatures.mouth_midright) smudgePoint(times, faceFeatures.mouth_midright, 10 * scale, -10 * scale);

			brushScale = 1.0 * scale;
			if (faceFeatures.eye_left) growPoint(1, faceFeatures.eye_left);
			if (faceFeatures.eye_right) growPoint(1, faceFeatures.eye_right);
		}

		
		private function sqish():void
		{
			var scale:Number = faceFeatures ? faceFeatures.faceScale : 0.5;
			
			brushScale = 0.2 * scale;
			if (faceFeatures.nose) smudgePoint(5, faceFeatures.nose, -10 * scale, 40 * scale);
			if (faceFeatures.mouth_center) smudgePoint(5, faceFeatures.mouth_center, 0, -20 * scale);
			
			brushScale = 0.5 ;
			if (faceFeatures.mouth_left) smudgePoint(5, faceFeatures.mouth_left, -25 * scale, -5 * scale);
			if (faceFeatures.mouth_right) smudgePoint(5, faceFeatures.mouth_right, 25 * scale, -5 * scale);
			
			brushScale = 0.7 * scale;
			if (faceFeatures.mouth_midleft) smudgePoint(5, faceFeatures.mouth_midleft, -10 * scale, -10 * scale);
			if (faceFeatures.mouth_midright) smudgePoint(5, faceFeatures.mouth_midright, 10 * scale, -10 * scale);

			brushScale = 0.8 * scale;
			if (faceFeatures.eye_left) growPoint(1, faceFeatures.eye_left);
			if (faceFeatures.eye_right) growPoint(1, faceFeatures.eye_right);
			
			/*brushScale = 1.0 * scale;
			if (faceFeatures.eye_left) smudgePoint(5, faceFeatures.eye_left, 0, -30 * scale);
			if (faceFeatures.eye_right) smudgePoint(5, faceFeatures.eye_right, 0, -30 * scale);
			if (faceFeatures.eye_left) smudgePoint(5, faceFeatures.eye_left, 0, 20 * scale);
			if (faceFeatures.eye_right) smudgePoint(5, faceFeatures.eye_right, 0, 20 * scale);*/
		}
		
		
		private function et():void
		{
			var scale:Number = faceFeatures ? faceFeatures.faceScale : 0.5;
			
			brushScale = 0.8 * scale;
			
			growPoint(2, faceFeatures.eye_left);
			smudgePoint(5, faceFeatures.eye_left, -15, 0);
			
			growPoint(2, faceFeatures.eye_right);
			smudgePoint(5, faceFeatures.eye_right, 15, 0);
		}
		
		
		private function buildSmudgeBrush(radius:Number):Sprite
		{
			var brush:Sprite = new Sprite();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(radius, radius);
			matrix.translate(-radius / 2, -radius / 2);
			matrix.scale(1.5, 1.5);
			
			brush.graphics.beginGradientFill(GradientType.RADIAL, [0x00FF00, 0xFFFFFF], [1, 0], [110, 255], matrix);
			brush.graphics.drawCircle(0, 0, radius);
			brush.graphics.endFill();
			
			return brush;
		}
		
		
		private function smudgePoint(steps:int, start:Point, stepX:Number, stepY:Number):void
		{
			mode = FaceGoo.SMUDGE;
			setBrush(smudgeBrush, point, brushScale);
			
			last = new Point(start.x, start.y);

			for (var i:int = 0; i < steps; i++)
			{
				smudgeBrush.x = start.x + (stepX / steps) * i;
				smudgeBrush.y = start.y + (stepY / steps) * i;
				smudge();
			}
		}
		
		
		private function growPoint(steps:int, point:Point):void
		{
			mode = FaceGoo.GROW;
			setBrush(growBrush, point, brushScale);

			growBrush.x = point.x;
			growBrush.y = point.y;
			
			for (var i:int = 0; i < steps; i++)
			{
				grow();
			}
		}
		
		
		private function drawBrush(point:Point):void
		{
			switch (mode)
			{
				case FaceGoo.SHRINK:
					setBrush(shrinkBrush, point, brushScale);
					shrink();
				break;

				case FaceGoo.GROW:
					setBrush(growBrush, point, brushScale);
					grow();
				break;
				
				case FaceGoo.SMUDGE:
					setBrush(smudgeBrush, point, brushScale);
					smudge();
				break;
			}
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		override public function mouseDownPoint(point:Point):void
		{
			last.x = point.x * width;
			last.y = point.y * height;
			
			click.x = point.x;
			click.y = point.y;
			
			mouseDown = true;
			
			drawBrush(point);
			smooth();
			
			trace("MOUSE DOWN", point.x, point.y);
		}
		
		override public function mouseUpPoint(point:Point):void
		{
			mouseDown = false;
			
			trace("MOUSE UP", point.x * width - click.x, point.y * height - click.y);
		}
		
		override public function mouseMovePoint(point:Point):void
		{
			if (!mouseDown) return;
			
			if (mode) trace("MOUSE MOVE", mode, point.x * width - click.x, point.y * height - click.y);

			drawBrush(point);
			
			smooth();
		}
		
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}