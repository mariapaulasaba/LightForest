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

