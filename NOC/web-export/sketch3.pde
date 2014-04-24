PImage background, lightImage, lightImage2;
Tree[] trees = new Tree[3];
ArrayList<Bird> birds;
Squirrel s;
Squirrel sq;
Rabbit rb;
Rabbit r;
Bug[] bugs = new Bug[15];

void setup() {
  size(1024, 768, P2D);
  smooth();
  // frameRate(20);


  background = loadImage("cenario3.jpg");
  lightImage = loadImage("light.png");
  lightImage2 = loadImage("light2.png");

  trees[0] = new Tree(40, 190, 260, 200);
  trees[1] = new Tree(360, 130, 350, 240);
  trees[2] = new Tree(715, 195, 310, 180);


  birds = new ArrayList<Bird>();
  for (int i = 0; i < 25; i++) {
    birds.add(new Bird(random(width), random(height)));
  }

  for (int i = 0; i < bugs.length ; i++) {
    bugs[i] = new Bug(random(width), random(height));
  }

  rb = new Rabbit(random(0, width), height-180, 10);
  r = new Rabbit(random(0, width), height-100, 12);
  s = new Squirrel(1);
  sq = new Squirrel(2);
}



void draw() {
  imageMode(CORNER);
 image(background, 0, 0);
 // background(0);

  PVector target = new PVector(mouseX, mouseY);


  bird();
  rabbit(target);
  squirrel();

  fill(0, 100);
//  rect(0, 0, width, height);

  imageMode(CENTER); 
  bugs(target);
  flashlight();
}


void flashlight() {
//  blendMode(ADD);
  image(lightImage, mouseX, mouseY, 100, 100);  
  image(lightImage2, mouseX, mouseY, 160, 160);
}

void bird() {
  for (Bird b : birds) {
    b.applyBehaviors(birds);
    b.update();
    b.display();

    float d = dist(mouseX, mouseY, b.location.x, b.location.y);
    if (d < 30)  b.light = true;

    float prob = random(1);
    if (prob < 0.0001) b.light = true;

    b.avoid();
  }
}

void squirrel() {
  s.setNewGoal();
  sq.setNewGoal();

  s.update();
  s.arrive();
  s.display();

  sq.update();
  sq.arrive();
  sq.display();

  if (mousePressed) { 
    s.light = true; 
    sq.light = true;
  }
}

void rabbit(PVector t) {
  rb.avoid(t);
  rb.update();
  rb.display();

  r.avoid(t);
  r.update();
  r.display();
}


void bugs(PVector t) {

  for (int i = 0; i < bugs.length ; i++) {

    bugs[i].update(bugs, t);  
    bugs[i].checkEdges();  
    bugs[i].display();
  }
}

class Bird {

  PImage img0, img1, img2, img3;
  PVector location;
  PVector velocity;
  PVector acceleration;
  float maxforce;   
  float maxspeed; 

  PVector goal;
  int t;
  boolean light;
  boolean reached;
  int counter;
  boolean direction;
 

  Bird(float x, float y) {
    t = (int)random(3);
    img0 = loadImage("bird0.png");
    img1 = loadImage("bird1.png");
    img2 = loadImage("bird2.png");
    img3 = loadImage("bird3.png");

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
        image(img0, -20, 0, 40, 31);      
        popMatrix();
      }
      else {
        image(img0, 20, 0, 40, 31);
      }
 
    }
    else {
      if (velocity.x >0) {
        pushMatrix();
        scale(-1, 1);  
        if (counter <= 5) image(img1, -20, 0, 40, 31);
        else if (counter > 5 && counter <=10) image(img2, -20, 0, 40, 31);
        else if (counter > 10 && counter <=13) image(img3, -20, 0, 40, 31);
        else if (counter > 13 && counter <=20) image(img2, -20, 0, 40, 31); 
        else if (counter > 20) {
          image(img1, -20, 0, 40, 31);  
          counter = 0;
        }
        popMatrix();
        counter ++;
      }
      else {
        if (counter <= 5) image(img1, 20, 0, 40, 31);
        else if (counter > 5 && counter <=10) image(img2, 20, 0, 40, 31);
        else if (counter > 10 && counter <=13) image(img3, 20, 0, 40, 31);
        else if (counter > 13 && counter <=20) image(img2, 20, 0, 40, 31);
        else if (counter > 20) {
          image(img1, 20, 0, 40, 31);
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

class Bug {
  PImage img;
  PVector location;
  PVector velocity;
  PVector acceleration;
  float maxspeed, maxforce;
  PVector noff;
  boolean state;
  int size;

  Bug(float x, float y) {
    img = loadImage("firefly.png");
    location = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    maxspeed = 1;
    maxforce = 1;
    noff = new PVector(random(1000), random(1000));
    state = false;
    size = (int) random(7,9);
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void update(Bug[] bugs, PVector t) {
    PVector force = PVector.sub(t, location);
    float d = force.mag();
    //d = constrain(d, 5.0, 25.0);
    force.normalize();
    force.mult(0.05/d*d);
    force.limit(maxforce);  
    

    if (d < 200 && t.y > 200) { 
      PVector separateForce = separate(bugs);
      //PVector seekForce = seek(t);
      //seekForce.mult(2);

      separateForce.mult(0.05);
      applyForce(separateForce);
      applyForce(force);
      velocity.add(acceleration);
      velocity.limit(maxspeed*2);
      location.add(velocity);
      acceleration.mult(0);
    }

    else {
      acceleration.x = map(noise(noff.x), 0, 1, -1, 1);
      acceleration.y = map(noise(noff.y), 0, 1, -1, 1);
      acceleration.mult(0.1);

      noff.add(0.01, 0.01, 0);

      velocity.add(acceleration);
      velocity.limit(maxspeed);
      location.add(velocity);

      //location.x = constrain(location.x, 0, width-1);
      //location.y = constrain(location.y, 0, height-1);
    }
  }


  void display() {
    noStroke();
    float prob = random(1);
    if(prob < 0.01)  state = !state;
    
    if(state) {
      image(img, location.x, location.y, size, size);
    }
    else {
    fill(0, 0, 0, 50);
    ellipse(location.x, location.y, 3, 3);
    }
  }



  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, location);  
    desired.normalize();
    desired.mult(maxspeed);

    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  
    return steer;
  }




  PVector separate (Bug[] bugs) {
    float desiredseparation = 10;
    PVector sum = new PVector();
    int count = 0;
    for (Bug other : bugs) {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < desiredseparation)) {
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

  void checkEdges() {
    if (location.x > width) location.x = 0;
    else if (location.x < 0) location.x = width;
    if (location.y > height) {
      location.y = 0;
    }
    else if (location.y < 0) {
      location.y = height;
    }
  }
}

class Rabbit {
  PImage img1, img2;
  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  boolean light;
  boolean direction;
  float frame;
  float ground;
  int pv;

  Rabbit(float x, float y, int size) {
    location = new PVector(x, y);
    ground = location.y;
    r = 10;
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);   
    light = false;
    frame = 0;
    direction = true;
    r = size;
    
    img1 = loadImage("rabbit1.png");
    img2 = loadImage("rabbit2.png");
    pv = 1;
  }



  void applyForce(PVector force) {
    acceleration.add(force);
  }


  void update() {
    gravity();
    impulse();
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
    
    
    //borders
    if(location.x > width-50) direction = false;
    else if(location.x < 50) direction = true;
  }



  void gravity() {
    PVector force = new PVector(0, 0.3);
    applyForce(force);
    
    //stop applying gravity if touched ground
    if (location.y > ground) {
   
      velocity.mult(0);
      location.y = ground;
    }
  }


  void impulse() {
    PVector impulse = new PVector(0,0);
    
    if (light) {
       frame ++;     
      //setting velocity through direction 
      if(direction) impulse = new PVector(2.5,-3.5);
      else impulse = new PVector(-2.5,-3.5);
      //giving impulse
      if (location.y < ground+1 && location.y > ground-1) velocity = impulse;
      
      //keep walking til random times
      if (frame > random(20,80)){
        light = false;
        frame = 0;
        
       //determine next direction 
       if(random(1)>0.8)   direction = !direction;
       //else direction = false;
      }

    }

  }


void avoid(PVector target){
PVector diff = PVector.sub(location,target);
//avoid light
if(diff.mag()<70) light = true;
//random walk 
float prob = random(1);
if(prob < 0.001) light = true;
}


  void display() {
   imageMode(CENTER);
    pushMatrix();
    translate(location.x, location.y);
    if (location.y > ground+5 || location.y < ground-5){
      if(velocity.x < 0){
        image(img2,37,0);
        pv = 0;
      }
    else{
      pushMatrix();
      scale(-1,1);
      image(img2,-37,0);
      popMatrix();
      pv = 1;
      
    }
    }
    
    else if(pv == 0) image(img1,37,0);
    else {
      pushMatrix();
      scale(-1,1);
      image(img1,-37,0);
      popMatrix();
    }
    popMatrix();
    imageMode(CORNER);
    
  }
}


class Squirrel {
  PImage img;

  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;   
  float maxspeed; 

  PVector goal;
  int t, h, w;
  boolean light;

  Squirrel(int tree) {
    t = tree;
    if (t == 1) {
      h = 20;
      w = 0;
    }
    else {
      h = 0;
      w = 20;
    }

    location = new PVector(trees[t].x3, trees[t].y2);
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0.5);    
    r = 6;
    maxspeed = 3;
    maxforce = 0.05;

    light = true;   
    goal = location;
    
    img = loadImage("squirrel.png");
  }


  void applyForce(PVector force) {
    acceleration.add(force);
  }



  void  update() {
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    location.add(velocity);
    acceleration.mult(0);
  }


  void arrive() {
    PVector desired = PVector.sub(goal, location); 
    float d = desired.mag();
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
    float theta = velocity.heading2D()+ radians(90);
    fill(175);
    stroke(0);
    pushMatrix();
    translate(location.x, location.y);
    rotate(theta);
    /*beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();*/
    image(img,0,0);
    popMatrix();

    
  }


  void setNewGoal() {

    if (light) {
      if (location.y > trees[t].y2 + 80) {
        goal = new PVector(random(trees[t].x3-10, trees[t].x3+10 )-w, 
        random(trees[t].y2, trees[t].y2+50)-h);
      }
    }
    else {
      int prob = (int)random(500);
      if (prob == 499)    goal = new PVector(random(trees[t].x3-10, trees[t].x3+10)-w, random(trees[t].y2, trees[t].y2  + 260)-h);
    }
    light = false;
    //line(trees[t].x3-10-w,trees[t].y2-h, trees[t].x3+10-w, trees[t].y2+260-h);
  }
}

class Tree{
  int x, y, h, w;
  int x2, y2, x3;
  
  Tree(int tempX, int tempY, int tempW, int tempH){
   x = tempX;
   y = tempY;
   h = tempH;
   w = tempW;

   x2 = x + w;
   y2 = y + h;
   
   x3 = x + w/2;
   
  }


void display(){
 // rect(x, y, w, h);
}


}


