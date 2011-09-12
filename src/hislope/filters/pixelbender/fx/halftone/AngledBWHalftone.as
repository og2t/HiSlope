/*---------------------------------------------------------------------------------------------

	[AS3] AngledBWHalftone
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

package hislope.filters.pixelbender.fx.halftone
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import hislope.filters.PBFilterBase;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class AngledBWHalftone extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Angled BW Halftone";
		private static const PARAMETERS:Array = [
			{
				name: "angle",
				label: "raster angle",
				current: 45,
				min: 0,
				max: 90,
				type: "number"
			}, {
				name: "pitch",
				current: 5,
				min: 1.0,
				max: 50,
				type: "number"
			}
		];

		[Embed("../../../../pbj/fx/halftone/AngledBWHalftone.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		// PARAMETERS /////////////////////////////////////////////////////////////////////////

		public var angle:Number;
		public var pitch:Number;
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function AngledBWHalftone(OVERRIDE:Object = null)
		{
			super(pbjFile);
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.applyShader(shaderFilter);
			
			postPreview(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		override public function updateParams():void
		{
			shader.data.pitch.value = [pitch];
			shader.data.angle.value = [angle];
			
			super.updateParams();
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}