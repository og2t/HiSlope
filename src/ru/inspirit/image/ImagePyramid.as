package ru.inspirit.image
{
	import flash.filters.BlurFilter;
	import apparat.math.IntMath;

	import ru.inspirit.image.filter.GaussianFilter;
	import ru.inspirit.image.mem.MemImageInt;
	import ru.inspirit.image.mem.MemImageUChar;

	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	/**
	 * @author Eugene Zatepyakin
	 */
	public final class ImagePyramid
	{		
		public const ORIGIN:Point = new Point();
		public const SCALE_DOWN:Matrix = new Matrix(0.5, 0, 0, 0.5);
		public static const GAUSSIAN_3x3:ConvolutionFilter = new ConvolutionFilter(
																				3,3,
																				[ 	1,2,1,
																					2,4,2,
																					1,2,1	], 
																				16);
		public static const GAUSSIAN_5x5:ConvolutionFilter = new ConvolutionFilter(
																					5, 5,
																					[	2, 4, 5,4,2,
																						4, 9,12,9,4,
																						5,12,15,12,5,
																						4, 9,12,9,4,
																						2, 4, 5,4,2	],
																						159);
		public static const GRAYSCALE_MATRIX:ColorMatrixFilter = new ColorMatrixFilter([
                        																0, 0, 0, 0, 0,
            																			0, 0, 0, 0, 0,
            																			.2989, .587, .114, 0, 0,
            																			0, 0, 0, 0, 0
																						]);
		public static const BLUR_FILTER:BlurFilter = new BlurFilter(2, 2, 2);
		
		public var pyrLevels:int;
		public var images:Vector.<BitmapData>;
		public var mem:Vector.<MemImageUChar>;
		public var rects:Vector.<Rectangle>;
		
		public var origWidth:int;
		public var origHeight:int;
		public var srcImage:BitmapData;
		
		public var memoryChunkSize:int = 0;
		
		public const intImage:MemImageInt = new MemImageInt();
		public var ram:ByteArray;
		
		public function ImagePyramid(levels:int = 3)
		{
			pyrLevels = levels;
			images = new Vector.<BitmapData>( levels, true );
			mem = new Vector.<MemImageUChar>( levels, true );
			rects = new Vector.<Rectangle>( levels, true );
		}
		
		public function calcRequiredChunkSize(width:int, height:int, levels:int = 3):int
		{
			var size:int = (width * height) << 2;
			
			for(var i:int = 0; i < levels; ++i)
			{
				size += ((width >> i) * (height >> i));
			}
			return IntMath.nextPow2(size);
		}
		
		public function setup(width:int, height:int, memPtr:int = -1):void
		{
			origWidth = width;
			origHeight = height;
			var offset:int = (width * height) << 2;
			intImage.setup( memPtr, width, height );
			
			for(var i:int = 0; i < pyrLevels; ++i)
			{
				if(images[i]) images[i].dispose();
				
				var bmp:BitmapData = new BitmapData(width >> i, height >> i, false, 0x00);
				bmp.lock();
				images[i] = bmp;
				rects[i] = bmp.rect;
				
				if(memPtr > -1)
				{
					mem[i] = new MemImageUChar();
					mem[i].setup( memPtr + offset, bmp.width, bmp.height );
					offset += (bmp.width * bmp.height);
				}
			}

			memoryChunkSize = calcRequiredChunkSize( width, height );
		}
		
		public function updateBitmaps(desaturate:Boolean = false, smoothFilter:int = 0, levelsToUpdate:int = 0):void
		{
			var bmp:BitmapData = images[0];
			var l:int = levelsToUpdate || pyrLevels;
			var i:int, j:int;

			if(desaturate)
			{
				bmp.applyFilter(srcImage, rects[0], ORIGIN, GRAYSCALE_MATRIX);
			} 
			else 
			{
				bmp.copyPixels( srcImage, rects[0], ORIGIN );
			}
			
			for(i = 1, j = 0; i < l; ++i, ++j)
			{				
				images[i].draw( images[j], SCALE_DOWN, null, null, rects[j], true );
			}
			
			if(smoothFilter == 3)
			{
				for(i = 0; i < l; ++i)
				{
					bmp = images[i];
					bmp.applyFilter( bmp, rects[i], ORIGIN, GAUSSIAN_3x3 );
				}
			}
		}
		
		public function updateMem(desaturate:Boolean = false, smoothFilter:int = 0, levelsToUpdate:int = 0):void
		{
			var bmp:BitmapData = images[0];
			var mi:MemImageUChar;
			var ptr0:int;
			var iptr:int = intImage.ptr;
			var w:int;
			var h:int;
			var l:int = levelsToUpdate || pyrLevels;
			var i:int, j:int;
			
			if(desaturate)
			{
				bmp.applyFilter(srcImage, rects[0], ORIGIN, GRAYSCALE_MATRIX);
			} 
			else 
			{
				bmp.copyPixels( srcImage, rects[0], ORIGIN );
			}
			
			for(i = 1, j = 0; i < l; ++i, ++j)
			{				
				images[i].draw( images[j], SCALE_DOWN, null, null, rects[j], true );
			}
			
			if(smoothFilter == 0)
			{
				/*
				mem[0].fill(images[0].getVector( rects[0] ));
				for(i = 1, j = 0; i < l; ++i, ++j)
				{
					mi = mem[i];
					ptr0 = mi.ptr;
					ptr1 = mem[j].ptr;
					w = mi.width;
					h = mi.height;

					ImageMacro.pyrDown( ptr1, ptr0, w, h );
				}
				*/
				for(i = 0; i < l; ++i)
				{
					bmp = images[i];
					mi = mem[i];
					
					mi.fill(bmp.getVector( rects[i] ));
				}
			}
			else if(smoothFilter == 3)
			{
				for(i = 0; i < l; ++i)
				{
					bmp = images[i];
					mi = mem[i];
					w = mi.width;
					h = mi.height;
					ptr0 = mi.ptr;
					
					mi.fillAndSmooth3x3(bmp.getVector( rects[i] ), w, h, iptr);
				}
			}
			else if(smoothFilter == 5)
			{
				for(i = 0; i < l; ++i)
				{
					bmp = images[i];
					mi = mem[i];
					w = mi.width;
					h = mi.height;
					ptr0 = mi.ptr;
					
					mi.fillAndSmooth5x5(bmp.getVector( rects[i] ), w, h, iptr);
				}
			}
			else if(smoothFilter == 7)
			{
				for(i = 0; i < l; ++i)
				{
					bmp = images[i];
					mi = mem[i];
					w = mi.width;
					h = mi.height;
					ptr0 = mi.ptr;
					
					mi.fillAndSmooth7x7(bmp.getVector( rects[i] ), w, h, iptr);
				}
			}
		}
		
		public function smoothPyramid(smoothFilter:int = 1, levelsToUpdate:int = 0):void
		{
			var bmp:BitmapData;
			var mi:MemImageUChar;
			var ptr0:int ;
			var w:int;
			var h:int;
			var l:int = levelsToUpdate || pyrLevels;
			var i:int;
			var iptr:int = intImage.ptr;
			
			if(smoothFilter == 3)
			{
				for(i = 0; i < l; ++i)
				{
					mi = mem[i];
					w = mi.width;
					h = mi.height;
					ptr0 = mi.ptr;
					
					GaussianFilter.gaussSmooth3x3Standard(ptr0, ptr0, w, h, iptr);
				}
			}
			else if(smoothFilter == 5)
			{
				for(i = 0; i < l; ++i)
				{
					mi = mem[i];
					w = mi.width;
					h = mi.height;
					ptr0 = mi.ptr;
					
					GaussianFilter.gaussSmooth5x5Standard( ptr0, ptr0, w, h, iptr);
				}
			}
			else if(smoothFilter == 7)
			{
				for(i = 0; i < l; ++i)
				{
					mi = mem[i];
					w = mi.width;
					h = mi.height;
					ptr0 = mi.ptr;
					
					GaussianFilter.gaussSmooth7x7Standard( ptr0, ptr0, w, h, iptr);
				}
			}
			else if(smoothFilter > 7)
			{
				for(i = 0; i < l; ++i)
				{
					bmp = images[i];
					mi = mem[i];
					ptr0 = mi.ptr;
					BLUR_FILTER.blurX = BLUR_FILTER.blurY = smoothFilter;

					bmp.applyFilter( bmp, rects[i], ORIGIN, BLUR_FILTER );
					mi.fill(bmp.getVector( rects[i] ));
				}
			}
		}
		
		public function swap(pyr:ImagePyramid):void
		{
			var ptr0:int;
			
			for(var i:int = 0; i < pyrLevels; ++i)
			{
				ptr0 = mem[i].ptr;
				mem[i].ptr = pyr.mem[i].ptr;
				pyr.mem[i].ptr = ptr0;
			}
		}
		
		public function dispose():void
		{
			for(var i:int = 0; i < pyrLevels; ++i)
			{				
				images[i].dispose();
			}
		}
	}
}