/*---------------------------------------------------------------------------------------------

	[AS3] Pixellize
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

package hislope.filters.basic
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Pixellize extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Pixellize";
		private static const PARAMETERS:Array = [
			{
				name: "pixelSize",
				current: 1,
				min: 1,
				max: 32,
				type: "uint"
			}
		];
		
		private static const DEBUG_VARS:Array = [
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		private var scaleUpMatrix:Matrix;
		private var scaleDownMatrix:Matrix;
		private var pixelBitmapData:BitmapData;
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var pixelSize:int;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Pixellize(OVERRIDEN:Object = null)
		{
			scaleUpMatrix = new Matrix();
			scaleDownMatrix = new Matrix();
			
			init(NAME, PARAMETERS, OVERRIDEN, DEBUG_VARS);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			pixelBitmapData.draw(metaBmpData, scaleDownMatrix);
			metaBmpData.draw(pixelBitmapData, scaleUpMatrix);
			
			postPreview(metaBmpData);
		}
		
		override public function updateParams():void
		{
			scaleUpMatrix.identity();
			scaleDownMatrix.identity();
			scaleDownMatrix.scale(1 / pixelSize, 1 / pixelSize);
			scaleUpMatrix.scale(pixelSize, pixelSize);
			pixelBitmapData = new BitmapData(Math.ceil(width / pixelSize), Math.ceil(height / pixelSize), false, 0x000000);
			
			super.updateParams();
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
	}
}