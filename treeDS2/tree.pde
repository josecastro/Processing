

float widthTronco;
float heightTronco;
float angleTronco;

PFont f;

void drawTree(int n, float h, float angle) {
  if (n > 0) {
    pushMatrix();
    line(0, 0, h, 0);
    translate(h, 0);
    rotate(-angle/2);
    drawTree(n-1, h*heightTronco, angle*angleTronco);
    rotate(angle);
    drawTree(n-1, h*heightTronco, angle*angleTronco);
    popMatrix();
  }
}

void setup() {
  size(1200, 600);
  f = createFont("Arial",35,true);
}

void draw() {
  background(255,255,255);
  float len = map(mouseX,0,width,0,PI);
  float ang = map(mouseY,0,height,0,PI);
  fill(0,0,0);
  text("len = "+len+", ang = PI*"+ang/PI,20,20);
  
  angleTronco = 1.0;
  heightTronco = 1.0;
  int iters = 12;
  translate(width/2, height/2);
  rotate(-PI/2.0);
  strokeWeight(1);
  drawTree(iters, len*50, ang);
  stroke(0,0,0);
}