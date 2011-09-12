package net.blog2t.util
{
    import flash.events.MouseEvent
    import flash.utils.ByteArray;
    import flash.utils.getTimer;
	import flash.display.BitmapData;
    import com.adobe.images.PNGEncoder;
	import flash.net.FileReference;

	public function saveImage(bmpData:BitmapData):void
	{
		try
		{
			var pngBytes:ByteArray= PNGEncoder.encode(bmpData);
			var fileReference:FileReference = new FileReference();
			fileReference.save(pngBytes, "HiSlope_" + getTimer() + ".png");
		}
		
		catch (error:Error)
		{
			trace(error);
		}
	}
}