/*---------------------------------------------------------------------------------------------

	[AS3] Pins
	=======================================================================================

	HiSlope toolkit copyright (c) 2010 Tomek 'Og2t' Augustyn
	http://play.blog2t.net/hislope

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

package hislope.filters.pixelbender
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import hislope.filters.PBFilterBase;
	import hislope.events.HiSlopeEvent;
	
	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Gamma extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Gamma";
		private static var PARAMETERS:Array = [
			{
				name: "gamma",
				current: 1.0,
				min: 1.0,
				max: 3.0,
				type: "number"
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		[Embed("../../pbj/Gamma.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var gamma:Number;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Gamma(OVERRIDE:Object = null)
		{
			super(pbjFile, PARAMETERS);

			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.applyFilter(metaBmpData, rect, point, shaderFilter);

			postPreview(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		override public function updateParams():void
		{
			shader.data.gamma.value = [gamma];
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}