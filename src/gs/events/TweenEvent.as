/*
VERSION: 0.9
DATE: 7/15/2008
ACTIONSCRIPT VERSION: 3.0 (Requires Flash Player 9)
DESCRIPTION: 
	Used for Event dispatching from the AS3 version of TweenMax (www.tweenmax.com)


CODED BY: Jack Doyle, jack@greensock.com
Copyright 2008, GreenSock (This work is subject to the terms at http://www.greensock.com/terms_of_use.html.)
*/

package gs.events {
	import flash.events.Event;
	
	public class TweenEvent extends Event {
		public static const version:Number = 0.9;
		public static const START:String = "start";
		public static const UPDATE:String = "update";
		public static const COMPLETE:String = "complete";
		
		public var info:Object;
		
		public function TweenEvent($type:String, $info:Object = null, $bubbles:Boolean = false, $cancelable:Boolean = false){
			super($type, $bubbles, $cancelable);
			this.info = $info;
		}
		
		public override function clone():Event{
			return new TweenEvent(this.type, this.info, this.bubbles, this.cancelable);
		}
	
	}
	
}