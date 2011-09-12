package hislope.vo.faceapi
{
	import hislope.vo.faceapi.ValueConfidence;
	
	public class FaceAttributes
	{
		public var face:ValueConfidence;
		public var gender:ValueConfidence;
		public var glasses:ValueConfidence;
		public var smiling:ValueConfidence;
		
		public function toString():String
		{
			return "[FaceAttributes face: " + face + ", gender: " + gender + ", glasses: " + glasses + ", smiling: " + smiling + "]";
		}
	}
}