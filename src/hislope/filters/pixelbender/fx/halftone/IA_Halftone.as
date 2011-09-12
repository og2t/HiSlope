/*---------------------------------------------------------------------------------------------

	[AS3] IA_Halftone
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

	public class IA_Halftone extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "IA Halftone";
		private static const PARAMETERS:Array = [
			{
				name: "radius",
				current: 5,
				min: 0,
				max: 50,
				type: "number"
			}, {
				name: "offset",
				current: 0.88,
				min: 0,
				max: 10,
				type: "number"
			}, {
				name: "brightness",
				current: 0.92
			}, {
				name: "multiplier",
				current: 0.9,
				min: 0.2,
				max: 8.0,
				type: "number"
			}
		];

		[Embed("../../../../pbj/fx/halftone/IA_Halftone.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		// PARAMETERS /////////////////////////////////////////////////////////////////////////

		public var radius:Number;
		public var offset:Number;
		public var brightness:Number;
		public var multiplier:Number;
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function IA_Halftone(OVERRIDE:Object = null)
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
			shader.data.radius.value = [radius];
			shader.data.offset.value = [offset];
			shader.data.brightness.value = [brightness];
			shader.data.multiplier.value = [multiplier];
			
			super.updateParams();
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}