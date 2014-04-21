#include "testApp.h"
using namespace ofxCv;
using namespace cv;

//--------------------------------------------------------------
void testApp::setup(){
    ofSetVerticalSync(true);
	
	camWidth = 640;
	camHeight = 480;
	
	ps3eye.listDevices();
	
	ps3eye.setDesiredFrameRate(60);
	ps3eye.initGrabber(camWidth,camHeight);
	
	ps3eye.setAutoGainAndShutter(false); // otherwise we can't set gain or shutter
	ps3eye.setGain(0.5);
	ps3eye.setShutter(0.1);
	ps3eye.setGamma(0.5);
	ps3eye.setBrightness(0.3);
	ps3eye.setContrast(1.0);
	ps3eye.setHue(0.0);
	
	ps3eye.setFlicker(1);
    
    
    
    contourFinder.setMinAreaRadius(10);
	contourFinder.setMaxAreaRadius(200);
    threshold = 50;

    // open an outgoing connection to HOST:PORT
	sender.setup(HOST, PORT);
}

//--------------------------------------------------------------
void testApp::update(){
    ps3eye.update();
	
	// Blink the led everytime there is a new frame
	if(ps3eye.isFrameNew()){
		ps3eye.setLed(true);
        
        contourFinder.setThreshold(threshold);
		contourFinder.findContours(ps3eye);
        //contourFinder.findContours(ps3eye, 20, (340*240)/3, 10, true);
       // cout << threshold << endl;
	}
	else ps3eye.setLed(false);

    
    int n = contourFinder.size();
	//for(int i = 0; i < n; i++) {
    if(n >= 1){
        // some different styles of contour centers
        blobCenter = toOf(contourFinder.getCentroid(0));
        ofSetColor(cyanPrint);
        ofCircle(blobCenter, 1);
        
        ofxOscMessage m;
        m.setAddress("/test");
        m.addFloatArg(blobCenter.x);
        m.addFloatArg(blobCenter.y);
        //m.addFloatArg(3.5f);
        //m.addStringArg("hello");
        //m.addFloatArg(ofGetElapsedTimef());
        sender.sendMessage(m);
  
    }
    else{
        ofxOscMessage m;
        m.setAddress("/test");
        m.addFloatArg(0);
        m.addFloatArg(0);
        //m.addFloatArg(3.5f);
        //m.addStringArg("hello");
        //m.addFloatArg(ofGetElapsedTimef());
        sender.sendMessage(m);
    
    
    }

    
    //cout << n << endl;
    

}

//--------------------------------------------------------------
void testApp::draw(){
    ofSetHexColor(0xffffff);
	ps3eye.draw(0,0);
    
    ofSetColor(255);
	contourFinder.draw();
    int n = contourFinder.size();
	for(int i = 0; i < n; i++) {
        
        // some different styles of contour centers
        ofVec2f centroid = toOf(contourFinder.getCentroid(i));
        ofVec2f average = toOf(contourFinder.getAverage(i));
        ofVec2f center = toOf(contourFinder.getCenter(i));
        ofSetColor(cyanPrint);
        ofCircle(centroid, 1);
        ofSetColor(magentaPrint);
        ofCircle(average, 1);
        ofSetColor(yellowPrint);
        ofCircle(center, 1);
    }

	
	ofDrawBitmapString("Ps3Eye FPS: "+ ofToString(ps3eye.getRealFrameRate()), 20,15);
}

//--------------------------------------------------------------
void testApp::keyPressed(int key){

}

//--------------------------------------------------------------
void testApp::keyReleased(int key){

}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void testApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void testApp::dragEvent(ofDragInfo dragInfo){ 

}