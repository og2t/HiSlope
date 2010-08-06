/*---------------------------------------------------------------------------------------------

	[AS3] FilterChain
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
	
	TODO: separate GUI from model 

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
	import flash.utils.getTimer;
	
	// CLASS //////////////////////////////////////////////////////////////////////////////////
		
    public class FilterChain extends Sprite
    {
		// CONSTANTS //////////////////////////////////////////////////////////////////////////
		
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
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////

        public function FilterChain(
			name:String = "Filter Chain",
			processingWidth:int = 320,
			processingHeight:int = 240,
			debug:Boolean = true,
			fitPreview:Boolean = true
		) {
			this.name = name;
			
			FilterBase.WIDTH = processingWidth;
			FilterBase.HEIGHT = processingHeight;
			
			//TODO make sure preview is smaller than 320x240 when bigger
			if (fitPreview) FilterBase.PREVIEW_SCALE = FilterBase.PREVIEW_WIDTH / processingWidth;

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
				filterPanel = new FilterPanel(filter);
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
			
			//vSlider.visible = (offsetY > sizeY); 
			
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
			sizeY = stage.stageHeight;

			vSlider = new VSlider(this, 320, 0, scrollPanels);
			vSlider.setSize(10, sizeY);
			vSlider.minimum = 0;
			vSlider.maximum = 1;
			vSlider.tick = 0.01;
			vSlider.value = 1;
			vSlider.backClick = true;
		
			panelsMask.graphics.beginFill(0x00ff00, 0.25);
			panelsMask.graphics.drawRect(0, 0, 320, sizeY);
		
			addChild(panelsMask);
			panelsHolder.mask = panelsMask;

			addChild(panelsHolder);
			info = new Label(panelsHolder, 10, 0, "Filter Chain");
			
			setStyles();
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
			
			scrollPos += diff * 0.7;
			
			if (Math.abs(diff) < 0.1)
			{
				scrollPos = scrollPosDest;
				removeEventListener(Event.ENTER_FRAME, scroll);
			}
			
			panelsHolder.y = int(scrollPos);
		}

		public function get debug():Boolean
		{
			return debugMode;
		}
		
		public function set debug(value:Boolean):void
		{
			debugMode = value;
		}

		private function setStyles():void
		{
			Style.BACKGROUND = 0x880000;
			Style.HANDLE_FACE = 0xFFFFFF;
			Style.BUTTON_FACE = 0x000000;
			Style.INPUT_TEXT = 0x333333;
			Style.LABEL_TEXT = 0xFFFFFF;
			Style.LABEL_BACKGROUND = 0x000000;
			Style.DROPSHADOW = 0x000000;
			Style.PANEL = 0x000000;
			Style.PROGRESS_BAR = 0xFFFFFF;
		}

        override public function toString():String
        {
            return "[FilterChain " + name + "]";
        }
    }
}
