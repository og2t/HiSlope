package ru.inspirit.image.filter
{
	import apparat.asm.*;
	import apparat.inline.Macro;
	import apparat.memory.Memory;
	
	/**
	 * @author Eugene Zatepyakin
	 */
	 
	public final class GaussianFilter extends Macro
	{		
		public static function gaussSmooth3x3(src:int, dst:int, w:int, h:int, int_buffer:int, W0:int, W1:int, shift:int):void
		{
			var y:int;
			var int_stride:int = w << 2;
			var rem:int = __cint(((w-2) >> 3) + 1);
			var tail:int = __cint(((w-2) % 8) + 1);
			var br:int;
			
			var src_row:int, ints:int;
			var src_row2:int = __cint(src + 1);
  			var ints2:int = __cint(int_buffer + 4);
			
			// First pass: make use of intermediate_int_image
			for(y = 0; y < h; ++y) 
			{
				src_row = src_row2;
				ints = ints2;
				
				//var a0:int = Memory.readUnsignedByte(src_row-1);
	            //var a1:int = Memory.readUnsignedByte(src_row);
	            //var _w:int;
	            
				br = rem;
				__asm(
					'loop:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop')
					);
					// main loop
					GaussianFilterMacro.gauss3x3AsmPass1( src_row , ints, W0, W1);
					GaussianFilterMacro.gauss3x3AsmPass1( src_row , ints, W0, W1);
					GaussianFilterMacro.gauss3x3AsmPass1( src_row , ints, W0, W1);
					GaussianFilterMacro.gauss3x3AsmPass1( src_row , ints, W0, W1);
					GaussianFilterMacro.gauss3x3AsmPass1( src_row , ints, W0, W1);
					GaussianFilterMacro.gauss3x3AsmPass1( src_row , ints, W0, W1);
					GaussianFilterMacro.gauss3x3AsmPass1( src_row , ints, W0, W1);
					GaussianFilterMacro.gauss3x3AsmPass1( src_row , ints, W0, W1);
					/*GaussianFilter.gauss3x3AsmPass1_1(src_row, ints, a0, a1, _w, W0, W1);
					GaussianFilter.gauss3x3AsmPass1_1(src_row, ints, a0, a1, _w, W0, W1);
					GaussianFilter.gauss3x3AsmPass1_1(src_row, ints, a0, a1, _w, W0, W1);
					GaussianFilter.gauss3x3AsmPass1_1(src_row, ints, a0, a1, _w, W0, W1);
					GaussianFilter.gauss3x3AsmPass1_1(src_row, ints, a0, a1, _w, W0, W1);
					GaussianFilter.gauss3x3AsmPass1_1(src_row, ints, a0, a1, _w, W0, W1);
					GaussianFilter.gauss3x3AsmPass1_1(src_row, ints, a0, a1, _w, W0, W1);
					GaussianFilter.gauss3x3AsmPass1_1(src_row, ints, a0, a1, _w, W0, W1);*/
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
					GaussianFilterMacro.gauss3x3AsmPass1( src_row , ints, W0, W1);
					//GaussianFilter.gauss3x3AsmPass1_1(src_row, ints, a0, a1, _w, W0, W1);
				__asm(
					Jump('loop1'),
					'endLoop1:'
					);
				
				src_row2 = __cint(src_row2 + w);
				Memory.writeInt(Memory.readInt(ints2), __cint(ints2 - 4));
				ints2 = __cint(ints2 + int_stride);
				Memory.writeInt(Memory.readInt(__cint(ints2 - 12)), __cint(ints2 - 8));
			}
			
			// Second pass:
			var delta:int = __cint(1 << (shift - 1));
			rem = __cint((w >> 3) + 1);
			tail = __cint((w % 8) + 1);
			
			var row0:int = int_buffer;
			var row1:int = __cint(row0 + int_stride);
			var row2:int = __cint(row1 + int_stride);
			
			var dest:int = dst + w;
			
			for(y = 1; y < h - 1; ++y) 
			{				
				br = rem;
				__asm(
					'loop2:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop2')
					);
					//
					GaussianFilterMacro.gauss3x3AsmPass2(dest, row0, row1, row2, W0, W1, delta, shift);
					GaussianFilterMacro.gauss3x3AsmPass2(dest, row0, row1, row2, W0, W1, delta, shift);
					GaussianFilterMacro.gauss3x3AsmPass2(dest, row0, row1, row2, W0, W1, delta, shift);
					GaussianFilterMacro.gauss3x3AsmPass2(dest, row0, row1, row2, W0, W1, delta, shift);
					GaussianFilterMacro.gauss3x3AsmPass2(dest, row0, row1, row2, W0, W1, delta, shift);
					GaussianFilterMacro.gauss3x3AsmPass2(dest, row0, row1, row2, W0, W1, delta, shift);
					GaussianFilterMacro.gauss3x3AsmPass2(dest, row0, row1, row2, W0, W1, delta, shift);
					GaussianFilterMacro.gauss3x3AsmPass2(dest, row0, row1, row2, W0, W1, delta, shift);
					//
				__asm(
					Jump('loop2'),
					'endLoop2:'
					);
				
				// finish
				br = tail;
				__asm(
					'loop3:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop3')
					);
					//
					GaussianFilterMacro.gauss3x3AsmPass2(dest, row0, row1, row2, W0, W1, delta, shift);
					//
				__asm(
					Jump('loop3'),
					'endLoop3:'
					);
			}
			
			// Second pass: borders...
			var dest0:int = dst;
			var dest1:int = dest0 + w;
			var destw1:int = dst + (h-1) * w;
			var destw2:int = destw1 - w;
			
			br = rem;
			__asm(
				'loop4:',
				DecLocalInt(br),
				GetLocal(br),
				PushByte(0),
				IfEqual('endLoop4')
				);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
			__asm(
				Jump('loop4'),
				'endLoop4:'
				);
				
			br = tail;
			__asm(
				'loop5:',
				DecLocalInt(br),
				GetLocal(br),
				PushByte(0),
				IfEqual('endLoop5')
				);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
			__asm(
				Jump('loop5'),
				'endLoop5:'
				);			
		}
		
		public static function gaussSmooth3x3Standard(src:int, dst:int, w:int, h:int, int_buffer:int):void
		{
			var y:int;
			var int_stride:int = w << 2;
			var rem:int = __cint(((w-2) >> 3) + 1);
			var tail:int = __cint(((w-2) % 8) + 1);
			var br:int;
			//var W0:int = 2;
			//var W1:int = 1;
			//var shift:int= 4;
			
			var src_row:int, ints:int;
			var src_row2:int = __cint(src + 1);
  			var ints2:int = __cint(int_buffer + 4);
			
			// First pass: make use of intermediate_int_image
			for(y = 0; y < h; ++y) 
			{
				src_row = src_row2;
				ints = ints2;
	            
				br = rem;
				__asm(
					'loop:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop')
					);
					// main loop
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
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
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
				__asm(
					Jump('loop1'),
					'endLoop1:'
					);
				
				src_row2 = __cint(src_row2 + w);
				Memory.writeInt(Memory.readInt(ints2), __cint(ints2 - 4));
				ints2 = __cint(ints2 + int_stride);
				Memory.writeInt(Memory.readInt(__cint(ints2 - 12)), __cint(ints2 - 8));
			}
			
			// Second pass:
			//var delta:int = 8;
			rem = __cint((w >> 3) + 1);
			tail = __cint((w % 8) + 1);
			
			var row0:int = int_buffer;
			var row1:int = __cint(row0 + int_stride);
			var row2:int = __cint(row1 + int_stride);
			
			var dest:int = __cint(dst + w);
			var eh:int = __cint(h-1);
			
			for(y = 1; y < eh; ++y) 
			{				
				br = rem;
				__asm(
					'loop2:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop2')
					);
					//
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					//
				__asm(
					Jump('loop2'),
					'endLoop2:'
					);
				
				// finish
				br = tail;
				__asm(
					'loop3:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop3')
					);
					//
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					//
				__asm(
					Jump('loop3'),
					'endLoop3:'
					);
			}
			
			// Second pass: borders...
			var dest0:int = dst;
			var dest1:int = __cint(dest0 + w);
			var destw1:int = __cint(dst + eh * w);
			var destw2:int = __cint(destw1 - w);
			
			br = rem;
			__asm(
				'loop4:',
				DecLocalInt(br),
				GetLocal(br),
				PushByte(0),
				IfEqual('endLoop4')
				);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
			__asm(
				Jump('loop4'),
				'endLoop4:'
				);
				
			br = tail;
			__asm(
				'loop5:',
				DecLocalInt(br),
				GetLocal(br),
				PushByte(0),
				IfEqual('endLoop5')
				);
				GaussianFilterMacro.gauss3x3AsmPass2Brd(dest0, dest1, destw1, destw2);
			__asm(
				Jump('loop5'),
				'endLoop5:' );
				
			//TestDescribe._txt.appendText( [dest0, dest1, destw1, destw2]+'\n');		
			//TestDescribe._txt.appendText( [row2, ints]+'\n');			
		}
		
		public static function gaussSmooth3x3StandardLimited(src:int, dst:int, w:int, h:int, int_buffer:int):void
		{
			var y:int;
			var int_stride:int = w << 2;
			var br:int;
			
			var align:int = 16;
			var w16:int = __cint((w-2) + align - 1) & ~int(align-1);
			w16 = __cint(w16 - int(w16 > w) * align);
			var rem:int =  __cint((w16 >> 4) + 1);
			
			var src_row:int, ints:int;
			var src_row2:int = __cint(src + 1);
  			var ints2:int = __cint(int_buffer + 4);
			
			// First pass: make use of intermediate_int_image
			for(y = 0; y < h;) 
			{
				src_row = src_row2;
				ints = ints2;
	            
				br = rem;
				__asm(
					'loop:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop')
					);
					// main loop
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					//
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss3x3AsmPass1Std( src_row , ints);
				__asm(
					Jump('loop'),
					'endLoop:'
				);
				
				src_row2 = __cint(src_row2 + w);
				ints2 = __cint(ints2 + int_stride);
				__asm(IncLocalInt(y));
			}
			
			// Second pass:
			w16 = __cint(w + align - 1) & ~int(align - 1);
			w16 = __cint(w16 - int(w16 > w) * align);
			rem = __cint((w16 >> 4) + 1);
			
			var row0:int = src_row2 = int_buffer;
			var row1:int = __cint(row0 + int_stride);
			var row2:int = __cint(row1 + int_stride);
			
			var dest:int = __cint(dst + w);
			var eh:int = __cint(h-1);
			
			for(y = 1; y < eh;) 
			{				
				br = rem;
				__asm(
					'loop2:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop2')
					);
					//
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					//
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
					GaussianFilterMacro.gauss3x3AsmPass2Std(dest, row0, row1, row2);
				__asm(
					Jump('loop2'),
					'endLoop2:'
					);
				
				src_row2 = row0 = __cint(src_row2 + int_stride);
				row1 = __cint(row0 + int_stride);
				row2 = __cint(row1 + int_stride);
				__asm(IncLocalInt(y));
			}
		}
		
		public static function gaussSmooth5x5(src:int, dst:int, w:int, h:int, int_buffer:int, W0:int, W1:int, W2:int, shift:int):void
		{
			var y:int, tmp:int;
			var int_stride:int = w << 2;
			var rem:int =  ((w-4) >> 3) + 1;
			var tail:int = ((w-4) % 8) + 1;
			var br:int;
			
			var src_row:int, ints:int;
			var src_row2:int = src + 2;
  			var ints2:int = int_buffer + 8;
			
			// First pass: make use of intermediate_int_image
			for(y = 0; y < h; ++y) 
			{
				//var src_row:int = src + (y * w) + 2;
				//var ints:int = int_buffer + (y * int_stride);
				src_row = src_row2;
				ints = ints2;
				
				br = rem;
				__asm(
					'loop:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop')
					);
					// main loop
					GaussianFilterMacro.gauss5x5AsmPass1( src_row , ints, W0, W1, W2);
					GaussianFilterMacro.gauss5x5AsmPass1( src_row , ints, W0, W1, W2);
					GaussianFilterMacro.gauss5x5AsmPass1( src_row , ints, W0, W1, W2);
					GaussianFilterMacro.gauss5x5AsmPass1( src_row , ints, W0, W1, W2);
					GaussianFilterMacro.gauss5x5AsmPass1( src_row , ints, W0, W1, W2);
					GaussianFilterMacro.gauss5x5AsmPass1( src_row , ints, W0, W1, W2);
					GaussianFilterMacro.gauss5x5AsmPass1( src_row , ints, W0, W1, W2);
					GaussianFilterMacro.gauss5x5AsmPass1( src_row , ints, W0, W1, W2);

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
					GaussianFilterMacro.gauss5x5AsmPass1( src_row , ints, W0, W1, W2);
				__asm(
					Jump('loop1'),
					'endLoop1:'
					);
				
				src_row2 += w;
				
				tmp = Memory.readInt(ints2);
				Memory.writeInt(tmp, ints2-4);
				Memory.writeInt(tmp, ints2-8);
				ints2 += int_stride;
				tmp = Memory.readInt(ints2 - 20);
				Memory.writeInt(tmp, ints2 - 16);
				Memory.writeInt(tmp, ints2 - 12);
			}
				
			// Second pass:
			var delta:int = 1 << (shift - 1);
			rem = (w >> 3) + 1;
			tail = (w % 8) + 1;
			
			var row0:int = int_buffer;
			var row1:int = row0 + int_stride;
			var row2:int = row1 + int_stride;
			var row3:int = row2 + int_stride;
			var row4:int = row3 + int_stride;
			
			var dest:int = dst + (w << 1);
			
			for(y = 2; y < h - 2; ++y) 
			{				
				br = rem;
				__asm(
					'loop2:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop2')
					);
					//
					GaussianFilterMacro.gauss5x5AsmPass2(dest, row0, row1, row2, row3, row4, W0, W1, W2, delta, shift);
					GaussianFilterMacro.gauss5x5AsmPass2(dest, row0, row1, row2, row3, row4, W0, W1, W2, delta, shift);
					GaussianFilterMacro.gauss5x5AsmPass2(dest, row0, row1, row2, row3, row4, W0, W1, W2, delta, shift);
					GaussianFilterMacro.gauss5x5AsmPass2(dest, row0, row1, row2, row3, row4, W0, W1, W2, delta, shift);
					GaussianFilterMacro.gauss5x5AsmPass2(dest, row0, row1, row2, row3, row4, W0, W1, W2, delta, shift);
					GaussianFilterMacro.gauss5x5AsmPass2(dest, row0, row1, row2, row3, row4, W0, W1, W2, delta, shift);
					GaussianFilterMacro.gauss5x5AsmPass2(dest, row0, row1, row2, row3, row4, W0, W1, W2, delta, shift);
					GaussianFilterMacro.gauss5x5AsmPass2(dest, row0, row1, row2, row3, row4, W0, W1, W2, delta, shift);
					//
				__asm(
					Jump('loop2'),
					'endLoop2:'
					);
				
				// finish
				br = tail;
				__asm(
					'loop3:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop3')
					);
					//
					GaussianFilterMacro.gauss5x5AsmPass2(dest, row0, row1, row2, row3, row4, W0, W1, W2, delta, shift);
					//
				__asm(
					Jump('loop3'),
					'endLoop3:'
					);
			}
			
			// Second pass: borders...
			var dest0:int = dst;
			var dest1:int = dest0 + w;
			var dest2:int = dest1 + w;
			var destw1:int = dst + (h-1) * w;
			var destw2:int = destw1 - w;
			var destw3:int = destw2 - w;

			br = rem;
			__asm(
				'loop4:',
				DecLocalInt(br),
				GetLocal(br),
				PushByte(0),
				IfEqual('endLoop4')
				);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
			__asm(
				Jump('loop4'),
				'endLoop4:'
				);
				
			br = tail;
			__asm(
				'loop5:',
				DecLocalInt(br),
				GetLocal(br),
				PushByte(0),
				IfEqual('endLoop5')
				);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
			__asm(
				Jump('loop5'),
				'endLoop5:'
				);			
		}
		public static function gaussSmooth5x5Standard(src:int, dst:int, w:int, h:int, int_buffer:int):void
		{
			var y:int, tmp:int;
			var int_stride:int = w << 2;
			var rem:int =  __cint(((w-4) >> 3) + 1);
			var tail:int = __cint(((w-4) % 8) + 1);
			var br:int;
			
			/*var W0:int = 6;
			var W1:int = 4;
			var W2:int = 1;
			var shift:int = 8;*/
			
			var src_row:int, ints:int;
			var src_row2:int = __cint(src + 2);
  			var ints2:int = __cint(int_buffer + 8);
			
			// First pass: make use of intermediate_int_image
			for(y = 0; y < h; ++y) 
			{
				src_row = src_row2;
				ints = ints2;
				
				br = rem;
				__asm(
					'loop:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop')
					);
					// main loop
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);

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
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
				__asm(
					Jump('loop1'),
					'endLoop1:'
					);
				
				src_row2 = __cint(src_row2 + w);
				
				tmp = Memory.readInt(ints2);
				Memory.writeInt(tmp, __cint(ints2-4));
				Memory.writeInt(tmp, __cint(ints2-8));
				ints2 = __cint(ints2 + int_stride);
				tmp = Memory.readInt(__cint(ints2 - 20));
				Memory.writeInt(tmp, __cint(ints2 - 16));
				Memory.writeInt(tmp, __cint(ints2 - 12));
			}
				
			// Second pass:
			//var delta:int = 128;//1 << (shift - 1);
			rem = __cint((w >> 3) + 1);
			tail = __cint((w % 8) + 1);
			
			var row0:int = int_buffer;
			var row1:int = row0 + int_stride;
			var row2:int = row1 + int_stride;
			var row3:int = row2 + int_stride;
			var row4:int = row3 + int_stride;
			
			var dest:int = __cint(dst + (w << 1));
			var eh:int = __cint(h-2);
			
			for(y = 2; y < eh; ++y) 
			{				
				br = rem;
				__asm(
					'loop2:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop2')
					);
					//
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					//
				__asm(
					Jump('loop2'),
					'endLoop2:'
					);
				
				// finish
				br = tail;
				__asm(
					'loop3:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop3')
					);
					//
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					//
				__asm(
					Jump('loop3'),
					'endLoop3:'
					);
			}
			
			// Second pass: borders...
			var dest0:int = dst;
			var dest1:int = __cint(dest0 + w);
			var dest2:int = __cint(dest1 + w);
			var destw1:int = __cint(dst + (h-1) * w);
			var destw2:int = __cint(destw1 - w);
			var destw3:int = __cint(destw2 - w);

			br = rem;
			__asm(
				'loop4:',
				DecLocalInt(br),
				GetLocal(br),
				PushByte(0),
				IfEqual('endLoop4')
				);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
			__asm(
				Jump('loop4'),
				'endLoop4:'
				);
				
			br = tail;
			__asm(
				'loop5:',
				DecLocalInt(br),
				GetLocal(br),
				PushByte(0),
				IfEqual('endLoop5')
				);
				GaussianFilterMacro.gauss5x5AsmPass2Brd(dest0, dest1, dest2, destw1, destw2, destw3);
			__asm(
				Jump('loop5'),
				'endLoop5:'
				);			
		}
		
		public static function gaussSmooth5x5StandardLimited(src:int, dst:int, w:int, h:int, int_buffer:int):void
		{
			var y:int;
			var int_stride:int = w << 2;
			var align:int = 16;
			var w16:int = __cint((w-4) + align - 1) & ~int(align-1);
			w16 = __cint(w16 - int(w16 > w) * align);
			var rem:int =  __cint((w16 >> 4) + 1);
			var br:int;
			
			var src_row:int, ints:int;
			var src_row2:int = __cint(src + 2);
  			var ints2:int = __cint(int_buffer + 8);
			
			// First pass: make use of intermediate_int_image
			for(y = 0; y < h;) 
			{
				src_row = src_row2;
				ints = ints2;
				
				br = rem;
				__asm(
					'loop:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop')
					);
					// main loop
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					//
					
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					GaussianFilterMacro.gauss5x5AsmPass1Std( src_row, ints);
					
				__asm(
					Jump('loop'),
					'endLoop:'
				);
				src_row2 = __cint(src_row2 + w);
				ints2 = __cint(ints2 + int_stride);
				__asm(IncLocalInt(y));
			}
				
			// Second pass:
			w16 = __cint(w + align - 1) & ~int(align - 1);
			w16 = __cint(w16 - int(w16 > w) * align);
			rem = __cint((w16 >> 4) + 1);
			
			var row0:int = src_row2 = int_buffer;
			var row1:int = __cint(row0 + int_stride);
			var row2:int = __cint(row1 + int_stride);
			var row3:int = __cint(row2 + int_stride);
			var row4:int = __cint(row3 + int_stride);
			
			var dest:int = __cint(dst + (w << 1));
			var eh:int = __cint(h-2);
			
			for(y = 2; y < eh;) 
			{				
				br = rem;
				__asm(
					'loop2:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop2')
					);
					//
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					//
					
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					GaussianFilterMacro.gauss5x5AsmPass2Std(dest, row0, row1, row2, row3, row4);
					
					//
				__asm(
					Jump('loop2'),
					'endLoop2:'
					);
				src_row2 = row0 = __cint(src_row2 + int_stride);
				row1 = __cint(row0 + int_stride);
				row2 = __cint(row1 + int_stride);
				row3 = __cint(row2 + int_stride);
				row4 = __cint(row3 + int_stride);
				__asm(IncLocalInt(y));
			}
		}
		
		public static function gaussSmooth7x7(src:int, dst:int, w:int, h:int, int_buffer:int, W0:int, W1:int, W2:int, W3:int, shift:int):void
		{
			var y:int, tmp:int;
			var int_stride:int = w << 2;
			var rem:int =  ((w-6) >> 3) + 1;
			var tail:int = ((w-6) % 8) + 1;
			var br:int;
			
			var src_row:int, ints:int;
			var src_row2:int = src + 3;
  			var ints2:int = int_buffer + 12;
			
			// First pass: make use of intermediate_int_image
			for(y = 0; y < h; ++y) 
			{
				src_row = src_row2;
				ints = ints2;
				
				br = rem;
				__asm(
					'loop:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop')
					);
					// main loop
					GaussianFilterMacro.gauss7x7AsmPass1( src_row , ints, W0, W1, W2, W3);
					GaussianFilterMacro.gauss7x7AsmPass1( src_row , ints, W0, W1, W2, W3);
					GaussianFilterMacro.gauss7x7AsmPass1( src_row , ints, W0, W1, W2, W3);
					GaussianFilterMacro.gauss7x7AsmPass1( src_row , ints, W0, W1, W2, W3);
					GaussianFilterMacro.gauss7x7AsmPass1( src_row , ints, W0, W1, W2, W3);
					GaussianFilterMacro.gauss7x7AsmPass1( src_row , ints, W0, W1, W2, W3);
					GaussianFilterMacro.gauss7x7AsmPass1( src_row , ints, W0, W1, W2, W3);
					GaussianFilterMacro.gauss7x7AsmPass1( src_row , ints, W0, W1, W2, W3);

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
					GaussianFilterMacro.gauss7x7AsmPass1( src_row , ints, W0, W1, W2, W3);
				__asm(
					Jump('loop1'),
					'endLoop1:'
					);
				
				src_row2 += w;
				
				tmp = Memory.readInt(ints2);
				Memory.writeInt(tmp, ints2-12);
				Memory.writeInt(tmp, ints2-8);
				Memory.writeInt(tmp, ints2-4);
				ints2 += int_stride;
				tmp = Memory.readInt(ints2 - 28);
				Memory.writeInt(tmp, ints2 - 24);
				Memory.writeInt(tmp, ints2 - 20);
				Memory.writeInt(tmp, ints2 - 16);
			}
				
			// Second pass:
			var delta:int = 1 << (shift - 1);
			rem = (w >> 3) + 1;
			tail = (w % 8) + 1;
			
			var row0:int = int_buffer;
			var row1:int = row0 + int_stride;
			var row2:int = row1 + int_stride;
			var row3:int = row2 + int_stride;
			var row4:int = row3 + int_stride;
			var row5:int = row4 + int_stride;
			var row6:int = row5 + int_stride;
			
			var dest:int = dst + (w * 3);
			
			for(y = 3; y < h - 3; ++y) 
			{
				
				br = rem;
				__asm(
					'loop2:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop2')
					);
					//
					GaussianFilterMacro.gauss7x7AsmPass2(dest, row0, row1, row2, row3, row4, row5, row6, W0, W1, W2, W3, delta, shift);
					GaussianFilterMacro.gauss7x7AsmPass2(dest, row0, row1, row2, row3, row4, row5, row6, W0, W1, W2, W3, delta, shift);
					GaussianFilterMacro.gauss7x7AsmPass2(dest, row0, row1, row2, row3, row4, row5, row6, W0, W1, W2, W3, delta, shift);
					GaussianFilterMacro.gauss7x7AsmPass2(dest, row0, row1, row2, row3, row4, row5, row6, W0, W1, W2, W3, delta, shift);
					GaussianFilterMacro.gauss7x7AsmPass2(dest, row0, row1, row2, row3, row4, row5, row6, W0, W1, W2, W3, delta, shift);
					GaussianFilterMacro.gauss7x7AsmPass2(dest, row0, row1, row2, row3, row4, row5, row6, W0, W1, W2, W3, delta, shift);
					GaussianFilterMacro.gauss7x7AsmPass2(dest, row0, row1, row2, row3, row4, row5, row6, W0, W1, W2, W3, delta, shift);
					GaussianFilterMacro.gauss7x7AsmPass2(dest, row0, row1, row2, row3, row4, row5, row6, W0, W1, W2, W3, delta, shift);
					//
				__asm(
					Jump('loop2'),
					'endLoop2:'
					);
				
				// finish
				br = tail;
				__asm(
					'loop3:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop3')
					);
					//
					GaussianFilterMacro.gauss7x7AsmPass2(dest, row0, row1, row2, row3, row4, row5, row6, W0, W1, W2, W3, delta, shift);
					//
				__asm(
					Jump('loop3'),
					'endLoop3:'
					);
			}
			
			// Second pass: borders...
			var dest0:int = dst;
			var dest1:int = dest0 + w;
			var dest2:int = dest1 + w;
			var dest3:int = dest2 + w;
			var destw1:int = dst + (h-1) * w;
			var destw2:int = destw1 - w;
			var destw3:int = destw2 - w;
			var destw4:int = destw3 - w;

			br = rem;
			__asm(
				'loop4:',
				DecLocalInt(br),
				GetLocal(br),
				PushByte(0),
				IfEqual('endLoop4')
				);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
			__asm(
				Jump('loop4'),
				'endLoop4:'
				);
				
			br = tail;
			__asm(
				'loop5:',
				DecLocalInt(br),
				GetLocal(br),
				PushByte(0),
				IfEqual('endLoop5')
				);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
			__asm(
				Jump('loop5'),
				'endLoop5:'
				);			
		}
		
		public static function gaussSmooth7x7Standard(src:int, dst:int, w:int, h:int, int_buffer:int):void
		{
			var y:int, tmp:int;
			var int_stride:int = w << 2;
			var rem:int =  ((w-6) >> 3) + 1;
			var tail:int = ((w-6) % 8) + 1;
			var br:int;
			
			var src_row:int, ints:int;
			var src_row2:int = src + 3;
  			var ints2:int = int_buffer + 12;
			
			// First pass: make use of intermediate_int_image
			for(y = 0; y < h; ++y) 
			{
				src_row = src_row2;
				ints = ints2;
				
				br = rem;
				__asm(
					'loop:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop')
					);
					// main loop
					GaussianFilterMacro.gauss7x7AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss7x7AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss7x7AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss7x7AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss7x7AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss7x7AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss7x7AsmPass1Std( src_row , ints);
					GaussianFilterMacro.gauss7x7AsmPass1Std( src_row , ints);

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
					GaussianFilterMacro.gauss7x7AsmPass1Std( src_row , ints);
				__asm(
					Jump('loop1'),
					'endLoop1:'
					);
				
				src_row2 += w;
				
				tmp = Memory.readInt(ints2);
				Memory.writeInt(tmp, ints2-12);
				Memory.writeInt(tmp, ints2-8);
				Memory.writeInt(tmp, ints2-4);
				ints2 += int_stride;
				tmp = Memory.readInt(ints2 - 28);
				Memory.writeInt(tmp, ints2 - 24);
				Memory.writeInt(tmp, ints2 - 20);
				Memory.writeInt(tmp, ints2 - 16);
			}
				
			// Second pass:
			//var delta:int = 1 << 11;//2048
			rem = (w >> 3) + 1;
			tail = (w % 8) + 1;
			
			var row0:int = int_buffer;
			var row1:int = row0 + int_stride;
			var row2:int = row1 + int_stride;
			var row3:int = row2 + int_stride;
			var row4:int = row3 + int_stride;
			var row5:int = row4 + int_stride;
			var row6:int = row5 + int_stride;
			
			var dest:int = dst + (w * 3);
			
			for(y = 3; y < h - 3; ++y) 
			{
				br = rem;
				__asm(
					'loop2:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop2')
					);
					//
					GaussianFilterMacro.gauss7x7AsmPass2Std(dest, row0, row1, row2, row3, row4, row5, row6);
					GaussianFilterMacro.gauss7x7AsmPass2Std(dest, row0, row1, row2, row3, row4, row5, row6);
					GaussianFilterMacro.gauss7x7AsmPass2Std(dest, row0, row1, row2, row3, row4, row5, row6);
					GaussianFilterMacro.gauss7x7AsmPass2Std(dest, row0, row1, row2, row3, row4, row5, row6);
					GaussianFilterMacro.gauss7x7AsmPass2Std(dest, row0, row1, row2, row3, row4, row5, row6);
					GaussianFilterMacro.gauss7x7AsmPass2Std(dest, row0, row1, row2, row3, row4, row5, row6);
					GaussianFilterMacro.gauss7x7AsmPass2Std(dest, row0, row1, row2, row3, row4, row5, row6);
					GaussianFilterMacro.gauss7x7AsmPass2Std(dest, row0, row1, row2, row3, row4, row5, row6);
					//
				__asm(
					Jump('loop2'),
					'endLoop2:'
					);
				
				// finish
				br = tail;
				__asm(
					'loop3:',
					DecLocalInt(br),
					GetLocal(br),
					PushByte(0),
					IfEqual('endLoop3')
					);
					//
					GaussianFilterMacro.gauss7x7AsmPass2Std(dest, row0, row1, row2, row3, row4, row5, row6);
					//
				__asm(
					Jump('loop3'),
					'endLoop3:'
					);
			}
			
			// Second pass: borders...
			var dest0:int = dst;
			var dest1:int = dest0 + w;
			var dest2:int = dest1 + w;
			var dest3:int = dest2 + w;
			var destw1:int = dst + (h-1) * w;
			var destw2:int = destw1 - w;
			var destw3:int = destw2 - w;
			var destw4:int = destw3 - w;

			br = rem;
			__asm(
				'loop4:',
				DecLocalInt(br),
				GetLocal(br),
				PushByte(0),
				IfEqual('endLoop4')
				);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
			__asm(
				Jump('loop4'),
				'endLoop4:'
				);
				
			br = tail;
			__asm(
				'loop5:',
				DecLocalInt(br),
				GetLocal(br),
				PushByte(0),
				IfEqual('endLoop5')
				);
				GaussianFilterMacro.gauss7x7AsmPass2Brd(tmp, dest0, dest1, dest2, dest3, destw1, destw2, destw3, destw4);
			__asm(
				Jump('loop5'),
				'endLoop5:'
				);			
		}
		
		public static function gaussSmooth_dsigma_0_sigma_0_Scales_4(src:int, dst:int, w:int, h:int, int_buffer:int):void
		{
			var W0:int = 138;
			var W1:int = 59;
			var shift:int = 16;
			gaussSmooth3x3(src, dst, w, h, int_buffer, W0, W1, shift);
		}
		
		public static function gaussSmooth_dsigma_1_sigma_0_Scales_4(src:int, dst:int, w:int, h:int, int_buffer:int):void
		{
			var W0:int = 126;
			var W1:int = 65;
			var shift:int = 16;
			gaussSmooth3x3(src, dst, w, h, int_buffer, W0, W1, shift);
		}
		
		public static function gaussSmooth_dsigma_2_sigma_0_Scales_4(src:int, dst:int, w:int, h:int, int_buffer:int):void
		{
			var W0:int = 116;
			var W1:int = 70;
			var shift:int = 16;
			gaussSmooth3x3(src, dst, w, h, int_buffer, W0, W1, shift);
		}
		
		public static function gaussSmooth_dsigma_2_sigma_0_Scales_4_5x5(src:int, dst:int, w:int, h:int, int_buffer:int):void
		{
			var W0:int = 102;
			var W1:int = 63;
			var W2:int = 14;
			var shift:int = 16;
			gaussSmooth5x5(src, dst, w, h, int_buffer, W0, W1, W2, shift);
		}
	}
}
import apparat.asm.*;
import apparat.inline.Macro;

internal final class GaussianFilterMacro extends Macro
{
	internal static function gauss3x3AsmPass1_1(src_row:int, ints:int, a0:int, a1:int, _w:int, W0:int, W1:int):void
		{
			__asm(
					GetLocal(W0),
					GetLocal(a1),
					MultiplyInt,
					GetLocal(W1),
					GetLocal(a0), 
					MultiplyInt, 
					AddInt,
					SetLocal(_w),
					GetLocal(a1),
					SetLocal(a0),
					IncLocalInt(src_row),
					GetLocal(src_row),
					GetByte,
					SetLocal(a1),
					GetLocal(W1),
					GetLocal(a1),
					MultiplyInt,
					GetLocal(_w),
					AddInt,
					GetLocal(ints),
					SetInt,
					GetLocal(ints), // move ints ptr
					PushByte(4),
					AddInt,
					SetLocal(ints)
				);
		}
		
		internal static function gauss3x3AsmPass1(src_row:int, ints:int, W0:int, W1:int):void
		{
			/*
			Memory.writeInt(
									W0 * Memory.readUnsignedByte(src_row) + 
									W1 * (Memory.readUnsignedByte(src_row-1) + 
									Memory.readUnsignedByte(src_row+1)), 
									ints);
					ints += 4;
					++src_row;
			*/
			__asm(
					GetLocal(W0),
					GetLocal(src_row),
					GetByte,
					MultiplyInt,
					GetLocal(W1),
					GetLocal(src_row),
					DecrementInt,
					GetByte,
    				IncLocalInt(src_row), // move src ptr 
    				GetLocal(src_row),   
					GetByte,
					AddInt,                  
					MultiplyInt,         
					AddInt,
					GetLocal(ints), 
					SetInt,
					GetLocal(ints), // move ints ptr
					PushByte(4),
					AddInt,
					SetLocal(ints)
				);
		}
		internal static function gauss3x3AsmPass1Std(src_row:int, ints:int):void
		{
			__asm(
					GetLocal(src_row),
					GetByte, 
					PushByte(1), 
					ShiftLeft,
					GetLocal(src_row),
					DecrementInt,
					GetByte,
    				IncLocalInt(src_row), // move src ptr 
    				GetLocal(src_row),   
					GetByte,
					AddInt,         
					AddInt,
					GetLocal(ints), 
					SetInt,
					GetLocal(ints), // move ints ptr
					PushByte(4),
					AddInt,
					SetLocal(ints)
				);
		}
		
		internal static function gauss3x3AsmPass2(dest:int, row0:int, row1:int, row2:int, W0:int, W1:int, delta:int, shift:int):void
		{
			/*
			Memory.writeByte(
								(W0 * Memory.readInt(row1) + 
								W1 * (Memory.readInt(row0) + 
								Memory.readInt(row2)) + delta) >> shift, 
								dest);
			++dest;
			row0 += 4;
			row1 += 4;
			row2 += 4;
			*/
			__asm(
					GetLocal(W0),
					GetLocal(row1),
					GetInt,
					MultiplyInt,
					GetLocal(W1),
					GetLocal(row0),
					GetInt,
					GetLocal(row2),
					GetInt,         
    				AddInt,
					MultiplyInt,
					AddInt,                  
					GetLocal(delta),         
					AddInt,
					GetLocal(shift), 
					ShiftRight,
					GetLocal(dest),
					SetByte,
					GetLocal(row0), // move row0 ptr (can we move 3 ptrs in smarter way?)
					PushByte(4),
					AddInt,
					SetLocal(row0),
					GetLocal(row1), // move row1 ptr
					PushByte(4),
					AddInt,
					SetLocal(row1),
					GetLocal(row2), // move row2 ptr
					PushByte(4),
					AddInt,
					SetLocal(row2),
					IncLocalInt(dest) // move dest ptr
				);
		}
		internal static function gauss3x3AsmPass2Std(dest:int, row0:int, row1:int, row2:int):void
		{
			__asm(
					GetLocal(row1),
					GetInt,
					PushByte(1),
					ShiftLeft,
					GetLocal(row0),
					GetInt,
					AddInt,
					GetLocal(row2),
					GetInt,         
    				AddInt,
					PushByte(8),
					AddInt,
					PushByte(4), 
					ShiftRight,
					GetLocal(dest),
					SetByte,
					GetLocal(row0), // move row0 ptr (can we move 3 ptrs in smarter way?)
					PushByte(4),
					AddInt,
					SetLocal(row0),
					GetLocal(row1), // move row1 ptr
					PushByte(4),
					AddInt,
					SetLocal(row1),
					GetLocal(row2), // move row2 ptr
					PushByte(4),
					AddInt,
					SetLocal(row2),
					IncLocalInt(dest) // move dest ptr
				);
		}
		internal static function gauss3x3AsmPass2Brd(dest0:int, dest1:int, destw1:int, destw2:int):void
		{
			/*
			Memory.writeByte(Memory.readUnsignedByte(dest1++), dest0++);
			Memory.writeByte(Memory.readUnsignedByte(destw2++), destw1++);
			*/
				__asm(
					GetLocal(dest1),
					GetByte,
					GetLocal(dest0),
					SetByte,
					
					GetLocal(destw2),
					GetByte,
					GetLocal(destw1),
					SetByte,
					
					IncLocalInt(dest0),
					IncLocalInt(dest1),
					IncLocalInt(destw2),
					IncLocalInt(destw1)
				);
		}
		
		internal static function gauss5x5AsmPass1(src_row:int, ints:int, W0:int, W1:int, W2:int):void
		{
			/*
			Memory.writeInt(
							W0 * Memory.readUnsignedByte(src_row) + 
							W1 * (Memory.readUnsignedByte(src_row-1) + 
							Memory.readUnsignedByte(src_row+1)) + 
							W2 * (Memory.readUnsignedByte(src_row-2) + 
							Memory.readUnsignedByte(src_row+2)), 
							ints);
			++src_row;
			ints += 4;
			*/
			__asm(
					GetLocal(W0),
					GetLocal(src_row),
					GetByte,
					MultiplyInt,
					
					GetLocal(W1),
					GetLocal(src_row),
					DecrementInt,
					GetByte, 
					GetLocal(src_row), 
					IncrementInt,   
					GetByte,
					AddInt,
					MultiplyInt,
					AddInt,
					
					GetLocal(W2),
					GetLocal(src_row),
					PushByte(2),
					SubtractInt,
					GetByte,
					GetLocal(src_row),
					PushByte(2),
					AddInt,
					GetByte,
					AddInt,
					MultiplyInt,
					AddInt,
					
					GetLocal(ints), 
					SetInt,
					GetLocal(ints), // move ints ptr
					PushByte(4),
					AddInt,
					SetLocal(ints),
					IncLocalInt(src_row) // move src ptr
				);
		}
		internal static function gauss5x5AsmPass1Std(src_row:int, ints:int):void
		{
			/*
			var W0:int = 6;
			var W1:int = 4;
			var W2:int = 1;
			Memory.writeInt(
							W0 * Memory.readUnsignedByte(src_row) + 
							W1 * (Memory.readUnsignedByte(src_row-1) + 
							Memory.readUnsignedByte(src_row+1)) + 
							W2 * (Memory.readUnsignedByte(src_row-2) + 
							Memory.readUnsignedByte(src_row+2)), 
							ints);
			++src_row;
			ints += 4;
			*/
			__asm(
					PushByte(6),
					GetLocal(src_row),
					GetByte,
					MultiplyInt,
					
					//GetLocal(W1),
					GetLocal(src_row),
					DecrementInt,
					GetByte, 
					GetLocal(src_row), 
					IncrementInt,   
					GetByte,
					AddInt,
					PushByte(2),
					ShiftLeft,
					AddInt,
					
					//GetLocal(W2),
					GetLocal(src_row),
					PushByte(2),
					SubtractInt,
					GetByte,
					GetLocal(src_row),
					PushByte(2),
					AddInt,
					GetByte,
					AddInt,
					AddInt,
					
					GetLocal(ints), 
					SetInt,
					
					GetLocal(ints), // move ints ptr
					PushByte(4),
					AddInt,
					SetLocal(ints),
					IncLocalInt(src_row) // move src ptr
				);
		}
		
		internal static function gauss5x5AsmPass2(dest:int, row0:int, row1:int, row2:int, row3:int, row4:int, W0:int, W1:int, W2:int, delta:int, shift:int):void
		{
			/*
			Memory.writeByte(
								(W0 * Memory.readInt(row2) + 
								W1 * (Memory.readInt(row1) + 
								Memory.readInt(row3)) + 
								W2 * (Memory.readInt(row0) + 
								Memory.readInt(row4)) +
								delta) >> shift, 
								dest);
			++dest;
			row0 += 4;
			row1 += 4;
			row2 += 4;
			row3 += 4;
			row4 += 4;
			*/
			__asm(
					GetLocal(W0),
					GetLocal(row2),
					GetInt,
					MultiplyInt,
					
					GetLocal(W1),
					GetLocal(row1),
					GetInt,
					GetLocal(row3),
					GetInt,
    				AddInt,
					MultiplyInt,
					AddInt,
					
					GetLocal(W2),
					GetLocal(row0),
					GetInt,
					GetLocal(row4),
					GetInt,
    				AddInt,
					MultiplyInt,
					AddInt,
					                  
					GetLocal(delta),         
					AddInt,
					
					GetLocal(shift), 
					ShiftRight,
					
					GetLocal(dest),
					SetByte,
					
					GetLocal(row0), // move row0 ptr (can we move 3 ptrs in smarter way?)
					PushByte(4),
					AddInt,
					SetLocal(row0),
					GetLocal(row1), // move row1 ptr
					PushByte(4),
					AddInt,
					SetLocal(row1),
					GetLocal(row2), // move row2 ptr
					PushByte(4),
					AddInt,
					SetLocal(row2),
					GetLocal(row3), // move row3 ptr
					PushByte(4),
					AddInt,
					SetLocal(row3),
					GetLocal(row4), // move row4 ptr
					PushByte(4),
					AddInt,
					SetLocal(row4),
					IncLocalInt(dest) // move dest ptr
				);
		}
		internal static function gauss5x5AsmPass2Std(dest:int, row0:int, row1:int, row2:int, row3:int, row4:int):void
		{
			/*
			var W0:int = 6;
			var W1:int = 4;
			var W2:int = 1;
			var shift:int = 8;
			var delta:int = 128;
			Memory.writeByte(
								(W0 * Memory.readInt(row2) + 
								W1 * (Memory.readInt(row1) + 
								Memory.readInt(row3)) + 
								W2 * (Memory.readInt(row0) + 
								Memory.readInt(row4)) +
								delta) >> shift, 
								dest);
			++dest;
			row0 += 4;
			row1 += 4;
			row2 += 4;
			row3 += 4;
			row4 += 4;
			*/
			__asm(
					PushByte(6),
					GetLocal(row2),
					GetInt,
					MultiplyInt,
					
					//GetLocal(W1),
					GetLocal(row1),
					GetInt,
					GetLocal(row3),
					GetInt,
    				AddInt,
					PushByte(2),
					ShiftLeft,
					AddInt,
					
					//GetLocal(W2),
					GetLocal(row0),
					GetInt,
					GetLocal(row4),
					GetInt,
    				AddInt,
					//MultiplyInt,
					AddInt,
					                  
					PushInt(128),
					AddInt,
					
					PushByte(8),
					ShiftRight,
					
					GetLocal(dest),
					SetByte,
					
					GetLocal(row0), // move row0 ptr (can we move 3 ptrs in smarter way?)
					PushByte(4),
					AddInt,
					SetLocal(row0),
					GetLocal(row1), // move row1 ptr
					PushByte(4),
					AddInt,
					SetLocal(row1),
					GetLocal(row2), // move row2 ptr
					PushByte(4),
					AddInt,
					SetLocal(row2),
					GetLocal(row3), // move row3 ptr
					PushByte(4),
					AddInt,
					SetLocal(row3),
					GetLocal(row4), // move row4 ptr
					PushByte(4),
					AddInt,
					SetLocal(row4),
					IncLocalInt(dest) // move dest ptr
				);
		}
		internal static function gauss5x5AsmPass2Brd(dest0:int, dest1:int, dest2:int, destw1:int, destw2:int, destw3:int):void
		{
			/*
			tmp = Memory.readUnsignedByte(dest2++);
			Memory.writeByte(tmp, dest0++);
			Memory.writeByte(tmp, dest1++);
			tmp = Memory.readUnsignedByte(destw3++);
			Memory.writeByte(tmp, destw1++);
			Memory.writeByte(tmp, destw2++);
			*/
				__asm(
					GetLocal(dest2),
					GetByte,
					GetLocal(dest0),
					SetByte,
					GetLocal(dest2),
					GetByte,
					GetLocal(dest1),
					SetByte,
					
					GetLocal(destw3),
					GetByte,
					GetLocal(destw1),
					SetByte,
					GetLocal(destw3),
					GetByte,
					GetLocal(destw2),
					SetByte,
					
					IncLocalInt(dest0),
					IncLocalInt(dest1),
					IncLocalInt(dest2),
					IncLocalInt(destw3),
					IncLocalInt(destw2),
					IncLocalInt(destw1)
				);
		}
		
		internal static function gauss7x7AsmPass1(src_row:int, ints:int, W0:int, W1:int, W2:int, W3:int):void
		{
			/*
			Memory.writeInt(
						W0 * Memory.readUnsignedByte(src_row) + 
						W1 * (Memory.readUnsignedByte(src_row-1) + 
						Memory.readUnsignedByte(src_row+1)) + 
						W2 * (Memory.readUnsignedByte(src_row-2) + 
						Memory.readUnsignedByte(src_row+2)) +
						W3 * (Memory.readUnsignedByte(src_row-3) + 
						Memory.readUnsignedByte(src_row+3)), 
						ints);
			++src_row;
			ints += 4;
			*/
			__asm(
					GetLocal(W0),
					GetLocal(src_row),
					GetByte,
					MultiplyInt,
					
					GetLocal(W1),
					GetLocal(src_row),
					DecrementInt,
					GetByte, 
					GetLocal(src_row), 
					IncrementInt,   
					GetByte,
					AddInt,
					MultiplyInt,
					AddInt,
					
					GetLocal(W2),
					GetLocal(src_row),
					PushByte(2),
					SubtractInt,
					GetByte,
					GetLocal(src_row),
					PushByte(2),
					AddInt,
					GetByte,
					AddInt,
					MultiplyInt,
					AddInt,
					
					GetLocal(W3),
					GetLocal(src_row),
					PushByte(3),
					SubtractInt,
					GetByte,
					GetLocal(src_row),
					PushByte(3),
					AddInt,
					GetByte,
					AddInt,
					MultiplyInt,
					AddInt,
					
					GetLocal(ints), 
					SetInt,
					GetLocal(ints), // move ints ptr
					PushByte(4),
					AddInt,
					SetLocal(ints),
					IncLocalInt(src_row) // move src ptr
				);
		}
		internal static function gauss7x7AsmPass1Std(src_row:int, ints:int):void
		{
			/*
			Memory.writeInt(
							((9 * Memory.readUnsignedByte(src_row) +	
							7 * (Memory.readUnsignedByte(src_row-1) + 
							Memory.readUnsignedByte(src_row+1)) + 
							Memory.readUnsignedByte(src_row-3) + 
							Memory.readUnsignedByte(src_row+3))<<1) +
							7 * (Memory.readUnsignedByte(src_row-2) + 
							Memory.readUnsignedByte(src_row+2)), 
							ints);
			++src_row;
			ints += 4;
			*/
			__asm(
					PushByte(9),
					GetLocal(src_row),
					GetByte,
					MultiplyInt,
					
					PushByte(7),
					GetLocal(src_row),
					DecrementInt,
					GetByte, 
					GetLocal(src_row), 
					IncrementInt,   
					GetByte,
					AddInt,
					MultiplyInt,
					AddInt,
					
					GetLocal(src_row),
					PushByte(3),
					SubtractInt,
					GetByte,
					GetLocal(src_row),
					PushByte(3),
					AddInt,
					GetByte,
					AddInt,
					AddInt,
					
					PushByte(1),
					ShiftLeft,
					
					PushByte(7),
					GetLocal(src_row),
					PushByte(2),
					SubtractInt,
					GetByte,
					GetLocal(src_row),
					PushByte(2),
					AddInt,
					GetByte,
					AddInt,
					MultiplyInt,
					AddInt,
					
					GetLocal(ints), 
					SetInt,
					GetLocal(ints), // move ints ptr
					PushByte(4),
					AddInt,
					SetLocal(ints),
					IncLocalInt(src_row) // move src ptr
				);
		}
		internal static function gauss7x7AsmPass2(dest:int, row0:int, row1:int, row2:int, row3:int, row4:int, row5:int, row6:int, W0:int, W1:int, W2:int, W3:int, delta:int, shift:int):void
		{
			/*
			Memory.writeByte(
							(W0 * Memory.readInt(row3) + 
							W1 * (Memory.readInt(row2) + 
							Memory.readInt(row4)) + 
							W2 * (Memory.readInt(row1) + 
							Memory.readInt(row5)) +
							W3 * (Memory.readInt(row0) + 
							Memory.readInt(row6)) +
							delta) >> shift, 
							dest);
			++dest;
			row0 += 4;
			row1 += 4;
			row2 += 4;
			row3 += 4;
			row4 += 4;
			row5 += 4;
			row6 += 4;
			*/
			__asm(
					GetLocal(W0),
					GetLocal(row3),
					GetInt,
					MultiplyInt,
					
					GetLocal(W1),
					GetLocal(row2),
					GetInt,
					GetLocal(row4),
					GetInt,
    				AddInt,
					MultiplyInt,
					AddInt,
					
					GetLocal(W2),
					GetLocal(row1),
					GetInt,
					GetLocal(row5),
					GetInt,
    				AddInt,
					MultiplyInt,
					AddInt,
					
					GetLocal(W3),
					GetLocal(row0),
					GetInt,
					GetLocal(row6),
					GetInt,
    				AddInt,
					MultiplyInt,
					AddInt,
					                  
					GetLocal(delta),         
					AddInt,
					
					GetLocal(shift), 
					ShiftRight,
					
					GetLocal(dest),
					SetByte,
					
					GetLocal(row0), // move row0 ptr (can we move 3 ptrs in smarter way?)
					PushByte(4),
					AddInt,
					SetLocal(row0),
					GetLocal(row1), // move row1 ptr
					PushByte(4),
					AddInt,
					SetLocal(row1),
					GetLocal(row2), // move row2 ptr
					PushByte(4),
					AddInt,
					SetLocal(row2),
					GetLocal(row3), // move row3 ptr
					PushByte(4),
					AddInt,
					SetLocal(row3),
					GetLocal(row4), // move row4 ptr
					PushByte(4),
					AddInt,
					SetLocal(row4),
					GetLocal(row5), // move row5 ptr
					PushByte(4),
					AddInt,
					SetLocal(row5),
					GetLocal(row6), // move row6 ptr
					PushByte(4),
					AddInt,
					SetLocal(row6),
					IncLocalInt(dest) // move dest ptr
				);
		}
		internal static function gauss7x7AsmPass2Std(dest:int, row0:int, row1:int, row2:int, row3:int, row4:int, row5:int, row6:int):void
		{
			/*
			Memory.writeByte(
							(((9 * Memory.readInt(row3 + x) +
							7 * (Memory.readInt(row2 + x) + Memory.readInt(row4 + x)) +
							Memory.readInt(row0 + x) + Memory.readInt(row6 + x))<<1) +
							7 * (Memory.readInt(row1 + x) + Memory.readInt(row5 + x)) + delta) >> 12, 
								dest);
			++dest;
			row0 += 4;
			row1 += 4;
			row2 += 4;
			row3 += 4;
			row4 += 4;
			row5 += 4;
			row6 += 4;
			*/
			__asm(
					PushByte(9),
					GetLocal(row3),
					GetInt,
					MultiplyInt,
					
					PushByte(7),
					GetLocal(row2),
					GetInt,
					GetLocal(row4),
					GetInt,
    				AddInt,
					MultiplyInt,
					AddInt,
					
					GetLocal(row0),
					GetInt,
					GetLocal(row6),
					GetInt,
    				AddInt,
					AddInt,
					
					PushByte(1),
					ShiftLeft,
					
					PushByte(7),
					GetLocal(row1),
					GetInt,
					GetLocal(row5),
					GetInt,
    				AddInt,
					MultiplyInt,
					AddInt,
					                  
					PushInt(2048),         
					AddInt,
					
					PushByte(12), 
					ShiftRight,
					
					GetLocal(dest),
					SetByte,
					
					GetLocal(row0), // move row0 ptr (can we move 3 ptrs in smarter way?)
					PushByte(4),
					AddInt,
					SetLocal(row0),
					GetLocal(row1), // move row1 ptr
					PushByte(4),
					AddInt,
					SetLocal(row1),
					GetLocal(row2), // move row2 ptr
					PushByte(4),
					AddInt,
					SetLocal(row2),
					GetLocal(row3), // move row3 ptr
					PushByte(4),
					AddInt,
					SetLocal(row3),
					GetLocal(row4), // move row4 ptr
					PushByte(4),
					AddInt,
					SetLocal(row4),
					GetLocal(row5), // move row5 ptr
					PushByte(4),
					AddInt,
					SetLocal(row5),
					GetLocal(row6), // move row6 ptr
					PushByte(4),
					AddInt,
					SetLocal(row6),
					IncLocalInt(dest) // move dest ptr
				);
		}
		internal static function gauss7x7AsmPass2Brd(tmp:int, dest0:int, dest1:int, dest2:int, dest3:int, destw1:int, destw2:int, destw3:int, destw4:int):void
		{
			/*
			tmp = Memory.readUnsignedByte(dest3++);
			Memory.writeByte(tmp, dest0++);
			Memory.writeByte(tmp, dest1++);
			Memory.writeByte(tmp, dest2++);
			tmp = Memory.readUnsignedByte(destw4++);
			Memory.writeByte(tmp, destw1++);
			Memory.writeByte(tmp, destw2++);
			Memory.writeByte(tmp, destw3++);
			*/
				__asm(
					GetLocal(dest3),
					GetByte,
					SetLocal(tmp),
					
					GetLocal(tmp),
					GetLocal(dest0),
					SetByte,
					GetLocal(tmp),
					GetLocal(dest1),
					SetByte,
					GetLocal(tmp),
					GetLocal(dest2),
					SetByte,
					
					GetLocal(destw4),
					GetByte,
					SetLocal(tmp),
					
					GetLocal(tmp),
					GetLocal(destw1),
					SetByte,
					GetLocal(tmp),
					GetLocal(destw2),
					SetByte,
					GetLocal(tmp),
					GetLocal(destw3),
					SetByte,
					
					IncLocalInt(dest0),
					IncLocalInt(dest1),
					IncLocalInt(dest2),
					IncLocalInt(dest3),
					IncLocalInt(destw4),
					IncLocalInt(destw3),
					IncLocalInt(destw2),
					IncLocalInt(destw1)
				);
		}
}