package com.tastenkunst.as3.brf.container3d {
	import com.tastenkunst.as3.brf.IBRFContainer3D;
	import com.tastenkunst.as3.poseestimation.ResultMatrix;

	import flash.display.Sprite;
	import flash.geom.Rectangle;

	/**
	 * @author Marcel Klammer, 2011
	 */
	public class BRFContainer3D implements IBRFContainer3D {
		
		protected var _container : Sprite;
		
		protected const _resetMatrix : ResultMatrix = new ResultMatrix();
		protected const _rawData : Vector.<Number> = new Vector.<Number>(16, true);

		public function BRFContainer3D(container : Sprite) {
			_container = container;
			_resetMatrix.setResetValues(Vector.<Number>([
				1.0,  0.0,    0.0,   0.0,
				0.0, -0.735, -0.677, 0.0,
				0.0,  0.677, -0.735, 675.0
			]));
			_resetMatrix.reset();
		}
		
		public function init(rect : Rectangle) : void {
		}
		
		public function updatePose(m : ResultMatrix) : void {
		}

		public function isValidPose() : Boolean {
			return true;
		}

		public function resetPose() : void {
			updatePose(_resetMatrix);
		}
	}
}
