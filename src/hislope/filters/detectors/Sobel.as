/*---------------------------------------------------------------------------------------------

	[AS3] Sobel
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
	import flash.events.Event;
	import flash.display.BitmapData;
	import hislope.filters.PBFilterBase;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Sobel extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Sobel";
		private static const PARAMETERS:Array = [
			{
				name: "lowThreshold",
				label: "low Threshold",
				current: 0.0
			}, {
				name: "highThreshold",
				label: "high Threshold",
				current: 1.0
			}, {
				name: "enableThreshold",
				label: "enable Threshold",
				current: false,
				type: "boolean"
			}
		];

		[Embed("../../pbj/detectors/Sobel.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		// PARAMETERS /////////////////////////////////////////////////////////////////////////

		public var lowThreshold:Number;
		public var highThreshold:Number;
		public var enableThreshold:Boolean;
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Sobel(OVERRIDE:Object = null)
		{
			super(pbjFile);
			
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
			shader.data.highThreshold.value = [highThreshold];
			shader.data.lowThreshold.value = [lowThreshold];
			shader.data.enableThreshold.value = [enableThreshold ? 1 : 0];
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}