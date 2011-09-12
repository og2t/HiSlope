/*---------------------------------------------------------------------------------------------

	[AS3] FilterName
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

package hislope.filters // filter path
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class FilterName extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		public static const INFO:String = "Filter Info / comments";
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
			// init your additional bitmapDatas, variables, etc. here
			
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
			
			postPreview(metaBmpData);
		}
		
		override public function updateParams():void
		{
			// update parameters if changed
			
			super.updateParams();
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
	}
}