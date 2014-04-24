/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
 // print("### received an osc message.");
 // print(" value1: " + theOscMessage.get(0).floatValue());
  //println(" value2: " + theOscMessage.get(1).floatValue());

  blobX = map(theOscMessage.get(0).floatValue(), 640, 0, 0, 1024);
  
  blobY = map(theOscMessage.get(1).floatValue(), 0, 480, 0, 768) ;
  
    print(" value1: " + blobX);
  println(" value2: " + blobY);

  
}
