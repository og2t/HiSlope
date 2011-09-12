package ru.inspirit.image.mem
{
	import apparat.asm.*;
	import apparat.inline.Macro;
	import apparat.math.FastMath;
	import apparat.memory.Memory;
	/**
	 * @author Eugene Zatepyakin
	 */
	public final class MemImageMacro extends Macro
	{	
		public static function fillUCharBuffer(ptr:int, img:Vector.<uint>):void
		{
			var i:int = 0;
			var n:int = img.length;
			var bit32:int = (n >> 6) + 1;
			
			__asm(
				'loop:',
				DecLocalInt(bit32),
				GetLocal(bit32),
				PushByte(0),
				IfEqual('endLoop')
				);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					//
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					//
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					//
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					//
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					//
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					//
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					//
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
					MemImageMacro.fillUCharPass(ptr, i, img);
			__asm(
				Jump('loop'),
				'endLoop:'
				);
			__asm(
				'loop1:',
				GetLocal(i),
				GetLocal(n),
				IfEqual('endLoop1')
				);
					MemImageMacro.fillUCharPass(ptr, i, img);
			__asm(
				Jump('loop1'),
				'endLoop1:'
			);
		}
		
		public static function fillIntBuffer(ptr:int, img:Vector.<uint>):void
		{
			var i:int = 0;
			var n:int = img.length;
			var bit32:int = (n >> 5) + 1;
			
			__asm(
				'loop:',
				DecLocalInt(bit32),
				GetLocal(bit32),
				PushByte(0),
				IfEqual('endLoop')
				);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					//
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					//
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					//
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
					MemImageMacro.fillIntPass(ptr, i, img);
			__asm(
				Jump('loop'),
				'endLoop:'
				);
			__asm(
				'loop1:',
				GetLocal(i),
				GetLocal(n),
				IfEqual('endLoop1')
				);
					MemImageMacro.fillIntPass(ptr, i, img);
			__asm(
				Jump('loop1'),
				'endLoop1:'
			);
		}
		
		/**
		 * image gradient magnitude computation using Sobel filter
		 * thanx to Patrick Le Clec'h for optimizing
		 * @param imgPtr	memory offset to input UCHAR image
		 * @param gradPtr	memory offset to output INT image 
		 */
		public static function computeSobelGradientMagnitude(imgPtr:int, gradPtr:int, w:int, h:int):void
		{
			var row:int = __cint(imgPtr + w + 1);
			var row_top:int;
			var row_bot:int;
			var eh:int = __cint(h - 1);
			var ew:int = __cint(w - 1);
			var cr:int, a:int, b:int, c:int, outp:int;
			var i:int, j:int, d:int, e:int, dx:int, dy:int; 
			var stride4:int = w << 2;
			var out_row:int = __cint(gradPtr + stride4 + 4);
			
			for(i = 1; i < eh; ++i)
			{
				cr = row;
				row_top = __cint(cr - w);
				row_bot = __cint(cr + w);
				outp = out_row;
				
				a = Memory.readUnsignedByte(row_bot - 1);
				b = Memory.readUnsignedByte(row_top - 1);
				c = Memory.readUnsignedByte(row_top + 1);
				d = Memory.readUnsignedByte(row_bot);
				e = Memory.readUnsignedByte(row_top);
			
				for(j = 1; j < ew; ++j)
				{
					dx = __cint( (a + (d << 1) + a - b - (e << 1) - c) >> 3 );
					dy = __cint( (b + (Memory.readUnsignedByte(cr-1) << 1) + a - c - (Memory.readUnsignedByte(cr+1) << 1) - a) >> 3 );
					Memory.writeInt(__cint(dx*dx + dy*dy), outp);
					__asm(IncLocalInt(cr),IncLocalInt(row_top),IncLocalInt(row_bot));
					outp = __cint(outp + 4);
					a=d;
					b=e;
					e=c;
					d = Memory.readUnsignedByte(row_bot);
					c = Memory.readUnsignedByte(row_top + 1);
				}
				row = __cint(row + w);
				out_row = __cint(out_row + stride4);
			}
		}
		
		public static function computeSobelDxDyGradient(imgPtr:int, gradXPtr:int, gradYPtr:int, w:int, h:int):void
		{
			var row:int = __cint(imgPtr + w + 1);
			var row_top:int;
			var row_bot:int;
			var eh:int = __cint(h - 1);
			var ew:int = __cint(w - 1);
			var cr:int, a:int, b:int, c:int, outxp:int, outyp:int;
			var i:int, j:int, d:int, e:int, dx:int, dy:int; 
			var stride4:int = w << 2;
			var out_rowx:int = __cint(gradXPtr + stride4 + 4);
			var out_rowy:int = __cint(gradYPtr + stride4 + 4);
			
			for(i = 1; i < eh; ++i)
			{
				cr = row;
				row_top = __cint(cr - w);
				row_bot = __cint(cr + w);
				outxp = out_rowx;				outyp = out_rowy;
				
				a = Memory.readUnsignedByte(row_bot - 1);
				b = Memory.readUnsignedByte(row_top - 1);
				c = Memory.readUnsignedByte(row_top + 1);
				d = Memory.readUnsignedByte(row_bot);
				e = Memory.readUnsignedByte(row_top);
			
				for(j = 1; j < ew; ++j)
				{
					dx = __cint( (a + (d << 1) + a - b - (e << 1) - c) >> 3 );
					dy = __cint( (b + (Memory.readUnsignedByte(cr-1) << 1) + a - c - (Memory.readUnsignedByte(cr+1) << 1) - a) >> 3 );
					Memory.writeInt(dx, outxp);					Memory.writeInt(dy, outyp);
					__asm(IncLocalInt(cr),IncLocalInt(row_top),IncLocalInt(row_bot));
					outxp = __cint(outxp + 4);					outyp = __cint(outyp + 4);
					a=d;
					b=e;
					e=c;
					d = Memory.readUnsignedByte(row_bot);
					c = Memory.readUnsignedByte(row_top + 1);
				}
				row = __cint(row + w);
				out_rowx = __cint(out_rowx + stride4);				out_rowy = __cint(out_rowy + stride4);
			}
		}
		
		/**
		 * image gradient magnitude computation
		 * @param imgPtr	memory offset to input UCHAR image
		 * @param gradPtr	memory offset to output INT image 
		 */
		public static function computeImageGradientMagnitude(imgPtr:int, gradPtr:int, w:int, h:int):void
		{
			var x:int, y:int, a:int, b:int, c:int, d:int;
			var img_xendp:int, img_endp:int;

			img_endp = __cint(imgPtr + w*(h-1));
			
			for (; imgPtr < img_endp; ) 
			{
		        a = Memory.readUnsignedByte(imgPtr);
		        c = Memory.readUnsignedByte(__cint(imgPtr+w));
		        
		        __asm(__cint(imgPtr + w - 1), SetLocal(img_xendp));
		        for (; imgPtr < img_xendp; ) 
		        {
		            __asm(IncLocalInt(imgPtr));
		
		            b = Memory.readUnsignedByte(imgPtr);
		            d = Memory.readUnsignedByte(__cint(imgPtr+w));
		
		            a = __cint(d - a);
		            c = __cint(b - c);
		            x = __cint(a + c);
		            y = __cint(a - c);
		
		            a = b;
		            c = d;

					Memory.writeInt(__cint(x * x + y * y), gradPtr);
					__asm(GetLocal(gradPtr),PushByte(4),AddInt,SetLocal(gradPtr));
		        }		
		        __asm(IncLocalInt(imgPtr));
		        __asm(GetLocal(gradPtr),PushByte(4),AddInt,SetLocal(gradPtr));
		    }
		}
		
		public static function computeIntegralImage(srcPtr:int, dstPtr:int, w:int, h:int):void
		{
			var rowI:int = srcPtr;
			var rowII:int = dstPtr;
			var sum:int = 0;
			var i:int = __cint(w + 1);
			var j:int;
			
			__asm(
					'loop:',
					DecLocalInt(i),
					GetLocal(i),
					PushByte(0),
					IfEqual('endLoop') );
			//      
			__asm( GetLocal(sum),GetLocal(rowI),GetByte,AddInt,SetLocal(sum),GetLocal(sum),GetLocal(rowII),SetInt );
			__asm( IncLocalInt( rowI ), GetLocal( rowII ), PushByte( 4 ), AddInt, SetLocal(rowII));
			//
			__asm(
					Jump('loop'),
					'endLoop:'
					);
			// 
	
			var prowII:int = __cint(dstPtr - rowII);
			var endI:int = __cint(srcPtr + (w*h));
			sum = i = 0;
			while( rowI < endI )
			{
				j = int(i<w);
				i=__cint(j*i+1);
				sum = __cint(j*sum+Memory.readUnsignedByte(rowI));
				Memory.writeInt(__cint(sum+Memory.readInt(prowII+rowII)), rowII);
				__asm( IncLocalInt(rowI) );
				rowII = __cint(rowII+4);
			}	
		}
		
		public static function pyrDown(fromPtr:int, toPtr:int, newW:int, newH:int):void
		{
			var i:int;
			var ow:int = newW << 1;
			var out:int = toPtr;
			var rem:int = (newW >> 5) + 1;
			var tail:int = (newW % 32) + 1;
			var br:int;
			
			var row0:int = fromPtr;
			var row1:int = row0 + ow;

			for(i = 0; i < newH; ++i)
			{
				
				br = rem;
				__asm(
					'loop:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop')
					);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					//
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
					MemImageMacro.pyrPass(row0, row1, out);
				__asm(
					Jump('loop'),
					'endLoop:'
				);
				// finish
				br = tail;
				__asm(
					'loop1:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop1')
					);
					MemImageMacro.pyrPass(row0, row1, out);
				__asm(
					Jump('loop1'),
					'endLoop1:'
					);
					
				row0 += ow;
				row1 = row0 + ow;
			}
		}
		
		public static function bilinearInterpolation(imgPtr:int, stride:int, x:Number, y:Number, val:Number):void
		{
			var mnx:int = x;
			var mny:int = y;
			var mxx:int = FastMath.rint( x + 0.4999 );
			var mxy:int = FastMath.rint( y + 0.4999 );
			
			var alfa:Number = mxx - x;
			var beta:Number = mxy - y;
			
			alfa=Number(alfa>=0.001)*alfa;
			var tmp:Number=Number(alfa<=0.999);
			alfa=tmp*alfa+(1.0-tmp);
			
			alfa=Number(beta>=0.001)*alfa; 
			tmp=Number(beta<=0.999);
			beta=tmp*beta+(1.0-tmp);
			
			var mnyw:int = mny * stride;
			//var mxyw:int = mxy * stride;    
			 
			var iywx:Number=Memory.readUnsignedByte(imgPtr + mnyw+mnx);
			var iywxx:Number=Memory.readUnsignedByte(imgPtr + mnyw+mxx);
			
			val = (beta * (alfa * iywx + (1.0-alfa) *  iywxx) + (1.0-beta) * (alfa * iywx + (1.0-alfa) * iywxx));
		}
		
		internal static function fillUCharPass(ptr:int, i:int, img:Vector.<uint>):void
		{
			__asm(
				GetLocal(img),
				GetLocal(i),
				GetProperty(AbcMultinameL(AbcNamespaceSet(AbcNamespace(NamespaceKind.PACKAGE, "")))),
				ConvertInt,
				GetLocal(ptr),
				SetByte,
				IncLocalInt(i),
				IncLocalInt(ptr)
			);
		}
		internal static function fillIntPass(ptr:int, i:int, img:Vector.<uint>):void
		{
			__asm(
				GetLocal(img),
				GetLocal(i),
				GetProperty(AbcMultinameL(AbcNamespaceSet(AbcNamespace(NamespaceKind.PACKAGE, "")))),
				ConvertInt,
				GetLocal(ptr),
				SetInt,
				IncLocalInt(i),
				GetLocal(ptr),
				PushByte(4),
				AddInt,
				SetLocal(ptr)
			);
		}
		
		internal static function pyrPass(row0:int, row1:int, out:int):void
		{
			__asm(
				GetLocal(row0),
				GetByte,
				IncLocalInt(row0),
				GetLocal(row0),
				GetByte,
				AddInt,				
				GetLocal(row1),
				GetByte,
				AddInt,
				IncLocalInt(row1),
				GetLocal(row1),
				GetByte,
				AddInt,
				PushByte(2),
				ShiftRight, 
				GetLocal( out ), 
				SetByte,
				IncLocalInt(out),
				IncLocalInt(row0),
				IncLocalInt(row1)
			);
		}
	}
}
