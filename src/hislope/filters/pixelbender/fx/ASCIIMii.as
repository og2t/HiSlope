/*---------------------------------------------------------------------------------------------

	[AS3] ASCIIMii
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
	v0.1	Born on 08/09/2011

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters.pixelbender.fx
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import hislope.filters.PBFilterBase;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class ASCIIMii extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "ASCIIMii";
		private static var PARAMETERS:Array = [
			{
				name: "size",
				current: 8,
				min: 1,
				max: 32,
				type: "int"
			}, {
				name: "charCount",
				current: 8,
				min: 1,
				max: 64,
				type: "int"
			}
		];
		
		private static const DEBUG_VARS:Array = [
		];
		
		[Embed("../../../pbj/fx/ASCIIMii.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		/*[Embed(source="../../../../../assets/c64.png")]*/
		/*[Embed(source="../../../../../assets/stripes.png")]*/
		[Embed(source="../../../../../assets/ascii_fontmap_white.png")]
		private const FontMap:Class;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var size:Number;
		public var charCount:Number;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function ASCIIMii(OVERRIDE:Object = null)
		{
			super(pbjFile);
			
			fullShaderPrecision();
			
			init(NAME, PARAMETERS, OVERRIDE, DEBUG_VARS);
			
			shader.data.text.input = (new FontMap() as Bitmap).bitmapData;
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.applyShader(shaderFilter);
			
			postPreview(metaBmpData);
		}
		
		override public function updateParams():void
		{
			shader.data.charCount.value = [charCount * size];
			shader.data.size.value = [size];
			
			super.updateParams();
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
	}
}