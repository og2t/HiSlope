/*---------------------------------------------------------------------------------------------

	[AS3] OldLens
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

package hislope.filters.pixelbender.fx
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import hislope.filters.PBFilterBase;
	
	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class OldLens extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Old Lens";
		private static var PARAMETERS:Array = [
			{
				name: "centerX",
				min: 0,
				max: 320,
				current: 160
			}, {
				name: "centerY",
				min: 0,
				max: 240,
				current: 120
			}, {
				name: "aberration",
				step: 0.01,
				min: 1.0,
				max: 1.2,
				current: 1.07
			}, {
				name: "dimStrength",
				label: "dim strength",
				step: 0.01,
				current: 0.3
			}, {
				name: "dimSize",
				label: "dim size",
				min: 0,
				max: 320,
				current: 64
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		[Embed("../../../pbj/fx/OldLens.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var centerX:Number;
		public var centerY:Number;
		public var aberration:Number;
		public var dimStrength:Number;
		public var dimSize:Number;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function OldLens(OVERRIDE:Object = null)
		{
			super(pbjFile, PARAMETERS);

			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.applyShader(shaderFilter);
			
			getPreviewFor(metaBmpData);
		}
		
		override public function updateParams():void
		{		
			shader.data.center.value = [centerX, centerY];
			shader.data.aberration.value = [aberration];
			shader.data.dim_strength.value = [dimStrength];
			shader.data.dim_size.value = [dimSize];
			
			super.updateParams();
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}