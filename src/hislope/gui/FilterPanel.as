/*---------------------------------------------------------------------------------------------

	[AS3] FilterPanel
	=======================================================================================

	HiSlope toolkit copyright (c) 2010 Tomek 'Og2t' Augustyn
	http://play.blog2t.net/hislope

	You are free to use this source code in any project. 
	You are free to modify this source code in anyway you see fit.
	You are free to distribute this source code.

	You may NOT charge anything for this source code.
	This notice and the copyright information must be left intact in any distribution of this source code. 
	You are encouraged to release any improvements back to the ActionScript community.w

	VERSION HISTORY:
	v0.1	Born on 09/07/2009

	USAGE:

	TODOs:
	
		#TODO separate logic from view

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.gui
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.filters.FilterBase;
	import hislope.gui.Histogram;
	import net.blog2t.math.Range;
	/*import net.blog2t.util.Cookie;*/
	import net.blog2t.util.print_r;
	/*import net.blog2t.util.StringUtils;*/
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import com.bit101.components.*;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class FilterPanel extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////
		
		public static const CHANGE_SIZE:String = "changeSize";
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var filter:FilterBase;
		private var previewBmp:Bitmap;
		private var histogram:Histogram;
		private var ui:*;

		private var isEnabledCB:CheckBox;
		private var showResultCB:CheckBox;
		private var showHistrogramCB:CheckBox;
		private var showDebugVarsCB:CheckBox;

		private var resetButton:PushButton;
		private var rndButton:PushButton;
		private var copyParamsButton:PushButton;

		private var window:Window;
		private var windowMask:Sprite = new Sprite();

		private var totalHeight:int;
		private var vbox:VBox;
		private var debugVarsBox:Sprite;
		private var hasDebugVars:Boolean;
	
		/*private var cookie:Cookie = new Cookie("HiSlope", 3600 * 24);*/
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function FilterPanel(filter:FilterBase, stageInit:Boolean = true) 
		{
			this.filter = filter;
			filter.panel = this;

			previewBmp = new Bitmap(filter.preview);
			
			histogram = new Histogram(filter);
			histogram.addEventListener(Histogram.CHANGE_CHANNELS, histogramChannelsChange, false, 0, true);

			vbox = new VBox(this, 0, 0);
			vbox.spacing = 1;

			window = new Window(vbox);
			window.hasMinimizeButton = true;
			window.title = filter.name.toUpperCase();
			window.draggable = false;
			window.shadow = false;
			window.addEventListener(Event.RESIZE, updateParamsVisible, false, 0, true);
			
			isEnabledCB = new CheckBox(window, 320 - 120, 5, "O", updateFilterEnabled);
			showResultCB = new CheckBox(window, 320 - 90, 5, "P", updatePreviewVisible);
			showHistrogramCB = new CheckBox(window, 320 - 60, 5, "H", updateHistogramVisible);

			var offsetY:int = 0;
			
			//FIXME try to do it before resetParams is called, as it does virtually the same

			for each (var param:Object in filter.params)
			{
				var callBack:Function;
				
				if (param.mode == undefined)
				{
					callBack = updateParams;
				} else if (param.mode == "readonly")
				{
					callBack = null;
				}
				
				var decimalPoints:int = 0;
				var tick:Number = 0.01;
				
				trace("________", param.name + " (" + param.type + "): " + param.current);
				
				if (param.type == "number" || param.type == "float")
				{
					decimalPoints = 2;
					if (param.step != undefined) tick = param.step;
				}

				if (param.label == undefined) param.label = param.name;
				else param.label = param.label.toLowerCase();

				switch (param.type)
				{
					case "int":
					case "uint":
					case "number":
					case "float":
					case "hex":
						if (param.mode != "readonly")
						{
							ui = new HUISlider(window.content, 10, offsetY, param.label, callBack);
							ui.minimum = param.min;
							ui.maximum = param.max;
							ui.labelPrecision = decimalPoints;
							ui.tick = tick;
							ui.setSize(320, 18);
						} else {
							//TODO add ProgressBar with label
							ui = new ProgressBar(window.content, 10, offsetY);
						}
						if (param.type == "hex") ui.displayHex = true;
					break;
					case "rgb":
					case "color":
						offsetY += 2;
						ui = new ColorChooser(window.content, 10, offsetY, param.label, callBack);
						offsetY += 4;
						//ui.usePopup = true;
					break;
					case "boolean":
						offsetY += 4;
						ui = new CheckBox(window.content, 10, offsetY, param.label, callBack);
						offsetY += 4;
					break;
					case "button":
						offsetY += 4;
						ui = new PushButton(window.content, 10, offsetY, param.label.toUpperCase(), invokeCallback);
						ui.name = param.callback;
						ui.height = 15;
						offsetY += 4;
					break;
					default:
						throw new Error("Unsupported type: '" + param.type + "' for " + param.name + " in " + filter + ".");
					break;
				}
				
				if (param.type != "button")
				{
					ui.value = param.current;
					ui.name = param.name;
				}	
				
				offsetY += ui.height - 3;
			}
			
			resetButton = new PushButton(window.content, 10, offsetY + 5, "RESET", resetParams);
			resetButton.setSize(50, 15);
			rndButton = new PushButton(window.content, 10 + 60, offsetY + 5, "RANDOMISE", randomiseParams);
			rndButton.setSize(70, 15);
			copyParamsButton = new PushButton(window.content, 140 + 10, offsetY + 5, "COPY PARAMS", copyParams);
			copyParamsButton.setSize(80, 15);
			
			window.setSize(320, offsetY + 25 + 20);
			
			if (filter.debugVars && filter.debugVars.length > 0)
			{
				hasDebugVars = true;
				
				showDebugVarsCB = new CheckBox(window, 320 - 30, 5, "V", updateDebugVarsVisible);
				showDebugVarsCB.value = true;
				
				debugVarsBox = new Sprite();
				
				offsetY = 0;

				for each (var debugVar:String in filter.debugVars)
				{
					ui = new Label(debugVarsBox, 10, offsetY, debugVar + ": --");
					ui.name = debugVar;
					offsetY += ui.height - 3;
				}
				
				vbox.addChild(debugVarsBox);
			}
			
			vbox.addChild(previewBmp);

			vbox.addChild(histogram);
			
			var line:Shape = new Shape();
			line.graphics.lineStyle(0, 0xffffff, 1);
			line.graphics.moveTo(0, 0);
			line.graphics.lineTo(320, 0);
			window.addChild(line);

			updateParamsVisible();
			updatePreviewVisible();
			//updateFilterEnabled();

			updatePositions();
			
			if (stageInit) addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		public function destroy():void
		{
			filter.removeEventListener(FilterBase.PROCESSED, render);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		public function init(event:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function updateUI(name:String, value:*):void
		{
			var ui:* = window.content.getChildByName(name);
			ui.value = value;
		}
		
		private function updateParams(event:Event):void
		{
			var targetUI:Object = event.currentTarget;
			var paramName:String = targetUI.name;

			filter.setParam(paramName, targetUI.value);
		}
		
		private function invokeCallback(event:Event):void
		{
			var targetUI:Object = event.currentTarget;
			var functionName:String = targetUI.name;
			
			filter[functionName]();
		}
				
		private function updatePositions():void
		{
			vbox.draw();
			dispatchEvent(new Event(FilterPanel.CHANGE_SIZE));
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////

		private function render(event:Event):void
		{
			updateTime();
			if (hasDebugVars) traceDebugVars();
		}

		private function traceDebugVars():void
		{
			for (var i:int = 0; i < debugVarsBox.numChildren; i++)
			{
				var label:Label = Label(debugVarsBox.getChildAt(i));
				label.text = label.name + ": " + filter.getParamValue(label.name);
			}
		}

		private function updateTime():void
		{
			var text:String = filter.name.toUpperCase();
			if (filter.enabled) text += ": " + filter.time + " ms"; else text += ": off";
			window.title = text;
		}

		private function updateFilterEnabled(event:Event = null):void
		{
			filterEnabled = isEnabledCB.value;
		}

		private function updateParamsVisible(event:Event = null):void
		{
			updatePositions();
		}
		
		private function updateDebugVarsVisible(event:Event = null):void
		{
			debugVarsBox.visible = showDebugVarsCB.value;
			updatePositions();
		}

		private function updatePreviewVisible(event:Event = null):void
		{
			previewVisible = showResultCB.value;
			updatePositions();
		}

		private function updateHistogramVisible(event:Event = null):void
		{
			histogramVisible = showHistrogramCB.value;
			updatePositions();
		}
		
		private function histogramChannelsChange(event:Event):void
		{
			previewBmp.bitmapData = filter.preview;
		}
		
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////

		public function set previewVisible(state:Boolean):void
		{
			previewBmp.visible = showResultCB.value = state;
			filter.generatePreview = state;
			updatePositions();
		}
		
		public function set paramsVisible(state:Boolean):void
		{
			window.minimized = !state;
		}
		
		public function set histogramVisible(state:Boolean):void
		{
			histogram.visible = showHistrogramCB.value = state;
			filter.generateHistogram = state;
			updatePositions();
		}
		
		public function set filterEnabled(value:Boolean):void
		{	
			trace(this, "filterEnabled", value);
			filter.enabled = isEnabledCB.value = value;
			window.alpha = histogram.alpha = (isEnabledCB.value) ? 1 : 0.5;
			if (debugVarsBox) debugVarsBox.alpha = window.alpha;
			
			if (value) filter.addEventListener(FilterBase.PROCESSED, render, false, 0, true);
			else filter.removeEventListener(FilterBase.PROCESSED, render);
		}
			
		override public function get height():Number
		{
			return vbox.height;
		}
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
		
		private function resetParams(event:Event):void
		{
			filter.resetParams();
		}
		
		private function randomiseParams(event:Event = null):void
		{
			for each (var param:Object in filter.params)
			{
				if (param.type == "button") continue;
				
				var min:Number = param.min;
				var max:Number = param.max;
								
				var randomValue:Number = Range.getBetween(min, max, (param.type == "rgb" || param.type == "int" || param.type == "boolean"));
				var ui:* = window.content.getChildByName(param.name);

				//trace(type, param.name, min, max, randomValue);
				
				if (ui)
				{
					ui.value = randomValue;
					filter.setParam(param.name, randomValue);
				}
			}
		}
		
		private function copyParams(event:Event):void
		{
			var params:Array = [];

			for each (var param:Object in filter.params)
			{
				var object:String = param.name + ": " + filter.getParamValue(param.name);
				
				if (param.type == "rgb" || param.type == "hex" || param.type == "color")
				{
					object = param.name + ": 0x" + filter.getParamValue(param.name).toString(16).toUpperCase();
				}
				
				params.push(object);
			}
			
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, "{" + params.join(", ") + "}");
			
			trace("Copied to clipboad:", "{" + params.join(", ") + "}");
		}
		
		/*private function copyParams(event:Event):void
		{
			var saveParams:Object = {};
			
			for each (var param:Object in filter.params)
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
					updateUI(paramName, readParams[paramName]);
				}
			}
		}*/
	}
}