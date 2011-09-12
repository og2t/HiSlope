/*---------------------------------------------------------------------------------------------

	[AS3] Utils
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
	v0.1	Born on 2010-06-28

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.core
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.Shader;
	import flash.display.ShaderParameter;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Utils
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		public static function detectKernelParameters(shader:Shader, params:Array):void
		{
			var infoString:String = "";
			
			for (var p:String in shader.data)
			{
			    infoString += p + ": " + shader.data[p] + "\n";

			    if (shader.data[p] is ShaderParameter)
			    {
			        // add the type of the parameter to the string
			        infoString += "* " + (shader.data[p] as ShaderParameter).type + "\n";
			
					for (var d:String in shader.data[p])
				    {
				        // use the built-in string conversion for the all the info associated
				        infoString += "\t" + d + ": " + shader.data[p][d] + "\n";
				
						var object:Object = {};
						if ((shader.data[p] as ShaderParameter).type == "float") object.type = "number";
						
						// detect float2 and float3
						
						if (d == "name") object.name = shader.data[p][d];
						if (d == "minValue") object.min = shader.data[p][d];
						if (d == "maxValue") object.max = shader.data[p][d];
						if (d == "defaultValue") object.current = shader.data[p][d];
				    }
			    }
			}
		}

		
		// Shamelessly stolen from SoulWire's SimpleGUI
		public static function propToLabel(prop:String):String
		{
			return prop .replace(/[_]+([a-zA-Z0-9]+)|([0-9]+)/g, " $1$2 ")
						.replace(/(?<=[a-z0-9])([A-Z])|(?<=[a-z])([0-9])/g, " $1$2")
						.replace(/^\s|\s$|(?<=\s)\s+/g, '').toLowerCase();
		}
		
		
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}