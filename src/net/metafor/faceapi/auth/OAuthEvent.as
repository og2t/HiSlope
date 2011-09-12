package net.metafor.faceapi.auth
{
	import flash.events.Event;
	
	public class OAuthEvent extends Event
	{
		public static const SUCCESS			:String = "OAuth.success";
		public static const FAULT			:String = "OAuth.fault";
		
		public function OAuthEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}