package ru.inspirit.image.mem
{
	import apparat.math.IntMath;
	import apparat.memory.Memory;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	/**
	 * @author Eugene Zatepyakin
	 */
	public final class MemImageInt
	{
		public var ptr:int;
		public var width:int;
		public var height:int;
		public var size:int;
		
		public var memoryChunkSize:int = 0;
		
		public function calcRequiredChunkSize(width:int, height:int):int
		{
			var size:int = (width * height) << 2;
			return IntMath.nextPow2(size);
		}
		
		public function setup(memOffset:int, width:int, height:int):void
		{
			this.width = width;
			this.height = height;
			this.size = width * height;

			ptr = memOffset;
			
			memoryChunkSize = calcRequiredChunkSize(width, height);
		}
		
		public function render(bmp:BitmapData):void
		{
			var w:int = IntMath.min(bmp.width, width);
			var h:int = IntMath.min(bmp.height, height);
			var area:int = w * h;
			var vec:Vector.<uint> = new Vector.<uint>( area );
			var _p:int = ptr;
			for(var i:int = 0; i < area; ++i, ++_p)
			{
				vec[i] = Memory.readInt(_p);
			}
			bmp.lock();
			bmp.setVector(new Rectangle(0, 0, w, h), vec);
			bmp.unlock();
		}
		
		public function fill(img:Vector.<uint>):void
		{
			var _ptr:int = ptr;
			MemImageMacro.fillIntBuffer(_ptr, img);
		}
	}
}
