package ru.inspirit.image.klt
{
	import apparat.asm.AddInt;
	import apparat.asm.GetLocal;
	import apparat.asm.IncLocalInt;
	import apparat.asm.PushByte;
	import apparat.asm.SetLocal;
	import apparat.asm.__asm;
	import apparat.asm.__cint;
	import apparat.inline.Macro;
	import apparat.math.FastMath;
	import apparat.memory.Memory;

	/**
	 * @author Eugene Zatepyakin
	 */
	public final class KLTMacro extends Macro
	{
		public static function getRectSubPix( 
									srcptr:int, src_step:int,
  									dstptr:int, win_sizeW:int, winH:int, 
  									cx:Number, cy:Number, convPtr:int ):void
		{
		    var ipx:int, ipy:int;
		    var a12:Number, a22:Number, b1:Number, b2:Number;
		    var a:Number, b:Number;
		    var s:Number;
		    var j:int;
		    var prev:Number, t:Number;
		    var win_sizeH:int = winH;
		
		    var centerx:Number = cx - (win_sizeW-1) * 0.5;
		    var centery:Number = cy - (win_sizeH-1) * 0.5;
		
		    ipx = centerx;
		    ipy = centery;
		    
		    a = centerx - ipx;
		    b = centery - ipy;
		    a = FastMath.max(a, 0.0001);
		    a12 = a*(1.0-b);
		    a22 = a*b;
		    b1 = 1.0 - b;
		    b2 = b;
		    s = (1.0 - a) / a;
		    var an1:Number = (1.0 - a);
		
		    srcptr = __cint(srcptr + ipy * src_step + ipx);
		    var btr:int;
	
	        for( ; win_sizeH--; )
	        {
	        	var _src:int = srcptr;
	        	btr = __cint(_src + src_step);
	        	
				prev = an1 * (b1 * __cint(Memory.readInt( convPtr + ((Memory.readUnsignedByte( _src ) + 256) << 2) )) 
							+ b2 * __cint(Memory.readInt( convPtr + ((Memory.readUnsignedByte( btr ) + 256) << 2) )) );
				__asm(IncLocalInt(_src), IncLocalInt(btr));
	            for( j = 0; j < win_sizeW; ++j )
	            {
					t =   a12 * __cint(Memory.readInt( convPtr + ((Memory.readUnsignedByte( _src ) + 256) << 2) )) 
						+ a22 * __cint(Memory.readInt( convPtr + ((Memory.readUnsignedByte( btr ) + 256) << 2) ));
					Memory.writeDouble( prev + t, dstptr );
	                prev = t * s;
	                
	               __asm(GetLocal(dstptr),PushByte(8),AddInt,SetLocal(dstptr));
	               __asm(IncLocalInt(_src), IncLocalInt(btr));
	            }
	            srcptr = __cint(srcptr + src_step);
	        }
		}
		
		public static function calcIxIy( 
								srcptr:int, src_step:int, dstXptr:int, dstYptr:int,
         						src_sizeW:int, src_sizeH:int, smooth0:Number, smooth1:Number, buffer0ptr:int ):void
		{
		    var src_width:int = src_sizeW;
		    var dst_width:int = __cint(src_sizeW - 2);
		    var t0:Number, t1:Number;
		    var x:int, height:int = __cint(src_sizeH - 2);
		    var buffer1ptr:int;
		    var buffer00ptr:int;
		    var src2ptr:int = __cint(srcptr + src_step);
			var src3ptr:int = __cint(src2ptr + src_step);
			
		    for( ;  height--; )
		    {
				buffer00ptr = buffer0ptr;
				buffer1ptr = __cint(buffer0ptr + src_step);
		        for( x = 0; x < src_width; ++x )
		        {
					t0 = Memory.readDouble(srcptr);
					t1 = Memory.readDouble(src3ptr);
					Memory.writeDouble(
										(t1 + t0) * smooth0 + Memory.readDouble(src2ptr) * smooth1, 
										buffer00ptr);
					Memory.writeDouble(
										t1 - t0, 
										buffer1ptr);
					// move pointers
					__asm(
                        	GetLocal(buffer00ptr),PushByte(8),AddInt,SetLocal(buffer00ptr),
							GetLocal(buffer1ptr),PushByte(8),AddInt,SetLocal(buffer1ptr),
							GetLocal(srcptr),PushByte(8),AddInt,SetLocal(srcptr),
							GetLocal(src2ptr),PushByte(8),AddInt,SetLocal(src2ptr),
							GetLocal(src3ptr),PushByte(8),AddInt,SetLocal(src3ptr)
                        	);
		        }
		        buffer00ptr = buffer0ptr;
				buffer1ptr = __cint(buffer0ptr + src_step);
		        for( x = 0; x < dst_width; ++x )
		        {
		            Memory.writeDouble(
		            					Memory.readDouble(__cint(buffer00ptr + 16)) - Memory.readDouble(buffer00ptr), 
		            					dstXptr);
					Memory.writeDouble(
		            					(Memory.readDouble(buffer1ptr) + Memory.readDouble(__cint(buffer1ptr + 16))) * smooth0 + Memory.readDouble(__cint(buffer1ptr + 8)) * smooth1, 
		            					dstYptr);
		            __asm(
                        	GetLocal(buffer00ptr),PushByte(8),AddInt,SetLocal(buffer00ptr),
							GetLocal(buffer1ptr),PushByte(8),AddInt,SetLocal(buffer1ptr),
							GetLocal(dstXptr),PushByte(8),AddInt,SetLocal(dstXptr),
							GetLocal(dstYptr),PushByte(8),AddInt,SetLocal(dstYptr)
                        	);
		        }
		    }
		}
	}
}
