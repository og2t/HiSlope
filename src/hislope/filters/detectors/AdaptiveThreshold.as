/*---------------------------------------------------------------------------------------------

	[AS3] AdaptiveThreshold
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

package hislope.filters.detectors
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.filters.ColorMatrixFilter;
	import hislope.filters.FilterBase;
	import hislope.util.PaletteMap;
	import net.blog2t.util.BitmapUtils;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class AdaptiveThreshold extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Adaptive Threshold";
		private static const PARAMETERS:Array = [
			{
				name: "amount",
				label: "blur strength",
				current: 16,
				min: 1,
				max: 20,
				type: "number"
			}, {
				name: "quality",
				label: "blur quality",
				current: 2,
				min: 1,
				max: 3,
				type: "stepper"
			}
		];

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var amount:Number;
		public var quality:int;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var subtractBmpData:BitmapData;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function AdaptiveThreshold(OVERRIDE:Object = null)
		{
			subtractBmpData = resultMetaBmpData.clone();
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			BitmapUtils.desaturateWeighted(metaBmpData, 0.212671, 0.715160, 0.072169);
			metaBmpData.copyTo(subtractBmpData);
			BitmapUtils.blur(subtractBmpData, amount, quality);
			metaBmpData.draw(subtractBmpData, null, null, BlendMode.SUBTRACT);
			metaBmpData.threshold(metaBmpData, rect, point, ">", 0, 0xffffffff, 0xff);

			postPreview(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}