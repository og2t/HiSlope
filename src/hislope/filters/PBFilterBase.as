/*---------------------------------------------------------------------------------------------

	[AS3] PBFilterBase
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
	v0.1	Born on 07/07/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES

---------------------------------------------------------------------------------------------*/

package hislope.filters
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.filters.IFilter;
	import flash.display.Shader;
	import flash.filters.ShaderFilter;
	import flash.display.ShaderParameter;
	import flash.display.ShaderPrecision;
	import flash.utils.ByteArray;
	import hislope.core.Utils;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class PBFilterBase extends FilterBase implements IFilter
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////
		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		protected var shaderFilter:ShaderFilter;
		protected var shader:Shader;
		private var shaderParams:Array = [];

		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function PBFilterBase(pbjFile:Class, PARAMETERS:Array = null)
		{
			shader = new Shader(new pbjFile() as ByteArray);
			shaderFilter = new ShaderFilter(shader);
			
			shader.precisionHint = ShaderPrecision.FAST;
			
			/*if (PARAMETERS) Utils.autoDetectKernelParams(shader, PARAMETERS, shaderParams);*/
			
			super();
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		public function fullShaderPrecision():void
		{
			shader.precisionHint = ShaderPrecision.FULL;
		}
		
		public function updateShaderParams(PARAMETERS:Array):void
		{
			// TODO go through all the shadeParams and update the shader according to the PARAMETERS
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}