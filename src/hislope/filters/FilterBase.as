/*---------------------------------------------------------------------------------------------

	[AS3] FilterBase
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

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.display.Shader;
	import flash.display.ShaderParameter;
	
	import hislope.filters.IFilter;
	
	import hislope.core.FilterChain;
	import hislope.core.FilterParser;
	import hislope.gui.FilterPanel;
	
	import hislope.events.HiSlopeEvent;
	import hislope.display.MetaBitmapData;

	import flash.events.EventDispatcher; 
	import flash.events.Event; 

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class FilterBase extends EventDispatcher implements IFilter
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		public static var PREVIEW_WIDTH:int = 320;
		public static var PREVIEW_HEIGHT:int = 240;
		
		public static var WIDTH:int = 320 * 2;
		public static var HEIGHT:int = 240 * 2;
		
		public static var PREVIEW_SMOOTHING:Boolean = true;

		public static const PI180:Number = Math.PI / 180;
		
		public static var stage:Stage;
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		protected var _name:String;
		protected var _defaultParams:Array;
		protected var _presetParams:Object;
		private var _debugVars:Array;
		private var _previewScale:Number = 1.0;
		private var previewScaleMatrix:Matrix = new Matrix();

		protected var point:Point;
		protected var rect:Rectangle;
		
		protected var _enabled:Boolean = true;
		protected var _displayPreview:Boolean = false;
		protected var _drawHistogram:Boolean = false;
		protected var fitPreview:Boolean;
		
		protected var _resultBmpData:MetaBitmapData;
		/*protected var _previousBmpData:BitmapData;*/

		private var _previewBmpData:BitmapData;
		private var _channelBmpData:BitmapData;

		protected var histogramBmpData:BitmapData;
		private var tempHistogramMap:BitmapData;
		private var _histogramChannels:int;
		public var _histogramData:Vector.<Vector.<Number>>;
		
		private var _time:int;
		private var _minTime:int;
		private var _maxTime:int;
		
		private var _storeResult:Boolean = false;
		
		private var filterPanel:FilterPanel;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function FilterBase() 
		{
			setProcessingSizes();

			_resultBmpData = new MetaBitmapData(FilterBase.WIDTH, FilterBase.HEIGHT, false, 0x0);
			/*_previousBmpData = new BitmapData(FilterBase.WIDTH, FilterBase.HEIGHT, false, 0x0);*/
			_previewBmpData = new BitmapData(FilterBase.PREVIEW_WIDTH, FilterBase.PREVIEW_HEIGHT, true, 0xff000000);
			_channelBmpData = new BitmapData(FilterBase.PREVIEW_WIDTH, FilterBase.PREVIEW_HEIGHT, true, 0xff000000);
			
			rect = _resultBmpData.rect;
			point = rect.topLeft;
			
			histogramChannels = 0x7;
			histogramBmpData = new BitmapData(256, 100, false, 0);
			tempHistogramMap = histogramBmpData.clone();
		}
		
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		public function setParam(paramName:String, value:*, updateAfter:Boolean = true):void
		{
			try
			{
				this[paramName] = value;
			}
			
			catch (error:Error)
			{
				throw new Error("Error: Value " + paramName + " not defined on " + _name + ". Use getter/setter or define variable as public.");
			}
			
			if (updateAfter) updateParams();
		}
		
		
		public function getParamValue(paramName:String):*
		{
			try
			{
				return this[paramName];
			}
			
			catch (error:Error)
			{
				throw new Error("Error: Value " + paramName + " not defined on " + _name + ". Use getter/setter or define variable as public.");
			}
		}
		
		
		public function updateParams():void
		{
			/*trace("updateParams");*/
			FilterParser.updateParams(this);
		}
		
		
		public function updateUIFor(name:String):void
		{
			updateUI(name, this[name]);
		}
		
		
		public function updatePanelUI():void
		{
			updateParams();
			FilterParser.updateParams(this, true);
		}
		
		
		public function updateUI(name:String, value:*):void
		{
			if (!filterPanel) return;
			
			/*trace("update slider", name, value, filterPanel);*/
			filterPanel.updateUI(name, value);
		}
		
		
		public function setProcessingSizes():void
		{
			if (FilterBase.WIDTH <= 0 || FilterBase.HEIGHT <= 0)
			{
				throw new Error("Error: processing dimensions must be greater than 0.");
			}
		}
		
		
		public function start():void
		{
			// to be implemented in subclasses
			/*throw new Error(this + " start() needs to be overwritten.");*/
		}
		
		
		public function stop():void
		{
			// to be implemented in subclasses
			/*throw new Error(this + " stop() needs to be overwritten.");*/
			
			dispatchEvent(new Event(HiSlopeEvent.INPUT_RENDERED));
		}
		
		
		public function mouseMovePoint(normPoint:Point):void
		{
			// to be implemented in subclasses
		}
		
		
		public function mouseDownPoint(normPoint:Point):void
		{
			// to be implemented in subclasses
		}
		
		
		public function mouseUpPoint(normPoint:Point):void
		{
			// to be implemented in subclasses
		}


		/**
		 *	Set initial values
		 */
		protected function init(name:String, defaultParams:Array = null, presetParams:Object = null, debugVars:Array = null):void
		{
			_name = name;
			_defaultParams = defaultParams;
			_presetParams = presetParams;
			_debugVars = debugVars;
			
			setParams();
			resetParams();
		}


		/**
		 * Processes metaBmpData
		 * @param metaBmpData MetaBitmapData 
		 */
		public function process(metaBmpData:MetaBitmapData):void
		{
			throw new Error("Error: You must overwrite method process(metaBmpData:MetaBitmapData) in your Filter class.");
		}

		
		/**
		 * Post processes
		 * @param bmpData BitmapData 
		 */
		public function postPreview(bmpData:*):void
		{
			// store metaBmpData as result
			if (_storeResult) _resultBmpData.copyPixels(bmpData, rect, point);
			
			dispatchEvent(new Event(HiSlopeEvent.FILTER_PROCESSED));

			/* Do not make previews if there's no panel */
			if (filterPanel == null) return;
			
			if (_drawHistogram) drawHistogram(bmpData.rect);

			if (fitPreview)
			{
				_previewBmpData.draw(_resultBmpData, previewScaleMatrix, null, null, null, PREVIEW_SMOOTHING);
				
				if (_histogramChannels != 7)
				{
					_channelBmpData.copyPixels(_previewBmpData, _previewBmpData.rect, _previewBmpData.rect.topLeft);
					_previewBmpData.fillRect(rect, 0xFF000000);
					_previewBmpData.copyChannel(_channelBmpData, rect, point, _histogramChannels, _histogramChannels);
				}
				
			} else {
				
				if (_histogramChannels != 7)
				{
					_previewBmpData.fillRect(rect, 0xFF000000);
					_previewBmpData.copyChannel(_resultBmpData, rect, point, _histogramChannels, _histogramChannels);
				}
			}
		}
		

		public function resetParams():void
		{
			FilterParser.resetParams(this);
		}


		public function randomiseParams():void
		{
			FilterParser.randomiseParams(this);
		}
		
		
		public function randomiseColors(event:Event = null):void
		{
			FilterParser.randomiseParams(this, true);
		}


		public function dispose():void
		{
			_resultBmpData.dispose();
			_resultBmpData = null;
			
			// TODO remove other stuff here as well
		}
		
		
		public function lowQuality():void
		{
			if (stage) stage.quality = StageQuality.LOW;
		}
		
		
		public function highQuality():void
		{
			if (stage) stage.quality = StageQuality.HIGH;
		}
		
		
		protected function getHistogramDataFor(source:MetaBitmapData, useROI:Boolean = false):void
		{
			if (useROI) _histogramData = source.histogram(source.roi);
			else _histogramData = source.histogram(source.rect);
		}
		

		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		private function setParams():void
		{
			FilterParser.setParams(this);
		}
		
		
		private function drawHistogram(rect:Rectangle):void
		{
			// FIXME attribute Quasimondo
			
			_histogramData = _resultBmpData.histogram(rect);
			
			var j:int, i:int;
			var maxValue:Number, value:Number;
			var channel:Vector.<Number>;

			var hRect:Rectangle = histogramBmpData.rect;
			hRect.width = 1;

			for (var c:int = 0; c < 3; c++)
			{
				channel = _histogramData[c];
				maxValue = 0.0;
				i = 256;
				
				while (i > 0)
				{
					value = channel[--i];
					if (value > maxValue) maxValue = value;
				}
				
				tempHistogramMap.fillRect(histogramBmpData.rect, 0x000000);
			
				for (i = 0; i < 256; i++)
				{
					hRect.x = i;
					hRect.height = 100 * channel[i] / maxValue;
					hRect.y = 100 - hRect.height;
					tempHistogramMap.fillRect(hRect, 0xff);
				}
				
				if (_histogramChannels & (1 << c))
				{
					histogramBmpData.copyChannel(tempHistogramMap, tempHistogramMap.rect, tempHistogramMap.rect.topLeft, 4, 1 << c);
				}
			}
		}
		
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		
		public function get defaultParams():Object
		{
			return _defaultParams;
		}

		
		public function get presetParams():Object
		{
			return _presetParams;
		}
		

		public function get debugVars():Array
		{
			return _debugVars;
		}


		public function get resultMetaBmpData():MetaBitmapData
		{
			return _resultBmpData;
		}

		
		public function get resultBitmapData():BitmapData
		{
			return _resultBmpData.clone() as BitmapData;
		}

		
		public function set previewScale(value:Number):void
		{
			_previewScale = value;
			previewScaleMatrix.identity();
			previewScaleMatrix.scale(_previewScale, _previewScale);
			
			FilterBase.PREVIEW_WIDTH = FilterBase.WIDTH * _previewScale;
			FilterBase.PREVIEW_HEIGHT = FilterBase.HEIGHT * _previewScale;
			
			_previewBmpData = new BitmapData(FilterBase.PREVIEW_WIDTH, FilterBase.PREVIEW_HEIGHT, true, 0xff000000);
			_channelBmpData = new BitmapData(FilterBase.PREVIEW_WIDTH, FilterBase.PREVIEW_HEIGHT, true, 0xff000000);
		}

		
		public function get previewScale():Number
		{
			return _previewScale;
		}

		
		public function get previewBmpData():BitmapData
		{
			if (_previewScale == 1 && _histogramChannels == 7) return _resultBmpData;
			return _previewBmpData;
		}

		
		public function get histogram():BitmapData
		{
			return histogramBmpData;
		}


		public function get histogramData():Vector.<Vector.<Number>>
		{
			return _histogramData;
		}
		
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			if (_enabled) start(); else stop();
			
			_minTime = 10000;
			_maxTime = 0;
			
			if (filterPanel) filterPanel.updatePanelState();
		}
		
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		
		public function set displayPreview(value:Boolean):void
		{
			_displayPreview = value;
			
			fitPreview = !(_previewScale == 1);
		}
		
		
		public function set generateHistogram(value:Boolean):void
		{
			_drawHistogram = value;
		}
		
		
		public function get generateHistogram():Boolean
		{
			return _drawHistogram;
		}
		
		
		public function get name():String
		{
			return _name;
		}
		
		
		public function get time():int
		{
			return _time;
		}
		
		
		public function get minTime():int
		{
			return _minTime;
		}
		
		
		public function get maxTime():int
		{
			return _maxTime;
		}
		
		
		public function set time(value:int):void
		{
			_time = value;
			
			if (_time < _minTime) _minTime = _time;
			if (_time > _maxTime) _maxTime = _time; 
		}
		
		
		public function set storeResult(value:Boolean):void
		{
			_storeResult = value;
		}
		
		
		public function get storeResult():Boolean
		{
			return _storeResult;
		}
		
		
		public function set histogramChannels(value:int):void
		{
			_histogramChannels = value;
			if (histogramBmpData) histogramBmpData.fillRect(histogramBmpData.rect, 0x000000);
		}
		
		
		public function get width():Number
		{
			return _resultBmpData.width;
		}


		public function get height():Number
		{
			return _resultBmpData.height;
		}

		
		/**
		 *	Sets reference to the FilterPanel
		 */
		public function set panel(value:FilterPanel):void
		{
			filterPanel = value;
		}

		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
		
		override public function toString():String
		{
			return "[Filter " + _name + "]";
		}
	}
}