/*---------------------------------------------------------------------------------------------

	[AS3] FilterBase
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
	import hislope.filters.IFilter;
	import hislope.core.FilterChain;
	import hislope.events.HiSlopeEvent;
	import hislope.display.MetaBitmapData;
	/*import net.blog2t.util.print_r;*/
	import __AS3__.vec.Vector;
	import flash.events.EventDispatcher; 
	import flash.events.Event; 
	import flash.display.Shader;
	import flash.display.ShaderParameter;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class FilterBase extends EventDispatcher implements IFilter
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		public static var PREVIEW_WIDTH:int = 320;
		public static var PREVIEW_HEIGHT:int = 240;
		
		public static var WIDTH:int = 320;
		public static var HEIGHT:int = 240;
		public static var PREVIEW_SCALE:Number = 1;
		public static var PREVIEW_SMOOTHING:Boolean = true;
		public static var FIT_PREVIEW:Boolean = true;

		public static var PROCESSED:String = "processed";
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		protected var _name:String;
		protected var _defaultParams:Array;
		protected var _presetParams:Object;
		private var _debugVars:Array;

		protected var point:Point;
		protected var rect:Rectangle;
		
		protected static var previewScaleMatrix:Matrix = new Matrix();

		protected var _enabled:Boolean = true;
		protected var _generatePreview:Boolean = false;
		protected var _drawHistogram:Boolean = false;
		
		protected var _resultBmpData:MetaBitmapData;
		protected var _previousBmpData:BitmapData;

		private var _previewBmpData:BitmapData;

		protected var histogramBmpData:BitmapData;
		private var tempHistogramMap:BitmapData;
		private var _histogramChannels:int;
		public var _histogramData:Vector.<Vector.<Number>>;
		
		protected var _time:int;
		
		private var filterPanel:Object;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function FilterBase() 
		{
			setProcessingSize(FilterBase.WIDTH, FilterBase.HEIGHT);

			_resultBmpData = new MetaBitmapData(FilterBase.WIDTH, FilterBase.HEIGHT, false, 0x0);
			_previousBmpData = new BitmapData(FilterBase.WIDTH, FilterBase.HEIGHT, false, 0x0);
			_previewBmpData = new BitmapData(FilterBase.PREVIEW_WIDTH, FilterBase.PREVIEW_HEIGHT, true, 0xff000000);
			
			rect = _resultBmpData.rect;
			point = rect.topLeft;
			
			histogramChannels = 0x7;
			histogramBmpData = new BitmapData(256, 100, false, 0);
			tempHistogramMap = histogramBmpData.clone();
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		public function setProcessingSize(width:int, height:int):void
		{
			if (width > 0 && height > 0)
			{
				FilterBase.WIDTH = width;
				FilterBase.HEIGHT = height;
				setPreviewScale(FilterBase.PREVIEW_SCALE);
			} else {
				throw new Error("Error: wrong bitmap sizes");
			}
		}
		
		public function setPreviewScale(previewScale:Number):void
		{
			FilterBase.PREVIEW_SCALE = previewScale;
			
			previewScaleMatrix.identity();
			previewScaleMatrix.scale(FilterBase.PREVIEW_SCALE, FilterBase.PREVIEW_SCALE);
		}
		
		/*public function fitPreviewScale(scale:Number):void
		{
			var previewScale:Number = scale * 2;
			if (previewScale > 1) previewScale = 1 / previewScale;
			setPreviewScale(previewScale);
		}*/
		
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
		 * Post processes
		 * @param metaBmpData MetaBitmapData 
		 */
		public function process(metaBmpData:MetaBitmapData):void
		{
			throw new Error("Error: You must overwrite method process(metaBmpData:MetaBitmapData) in your Filter class.");
			// this gets overwritten in the subclass 
		}
		
		public function getPreviewFor(metaBmpData:MetaBitmapData):void
		{
			/* Do not make previews if there's no panel */
			if (!filterPanel) return;
			
			//trace(this, rect, point);
			
			// store metaBmpData as result
			_resultBmpData.copyPixels(metaBmpData, rect, point);
			
			if (_drawHistogram) drawHistogram();
			if (_generatePreview) _previewBmpData.draw(_resultBmpData, previewScaleMatrix, null, null, null, PREVIEW_SMOOTHING);
			
			if (_histogramChannels != 7)
			{
				_previewBmpData.fillRect(rect, 0xFF000000);
				_previewBmpData.copyChannel(_resultBmpData, rect, point, _histogramChannels, _histogramChannels);
			}
			
			dispatchEvent(new Event(FilterBase.PROCESSED));
		}

		public function updateParams():void
		{
			if (!filterPanel) return;

			// check what had changed and update UI accordingly
			for each (var param:Object in _defaultParams)
			{
				if (param.type == "button") continue;
				
				if (this[param.name] != param.lastValue)
				{
					trace("param changed:", param.name, this[param.name]);
					param.lastValue = this[param.name];
					updateUI(param.name, this[param.name])
				}
			}
		}
		
		public function resetParams():void
		{
			trace("RESET FILTER PARAMS");
			
			for each (var param:Object in _defaultParams)
			{
				if (param.type == "button") continue;
			
				if (param.type != undefined)
				{
					param.type = param.type.toLowerCase();
				} else {
					// auto detect param type (number or boolean only)
					param.type = typeof this[param.name];
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
			
				setParam(param.name, param.current, false);
				updateUI(param.name, param.current);
			}
			
			updateParams();
		}

		public function dispose():void
		{
			_resultBmpData.dispose();
			_resultBmpData = null;
		}
		
		public function restrictToRegion(region:Rectangle):void
		{
			//trace(this, ": restrictToRegion", region);
			
			rect = region;
			point = rect.topLeft;
		}
		
		public function randomiseParams():void
		{
			if (filterPanel) filterPanel.randomiseParams();
		}
		
		public function randomiseColors():void
		{
			if (filterPanel) filterPanel.randomiseParams(true);
		}
		
		public function updateUI(name:String, value:*):void
		{
			if (!filterPanel) return;
			
			/*trace("update slider", name, value, filterPanel);*/
			filterPanel.updateUI(name, value);
		}
		
		public function setParam(name:String, value:*, updateAfter:Boolean = true):void
		{
			try
			{
				this[name] = value;
			}
			catch (error:Error)
			{
				throw new Error("Error: Value " + name + " not defined on " + _name + ". Use getter/setter or define variable as public.");
			}
			
			if (updateAfter) updateParams();
		}
		
		public function getParamValue(name:String):*
		{
			try
			{
				return this[name];
			}
			catch (error:Error)
			{
				throw new Error("Error: Value " + name + " not defined on " + _name + ". Use getter/setter or define variable as public.");
			}
		}
		
		public function getHistogramDataFor(source:MetaBitmapData):void
		{
			_histogramData = source.histogram(source.rect);
		}
				
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		private function setParams():void
		{
			trace("\n" + this, "_presetParams", _presetParams);
			
			if (_presetParams)
			{
				for (var paramName:String in _presetParams)
				{
					trace("\tOVERRIDES\n\t", paramName + ": " + _presetParams[paramName]);
					
					setParam(paramName, _presetParams[paramName], false);

					// nasty: update default params for this instance
					for (var i:int = 0; i < _defaultParams.length; i++)
					{
						if (_defaultParams[i].name == paramName)
						{
							trace("\tOVERRIDE " + paramName + " from: " + _defaultParams[i].current + " to: " + _presetParams[paramName]);
							_defaultParams[i].current = _presetParams[paramName];
						}
					}
				}
			}
		}
		
		private function drawHistogram():void
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
		
		public function get params():Object
		{
			return _defaultParams;
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
		
		public function get preview():BitmapData
		{
			trace("!", _histogramChannels);
			
			if (FilterBase.PREVIEW_SCALE == 1 && _histogramChannels == 7) return _resultBmpData;
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
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set generatePreview(value:Boolean):void
		{
			_generatePreview = value;
			
			if (PREVIEW_SCALE == 1) _generatePreview = false;
		}
		
		public function set generateHistogram(value:Boolean):void
		{
			_drawHistogram = value;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get time():int
		{
			return _time;
		}
		
		public function set time(value:int):void
		{
			_time = value;
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
		public function set panel(value:Object):void
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