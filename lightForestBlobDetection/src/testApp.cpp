#include "testApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
	ofSetVerticalSync(true);
    ofSetFrameRate(60);
	//ofSetWindowShape(1024, 768);
    //ofToggleFullscreen();
	
	ps3eye.initGrabber(320, 240);
	
    
    //setting up the gui controls
	gui.setup("PS3Eye", "ps3eye.xml");
	gui.setPosition(660,20);
	
    ofxToggle * autoGainAndShutter = new ofxToggle();
    autoGainAndShutter->setup("Auto Gain and Shutter", false);
    autoGainAndShutter->addListener(this, &ofApp::onAutoGainAndShutterChange);
    gui.add(autoGainAndShutter);
     
    ofxFloatSlider * gain = new ofxFloatSlider();
    gain->setup("Gain", 0.5, 0.0, 1.0);
    gain->addListener(this, &ofApp::onGainChange);
    gui.add(gain);
     
    ofxFloatSlider * shutter = new ofxFloatSlider();
    shutter->setup("Shutter", 0.5, 0.0, 1.0);
    shutter->addListener(this, &ofApp::onShutterChange);
    gui.add(shutter);
     
    ofxFloatSlider * gamma = new ofxFloatSlider();
    gamma->setup("Gamma", 0.5, 0.0, 1.0);
    gamma->addListener(this, &ofApp::onGammaChange);
    gui.add(gamma);
     
    ofxFloatSlider * brightness = new ofxFloatSlider();
    brightness->setup("Brightness", 0.5, 0.0, 1.0);
    brightness->addListener(this, &ofApp::onBrightnessChange);
    gui.add(brightness);
     
    ofxFloatSlider * contrast = new ofxFloatSlider();
    contrast->setup("Contrast", 0.5, 0.0, 1.0);
    contrast->addListener(this, &ofApp::onContrastChange);
    gui.add(contrast);
     
    ofxFloatSlider * hue = new ofxFloatSlider();
    hue->setup("Hue", 0.5, 0.0, 1.0);
    hue->addListener(this, &ofApp::onHueChange);
    gui.add(hue);
    
    ofxIntSlider * threshold = new ofxIntSlider();
    threshold->setup("Threshold", 80, 0, 255);
    threshold->addListener(this, &ofApp::onThresholdChange);
    gui.add(threshold);
     
    ofxIntSlider * flicker = new ofxIntSlider();
    flicker->setup("Flicker Type", 0, 0, 2);
    flicker->addListener(this, &ofApp::onFlickerChange);
    gui.add(flicker);
     
    ofxIntSlider * wb = new ofxIntSlider();
    wb->setup("White Balance Mode", 4, 1, 4);
    wb->addListener(this, &ofApp::onFlickerChange);
    gui.add(wb);
	
	ofxToggle * led = new ofxToggle();
    led->setup("LED", true);
	led->addListener(this, &ofApp::onLedChange);
	gui.add(led);
	
	// Load initial values from Xml
    gui.loadFromFile("ps3eye.xml");
    bool b;
    float f;
    int i;
    b = gui.getToggle("Auto Gain and Shutter");
    onAutoGainAndShutterChange(b);
    f = gui.getFloatSlider("Gain");
    onGainChange(f);
    f = gui.getFloatSlider("Shutter");
    onShutterChange(f);
    f = gui.getFloatSlider("Gamma");
    onGammaChange(f);
    f = gui.getFloatSlider("Brightness");
    onBrightnessChange(f);
    f = gui.getFloatSlider("Contrast");
    onContrastChange(f);
    f = gui.getFloatSlider("Hue");
    onHueChange(f);
    b = gui.getToggle("LED");
    onLedChange(b);
    i = gui.getIntSlider("Threshold");
    i = gui.getIntSlider("Flicker Type");
    onFlickerChange(i);
    i = gui.getIntSlider("White Balance Mode");
    onWhiteBalanceChange(i);
    
    //opencv variables
    colorImg.allocate(320,240);
	grayImage.allocate(320,240);
	grayBg.allocate(320,240);
	grayDiff.allocate(320,240);
    
	bLearnBakground = true;
    
    //osc setup
    sender.setup(HOST, PORT);
	
}

//--------------------------------------------------------------
void ofApp::update(){
    ofBackground(100,100,100);
	bool bNewFrame = false;
    
    ps3eye.update();
    
    bNewFrame = ps3eye.isFrameNew();
    
	if (bNewFrame){
        
        colorImg.setFromPixels(ps3eye.getPixels(), 320, 240);
        
        grayImage = colorImg;
		if (bLearnBakground == true){
			grayBg = grayImage;		// the = sign copys the pixels from grayImage into grayBg (operator overloading)
			bLearnBakground = false;
		}
        
		// take the abs value of the difference between background and incoming and then threshold:
		grayDiff.absDiff(grayBg, grayImage);
		grayDiff.threshold(cvThreshold);
        
		contourFinder.findContours(grayDiff, 100, 10000, 1, false);	// find holes
	}
    
    if(contourFinder.nBlobs == 1){
        // some different styles of contour centers
        blobCenter = contourFinder.blobs[0].boundingRect.getCenter();
        ofCircle(blobCenter, 10);
        
        blobCenter *= 2;
        
        cout << blobCenter << endl;
        
        ofxOscMessage m;
        m.setAddress("/test");
        m.addFloatArg(blobCenter.x);
        m.addFloatArg(blobCenter.y);
        //m.addFloatArg(3.5f);
        //m.addStringArg("hello");
        //m.addFloatArg(ofGetElapsedTimef());
        sender.sendMessage(m);
        
    }
    
}

//--------------------------------------------------------------
void ofApp::draw(){
	// draw the incoming, the grayscale, the bg and the thresholded difference
	ofSetHexColor(0xffffff);
	colorImg.draw(20,20);
	grayImage.draw(360,20);
	grayBg.draw(20,280);
	grayDiff.draw(360,280);
    
	// then draw the contours:
    
	ofFill();
	ofSetHexColor(0x333333);
	ofRect(360,540,320,240);
	ofSetHexColor(0xffffff);
    
	// we could draw the whole contour finder
	//contourFinder.draw(360,540);
    
	// or, instead we can draw each blob individually from the blobs vector,
	// this is how to get access to them:
    for (int i = 0; i < contourFinder.nBlobs; i++){
        contourFinder.blobs[i].draw(360,540);
		
		// draw over the centroid if the blob is a hole
		ofSetColor(255);
		if(contourFinder.blobs[i].hole){
			ofDrawBitmapString("hole",
                               contourFinder.blobs[i].boundingRect.getCenter().x + 360,
                               contourFinder.blobs[i].boundingRect.getCenter().y + 540);
		}
    }
    
	ofDrawBitmapString("FPS "+ofToString(ps3eye.getRealFrameRate()), 20, 20);
    
    ofSetHexColor(0xffffff);
	stringstream reportStr;
	reportStr << "bg subtraction and blob detection" << endl
    << "press ' ' to capture bg" << endl
    << "threshold " << cvThreshold << " (press: +/-)" << endl
    << "num blobs found " << contourFinder.nBlobs << ", fps: " << ofGetFrameRate();
	ofDrawBitmapString(reportStr.str(), 20, 600);
    
	gui.draw();
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){
    
	switch (key){
		case ' ':
			bLearnBakground = true;
			break;
	}
}

//--------------------------------------------------------------
void ofApp::onAutoGainAndShutterChange(bool & value){
	ps3eye.setAutoGainAndShutter(value);
}

//--------------------------------------------------------------
void ofApp::onGainChange(float & value){
	// Only set if auto gain & shutter is off
	if(!(bool&)gui.getToggle("Auto Gain and Shutter")){
        ps3eye.setGain(value);
	}
}

//--------------------------------------------------------------
void ofApp::onShutterChange(float & value){
	// Only set if auto gain & shutter is off
	if(!(bool&)gui.getToggle("Auto Gain and Shutter")){
        ps3eye.setShutter(value);
	}
}

//--------------------------------------------------------------
void ofApp::onGammaChange(float & value){
	ps3eye.setGamma(value);
}

//--------------------------------------------------------------
void ofApp::onBrightnessChange(float & value){
	ps3eye.setBrightness(value);
}

//--------------------------------------------------------------
void ofApp::onContrastChange(float & value){
	ps3eye.setContrast(value);
}

//--------------------------------------------------------------
void ofApp::onHueChange(float & value){
	ps3eye.setHue(value);
}

//--------------------------------------------------------------
void ofApp::onLedChange(bool & value){
	ps3eye.setLed(value);
}

//--------------------------------------------------------------
void ofApp::onThresholdChange(int & value){
	cvThreshold = value;
}


//--------------------------------------------------------------
void ofApp::onFlickerChange(int & value){
	ps3eye.setFlicker(value);
}

//--------------------------------------------------------------
void ofApp::onWhiteBalanceChange(int & value){
	ps3eye.setWhiteBalance(value);
}