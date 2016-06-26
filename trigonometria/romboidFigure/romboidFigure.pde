

void setup() {
  //fullScreen();
  size(600, 600);
}

float angle = PI/3.0;
float angleRotate = PI/6;

void romboid(float len1, float len2) {
   line(0,0,len2,len1);
   line(len2,len1,len2+len2,0);
   line(len2+len2,0,len2,-len1);
   line(len2,-len1,0,0);  
}

void draw() {
  float lineLength = min(width, height)/8.2;
  float len1 = lineLength*cos(angle);
  float len2 = lineLength*sin(angle);
  
  background(255,255,255);
  
  pushMatrix();
  translate(width/2.0,height/2.0);

  float iterAngle = PI*((frameCount % 720)/720.0) - PI/2.0;

  for (int i = 0; i < 6; i++) {
    pushMatrix();
    rotate(-2.0*angleRotate*i);
    line(0,0,lineLength,0);
    translate(lineLength,0);
    rotate(-iterAngle);
    romboid(len1,len2);
    translate(len2+len2,0);
    rotate(iterAngle);
    romboid(len2,len1);
    
    translate(len1+len1,0);
    rotate(-iterAngle-3.0*angleRotate);
    line(-lineLength,0,lineLength,0);

    popMatrix();
  }
  
  rotate(angleRotate);
  for (int i = 0; i < 6; i++) {
    pushMatrix();
    rotate(-2.0*angleRotate*i-iterAngle);
    line(0,0,lineLength,0);
    translate(lineLength,0);
    rotate(iterAngle);
    romboid(len1,len2);
    translate(len2+len2,0);
    rotate(-iterAngle);
    romboid(len2,len1);
    
    translate(len1+len1,0);
    rotate(iterAngle+3.0*angleRotate);
    line(-lineLength,0,lineLength,0);
 
    popMatrix();
  }
 
  popMatrix();
}