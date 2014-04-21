#pragma once

#include "ofMain.h"
#include "ofxMacamPs3Eye.h"
#include "ofxCv.h"
#include "ofxOsc.h"

#define HOST "localhost"
#define PORT 12345


class testApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();

		void keyPressed  (int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);
    
    
    //PS3 Eye
    ofxMacamPs3Eye ps3eye;
    int 				camWidth;
    int 				camHeight;
	
    ofxCv::ContourFinder contourFinder;
    //ofxCvContourFinder contourFinder;
    int threshold;
    ofVec2f blobCenter;
    
    ofxOscSender sender;    

};
