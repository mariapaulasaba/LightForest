class Squirrel {
  PImage img1, img2;

  PVector topLocation;
  PVector bottomLocation;
  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;   
  float maxspeed; 

  PVector goal;
  int counter, t, x, y, h, w;
  boolean light;
  boolean direction;
  boolean reached;

  Squirrel(int tree) {
    t = tree;
    counter = 0;
    if (t == 1) {
      x = 10;
      y = -15;
    }
    else {
      x = -120;
      y = 0;
    }
    
    w = width/22;
    h = height/8;
    
    topLocation = new PVector(trees[t].x3+x, trees[t].y2+y);
    bottomLocation = new PVector(trees[t].x3+x, trees[t].y2+y+150);

    location = topLocation.get();
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0.5);    
    r = 6;
    maxspeed = 3;
    maxforce = 0.05;

    goal = location;
    reached = true;
    light = true;   

    if (t == 1) {
      img1 = loadImage("squirrel.png");
      img2 = loadImage("squirrel2.png");
    }
    else {
      img1 = loadImage("squirrel3.png");
      img2 = loadImage("squirrel4.png");
    }
  }


  void applyForce(PVector force) {
    acceleration.add(force);
  }



  void  update() {
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    location.add(velocity);
    acceleration.mult(0);

    if (velocity.y < 0.01 && velocity.y > -0.01) direction = true;
    else if (velocity.y > 0) direction = false;
    else direction = true;
  }


  void arrive() {
    PVector desired = PVector.sub(goal, location); 
    float d = desired.mag();
    if (d < 5) {
      reached = true;
    }
    else reached = false;

    if (d < 100) {
      float m = map(d, 0, 100, 0, maxspeed);
      desired.setMag(m);
    } 
    else {
      desired.setMag(maxspeed);
    }

    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  
    applyForce(steer);
  }

  void display() {
    float theta = velocity.heading2D();
    fill(175);
    stroke(0);
    pushMatrix();
    translate(location.x, location.y);

    if (direction) {   
      if (velocity.y < -0.5 || velocity.y > 0.5) {
        if (counter <= 5) image(img1, 0, 0, w, h);     
        else if (counter > 5 && counter <=10) image(img2, 0, 0, w, h);
      }
      else image(img1, 0, 0, w, h);
    }
    else {
      pushMatrix();
      scale(1, -1);
      if (velocity.y < -0.5 || velocity.y > 0.5) {
        if (counter <= 5) image(img1, 0, -42, w, h);     
        else if (counter > 5 && counter <=10) image(img2, 0, -42, w, h);
      }
      else image(img1, 0, -42, w, h
      );
      popMatrix();
    }
    popMatrix();

    counter ++;
    if (counter > 10) counter = 0;
    stroke(255, 0, 0);
  }


  void setNewGoal() {

    if (light && reached) {
          squirrelSound.trigger();

      goal = new PVector(location.x, random(topLocation.y,bottomLocation.y));  
      float d = abs(location.y - goal.y);
      while(d < 100) {
        goal = new PVector(location.x, random(topLocation.y,bottomLocation.y));  
         d = abs(location.y - goal.y);
      }

     // println(d);
    }
    
    else {
      int prob = (int)random(500);
     // if (prob == 499)   goal = new PVector(location.x, random(topLocation.y, bottomLocation.y));
    }
    light = false;
  }


void avoid(PVector target){
PVector diff = PVector.sub(location,target);
//avoid light
//if(diff.mag()<70 &&) velocity.y = 0;
if(diff.mag()<70) light = true;

}


void scare(Rabbit r, ArrayList<Bird> bs){
  
  PVector diff = PVector.sub(location, r.location);
  if(diff.mag()<70) light = true;
 // println(light);
  
  for (Bird b : bs) {

  PVector d = PVector.sub(location, b.location);
  if(d.mag()<40) light = true;
  

  }
}

}


