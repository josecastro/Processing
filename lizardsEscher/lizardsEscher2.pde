float hexagonSize;
float distY;
float distX;

public static final int tNONE = 0;
public static final int tPOINT = 1;
public static final int tLINE  = 2;

int direction = 1;

boolean change;
boolean dragging;
boolean referenceFrame;
int xOffset;
int yOffset;
float dx, dy;

// implements a hexagonal based tile for
// the tesselation
class HexagonTile {
  ArrayList<PVector>[] line; // Array of lists of points, each list is one side of the hexagon
  PVector reference[];       // Vertices of the Hexagon, these are used to maintain symetry
  float radius;              // distance from center to each vertex
  float rotation;            // Rotation necessary to create symetries between sides
  PShape s;                  // precalculated shape of tile
  int selectionSegment;      // index of side of hexagon where candidate for selection (movement) is
  int selectionPoint;        // index of point where cadidate line/point is within side
  int selectionType;         // type of selection, could be tNONE, tPOINT or tLINE
  PVector candidatePoint;    // new point position, if we decide to create one
  PVector mirrorPoint;

  boolean pointSelected() { return selectionType == tPOINT; }

  void deleteSelection() {
    if (selectionType == tNONE) return; // nothing to do here
    if ((selectionType == tPOINT) && (selectionPoint == 0)) return; // ditto
    
    if (selectionType == tPOINT) {
      line[selectionSegment].remove(selectionPoint);
      if (selectionSegment % 2 == 0) 
        line[selectionSegment+1].remove(line[selectionSegment+1].size()-1-selectionPoint);
      else
        line[selectionSegment-1].remove(line[selectionSegment-1].size()-1-selectionPoint);
    }
  }

  // used when mouse button is pressed
  // current selected point moved until mouse button is released
  // if a line has been selected, we split it and add a point in in between
  // that corresponds to candidatePoint above
  
  void getOrCreatePoint() {
    if (selectionType == tNONE) return; // nothing to do here
    if ((selectionType == tPOINT) && (selectionPoint == 0)) return; // ditto
    if (selectionType == tLINE) {
      line[selectionSegment].add(selectionPoint+1, candidatePoint);

      mirrorPoint = new PVector(candidatePoint.x,candidatePoint.y);
      if (selectionSegment % 2 == 0) {
        rotatePoint(mirrorPoint,reference[selectionSegment/2],rotation);
        line[selectionSegment+1].add(line[selectionSegment+1].size()-1-selectionPoint,mirrorPoint);
      } else {
        rotatePoint(mirrorPoint,reference[selectionSegment/2],-rotation);
        line[selectionSegment-1].add(line[selectionSegment-1].size()-1-selectionPoint,mirrorPoint);
      }

      selectionType = tPOINT;
      selectionPoint++;
    }
    if (selectionType == tPOINT) {
      if (selectionSegment % 2 == 0) {
        mirrorPoint = line[selectionSegment+1].get(line[selectionSegment+1].size()-1-selectionPoint);
      } else {
        mirrorPoint = line[selectionSegment-1].get(line[selectionSegment-1].size()-1-selectionPoint);
      }
    }
  }

  // called when mouse is moved
  // the point is shifted
  void shiftPoint(float dx, float dy) {
    line[selectionSegment].get(selectionPoint).add(dx, dy);
    if (selectionPoint > 0) {
      PVector rotationDx = new PVector(dx,dy);
      if (selectionSegment % 2 == 0) 
        rotationDx.rotate(rotation);
      else
        rotationDx.rotate(-rotation);
      mirrorPoint.add(rotationDx.x, rotationDx.y);
    }
      
  }

  // Highlights currently selected item
  // be it a line or a point
  void drawSelection() {
    PVector p1;
    PVector p2;

    switch (selectionType) {
    case tPOINT :
      p1 = line[selectionSegment].get(selectionPoint);
      ellipse(p1.x, p1.y, 3.0, 3.0);
      break;
    case tLINE:
      p1 = line[selectionSegment].get(selectionPoint);
      p2 = line[selectionSegment].get(selectionPoint+1);
      if (p1 != null)
        line(p1.x, p1.y, p2.x, p2.y);
      break;
    }
  }

  // just checks if mouse is over something movable
  boolean selected() { 
    return selectionType != tNONE;
  }

  // I think PVector implements this, have to check
  float distanceToPoint(PVector p1, PVector p2) {
    return PVector.sub(p1, p2).mag();
  }

  // sets the candidatePoint variable with the point 
  // that lies in the intersection of the line that
  // passes through point p and is perpedicularly with the
  // segment (p1,p2)
  PVector setCandidatePoint(PVector p, PVector p1, PVector p2) {
    PVector v1 = PVector.sub(p, p1);
    PVector v2 = PVector.sub(p2, p1);
    float c = PVector.dot(v1, v2)/PVector.dot(v2, v2);

    candidatePoint = PVector.mult(v2, c).add(p1);
    return candidatePoint;
  }

  float distanceToSegment(PVector p, PVector p1, PVector p2) {
    PVector v1 = PVector.sub(p, p1);
    PVector v2 = PVector.sub(p2, p1);
    float c = PVector.dot(v1, v2)/PVector.dot(v2, v2);

    if (c < 0 || c > 1.0) return 1000.0;
    return PVector.sub(v1, v2.mult(c)).mag();
  }

  // calculates the min distance to a point or line
  // in the figure, as a side effects it sets the
  // candidatePoint variable when the selected object is
  // a segment
  float minDistance(float x, float y) {
    PVector p = new PVector(x, y);
    float dist = 5.0;
    selectionType = tNONE;
    for (int i = 0; (i < 6) && (selectionType == tNONE); i++)
      for (int j = 0; (j < line[i].size()-1) && (selectionType == tNONE); j++) {
        float d;
        if (selectionType == tNONE) { 
          d = distanceToPoint(p, line[i].get(j));
          if (d < dist+2) {
            selectionSegment = i;
            selectionPoint   = j;
            selectionType    = tPOINT;
            dist = d;
            break;
          }

          d = distanceToSegment(p, line[i].get(j), line[i].get(j+1));
          if (d < dist) {
            selectionSegment = i;
            selectionPoint   = j;
            selectionType    = tLINE;
            dist = d;
            setCandidatePoint(p, line[i].get(j), line[i].get(j+1));
          }
        }
      }
    return (selectionType != tNONE ? dist : 100000.0);
  }  

  PVector rotatePoint(PVector p, PVector center, float angle) {
    p.sub(center);
    p.rotate(angle);
    p.add(center);
    return p;
  }
  
  // Creates the tile shape based on the points in the figure
  // saves the shape for latter rendering
  PShape createPolygon() {
    PShape prev = s;
    s = createShape();
    s.beginShape();
    for (int i = 0; i < 6; i++)
      for (int j = 0; j < line[i].size()-1; j++) {
        PVector p = line[i].get(j);
        s.vertex(p.x, p.y);
      }

    s.endShape(CLOSE);
    return prev;
  }

  // Tile constructor
  // starts off as a simple hexagon
  HexagonTile(float sz) {
    line = new ArrayList[6];
    reference = new PVector[3];
    radius = sz;

    for (int i = 0; i < 6; i++) {
      float x = cos(direction*i*2*PI/6.0)*sz;
      float y = sin(direction*i*2*PI/6.0)*sz;
      line[i] = new ArrayList<PVector>(); // initialize array
      line[i].add(new PVector(x, y)); // add first point

      x = cos(direction*i*2*PI/3.0+direction*PI/3.0)*sz;
      y = sin(direction*i*2*PI/3.0+direction*PI/3.0)*sz;      
    }
    
    for (int i = 0; i < 6; i++)
      line[i].add(line[(i+1)%6].get(0));

    for (int i = 0; i < 3; i++) {
      PVector p = line[2*i+1].get(0);
      reference[i] = new PVector(p.x,p.y);
    }
    
    rotation = direction*(PI+PI/3.0);
    createPolygon();
    
    // initiaize to nothing
    selectionSegment = -1;
    selectionPoint   = -1;
    selectionType    = tNONE;
  }

  void draw() { shape(s); }
}

float drawScale;
HexagonTile lizard;
HexagonTile hexagon;

void setup() {
  float angle = direction*PI/6.0; // hexagon angle for points
  size(600, 600);
  background(255, 255, 255);
  // reasonable hexagon size
  hexagonSize = min(width, height)/10;
  
  // Y offset of second hexagon
  distY = cos(angle)*hexagonSize;
  distX = 3.0*hexagonSize/2.0;
  drawScale = 2.0;
  change = true;
  dragging = false;
  
  // create displayable tile
  lizard  = new HexagonTile(hexagonSize);
  
  // set transparent reference frame with hexagon variable
  stroke(255,128);
  fill(255,0);
  hexagon = new HexagonTile(hexagonSize);
  
  referenceFrame = true;
}

void draw() {  
  float mx = (mouseX-width/2.0)/drawScale;
  float my = (mouseY-height/2.0)/drawScale;

  translate(width/2, height/2);
  scale(drawScale);

  if (dragging) {
    lizard.shiftPoint(dx, dy);
    lizard.createPolygon();
  }

  if (change || dragging) {
    float angle1 = 0; ;
    float angle2 = direction*2.0*PI/3.0;

    background(255, 255, 255);
    stroke(0, 0, 0);

    int nWidth  = ceil(width/(3.0*hexagonSize*drawScale))+1;
    int nHeight = ceil(height/(2.0*distY*drawScale))+1;

    if (nWidth % 2 != 0) nWidth++;
    if (nHeight % 2 != 0) nHeight++;

    angle1 += direction*(2.0*PI/3.0*nHeight/2);
    angle2 += direction*(2.0*PI/3.0*nHeight/2);

    for (float y = -distY*nHeight; y < distY*nHeight; y+= distY+distY) {
      for (float x = -3.0*hexagonSize*nWidth/2; x < 3.0*hexagonSize*(nWidth/2); x+= 3.0*hexagonSize) {
        lizard.s.setFill(color(0, 128+128*noise(x, y)-64, 0));
        translate(x,y);
        rotate(direction*angle1);
        lizard.draw();
        if (referenceFrame) hexagon.draw();
        rotate(-direction*angle1);
        translate(direction*3.0*hexagonSize/2.0, distY);
        rotate(direction*angle2);
        lizard.draw();
        if (referenceFrame) hexagon.draw();
        rotate(-direction*angle2);
        translate((-x-direction*3.0*hexagonSize/2.0), -y-distY);
      }
      angle1 -= direction*(2.0*PI/3.0);
      angle2 -= direction*(2.0*PI/3.0);
    }
    change = false;
  }

  lizard.drawSelection();
  if (dragging) {
    lizard.shiftPoint(-dx, -dy);
    lizard.createPolygon();
  } else {
    float distance = lizard.minDistance(mx,my);
    if (distance < 5) {
      stroke(255, 255, 255);
      lizard.drawSelection();
      stroke(0, 0, 0);
    }
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  drawScale += 0.01*e;
  change = true;
}

void mousePressed() {
  if (lizard.selected()) {
    change = true;
    lizard.getOrCreatePoint();
    dragging = true;
    dx = 0;
    dy = 0;
    xOffset = mouseX;
    yOffset = mouseY;
  }
}

void mouseDragged() {
  change = true;
  if (dragging) {
    dx = (mouseX - xOffset)/drawScale;
    dy = (mouseY - yOffset)/drawScale;
  } 
}

void mouseReleased() {
  change = true;
  if (dragging) {
    dragging = false;
    lizard.shiftPoint(dx, dy);
    lizard.createPolygon();
  }
  else 
    referenceFrame = !referenceFrame;  
}

void keyPressed() {
  if ((key == 'd' || key == 'D') && lizard.pointSelected()) {
    lizard.deleteSelection();
    lizard.createPolygon();
    change = true;
  }
  if ((key == 'r' || key == 'R') && lizard.pointSelected()) {
    lizard = new HexagonTile(lizard.radius);
    change = true;
  }
}