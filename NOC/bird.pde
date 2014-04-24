class Bird {

  PImage img0, img1, img2, img3;
  PVector location;
  PVector velocity;
  PVector acceleration;
  float maxforce;   
  float maxspeed; 

  PVector goal;
  int w, h, t;
  boolean light;
  boolean reached;
  int counter;
  boolean direction;
 

  Bird(float x, float y) {
    t = (int)random(3);
    img0 = loadImage("cbird0.png");
    img1 = loadImage("cbird1.png");
    img2 = loadImage("cbird2.png");
    img3 = loadImage("cbird3.png");
    
    w = width/25;
    h = height/25;
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    goal = new PVector(random(trees[t].x, trees[t].x2), random(trees[t].y, trees[t].y2));    
    location = goal;

    maxspeed = 3;
    maxforce = 2;
    light = false;
    reached = true;
    float prob = random(1);
    if(prob > 0.5) direction = true;
    else direction = false;
    counter = 0;
  }



  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void update() {
    velocity.add(acceleration);
    // velocity.limit(maxspeed);
    location.add(velocity);
    acceleration.mult(0);
  }



  void display() {
    imageMode(CENTER);
    pushMatrix();
    translate(location.x, location.y);
    if (velocity.x < 0.05 && velocity.x > -0.05) {
      if (direction) {
        pushMatrix();
        scale(-1, 1);
        image(img0, -20, 0, w, h);      
        popMatrix();
      }
      else {
        image(img0, 20, 0, w, h);
      }
 
    }
    else {
      if (velocity.x >0) {
        pushMatrix();
        scale(-1, 1);  
        if (counter <= 5) image(img1, -20, 0, width/25, 31);
        else if (counter > 5 && counter <=10) image(img2, -20, 0, w, h);
        else if (counter > 10 && counter <=13) image(img3, -20, 0, w, h);
        else if (counter > 13 && counter <=20) image(img2, -20, 0, w, h); 
        else if (counter > 20) {
          image(img1, -20, 0, w, h);  
          counter = 0;
        }
        popMatrix();
        counter ++;
      }
      else {
        if (counter <= 5) image(img1, 20, 0, w, h);
        else if (counter > 5 && counter <=10) image(img2, 20, 0, w, h);
        else if (counter > 10 && counter <=13) image(img3, 20, 0,w, h);
        else if (counter > 13 && counter <=20) image(img2, 20, 0,w, h);
        else if (counter > 20) {
          image(img1, 20, 0, w, h);
          counter = 0;
        }
        counter ++;
      }
    } 
    popMatrix();
    imageMode(CORNER);
  }


  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, location);  
    float d = desired.mag();   
    if (d < 5) {
      reached = true;
    }
    else reached = false;

    if (d < 10) {
      float m = map(d, 0, 100, 0, maxspeed);
      desired.setMag(m);
    } 
    else {
      desired.setMag(maxspeed);
    }

    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  
    return steer;
  }

  PVector separate (ArrayList<Bird> birds) {
    float desiredseparation = 30;
    PVector sum = new PVector();
    int count = 0;
    for (Bird other : birds) {
      float d = PVector.dist(location, other.location);
      float prob = random(1);
      
      if ((d > 10) && (d < desiredseparation) && other.reached != true && prob < 0.2) {
        PVector diff = PVector.sub(location, other.location);
        diff.normalize();
        diff.div(d);        
        sum.add(diff);
        count++;
      }
    }

    if (count > 0) {
      sum.div(count);
      sum.normalize();
      sum.mult(maxspeed);
      sum.sub(velocity);
      sum.limit(maxforce);
    }
    return sum;
  }


  void applyBehaviors(ArrayList<Bird> birds) {
    PVector seekForce = seek(goal);     
    applyForce(seekForce);    


    if (!reached) {  
      PVector separateForce = separate(birds);
      separateForce.mult(1);
      applyForce(separateForce);
    }
    else {
      for (Bird other : birds) {
        float d = PVector.dist(location, other.location);
        if ((d<10) && other.reached != true) {
          float prob = random(1);
          if(prob < 0.3) setNewGoal();
         // else other.setNewGoal();
        }
      }
    }
  }



  void avoid() {
    if (light && reached) setNewGoal();
    light = false;
  }

  void setNewGoal() {
    
    direction = !direction;
    
    //choose a new tree  
    int pt = t;
    t = (int)random(3);
    while (t == pt) t = (int)random(3); 
    //go to new tree
    goal = new PVector(random(trees[t].x, trees[t].x2), random(trees[t].y, trees[t].y2));
    PVector desired = PVector.sub(goal, location);
    desired.normalize();
    // velocity = new PVector(desired.x * 10, -15);
  }
}

