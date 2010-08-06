/*
VERSION: 0.9
DATE: 7/15/2008
ACTIONSCRIPT VERSION: 3.0
DESCRIPTION:
	There are 2 primary benefits of using this utility to define your TweenMax variables:
		1) In most code editors, code hinting will be activated which helps remind you which special properties are available in TweenMax
		2) It allows you to code using strict datatyping (although it doesn't force you to).

USAGE:
	
	Instead of TweenMax.to(my_mc, 1, {x:300, tint:0xFF0000, onComplete:myFunction}), you could use this utility like:
	
		var myVars:TweenMaxVars = new TweenMaxVars();
		myVars.addProp("x", 300); // use addProp() to add any property that doesn't already exist in the TweenMaxVars instance.
		myVars.tint = 0xFF0000;
		myVars.onComplete = myFunction;
		TweenMax.to(my_mc, 1, myVars);
		
	Or if you just want to add multiple properties with one function, you can add up to 15 with the addProps() function, like:
	
		var myVars:TweenMaxVars = new TweenMaxVars();
		myVars.addProps("x", 300, false, "y", 100, false, "scaleX", 1.5, false, "scaleY", 1.5, false);
		myVars.onComplete = myFunction;
		TweenMax.to(my_mc, 1, myVars);
		
NOTES:
	- This class adds about 2 Kb to your published SWF.
	- This utility is completely optional. If you prefer the shorter synatax in the regular TweenMax class, feel
	  free to use it. The purpose of this utility is simply to enable code hinting and to allow for strict datatyping.
	- You may add custom properties to this class if you want, but in order to expose them to TweenMax, make sure
	  you also add a getter and a setter that adds the property to the _exposedInternalProps Object.
	- You can reuse a single TweenMaxVars Object for multiple tweens if you want, but be aware that there are a few
	  properties that must be handled in a special way, and once you set them, you cannot remove them. Those properties
	  are: frame, visible, tint, and volume. If you are altering these values, it might be better to avoid reusing a TweenMaxVars
	  Object.

CODED BY: Jack Doyle, jack@greensock.com
Copyright 2008, GreenSock (This work is subject to the terms in http://www.greensock.com/terms_of_use.html.)
*/

package gs.utils {
	import gs.utils.TweenFilterLiteVars;

	dynamic public class TweenMaxVars extends TweenFilterLiteVars {
		public static const version:Number = 0.9;
		/**
		 * Array of Objects, one for each "control point" (see documentation on Flash's curveTo() drawing method for more about how control points work). In this example, let's say the control point would be at x/y coordinates 250,50. Just make sure your my_mc is at coordinates 0,0 and then do: TweenMax.to(my_mc, 3, {_x:500, _y:0, bezier:[{_x:250, _y:50}]});
		 */
		public var bezier:Array; 
		/**
		 * Identical to bezier except that instead of passing Bezier control point values, you pass values through which the Bezier values should move. This can be more intuitive than using control points.
		 */
		public var bezierThrough:Array;
		/**
		 * A common effect that designers/developers want is for a MovieClip/Sprite to orient itself in the direction of a Bezier path (alter its rotation). orientToBezier makes it easy. In order to alter a rotation property accurately, TweenMax needs 4 pieces of information:
		 * 
		 * 1. Position property 1 (typically "x")
		 * 2. Position property 2 (typically "y")
		 * 3. Rotational property (typically "rotation")
		 * 4. Number of degrees to add (optional - makes it easy to orient your MovieClip/Sprite properly)
		 * 
		 * The orientToBezier property should be an Array containing one Array for each set of these values. For maximum flexibility, you can pass in any number of Arrays inside the container Array, one for each rotational property. This can be convenient when working in 3D because you can rotate on multiple axis. If you're doing a standard 2D x/y tween on a bezier, you can simply pass in a boolean value of true and TweenMax will use a typical setup, [["x", "y", "rotation", 0]]. Hint: Don't forget the container Array (notice the double outer brackets)  
		 */
		public var orientToBezier:Array;
		/**
		 * Although hex colors are technically numbers, if you try to tween them conventionally, you'll notice that they don't tween smoothly. To tween them properly, the red, green, and blue components must be extracted and tweened independently. TweenMax makes it easy. To tween a property of your object that's a hex color to another hex color, use this special hexColors property of TweenMax. It must be an OBJECT with properties named the same as your object's hex color properties. For example, if your my_obj object has a "myHexColor" property that you'd like to tween to red (0xFF0000) over the course of 2 seconds, do: TweenMax.to(my_obj, 2, {hexColors:{myHexColor:0xFF0000}}); You can pass in any number of hexColor properties. 
		 */
		public var hexColors:Object;
		/**
		 * A function to which the TweenMax instance should dispatch a TweenEvent when it begins. This is the same as doing myTweenMaxInstance.addEventListener(TweenEvent.START, myFunction); 
		 */
		public var onStartListener:Function;
		/**
		 * A function to which the TweenMax instance should dispatch a TweenEvent every time it updates values. This is the same as doing myTweenMaxInstance.addEventListener(TweenEvent.UPDATE, myFunction); 
		 */
		public var onUpdateListener:Function;
		/**
		 * A function to which the TweenMax instance should dispatch a TweenEvent when it completes. This is the same as doing myTweenMaxInstance.addEventListener(TweenEvent.COMPLETE, myFunction); 
		 */
		public var onCompleteListener:Function;
		/**
		 * A function to which the TweenMax instance should dispatch a TweenEvent when it completes the allTo() or allFrom() tweens. ONLY used with allTo() and allFrom() methods!
		 */
		public var onCompleteAllListener:Function;
		/**
		 * A function that should be called when the allTo() or allFrom() tweens have completed. ONLY used with allTo() and allFrom() methods!
		 */
		public var onCompleteAll:Function;
		/**
		 * An Array of parameters to pass the onCompleteAll function when the allTo() or allFrom() tweens have completed. ONLY used with allTo() and allFrom() methods!
		 */
		public var onCompleteAllParams:Array;
		//public var quaternions:Object;
		
		/**
		 * 
		 * @param $vars An Object containing properties that correspond to the properties you'd like to add to this TweenMaxVars Object. For example, TweenMaxVars({blurFilter:{blurX:10, blurY:20}, onComplete:myFunction})
		 * 
		 */
		public function TweenMaxVars($vars:Object = null) {
			super($vars);
		}
		
		
	}
}