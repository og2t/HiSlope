/*---------------------------------------------------------------------------------------------

	[AS3] ColorGrading
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
	import flash.display.BitmapData;
	import hislope.filters.FilterBase;
	import hislope.filters.PaletteMap;
	import net.blog2t.util.BitmapUtils;
	
	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class ColorGrading extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Color Grading";
		private static const PARAMETERS:Array = [
			{
				name: "colorStart",
				label: "color at 0x00",
				current: 0x000000,
				type: "rgb"
			}, {
				name: "colorMiddle",
				label: "color at 0x7f",
				current: 0x2F902F,
				type: "rgb"
			}, {
				name: "colorEnd",
				label: "color at 0xff",
				current: 0xFFFFFF,
				type: "rgb"
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var paletteMap:PaletteMap = new PaletteMap();

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var colorStart:uint;
		public var colorMiddle:uint;
		public var colorEnd:uint;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function ColorGrading(OVERRIDE:Object = null)
		{
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			BitmapUtils.desaturate(metaBmpData);
			metaBmpData.paletteMap(metaBmpData, rect, point, paletteMap.reds, paletteMap.greens, paletteMap.blues, paletteMap.alphas);
			
			getPreviewFor(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		override public function updateParams():void
		{			
			paletteMap.colorGrading([colorStart, colorMiddle, colorEnd], 256);
		}

		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}