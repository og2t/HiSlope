/*
VERSION: 0.9
DATE: 7/15/2008
ACTIONSCRIPT VERSION: 3.0
DESCRIPTION:
	There are 2 primary benefits of using this utility to define your TweenFilterLite variables:
		1) In most code editors, code hinting will be activated which helps remind you which special properties are available in TweenFilterLite
		2) It allows you to code using strict datatyping (although it doesn't force you to).

USAGE:
	
	Instead of TweenFilterLite.to(my_mc, 1, {x:300, tint:0xFF0000, onComplete:myFunction}), you could use this utility like:
	
		var myVars:TweenFilterLiteVars = new TweenFilterLiteVars();
		myVars.addProp("x", 300); // use addProp() to add any property that doesn't already exist in the TweenFilterLiteVars instance.
		myVars.tint = 0xFF0000;
		myVars.onComplete = myFunction;
		TweenFilterLite.to(my_mc, 1, myVars);
		
	Or if you just want to add multiple properties with one function, you can add up to 15 with the addProps() function, like:
	
		var myVars:TweenFilterLiteVars = new TweenFilterLiteVars();
		myVars.addProps("x", 300, false, "y", 100, false, "scaleX", 1.5, false, "scaleY", 1.5, false);
		myVars.onComplete = myFunction;
		TweenFilterLite.to(my_mc, 1, myVars);
		
NOTES:
	- This class adds about 2 Kb to your published SWF.
	- This utility is completely optional. If you prefer the shorter synatax in the regular TweenFilterLite class, feel
	  free to use it. The purpose of this utility is simply to enable code hinting and to allow for strict datatyping.
	- You may add custom properties to this class if you want, but in order to expose them to TweenFilterLite, make sure
	  you also add a getter and a setter that adds the property to the _exposedInternalProps Object.
	- You can reuse a single TweenFilterLiteVars Object for multiple tweens if you want, but be aware that there are a few
	  properties that must be handled in a special way, and once you set them, you cannot remove them. Those properties
	  are: frame, visible, tint, and volume. If you are altering these values, it might be better to avoid reusing a TweenFilterLiteVars
	  Object.

CODED BY: Jack Doyle, jack@greensock.com
Copyright 2008, GreenSock (This work is subject to the terms in http://www.greensock.com/terms_of_use.html.)
*/

package gs.utils {
	import gs.utils.TweenLiteVars;

	dynamic public class TweenFilterLiteVars extends TweenLiteVars {
		public static const version:Number = 0.9;
		/**
		 * Adds a BlurFilter. Available properties: blurX, blurY, quality
		 */
		public var blurFilter:Object; 
		/**
		 * Adds a ColorMatrixFilter. Available properties: colorize, amount, contrast, brightness, saturation, hue, threshold, relative, matrix 
		 */
		public var colorMatrixFilter:Object;
		/**
		 * Adds a GlowFilter. Available properties: alpha, blurX, blurY, color, strength, quality, inner, knockout 
		 */
		public var glowFilter:Object;
		/**
		 * Adds a DropShadowFilter. Available properties: alpha, angle, blurX, blurY, color, distance, strength, quality
		 */
		public var dropShadowFilter:Object; 
		/**
		 * Adds a BevelFilter. Available properties: angle, blurX, blurY, distance, highlightAlpha, highlightColor, shadowAlpha, shadowColor, strength, quality
		 */
		public var bevelFilter:Object; 
		
		/**
		 * 
		 * @param $vars An Object containing properties that correspond to the properties you'd like to add to this TweenFilterLiteVars Object. For example, TweenFilterLiteVars({blurFilter:{blurX:10, blurY:20}, onComplete:myFunction})
		 * 
		 */
		public function TweenFilterLiteVars($vars:Object = null) {
			super($vars);
		}
		
		
	}
}