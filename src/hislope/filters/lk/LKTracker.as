/*---------------------------------------------------------------------------------------------

	[AS3] LKTracker
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

package hislope.filters.lk
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.utils.Endian;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.BlurFilter;

	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;
	import hislope.geom.FeaturePoint;
	
	import apparat.asm.__cint;
	import apparat.math.FastMath;
	import apparat.memory.Memory;
	
	import ru.inspirit.pyrFlowLK.TrackPoint;
	import ru.inspirit.image.klt.KLTracker;
	import ru.inspirit.image.mem.MemImageMacro;
	import ru.inspirit.image.mem.MemImageUChar;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class LKTracker extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		public static const INFO:String = "Click the preview to add tracking points.<br/>Use addFeaturePoint(point:FeaturePoint) to add points manually.";
		
		private static const NAME:String = "LKTracker";
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
	
		private var canvasShape:Shape = new Shape();
		private const canvas:Graphics = canvasShape.graphics;

		private var buffBmpData:BitmapData;
		
		public static const GRAYSCALE_MATRIX:ColorMatrixFilter = new ColorMatrixFilter([
                        																0, 0, 0, 0, 0,
            																			0, 0, 0, 0, 0,
            																			.2989, .587, .114, 0, 0,
            																			0, 0, 0, 0, 0
																						]);
		public const ORIGIN:Point = new Point();
		public const blur2x2:BlurFilter = new BlurFilter(2, 2, 2);
		public const blur4x4:BlurFilter = new BlurFilter(4, 4, 2);
		
        public const ram:ByteArray = new ByteArray();
        public const klt:KLTracker = new KLTracker();
        
        public var imgU640:MemImageUChar;
        public var imgU320:MemImageUChar;
        public var imgU160:MemImageUChar;
        public var imgU640_:MemImageUChar;
        public var imgU320_:MemImageUChar;
        public var imgU160_:MemImageUChar;
        
        public var trackPoints:Vector.<TrackPoint> = new Vector.<TrackPoint>();
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function LKTracker(OVERRIDE:Object = null)
		{
			buffBmpData = resultMetaBmpData.clone();

			initTracker();
			
			init(NAME, PARAMETERS, OVERRIDE, DEBUG_VARS);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			var t:int;
			
			buffBmpData.draw(metaBmpData);

			buffBmpData.applyFilter( buffBmpData, rect, point, blur2x2 );
			buffBmpData.applyFilter( buffBmpData, rect, point, GRAYSCALE_MATRIX );

			imgU640.fill( buffBmpData.getVector( buffBmpData.rect ) );
			var uptr1:int = imgU640.ptr;
			var uptr2:int = imgU320.ptr;
			var w2:int = 320;
			var h2:int = 240;
			MemImageMacro.pyrDown( uptr1, uptr2, w2, h2 );

            uptr1 = imgU160.ptr;
            w2 = 160;
            h2 = 120;
            MemImageMacro.pyrDown( uptr2, uptr1, w2, h2 );
			
			//imgU320.render(buffBmpData);
			
			var n:int = trackPoints.length;
			var newPoints:Vector.<Number> = new Vector.<Number>(n<<1);
			var prevPoints:Vector.<Number> = new Vector.<Number>(n<<1);
			var status:Vector.<int> = new Vector.<int>(n);
			var pp:TrackPoint;
			var fx:Number, fy:Number;
			for(var i:int = 0; i < n; ++i)
			{
				pp = trackPoints[i];
				prevPoints[i<<1] = pp.x;
				prevPoints[__cint((i<<1)+1)] = pp.y;

				pp.tracked = false;
			}
			
			klt.currImg = Vector.<int>([imgU640.ptr, imgU320.ptr, imgU160.ptr]);
			klt.prevImg = Vector.<int>([imgU640_.ptr, imgU320_.ptr, imgU160_.ptr]);
			
			klt.trackPoints(n, prevPoints, newPoints, status, 20, 0.01);
			
            var filterdPoints:Vector.<TrackPoint> = new Vector.<TrackPoint>();
            t = 0;
			for(i = 0; i < n; ++i)
			{
				if(status[i] == 1)
				{
					fx = newPoints[i<<1];
					fy = newPoints[__cint((i<<1)+1)];
					pp = trackPoints[i];
					pp.x = fx;
					pp.y = fy;
					pp.tracked = true;
                    filterdPoints.push(pp);
                    t++;
				}
			}
            trackPoints = filterdPoints.concat();
            n = t;

			plotPoints(trackPoints, n);
			
			// swap images
			t = imgU640.ptr;
			imgU640.ptr = imgU640_.ptr;
			imgU640_.ptr = t;
			t = imgU320.ptr;
			imgU320.ptr = imgU320_.ptr;
			imgU320_.ptr = t;
            t = imgU160.ptr;
			imgU160.ptr = imgU160_.ptr;
			imgU160_.ptr = t;
			
			
			postPreview(buffBmpData);
		}
		
		
		public function clearPoints(event:Event = null):void
		{
			trackPoints.length = 0;
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
			var n:int = trackPoints.length;
			
			trace(n);
			
			var p:*;
			var nx:Number = point.x;
			var ny:Number = point.y;
			for(var i:int = 0; i < n; ++i)
			{
				p = trackPoints[i];
				var dx:Number = p.x - nx;
				var dy:Number = p.y - ny;
				if(dx*dx + dy*dy < 100)
				{
					trackPoints.splice(i, 1);
					return;
				}
			}

			if (id != "")
			{
				p = new FeaturePoint(nx, ny, id);
			} else {
				p = new TrackPoint(nx, ny);
			}
			p.vx = p.vy = 0;
			trackPoints.push(p);
			
			trace(trackPoints.length);
		}
		
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		public function initTracker():void
		{
			if (!stage) throw new Error("LKTracker requires access to the stage. Use FilterBase.stage = stage; before instantiating.")
			
			var imgChunk1:int = 640*480;
            var imgChunk2:int = 320*240;
            var imgChunk3:int = 160*120;
			var imgChunk4:int = (640 * 480) << 2;
			var kltChunk:int = klt.calcRequiredChunkSize(21);

            ram.endian = Endian.LITTLE_ENDIAN;
			ram.length = imgChunk1*2 + imgChunk2*2 + imgChunk3*2 + imgChunk4*2 + kltChunk + 1024;
			ram.position = 0;
			Memory.select(ram);

			var offset:int = 1024;
			imgU640 = new MemImageUChar();
			imgU640.setup(offset, 640, 480);
			offset += imgChunk1;
			imgU320 = new MemImageUChar();
			imgU320.setup(offset, 320, 240);
			offset += imgChunk2;
            imgU160 = new MemImageUChar();
            imgU160.setup(offset, 160, 120);
			offset += imgChunk3;
			//
			imgU640_ = new MemImageUChar();
			imgU640_.setup(offset, 640, 480);
			offset += imgChunk1;
			imgU320_ = new MemImageUChar();
			imgU320_.setup(offset, 320, 240);
			offset += imgChunk2;
            imgU160_ = new MemImageUChar();
            imgU160_.setup(offset, 160, 120);
			offset += imgChunk3;
			//
			klt.setup( offset, 640, 480, 21 );
		}


		private function plotPoints(pts:Vector.<TrackPoint>, n:int):void
		{
			var px:int, py:int;
			var col:uint = 0x00FF00;
			
			buffBmpData.lock();

			for(var i:int = 0; i < n; ++i)
			{
				px = FastMath.rint(pts[i].x);
				py = FastMath.rint(pts[i].y);
				col = pts[i].tracked ? 0x00FF00 : 0xFF0000;
				
				buffBmpData.setPixel(px, py, col);
				buffBmpData.setPixel(px+1, py, col);
				buffBmpData.setPixel(px-1, py, col);
				buffBmpData.setPixel(px, py+1, col);
				buffBmpData.setPixel(px, py-1, col);
			}
			buffBmpData.unlock( buffBmpData.rect );
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}