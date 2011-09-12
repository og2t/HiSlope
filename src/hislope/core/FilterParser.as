/*---------------------------------------------------------------------------------------------

	[AS3] FilterParser
	=======================================================================================

	Copyright (c) 2009 blog2t.net
	All Rights Reserved

	VERSION HISTORY:
	v0.1	Born on 2009-08-28

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:
	
		- TODO This class is shitty and loopy. Needs a total rewrite from scratch (use Soulwire's SimpleGUI solutions)

---------------------------------------------------------------------------------------------*/

package hislope.core
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import hislope.filters.FilterBase;
	import hislope.gui.FilterPanel;
	import hislope.core.Utils;
	import net.blog2t.math.Range;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class FilterParser
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		/*private var cookie:Cookie = new Cookie("HiSlope", 3600 * 24);*/
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		public static function parseParams(filter:FilterBase, filterPanel:FilterPanel):void
		{
			for each (var param:Object in filter.defaultParams)
			{
				var callback:Function;
				var decimalPoints:int = 0;
				var tick:Number = 0.01;
				
				if (param.callback == undefined)
				{
					callback = filterPanel.updateParams;
				} else {
					callback = filter[param.callback];
				}
				
				if (param.mode == "readonly")
				{
					callback = null;
				}
				
				if (param.type != "button")
				{
					trace("________", param.name + " (" + param.type + "): " + param.current);
				}
				
				if (param.type == "number" || param.type == "float")
				{
					decimalPoints = 2;
					if (param.step != undefined) tick = param.step;
				}

				if (param.label == undefined)
				{
					if (param.type == "button") param.label = Utils.propToLabel(param.callback);
					else param.label = Utils.propToLabel(param.name);
				} else {
					param.label = param.label.toLowerCase();
				}

				switch (param.type)
				{
					case "int":
					case "uint":
					case "number":
					case "float":
					case "hex":
						filterPanel.addSlider(param, callback, decimalPoints, tick);
						break;
					case "stepper":
						filterPanel.addStepper(param, callback);
						break;
					/*case "range":
						filterPanel.addRange(param, callback);
						break;*/
					case "rgb":
					case "color":
						filterPanel.addColorChooser(param, callback);
						break;
					case "boolean":
						filterPanel.addCheckBox(param, callback);
						break;
					case "button":
						filterPanel.addPushButton(param, callback);
						break;
					case "input":
					case "string":
						filterPanel.addInput(param, callback);
						break;
					case "combo":
						filterPanel.addCombo(param, callback);
						break;
					case "knob":
						filterPanel.addKnob(param, callback);
						break;
					default:
						throw new Error("Unsupported type: '" + param.type + "' for " + param.name + " in " + filter + ".");
				}
			}
		}
		
		
		public static function resetParams(filter:FilterBase):void
		{
			trace("RESET FILTER PARAMS");
			
			for each (var param:Object in filter.defaultParams)
			{
				if (param.type == "button") continue;
			
				if (param.type != undefined)
				{
					param.type = param.type.toLowerCase();
				} else {
					// auto detect param type (number or boolean only)
					param.type = typeof filter[param.name];
				}
			
				if (param.current == undefined)
				{
					if (param.type != "boolean") param.current = 0; else param.current = false;
				}
				
				if (param.min == undefined) param.min = 0;
				
				if (param.max == undefined)
				{
					if (param.type == "rgb" || param.type == "current") param.max = 0xFFFFFF;
					else if (param.type == "boolean") param.max = 2;
					else param.max = 1;
				}
				
				trace("\t", param.name + ": " + param.current + " (" + param.type + ")" + " [" + param.min + ", " + param.max + "]");
			
				// remember last value
				param.lastValue = param.current;
			
				filter.setParam(param.name, param.current, false);
				filter.updateUI(param.name, param.current);
			}
			
			filter.updateParams();
		}
		
		
		public static function randomiseParams(filter:FilterBase, coloursOnly:Boolean = false):void
		{
			for each (var param:Object in filter.defaultParams)
			{
				if (param.type == "button" || param.random == false) continue;
				if (coloursOnly && !(param.type == "rgb" || param.type == "hex" || param.type == "color")) continue;
				
				if (!coloursOnly && param.lock) continue;
				
				var min:Number = param.min;
				var max:Number = param.max;
				
				var randomValue:Number = Range.getBetween(min, max, (param.type == "rgb" || param.type == "int" || param.type == "boolean"));
				param.lastValue = filter[param.name];
				filter.setParam(param.name, randomValue);
				filter.updateUI(param.name, filter[param.name]);
			}
		}
		
		
		public static function setParams(filter:FilterBase):void
		{
			trace("\n" + filter, "_presetParams", filter.presetParams);
			
			if (filter.presetParams)
			{
				for (var paramName:String in filter.presetParams)
				{
					trace("\tOVERRIDES: ", paramName + ": " + filter.presetParams[paramName]);
					
					// FIXME mega-loop WTF?
					filter.setParam(paramName, filter.presetParams[paramName], false);

					// nasty: update default params for this instance
					for (var i:int = 0; i < filter.defaultParams.length; i++)
					{
						if (filter.defaultParams[i].name == paramName)
						{
							trace("\tOVERRIDE " + paramName + " from: " + filter.defaultParams[i].current + " to: " + filter.presetParams[paramName]);
							filter.defaultParams[i].current = filter.presetParams[paramName];
						}
					}
				}
			}
		}
		
		
		public static function updateParams(filter:FilterBase, updateUI:Boolean = false):void
		{
			// check what had changed and update UI accordingly
			
			for each (var param:Object in filter.defaultParams)
			{
				if (param.type == "button") continue;
				
				if (filter[param.name] != param.lastValue)
				{
					/*trace("param changed:", param.name, filter[param.name]);*/
					param.lastValue = filter[param.name];
					
					if (updateUI) filter.updateUI(param.name, filter[param.name]);
				}
			}
		}
		
		
		public static function copyParams(filter:FilterBase):void
		{
			var params:Array = [];

			for each (var param:Object in filter.defaultParams)
			{
				trace(param.name, param.type);
				
				if (param.type == "button") continue;
				
				var object:String;
				
				if (param.type != "boolean")
				{
					object = param.name + ": " + filter.getParamValue(param.name).toFixed(3);
				} else {
					object = param.name + ": " + filter.getParamValue(param.name);
				}
				
				if (param.type == "rgb" || param.type == "hex" || param.type == "color")
				{
					object = param.name + ": 0x" + filter.getParamValue(param.name).toString(16).toUpperCase();
				}
				
				params.push(object);
			}
			
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, "{" + params.join(", ") + "}");
			
			trace("Copied to clipboad:", "{" + params.join(", ") + "}");
		}
		
		
		/*public static function undoParams(filter:FilterBase):void
		{
			// check what had changed and update UI accordingly
			for each (var param:Object in filter.defaultParams)
			{
				if (param.type == "button") continue;
				
				if (param.lastValue != undefined)
				{
					filter.setParam(param.name, param.lastValue);
					trace("param reverted:", param.name, filter[param.name]);
					filter.updateUI(param.name, filter[param.name]);
				}
			}
		}*/

		
		/*private function copyParams(event:Event):void
		{
			var saveParams:Object = {};
			
			for each (var param:Object in filter.defaultParams)
			{
				saveParams[param.name] = filter.getParamValue(param.name);
			}

			cookie.put(filter.name, saveParams);
		}
		
		
		private function pasteParams(event:Event):void
		{
			var readParams:Object = cookie.get(filter.name);
			
			for (var paramName:String in readParams)
			{
				if (paramName != "time")
				{
					filter.setParam(paramName, readParams[paramName]);
					filter.updateUI(paramName, readParams[paramName]);
				}
			}
		}*/
		
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}