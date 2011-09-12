/*---------------------------------------------------------------------------------------------

	[AS3] PosterizeOutline
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

package hislope.filters.basic
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.filters.FilterBase;
	import hislope.util.PaletteMap;
	import net.blog2t.util.BitmapUtils;
	import hislope.display.MetaBitmapData;
	import flash.filters.GlowFilter;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class PosterizeOutline extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Posterize Outline";
		private static const PARAMETERS:Array = [
			{
				name: "levels",
				label: "Number of levels",
				current: 4,
				min: 1,
				max: 8,
				type: "int"
			}, {
				name: "smoothing",
				label: "Smoothing",
				current: 4,
				min: 1,
				max: 20,
				type: "number"
			}, {
				name: "smoothOutline",
				label: "Smooth outline only",
				current: true,
				type: "boolean"
			}, {
				name: "grayscale",
				label: "Desaturate",
				current: true,
				type: "boolean"
			}, {
				name: "outlineColor",
				label: "outline color",
				current: 0x000000,
				type: "rgb"
			}
		];
		
		private const outlineFilter:GlowFilter = new GlowFilter(0xff0000, 1, 2, 2, 5, 2, false, false);
	
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var paletteMap:PaletteMap = new PaletteMap();
		private var greys:int;
		private var step:int;
		private var outlineBmpData:MetaBitmapData;
		private var linesBmpData:MetaBitmapData;

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var levels:int;
		public var grayscale:Boolean;
		public var smoothOutline:Boolean;
		public var smoothing:Number;
		public var outlineColor:uint;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function PosterizeOutline(OVERRIDE:Object = null)
		{
			outlineBmpData = new MetaBitmapData(resultMetaBmpData.width, resultMetaBmpData.height, true, 0x00000000);
			linesBmpData = new MetaBitmapData(resultMetaBmpData.width, resultMetaBmpData.height, true, 0x00000000);
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			if (!smoothOutline && smoothing > 1) BitmapUtils.blur(metaBmpData, smoothing, 3);
			
			metaBmpData.copyTo(outlineBmpData);
			
			if (grayscale) BitmapUtils.desaturate(outlineBmpData);
			
			if (smoothOutline && smoothing > 1) BitmapUtils.blur(outlineBmpData, smoothing, 3);
		
			outlineBmpData.paletteMap(outlineBmpData, rect, point, paletteMap.reds, paletteMap.greens, paletteMap.blues, paletteMap.alphas);
			
         	outlineBmpData.threshold(outlineBmpData, rect, point, ">", 0x00000000, 0x00000000, 0x00010101 * step, false);
			outlineBmpData.applyFilter(outlineBmpData, rect, point, outlineFilter);

			linesBmpData.fillRect(rect, 0x00000000);
			linesBmpData.threshold(outlineBmpData, rect, point, "==", 0xffff0000, 0xff000000 | outlineColor, 0xffffffff, false);
			
			if (grayscale) BitmapUtils.desaturate(metaBmpData);
			metaBmpData.paletteMap(metaBmpData, rect, point, paletteMap.reds, paletteMap.greens, paletteMap.blues, paletteMap.alphas);
			
			metaBmpData.copyPixels(linesBmpData, rect, point);

			postPreview(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		override public function updateParams():void
		{	
			greys = Math.pow(2, levels);
			step = (0xff + 1) / greys;
			paletteMap.discretize(greys);
			
			super.updateParams();
		}

		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}