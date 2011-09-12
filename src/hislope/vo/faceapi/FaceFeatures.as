package hislope.vo.faceapi
{
	import hislope.vo.faceapi.FaceAttributes;
	import hislope.vo.faceapi.FaceUID;
	
	import flash.geom.Point;
	
	public class FaceFeatures
	{
		public var width:Number;
		public var height:Number;

		public var pitch:Number;
		public var roll:Number;
		public var yaw:Number;
		
		public var threshold:Number;

		public var tagger_id:Number;
		public var gid:Number;


		public var tid:String;

		
		
		public var center:Point;
		public var ear_left:Point;
		public var ear_right:Point;
		public var eye_left:Point;
		public var eye_right:Point;
		public var mouth_center:Point;
		public var mouth_left:Point;
		public var mouth_right:Point;
		public var nose:Point;

		public var mouth_midleft:Point;	//
		public var mouth_midright:Point;	//
		
		// 
		public var faceScale:Number;
		
		public var chin:Point;		//?
		public var label:String;	//?

		public var attributes:FaceAttributes;
		
		
		public var confirmed:Boolean;
		public var recognizable:Boolean;
		public var manual:Boolean;

		public var uids:Vector.<FaceUID>;
	}
}