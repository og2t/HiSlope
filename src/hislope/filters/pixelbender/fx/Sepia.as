/*---------------------------------------------------------------------------------------------

	[AS3] Sepia
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
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.display.Shader;
	import net.blog2t.util.ColorUtils;
	import hislope.filters.PBFilterBase;
	import flash.filters.ShaderFilter;
	import flash.utils.ByteArray;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Sepia extends PBFilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Sepia";
		private static const PARAMETERS:Array = [
			{
				name: "intensity",
				current: 0.15,
				step: 0.01
			}
		];

		[Embed("../../../pbj/Sepia.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		// PARAMETERS /////////////////////////////////////////////////////////////////////////

		public var intensity:Number;
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Sepia(OVERRIDE:Object = null)
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
			shader.data.intensity.value = [intensity];
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}