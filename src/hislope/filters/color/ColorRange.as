/*---------------------------------------------------------------------------------------------

	[AS3] ColorRange
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

package hislope.filters.color
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import flash.events.Event;
	import flash.display.BitmapData;
	import net.blog2t.util.ColorUtils;
	import net.blog2t.util.BitmapUtils;
	import hislope.filters.FilterBase;
	import flash.utils.ByteArray;
	import flash.geom.Rectangle;
	import flash.filters.BlurFilter;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class ColorRange extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Color Range";
		private static const PARAMETERS:Array = [
			{
				name: "blur",
				label: "blur",
				current: 7.0,
				min: 1,
				max: 20,
				type: "number"
			}, {
				name: "fuziness",
				label: "fuziness",
				current: 0.5,
				min: 0,
				max: 1,
				type: "number"
			}, {
				name: "sample",
				label: "sample colour",
				current: 0x0,
				type: "rgb"
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var rmin:uint;
		private var gmin:uint;
		private var bmin:uint;
		
		private var rmax:uint;
		private var gmax:uint;
        private var bmax:uint;

		private var rgbMin:uint;
        private var rgbMax:uint;

		private var sourceBmpData:MetaBitmapData;
		private var activeBmpData:BitmapData;
		private var activePixels:ByteArray;

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var sample:uint;
		public var fuziness:Number;
		public var blur:Number;
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function ColorRange(OVERRIDE:Object = null)
		{
			activeBmpData = resultMetaBmpData.clone();
			sourceBmpData = resultMetaBmpData.getClone();
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			/*if (metaBmpData.activeRect)
				{
					//metaBmpData.copyTo(sourceBmpData);
					activePixels = metaBmpData.getPixels(metaBmpData.activeRect);
					activePixels.position = 0;
					metaBmpData.fillRect(new Rectangle(0, 0, metaBmpData.width, metaBmpData.height), 0x7f0000);
					metaBmpData.setPixels(metaBmpData.activeRect, activePixels);
					restrictToRegion(metaBmpData);
				} else {
					//copy metaBmpData to activeBmpData
				}*/

			/*BitmapUtils.blur(metaBmpData, blur);*/
			/*metaBmpData.blur(blur);*/
			metaBmpData.applyFilter(metaBmpData, rect, point, new BlurFilter(blur, blur, 2));
			
			/*activeBmpData.lock();
			activeBmpData.threshold(activeBmpData, rect, point, "<", rmin << 16, 0, 0x00ff0000, true);
			activeBmpData.threshold(activeBmpData, rect, point, "<", gmin << 8, 0, 0x0000ff00, true);
			activeBmpData.threshold(activeBmpData, rect, point, "<", bmin, 0, 0x000000ff, true);
			activeBmpData.threshold(activeBmpData, rect, point, ">", rmax << 16, 0, 0x00ff0000, true);
			activeBmpData.threshold(activeBmpData, rect, point, ">", gmax << 8, 0, 0x0000ff00, true);
			activeBmpData.threshold(activeBmpData, rect, point, ">", bmax, 0, 0x000000ff, true);
			activeBmpData.threshold(activeBmpData, rect, point, "==", 0xff000000, 0xffffffff, 0xff000000, true);
			activeBmpData.unlock();*/

			metaBmpData.lock();
			metaBmpData.threshold(metaBmpData, rect, point, "<", rmin << 16, 0, 0x00ff0000, true);
			metaBmpData.threshold(metaBmpData, rect, point, "<", gmin << 8, 0, 0x0000ff00, true);
			metaBmpData.threshold(metaBmpData, rect, point, "<", bmin, 0, 0x000000ff, true);
			metaBmpData.threshold(metaBmpData, rect, point, ">", rmax << 16, 0, 0x00ff0000, true);
			metaBmpData.threshold(metaBmpData, rect, point, ">", gmax << 8, 0, 0x0000ff00, true);
			metaBmpData.threshold(metaBmpData, rect, point, ">", bmax, 0, 0x000000ff, true);
			metaBmpData.threshold(metaBmpData, rect, point, "==", 0xff000000, 0xffffffff, 0xff000000, true);
			metaBmpData.unlock();

			//sourceBmpData.copyPixels(activeBmpData, metaBmpData.activeRect, metaBmpData.activeRect.topLeft);

			getPreviewFor(metaBmpData);
			/*getPreviewFor(sourceBmpData as MetaBitmapData);*/
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		override public function updateParams():void
		{		
			rgbMin = ColorUtils.brighten(sample, -fuziness);
			rgbMax = ColorUtils.brighten(sample, fuziness);

			rmin = (rgbMin >> 16) & 0xff;
			gmin = (rgbMin >> 8) & 0xff;
			bmin = rgbMin  & 0xff;

			rmax = (rgbMax >> 16) & 0xff;
			gmax = (rgbMax >> 8) & 0xff;
			bmax = rgbMax  & 0xff;
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}