/*---------------------------------------------------------------------------------------------

	[AS3] Technicolor
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

package hislope.filters.pixelbender.fx
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.display.Shader;
	import hislope.filters.FilterBase;
	import flash.filters.ShaderFilter;
	import flash.utils.ByteArray;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Technicolor extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Technicolor";
		private static const PARAMETERS:Array = [
			{
				name: "amount",
				current: 0.5
			}
		];

		[Embed("../../../pbj/Technicolor.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var shaderFilter:ShaderFilter;
		private var shader:Shader;

		// PARAMETERS /////////////////////////////////////////////////////////////////////////

		public var amount:Number;
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Technicolor(OVERRIDE:Object = null)
		{
			shader = new Shader(new pbjFile() as ByteArray);
           	shaderFilter = new ShaderFilter(shader);

			/*detectKernelParams(shader, PARAMETERS);*/
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.applyFilter(metaBmpData, rect, point, shaderFilter);

			getPreviewFor(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		override public function updateParams():void
		{
			shader.data.amount.value = [amount];
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}