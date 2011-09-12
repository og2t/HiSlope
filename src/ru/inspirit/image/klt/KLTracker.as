package ru.inspirit.image.klt
{
	import apparat.asm.*;
	import apparat.math.FastMath;
	import apparat.math.IntMath;
	import apparat.memory.Memory;

	/**
	 * @author Eugene Zatepyakin
	 */
	public final class KLTracker
	{
		public var currImg:Vector.<int>;		
		public var prevImg:Vector.<int>;
		
		public var initW:int = 640;
		public var initH:int = 480;

        protected var patchSize:int;
        
		protected var patchIPtr:int;
		protected var patchJPtr:int;
		protected var IxPtr:int;
		protected var IyPtr:int;
		protected var convPtr:int;
        
        public function calcRequiredChunkSize(patchSize:int = 8):int
		{	
			var pS:int = __cint(patchSize * 2 + 1);
		    var patchLen:int = __cint(pS * pS);
		    var srcPatchLen:int = __cint((pS + 2) * (pS + 2));
			var bufferBytes:int = __cint((srcPatchLen + patchLen * 3) << 3);
						
			var size:int = __cint((768 << 2) + bufferBytes);
			
			return IntMath.nextPow2(size);
		}
		
		public function setup(memOffset:int, imageWidth:int, imageHeight:int, patchSize:int = 8):void
		{
			this.initW = imageWidth;
			this.initH = imageHeight;
			this.patchSize = patchSize;

			convPtr = memOffset;
			patchIPtr = convPtr + (768 << 2);
			
			var pS:int = __cint(patchSize * 2 + 1);
		    var patchLen:int = __cint(pS * pS);
		    var srcPatchLen:int = __cint((pS + 2)*(pS + 2));
						
			patchJPtr = __cint(patchIPtr + (srcPatchLen << 3));
			IxPtr = __cint(patchJPtr + (patchLen << 3));
			IyPtr = __cint(IxPtr + (patchLen << 3));

			for(var i:int = 0; i < 768; ++i)
			{
				Memory.writeInt(CONV_TAB[i], __cint(convPtr + (i<<2)));
			}
		}
		
		public function trackPoints(count:int, inputPoints:Vector.<Number>, resultPoints:Vector.<Number>,
									status:Vector.<int>, maxIter:int = 10, epsilon:Number = 1e-3):void
		{
			var winSizeW:int = patchSize;
			var winSizeH:int = patchSize;
			var patchSizeW:int = __cint((winSizeW << 1) + 1);
			var patchSizeH:int = __cint((winSizeH << 1) + 1);
			var i:int, l:int, j:int, x:int, y:int, ptr1:int, ptr2:int, ptr3:int, ptr4:int, pstp1:int, pstp2:int;
			var t0:Number, t:Number, v0:Number, v1:Number;
			var pi_ptr:int, pj_ptr:int, ix_ptr:int, iy_ptr:int;
			var vx:Number, vy:Number;
		    var minIx:int, minIy:int, maxIx:int, maxIy:int, ix:int, iy:int;
		    var minJx:int, minJy:int, maxJx:int, maxJy:int;
		    var iszW:int, iszH:int, jszW:int, jszH:int;
		    var pt_status:int;
		    var ux:Number, uy:Number;
		    var prev_minJx:int, prev_minJy:int, prev_maxJx:int, prev_maxJy:int;
		    var Gxx:Number, Gxy:Number, Gyy:Number, D:Number;
		    var prev_mx:Number, prev_my:Number;
		    var imageAPtr:int, imageBPtr:int;
		    var ii:int;
		    var min_determinant:Number = 2.2204460492503131E-16;
			
			if( count == 0 ) return;
			
			epsilon *= epsilon;
			var levels:int = currImg.length;
			var level:int = __cint(levels - 1);
			
			for(i = 0; i < count; ++i) 
			{
				status[i] = 1;
				resultPoints[i<<1] = inputPoints[i<<1];
				resultPoints[__cint((i<<1)+1)] = inputPoints[__cint((i<<1)+1)];
			}
			
			var smooth0:Number = 0.09375;
			var smooth1:Number = 0.3125;
			
			for( l = level; l >= 0; --l )
			{
				var levelSizeW:int = initW >> l;
				var levelSizeH:int = initH >> l;
				var levelStep:int = levelSizeW;
				var levelScale:Number = 1.0 / (1 << l);
				imageAPtr = prevImg[l];
				imageBPtr = currImg[l];
				
				// find flow for each given point
				for( i = 0; i < count; ++i )
				{
					ii = i << 1;
					
					prev_minJx = -1;
					prev_minJy = -1;
					prev_maxJx = -1;
					prev_maxJy = -1;
				    prev_mx = 0, prev_my = 0;
				    
				    vx = resultPoints[ii];
					vy = resultPoints[__cint(ii + 1)];
					
					if( l < level )
					{
					    vx += vx;
					    vy += vy;
					}
					else
					{
					    vx = vx * levelScale;
					    vy = vy * levelScale;
					}
					
					pt_status = status[i];
					if( !pt_status ) continue;
		
		            ux = inputPoints[ii] * levelScale;
		            uy = inputPoints[__cint(ii + 1)] * levelScale;
		            
		            // intersect
				
				    ix = ux;
				    iy = uy;
				
				    ix = __cint(ix - winSizeW);
				    iy = __cint(iy - winSizeH);
				
				    minIx = IntMath.max( 0, -ix );
				    minIy = IntMath.max( 0, -iy );
					maxIx = IntMath.min( patchSizeW, __cint(levelSizeW - ix) );
					maxIy = IntMath.min( patchSizeH, __cint(levelSizeH - iy) );
		            //
		            
		            iszW = jszW = __cint(maxIx - minIx + 2);
					iszH = jszH = __cint(maxIy - minIy + 2);
		            ux += __cint(minIx - (patchSizeW - maxIx + 1)) * 0.5;
		            uy += __cint(minIy - (patchSizeH - maxIy + 1)) * 0.5;
		            
		            if( iszW < 3 || iszH < 3 )
		            {
		                // point is outside the image. take the next
		                status[i] = 0;
		                continue;
		            }
		            
					ptr1 = imageAPtr;
					ptr2 = convPtr;
					ptr3 = patchIPtr;
					
		            KLTMacro.getRectSubPix( ptr1, levelStep, ptr3, iszW, iszH, ux, uy, ptr2 );		            
		            
		            ptr1 = patchIPtr;
		            ptr2 = IxPtr;
		            ptr3 = IyPtr;
		            ptr4 = patchJPtr;
		            pstp1 = iszW << 3;
		            
		            KLTMacro.calcIxIy( ptr1, pstp1, ptr2, ptr3, iszW, iszH, smooth0, smooth1, ptr4 );

					for ( j = 0; j < maxIter; ++j )
		            {
		                var bx:Number = 0, by:Number = 0;
		                var mx:Number, my:Number;
		                var _vx:Number, _vy:Number;
		
		                // intersect
						ix = vx;
					    iy = vy;
					
					    ix = __cint(ix - winSizeW);
					    iy = __cint(iy - winSizeH);
					
					    minJx = IntMath.max( 0, -ix );
					    minJy = IntMath.max( 0, -iy );
						maxJx = IntMath.min( patchSizeW, __cint(levelSizeW - ix ));
						maxJy = IntMath.min( patchSizeH, __cint(levelSizeH - iy ));
		                //
		                
		                minJx = IntMath.max( minJx, minIx );
		                minJy = IntMath.max( minJy, minIy );
		
		                maxJx = IntMath.min( maxJx, maxIx );
		                maxJy = IntMath.min( maxJy, maxIy );
		
		                jszW = __cint(maxJx - minJx);
						jszH = __cint(maxJy - minJy);
		
		                _vx = vx + __cint(minJx - (patchSizeW - maxJx + 1)) * 0.5;
		                _vy = vy + __cint(minJy - (patchSizeH - maxJy + 1)) * 0.5;
		                
		                if( jszW < 1 || jszH < 1 )
		                {
		                    // point is outside image. take the next
		                    pt_status = 0;
		                    break;
		                }
		                
		                ptr1 = imageBPtr;
						ptr2 = convPtr;
						ptr3 = patchJPtr;
		                KLTMacro.getRectSubPix( ptr1, levelStep, ptr3, jszW, jszH, _vx, _vy, ptr2 );
		                
		                var chk:int = __cint(
		                				int(maxJx == prev_maxJx)
		                				&int(maxJy == prev_maxJy)
		                				&int(minJx == prev_minJx)
		                				&int(minJy == prev_minJy) );
		                
		                if( chk == 1 )
		                {
		                	ptr1 = __cint(patchIPtr + (((minJy - minIy + 1) * iszW + minJx - minIx + 1) << 3));
	                        ptr2 = patchJPtr;
	                        ptr3 = __cint(IxPtr + (((minJy - minIy)*(iszW-2) + minJx - minIx) << 3));
							ptr4 = __cint(IyPtr + (ptr3 - IxPtr));
							pstp1 = iszW << 3;
							ix = jszW << 3;
							pstp2 = __cint((iszW-2) << 3);
		                    for( y = 0; y < jszH; ++y )
		                    {
		                        pi_ptr = ptr1;
		                        pj_ptr = ptr2;
		                        ix_ptr = ptr3;
		                        iy_ptr = ptr4;
		
		                        for( x = 0; x < jszW; ++x )
		                        {
		                            t0 = Memory.readDouble(pi_ptr) - Memory.readDouble(pj_ptr);
		                            bx += t0 * Memory.readDouble(ix_ptr);
		                            by += t0 * Memory.readDouble(iy_ptr);
		                            __asm(
		                            	GetLocal(pi_ptr),PushByte(8),AddInt,SetLocal(pi_ptr),
										GetLocal(pj_ptr),PushByte(8),AddInt,SetLocal(pj_ptr),
										GetLocal(ix_ptr),PushByte(8),AddInt,SetLocal(ix_ptr),
										GetLocal(iy_ptr),PushByte(8),AddInt,SetLocal(iy_ptr)
		                            	);
		                        }
		                         __asm(
	                            	GetLocal(ptr1),GetLocal(pstp1),AddInt,SetLocal(ptr1),
									GetLocal(ptr2),GetLocal(ix),AddInt,SetLocal(ptr2),
									GetLocal(ptr3),GetLocal(pstp2),AddInt,SetLocal(ptr3),
									GetLocal(ptr4),GetLocal(pstp2),AddInt,SetLocal(ptr4)
	                            	);
		                    }
		                }
		                else
		                {
		                    Gxx = Gyy = Gxy = 0;
		                    ptr1 = __cint(patchIPtr + (((minJy - minIy + 1) * iszW + minJx - minIx + 1) << 3));
	                        ptr2 = patchJPtr;
	                        ptr3 = __cint(IxPtr + (((minJy - minIy)*(iszW-2) + minJx - minIx) << 3));
							ptr4 = __cint(IyPtr + (ptr3 - IxPtr));
							pstp1 = iszW << 3;
							ix = jszW << 3;
							pstp2 = __cint((iszW-2) << 3);
		                    for( y = 0; y < jszH; ++y )
		                    {		                        
		                        pi_ptr = ptr1;
		                        pj_ptr = ptr2;
		                        ix_ptr = ptr3;
		                        iy_ptr = ptr4;
		
		                        for( x = 0; x < jszW; ++x )
		                        {
		                            t = Memory.readDouble(pi_ptr) - Memory.readDouble(pj_ptr);
		                            v0 = Memory.readDouble(ix_ptr);
		                            v1 = Memory.readDouble(iy_ptr);
		                            bx += t * v0;
		                            by += t * v1;
		                            Gxx += v0 * v0;
		                            Gxy += v0 * v1;
		                            Gyy += v1 * v1;
		                            __asm(
		                            	GetLocal(pi_ptr),PushByte(8),AddInt,SetLocal(pi_ptr),
										GetLocal(pj_ptr),PushByte(8),AddInt,SetLocal(pj_ptr),
										GetLocal(ix_ptr),PushByte(8),AddInt,SetLocal(ix_ptr),
										GetLocal(iy_ptr),PushByte(8),AddInt,SetLocal(iy_ptr)
		                            	);
		                        }
		                         __asm(
	                            	GetLocal(ptr1),GetLocal(pstp1),AddInt,SetLocal(ptr1),
									GetLocal(ptr2),GetLocal(ix),AddInt,SetLocal(ptr2),
									GetLocal(ptr3),GetLocal(pstp2),AddInt,SetLocal(ptr3),
									GetLocal(ptr4),GetLocal(pstp2),AddInt,SetLocal(ptr4)
	                            	);
		                    }
		
		                    D = Gxx * Gyy - Gxy * Gxy;
		                    if( D < min_determinant )
		                    {
		                        pt_status = 0;
		                        break;
		                    }
		
		                    D = 1.0 / D;
		
		                    prev_minJx = minJx;
							prev_minJy = minJy;
		                    prev_maxJx = maxJx;
							prev_maxJy = maxJy;
		                }
		                
		                mx = (Gyy * bx - Gxy * by) * D;
		                my = (Gxx * by - Gxy * bx) * D;
		
		                vx += mx;
		                vy += my;
		
		                if( mx * mx + my * my < epsilon ) break;
		                
		                if( j > 0 && FastMath.abs(mx + prev_mx) < 0.01 && FastMath.abs(my + prev_my) < 0.01 )
		                {
		                    vx -= mx * 0.5;
		                    vy -= my * 0.5;
		                    break;
		                }
		                prev_mx = mx;
		                prev_my = my;
		            }
		            
		            resultPoints[ii] = vx;
					resultPoints[__cint(ii + 1)] = vy;
            		status[i] = pt_status;
            		
				}
			}
		}
		
		protected static var CONV_TAB:Vector.<int> = Vector.<int>( // 768
		[
		    -256.0, -255.0, -254.0, -253.0, -252.0, -251.0, -250.0, -249.0,
		    -248.0, -247.0, -246.0, -245.0, -244.0, -243.0, -242.0, -241.0,
		    -240.0, -239.0, -238.0, -237.0, -236.0, -235.0, -234.0, -233.0,
		    -232.0, -231.0, -230.0, -229.0, -228.0, -227.0, -226.0, -225.0,
		    -224.0, -223.0, -222.0, -221.0, -220.0, -219.0, -218.0, -217.0,
		    -216.0, -215.0, -214.0, -213.0, -212.0, -211.0, -210.0, -209.0,
		    -208.0, -207.0, -206.0, -205.0, -204.0, -203.0, -202.0, -201.0,
		    -200.0, -199.0, -198.0, -197.0, -196.0, -195.0, -194.0, -193.0,
		    -192.0, -191.0, -190.0, -189.0, -188.0, -187.0, -186.0, -185.0,
		    -184.0, -183.0, -182.0, -181.0, -180.0, -179.0, -178.0, -177.0,
		    -176.0, -175.0, -174.0, -173.0, -172.0, -171.0, -170.0, -169.0,
		    -168.0, -167.0, -166.0, -165.0, -164.0, -163.0, -162.0, -161.0,
		    -160.0, -159.0, -158.0, -157.0, -156.0, -155.0, -154.0, -153.0,
		    -152.0, -151.0, -150.0, -149.0, -148.0, -147.0, -146.0, -145.0,
		    -144.0, -143.0, -142.0, -141.0, -140.0, -139.0, -138.0, -137.0,
		    -136.0, -135.0, -134.0, -133.0, -132.0, -131.0, -130.0, -129.0,
		    -128.0, -127.0, -126.0, -125.0, -124.0, -123.0, -122.0, -121.0,
		    -120.0, -119.0, -118.0, -117.0, -116.0, -115.0, -114.0, -113.0,
		    -112.0, -111.0, -110.0, -109.0, -108.0, -107.0, -106.0, -105.0,
		    -104.0, -103.0, -102.0, -101.0, -100.0,  -99.0,  -98.0,  -97.0,
		     -96.0,  -95.0,  -94.0,  -93.0,  -92.0,  -91.0,  -90.0,  -89.0,
		     -88.0,  -87.0,  -86.0,  -85.0,  -84.0,  -83.0,  -82.0,  -81.0,
		     -80.0,  -79.0,  -78.0,  -77.0,  -76.0,  -75.0,  -74.0,  -73.0,
		     -72.0,  -71.0,  -70.0,  -69.0,  -68.0,  -67.0,  -66.0,  -65.0,
		     -64.0,  -63.0,  -62.0,  -61.0,  -60.0,  -59.0,  -58.0,  -57.0,
		     -56.0,  -55.0,  -54.0,  -53.0,  -52.0,  -51.0,  -50.0,  -49.0,
		     -48.0,  -47.0,  -46.0,  -45.0,  -44.0,  -43.0,  -42.0,  -41.0,
		     -40.0,  -39.0,  -38.0,  -37.0,  -36.0,  -35.0,  -34.0,  -33.0,
		     -32.0,  -31.0,  -30.0,  -29.0,  -28.0,  -27.0,  -26.0,  -25.0,
		     -24.0,  -23.0,  -22.0,  -21.0,  -20.0,  -19.0,  -18.0,  -17.0,
		     -16.0,  -15.0,  -14.0,  -13.0,  -12.0,  -11.0,  -10.0,   -9.0,
		      -8.0,   -7.0,   -6.0,   -5.0,   -4.0,   -3.0,   -2.0,   -1.0,
		       0.0,    1.0,    2.0,    3.0,    4.0,    5.0,    6.0,    7.0,
		       8.0,    9.0,   10.0,   11.0,   12.0,   13.0,   14.0,   15.0,
		      16.0,   17.0,   18.0,   19.0,   20.0,   21.0,   22.0,   23.0,
		      24.0,   25.0,   26.0,   27.0,   28.0,   29.0,   30.0,   31.0,
		      32.0,   33.0,   34.0,   35.0,   36.0,   37.0,   38.0,   39.0,
		      40.0,   41.0,   42.0,   43.0,   44.0,   45.0,   46.0,   47.0,
		      48.0,   49.0,   50.0,   51.0,   52.0,   53.0,   54.0,   55.0,
		      56.0,   57.0,   58.0,   59.0,   60.0,   61.0,   62.0,   63.0,
		      64.0,   65.0,   66.0,   67.0,   68.0,   69.0,   70.0,   71.0,
		      72.0,   73.0,   74.0,   75.0,   76.0,   77.0,   78.0,   79.0,
		      80.0,   81.0,   82.0,   83.0,   84.0,   85.0,   86.0,   87.0,
		      88.0,   89.0,   90.0,   91.0,   92.0,   93.0,   94.0,   95.0,
		      96.0,   97.0,   98.0,   99.0,  100.0,  101.0,  102.0,  103.0,
		     104.0,  105.0,  106.0,  107.0,  108.0,  109.0,  110.0,  111.0,
		     112.0,  113.0,  114.0,  115.0,  116.0,  117.0,  118.0,  119.0,
		     120.0,  121.0,  122.0,  123.0,  124.0,  125.0,  126.0,  127.0,
		     128.0,  129.0,  130.0,  131.0,  132.0,  133.0,  134.0,  135.0,
		     136.0,  137.0,  138.0,  139.0,  140.0,  141.0,  142.0,  143.0,
		     144.0,  145.0,  146.0,  147.0,  148.0,  149.0,  150.0,  151.0,
		     152.0,  153.0,  154.0,  155.0,  156.0,  157.0,  158.0,  159.0,
		     160.0,  161.0,  162.0,  163.0,  164.0,  165.0,  166.0,  167.0,
		     168.0,  169.0,  170.0,  171.0,  172.0,  173.0,  174.0,  175.0,
		     176.0,  177.0,  178.0,  179.0,  180.0,  181.0,  182.0,  183.0,
		     184.0,  185.0,  186.0,  187.0,  188.0,  189.0,  190.0,  191.0,
		     192.0,  193.0,  194.0,  195.0,  196.0,  197.0,  198.0,  199.0,
		     200.0,  201.0,  202.0,  203.0,  204.0,  205.0,  206.0,  207.0,
		     208.0,  209.0,  210.0,  211.0,  212.0,  213.0,  214.0,  215.0,
		     216.0,  217.0,  218.0,  219.0,  220.0,  221.0,  222.0,  223.0,
		     224.0,  225.0,  226.0,  227.0,  228.0,  229.0,  230.0,  231.0,
		     232.0,  233.0,  234.0,  235.0,  236.0,  237.0,  238.0,  239.0,
		     240.0,  241.0,  242.0,  243.0,  244.0,  245.0,  246.0,  247.0,
		     248.0,  249.0,  250.0,  251.0,  252.0,  253.0,  254.0,  255.0,
		     256.0,  257.0,  258.0,  259.0,  260.0,  261.0,  262.0,  263.0,
		     264.0,  265.0,  266.0,  267.0,  268.0,  269.0,  270.0,  271.0,
		     272.0,  273.0,  274.0,  275.0,  276.0,  277.0,  278.0,  279.0,
		     280.0,  281.0,  282.0,  283.0,  284.0,  285.0,  286.0,  287.0,
		     288.0,  289.0,  290.0,  291.0,  292.0,  293.0,  294.0,  295.0,
		     296.0,  297.0,  298.0,  299.0,  300.0,  301.0,  302.0,  303.0,
		     304.0,  305.0,  306.0,  307.0,  308.0,  309.0,  310.0,  311.0,
		     312.0,  313.0,  314.0,  315.0,  316.0,  317.0,  318.0,  319.0,
		     320.0,  321.0,  322.0,  323.0,  324.0,  325.0,  326.0,  327.0,
		     328.0,  329.0,  330.0,  331.0,  332.0,  333.0,  334.0,  335.0,
		     336.0,  337.0,  338.0,  339.0,  340.0,  341.0,  342.0,  343.0,
		     344.0,  345.0,  346.0,  347.0,  348.0,  349.0,  350.0,  351.0,
		     352.0,  353.0,  354.0,  355.0,  356.0,  357.0,  358.0,  359.0,
		     360.0,  361.0,  362.0,  363.0,  364.0,  365.0,  366.0,  367.0,
		     368.0,  369.0,  370.0,  371.0,  372.0,  373.0,  374.0,  375.0,
		     376.0,  377.0,  378.0,  379.0,  380.0,  381.0,  382.0,  383.0,
		     384.0,  385.0,  386.0,  387.0,  388.0,  389.0,  390.0,  391.0,
		     392.0,  393.0,  394.0,  395.0,  396.0,  397.0,  398.0,  399.0,
		     400.0,  401.0,  402.0,  403.0,  404.0,  405.0,  406.0,  407.0,
		     408.0,  409.0,  410.0,  411.0,  412.0,  413.0,  414.0,  415.0,
		     416.0,  417.0,  418.0,  419.0,  420.0,  421.0,  422.0,  423.0,
		     424.0,  425.0,  426.0,  427.0,  428.0,  429.0,  430.0,  431.0,
		     432.0,  433.0,  434.0,  435.0,  436.0,  437.0,  438.0,  439.0,
		     440.0,  441.0,  442.0,  443.0,  444.0,  445.0,  446.0,  447.0,
		     448.0,  449.0,  450.0,  451.0,  452.0,  453.0,  454.0,  455.0,
		     456.0,  457.0,  458.0,  459.0,  460.0,  461.0,  462.0,  463.0,
		     464.0,  465.0,  466.0,  467.0,  468.0,  469.0,  470.0,  471.0,
		     472.0,  473.0,  474.0,  475.0,  476.0,  477.0,  478.0,  479.0,
		     480.0,  481.0,  482.0,  483.0,  484.0,  485.0,  486.0,  487.0,
		     488.0,  489.0,  490.0,  491.0,  492.0,  493.0,  494.0,  495.0,
		     496.0,  497.0,  498.0,  499.0,  500.0,  501.0,  502.0,  503.0,
		     504.0,  505.0,  506.0,  507.0,  508.0,  509.0,  510.0,  511.0
			]);
	}
}