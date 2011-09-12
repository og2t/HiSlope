/*---------------------------------------------------------------------------------------------

	[AS3] FilterPanel
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
	v0.1	Born on 09/07/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.gui
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.filters.FilterBase;
	import hislope.gui.HistogramView;
	
	import hislope.events.HiSlopeEvent;
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import hislope.core.FilterChain;
	import hislope.core.FilterParser;
	import hislope.core.Utils;
	
	import flash.geom.Point;
	
	//import net.blog2t.minimalcomps.*;	/*Use Minimal Components+ in the first place*/
	import com.bit101.components.*;	/*Then default to original Minimal Components*/

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class FilterPanel extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////
		
		public static const CHANGE_SIZE:String = "changeSize";
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var filter:FilterBase;

		private var window:Window;

		private var isEnabledCB:CheckBox;
		private var showResultCB:CheckBox;
		private var showHistogramCB:CheckBox;
		private var showDebugVarsCB:CheckBox;
		
		private var previewBmp:Bitmap;
		private var previewHolder:Sprite = new Sprite();
		private var previewLabel:Label = new Label();
		
		private var histogramView:HistogramView;
		private var ui:*;


		private var resetButton:PushButton;
		private var rndButton:PushButton;
		private var copyParamsButton:PushButton;
		/*private var undoParamsButton:PushButton;*/
		
		private var line:Shape = new Shape();

		private var totalHeight:int;
		private var vbox:VBox;
		private var debugVarsBox:Sprite;
		private var hasDebugVars:Boolean;
		
		private var offsetY:int;
		private var decimalPoints:int;
		private var tick:Number;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function FilterPanel(filter:FilterBase, previewScale:Number = 1.0) 
		{
			this.filter = filter;
			filter.panel = this;
			filter.previewScale = previewScale;

			previewBmp = new Bitmap(filter.previewBmpData);
			previewHolder.addChild(previewBmp);
			previewLabel = new Label(previewHolder, 10, 0, "100%");
			previewLabel.blendMode = BlendMode.DIFFERENCE;
			
			histogramView = new HistogramView(filter);
			histogramView.addEventListener(HistogramView.CHANGE_CHANNELS, histogramChannelsChange, false, 0, true);

			vbox = new VBox(this, 0, 0);
			vbox.spacing = 1;

			window = new Window(vbox);
			window.hasMinimizeButton = true;
			window.title = filter.name.toUpperCase();
			window.draggable = false;
			window.shadow = false;
			window.addEventListener(Event.RESIZE, updateParamsVisible, false, 0, true);
			
			isEnabledCB = new CheckBox(window, 320 - 105, 5, "On", updateFilterEnabled);
			showResultCB = new CheckBox(window, 320 - 70, 5, "Prv", updatePreviewVisible);
			showHistogramCB = new CheckBox(window, 320 - 35, 5, "Hst", updateHistogramVisible);

			offsetY = 0;
			
			window.addEventListener(MouseEvent.MOUSE_DOWN, panelClicked, false, 0, true);
			
			//FIXME try to do it before onResetParams is called, as it does virtually the same
			FilterParser.parseParams(filter, this);
			

			resetButton = new PushButton(window.content, 10, offsetY + 5, "RESET", onResetParams);
			resetButton.setSize(50, 15);
			rndButton = new PushButton(window.content, 10 + 60, offsetY + 5, "RANDOMISE", onRandomise);
			rndButton.setSize(70, 15);
			copyParamsButton = new PushButton(window.content, 140 + 10, offsetY + 5, "COPY PARAMS", onCopyParams);
			copyParamsButton.setSize(80, 15);
			/*undoParamsButton = new PushButton(window.content, 230 + 10, offsetY + 5, "UNDO", onUndoParams);
			undoParamsButton.setSize(70, 15);*/
			
			window.setSize(320, offsetY + 25 + 20);
			
			if (filter.debugVars && filter.debugVars.length > 0)
			{
				hasDebugVars = true;
				
				showDebugVarsCB = new CheckBox(window, 320 - 150, 5, "Vars", updateDebugVarsVisible);
				showDebugVarsCB.value = true;
				
				debugVarsBox = new Sprite();
				
				offsetY = 0;

				for each (var debugVar:String in filter.debugVars)
				{
					ui = new Label(debugVarsBox, 10, offsetY, Utils.propToLabel(debugVar) + ": --");
					ui.name = debugVar;
					offsetY += ui.height - 3;
				}
				
				vbox.addChild(debugVarsBox);
			}
			
			vbox.addChild(previewHolder);
			vbox.addChild(histogramView);

			drawPanel(0xFFFFFF, 0x000000);
			window.addChild(line);

			updateParamsVisible();
			updatePreviewVisible();
			//updateFilterEnabled();

			updateTotalHeight();
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		public function destroy():void
		{
			filter.removeEventListener(HiSlopeEvent.FILTER_PROCESSED, render);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		public function updateUI(name:String, value:*):void
		{
			var ui:* = window.content.getChildByName(name);
			ui.value = value;
		}

		
		public function updateParams(event:Event):void
		{
			var targetUI:Object = event.currentTarget;
			var paramName:String = targetUI.name;

			filter.setParam(paramName, targetUI.value);
		}

		
		/*private function buttonCallback(event:Event):void
		{
			var targetUI:Object = event.currentTarget;
			var functionName:String = targetUI.name;
			
			filter[functionName]();
		}*/


		private function updateTotalHeight():void
		{
			vbox.draw();
			dispatchEvent(new Event(FilterPanel.CHANGE_SIZE));
		}
		
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		private function panelClicked(event:MouseEvent):void
		{
			FilterChain.currentPanel = this;
		}

		
		private function previewMouseMove(event:MouseEvent):void
		{
			filter.mouseMovePoint(new Point(previewHolder.mouseX / previewBmp.width, previewHolder.mouseY / previewBmp.height));
		}

		
		private function previewMouseDown(event:MouseEvent):void
		{
			filter.mouseDownPoint(new Point(previewHolder.mouseX / previewBmp.width, previewHolder.mouseY / previewBmp.height));
		}

		
		private function previewMouseUp(event:MouseEvent):void
		{
			filter.mouseUpPoint(new Point(previewHolder.mouseX / previewBmp.width, previewHolder.mouseY / previewBmp.height));
		}


		public function selectPanel():void
		{
			drawPanel(0xFF0000, 0x400000);
		}

		
		public function deselectPanel():void
		{
			FilterChain.currentPanel.drawPanel(0xFFFFFF, 0x000000);
		}


		private function onRandomise(event:Event):void
		{
			filter.randomiseParams();
		}
		
		
		private function onResetParams(event:Event):void
		{
			filter.resetParams();
		}
		
		
		private function onCopyParams(event:Event):void
		{
			FilterParser.copyParams(filter);
		}
		
		
		/*private function onUndoParams(event:Event):void
		{
			FilterParser.undoParams(filter);
		}*/
		

		private function render(event:Event):void
		{
			/*trace(this.filter, "render");*/
			updateTime();
			if (hasDebugVars) traceDebugVars();
		}


		private function traceDebugVars():void
		{
			for (var i:int = 0; i < debugVarsBox.numChildren; i++)
			{
				var label:Label = Label(debugVarsBox.getChildAt(i));
				label.text = Utils.propToLabel(label.name) + ": " + filter.getParamValue(label.name);
			}
		}
		
		
		private function updateTime():void
		{
			window.title = filter.name.toUpperCase() + ": " + filter.time + " ms\t(" + filter.minTime + "-" + filter.maxTime + ")";
		}


		private function updateFilterEnabled(event:Event = null):void
		{
			filterEnabled = isEnabledCB.value;
			isEnabledCB.label = isEnabledCB.value ? "On":"Off"; 
		}


		private function updateParamsVisible(event:Event = null):void
		{
			updateTotalHeight();
		}

		
		private function updateDebugVarsVisible(event:Event = null):void
		{
			debugVarsBox.visible = showDebugVarsCB.value;
			updateTotalHeight();
		}


		private function updatePreviewVisible(event:Event = null):void
		{
			previewVisible = showResultCB.value;
			updateTotalHeight();
		}


		private function updateHistogramVisible(event:Event = null):void
		{
			histogramVisible = showHistogramCB.value;
			updateTotalHeight();
		}
		
		
		public function updatePanelState():void
		{
			isEnabledCB.value = filter.enabled;
			isEnabledCB.label = isEnabledCB.value ? "On":"Off"
			
			previewLabel.text = int(filter.previewScale * 100) + "%";
			
			window.alpha = histogramView.alpha = (isEnabledCB.value) ? 1:0.5;
			if (debugVarsBox) debugVarsBox.alpha = window.alpha;
		}
		
		
		private function histogramChannelsChange(event:Event):void
		{
			previewBmp.bitmapData = filter.previewBmpData;
		}

		
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////

		public function set previewVisible(state:Boolean):void
		{
			previewHolder.visible = showResultCB.value = state;
			filter.displayPreview = state;
			
			updateTotalHeight();
			
			if (state)
			{
				previewHolder.addEventListener(MouseEvent.MOUSE_MOVE, previewMouseMove, false, 0, true);
				previewHolder.addEventListener(MouseEvent.MOUSE_DOWN, previewMouseDown, false, 0, true);
				previewHolder.addEventListener(MouseEvent.MOUSE_UP, previewMouseUp, false, 0, true);
			} else {
				previewHolder.removeEventListener(MouseEvent.MOUSE_MOVE, previewMouseMove);
				previewHolder.removeEventListener(MouseEvent.MOUSE_DOWN, previewMouseDown);
				previewHolder.removeEventListener(MouseEvent.MOUSE_UP, previewMouseUp);
			}
		}
		
		
		public function get previewVisible():Boolean
		{
			return previewHolder.visible;
		}
		
		
		public function set paramsVisible(state:Boolean):void
		{
			window.minimized = !state;
		}
		
		
		public function set histogramVisible(state:Boolean):void
		{
			histogramView.visible = state;
			filter.generateHistogram = state;
			showHistogramCB.value = state;
			updateTotalHeight();
		}
		
		
		public function get histogramVisible():Boolean
		{
			return filter.generateHistogram;
		}
		
		
		public function set debugVarsVisible(state:Boolean):void
		{
			showDebugVarsCB.value = state;
			updateDebugVarsVisible();
		}

		
		public function get debugVarsVisible():Boolean
		{
			return showDebugVarsCB.value;
		}
		
		
		public function set filterEnabled(value:Boolean):void
		{	
			trace(this, "filterEnabled", value);
			
			filter.enabled = value;
			updatePanelState();
			
			if (value)
			{
				filter.addEventListener(HiSlopeEvent.FILTER_PROCESSED, render, false, 0, true);
			}
			
			else 
			{
				filter.removeEventListener(HiSlopeEvent.FILTER_PROCESSED, render);
				window.title = filter.name.toUpperCase();
			}
		}
		
		
		public function get filterEnabled():Boolean
		{
			return filter.enabled;
		}
		
			
		override public function get height():Number
		{
			return vbox.height;
		}
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
		
		public function drawPanel(lineColor:uint, backgroundColor:uint):void
		{
			line.graphics.clear();
			line.graphics.lineStyle(0, lineColor, 2);
			line.graphics.moveTo(0, 0);
			line.graphics.lineTo(320, 0);
			
			window.color = backgroundColor;
		}
		
		
		public function showParams():void
		{
			window.minimized = false;
		}
		
		
		public function hideParams():void
		{
			window.minimized = true;
		}
		
		
		private function updateNameAndValue(param:Object):void
		{
			ui.value = param.current;
			ui.name = param.name;
		}	

		
		private function updateOffsetY():void
		{
			offsetY += ui.height - 3;
		}
		
		
		private function addLabel(component:Component, labelText:String, offset:int = 0):void
		{
			var label:Label = new Label();
			label.text = labelText;
			label.draw();
			label.x = component.x;
			label.y = component.y + offset;
			component.x += label.width + 5;

			window.content.addChild(label);
		}
		
		
		public function addSlider(param:Object, callback:Function, decimalPoints:int, tick:Number):void
		{
			if (param.mode != "readonly")
			{
				ui = new HUIBarSlider(window.content, 10, offsetY, param.label, callback);
				/*ui = new HUISlider(window.content, 10, offsetY, param.label, callback);*/
				ui.minimum = param.min;
				ui.maximum = param.max;
				ui.labelPrecision = decimalPoints;
				ui.tick = tick;
				ui.setSize(320, 18);
			} else {
				ui = new ProgressBar(window.content, 10, offsetY + 4);
				addLabel(ui, param.label, -4);
				offsetY += 6;
			}

			if (param.type == "hex") ui.displayHex = true;
			
			updateNameAndValue(param);
			updateOffsetY();
		}
		
		
		/*public function addRange(param:Object, callback:Function):void
		{
			ui = new HRangeSlider(window.content, 10, offsetY, callback);
			ui.minimum = param.min;
			ui.maximum = param.max;
			
			ui.name = param.name;
			ui.lowValue = param.min;
			ui.highValue = param.max;
			
			updateOffsetY();
		}*/
		

		public function addCombo(param:Object, callback:Function):void
		{
			offsetY += 4;
			ui = new ComboBox(window.content, 10, offsetY, param.label, param.items);
			ui.addEventListener(Event.SELECT, callback);
			offsetY += 4;
			
			ui.name = param.name;
			updateOffsetY();
		}


		public function addInput(param:Object, callback:Function):void
		{
			offsetY += 4;
			ui = new InputText(window.content, 10, offsetY, param.label, callback);
			offsetY += 4;
			
			updateNameAndValue(param);
			updateOffsetY();
		}
		
		
		public function addStepper(param:Object, callback:Function):void
		{
			offsetY += 4;
			ui = new NumericStepper(window.content, 10, offsetY, callback);
			addLabel(ui, param.label);
			ui.minimum = param.min;
			ui.maximum = param.max;
			offsetY += 4;
			
			updateNameAndValue(param);
			updateOffsetY();
		}
		
		
		public function addKnob(param:Object, callback:Function):void
		{
			offsetY += 4;
			ui = new SmallKnob(window.content, 10, offsetY, param.label, callback);
			ui.minimum = param.min;
			ui.maximum = param.max;
			offsetY += 24;
			
			updateNameAndValue(param);
			updateOffsetY();
		}
		
		
		public function addColorChooser(param:Object, callback:Function):void
		{
			offsetY += 2;
			ui = new ColorChooser(window.content, 10, offsetY, param.label, callback);
			offsetY += 4;
			//ui.usePopup = true;
			
			updateNameAndValue(param);
			updateOffsetY();
		}
		
		
		public function addCheckBox(param:Object, callback:Function):void
		{
			offsetY += 4;
			ui = new CheckBox(window.content, 10, offsetY, param.label, callback);
			offsetY += 4;
			
			updateNameAndValue(param);
			updateOffsetY();
		}
		
		
		public function addPushButton(param:Object, callback:Function):void
		{
			offsetY += 4;
			ui = new PushButton(window.content, 10, offsetY, param.label.toUpperCase(), callback);
			/*ui.name = param.callback;*/
			ui.height = 15;
			offsetY += 4;
			updateOffsetY();
		}
		
	}
}