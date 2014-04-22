#pragma once

#include "ofMain.h"
#include "ofxGui.h"
#include "ofxMacamPs3Eye.h"
#include "ofxOpenCv.h"
#include "ofxOsc.h"

#define HOST "localhost"
#define PORT 12345

class ofApp : public ofBaseApp{

	public:
    void setup();
	void update();
	void draw();
	void keyPressed(int key);
    
	void onAutoGainAndShutterChange(bool & value);
	void onGainChange(float & value);
	void onShutterChange(float & value);
	void onGammaChange(float & value);
	void onBrightnessChange(float & value);
	void onContrastChange(float & value);
	void onHueChange(float & value);
	void onLedChange(bool & value);
    void onThresholdChange(int & value);
	void onFlickerChange(int & value);
	void onWhiteBalanceChange(int & value);
	
    
    //gui and ps3 eye
	ofxPanel gui;
	ofxMacamPs3Eye ps3eye;
    
    //opencv things
    ofxCvColorImage			colorImg;
    
    ofxCvGrayscaleImage 	grayImage;
    ofxCvGrayscaleImage 	grayBg;
    ofxCvGrayscaleImage 	grayDiff;
    
    ofxCvContourFinder 	contourFinder;
    
    int 				cvThreshold;
    bool				bLearnBakground;
    
    //sending blob
    ofVec2f blobCenter;
    
    ofxOscSender sender;
		
};
