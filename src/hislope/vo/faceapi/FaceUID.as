package hislope.vo.faceapi
{
	import hislope.vo.faceapi.ValueConfidence;
	
	public class FaceUID extends ValueConfidence
	{
		public function FaceUID(uid:String, confidence:int)
		{
			super(uid, confidence);
		}
	}
}