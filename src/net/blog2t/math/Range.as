/*---------------------------------------------------------------------------------------------

	[AS3] Range
	=======================================================================================

	VERSION HISTORY:
	v0.1	Born on 2008-04-23
	v0.2	23/12/2008	Modulo method added
	v0.3	26/01/2009	distance method added
	v0.4	25/10/2009	getBetween added

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package net.blog2t.math
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Range
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
	
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		/**
		 *	Function: Trimmer
		 *	 	
		 *	Trims the value to [min, max]
		 *	f(x) = {
		 *	  min: when x < min;
		 *	  max: when x > max;
		 *	  value: when x > min and x < max;
		 *	}
		 *	
		 */
		public static function limit(value:Number, min:Number = 0, max:Number = 1):Number
		{
			return Math.min(Math.max(min, value), max);
		}

		/**
		 *	Function: Trimmer (integer)
		 *	 	
		 *	Trims the value to int[min, max]
		 *	f(x) = int{
		 *	  min: when x < min;
		 *	  max: when x > max;
		 *	  value: when x > min and x < max;
		 *	}
		 *	
		 */
		public static function limitInt(value:Number, min:Number, max:Number):Number
		{
			return int(Math.min(Math.max(min, value), max));
		}


		public static function isBetween(value:Number, min:Number, max:Number):Boolean
		{
			return (value >= min && value <= max);
		}


		/**
		 *	Function: Signum
		 *		
		 *	f(x, [t = 0]) = {
		 *	  1: when x > t;
		 *	 -1: when x < t;
		 *	  0: when x = t;
		 *	}
		 */
	
		public static function signum(value:Number, threshold:Number = 0):Number
		{
			if (value > threshold) return 1;
			else if (value < threshold) return -1;
			else return 0;
		}
		
		
		/**
		 *	These by Keith Peters aka Bit-101
		 *	http://www.bit-101.com/blog/?p=1242
		 *	
		 *	value = Range.map(handle.y, height - handle.height, 0, minimum, maximum); 
		 */
		public static function normalize(value:Number, minimum:Number, maximum:Number):Number
		{
		    return (value - minimum) / (maximum - minimum);
		}
		
		
		public static function interpolate(value:Number, minimum:Number, maximum:Number):Number
		{
		
		    return minimum + (maximum - minimum) * value;
		}
		
		
		public static function map(value:Number, min1:Number, max1:Number, min2:Number = 0, max2:Number = 1):Number
		{
		    return interpolate(normalize(value, min1, max1), min2, max2);
		}
		
		
		public static function findPreferredRatio(width:Number, height:Number, maxWidth:Number, maxHeight:Number):Number
		{
			var dw:Number = maxWidth / width;
			var dh:Number = maxHeight / height;
			return (dw < dh) ? dw : dh;
		}
		
		/**
		 *	I needed modulo result to be positive for all real numbers:
		 *	
		 *	-6 % 160 = -6        crap :(
		 *	mod(-6, 160) = 154   excellent! :)
		 */
		public static function modulo(a:Number, n:Number):Number
		{
			return a - n * Math.floor(a / n);
		}
		
		
		public static function distance(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
		}
		
		
		public static function deltaDistance(deltaX:Number, deltaY:Number):Number
		{
			return Math.sqrt(deltaX * deltaX + deltaY * deltaY);
		}
		
		
		/**
		* Randomises a number between min and max
		* @param	min		min number
		* @param	min		max number
		* @return	number	random number between min and max
		*/
		public static function getBetween(min:Number, max:Number, integer:Boolean = false):Number
		{
			var number:Number = min + Math.random() * (max - min);
			return integer ? Math.floor(number) : number;
		}
	}
	// END OF CLASS ///////////////////////////////////////////////////////////////////////////
}


