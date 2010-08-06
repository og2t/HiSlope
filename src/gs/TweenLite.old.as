/*
VERSION: 6.04
DATE: 3/11/2008
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenLite.com (there's a link to the AS3 version)
DESCRIPTION:
	Tweening. We all do it. Most of us have learned to avoid Adobe's Tween class in favor of a more powerful, 
	less code-heavy engine (Tweener, Fuse, MC Tween, etc.). Each has its own strengths & weaknesses. A few years back, 
	I created TweenLite because I needed a very compact tweening engine that was fast and efficient (I couldn't 
	afford the file size bloat that came with the other tweening engines). It quickly became integral to my work flow.

	Since then, I've added new capabilities while trying to keep file size way down (3K). TweenFilterLite extends 
	TweenLite and adds the ability to tween filters including ColorMatrixFilter effects like saturation, contrast, 
	brightness, hue, and even colorization but it only adds about 3k to the file size. Same syntax as TweenLite. 
	There are AS2 and AS3 versions of both of the classes.

	I know what you're thinking - "if it's so 'lightweight', it's probably missing a lot of features which makes 
	me nervous about using it as my main tweening engine." It is true that it doesn't have the same feature set 
	as the other tweening engines, but I can honestly say that after using it on almost every project I've worked 
	on over the last few years, it has never let me down. I never found myself needing some other functionality. 
	You can tween any property (including a MovieClip's volume and color), use any easing function, build in delays, 
	callback functions, pass arguments to that callback function, and even tween arrays all with one line of code. 
	You very well may require a feature that TweenLite (or TweenFilterLite) doesn't have, but I think most 
	developers will use the built-in features to accomplish whatever they need and appreciate the streamlined 
	nature of the class(es).

	I haven't been able to find a faster tween engine either. The syntax is simple and the class doesn't rely on 
	complicated prototype alterations that can cause problems with certain compilers. TweenLite is simple, very 
	fast, and more lightweight than any other popular tweening engine with similar features.

ARGUMENTS:
	1) $target: Target MovieClip (or any other object) whose properties we're tweening
	2) $duration: Duration (in seconds) of the effect
	3) $vars: An object containing the end values of all the properties you'd like to have tweened (or if you're using the 
	         TweenLite.from() method, these variables would define the BEGINNING values). For example:
					  alpha: The alpha (opacity level) that the target object should finish at (or begin at if you're 
							 using TweenLite.from()). For example, if the target.alpha is 1 when this script is 
					  		 called, and you specify this argument to be 0.5, it'll transition from 1 to 0.5.
					  x: To change a MovieClip's x position, just set this to the value you'd like the MovieClip to 
					     end up at (or begin at if you're using TweenLite.from()). 
				  SPECIAL PROPERTIES (**OPTIONAL**):
				  	  delay: Amount of delay before the tween should begin (in seconds).
					  ease: You can specify a function to use for the easing with this variable. For example, 
					        fl.motion.easing.Elastic.easeOut. The Default is Regular.easeOut.
					  easeParams: An array of extra parameters to feed the easing equation. This can be useful when you 
					  			  use an equation like Elastic and want to control extra parameters like the amplitude and period.
								  Most easing equations, however, don't require extra parameters so you won't need to pass in any easeParams.
					  autoAlpha: Same as changing the "alpha" property but with the additional feature of toggling the "visible" property 
				  				 to false if the alpha ends at 0. It will also toggle visible to true before the tween starts if the value 
								 of autoAlpha is greater than zero.
					  volume: To change a MovieClip's volume, just set this to the value you'd like the MovieClip to
					          end up at (or begin at if you're using TweenLite.from()).
					  tint: To change a MovieClip's color, set this to the hex value of the color you'd like the MovieClip
					  		   to end up at(or begin at if you're using TweenLite.from()). An example hex value would be 0xFF0000. 
							   If you'd like to remove the color from a MovieClip, just pass null as the value of tint.
					  frame: Use this to tween a MovieClip to a particular frame.
					  onStart: If you'd like to call a function as soon as the tween begins, pass in a reference to it here.
					  		   This is useful for when there's a delay. 
					  onStartParams: An array of parameters to pass the onStart function. (this is optional)
					  onUpdate: If you'd like to call a function every time the property values are updated (on every frame during
								the time the tween is active), pass a reference to it here.
					  onUpdateParams: An array of parameters to pass the onUpdate function (this is optional)
					  onComplete: If you'd like to call a function when the tween has finished, use this. 
					  onCompleteParams: An array of parameters to pass the onComplete function (this is optional)
					  renderOnStart: If you're using TweenLite.from() with a delay and want to prevent the tween from rendering until it
					  				 actually begins, set this to true. By default, it's false which causes TweenLite.from() to render
									 its values immediately, even before the delay has expired.
					  overwrite: If you do NOT want the tween to automatically overwrite any other tweens that are 
					             affecting the same target, make sure this value is false.
	
	

EXAMPLES: 
	As a simple example, you could tween the alpha to 50% (0.5) and move the x position of a MovieClip named "clip_mc" 
	to 120 and fade the volume to 0 over the course of 1.5 seconds like so:
	
		import gs.TweenLite;
		TweenLite.to(clip_mc, 1.5, {alpha:0.5, x:120, volume:0});
	
	If you want to get more advanced and tween the clip_mc MovieClip over 5 seconds, changing the alpha to 0.5, 
	the x to 120 using the "easeOutBack" easing function, delay starting the whole tween by 2 seconds, and then call
	a function named "onFinishTween" when it has completed and pass in a few parameters to that function (a value of
	5 and a reference to the clip_mc), you'd do so like:
		
		import gs.TweenLite;
		import fl.motion.easing.Back;
		TweenLite.to(clip_mc, 5, {alpha:0.5, x:120, ease:Back.easeOut, delay:2, onComplete:onFinishTween, onCompleteParams:[5, clip_mc]});
		function onFinishTween(argument1:Number, argument2:MovieClip):void {
			trace("The tween has finished! argument1 = " + argument1 + ", and argument2 = " + argument2);
		}
	
	If you have a MovieClip on the stage that is already in it's end position and you just want to animate it into 
	place over 5 seconds (drop it into place by changing its y property to 100 pixels higher on the screen and 
	dropping it from there), you could:
		
		import gs.TweenLite;
		import fl.motion.easing.Elastic;
		TweenLite.from(clip_mc, 5, {y:"-100", ease:Elastic.easeOut});		
	

NOTES:
	- This class will add about 3kb to your Flash file.
	- Putting quotes around values will make the tween relative to the current value. For example, if you do
	  TweenLite.to(mc, 2, {x:"-20"}); it'll move the mc.x to the left 20 pixels which is the same as doing
	  TweenLite.to(mc, 2, {x:mc.x - 20});
	- You must target Flash Player 9 or later (ActionScript 3.0)
	- You can tween the volume of any MovieClip using the tween property "volume", like:
	  TweenLite.to(myClip_mc, 1.5, {volume:0});
	- You can tween the color of a MovieClip using the tween property "tint", like:
	  TweenLite.to(myClip_mc, 1.5, {tint:0xFF0000});
	- To tween an array, just pass in an array as a property named endArray like:
	  var myArray:Array = [1,2,3,4];
	  TweenLite.to(myArray, 1.5, {endArray:[10,20,30,40]});
	- You can kill all tweens for a particular object (usually a MovieClip) anytime with the 
	  TweenLite.killTweensOf(myClip_mc); function. If you want to have the tweens forced to completion, 
	  pass true as the second parameter, like TweenLite.killTweensOf(myClip_mc, true);
	- You can kill all delayedCalls to a particular function using TweenLite.killDelayedCallsTo(myFunction_func);
	  This can be helpful if you want to preempt a call.
	- Use the TweenLite.from() method to animate things into place. For example, if you have things set up on 
	  the stage in the spot where they should end up, and you just want to animate them into place, you can 
	  pass in the beginning x and/or y and/or alpha (or whatever properties you want).
	  
	  
CHANGE LOG:
	6.04:
		- Fixed bug that caused calls to complete() to not render if the tween hadn't ever started (like if there was a delay that hadn't expired yet)
	6.03:
		- Added the "renderOnStart" property that can force TweenLite.from() to render only when the tween actually starts (by default, it renders immediately even if the tween has a delay.)
	6.02:
		- Fixed bug that could cause TweenLite.delayedCall() to generate a 1010 error.
	6.01:
		- Fixed bug that could cause TweenLite.from() to not render the values immediately.
		- Fixed bug that could prevent tweens with a duration of zero from rendering properly.
	6.0:
		- Added ability to tween a MovieClip's frame
		- Added onCompleteScope, onStartScope, and onUpdateScope
		- Reworked internal class routines for handling SubTweens
	5.9:
		- Added ability to tween sound volumes directly (not just MovieClip volumes).
	5.87:
		- Fixed potential 1010 errors when an onUpdate() calls a killTweensOf() for an object.
	5.85:
		- Fixed an issue that prevented TextField filters from being applied properly with TweenFilterLite.
	5.8:
		- Added the ability to define extra easing parameters using easeParams.
		- Changed "mcColor" to "tint" in order to make it more intuitive. Using mcColor for tweening color values is deprecated and will be removed eventually.
	5.7:	
		- Improved speed (made changes to the render() and initTweenVals() functions)
		- Added a complete() function which allows you to immediately skip to the end of a tween.
	5.61:
		- Removed a line of code that in some very rare instances could contribute to an intermittent 1010 error in TweenFilterLite which extends this class.
		- Fixed an issue with tweening tint and alpha together.
	5.5: 
		- Added a few very minor conditional checks to improve reliability, and re-released with TweenFilterLite 5.5 (which fixed rare 1010 errors).
	5.4: 
		- Eliminated rare 1010 errors with TweenFilterLite
	5.3:
		- Added onUpdate and onUpdateParams features
		- Finally removed extra/duplicated (deprecated) constructor parameters that had been left in for almost a year simply for backwards compatibility.

CODED BY: Jack Doyle, jack@greensock.com
Copyright 2008, GreenSock (This work is subject to the terms in http://www.greensock.com/terms_of_use.html.)
*/

package gs {
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.geom.ColorTransform;
	import flash.media.SoundChannel;
	import flash.utils.*;

	public class TweenLite {
		public static var version:Number = 6.04;
		public static var killDelayedCallsTo:Function = killTweensOf;
		protected static var _all:Dictionary = new Dictionary(); //Holds references to all our tween targets.
		private static var _sprite:Sprite = new Sprite(); //A reference to the sprite that we use to drive all our ENTER_FRAME events.
		private static var _listening:Boolean; //If true, the ENTER_FRAME is being listened for (there are tweens that are in the queue)
		private static var _timer:Timer = new Timer(2000);
	
		public var duration:Number; //Duration (in seconds)
		public var vars:Object; //Variables (holds things like alpha or y or whatever we're tweening)
		public var delay:Number; //Delay (in seconds)
		public var startTime:uint; //Start time
		public var initTime:uint; //Time of initialization. Remember, we can build in delays so this property tells us when the frame action was born, not when it actually started doing anything.
		public var tweens:Object; //Contains parsed data for each property that's being tweened (each has to have a target, property, start, and a change).
		public var target:Object; //Target object (often a MovieClip)
		
		protected var _active:Boolean; //If true, this tween is active.
		protected var _subTweens:Array; //Only used for associated sub-tweens like tint and volume
		protected var _hst:Boolean; //Has sub-tweens. We track this with a boolean value as opposed to checking _subTweens.length for speed purposes
		protected var _initted:Boolean;
		
		public function TweenLite($target:Object, $duration:Number, $vars:Object) {
			if ($target == null) {return};
			if (($vars.overwrite != false && $target != null) || _all[$target] == undefined) { 
				delete _all[$target];
				_all[$target] = new Dictionary();
			}
			_all[$target][this] = this;
			this.vars = $vars;
			this.duration = $duration || 0.001; //Easing equations don't work when the duration is zero.
			this.delay = $vars.delay || 0;
			this.target = $target;
			if (!(this.vars.ease is Function)) {
				this.vars.ease = easeOut;
			}
			if (this.vars.easeParams != null) {
				this.vars.proxiedEase = this.vars.ease;
				this.vars.ease = easeProxy;
			}
			if (this.vars.mcColor != null) {
				this.vars.tint = this.vars.mcColor;
			}
			if (!isNaN(Number(this.vars.autoAlpha))) {
				this.vars.alpha = Number(this.vars.autoAlpha);
			}
			this.tweens = {};
			_subTweens = [];
			_hst = _initted = false;
			_active = ($duration == 0 && this.delay == 0);
			this.initTime = getTimer();
			if ((this.vars.runBackwards == true && this.vars.renderOnStart != true) || _active) {
				initTweenVals();
				this.startTime = getTimer();
				if (_active) { //Means duration is zero and delay is zero, so render it now, but add one to the startTime because this.duration is always forced to be at least 0.001 since easing equations can't handle zero.
					render(this.startTime + 1);
				} else {
					render(this.startTime);
				}
			}
			if (!_listening && !_active) {
				_sprite.addEventListener(Event.ENTER_FRAME, executeAll);
				_timer.addEventListener("timer", killGarbage);
            	_timer.start();
				_listening = true;
			}
		}
		
		public function initTweenVals($hrp:Boolean = false, $reservedProps:String = ""):void {
			var isDO:Boolean = (this.target is DisplayObject);
			var p:String;
			if (this.target is Array) {
				var endArray:Array = this.vars.endArray || [];
				for (var i:int = 0; i < endArray.length; i++) {
					if (this.target[i] != endArray[i] && this.target[i] != undefined) {
						this.tweens[i.toString()] = {o:this.target, p:i.toString(), s:this.target[i], c:endArray[i] - this.target[i]}; //o: object, s:starting value, c:change in value, e: easing function
					}
				}
			} else {
				for (p in this.vars) {
					if (p == "ease" || p == "delay" || p == "overwrite" || p == "onComplete" || p == "onCompleteParams" || p == "onCompleteScope" || p == "runBackwards" || p == "onUpdate" || p == "onUpdateParams" || p == "onUpdateScope" || p == "autoAlpha" || p == "onStart" || p == "onStartParams" || p == "onStartScope" ||p == "renderOnStart" || p == "easeParams" || p == "mcColor" || p == "type" || ($hrp && $reservedProps.indexOf(" " + p + " ") != -1)) { //"type" is for TweenFilterLite, and it's an issue when trying to tween filters on TextFields which do actually have a "type" property.
						
					} else if (p == "tint" && isDO) { //If we're trying to change the color of a DisplayObject, then set up a quasai proxy using an instance of a TweenLite to control the color.
						var clr:ColorTransform = this.target.transform.colorTransform;
						var endClr = new ColorTransform();
						if (this.vars.alpha != undefined) {
							endClr.alphaMultiplier = this.vars.alpha;
							delete this.vars.alpha;
							delete this.tweens.alpha;
						} else {
							endClr.alphaMultiplier = this.target.alpha;
						}
						if (this.vars[p] != null && this.vars[p] != "") { //In case they're actually trying to remove the colorization, they should pass in null or "" for the tint
							endClr.color = this.vars[p];
						}
						addSubTween(tintProxy, {progress:0}, {progress:1}, {target:this.target, color:clr, endColor:endClr});
					} else if (p == "frame" && isDO) {
						addSubTween(frameProxy, {frame:this.target.currentFrame}, {frame:this.vars[p]}, {target:this.target});
					} else if (p == "volume" && (isDO || this.target is SoundChannel)) { //If we're trying to change the volume of a MovieClip or Sound object, then set up a quasai proxy using an instance of a TweenLite to control the volume.
						addSubTween(volumeProxy, this.target.soundTransform, {volume:this.vars[p]}, {target:this.target});
					} else {
						if (this.target.hasOwnProperty(p)) {
							if (typeof(this.vars[p]) == "number") {
								this.tweens[p] = {o:this.target, p:p, s:this.target[p], c:this.vars[p] - this.target[p]}; //o:object, p:property, s:starting value, c:change in value
							} else {
								this.tweens[p] = {o:this.target, p:p, s:this.target[p], c:Number(this.vars[p])}; //o:object, p:property, s:starting value, c:change in value
							}
						}
					}
				}
			}
			if (this.vars.runBackwards == true) {
				var tp:Object;
				for (p in this.tweens) {
					tp = this.tweens[p];
					tp.s += tp.c;
					tp.c *= -1;
				}
			}
			if (typeof(this.vars.autoAlpha) == "number") {
				this.target.visible = !(this.vars.runBackwards == true && this.target.alpha == 0);
			}
			_initted = true;
		}
		
		protected function addSubTween($proxy:Function, $target:Object, $props:Object, $info:Object = null):void {
			_subTweens.push({proxy:$proxy, target:$target, info:$info});
			for (var p:String in $props) {
				if ($target.hasOwnProperty(p)) {
					if (typeof($props[p]) == "number") {
						this.tweens["st" + _subTweens.length + "_" + p] = {o:$target, p:p, s:$target[p], c:$props[p] - $target[p]}; //o:Object, p:Property, s:Starting value, c:Change in value;
					} else {
						this.tweens["st" + _subTweens.length + "_" + p] = {o:$target, p:p, s:$target[p], c:Number($props[p])};
					}
				}
			}
			_hst = true; //has sub tweens. We track this with a boolean value as opposed to checking _subTweens.length for speed purposes
		}
		
		public static function to($target:Object, $duration:Number, $vars:Object):TweenLite {
			return new TweenLite($target, $duration, $vars);
		}
		
		//This function really helps if there are objects (usually MovieClips) that we just want to animate into place (they are already at their end position on the stage for example). 
		public static function from($target:Object, $duration:Number, $vars:Object):TweenLite {
			$vars.runBackwards = true;
			return new TweenLite($target, $duration, $vars);
		}
		
		public static function delayedCall($delay:Number, $onComplete:Function, $onCompleteParams:Array = null, $onCompleteScope:* = null):TweenLite {
			return new TweenLite($onComplete, 0, {delay:$delay, onComplete:$onComplete, onCompleteParams:$onCompleteParams, onCompleteScope:$onCompleteScope, overwrite:false}); //NOTE / TO-DO: There may be a bug in the Dictionary class that causes it not to handle references to objects correctly! (I haven't verified this yet)
		}
		
		public function render($t:uint):void {
			var time:Number = ($t - this.startTime) / 1000;
			if (time > this.duration) {
				time = this.duration;
			}
			var factor:Number = this.vars.ease(time, 0, 1, this.duration);
			var tp:Object;
			for (var p:String in this.tweens) {
				tp = this.tweens[p];
				tp.o[tp.p] = tp.s + (factor * tp.c);
			}
			if (_hst) { //has sub-tweens
				for (var i:uint = 0; i < _subTweens.length; i++) {
					_subTweens[i].proxy(_subTweens[i]);
				}
			}
			if (this.vars.onUpdate != null) {
				this.vars.onUpdate.apply(this.vars.onUpdateScope, this.vars.onUpdateParams);
			}
			if (time == this.duration) {
				complete(true);
			}
		}
		
		public static function executeAll($e:Event = null):void {
			var a:Dictionary = _all; //speeds things up slightly
			var t:uint = getTimer();
			var p:Object, tw:Object;
			for (p in a) {
				for (tw in a[p]) {
					if (a[p][tw] != undefined && a[p][tw].active) {
						a[p][tw].render(t);
						if (a[p] == undefined) { //Could happen if, for example, an onUpdate triggered a killTweensOf() for the object that's currently looping here. Without this code, we run the risk of hitting 1010 errors
							break;
						}
					}
				}
			}
		}
		
		public function complete($skipRender:Boolean = false):void {
			if (!$skipRender) {
				if (!_initted) {
					initTweenVals();
				}
				this.startTime = 0;
				render(this.duration * 1000); //Just to force the render
				return;
			}
			if (typeof(this.vars.autoAlpha) == "number" && this.target.alpha == 0) { 
				this.target.visible = false;
			}
			if (this.vars.onComplete != null) {
				this.vars.onComplete.apply(this.vars.onCompleteScope, this.vars.onCompleteParams);
			}
			removeTween(this);
		}
		
		public static function removeTween($t:TweenLite = null):void {
			if ($t != null && _all[$t.target] != undefined) {
				delete _all[$t.target][$t];
			}
		}
		
		public static function killTweensOf($tg:Object = null, $complete:Boolean = false):void {
			if ($tg != null && _all[$tg] != undefined) {
				if ($complete) {
					var o:Object = _all[$tg];
					for (var tw:* in o) {
						o[tw].complete(false);
					}
				}
				delete _all[$tg];
			}
		}
		
		public static function killGarbage($e:TimerEvent):void {
			var tg_cnt:uint = 0;
			var found:Boolean;
			var p:Object, twp:Object, tw:Object;
			for (p in _all) {
				found = false;
				for (twp in _all[p]) {
					found = true;
					break;
				}
				if (!found) {
					delete _all[p];
				} else {
					tg_cnt++;
				}
			}
			if (tg_cnt == 0) {
				_sprite.removeEventListener(Event.ENTER_FRAME, executeAll);
				_timer.removeEventListener("timer", killGarbage);
				_timer.stop();
				_listening = false;
			}
		}
		
		//Default ease function for tweens other than alpha (Regular.easeOut)
		protected static function easeOut($t:Number, $b:Number, $c:Number, $d:Number):Number {
			return -$c * ($t /= $d) * ($t - 2) + $b;
		}
		
//---- PROXY FUNCTIONS ------------------------------------------------------------------------
		
		protected function easeProxy($t:Number, $b:Number, $c:Number, $d:Number):Number { //Just for when easeParams are passed in via the vars object.
			return this.vars.proxiedEase.apply(null, arguments.concat(this.vars.easeParams));
		}
		public static function tintProxy($o:Object):void {
			var n:Number = $o.target.progress;
			var r:Number = 1 - n;
			$o.info.target.transform.colorTransform = new ColorTransform($o.info.color.redMultiplier * r + $o.info.endColor.redMultiplier * n,
																		  $o.info.color.greenMultiplier * r + $o.info.endColor.greenMultiplier * n,
																		  $o.info.color.blueMultiplier * r + $o.info.endColor.blueMultiplier * n,
																		  $o.info.color.alphaMultiplier * r + $o.info.endColor.alphaMultiplier * n,
																		  $o.info.color.redOffset * r + $o.info.endColor.redOffset * n,
																		  $o.info.color.greenOffset * r + $o.info.endColor.greenOffset * n,
																		  $o.info.color.blueOffset * r + $o.info.endColor.blueOffset * n,
																		  $o.info.color.alphaOffset * r + $o.info.endColor.alphaOffset * n);
		}
		public static function frameProxy($o:Object):void {
			$o.info.target.gotoAndStop(Math.round($o.target.frame));
		}
		public static function volumeProxy($o:Object):void {
			$o.info.target.soundTransform = $o.target;
		}
		
		
//---- GETTERS / SETTERS -----------------------------------------------------------------------
		
		public function get active():Boolean {
			if (_active) {
				return true;
			} else if ((getTimer() - this.initTime) / 1000 > this.delay) {
				_active = true;
				this.startTime = this.initTime + (this.delay * 1000);
				if (!_initted) {
					initTweenVals();
				} else if (typeof(this.vars.autoAlpha) == "number") {
					this.target.visible = true;
				}
				if (this.vars.onStart != null) {
					this.vars.onStart.apply(this.vars.onStartScope, this.vars.onStartParams);
				}
				if (this.duration == 0.001) { //In the constructor, if the duration is zero, we shift it to 0.001 because the easing functions won't work otherwise. We need to offset the this.startTime to compensate too.
					this.startTime -= 1;
				}
				return true;
			} else {
				return false;
			}
		}
		
	}
	
}