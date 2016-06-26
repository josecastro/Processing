// Jose Castro, clase 3.


class Node {
  PVector pos;
  PVector pos0;
  Node izq, der;
  float strokeWidth;

  Node(int iter, float x, float y, float len, float baseAngle, float angle, float lf, float af, float sw) {
    pos  = new PVector(x,y);
    pos0 = new PVector(x,y);
    strokeWidth = sw;
    if (iter == 0) {
      izq = null;
      der = null;
    }
    else {
      float dx = cos(baseAngle+angle)*len;
      float dy = sin(baseAngle+angle)*len;
      izq = new Node(iter-1, x+dx, y+dy, len*lf, baseAngle+angle, angle*af,lf,af,sw*cos(angle));
      dx = cos(baseAngle-angle)*len;
      dy = sin(baseAngle-angle)*len;
      der = new Node(iter-1, x+dx, y+dy, len*lf, baseAngle-angle, angle*af,lf,af,sw*cos(angle));
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
    strokeWeight(strokeWidth);
    if (izq != null) {
      line(pos.x,pos.y,izq.pos.x,izq.pos.y);
      izq.draw();
    }
    strokeWeight(strokeWidth);
    if (der != null) {
      line(pos.x,pos.y,der.pos.x,der.pos.y);
      der.draw();
    }
  }
  
  void move(float distance) {
    float dist = sqrt((mouseX - pos.x)*(mouseX - pos.x) + (mouseY-pos.y)*(mouseY-pos.y));
    
    if (dist < distance) {
      pos.x += (mouseX - pos.x)/350.0;
      pos.y += (mouseY - pos.y)/350.0;
    } else {
      pos.x += (pos0.x - pos.x)/350.0;
      pos.y += (pos0.y - pos.y)/350.0;
    }
    if (izq != null) izq.move(distance);
    if (der != null) der.move(distance);
  }
}

Node n;
float lenFactor; 
float angleFactor;
float startAngle;
float stroke_width;
float len;
float baseAngle;
float angle;

void setup() {
  size(600,600);
  len = 109.0;
  lenFactor = 0.7;
  angleFactor = 0.8;
  startAngle = -PI/2.0;
  stroke_width = 1.0;
  strokeWeight(stroke_width);
  baseAngle = -1.5;
  angle = PI/3.5;
  n = new Node(9,width/2.0,height/2.0, len, -PI/2.0, PI/2.9,lenFactor,angleFactor,8*cos(angle));
}

void draw() {
  background(255,255,255);
  strokeWeight(stroke_width);
  
  //n.reset(width/2.0,height/2.0,len,baseAngle,angle,lenFactor,angleFactor);
  
  n.move(100);
  strokeWeight(8.0);
  line(n.pos.x,n.pos.y,n.pos0.x,n.pos0.y+2.0*len);
  n.draw();
}