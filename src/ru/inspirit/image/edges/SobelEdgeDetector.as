package ru.inspirit.image.edges
{
	import apparat.asm.IncLocalInt;
	import apparat.asm.__asm;
	import apparat.asm.__cint;
	import apparat.math.IntMath;
	import apparat.memory.Memory;
	import apparat.memory.memset;
	
	/**
	 * Edges detector using Sobel Filter
	 * 
	 * @author Eugene Zatepyakin
	 * @see http://blog.inspirit.ru
	 * 
	 * @author Patrick Le Clec'h
	 * lots of speed up tips and tricks ;-) 
	 */
	public class SobelEdgeDetector
	{
		protected var width:int;
		protected var height:int;
		protected var area:int;
		
		public var gradXPtr:int;
		public var gradYPtr:int;
		public var orientPtr:int;
		public var magPtr:int;
		
		public function calcRequiredChunkSize(width:int, height:int):int
		{
			var size:int = 0;
			size += (width * height) << 2;
			size += (width * height) << 2;
			size += (width * height) << 2;
			size += (width * height);
			
			return IntMath.nextPow2(size);
		}
		
		public function setup(memOffset:int, width:int, height:int):void
		{
			this.width = width;
			this.height = height;
			this.area = width * height;
			
			gradXPtr = memOffset;
			gradYPtr = gradXPtr + (area << 2);
			magPtr = gradYPtr + (area << 2);
			orientPtr = magPtr + (area << 2);
		}
		
		/**
		 * @param imgPtr	mem offset to image data (uchar)
		 * @param edgPtr	mem offset to edges data (int)
		 */
		public function detect(imgPtr:int, edgPtr:int, w:int, h:int):void
		{
			var row:int = __cint(imgPtr + w + 1);
			var row_top:int;
			var row_bot:int;
			var eh:int = __cint(h - 1);
			var ew:int = __cint(w - 1);
			var cr:int, a:int, b:int, c:int, outxp:int, outyp:int, outop:int;
			var i:int, j:int, d:int, e:int, dx:int, dy:int, dir:int;
			var stride4:int = w << 2;
			var out_rowx:int = __cint(gradXPtr + stride4 + 4);
			var out_rowy:int = __cint(gradYPtr + stride4 + 4);
			var out_ori:int = __cint(orientPtr + w + 1);
			
			for(i = 1; i < eh; ++i)
			{
				cr = row;
				row_top = __cint(cr - w);
				row_bot = __cint(cr + w);
				outxp = out_rowx;
				outyp = out_rowy;
				outop = out_ori;
				
				a = Memory.readUnsignedByte(row_bot - 1);
				b = Memory.readUnsignedByte(row_top - 1);
				c = Memory.readUnsignedByte(row_top + 1);
				d = Memory.readUnsignedByte(row_bot);
				e = Memory.readUnsignedByte(row_top);
			
				for(j = 1; j < ew; ++j)
				{
					// this one returns lower values
					//dx = __cint( (a + (d << 1) + a - b - (e << 1) - c) >> 3 );
					//dy = __cint( (b + (Memory.readUnsignedByte(cr-1) << 1) + a - c - (Memory.readUnsignedByte(cr+1) << 1) - a) >> 3 );
					
					// this is for stronger gradient values
					dx = __cint( (a + (d << 1) + a - b - (e << 1) - c) >> 1 );
					dy = __cint( (b + (Memory.readUnsignedByte(cr-1) << 1) + a - c - (Memory.readUnsignedByte(cr+1) << 1) - a) >> 1 );
					
					// write abs values for NonMaxSuppress
					var abs_dx:int= __cint((1-(int(dx<0)<<1))*dx);
					var abs_dy:int= __cint((1-(int(dy<0)<<1))*dy);
		
					Memory.writeInt(abs_dx, outxp);
					Memory.writeInt(abs_dy, outyp);
					
					// directions
					// 0 -> |
					// 1 -> -
					// 2 -> /
					// 3 -> \
			
					abs_dx <<= 7;
					var dyeqz:int=int(dy==0);
					var dxltz:int=int(dx<0);
					var adxgtz309:int=int(abs_dx > __cint(309*abs_dy));
					dir=__cint((1-int(dx==0)) * (dyeqz + (1-dyeqz) * ( adxgtz309+(1-adxgtz309)*int(abs_dx > __cint(53*abs_dy))*(2+dxltz*int(dy>=0)+(1-dxltz)*int(dy<0)))));
					
					Memory.writeByte(dir, outop);					
					
					__asm(IncLocalInt(cr),IncLocalInt(row_top),IncLocalInt(row_bot),IncLocalInt(outop));
					outxp = __cint(outxp + 4);
					outyp = __cint(outyp + 4);
					a=d;
					b=e;
					e=c;
					d = Memory.readUnsignedByte(row_bot);
					c = Memory.readUnsignedByte(row_top + 1);
				}
				row = __cint(row + w);
				out_ori = __cint(out_ori + w);
				out_rowx = __cint(out_rowx + stride4);
				out_rowy = __cint(out_rowy + stride4);
			}
			
			// Suppress Non Maximum Edges

			row = __cint(edgPtr + stride4);
			out_rowx = __cint(gradXPtr + stride4 + 4);
			out_rowy = __cint(gradYPtr + stride4 + 4);
			out_ori = __cint(orientPtr + w + 1);
			var addrx1:int, addrx2:int, addry1:int, addry2:int, offset:int, cased0:int, case1_d0:int;
			
			memset(edgPtr, 0, stride4);
			
			for(i = 1; i < eh; ++i)
			{
				Memory.writeInt( 0, row );
				row = __cint(row + 4);
				outxp = out_rowx;
				outyp = out_rowy;
				var xrow_top:int = __cint(outxp - stride4);
				var xrow_bot:int = __cint(outxp + stride4);
				var yrow_top:int = __cint(outyp - stride4);
				var yrow_bot:int = __cint(outyp + stride4);
				outop = out_ori;
			
				for(j = 1; j < ew; ++j)
				{
					dir = Memory.readUnsignedByte(outop);
					
					a = __cint(Memory.readInt(outxp) + Memory.readInt(outyp));
					//
					// directions
					// 0 -> |
					// 1 -> -
					// 2 -> /
					// 3 -> \
					//
					offset   = __cint((4-((dir&1)<<3)) * int(dir!=1));
					//offset   = __cint((4-((dir&2)<<3)) * int(dir!=1));
					cased0   = int(dir==0);
					case1_d0 = __cint(1-cased0);
					
					addrx1   = __cint(outxp*cased0);
					addry1   = __cint(outyp*cased0);
					addrx2   = __cint(addrx1+case1_d0*xrow_bot);
					addry2   = __cint(addry1+case1_d0*yrow_bot);
					addrx1   = __cint(addrx1+case1_d0*xrow_top);
					addry1   = __cint(addry1+case1_d0*yrow_top);
		
					Memory.writeInt(
						__cint(a*(int(( Memory.readInt(addrx1-offset) + Memory.readInt(addry1-offset) ) <= a) & 
				          int(( Memory.readInt(addrx2+offset) + Memory.readInt(addry2+offset) ) <= a))), row);
					//
					__asm(IncLocalInt(outop));
					row = __cint(row + 4);
					outxp = __cint(outxp + 4);
					outyp = __cint(outyp + 4);
					xrow_top = __cint(xrow_top + 4);
					xrow_bot = __cint(xrow_bot + 4);
					yrow_top = __cint(yrow_top + 4);
					yrow_bot = __cint(yrow_bot + 4);
				}
				//
				Memory.writeInt( 0, row );
				row = __cint(row + 4);
				//
				out_ori = __cint(out_ori + w);
				out_rowx = __cint(out_rowx + stride4);
				out_rowy = __cint(out_rowy + stride4);
			}
			
			memset(row, 0, stride4);
		}
	}
}
