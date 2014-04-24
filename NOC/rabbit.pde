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
  int w, h;

  Rabbit(float x, float y, int n) {
    location = new PVector(x, y);
    ground = location.y;
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);   
    light = false;
    frame = 0;
    direction = true;
    r = n;


    pv = 1;

    if (n == 1) {
      w = width/12;
      h = height/10;
      img1 = loadImage("rabbit1.png");
      img2 = loadImage("rabbit2.png");
    }
    else {
      w = width/11;
      h = height/9;
      img1 = loadImage("rabbit3.png");
      img2 = loadImage("rabbit4.png");
    }
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
    if (location.x > width-100) direction = false;
    else if (location.x < 50) direction = true;
  }



  void gravity() {
    PVector force = new PVector(0, 0.4);
    applyForce(force);

    //stop applying gravity if touched ground
    if (location.y > ground) {

      velocity.mult(0);
      location.y = ground;
    }
  }


  void impulse() {
    PVector impulse = new PVector(0, 0);

    if (light) {
      frame ++;     
      //setting velocity through direction 
      if (direction) impulse = new PVector(3.5, -4.5);
      else impulse = new PVector(-3.5, -4.5);
      //giving impulse
      if (location.y < ground+1 && location.y > ground-1) {
        rabbitSound.trigger();
        velocity = impulse;
      }

      //keep walking til random times
      if (frame > random(20, 80)) {
        light = false;
        frame = 0;

        //determine next direction 
        if (random(1)>0.8)   direction = !direction;
        else direction = false;
      }
    }
  }


  void avoid(PVector target) {
    PVector diff = PVector.sub(location, target);

    //avoid light
    if (diff.mag()<70) {
      if (location.x < width  && location.x > target.x) direction = true;
      else if (location.x > 0 && location.x < target.x) direction = false;
      light = true;
    }
    //random walk 
    float prob = random(1);
    if (prob < 0.001) light = true;
  }


  void display() {
    // println(direction);
    imageMode(CENTER);
    pushMatrix();
    translate(location.x, location.y);
    if (location.y > ground+5 || location.y < ground-5) {
      if (velocity.x < 0) {
        image(img2, w/2, 0, w, h);
        pv = 0;
      }
      else {
        pushMatrix();
        scale(-1, 1);
        image(img2, -w/2, 0, w, h);
        popMatrix();
        pv = 1;
      }
    }

    else if (pv == 0) image(img1, w/2, 0, w, h);
    else {
      pushMatrix();
      scale(-1, 1);
      image(img1, -w/2, 0, w, h);
      popMatrix();
    }
    popMatrix();
    imageMode(CORNER);
  }
}

