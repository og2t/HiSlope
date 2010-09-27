/*---------------------------------------------------------------------------------------------

	[AS3] FilterChain
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
	
	TODO: separate GUI from the model 

	DEV IDEAS:

	KNOWN ISSUES:
	
---------------------------------------------------------------------------------------------*/

package hislope.core
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////
	
	import com.bit101.components.Style;
	import com.bit101.components.Label;
	import com.bit101.components.VSlider;
	
	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;
	import hislope.filters.FilterBase;
	import hislope.gui.FilterPanel;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	import flash.geom.Rectangle;
	
	// CLASS //////////////////////////////////////////////////////////////////////////////////
		
    public class FilterChain extends Sprite
    {
		// CONSTANTS //////////////////////////////////////////////////////////////////////////
		
		public static var _currentPanel:FilterPanel = null;
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
    	private var numFilters:int;
        private var debugMode:Boolean;
        private var filtersArray:Array;
		private var filterPanelsArray:Array;
		private var filterPanel:FilterPanel;
		private var vSlider:VSlider;
		private var panelsMask:Sprite = new Sprite();
		private var sizeY:Number;
		private var scrollPosDest:Number = 0;
		private var scrollPos:Number = 0;
		private var panelsHolder:Sprite = new Sprite();
		private var totalTime:Number = 0;
		private var info:Label;
		private var fitPreview:Boolean;
		
		public var previewScale:Number = 1.0;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////

        public function FilterChain(
			name:String = "Filter Chain",
			processingWidth:int = 320,
			processingHeight:int = 240,
			debug:Boolean = true,
			fitPreview:Boolean = true,
			sizeY:int = 600
		) {
			this.name = name;
			this.sizeY = sizeY;
			
			FilterBase.WIDTH = processingWidth;
			FilterBase.HEIGHT = processingHeight;
			
			//TODO make sure preview is smaller than 320x240 when bigger
			if (fitPreview) previewScale = FilterBase.PREVIEW_WIDTH / processingWidth;

            debugMode = debug;
			
			if (debugMode) if (stage) init(); else addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			
			filtersArray = [];
			filterPanelsArray = [];
            numFilters = 0;
        }

		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

        public function addFilter(filter:FilterBase, preview:Boolean = false, histogram:Boolean = false, showParams:Boolean = true, enabled:Boolean = true):void
        {
			trace("adding filter", filter);
			
			filtersArray.push(filter);

			if (debugMode)
			{
				filterPanel = new FilterPanel(filter, previewScale);
				panelsHolder.addChild(filterPanel);
				filterPanelsArray.push(filterPanel);
				filterPanel.addEventListener(FilterPanel.CHANGE_SIZE, renderPanels);
				filterPanel.filterEnabled = enabled;
				filterPanel.previewVisible = preview;
				filterPanel.histogramVisible = histogram;
				filterPanel.paramsVisible = showParams;
			} else {
				filter.enabled = enabled;
			}

			filter.generatePreview = preview;
			
			numFilters++;
        }

        public function removeFilter(enableOutput:Number):void
        {
			filtersArray.splice(enableOutput, 1);
            numFilters--;
        }

		public function renderPanels(event:Event = null):void
		{
			var offsetY:int = 20;
			
			for each (filterPanel in filterPanelsArray)
			{
				filterPanel.y = offsetY;
				offsetY += filterPanel.height;
			}
			
			vSlider.visible = (offsetY > sizeY);
			if (!vSlider.visible)
			{
				panelsHolder.y = 0;
				vSlider.value = 1;
			}
			
			// fill background
			
			panelsHolder.graphics.clear();
			panelsHolder.graphics.beginFill(0x000000, 0.85);
			panelsHolder.graphics.drawRect(0, 0, 320, offsetY);
		}

        public function enableOutput():void
        {
        }

        public function disableOutput():void
        {
        }

        public function process(metaBmpData:MetaBitmapData):void
        {
			/*metaBmpData.draw(testScreen);*/
	
			if (filtersArray.length == 0)
			{
				info.text = this.name.toUpperCase() + " has no filters.";
				return;
			}
			
            var filterId:int = 0;
            var startTime:Number;
            var endTime:Number;
			var filterTime:Number;
            var filter:FilterBase;

			metaBmpData.resetROI();

			if (!debugMode)
            {
                do {
					filter = filtersArray[filterId];
					if (filter.enabled) filter.process(metaBmpData);
				}  while (filterId++ < numFilters - 1);
            }
			
			else
			{
				totalTime = 0;
				
				do {
					filter = filtersArray[filterId];
					startTime = getTimer();
					if (filter.enabled) filter.process(metaBmpData);
					endTime = getTimer();
					filterTime = endTime - startTime;
					filter.time = filterTime;
					totalTime += filterTime;
				} while (filterId++ < numFilters - 1);
				
				info.text = this.name.toUpperCase() + " total: " + totalTime + " ms";
            }
        }

		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		private function init(event:Event = null):void
		{
			vSlider = new VSlider(this, 320, 0, scrollPanels);
			vSlider.setSize(10, sizeY);
			vSlider.minimum = 0;
			vSlider.maximum = 1;
			vSlider.value = 1;
			vSlider.tick = 0.01;
			vSlider.backClick = true;
			
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel, false, 0, true);
		
			panelsMask.graphics.beginFill(0x00ff00, 0.25);
			panelsMask.graphics.drawRect(0, 0, 320, sizeY);
		
			addChild(panelsMask);
			panelsHolder.mask = panelsMask;

			addChild(panelsHolder);
			
			setStyles();
			
			info = new Label(panelsHolder, 10, 0, "Filter Chain");
			stage.addEventListener(KeyboardEvent.KEY_UP, keyDown, false, 0, true);
			
			stage.stageFocusRect = false;
		}

		private function scrollPanels(event:Event = null):void
		{
			addEventListener(Event.ENTER_FRAME, scroll, false, 0, true);
			scrollPosDest = - (1 - vSlider.value) * (panelsHolder.height - sizeY);
			
			if (scrollPosDest > 0) scrollPosDest = 0;

			if (!scrollPosDest) scrollPosDest = 0;
		}
		
		private function scroll(event:Event):void
		{
			var diff:Number = scrollPosDest - scrollPos; 
			
			scrollPos += diff * 0.3;
			
			if (Math.abs(diff) < 0.1)
			{
				scrollPos = scrollPosDest;
				removeEventListener(Event.ENTER_FRAME, scroll);
			}
			
			panelsHolder.y = int(scrollPos);
		}
		
		private function mouseWheel(event:MouseEvent):void
		{
			vSlider.value += event.delta * 0.001;
			scrollPanels();
		}

		public function get debug():Boolean
		{
			return debugMode;
		}
		
		public function set debug(value:Boolean):void
		{
			debugMode = value;
		}
		
		public static function set currentPanel(value:FilterPanel):void
		{
			if (_currentPanel) _currentPanel.deselectPanel();
			_currentPanel = value;
			_currentPanel.selectPanel();
		}
		
		public static function get currentPanel():FilterPanel
		{
			return _currentPanel;
		}
		
		private function nextPanel():void
		{
			var currentIndex:int = filterPanelsArray.indexOf(_currentPanel);
			if (currentIndex < filterPanelsArray.length - 1) currentIndex++;
			currentPanel = filterPanelsArray[currentIndex];
		}
		
		private function prevPanel():void
		{
			var currentIndex:int = filterPanelsArray.indexOf(_currentPanel);
			if (currentIndex > 0) currentIndex--;
			currentPanel = filterPanelsArray[currentIndex];
		}
		
		private function setStyles():void
		{
			Style.BACKGROUND = 0x880000;
			Style.HANDLE_FACE = 0xFFFFFF;
			Style.BUTTON_FACE = 0x000000;
			Style.INPUT_TEXT = 0xFFFFFF;
			Style.LABEL_TEXT = 0xFFFFFF;
			Style.LABEL_BACKGROUND = 0x000000;
			Style.DROPSHADOW = 0x000000;
			Style.PANEL = 0x000000;
			Style.PROGRESS_BAR = 0xFFFFFF;
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		private function keyDown(event:KeyboardEvent):void
		{
			/*trace("key", event.keyCode);*/
			
			switch (event.keyCode)
			{
				case 38:
					if (!event.altKey)
					{
						prevPanel();
					} else {
						vSlider.value += 0.1;
						scrollPanels();
					}
				break;
				
				case 40:
					if (!event.altKey)
					{
						nextPanel();
					} else {
						vSlider.value -= 0.1;
						scrollPanels();
					}
				break;
				
				case 32:
					this.visible = !this.visible;
				break;
			}
			
			if (!currentPanel) return;
			
			switch (event.keyCode)
			{
				case 79:
					currentPanel.filterEnabled = !currentPanel.filterEnabled;
				break;
				
				case 80:
					currentPanel.previewVisible = !currentPanel.previewVisible;
				break;
				
				case 72:
					currentPanel.histogramVisible = !currentPanel.histogramVisible;
				break;
				
				case 37:
					if (!event.altKey) currentPanel.hideParams();
				break;
				
				case 39:
					if (!event.altKey) currentPanel.showParams();
				break;
			}
		}
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////

        override public function toString():String
        {
            return "[FilterChain " + name + "]";
        }
    }
}
