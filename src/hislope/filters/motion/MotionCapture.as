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
	import hislope.filters.PaletteMap;
	import net.blog2t.util.BitmapUtils;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class MotionCapture extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Motion Capture";
		private static const PARAMETERS:Array = [
			{
				name: "sensitivity",
				label: "Sensitivity",
				current: 80,
				min: 0,
				max: 128,
				type: "int"	
			}, {
				name: "blurAmount",
				label: "Blur strength",
				current: 10,
				min: 1,
				max: 20,
				type: "number"
			}, {
				name: "blurQuality",
				label: "Blur quality",
				current: 2,
				min: 1,
				max: 3,
				type: "int"
			}, {
				name: "timeout",
				label: "Timeout",
				current: 0.25,
				min: 0.25,
				max: 10,
				type: "number"
			}, {
				name: "lockPosition",
				label: "Lock Position",
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

		private var areasBmpData:MetaBitmapData;
		private var sourceBmpData:MetaBitmapData;
		private var beforeBmpData:MetaBitmapData;
		private var outline:Shape = new Shape();
		
		private var motionRect:Rectangle = new Rectangle(100, 100, 100, 100);
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function MotionCapture(OVERRIDE:Object = null)
		{
			areasBmpData = resultMetaBmpData.getClone();
			beforeBmpData = resultMetaBmpData.getClone();
			sourceBmpData = resultMetaBmpData.getClone();
			
			init(NAME, PARAMETERS, OVERRIDE);
			
			expire(2000);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.copyTo(areasBmpData);
			
			areasBmpData.draw(beforeBmpData, null, null, BlendMode.DIFFERENCE);
			metaBmpData.copyTo(beforeBmpData);

			// make all pixels greater than just over black (0xFF111111) green (0xFF00FF00)
			areasBmpData.threshold(areasBmpData, rect, point, ">", 0xFF111111, 0xFF00FF00, 0x00FFFFFF, true);
			
			sourceBmpData.fillRect(rect, 0xFF000000);
			// cutoff all green == 7f
			sourceBmpData.threshold(areasBmpData, rect, point, "==", 0xFF00FF00, 0xFF007F00, 0x00FFFFFF, false);

			// replace with blurthreshold filter
			BitmapUtils.blur(sourceBmpData, blurAmount, blurQuality);
			sourceBmpData.threshold(sourceBmpData, rect, point, ">", 128 - sensitivity << 8, 0xffffffff, 0x0000ff00, false);

			var recta:Rectangle = sourceBmpData.getColorBoundsRect(0xFFFFFFFF, 0xffffffff, true);
			
			outline.graphics.clear();
			outline.graphics.lineStyle(1, 0xff0000, 1);
			outline.graphics.drawRect(recta.x, recta.y, recta.width, recta.height);
			
			motionRect = motionRect.union(recta);
			
			outline.graphics.lineStyle(1, 0x00ff00, 1);
			outline.graphics.drawRect(motionRect.x, motionRect.y, motionRect.width, motionRect.height);

			metaBmpData.motionRect = motionRect;
			
			BitmapUtils.copy(sourceBmpData, metaBmpData);
			sourceBmpData.draw(outline);

			getPreviewFor(sourceBmpData as MetaBitmapData);
			/*getPreviewFor(areasBmpData);*/
		}
		
		override public function dispose():void
		{
			areasBmpData.dispose();
			areasBmpData = null;
			beforeBmpData.dispose();
			beforeBmpData = null;
			
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

		override public function updateParams():void
		{
		}

		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}