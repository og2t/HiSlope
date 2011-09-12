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
	import hislope.core.ChainStats;
	import hislope.core.ChainFooter;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	
	import flash.ui.Keyboard;
	
	// CLASS //////////////////////////////////////////////////////////////////////////////////
		
    public class FilterChain extends Sprite
    {
		// CONSTANTS //////////////////////////////////////////////////////////////////////////
		
		public static var _currentPanel:FilterPanel = null;
		[Embed(source="../../assets/sounds/subtle.mp3")]
		public static const UISound:Class;
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
    	private var numFilters:int;
        private var debugMode:Boolean;
        
		private var filtersArray:Vector.<FilterBase>;
		private var filterPanelsArray:Array;
		
		private var filterPanel:FilterPanel;
		
		private var vSlider:VSlider;
		private var sliderHeight:Number;
		private var visibleHeight:Number;
		
		private var scrollPosDest:Number = 0;
		private var scrollPos:Number = 0;
		
		private var fitPreview:Boolean;

		private var testScreen:Sprite = new Sprite();
		private var panelsBgrd:Shape = new Shape();	

		private var panelsContainer:Sprite = new Sprite();
		private var panelsHolder:Sprite = new Sprite();

		private var chainStats:ChainStats;
		private var chainFooter:ChainFooter;
		
		public var previewScale:Number = 1.0;
		private var uiSound:Sound = new UISound();
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////

        public function FilterChain(
			name:String = "Filter Chain",
			processingWidth:int = 320,
			processingHeight:int = 240,
			debug:Boolean = true,
			visibleHeight:int = -1,
			fitPreview:Boolean = true
		) {
			this.name = name;
			
			FilterBase.WIDTH = processingWidth;
			FilterBase.HEIGHT = processingHeight;

            debugMode = debug;
			this.visibleHeight = visibleHeight;
			
			
			
			// TODO make sure preview is smaller than 320x240 when bigger
			if (fitPreview) previewScale = FilterBase.PREVIEW_WIDTH / processingWidth;
			
			if (debugMode)
			{
				setStyles();
				
				if (stage) setupDebug(); else addEventListener(Event.ADDED_TO_STAGE, setupDebug, false, 0, true);
				drawTestScreen(processingWidth, processingHeight);
			}
			
			filtersArray = new Vector.<FilterBase>();
			filterPanelsArray = [];
            numFilters = 0;
        }

		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

        public function addFilter(filter:FilterBase, preview:Boolean = true, histogram:Boolean = false, showParams:Boolean = true, enabled:Boolean = true):void
        {
			trace("adding filter", filter);
			
			filtersArray.push(filter);

			if (debugMode)
			{
				filter.storeResult = true;
				filterPanel = new FilterPanel(filter, previewScale);
				panelsContainer.addChild(filterPanel);
				filterPanelsArray.push(filterPanel);
				filterPanel.addEventListener(FilterPanel.CHANGE_SIZE, renderPanels);
				filterPanel.filterEnabled = enabled;
				filterPanel.previewVisible = preview;
				filterPanel.histogramVisible = histogram;
				filterPanel.paramsVisible = showParams;
			} else {
				filter.enabled = enabled;
			}

			filter.displayPreview = preview;
			
			numFilters++;
        }


        public function removeFilter(enableOutput:Number):void
        {
			filtersArray.splice(enableOutput, 1);
            numFilters--;
        }


		public function renderPanels(event:Event = null):void
		{
			var offsetY:int = 0;
			
			for each (filterPanel in filterPanelsArray)
			{
				filterPanel.y = offsetY;
				offsetY += filterPanel.height;
			}

			vSlider.visible = (offsetY >= visibleHeight);

			if (vSlider.visible)
			{
				scrollPanels();
			} else {
				panelsContainer.y = 0;
				vSlider.value = 1;
			}
			
			panelsBgrd.height = offsetY;
		}

        public function enableOutput():void
        {
        }


        public function disableOutput():void
        {
        }


        public function process(metaBmpData:MetaBitmapData):void
        {
			if (debugMode && filtersArray.length == 0)
			{
				chainStats.status = "has no filters.";
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
				var totalTime:int = 0;
				
				/*metaBmpData.draw(testScreen);*/
				
				do {
					filter = filtersArray[filterId];
					startTime = getTimer();
					if (filter.enabled) filter.process(metaBmpData);
					endTime = getTimer();
					filterTime = endTime - startTime;
					filter.time = filterTime;
					totalTime += filterTime;
				} while (filterId++ < numFilters - 1);
				
				chainStats.chainTime = totalTime;
            }
        }

		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		private function setupDebug(event:Event = null):void
		{
			chainStats = new ChainStats(name);
			chainFooter = new ChainFooter();

			if (visibleHeight == -1)
			{
				visibleHeight = stage.stageHeight;
				stage.addEventListener(Event.RESIZE, stageResized, false, 0, true);
			}
			
			sliderHeight = visibleHeight;
			
			vSlider = new VSlider(this, 321, 0, scrollPanels);
			vSlider.setSize(10, sliderHeight);
			vSlider.minimum = 0;
			vSlider.maximum = 1;
			vSlider.value = 1;
			vSlider.tick = 0.01;
			vSlider.backClick = true;

			addChild(panelsHolder);
			
			// fill background
			panelsBgrd.graphics.clear();
			panelsBgrd.graphics.beginFill(0x000000, 0.85);
			panelsBgrd.graphics.drawRect(0, 0, 320, 100);

			panelsHolder.addChild(panelsBgrd);
			panelsHolder.addChild(panelsContainer);
			
			addChild(chainStats);
			panelsHolder.y = ChainStats.HEIGHT;
			
			addChild(chainFooter);
			
			updatePostition();

			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyPressed, false, 0, true);
			
			stage.stageFocusRect = false;
		}


		private function scrollPanels(event:Event = null):void
		{
			addEventListener(Event.ENTER_FRAME, scroll, false, 0, true);
			scrollPosDest = - (1 - vSlider.value) * (panelsContainerHeight - visibleHeight);
			
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
			
			panelsContainer.y = int(scrollPos);
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
		
		
		private function updatePostition():void
		{
			visibleHeight = sliderHeight - (ChainStats.HEIGHT + ChainFooter.HEIGHT);
			vSlider.height = sliderHeight;
			chainFooter.y = sliderHeight - ChainFooter.HEIGHT;
			panelsHolder.scrollRect = new Rectangle(0, 0, 320 + vSlider.width + 1, visibleHeight);
		}
		
		
		/**
		 * Applies custom HiSlope colour theme for bit-101's MinimalComps
		 */
		private function setStyles():void
		{
			/*const MAIN_THEME:uint = 0x521965;*/
			const MAIN_THEME:uint = 0x880000;
			
			Style.BACKGROUND = MAIN_THEME;
			Style.HANDLE_FACE = 0xFFFFFF;
			Style.BUTTON_FACE = 0x000000;
			Style.INPUT_TEXT = 0xFFFFFF;
			Style.LABEL_TEXT = 0xFFFFFF;
			Style.LABEL_BACKGROUND = 0x000000;
			Style.DROPSHADOW = 0x000000;
			Style.PANEL = 0x000000;
			Style.PROGRESS_BAR = 0xFFFFFF;
			
			Style.BUTTON_DOWN = 0xEEEEEE;
			Style.TEXT_BACKGROUND = 0xFFFFFF;
			Style.LIST_DEFAULT = 0x000000;
			Style.LIST_ALTERNATE = MAIN_THEME;
			Style.LIST_SELECTED = MAIN_THEME;
			Style.LIST_ROLLOVER = 0xEE0000;
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		private function onMouseWheel(event:MouseEvent):void
		{
			vSlider.value += event.delta * 0.001;
			scrollPanels();
		}
		
		
		private function stageResized(event:Event):void
		{
			sliderHeight = stage.stageHeight;
			
			updatePostition();
			renderPanels();
		}
		
		
		private function keyPressed(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.UP:
					prevPanel();
				break;
				
				case Keyboard.DOWN:
					nextPanel();
				break;
				
				case 32:
					this.visible = !this.visible;
				break;
			}
			
			if (!currentPanel) return;
			
			switch (event.keyCode)
			{
				case Keyboard.O:
					currentPanel.filterEnabled = !currentPanel.filterEnabled;
					break;
				
				case Keyboard.P:
					currentPanel.previewVisible = !currentPanel.previewVisible;
					break;
				
				case Keyboard.H:
					currentPanel.histogramVisible = !currentPanel.histogramVisible;
					break;
					
				case Keyboard.V:
					currentPanel.debugVarsVisible = !currentPanel.debugVarsVisible;
				break;
				
				case Keyboard.LEFT:
					//if (!event.altKey) 
					currentPanel.hideParams();
					break;
				
				case Keyboard.RIGHT:
					//if (!event.altKey)
					currentPanel.showParams();
					break;
			}
			
			/*uiSound.play();*/
		}
		
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		
		override public function get width():Number
		{
			// panel width + slider
			return 320 + 12;
		}
		
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////

		private function drawTestScreen(screenWidth:int, screenHeight:int):void
		{
			testScreen.graphics.beginFill(0x404040, 0);
			testScreen.graphics.lineStyle(0, 0x808080, 1);
			testScreen.graphics.drawRect(0, 0, screenWidth - 1, screenHeight - 1);
			testScreen.graphics.endFill();
			testScreen.graphics.moveTo(0, 0);
			testScreen.graphics.lineTo(screenWidth - 1, screenHeight - 1);
			testScreen.graphics.moveTo(screenWidth - 1, 0);
			testScreen.graphics.lineTo(0, screenHeight - 1);
		}
		

		public function get panelsContainerHeight():Number
		{
			var totalHeight:Number = 0;
			var numPanels:int = panelsContainer.numChildren;
			
			while (--numPanels >= 0)
			{
				totalHeight += (panelsContainer.getChildAt(numPanels) as FilterPanel).height;
			}
			
			return totalHeight;
		}
		

        override public function toString():String
        {
            return "[FilterChain " + name + "]";
        }
    }
}
