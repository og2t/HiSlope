/*---------------------------------------------------------------------------------------------

	[AS3] Posterize
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

	import flash.display.BitmapData;
	import hislope.filters.FilterBase;
	import hislope.filters.PaletteMap;
	import net.blog2t.util.BitmapUtils;
	import hislope.display.MetaBitmapData;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Posterize extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Posterize";
		private static const PARAMETERS:Array = [
			{
				name: "levels",
				label: "Number of levels",
				current: 16,
				min: 1,
				max: 255,
				type: "int"
			}, {
				name: "grayscale",
				label: "Desaturate",
				current: true,
				type: "boolean"
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var paletteMap:PaletteMap = new PaletteMap();

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		private var _levels:Number;
		private var _grayscale:Boolean;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Posterize(OVERRIDE:Object = null)
		{
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			if (_grayscale) BitmapUtils.desaturate(metaBmpData);
		
			metaBmpData.paletteMap(metaBmpData, rect, point, paletteMap.reds, paletteMap.greens, paletteMap.blues, paletteMap.alphas);

			getPreviewFor(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		override public function updateParams():void
		{			
			paletteMap.posterize(_levels);
		}

		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		
		public function get levels():Number
		{
			return _levels;
		}
		
		public function set levels(value:Number):void
		{
			_levels = value;
			updateParams();
		}
		
		public function get grayscale():Boolean
		{
			return _grayscale;
		}
		
		public function set grayscale(value:Boolean):void
		{
			_grayscale = value;
			updateParams();
		}
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}