int circuitSize = 32; // power of 2
float stepY;
float[] stepX;
int[][] v;
float deltaX;
int numSteps;
int boxSize;
int comparatorRadius;
PFont f;
float xOffset;
float maxX;
float minX;

ArrayList<comparator>[] comparatorList;

int log2(int n) {
  if (n == 1) return 0;
  else return 1+log2(n / 2);
}

int pow2(int n) {
  if (n == 0) return 1;
  else return 2*pow2(n-1);
}

// invert n bits of val(ue) into accum(ulator)
int invertBits(int n, int val, int accum) {
  if (n == 0)
    return accum;
  else {
    return invertBits(n-1, val/2, accum*2+(val % 2));
  }
}

abstract class widget {
  float x;
  float y;
  abstract void draw();
};

class comparator extends widget {
  float radius;
  int step;
  int i;
  int j;
  boolean ascending;
  float posy1;
  float posy2;
  float x1;
  float x2;
        
  comparator(int _step, boolean _ascending, int _i, int _j) {
    i = _i;
    j = _j;
    step = _step;
    radius = comparatorRadius;
    ascending = _ascending;
    posy1 = i*stepY+stepY*.25+boxSize/2;
    posy2 = j*stepY+stepY*.25+boxSize/2;
    x1 = stepX[step]+boxSize/2;
    x2 = stepX[step+1]+boxSize/2;        
  }

  void draw() {
    float posy1 = i*stepY+stepY*.25+boxSize/2;
    float posy2 = j*stepY+stepY*.25+boxSize/2;
    float x1 = stepX[step]+boxSize/2;
    float x2 = stepX[step+1]+boxSize/2;
    
    line(x1,posy1,x2,posy2);
    line(x1,posy2,x2,posy1);

    x = (stepX[step]+stepX[step+1])/2 + boxSize/2;
    y = (posy1+posy2)/2;
    
    fill(255);
    stroke(0);
    ellipse(x, y, radius, radius);
    
    fill(0);
    if (ascending) 
      text("+", x-5, y+4);
    else
      text("-", x-3, y+4);    
  }
  
  void drawNumber(float xPos) {
    if (xPos >= x1 && xPos < x2) {
      int posMax = (ascending ? j : i);
      int posMin = (ascending ? i : j);
      int valMax = max(v[step][i],v[step][j]);
      int valMin = min(v[step][i],v[step][j]);
      v[step+1][posMax] = valMax;
      v[step+1][posMin] = valMin;
      
      //int xOffset = -12;
      //int yOffset = 4;
      
      float time = (xPos - x1) / (x2 - x1);
      
      if (time < 0.5) {
        float xText = time*(x2-x1) + x1;
        float y1 = time*(posy2-posy1)+posy1;
        float y2 = time*(posy1-posy2)+posy2;
        fill(255-v[step][i],v[step][i],min(v[step][i],255-v[step][i]));
        ellipse(xText,y1,15,15);
        // text(v[step][i],xText+xOffset,y1+yOffset);
        fill(255-v[step][j],v[step][j],min(v[step][j],255-v[step][j]));
        ellipse(xText,y2,15,15);
        //text(v[step][j],xText+xOffset,y2+yOffset);
      } else {
        float xText = time*(x2-x1) + x1;
        float y1 = time*(posy2-posy1)+posy1;
        float y2 = time*(posy1-posy2)+posy2;
        fill(255-v[step+1][j],v[step+1][j],min(v[step+1][j],255-v[step+1][j]));
        ellipse(xText,y1,15,15);
        //text(v[step+1][j],xText+xOffset,y1+yOffset);
        fill(255-v[step+1][i],v[step+1][i],min(v[step+1][i],255-v[step+1][i]));
        ellipse(xText,y2,15,15);
        //text(v[step+1][i],xText+xOffset,y2+yOffset);
      }
    }
  }
}

void compare(int step, boolean ascending, int i, int j) {
  comparatorList[step].add(new comparator(step, ascending, i, j));
}

int bitonicSortBlock(int step, boolean ascending, int blockStart, int blockSize) {
  if (blockSize == 1) return step;
  int midSize = blockSize / 2;
  for (int i = 0; i < midSize; i++) {
    compare(step, ascending, i+blockStart, i+blockStart+midSize);
  }
  bitonicSortBlock(step+1, ascending, blockStart, midSize);
  return bitonicSortBlock(step+1,ascending, blockStart+midSize, midSize);
}

void bitonicSortCircuit(int length) {
  int step = 0;
  for (int blockSize = 2; blockSize <= length; blockSize *= 2) {
    boolean ascending = true;
    int nextStep = 0;

    for (int blockStart = 0; blockStart < length; blockStart += blockSize) {
      nextStep = bitonicSortBlock(step, ascending, blockStart, blockSize);
      ascending = !ascending;
    }
    step = nextStep;
  }
}

void printVector(int[] v) {
  for (int i = 0; i < v.length; i++)
    print(" "+v[i]);
  println("");
}

boolean change;

void setup() {
  size(1200, 780);  

  f = createFont("Arial", 18, true);
  // Calculate number of offset in X coordinate
  // formula is \sum_{i=0}ˆlog2(circuitSize)-1 (\sum_{j=0}ˆî 2ˆj)
  // result in numStepsX variable;
  int log2Size = log2(circuitSize);
  int numStepsX = circuitSize*2 - 2 - log2Size;
  numSteps = (log2Size*(log2Size+1))/2+1;
  
  boxSize = 10;
  comparatorRadius = 15;

  v = new int[numSteps][circuitSize];

  stepY = height*1.0/(circuitSize+1);
  deltaX = width*1.0/(numStepsX+1);

  int currentStep = 1;
  stepX = new float[numSteps];
  stepX[0] = (deltaX-boxSize)/2;

  for (int offset = 1; offset < circuitSize; offset += offset) {
    for (int nOffset = offset; nOffset > 0; nOffset /= 2) {
      stepX[currentStep] = stepX[currentStep-1] + deltaX*nOffset;
      currentStep += 1;
    }
  }

  comparatorList = new ArrayList[numSteps];
  for (int i = 0; i < numSteps; i++)
    comparatorList[i] = new ArrayList<comparator>();
  
  ArrayList l = new ArrayList();
  
  for (int i = 0; i < circuitSize; i++)
    l.add((i*256)/(circuitSize-1));
  java.util.Collections.shuffle(l);
  for(int i = 0; i < circuitSize; i++)
    v[0][i] = (int)l.get(i);

  bitonicSortCircuit(circuitSize);

  change = true;
  frameRate(25);
  
  minX = comparatorList[0].get(0).x1;
  maxX = comparatorList[numSteps-2].get(0).x2-1;

  // start at the first level
  xOffset = comparatorList[0].get(0).x1;  
}

void draw() {
  if (change) {
    background(229,228,212);
    //background(213,214,244);
    stroke(0,0,0);
    for (int i = 0; i < numSteps; i++)
      for (comparator c : comparatorList[i])
        c.draw();
        
    fill(255);
    stroke(0);
    for (int i = 0; i < numSteps; i++) {
      for (int j = 0; j < circuitSize; j++)
        rect(stepX[i], j*stepY+stepY*.25, boxSize, boxSize);
    }
    
    stroke(0,0,0);
    fill(0,128,0);
    for (int i = 0; i < numSteps; i++)
      for (comparator c : comparatorList[i])
        c.drawNumber(xOffset);    

    change = false;
    stroke(0);
    fill(0);

    //float xpos = comparatorList[numSteps-log2(circuitSize)-1].get(0).x-textWidth("Bitonic Sort Circuit")/2;
    //text("Bitonic Sort Circuit", xpos, 50);

  }
}


void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  xOffset += e;
  if (xOffset < minX) xOffset = minX;
  if (xOffset > maxX) xOffset = maxX;
  change = true;
}