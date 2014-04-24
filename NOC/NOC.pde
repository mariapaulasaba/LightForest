//computer vision stuff
import oscP5.*;
import netP5.*;
OscP5 oscP5;
float blobX, blobY;

//sound stuff
import ddf.minim.*;
Minim minim;
AudioSample corujaSound, rabbitSound;
AudioSample squirrelSound, birdSound;
AudioPlayer player;
int corujaCounter;

//animations stuff
PImage background, arvores, frente, lightImage, lightImage2, coruja;
Tree[] trees = new Tree[3];
ArrayList<Bird> birds;
Squirrel s;
Squirrel sq;
Rabbit rb;
Rabbit r;
Bug[] bugs = new Bug[15];



void setup() {
  size(1680, 1050, P2D);
  smooth();
  // frameRate(20);
  oscP5 = new OscP5(this,12345);

  minim = new Minim(this);
  corujaSound = minim.loadSample( "som_coruja.wav", 512  );
  birdSound = minim.loadSample( "som_asas.wav", 2048  );  
  rabbitSound = minim.loadSample( "som_coelho.wav", 512  );  
  squirrelSound = minim.loadSample( "som_esquilo.wav", 512  );  

 // player = minim.loadFile("som_musica.wav");
   player = minim.loadFile("som_floresta.wav");

  player.play(); 
  player.loop();
  corujaCounter = 0;

  noCursor();
  frente = loadImage("frente.png");
  arvores = loadImage("arvores.png");
  background = loadImage("cenario1.jpg");

  lightImage = loadImage("light.png");
  lightImage2 = loadImage("light2.png");
  coruja = loadImage("coruja.png");

  trees[0] = new Tree(width/25, height/4-10, width/4, height/4+20);
  trees[1] = new Tree(width/25*9, height/4-70, width/3, height/4+60);
  trees[2] = new Tree(width/25*18, height/4-10, width/3-40, height/4);


  birds = new ArrayList<Bird>();
  for (int i = 0; i < 25; i++) {
    birds.add(new Bird(random(width), random(height)));
  }

  for (int i = 0; i < bugs.length ; i++) {
    bugs[i] = new Bug(random(width), random(height));
  }

  rb = new Rabbit(random(width/10, width/10-100), height-height/4.3, 1);
  r = new Rabbit(random(width/10, width/10-100), height-height/7.5, 2);
  s = new Squirrel(1);
  sq = new Squirrel(2);
}



void draw() {
  noCursor();
  imageMode(CORNER);
  image(background, 0, 0, width, height);
  // background(0);

  PVector target = new PVector(blobX, blobY);

  println(frameRate);

  rabbit(target);
  bird();
  squirrel(target);



  image(frente, 0, 0, width, height);

  fill(0, 100);
  noStroke();
  //rect(0, 0, width, height);

  imageMode(CENTER); 
  bugs(target);
  flashlight();
  trees[1].display();
  trees[2].display();
}


void flashlight() {
  if (dist(blobX, blobY, width/5.7, height/1.75) < 50) { 
    if ( corujaCounter == 0) {
      corujaSound.trigger();
    }
    corujaCounter++;
    if (corujaCounter > 80) corujaCounter = 0;
  }

  image(coruja,  width/5.7, height/1.75, width/34, height/15);
  blendMode(ADD);
  
    if(blobX != 0){
  image(lightImage, blobX, blobY, 180, 180);  
  image(lightImage2, blobX, blobY, 160, 160);
  }
  
  else{
   image(lightImage, mouseX, mouseY, 180, 180);  
  image(lightImage2, mouseX, mouseY, 160, 160); 
  }

}

void bird() {
  for (Bird b : birds) {
    b.applyBehaviors(birds);
    b.update();
    b.display();

    float d = dist(blobX, blobY, b.location.x, b.location.y);
    if (d < 60) {
      b.light = true;
      birdSound.trigger();
    }
    float prob = random(1);
    if (prob < 0.0001) {
      b.light = true;
      birdSound.trigger();
    }
    b.avoid();
  }
}



void squirrel(PVector t) {

  s.scare(rb, birds);
  sq.scare(rb, birds);

  s.avoid(t);
  sq.avoid(t);
  s.setNewGoal();
  sq.setNewGoal();

  s.update();
  s.arrive();
  s.display();

  sq.update();
  sq.arrive();
  sq.display();
}

void rabbit(PVector t) {
  rb.avoid(t);
  rb.update();
  rb.display();
  image(arvores, 0, 0, width, height);

  r.avoid(t);
  r.update();
  r.display();
  // println(r.direction);
}


void bugs(PVector t) {

  for (int i = 0; i < bugs.length ; i++) {

    bugs[i].update(bugs, t);  
    bugs[i].checkEdges();  
    bugs[i].display();
  }
}

void stop()
{
  // always close Minim audio classes when you are done with them
  corujaSound.close();
  birdSound.close();
  rabbitSound.close();
  squirrelSound.close();
  player.close();
  minim.stop();

  super.stop();
}

