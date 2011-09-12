package ru.inspirit.image.mem
{
	import ru.inspirit.image.filter.GaussianFilter;
	import apparat.math.IntMath;
	import apparat.memory.Memory;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	/**
	 * @author Eugene Zatepyakin
	 */
	public final class MemImageUChar
	{
		public var ptr:int;
		public var width:int;
		public var height:int;
		public var size:int;
		
		public var memoryChunkSize:int = 0;
		
		public function calcRequiredChunkSize(width:int, height:int):int
		{
			var size:int = width * height;
			return IntMath.nextPow2(size);
		}
		
		public function setup(memOffset:int, width:int, height:int):void
		{
			this.width = width;
			this.height = height;
			this.size = width * height;

			ptr = memOffset;
			memoryChunkSize = calcRequiredChunkSize( width, height );
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
				var c:uint = Memory.readUnsignedByte(_p);
				vec[i] = c << 16 | c << 8 | c;
			}
			bmp.lock();
			bmp.setVector(new Rectangle(0, 0, w, h), vec);
			bmp.unlock();
		}
		
		public function fill(img:Vector.<uint>):void
		{
			var _ptr:int = ptr;
			MemImageMacro.fillUCharBuffer(_ptr, img);
		}
		
		public function fillAndSmooth3x3(img:Vector.<uint>, w:int, h:int, intBuffer:int):void
		{
			var _ptr:int = ptr;
			MemImageMacro.fillUCharBuffer(_ptr, img);
			
			_ptr = ptr;
			GaussianFilter.gaussSmooth3x3Standard(_ptr, _ptr, w, h, intBuffer);
		}
		
		public function fillAndSmooth5x5(img:Vector.<uint>, w:int, h:int, intBuffer:int):void
		{
			var _ptr:int = ptr;
			MemImageMacro.fillUCharBuffer(_ptr, img);
			
			_ptr = ptr;
			GaussianFilter.gaussSmooth5x5Standard(_ptr, _ptr, w, h, intBuffer);
		}
		
		public function fillAndSmooth7x7(img:Vector.<uint>, w:int, h:int, intBuffer:int):void
		{
			var _ptr:int = ptr;
			MemImageMacro.fillUCharBuffer(_ptr, img);
			
			_ptr = ptr;
			GaussianFilter.gaussSmooth7x7Standard(_ptr, _ptr, w, h, intBuffer);
		}
	}
}
