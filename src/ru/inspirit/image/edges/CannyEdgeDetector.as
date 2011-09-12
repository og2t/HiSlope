package ru.inspirit.image.edges
{
	import apparat.asm.AddInt;
	import apparat.asm.GetLocal;
	import apparat.asm.IncLocalInt;
	import apparat.asm.PushByte;
	import apparat.asm.SetLocal;
	import apparat.asm.__asm;
	import apparat.asm.__cint;
	import apparat.math.IntMath;
	import apparat.memory.Memory;
	import apparat.memory.memset;
	
	/**
	 * released under MIT License (X11)
	 * http://www.opensource.org/licenses/mit-license.php
	 * 
	 * This class provides a configurable implementation of the Canny edge
	 * detection algorithm. This classic algorithm has a number of shortcomings,
	 * but remains an effective tool in many scenarios.
	 * 
	 * @author Eugene Zatepyakin
	 * @see http://blog.inspirit.ru
	 * 
	 * @author Patrick Le Clec'h
	 * lots of speed up tips and tricks ;-) 
	 */
	public class CannyEdgeDetector
	{	
		protected var width:int;
		protected var height:int;
		protected var area:int;
		protected var _lowThreshold:Number;
		protected var _highThreshold:Number;
		
		public var gradXPtr:int;
		public var gradYPtr:int;
		public var magPtr:int;
		protected var histPtr:int;
		
		public function calcRequiredChunkSize(width:int, height:int):int
		{
			var size:int = (130050 << 2); // histogram space
			size += (width * height) << 2;
			size += (width * height) << 2;
			size += (width * height) << 2;
			
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
			histPtr = magPtr + (area << 2);
		}
		
		/**
		 * @param imgPtr	mem offset to image data (uchar)
		 * @param edgPtr	mem offset to edges data (int)
		 */
		public function detect(imgPtr:int, edgPtr:int, width:int, height:int):void
		{
			var w:int = width;
			var h:int = height;
			var a:int, b:int, c:int, outxp:int, outyp:int;
			var i:int, d:int, dx:int, dy:int;
			var stride4:int = w << 2;
			var magp:int;
			var maxMag:int = 0;
			var magn:int;
			var temp:int;
			var thresh_low:Number = this.lowThreshold;
			var thresh_high:Number = this.highThreshold;
			
			var img_xendp:int, img_endp:int;

			img_endp = __cint(imgPtr + w*(h-1));
			var row:int = imgPtr;
			outxp = gradXPtr;
			outyp = gradYPtr;
			magp = magPtr;
			
			for (; row < img_endp; ) 
			{
		        a = Memory.readUnsignedByte(row);
		        c = Memory.readUnsignedByte(__cint(row+w));
		        
		        __asm(__cint(row + w - 1), SetLocal(img_xendp));
		        for (; row < img_xendp; ) 
		        {
		            __asm(IncLocalInt(row));
		
		            b = Memory.readUnsignedByte(row);
		            d = Memory.readUnsignedByte(__cint(row+w));
		
		            a = __cint(d - a);
		            c = __cint(b - c);
		            dx = __cint(a + c);
		            dy = __cint(a - c);
		
		            a = b;
		            c = d;
		            
		            magn = __cint(dx*dx + dy*dy);
		            
		            temp = int(magn>maxMag);
					maxMag = __cint(magn*temp+(1-temp)*maxMag);
		            
		            Memory.writeInt(dx, outxp);
		            Memory.writeInt(dy, outyp);

					Memory.writeInt(magn, magp);
					__asm(GetLocal(magp),PushByte(4),AddInt,SetLocal(magp));
					__asm(GetLocal(outxp),PushByte(4),AddInt,SetLocal(outxp));
					__asm(GetLocal(outyp),PushByte(4),AddInt,SetLocal(outyp));
		        }		
		        __asm(IncLocalInt(row));
		        __asm(GetLocal(magp),PushByte(4),AddInt,SetLocal(magp));
				__asm(GetLocal(outxp),PushByte(4),AddInt,SetLocal(outxp));
				__asm(GetLocal(outyp),PushByte(4),AddInt,SetLocal(outyp));
		    }
			
			maxMag++;
			row = histPtr;
			magp = magPtr;
			var area:int = __cint(w * h);
			var numedges:int, highcount:int, maximum_mag:int, highthreshold:int, lowthreshold:int;
			
			memset( row, 0, maxMag << 2 );
			for (i = 0; i < area; ++i)
			{
				a = __cint(row + (Memory.readInt(magp) << 2));
				b = Memory.readInt(a);
				__asm(IncLocalInt(b));
				Memory.writeInt(b, a);
				magp = __cint(magp + 4);
			}
			
			row = __cint(histPtr + 4);
			maximum_mag = 0;
			for(i = 1, numedges = 0; i < maxMag; ++i)
			{
				a = Memory.readInt(row);
				temp = int(a!=0);
				maximum_mag = __cint(i*temp+(1-temp)*maximum_mag);
				numedges = __cint(numedges + a);
				row = __cint(row + 4);
			}
			
			highcount = numedges * thresh_high + 0.5;
			i = 1;
			numedges = Memory.readInt(histPtr + 4);
			row = __cint(histPtr + 8);
			b = __cint(maximum_mag-1);
			while( i < b && numedges < highcount )
			{
				__asm(IncLocalInt(i));
				a = Memory.readInt(row);
				numedges = __cint(numedges + a);
				row = __cint(row + 4);
			}
			
			highthreshold = i;
			lowthreshold = (highthreshold * thresh_low + 0.5);
			// 
		
			row = __cint( edgPtr + stride4 + 4 );
			outxp = __cint(gradXPtr + stride4 + 4);
			outyp = __cint(gradYPtr + stride4 + 4);
			magp = __cint(magPtr + stride4 + 4);
			maxMag = __cint( magPtr + ((w*(h - 1) + 1) << 2) );
			
			//var NO_EDGE_PIXEL:int = 0;
			//var DUMMY_PIXEL:int = 1;
			var EDGE_PIXEL:int = 0xFF;
			
			var reg:int;
			var o1:int, o2:int;
			var i1:int,i2:int,sx:int,sy:int,s:int, m1:int,m2:int,denom:int;
			var stride4p1:int = __cint( stride4 + 4);
			var stride4m1:int = __cint( stride4 - 4);
			//var stktop:Vector.<int> = new Vector.<int>();
			var stackPtr:int = histPtr;
			//var len:int=0;
			
			memset( edgPtr, 0, stride4 );
			
			for (; magp < maxMag; )
			{
				Memory.writeInt( 0, row );
				row = __cint(row + 4);
				//
				var magn_max_x:int = __cint(magp + ((w - 2)<<2));
				for (; magp < magn_max_x;) 
				{
					magn = Memory.readInt(magp);
					if(magn < lowthreshold)
					{
						Memory.writeInt( 0, row );
					}
					else
					{
						// do NonMaxSuppress
						dx = Memory.readInt(outxp);
						dy = Memory.readInt(outyp);
						
						sx = __cint(1 - (int(dx<0) << 1)); //dx < 0?-1:1;
						sy = __cint(1 - (int(dy<0) << 1)); //dy < 0?-1:1;
						dx = __cint(dx * sx);
						dy = __cint(dy * sy);
						s = __cint(sx * sy);
						reg = magn;
						if (dy == 0)
						{
							m1 = Memory.readInt(magp + 4);
							m2 = Memory.readInt(magp - 4);
						} else if (dx == 0)
						{
							m1 = Memory.readInt(magp + stride4);
							m2 = Memory.readInt(magp - stride4);
						} 
						else 
						{
							var dy_lte_dx:int=int(dy <= dx);
							var dy_lte_dx_1:int=__cint(1-dy_lte_dx);
							var s_gtz:int=int(s>0);
							var s_gtz_1:int=__cint(1-s_gtz);
							
							o1 = __cint(s_gtz*( (dy_lte_dx<<2) + dy_lte_dx_1*stride4p1) + s_gtz_1*(dy_lte_dx*stride4m1+dy_lte_dx_1*stride4));
							o2 = __cint(s_gtz*( dy_lte_dx*stride4p1 + dy_lte_dx_1*stride4) + s_gtz_1*(dy_lte_dx_1*stride4m1-(dy_lte_dx<<2)));
							i1 = __cint(s_gtz*(dy_lte_dx*dy + dy_lte_dx_1*(dy - dx)) + s_gtz_1*(dy_lte_dx*(dx - dy)+dy_lte_dx_1*dx));
							
							denom = __cint(dy_lte_dx*dx+dy_lte_dx_1*dy);
							i2 = __cint(denom-i1);
							
							//
									
							m1 = __cint(Memory.readInt(magp + o1)*i2 + Memory.readInt(magp + o2)*i1);
							m2 = __cint(Memory.readInt(magp - o1)*i2 + Memory.readInt(magp - o2)*i1);
							reg = __cint(magn * denom);
							
						}
					
						// result check
						var chk:int=int(int(reg>=m1) & int(reg>=m2) & int(m1!=m2));
						var m_ge_h:int=__cint(chk*int(magn >= highthreshold));
						Memory.writeInt( __cint(chk * (m_ge_h*0xff+(1-m_ge_h))), row );
						//stktop[len]=row;
						//len=__cint(len+m_ge_h);
						Memory.writeInt(row, stackPtr);
						stackPtr = __cint(stackPtr + (m_ge_h<<2));
					}
					//
					magp = __cint(magp + 4);
					outxp = __cint(outxp + 4);
					outyp = __cint(outyp + 4);
					row = __cint(row + 4);
				}
				Memory.writeInt( 0, row );
				row = __cint(row + 4);
				
				magp = __cint(magp + 8);
				outxp = __cint(outxp + 8);
				outyp = __cint(outyp + 8);
			}
			
			// fill last row with zero
			for(i=0; i < w; ++i)
			{
				Memory.writeInt( 0, row );
				row = __cint(row + 4);
			}
			
			// simple path following
			//while (len>0)
			i = histPtr;
			while (stackPtr > i) 
			{
				 //len=__cint(len-1);
				 //row = stktop[len];
				 stackPtr = __cint(stackPtr - 4);
				 row = Memory.readInt(stackPtr);
		
				row = __cint( row - stride4p1 );
				if(Memory.readInt(row) == 1)
				{
					Memory.writeInt( EDGE_PIXEL, row );
					//stktop[len]=row;
					//len=__cint(len+1);
					Memory.writeInt(row, stackPtr);
					stackPtr = __cint(stackPtr + 4);
				}
				row = __cint( row + 4 );
				if(Memory.readInt(row) == 1)
				{
					Memory.writeInt( EDGE_PIXEL, row );
					//stktop[len]=row;
					//len=__cint(len+1);
					Memory.writeInt(row, stackPtr);
					stackPtr = __cint(stackPtr + 4);
				}
				row = __cint( row + 4 );
				if(Memory.readInt(row) == 1)
				{
					Memory.writeInt( EDGE_PIXEL, row );
					//stktop[len]=row;
					//len=__cint(len+1);
					Memory.writeInt(row, stackPtr);
					stackPtr = __cint(stackPtr + 4);
				}
				row = __cint( row + stride4 );
				if(Memory.readInt(row) == 1)
				{
					Memory.writeInt( EDGE_PIXEL, row );
					//stktop[len]=row;
					//len=__cint(len+1);
					Memory.writeInt(row, stackPtr);
					stackPtr = __cint(stackPtr + 4);
				}
				row = __cint( row - 8 );
				if(Memory.readInt(row) == 1)
				{
					Memory.writeInt( EDGE_PIXEL, row );
					//stktop[len]=row;
					//len=__cint(len+1);
					Memory.writeInt(row, stackPtr);
					stackPtr = __cint(stackPtr + 4);
				}
				row = __cint( row + stride4 );
				if(Memory.readInt(row) == 1)
				{
					Memory.writeInt( EDGE_PIXEL, row );
					//stktop[len]=row;
					//len=__cint(len+1);
					Memory.writeInt(row, stackPtr);
					stackPtr = __cint(stackPtr + 4);
				}
				row = __cint( row + 4 );
				if(Memory.readInt(row) == 1)
				{
					Memory.writeInt( EDGE_PIXEL, row );
					//stktop[len]=row;
					//len=__cint(len+1);
					Memory.writeInt(row, stackPtr);
					stackPtr = __cint(stackPtr + 4);
				}
				row = __cint( row + 4 );
				if(Memory.readInt(row) == 1)
				{
					Memory.writeInt( EDGE_PIXEL, row );
					//stktop[len]=row;
					//len=__cint(len+1);
					Memory.writeInt(row, stackPtr);
					stackPtr = __cint(stackPtr + 4);
				}
			}
		}
		
		public function set lowThreshold(value:Number):void
		{
			_lowThreshold = value;
			if(_lowThreshold > _highThreshold){
				value = _lowThreshold;
				_lowThreshold = _highThreshold;
				_highThreshold = value;
			}
		}
		public function get lowThreshold():Number
		{
			return _lowThreshold;
		}

		public function set highThreshold(value:Number):void
		{
			_highThreshold = value;
			if(_lowThreshold > _highThreshold){
				value = _lowThreshold;
				_lowThreshold = _highThreshold;
				_highThreshold = value;
			}
		}
		public function get highThreshold():Number
		{
			return _highThreshold;
		}
	}
}
