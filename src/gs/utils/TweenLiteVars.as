/*
VERSION: 0.9
DATE: 7/15/2008
ACTIONSCRIPT VERSION: 3.0
DESCRIPTION:
	There are 2 primary benefits of using this utility to define your TweenLite variables:
		1) In most code editors, code hinting will be activated which helps remind you which special properties are available in TweenLite
		2) It allows you to code using strict datatyping (although it doesn't force you to).

USAGE:
	
	Instead of TweenLite.to(my_mc, 1, {x:300, tint:0xFF0000, onComplete:myFunction}), you could use this utility like:
	
		var myVars:TweenLiteVars = new TweenLiteVars();
		myVars.addProp("x", 300); // use addProp() to add any property that doesn't already exist in the TweenLiteVars instance.
		myVars.tint = 0xFF0000;
		myVars.onComplete = myFunction;
		TweenLite.to(my_mc, 1, myVars);
		
	Or if you just want to add multiple properties with one function, you can add up to 15 with the addProps() function, like:
	
		var myVars:TweenLiteVars = new TweenLiteVars();
		myVars.addProps("x", 300, false, "y", 100, false, "scaleX", 1.5, false, "scaleY", 1.5, false);
		myVars.onComplete = myFunction;
		TweenLite.to(my_mc, 1, myVars);
		
NOTES:
	- This class adds about 1.5 Kb to your published SWF.
	- This utility is completely optional. If you prefer the shorter synatax in the regular TweenLite class, feel
	  free to use it. The purpose of this utility is simply to enable code hinting and to allow for strict datatyping.
	- You may add custom properties to this class if you want, but in order to expose them to TweenLite, make sure
	  you also add a getter and a setter that adds the property to the _exposedInternalProps Object.
	- You can reuse a single TweenLiteVars Object for multiple tweens if you want, but be aware that there are a few
	  properties that must be handled in a special way, and once you set them, you cannot remove them. Those properties
	  are: frame, visible, tint, and volume. If you are altering these values, it might be better to avoid reusing a TweenLiteVars
	  Object.

CODED BY: Jack Doyle, jack@greensock.com
Copyright 2008, GreenSock (This work is subject to the terms in http://www.greensock.com/terms_of_use.html.)
*/

package gs.utils {
	import gs.TweenLite;

	dynamic public class TweenLiteVars {
		public static const version:Number = 0.9;
		public const isTV:Boolean = true; // (stands for "isTweenVars") - Just gives us a way to check inside TweenLite to see if the Object is a TweenLiteVars without having to embed the class. This is helpful when handling tint, visible, and other properties that the user didn't necessarily define, but this utility class forces to be present.
		/**
		 * Same as changing the "alpha" property but with the additional feature of toggling the "visible" property to false when alpha is 0.
		 */
		public var autoAlpha:Number;
		/**
		 * The number of seconds to delay before the tween begins.
		 */
		public var delay:Number = 0;
		/**
		 * An easing function (i.e. fl.motion.easing.Elastic.easeOut) The default is Regular.easeOut. 
		 */
		public var ease:Function;
		/**
		 * An Array of extra parameter values to feed the easing equation (beyond the standard 4). This can be useful with easing equations like Elastic that accept extra parameters like the amplitude and period. Most easing equations, however, don't require extra parameters so you won't need to pass in any easeParams. 
		 */
		public var easeParams:Array;
		/**
		 * An Array containing numeric end values of the target Array. Keep in mind that the target of the tween must be an Array with at least the same length as the endArray. 
		 */
		public var endArray:Array; 
		/**
		 * A function to call when the tween begins. This can be useful when there's a delay and you want something to happen just as the tween begins. 
		 */
		public var onStart:Function; 
		/**
		 * An Array of parameters to pass the onStart function. 
		 */
		public var onStartParams:Array;
		/**
		 * A function to call whenever the tweening values are updated (on every frame during the time the tween is active). 
		 */
		public var onUpdate:Function;
		/**
		 * An Array of parameters to pass the onUpdate function 
		 */
		public var onUpdateParams:Array;
		/**
		 * A function to call when the tween has completed.  
		 */
		public var onComplete:Function;
		/**
		 * An Array of parameters to pass the onComplete function 
		 */
		public var onCompleteParams:Array; 
		/**
		 * If you do NOT want the tween to automatically overwrite tweens that are affecting the same target, make sure this value is false. 
		 */
		public var overwrite:Boolean = true;  
		/**
		 * To prevent a tween from getting garbage collected after it completes, set persist to true. This does NOT, however, prevent teh tween from getting overwritten by other tweens of the same target.
		 */
		public var persist:Boolean = false;
		/**
		 * To remove the tint from a DisplayObject, set removeTint to true. 
		 */
		public var removeTint:Boolean;
		/**
		 * If you're using TweenLite.from() with a delay and you want to prevent the tween from rendering until it actually begins, set this special property to true. By default, it's false which causes TweenLite.from() to render its values immediately, even before the delay has expired. 
		 */
		public var renderOnStart:Boolean = false;
		/**
		 * Primarily used in from() calls - forces the values to get flipped. 
		 */
		public var runBackwards:Boolean = false;
		
		protected var _exposedInternalProps:Object; // Gives us a way to make certain non-dynamic properties enumerable.
		protected var _frame:int;
		protected var _tint:uint; 
		protected var _visible:Boolean = true; 
		protected var _volume:Number; 
		
		/**
		 * 
		 * @param $vars An Object containing properties that correspond to the properties you'd like to add to this TweenLiteVars Object. For example, TweenLiteVars({x:300, onComplete:myFunction})
		 * 
		 */
		public function TweenLiteVars($vars:Object = null) {
			_exposedInternalProps = {};
			if ($vars != null) {
				for (var p:String in $vars) {
					this[p] = $vars[p];
				}
			}
			if (TweenLite.version < 7.0) {
				trace("TweenLiteVars error! Please update your TweenLite class or try deleting your ASO files. TweenLiteVars requires a more recent version. Download updates at http://www.TweenLite.com.");
			}
		}
		
		/**
		 * 
		 * Adds a dynamic property for tweening and allows you to set whether the end value is relative or not
		 * @param $name Property name
		 * @param $value Numeric end value (or beginning value for from() calls)
		 * @param $relative If true, the value will be relative to the target's current value. For example, if my_mc.x is currently 300 and you do addProp("x", 200, true), the end value will be 500.
		 * 
		 */
		public function addProp($name:String, $value:Number, $relative:Boolean = false):void {
			if ($relative) {
				this[$name] = String($value);
			} else {
				this[$name] = $value;
			}
		}
		
		/**
		 * 
		 * Adds up to 15 dynamic properties at once (just like doing addProp() multiple times). Saves time and reduces code.
		 * 
		 */
		public function addProps($name1:String, $value1:Number, $relative1:Boolean = false,
								 $name2:String = null, $value2:Number = 0, $relative2:Boolean = false,
								 $name3:String = null, $value3:Number = 0, $relative3:Boolean = false,
								 $name4:String = null, $value4:Number = 0, $relative4:Boolean = false,
								 $name5:String = null, $value5:Number = 0, $relative5:Boolean = false,
								 $name6:String = null, $value6:Number = 0, $relative6:Boolean = false,
								 $name7:String = null, $value7:Number = 0, $relative7:Boolean = false,
								 $name8:String = null, $value8:Number = 0, $relative8:Boolean = false,
								 $name9:String = null, $value9:Number = 0, $relative9:Boolean = false,
								 $name10:String = null, $value10:Number = 0, $relative10:Boolean = false,
								 $name11:String = null, $value11:Number = 0, $relative11:Boolean = false,
								 $name12:String = null, $value12:Number = 0, $relative12:Boolean = false,
								 $name13:String = null, $value13:Number = 0, $relative13:Boolean = false,
								 $name14:String = null, $value14:Number = 0, $relative14:Boolean = false,
								 $name15:String = null, $value15:Number = 0, $relative15:Boolean = false):void {
			addProp($name1, $value1, $relative1);
			if ($name2 != null) {
				addProp($name2, $value2, $relative2);
			}
			if ($name3 != null) {
				addProp($name3, $value3, $relative3);
			}
			if ($name4 != null) {
				addProp($name4, $value4, $relative4);
			}
			if ($name5 != null) {
				addProp($name5, $value5, $relative5);
			}
			if ($name6 != null) {
				addProp($name6, $value6, $relative6);
			}
			if ($name7 != null) {
				addProp($name7, $value7, $relative7);
			}
			if ($name8 != null) {
				addProp($name8, $value8, $relative8);
			}
			if ($name9 != null) {
				addProp($name9, $value9, $relative9);
			}
			if ($name10 != null) {
				addProp($name10, $value10, $relative10);
			}
			if ($name11 != null) {
				addProp($name11, $value11, $relative11);
			}
			if ($name12 != null) {
				addProp($name12, $value12, $relative12);
			}
			if ($name13 != null) {
				addProp($name13, $value13, $relative13);
			}
			if ($name14 != null) {
				addProp($name14, $value14, $relative14);
			}
			if ($name15 != null) {
				addProp($name15, $value15, $relative15);
			}
		}
		
		
//---- GETTERS / SETTERS -------------------------------------------------------------------------------------------------------------

		/**
		 * 
		 * @return Exposes enumerable properties.
		 * 
		 */
		public function get exposedProps():Object {
			var o:Object = {};
			var p:String;
			for (p in _exposedInternalProps) {
				o[p] = _exposedInternalProps[p];
			}
			for (p in this) {
				o[p] = this[p]; //add all the dynamic properties.
			}
			return o;
		}
		public function get visible():Boolean {
			return _visible;
		}
		/**
		 * 
		 * @param $b To set a DisplayObject's "visible" property at the end of the tween, use this special property.
		 * 
		 */
		public function set visible($b:Boolean):void {
			_visible = _exposedInternalProps.visible = $b;
		}
		public function get frame():int {
			return _frame;
		}
		/**
		 * 
		 * @param $n Tweens a MovieClip to a particular frame.
		 * 
		 */
		public function set frame($n:int):void {
			_frame = _exposedInternalProps.frame = $n;
		}
		public function get tint():uint {
			return _tint;
		}
		/**
		 * 
		 * @param $n To change a DisplayObject's tint, set this to the hex value of the color you'd like the DisplayObject to end up at(or begin at if you're using TweenLite.from()). An example hex value would be 0xFF0000. If you'd like to remove the tint from a DisplayObject, use the removeTint special property.
		 * 
		 */
		public function set tint($n:uint):void {
			_tint = _exposedInternalProps.tint = $n;
		}
		public function get volume():Number {
			return _volume;
		}
		/**
		 * 
		 * @param $n To change a MovieClip's (or SoundChannel's) volume, just set this to the value you'd like the MovieClip to end up at (or begin at if you're using TweenLite.from()).
		 * 
		 */
		public function set volume($n:Number):void { 
			_volume = _exposedInternalProps.volume = $n;
		}
		
	}
}