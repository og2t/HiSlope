/*---------------------------------------------------------------------------------------------

	[AS3] Pencil
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
	import hislope.filters.FilterBase;
	import flash.filters.ShaderFilter;
	import flash.utils.ByteArray;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Pencil extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Pencil";
		private static const PARAMETERS:Array = [
			{
				name: "n0",
				current: 97.0,
				max: 100,
				type: "number"
			}, {
				name: "n1",
				current: 15.0,
				max: 100,
				type: "number"
			}, {
				name: "n2",
				current: 97.0,
				max: 100,
				type: "number"
			}, {
				name: "n3",
				current: 9.7,
				max: 10,
				type: "number"
			}
		];

		[Embed("../../../pbj/Pencil.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var shaderFilter:ShaderFilter;
		private var shader:Shader;

		// PARAMETERS /////////////////////////////////////////////////////////////////////////

		public var n0:Number;
		public var n1:Number;
		public var n2:Number;
		public var n3:Number;
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Pencil(OVERRIDE:Object = null)
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

			postPreview(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		override public function updateParams():void
		{
			shader.data.n0.value = [n0];
			shader.data.n1.value = [n1];
			shader.data.n2.value = [n2];
			shader.data.n3.value = [n3];
			
			super.updateParams();
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}