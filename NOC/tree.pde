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
//  rect(x, y, w, h);
// fill(255,0,0);
// ellipse(x3, y2, 30,30);
}


}

