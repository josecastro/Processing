// Jose Castro, clase 3.

boolean overTree;
boolean redrawTree;

class Node {
  PVector pos;
  PVector pos0;
  PVector posDad;
  
  Node izq, der;

  Node(int iter, float dadx, float dady, float x, float y, float len, float baseAngle, float angle, float lf, float af) {
    pos  = new PVector(x,y);
    pos0 = new PVector(x,y);
    posDad = new PVector(dadx,dady);
    
    if (iter == 0) {
      izq = null;
      der = null;
    }
    else {
      float dx = cos(baseAngle+angle)*len;
      float dy = sin(baseAngle+angle)*len;
      izq = new Node(iter-1, x, y, x+dx, y+dy, len*lf, baseAngle+angle, angle*af,lf,af);
      dx = cos(baseAngle-angle)*len;
      dy = sin(baseAngle-angle)*len;
      der = new Node(iter-1, x, y, x+dx, y+dy, len*lf, baseAngle-angle, angle*af,lf,af);
    }
  }
  
  void reset(float x, float y, float len, float baseAngle, float angle, float lf, float af) {
    pos.x  = x; pos.y  = y;
    pos0.x = x; pos0.y = y;
    if (izq != null) {
      float dx = cos(baseAngle+angle)*len;
      float dy = sin(baseAngle+angle)*len;
      izq.reset(x+dx, y+dy, len*lf, baseAngle+angle, angle*af,lf,af);
    }
    if (der != null) {
      float dx = cos(baseAngle-angle)*len;
      float dy = sin(baseAngle-angle)*len;
      der.reset(x+dx, y+dy, len*lf, baseAngle-angle, angle*af,lf,af);
    }
  }
  
  void draw() {
    if (izq != null && der != null) {
      stroke(0);
      line(pos.x,pos.y,izq.pos.x,izq.pos.y);
      line(pos.x,pos.y,der.pos.x,der.pos.y);
      izq.draw();
      der.draw();
    } else {
      fill(32,255,32,128);
      ellipse(pos.x,pos.y,10,10);
    }
  }
  
  void move(float distance, float x, float y) {
    float dist = sqrt((mouseX - pos.x)*(mouseX - pos.x) + (mouseY-pos.y)*(mouseY-pos.y));
    posDad.x = x;
    posDad.y = y;
    
    if (dist < distance && overTree) {
      pos.x += (mouseX - pos.x)/350.0;
      pos.y += (mouseY - pos.y)/350.0;
    } else if (overTree && izq != null && der != null) {
      float x2 = (posDad.x + izq.pos.x + der.pos.x) / 3.0;
      float y2 = (posDad.y + izq.pos.y + der.pos.y) / 3.0;
      pos.x += (x2 - pos.x)/350.0;
      pos.y += (y2 - pos.y)/350.0;
    } else {
      pos.x += (pos0.x - pos.x)/350.0;
      pos.y += (pos0.y - pos.y)/350.0;
    }
    if (izq != null) izq.move(distance,pos.x,pos.y);
    if (der != null) der.move(distance,pos.x,pos.y);
  }
}

Node n;

float len;
float lenFactor = 1.0;
float angleFactor = 1.0;
float startAngle = PI*0.10;
float baseAngle = -PI/2.0;
int iters = 10;

void setup() {
  size(600,600);
  len = 25.0;
  n = new Node(iters,width/2.0, height/2.0+len, width/2.0,height/2.0, len, baseAngle, startAngle,lenFactor,angleFactor);
  overTree = false;
  redrawTree = false;
}

void draw() {
  background(255,255,255);
  
  overTree = (mouseX > 5 && mouseX < width-5 && mouseY > 5 && mouseY < height-5);

  if (!redrawTree) 
    n.move(100,width/2.0,height/2.0+len);
  else {
    len = map(mouseY,0,height,0,PI)*50;
    startAngle = map(mouseX,0,width,0,PI);
    n.reset(width/2.0,height/2.0,len,baseAngle,startAngle,lenFactor,angleFactor);
  }
  line(n.pos.x,n.pos.y,n.pos0.x,n.pos0.y+len);

  n.draw();
}

void mousePressed() {
  redrawTree = overTree;
}

void mouseReleased() {
  redrawTree = false;
}