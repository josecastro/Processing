
static int colorA = 1;
static int colorB = 2;
static int colorC = 3;
static int colorAB= 5;
static int colorAB2=4;

boolean overBox = false;
boolean locked  = false;
float xOffset = 0.0;
float yOffset = 0.0;
float bx = 0.0;
float by = 0.0;
float porcentaje = 61;
float sizeAB;
float A;
float B;
float C;

float minTextAplusBsquared;
float maxTextAplusBsquared;
float minTextAsquared;
float maxTextAsquared;
float minTextBsquared;
float maxTextBsquared;
float minTextCsquared;
float maxTextCsquared;
float minText2AB;
float maxText2AB;
float minText2ABrect;
float maxText2ABrect;
float minText4ABdiv2;
float maxText4ABdiv2;
float minTextAA;
float maxTextAA;
float minTextBB;
float maxTextBB;
float minTextCC;
float maxTextCC;

PFont f;

void setup() {
  size(800,600);
  //fullScreen();
  f = createFont("Arial", 25, true);
  sizeAB = min(width,height)*0.5;
  minTextAplusBsquared = 10;
  maxTextAplusBsquared = minTextAplusBsquared+textWidth("(A+B)^2");
  minTextAsquared = maxTextAplusBsquared+textWidth(" = ");
  maxTextAsquared = minTextAsquared+textWidth("A^2");
  minTextBsquared = maxTextAsquared+textWidth("+");
  maxTextBsquared = minTextBsquared+textWidth("B^2");
  minText2AB = maxTextBsquared+textWidth("+");
  maxText2AB = minText2AB+textWidth("2AB");
  minTextCsquared = maxText2AB+textWidth(" = ");
  maxTextCsquared = minTextCsquared+textWidth("C^2");
  minText4ABdiv2 = maxTextCsquared+textWidth("+");
  maxText4ABdiv2 = minText4ABdiv2+textWidth("4(AB/2)");
  minText2ABrect = minText4ABdiv2+textWidth("4");
  maxText2ABrect = minText2ABrect+textWidth("2AB");
  minTextAA = maxText4ABdiv2+textWidth(" => ");
  maxTextAA = minTextAA+textWidth("A^2");
  minTextBB = maxTextAA+textWidth("+");
  maxTextBB = minTextBB+textWidth("B^2");  
  minTextCC = maxTextBB+textWidth(" = ");
  maxTextCC = minTextCC+textWidth("C^2");  
} 

void draw() {
  background(227,228,246);
  stroke(0,0,0);

  A = sizeAB * (porcentaje/100.0);
  B = sizeAB * (100-porcentaje)/100.0;

  if (locked) {
    A += bx;
    B -= bx;
  }

  C = sqrt(A*A+B*B);

  float translateX = (width-sizeAB)*0.7;
  float translateY = (height-sizeAB)*0.9;
  if (mouseX > -B+translateX && mouseX < A+translateX && 
      mouseY > -A+translateY && mouseY < B+translateY) 
    overBox = true;
  else
    overBox = false;
    
  stroke(0);
  fill(0);
  text("(A+B)^2 = A^2+B^2+2AB = C^2+4(AB/2) => A^2+B^2 = C^2",minTextAplusBsquared,20);  

  text("| |",minText2ABrect+textWidth(" "),37);
  text("2AB",minText2ABrect,53);

  pushMatrix();
  translate(translateX, translateY);


  setColor(colorA); rect(0,-A,A,A);
  setColor(colorB); rect(-B,0,B,B);
  setColor(colorAB);rect(-B,-A,B,A);
  
  pushMatrix();
  translate(0,B);
  rotate(-atan(B/A));
  setColor(colorC);
  rect(0,0,C,C);
  popMatrix();
  
  pushMatrix();
  line(0,B,A,B);
  line(A,B,A,0);

  for (int i = 0; i < 4; i++) {
    setColor(colorAB2);
    triangle(0,0,A,0,0,B);
    
    translate(A+B,0);
    rotate(PI/2.0);
  }
  popMatrix();
  
  line(-B,0,-B,-A);
  line(-B,-A,0,-A);
  
  if (overBox) {
    if (locked)
      stroke(128);
    else
      stroke(255);
    fill(255,64);
    fill(255,64);
    rect(-B,-A,A+B,A+B);
  }
  
  stroke(0,0,0);
  fill(0,0,0);
  text("C^2", (A+B)/2.0-10,(A+B)/2.0);
  text("A^2", A/2.0-10, -A/2.0);
  text("B^2", -B/2-10, B/2);
  text("AxB", -B/2-10, -A/2.0);
  text("AB/2",10,17);
  text("AB/2",10,A+B-10);
  text("AB/2",A+B-36,A+B-10);
  text("AB/2",A+B-36,17);
  text("AB/2",A-37,B-12);
  
  text("+",-5,-A-16);
  text("B",-B/2.0-5,-A-16);
  text("A",A/2.0-5,-A-16);

  text("+",-B-30,3);
  text("A",-B-30,-A/2.0);
  text("B",-B-30,B/2.0);
  
  text("+",A+B+15,A+3);
  text("A",A+B+15,A/2.0);
  text("B",A+B+15,A+B/2.0);

  int offs1 = 8;
  int offs2 = 21;
  text("+",B-6,A+B+offs2);
  text("B",B/2.0,A+B+offs2);
  text("A",B+A/2.0,A+B+offs2);

  arrow(0,-A-10, 0, A);
  arrow(0,-A-10,PI, B);
  arrow(-B-12,0,-PI/2.0,A);
  arrow(-B-12,0,PI/2.0,B);
  arrow(A+B+10,A,-PI/2.0,A);
  arrow(A+B+10,A,PI/2.0,B);
  arrow(B,A+B+offs1,0,A);
  arrow(B,A+B+offs1,PI,B);

  if (mouseY > 10 && mouseY < 25) {
    if (mouseX > minTextAplusBsquared && mouseX < maxTextAplusBsquared) 
        drawAplusBsquare();
      
    if (mouseX > minTextAsquared && mouseX < maxTextAsquared)
        drawAxAsquare();

    if (mouseX > minTextBsquared && mouseX < maxTextBsquared)
        drawBxBsquare();

    if (mouseX > minText2AB && mouseX < maxText2AB) 
        draw2AxBrectangles();
      
    if (mouseX > minTextCsquared && mouseX < maxTextCsquared) 
      drawCxCsquare();
      
    if (mouseX > minText4ABdiv2 && mouseX < maxText4ABdiv2) 
      draw4AxBdiv2triangles();
      
    if (mouseX > minTextAA && mouseX < maxTextAA) 
      drawAxAsquare();
      
    if (mouseX > minTextBB && mouseX < maxTextBB) 
      drawBxBsquare();
      
    if (mouseX > minTextCC && mouseX < maxTextCC) 
      drawCxCsquare();
  }
  if (mouseX > minText2ABrect && mouseX < maxText2ABrect && mouseY > 40 && mouseY < 70) {
    draw2AxBrectangles();
    line(-B,0,0,-A);
    line(0,B,A,0);
  }
  
  popMatrix();
}

void mousePressed() {
  locked = overBox;
  if (locked) {
    xOffset = mouseX;
    yOffset = mouseY;
    bx = 0.0;
    by = 0.0;
  }
}

void mouseDragged() {
  if (locked) {
    bx = mouseX - xOffset;
    by = mouseY - yOffset;
  }
}

void mouseReleased() {
  if (locked) {
    locked = false;
    porcentaje = ((sizeAB*porcentaje/100.0+bx)/sizeAB)*100.0;
  }
}

void drawAplusBsquare() {
  stroke(255);
  fill(255,64);
  rect(-B,-A,A+B,A+B);
}

void drawAxAsquare() {
  stroke(255);
  fill(255,64);
  rect(0,-A,A,A);
}

void drawBxBsquare() {
  stroke(255);
  fill(255,64);
  rect(-B,0,B,B);
}

void draw2AxBrectangles() {
  stroke(255);
  fill(255,64);
  rect(-B,-A,B,A);
  rect(0,0,A,B);
}

void drawCxCsquare() {
  pushMatrix();
  translate(0,B);
  rotate(-atan(B/A));
  stroke(255);
  fill(255,64);
  rect(0,0,C,C);
  popMatrix();
}

void draw4AxBdiv2triangles() {
  stroke(255);
  fill(255,64);
  pushMatrix();
  for (int i = 0; i < 4; i++) {
    triangle(0,0,A,0,0,B);
    
    translate(A+B,0);
    rotate(PI/2.0);
  }
  popMatrix();
}

void arrow(float x, float y, float angle, float len) {
  pushMatrix();
  translate(x,y);
  rotate(angle);
  line(0,0,len,0);
  triangle(len,0,len-6,-2,len-6,2);
  triangle(0,0,6,-2,6,2);
  popMatrix();
}

// utility function to put a color
void setColor(int index)
{
  if      (index == 1) fill(202, 96,  96); // red
  else if (index == 2) fill( 90, 64,  98); // cyan
  else if (index == 3) fill( 82, 82, 154); // blue
  else if (index == 4) fill( 60, 93,  60); // green
  else fill(123,117,174);
}