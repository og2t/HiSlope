/*---------------------------------------------------------------------------------------------

	[AS3] RGBHalftone
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
	import flash.events.Event;
	import hislope.filters.PBFilterBase;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class RGBHalftone extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "RGB Halftone";
		private static const PARAMETERS:Array = [
			{
				name: "angle",
				label: "raster angle",
				current: 45,
				min: -45,
				max: 90,
				type: "number"
			}, {
				name: "angleDiff",
				label: "angle difference between channels",
				current: 60,
				min: 0,
				max: 60,
				type: "number"
			}, {
				name: "threshold",
				label: "strength",
				current: 0.6,
				min: 0,
				max: 0.99,
				step: 0.01,
				type: "number"
			}, {
				name: "dotSize",
				label: "raster dot size",
				current: 2.5,
				min: 0.1,
				max: 60,
				step: 0.01,
				type: "number"
			}, {
				name: "centerX",
				label: "rotation x",
				current: WIDTH / 2,
				min: 0,
				max: 320,
				type: "uint"
			}, {
				name: "centerY",
				label: "rotation y",
				current: HEIGHT / 2,
				min: 0,
				max: 240,
				type: "uint"
			}, {
				name: "equalAngles",
				current: false
			}
		];
		
		[Embed("../../../../pbj/fx/halftone/RGBHalftone.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		// PARAMETERS /////////////////////////////////////////////////////////////////////////

		public var angle:Number;
		public var angleDiff:Number;
		public var threshold:Number;
		public var dotSize:Number;
		public var centerX:uint;
		public var centerY:uint;
		public var equalAngles:Boolean;
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function RGBHalftone(OVERRIDE:Object = null)
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
			shader.data.rotationCenter.value = [centerX, centerY];
			shader.data.angle.value = [angle / 2];
			shader.data.angleDiff.value = (equalAngles) ? [0] : [angleDiff];
			shader.data.threshold.value = [threshold];
			shader.data.dotSize.value = [dotSize];
			
			super.updateParams();
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}