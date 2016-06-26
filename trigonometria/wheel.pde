
float dotSize = 4.0;

void setup() {
  size(600,600);
}

void draw() {
  background(255,255,255);
  float diameter = min(width,height)/1.6;
  float radius   = diameter/2.0;
  float r = radius/2.0;
  float theta = frameCount/60.0;

  pushMatrix();
  translate(width/2.0,height/2.0);
  
  drawCircle(radius);
  crossHairs(1.5*radius);
  fill(0,0);
  stroke(0,0,0);
  ellipse(0,0,radius,3.0*radius);
  ellipse(0,0,3.0*radius,radius);
  ellipse(0,0,radius,radius);
  
  pushMatrix();
  rotate(PI/4.0);
  ellipse(0,0,radius,3.0*radius);
  ellipse(0,0,3.0*radius,radius);
  popMatrix();
  
  rotate(theta);
  translate(r,0);
  rotate(-2.0*theta);
  drawCircle(r);
  crossHairs(2.0*r);
  
  popMatrix();
}

void drawCircle(float r) {
  fill(255,0);
  stroke(0,0,0);
  
  ellipse(0,0,2.0*r,2.0*r);
  
  fill(0,0,0);
  ellipse(0,r,dotSize,dotSize);
  ellipse(r,0,dotSize,dotSize);
  ellipse(0,-r,dotSize,dotSize);
  ellipse(-r,0,dotSize,dotSize);
  ellipse(0,0,dotSize,dotSize);
}

void crossHairs(float size) {
  fill(0,0,0);
  stroke(0,0,0);
  line(-size,0,size,0);
  line(0,-size,0,size);
  ellipse(0,size,dotSize,dotSize);
  ellipse(size,0,dotSize,dotSize);
  ellipse(0,-size,dotSize,dotSize);
  ellipse(-size,0,dotSize,dotSize);
}