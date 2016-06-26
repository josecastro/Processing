/* 
 (C) Jose Castro 2016. Instituto Tecnologico de Costa Rica

 Basado en:
   http://link.springer.com/chapter/10.1007%2F978-3-540-71027-1_9
   http://www.dcs.bbk.ac.uk/TriStarp/pubs/JL1_00.pdf

 Curva de Hilbert en 3 dimensiones
 1. mapKey, primitiva para mapear un numero binario a un punto en una maya 3D
 que va en orden de los puntos de la curva Hilbert de orden n, con m puntos.
  
 2. setColor: utilitario para cambiar de color
 
 3. generateHibert, funcion principal que genera un
    segmento de la curva
 */

import processing.opengl.*;

PFont f;
float angleX = random(2.0*PI);
float angleY = random(2.0*PI);
float angleZ = random(2.0*PI);

void setup() {
  size(600, 600, P3D);
  //fullScreen(P3D);
  noStroke();
  f = createFont("Arial", 16, true);
  randomSeed(second());
}

float start = 0.0;
float last  = 0.0;

void draw() {
  float time     = millis();
  float distance = min(width,height)/2.0;
  float scale    = distance/6.0;

  if ((time - last) > 500.0) {
    start = time;
    angleX = random(2.0*PI);
    angleY = random(2.0*PI);
    angleZ = random(2.0*PI);
  }

  last = time;
  
  float frame = (time - start) / 5000.0;
  while (frame > 32.0) frame -= 32.0;
  
  background(196, 196, 196);
  lights();

  pushMatrix();    
  translate( width/2.0, height/2.0, -distance*7.0/6.0 );
  rotateX( frame + angleX );
  rotateY( frame + angleY );
  rotateZ( frame + angleZ );
  generateHilbert(10, 1, 0.1+frame/2, scale);
  generateHilbert(10, 2, 0.1+frame/2, scale);
  generateHilbert(10, 3, 0.1+frame/2, scale);
  generateHilbert(10, 4, 0.1+frame/2, scale);
  generateHilbert(10, 5, 0.1+frame/2, scale);
  popMatrix();

  fill(0, 0, 0);
  text("Jose Castro - 3D Hilbert Space Filling Curve " + frame, 10, height - 50);
}

void drawCylinder(int sides, float r, float h)
{
  float angle = 360 / sides;

  sphere(r);

  pushMatrix();
  translate(0, 0, h);
  sphere(r);
  popMatrix();

  // draw sides
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < sides + 1; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, h);
    vertex( x, y, 0);
  }
  endShape(CLOSE);
}

//
// this function generates the Hilbert 3D curve with order of
// approximation m
//
// A nice touch is the clock macro which if you do a sequence
// of frames will make the animation
//
//

int sides = 10;

static int EXTENSION = 8;
static int SIDES = 8;

void generateHilbert(int size, int m, float clock, float scale) // m = order of Hilbert approximation
{
  int duration  = 1 << (m - 1);
  int gradation = 1 << m; // amount of subdivisions on each dimension
  int maxloop = gradation*gradation*gradation; 
  int extension = (m == 5 ? 100 : EXTENSION);

  if (clock <= ((1.0*duration)/maxloop + (duration-1))) return;
  if (clock >= extension + duration + duration-1) return;

  long[] point1  = new long[3]; // 3D Hilbert Curve
  long[] point2  = new long[3]; 
  long[] key     = new long[m];
  int rho_iSize = 1 << 3; // 3 Dimensional data

  // gradation^3, 3D data
  // this is the amount of vertices in the Hilbert curve
  //

  // meassure and offset are needed to graph the stuf
  // the unit cube
  float meassure = (size * 1.0) / gradation;
  float offset   = -((int)size)*0.5 + meassure * 0.5;

  int i;
  int j;
  // int sides = 8; // 
  float width = 0.05 / m;
  Boolean firstime = true;

  for (j = 0; j < m; ++j) key[j] = 0;
  mapKey(key, 3, m, point1);

  setColor(m);

  for (i = 1; i < maxloop; ++i) {
    if ((clock > ((i*1.0*duration)/maxloop + (duration-1))) && (clock < extension + (i*1.0*duration)/maxloop + (duration-1))) {

      int val = i;
      for (j = 0; j < m; ++j) {
        key[m-1-j] = val % rho_iSize;
        val /= rho_iSize;
      }
      mapKey(key, 3, m, point2);

      if (firstime) {
        val = i-1;
        for (j = 0; j < m; ++j) {
          key[m-1-j] = val % rho_iSize;
          val /= rho_iSize;
        }
        mapKey(key, 3, m, point1);
        firstime = false;
      }

      pushMatrix();
      translate(scale*(point1[0]*meassure+offset), scale*(point1[1]*meassure+offset), scale*(point1[2]*meassure+offset));

      if (point1[2] > point2[2])
        // glRotated(180, 1, 0, 0);
        rotateX(PI);
      else
        if (point1[2] == point2[2])
          if (point1[1] != point2[1])
            // glRotated(90*(point1[1]-point2[1]), 1, 0, 0);
            rotateX((point1[1]-point2[1])*PI*0.5);
          else
            // glRotated(90*(point2[0]-point1[0]), 0, 1, 0);
            rotateY((point2[0]-point1[0])*PI*0.5);

      if (clock >= extension + ((i-1)*1.0*duration)/maxloop+(duration-1)) {
        pushMatrix();
        float clck = clock - extension;

        translate(0, 0, scale*meassure*(clck-(((i-1)*1.0*duration)/maxloop + (duration-1)))*maxloop/duration);

        sphere(size*width*scale);

        // gluCylinder(cylinder, size*width, size*width, meassure-meassure*(clck-(((i-1)*1.0*duration)/maxloop + (duration-1)))*maxloop/duration, sides, sides);
        drawCylinder(20, size*width*scale, scale*(meassure-meassure*(clck-(((i-1)*1.0*duration)/maxloop + (duration-1)))*maxloop/duration));
        popMatrix();
      } else {
        sphere(size*width*scale);

        if (clock > (((i+1)*1.0*duration)/maxloop + (duration-1))) {
          // gluCylinder( cylinder, size*width, size*width, meassure, sides, sides);
          drawCylinder(20, size*width*scale, scale*meassure);
        } else {
          pushMatrix();

          //gluCylinder(cylinder, size*width, size*width, meassure*(clock-((i*1.0*duration)/maxloop + (duration-1)))*maxloop/duration, sides, sides);
          drawCylinder(20, size*width*scale, scale*meassure*(clock-((i*1.0*duration)/maxloop + (duration-1)))*maxloop/duration);

          translate(0, 0, scale*meassure*(clock-((i*1.0*duration)/maxloop + (duration-1)))*maxloop/duration);

          sphere(size*width*scale);
          popMatrix();
        }
      }

      popMatrix();

      point1[0] = point2[0];
      point1[1] = point2[1];
      point1[2] = point2[2];
    }
  }

  if ((clock >  (duration + duration-1)) &&
    (clock < (duration + duration-1+extension)))
  {
    int val = maxloop;
    for (j = 0; j < m; ++j)
    {
      key[m-1-j] = val % rho_iSize;
      val /= rho_iSize;
    }
    mapKey(key, 3, m, point2);

    val = maxloop-1;
    for (j = 0; j < m; ++j)
    {
      key[m-1-j] = val % rho_iSize;
      val /= rho_iSize;
    }
    mapKey(key, 3, m, point1);

    pushMatrix();
    translate(scale*(point1[0]*meassure+offset), scale*(point1[1]*meassure+offset), scale*(point1[2]*meassure+offset));
    if (point1[2] > point2[2])
      // glRotated(180, 1, 0, 0);
      rotateX(PI);
    else
      if (point1[2] == point2[2])
        if (point1[1] != point2[1])
          // glRotated(90*(point1[1]-point2[1]), 1, 0, 0);
          rotateX(0.5*PI*(point1[1]-point2[1]));
        else
          // rotate(90*(point2[0]-point1[0]), 0, 1, 0);
          rotateY(0.5*PI*(point2[0]-point1[0]));

    sphere(size*width*scale);
    popMatrix();
  }

  return;
}

// Reference : http://www.dcs.bbk.ac.uk/TriStarp/pubs/JL1_00.pdf
long[] mapKey(long key[], long n, long m, long coord[])
{
  long ai;
  long rho_i;
  long Ji;
  long Oi;
  long Pi;
  long Jsum = 0;
  long Oi_bar;
  long Pi_bar = 0;
  long wi = 0;
  long mask = (1 << (m-1));

  int i;
  for (i = 0; i < n; ++i) { 
    coord[i] = 0;
  }

  for (i = 0; i < m; ++i)
  {
    // get the rho of the current iteration
    rho_i = key[i];

    // principal position calculation
    Ji = n;
    int j;
    for (j = 1; j < n; ++j)
      if ((rho_i >> j & 1) == (rho_i & 1))
        continue;
      else
        break;
    if (j != n)
      Ji -= j;

    Oi = rho_i ^ (rho_i / 2);

    if (rho_i < 3)
      Pi = 0;
    else
      if ((rho_i % 2) != 0)
        Pi = (rho_i-1) ^ ((rho_i-1)/2);
      else
        Pi = (rho_i-2) ^ ((rho_i-2)/2);

    wi = wi ^ Pi_bar;

    if (Jsum % n == 0)
    {
      Oi_bar = Oi;
      Pi_bar = Pi;
    } else
    {
      long temp1 = Oi >> (Jsum % n);
      long temp2 = Oi << (n - (Jsum % n));
      Oi_bar  = temp2 | temp1;
      Oi_bar &=((long)1 << n) - 1;

      temp1   = Pi >> (Jsum % n);
      temp2   = Pi << (n - (Jsum % n));
      Pi_bar  = temp1 | temp2;
      Pi_bar &=((long)1 << n) - 1;
    }
    Jsum += Ji - 1;
    ai = wi ^ Oi_bar;

    long maskt = 1 << (n-1);

    for (j = 0; j < n; ++j)
    {
      if ((ai & maskt) != 0)
        coord[j] |= mask;
      maskt >>= 1;
    }
    mask >>= 1;
  }
  return coord;
}

// utility function to put a color
void setColor(int index)
{
  if (index == 1)
    fill(209, 70, 70); // red
  else if (index == 2)
    fill(108, 60, 124); // cyan
  else if (index == 3)
    fill(94, 94, 156); // blue
  else if (index == 4)
    fill(42, 119, 47); // green
  else fill(240,215,73);
}