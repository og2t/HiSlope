/*---------------------------------------------------------------------------------------------

	[AS3] Blur
	=======================================================================================

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
				label: "quality",
				current: 2,
				min: 1,
				max: 3,
				type: "int"
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
			
			getPreviewFor(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		override public function updateParams():void
		{
			blurFilter.blurX = blurFilter.blurY = amount;
			blurFilter.quality = quality;
		}

		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}