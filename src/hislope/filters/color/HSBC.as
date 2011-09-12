/*---------------------------------------------------------------------------------------------

	[AS3] HSBC
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
	import hislope.filters.FilterBase;
	import flash.filters.ColorMatrixFilter;
	import com.gskinner.geom.ColorMatrix;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class HSBC extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "HSBC";
		private static const PARAMETERS:Array = [
			{
				name: "hue",
				label: "hue",
				current: 0,
				min: -180,
				max: 180,
				type: "int"
			}, {
				name: "saturation",
				label: "saturation",
				current: 0,
				min: -100,
				max: 100,
				type: "int"
			}, {
				name: "brightness",
				label: "brightness",
				current: 0,
				min: -100,
				max: 100,
				type: "int"
			}, {
				name: "contrast",
				label: "contrast",
				current: 0,
				min: -100,
				max: 100,
				type: "int"
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var colorMatrix:ColorMatrix = new ColorMatrix();
		private var colorMatrixFilter:ColorMatrixFilter;

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var hue:int;
		public var saturation:int;
		public var brightness:int;
		public var contrast:int;
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function HSBC(OVERRIDE:Object = null)
		{
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.applyFilter(metaBmpData, rect, point, colorMatrixFilter);
			postPreview(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		override public function updateParams():void
		{		
			colorMatrix.reset();
			colorMatrix.adjustColor(brightness, contrast, saturation, hue);
			colorMatrixFilter = new ColorMatrixFilter(colorMatrix);
			
			super.updateParams();
		}
		
		/*var a: int = img.getAvgValue();
		img.adjustBrightness( Math.exp( (0×80 - a) / 0×80 ) * 0×10 );
		img.adjustContrast( Math.exp( (0×80 - a) / 0×80 ) );*/
	}
}