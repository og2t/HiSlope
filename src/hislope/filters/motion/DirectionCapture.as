/*---------------------------------------------------------------------------------------------

	[AS3] Direction Capture
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
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.filters.ColorMatrixFilter;
	import hislope.filters.FilterBase;
	import hislope.util.PaletteMap;
	import hislope.filters.basic.Posterize;
	import net.blog2t.util.BitmapUtils;
	import flash.geom.Rectangle;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class DirectionCapture extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Direction Capture";
		private static const PARAMETERS:Array = [
			{
				name: "amount",
				label: "Blur strength",
				current: 1,
				min: 1,
				max: 20,
				type: "number"
			}, {
				name: "quality",
				label: "Blur quality",
				current: 1,
				min: 1,
				max: 3,
				type: "stepper"
			}, {
				name: "enablePosterize",
				current: false
			}
		];

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var amount:Number;
		public var quality:int;
		public var enablePosterize:Boolean;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var previousBmpData:BitmapData;
		private var posterize:Posterize;
		private var outline:Shape = new Shape();
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function DirectionCapture(OVERRIDE:Object = null)
		{
			posterize = new Posterize();
			posterize.levels = 2;
			
			previousBmpData = resultMetaBmpData.clone();
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			/*var comparsion:Object = previousBmpData.compare(metaBmpData) as BitmapData;*/
			var comparsion:Object = metaBmpData.compare(previousBmpData) as BitmapData;
			if (comparsion == null) return;

			metaBmpData.copyTo(previousBmpData);
			if (comparsion != 0) metaBmpData.copyPixels(comparsion as BitmapData, rect, point);

			BitmapUtils.desaturate(metaBmpData);
			
			if (amount > 1)
			{
				BitmapUtils.blur(metaBmpData, amount, quality);
				
				if (enablePosterize)
				{
					posterize.process(metaBmpData);
				}
			}

			// experimental
			/*var recta:Rectangle = metaBmpData.getColorBoundsRect(0xFFFFFFFF, 0xffffffff, true);
			var rectb:Rectangle = metaBmpData.getColorBoundsRect(0xFFFFFFFF, 0xff000000, true);
			outline.graphics.clear();
			outline.graphics.lineStyle(1, 0xff0000, 1);
			outline.graphics.drawRect(recta.x, recta.y, recta.width, recta.height);
			outline.graphics.lineStyle(1, 0x00ff00, 1);
			outline.graphics.drawRect(rectb.x, rectb.y, rectb.width, rectb.height);
			metaBmpData.draw(outline);*/
			
			//metaBmpData.threshold(metaBmpData, rect, point, ">", 0x0001000, 0xffffffff, 0x0000ff00, false);

			postPreview(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}