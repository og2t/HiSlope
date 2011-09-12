/*---------------------------------------------------------------------------------------------

	[AS3] MotionCapture
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

package hislope.filters.motion
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.BlendMode;
	import flash.filters.ColorMatrixFilter;
	import hislope.filters.IFilter;
	import hislope.filters.FilterBase;
	import hislope.util.PaletteMap;
	import net.blog2t.util.BitmapUtils;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class MotionCapture extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Motion Capture";
		private static const INFO:String = "Tracks motion and adds motionRect and motionAreasBmpData to metaBmpData";
		
		private static const PARAMETERS:Array = [
			{
				name: "sensitivity",
				current: 122,
				min: 0,
				max: 128,
				type: "int"	
			}, {
				name: "blurAmount",
				current: 10,
				min: 1,
				max: 20,
				type: "number"
			}, {
				name: "blurQuality",
				current: 2,
				min: 1,
				max: 3,
				type: "stepper"
			}, {
				name: "timeout",
				current: 0.25,
				min: 0.25,
				max: 10,
				type: "number"
			}, {
				name: "lockPosition",
				current: false,
				type: "boolean"
			}
		];

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var blurAmount:Number;
		public var blurQuality:int;
		public var sensitivity:int;
		public var timeout:Number;
		public var lockPosition:Boolean;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var areasBmpData:BitmapData;
		private var motionBmpData:BitmapData;
		private var previousBmpData:BitmapData;
		private var outline:Shape = new Shape();
		
		private var motionRect:Rectangle = new Rectangle(100, 100, 100, 100);
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function MotionCapture(OVERRIDE:Object = null)
		{
			areasBmpData = resultMetaBmpData.clone();
			previousBmpData = resultMetaBmpData.clone();
			motionBmpData = resultMetaBmpData.clone();
			
			init(NAME, PARAMETERS, OVERRIDE);
			
			expire(2000);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.copyTo(areasBmpData);
			
			// draw previousBmpData using difference
			areasBmpData.draw(previousBmpData, null, null, BlendMode.DIFFERENCE);
			
			// store current metaBmpData as previousBmpData
			metaBmpData.copyTo(previousBmpData);

			// make all pixels greater than just over black (0xFF111111) green (0xFF00FF00)
			areasBmpData.threshold(areasBmpData, rect, point, ">", 0xFF111111, 0xFF00FF00, 0x00FFFFFF, true);
			
			// clear 
			motionBmpData.fillRect(rect, 0xFF000000);
			// cutoff all green == 7f
			motionBmpData.threshold(areasBmpData, rect, point, "==", 0xFF00FF00, 0xFF007F00, 0x00FFFFFF, false);

			// TODO replace with blurthreshold filter
			BitmapUtils.blur(motionBmpData, blurAmount, blurQuality);
			motionBmpData.threshold(motionBmpData, rect, point, ">", 128 - sensitivity << 8, 0xffffffff, 0x0000ff00, false);

			var recta:Rectangle = motionBmpData.getColorBoundsRect(0xFFFFFFFF, 0xffffffff, true);
			
			outline.graphics.clear();
			outline.graphics.lineStyle(1, 0xff0000, 1);
			outline.graphics.drawRect(recta.x, recta.y, recta.width, recta.height);
			
			motionRect = motionRect.union(recta);
			
			outline.graphics.lineStyle(1, 0x00ff00, 1);
			outline.graphics.drawRect(motionRect.x, motionRect.y, motionRect.width, motionRect.height);

			// FIXME use VOs
			metaBmpData.motionRect = motionRect;
			metaBmpData.motionAreasBmpData = motionBmpData;
			
			motionBmpData.draw(outline);
			motionBmpData.draw(metaBmpData, null, null, BlendMode.SCREEN);

			postPreview(motionBmpData);
		}
		
		
		override public function dispose():void
		{
			areasBmpData.dispose();
			areasBmpData = null;
			previousBmpData.dispose();
			previousBmpData = null;
			
			super.dispose();
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		private function expire(customTimeout:int = 0):void
		{
			if (lockPosition) return;
			
			if (customTimeout > 0) setTimeout(expire, customTimeout);
			else setTimeout(expire, timeout * 1000);
			
			motionRect.setEmpty();
		}

		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}