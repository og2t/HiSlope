/*---------------------------------------------------------------------------------------------

	[AS3] FilterName
	=======================================================================================

	VERSION HISTORY:
	v0.1	Born on 09/07/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class FilterName extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Filter Name";
		private static const PARAMETERS:Array = [
			{
				name: "param1",
				label: "param 1",
				current: 0.1,
				min: 0,
				max: 1,
				type: "number"
			}, {
				name: "param2",
				label: "param 2",
				current: 1,
				min: 0,
				max: 255,
				type: "int"
			}
		];
		
		private static const DEBUG_VARS:Array = [
			"time",
			"frames"
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		public var time:Number;
		public var frames:Number;
	
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var param1:Number;
		public var param2:int;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function FilterName(OVERRIDEN:Object = null)
		{
			// init your bitmaps, variables, etc. here
			
			time = 0;
			frames = 0;
			
			init(NAME, PARAMETERS, OVERRIDEN, DEBUG_VARS);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			// do operations
			
			time += param1;
			frames += param2;
			
			getPreviewFor(metaBmpData);
		}
		
		override public function updateParams():void
		{
			// update parameters if changed
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
	}
}