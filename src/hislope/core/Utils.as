/*---------------------------------------------------------------------------------------------

	[AS3] Utils
	=======================================================================================

	Copyright (c) 2010 blog2t.net
	All Rights Reserved

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

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Utils extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Utils() 
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
		}

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
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}