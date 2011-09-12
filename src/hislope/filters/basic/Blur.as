/*---------------------------------------------------------------------------------------------

	[AS3] Blur
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

	import flash.filters.BlurFilter;
	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Blur extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Blur";
		private static const PARAMETERS:Array = [
			{
				name: "amount",
				label: "strength",
				current: 5,
				min: 1,
				max: 20,
				type: "number"
			}, {
				name: "quality",
				current: 2,
				min: 1,
				max: 3,
				type: "stepper"
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var blurFilter:BlurFilter;

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var amount:Number;
		public var quality:int;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Blur(OVERRIDE:Object = null)
		{
			blurFilter = new BlurFilter(amount, amount, quality);
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.applyFilter(metaBmpData, rect, point, blurFilter);
			
			postPreview(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		override public function updateParams():void
		{
			blurFilter.blurX = blurFilter.blurY = amount;
			blurFilter.quality = quality;
			
			super.updateParams();
		}

		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}