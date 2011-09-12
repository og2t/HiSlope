/*---------------------------------------------------------------------------------------------

	[AS3] PlainHalftone
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
	/*import flash.display.ShaderJob;
	import flash.display.BitmapData;*/

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class PlainHalftone extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Plain Halftone";
		private static const PARAMETERS:Array = [
			{
				name: "angle",
				label: "raster angle",
				current: 45,
				min: -45,
				max: 90,
				type: "number"
			}, {
				name: "threshold",
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
				label: "center rotation x",
				current: WIDTH / 2,
				min: 0,
				max: 320,
				type: "uint"
			}, {
				name: "centerY",
				label: "center rotation y",
				current: HEIGHT / 2,
				min: 0,
				max: 240,
				type: "uint"
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		[Embed("../../../../pbj/fx/halftone/Halftone.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////

		public var angle:Number;
		public var threshold:Number;
		public var dotSize:Number;
		public var centerX:uint;
		public var centerY:uint;

		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function PlainHalftone(OVERRIDE:Object = null)
		{
			super(pbjFile);

			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			/*shader.data.srcPixel.input = metaBmpData;
			var job:ShaderJob = new ShaderJob(shader, metaBmpData as BitmapData, metaBmpData.width, metaBmpData.height);
			job.start(true);*/
			
			metaBmpData.applyShader(shaderFilter);
			
			postPreview(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		override public function updateParams():void
		{
			shader.data.dotSize.value = [dotSize];
			shader.data.threshold.value = [threshold];
			shader.data.angle.value = [angle];
			shader.data.rotationCenter.value = [centerX, centerY];
			
			super.updateParams();
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}