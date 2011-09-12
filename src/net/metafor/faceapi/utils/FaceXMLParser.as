/*---------------------------------------------------------------------------------------------

	[AS3] FaceXMLParser
	=======================================================================================

	Copyright (c) 2011 blog2t.net
	All Rights Reserved

	VERSION HISTORY:
	v0.1	Born on 2011-09-02

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package net.metafor.faceapi.utils
{
	import hislope.vo.faceapi.FaceFeatures;
	import hislope.vo.faceapi.FaceAttributes;
	import hislope.vo.faceapi.ValueConfidence;
	import hislope.vo.faceapi.FaceUID;
	import flash.geom.Point;
	import net.blog2t.math.Range;
	import flash.display.Graphics;

	public class FaceXMLParser
	{
		public static const POINT_FEATURES:Array = [
			"center",
			"ear_left",
			"ear_right",
			"eye_left",
			"eye_right",
			"mouth_center",
			"mouth_left",
			"mouth_midleft",
			"mouth_right",
			"mouth_midright",
			"nose"
		];
		
		
		public static const NUMBER_FEATURES:Array = [
			"width",
			"height",
			"pitch",
			"roll",
			"yaw",
			"threshold",
			"tagger_id",
			"gid",
			"tid"
		];
		
		
		public static const FACE_ATTRIBUTES:Array = [
			"face",
			"gender",
			"glasses",
			"smiling"
		];
		
		
		/*private static var testXML:XML = <response>
				  <photos list="true">
				    <photo>
				      <url>http://face.com/getImage.php?type=ph&amp;key=2d0e1394180422bd0600643efa163a36</url>
				      <pid>F@d52e3d25b96eca5a8c9a09a15a3afdaf_eb974fa99cd199734c54c638d7d92bce</pid>
				      <width>640</width>
				      <height>480</height>
				      <tags list="true">
				        <tag>
				          <tid>TEMP_F@d52e3d25b96eca5a8c9a09a15a3afdaf_eb974fa99cd199734c54c638d7d92bce_53.05_67.60_1_0</tid>
				          <recognizable>1</recognizable>
				          <threshold>64</threshold>
				          <uids list="true">
				            <recognition>
				              <uid>TOMEK@showtell</uid>
				              <confidence>28</confidence>
				            </recognition>
				            <recognition>
				              <uid>TOMMY@showtell</uid>
				              <confidence>6</confidence>
				            </recognition>
				          </uids>
				          <gid/>
				          <label/>
				          <confirmed>0</confirmed>
				          <manual>0</manual>
				          <tagger_id/>
				          <width>32.97</width>
				          <height>43.96</height>
				          <center>
				            <x>53.05</x>
				            <y>67.6</y>
				          </center>
				          <eye_left>
				            <x>46.18</x>
				            <y>57.93</y>
				          </eye_left>
				          <eye_right>
				            <x>60.41</x>
				            <y>56.32</y>
				          </eye_right>
				          <mouth_left>
				            <x>48.98</x>
				            <y>78.83</y>
				          </mouth_left>
				          <mouth_center>
				            <x>54.87</x>
				            <y>79.52</y>
				          </mouth_center>
				          <mouth_right>
				            <x>59.83</x>
				            <y>77.12</y>
				          </mouth_right>
				          <nose>
				            <x>55.26</x>
				            <y>70.2</y>
				          </nose>
				          <ear_left/>
				          <ear_right/>
				          <chin/>
				          <yaw>13.54</yaw>
				          <roll>-4.87</roll>
				          <pitch>-1.04</pitch>
				          <attributes>
				            <face>
				              <value>true</value>
				              <confidence>96</confidence>
				            </face>
				            <gender>
				              <value>female</value>
				              <confidence>38</confidence>
				            </gender>
				            <glasses>
				              <value>false</value>
				              <confidence>8</confidence>
				            </glasses>
				            <smiling>
				              <value>false</value>
				              <confidence>71</confidence>
				            </smiling>
				          </attributes>
				        </tag>
				      </tags>
				    </photo>
				  </photos>
				  <status>success</status>
				  <usage>
				    <used>4</used>
				    <remaining>4996</remaining>
				    <limit>5000</limit>
				    <reset_time_text>Fri, 02 Sep 2011 13:55:04 +0000</reset_time_text>
				    <reset_time>1314971704</reset_time>
				  </usage>
				</response>;*/
		
		
		public static function parseXML(xml:XML):Vector.<FaceFeatures>
		{
			/*xml = testXML;*/
			
			var photoWidth:int = xml..photos.photo[0].width;
			var photoHeight:int = xml..photos.photo[0].height;
			var feature:String;
			var i:int;
			var j:int;
			var faceAttributes:FaceAttributes = new FaceAttributes();
			
			var numFaces:int = xml..tags.tag.length();
			var faces:Vector.<FaceFeatures> = new Vector.<FaceFeatures>(numFaces);
			
			for (i = 0; i < numFaces; i++)
			{
				var faceFeatures:FaceFeatures = new FaceFeatures();
				
				var tag:XML = xml..tags.tag[i];

				for each (feature in POINT_FEATURES)
				{
					if (tag[feature].x != undefined && tag[feature].y != undefined)
					{
						faceFeatures[feature] = new Point(tag[feature].x / 100 * photoWidth, tag[feature].y / 100 * photoHeight);
					}
				}

				if (faceFeatures.eye_left && faceFeatures.eye_right)
				{
					var eyeDistance:Number = Range.distance(
						faceFeatures.eye_left.x,
						faceFeatures.eye_left.y,
						faceFeatures.eye_right.x,
						faceFeatures.eye_right.y
					);
				
					faceFeatures.faceScale = eyeDistance * 0.75 / 100;
				}
				
				faceFeatures.mouth_midleft = new Point(
					(faceFeatures.mouth_left.x + faceFeatures.mouth_center.x) / 2,
					faceFeatures.mouth_center.y
				);

				faceFeatures.mouth_midright = new Point(
					(faceFeatures.mouth_right.x + faceFeatures.mouth_center.x) / 2,
					faceFeatures.mouth_center.y
				);


				for each (feature in NUMBER_FEATURES)
				{
					if (tag[feature] != undefined)
					{
						faceFeatures[feature] = tag[feature];
					}
				}
				
				
				for each (feature in FACE_ATTRIBUTES)
				{
					if (tag.attributes[feature] != undefined)
					{
						faceAttributes[feature] = new ValueConfidence(tag.attributes[feature].value, tag.attributes[feature].confidence);
					}
				}
				
				faceFeatures.attributes = faceAttributes;

				faceFeatures.tid = tag.tid;

				
				// Parse UIDs
				faceFeatures.uids = new Vector.<FaceUID>();
				
				for (j = 0; j < tag.uids.recognition.length(); j++)
				{
					var uidXML:XML = tag.uids.recognition[j];
					var faceUID:FaceUID = new FaceUID(uidXML.uid, uidXML.confidence);
					faceFeatures.uids.push(faceUID);
					trace(faceUID);
				}
				
				faces[i] = faceFeatures;
			}
			
			return faces;
		}
	
	
		public static function drawFeaturePoints(faceFeatures:FaceFeatures, canvas:Graphics, featuresList:Array):void
		{
			canvas.clear();
			
			for each (var feature:String in featuresList)
			{
				var featurePoint:Point = faceFeatures[feature];
				if (!featurePoint) continue;
				canvas.beginFill(0xff0000, 1.0);
				canvas.drawCircle(featurePoint.x, featurePoint.y, 2);
				canvas.endFill();
			}
		}
	}
}