package net.metafor.faceapi.events
{
	import flash.events.Event;
	
	import net.metafor.faceapi.FaceResult;
	
	public class FaceEvent extends Event
	{		
		public static const SUCCESS			:String = "faceEvent.success";
		public static const FAIL			:String = "faceEvent.fail";
		public static const TAG_SAVED		:String = "faceEvent.tagSaved";
		
		public var data						:*;
		public var rawResult				:*;
		public var result					:FaceResult;
		
		public function FaceEvent(type:String, data:* = null, rawResult:* = null , result:FaceResult = null, bubbles:Boolean=false, cancelable:Boolean=false )
		{
			super(type, bubbles, cancelable);
			
			this.data 			= data;
			this.rawResult 		= rawResult;
			this.result 		= result;
		}
	}
}