package hislope.vo.faceapi
{
	public class ValueConfidence
	{
		public var value:*;
		public var confidence:int;

		public function ValueConfidence(value:*, confidence:int)
		{
			this.value = value;
			this.confidence = confidence;
		}
	
		public function toString():String
		{
			return "[" + value + ", " + confidence + "]";
		}
	}
}