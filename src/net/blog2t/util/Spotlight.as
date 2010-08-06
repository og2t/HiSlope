/*---------------------------------------------------------------------------------------------

	[AS3] Spotlight
	=======================================================================================

	(c) 2010 Tomek 'Og2t' Augustyn
	http://play.blog2t.net/

	You are free to use this source code in any project. 
	You are free to modify this source code in anyway you see fit.
	You are free to distribute this source code.

	You may NOT charge anything for this source code.
	This notice and the copyright information must be left intact in any distribution of this source code. 
	You are encouraged to release any improvements back to the ActionScript community.

	VERSION HISTORY:
	v0.1	Born on 2008/9/4
	v0.3	2008/10/17	Fixed on(), off() if triggered often ie. onMouseMove
						Added key control for params
	v0.4	2009/5/14	Added overlayColor and changed zoom scale to up

	USAGE:
	
	- add usage

	TODOs:

	- needs tidying up

	DEV IDEAS:
	
	? add object focus by drawing the MC onto the bitmap over everything
	
	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package net.blog2t.util
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filters.BlurFilter;
	
	import gs.TweenLite;
	import fl.motion.easing.Exponential;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Spotlight extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private const TRANSITION_SPEED:Number = 0.5;
		private const ZOOM_SCALE:Number = 5;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var _sizeX:Number;
		private var _sizeY:Number;
		
		private var _overlayOpacity:Number = 0.75;
		private var _radius:Number = 50;
		private var _blur:Number = 10;
		private var _centerX:Number = 0;
		private var _centerY:Number = 0;
		private var _overlayColor:uint = 0x000000;
				
		private var _isOn:Boolean = false;
		private var _isDimmed:Boolean = false;
		
		private var spotlightBlur:BlurFilter = new BlurFilter(_blur, _blur, 2);
		
		private var spotlight:Shape = new Shape();
		private var overlay:Shape = new Shape();
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Spotlight(sizeX:Number = 100, sizeY:Number = 100, opacity:Number = 0.75) 
		{
			_sizeX = sizeX;
			_sizeY = sizeY;
			_overlayOpacity = opacity;

			// "layer" mode needs to be set in order for the erase mode to work
			blendMode = BlendMode.LAYER;
			addChild(overlay);
			addChild(spotlight);
			spotlight.blendMode = BlendMode.ERASE;

			spotlight.scaleX = 0;
			spotlight.scaleY = 0;
			alpha = 0;
			visible = false;

			spotlightBlur.blurX = spotlightBlur.blurY = _blur;
			spotlight.filters = [spotlightBlur];

			drawOverlay();
			redraw();

			mouseEnabled = false;
 			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
				
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		public function dim():void
		{
			if (_isDimmed) return;

			if (!_isOn) on();
			
			_isDimmed = true;
			
			TweenLite.to(spotlight, TRANSITION_SPEED,
			{
				scaleX: 0,
				scaleY: 0,
				ease: Exponential.easeOut
			});
		}
		
		public function undim(setRadius:Number = -1, setBlur:Number = -1, setCenterX:Number = -1, setCenterY:Number = -1):void
		{
			if (!_isDimmed && !isOn) return;

			_isDimmed = false;
			
			if (setRadius != -1) radius = setRadius;
			if (setBlur != -1) blur = setBlur;
			if (setCenterX != -1) centerX = setCenterX;
			if (setCenterY != -1) centerY = setCenterY;
			
			TweenLite.to(spotlight, TRANSITION_SPEED,
			{
				scaleX: 1,
				scaleY: 1,
				ease: Exponential.easeOut
			});
		}
		
		public function on(setRadius:Number = -1, setBlur:Number = -1, setCenterX:Number = -1, setCenterY:Number = -1):void
		{
			if (_isOn) return;
			
			_isOn = true;
			
			//may be move these into a separate function?
			
			if (setRadius != -1) radius = setRadius;
			if (setBlur != -1) blur = setBlur;
			if (setCenterX != -1) centerX = setCenterX;
			if (setCenterY != -1) centerY = setCenterY;
			
			TweenLite.to(this, TRANSITION_SPEED,
			{
				autoAlpha: _overlayOpacity,
				ease: Exponential.easeInOut
			});
			
			TweenLite.to(spotlight, TRANSITION_SPEED,
			{
				scaleX: 1,
				scaleY: 1,
				ease: Exponential.easeInOut
			});
		}
		
		public function off(setRadius:Number = -1, setBlur:Number = -1):void
		{
			if (!_isOn) return;
			
			_isOn = false;
			
			TweenLite.to(this, TRANSITION_SPEED,
			{
				autoAlpha: 0,
				onComplete: function():void
				{
					if (setRadius != -1) radius = setRadius;
					if (setBlur != -1) blur = setBlur;
				},
				ease: Exponential.easeInOut
			});
			
			TweenLite.to(spotlight, TRANSITION_SPEED,
			{
				scaleX: ZOOM_SCALE,
				scaleY: ZOOM_SCALE,
				ease: Exponential.easeInOut
			});
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
				
		public function redraw():void
		{
			if (_isOn) drawOverlay();
			
			spotlight.graphics.clear();
			// the colour doesn't matter as ERASE blendMode cares about alpha
			spotlight.graphics.beginFill(0x000000, 1);			
			spotlight.graphics.drawCircle(0, 0, _radius);
		}

		private function drawOverlay():void
		{
			overlay.graphics.clear();
			overlay.graphics.beginFill(_overlayColor, _overlayOpacity);
			overlay.graphics.drawRect(0, 0, _sizeX, _sizeY);
		}
				
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		private function init(event:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
				
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		
		public function get isOn():Boolean
		{
			return _isOn;
		}
		
		public function set isOn(value:Boolean):void
		{
			visible = true;
			alpha = 1;
			_isOn = value;
		}
		
		public function get isDimmed():Boolean
		{
			return _isDimmed;
		}
				
		public function set radius(value:Number):void
		{
			_radius = value;
			redraw();
		}
		
		public function get radius():Number
		{
			return _radius;
		}
		
		public function set color(value:uint):void
		{
			_overlayColor = value;
			drawOverlay();
		}
		
		public function get color():uint
		{
			return _overlayColor;
		}
		
		public function set opacity(value:Number):void
		{
			if (value > 1) value = 1;
			
			_overlayOpacity = value;
			//if (_isOn) alpha = _overlayOpacity;
		}
		
		public function get opacity():Number
		{
			return _overlayOpacity;
		}
		
		public function set blur(value:Number):void
		{
			_blur = value;		
			spotlightBlur = new BlurFilter(_blur, _blur, 2);
			spotlight.filters = [spotlightBlur];
		}
		
		public function get blur():Number
		{
			return _blur;
		}
		
		public function set centerX(value:Number):void
		{
			if (value < 0 || value > _sizeX) return;
			_centerX = value;
			spotlight.x = _centerX;
		}
		
		public function get centerX():Number
		{
			return _centerX;
		}
		
		public function set centerY(value:Number):void
		{
			if (value < 0 || value > _sizeY) return;
			
			_centerY = value;
			spotlight.y = _centerY;
		}
		
		public function get centerY():Number
		{
			return _centerY;
		}
		
		override public function set width(value:Number):void
		{
			_sizeX = value;
			drawOverlay();
		}
		
		override public function set height(value:Number):void
		{
			_sizeY = value;
			drawOverlay();
		}
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}