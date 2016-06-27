int circuitSize = 32; // power of 2
int numSteps;
int sumSteps;
int[] maxStep;

float stepY;
float stepX;
float xOffset;
float minX;
float maxX;

ArrayList<comparator>[] comparatorList;
int[] reorder;
int[][] v;

boolean changed;
int boxSize;
int comparatorRadius;

class comparator {
  int i;
  int j;
  int pos;
  int step;
  float posY1;
  float posY2;
  float posY3;
  float m1;
  float m2;
  float xComparator;
  float yComparator;
  float posX0; // x position of start of box
  float posX1; // x position of start of line slanted
  float posXLine1; // x position of start straight line
  float posXLine2;
  float posXComparator; // x position of start of comparator;
  float posX2; // x position of end of comparator area
  boolean reshuffle;
  
  // reShuffleStep = -1 => dont use reshuffle for comparator, just the step
  // otherwise use reshuffled step
  comparator(int _step, int _i, int _j, int _pos, boolean reshuffled) {
    i = _i;
    j = _j;
    step = _step;
    pos = _pos;
    reshuffle = reshuffled; // indicates if we are inverting bits, used only for display purposes
  }
  void run() {
    v[step+1][pos] = min(v[step][i],v[step][j]);
    v[step+1][pos+1] = max(v[step][i],v[step][j]);
  }
  int maxStep() {
    return max(abs(i-pos),abs(j-(pos+1)));
  }
  void drawLines() {
    line(posX1,posY1,posXLine1,posY3);
    line(posXLine1,posY3,posXComparator,posY3);
    line(posXComparator,posY3,posX2,posY3+stepY);
    
    line(posX1,posY2,posXLine2,posY3+stepY);
    line(posXLine2,posY3+stepY,posXComparator,posY3+stepY);
    line(posXComparator,posY3+stepY,posX2,posY3);

    rect(posX1-boxSize, posY1-boxSize/2, boxSize, boxSize);
    rect(posX1-boxSize, posY2-boxSize/2, boxSize, boxSize);  
  }
  
  void drawData(float xOffset) { // draw circle 
        if (xOffset >= posX0 && xOffset < posX1) {
          setColor(v[step][i]);
          ellipse(xOffset,(i+1)*stepY,comparatorRadius,comparatorRadius);
          setColor(v[step][j]);
          ellipse(xOffset,(j+1)*stepY,comparatorRadius,comparatorRadius);
        } else if (xOffset >= posXComparator && xOffset < xComparator) {
          setColor(v[step][i]);
          float y = stepY/stepX*(xOffset-posXComparator) + posY3;
          ellipse(xOffset,y,comparatorRadius,comparatorRadius);
          setColor(v[step][j]);
          y = -stepY/stepX*(xOffset-posXComparator) + posY3+stepY;
          ellipse(xOffset,y,comparatorRadius,comparatorRadius);
        } else if (xOffset >= xComparator && xOffset < posX2) {
          setColor(v[step+1][pos+1]);
          float y = stepY/stepX*(xOffset-posXComparator) + posY3;
          ellipse(xOffset,y,comparatorRadius,comparatorRadius);
          setColor(v[step+1][pos]);
          y = -stepY/stepX*(xOffset-posXComparator) + posY3+stepY;
          ellipse(xOffset,y,comparatorRadius,comparatorRadius);
        } else {
          if (xOffset >= posX1 && xOffset < posXLine1) {
            setColor(v[step][i]);
            float y = m1*(xOffset-posX1) + posY1;
            ellipse(xOffset,y,comparatorRadius,comparatorRadius);
          } else if (xOffset >= posXLine1 && xOffset < posXComparator) {
            setColor(v[step][i]);
            ellipse(xOffset, posY3,comparatorRadius,comparatorRadius);            
          }
          if (xOffset >= posX1 && xOffset < posXLine2) {
            setColor(v[step][j]);
            float y = m2*(xOffset-posX1) + posY2;
            ellipse(xOffset,y,comparatorRadius,comparatorRadius);
          } else if (xOffset >= posXLine2 && xOffset < posXComparator) {
            setColor(v[step][j]);
            ellipse(xOffset,posY3+stepY,comparatorRadius,comparatorRadius);
          }
        } 
  }
}

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

void printVector(int[] v) {
  for (int i = 0; i < v.length; i++)
    print(v[i]+" ");
  println("");
}

void reShuffle(int blockSize) {
  int[] temp = new int[blockSize];
  int n = log2(blockSize);
  
  for (int i = 0; i < blockSize; i++)
    temp[invertBits(n,i,0)] = i;

  for (int blockStart = 0; blockStart < reorder.length; blockStart += blockSize)
    for (int i = 0; i < blockSize; i++)
      reorder[blockStart+i] = temp[i]+blockStart;
}

int oddEvenStep(int step, int[] reorder, int blockStart, int blockSize) {
  if (blockSize == 2) {
    comparatorList[step].add(new comparator(step, reorder[blockStart], reorder[blockStart+1], blockStart, true));
    return step+1;
  }
  else {
    oddEvenStep(step, reorder, blockStart, blockSize/2);
    int lastStep = oddEvenStep(step, reorder, blockStart+blockSize/2, blockSize/2);
    for (int i = 0; i < blockSize/2-1; i++)
      comparatorList[lastStep].add(new comparator(lastStep, blockStart+i+1, blockStart+blockSize/2+i, blockStart+2*i+1, false));
    return lastStep+1;
  }
}

void oddEvenMergeSort(int circuitSize) {
  int step = 0;
  for (int blockSize = 2; blockSize <= circuitSize; blockSize *= 2) {
    if (blockSize > 2) reShuffle(blockSize);

    int nextStep = 0;
    for (int blockStart = 0; blockStart < circuitSize; blockStart += blockSize) 
      nextStep = oddEvenStep(step, reorder, blockStart, blockSize);
    step = nextStep;
  }
}

void runOddEvenCircuit() {
  for (int i = 0; i < numSteps-1; i++) {
    for (int j = 0; j < circuitSize; j++)
      v[i+1][j] = v[i][j];
    for (comparator c : comparatorList[i]) 
      c.run();
  }
}

PFont f;

void setup() {
  size(1200, 780);  

  f = createFont("Arial", 18, true);
  // Calculate number of offset in X coordinate
  // formula is \sum_{i=0}ˆlog2(circuitSize)-1 (\sum_{j=0}ˆî 2ˆj)
  // result in numStepsX variable;
  int log2Size = log2(circuitSize);
  numSteps = (log2Size*(log2Size+1))/2+1;
  
  reorder = new int[circuitSize];
  for (int i = 0; i < circuitSize; i++) reorder[i] = i;
    
  v = new int[numSteps][circuitSize];
  maxStep = new int[numSteps];
  
  comparatorList = new ArrayList[numSteps];
  for (int i = 0; i < numSteps; i++)
    comparatorList[i] = new ArrayList<comparator>();

  ArrayList l = new ArrayList();
  
  for (int i = 0; i < circuitSize; i++)
    l.add((i*255)/(circuitSize-1));
  java.util.Collections.shuffle(l);
  for(int i = 0; i < circuitSize; i++)
    v[0][i] = (int)l.get(i);

  oddEvenMergeSort(circuitSize);
  runOddEvenCircuit();
  sumSteps = 0;
  for (int i = 0; i < numSteps; i++) {
    maxStep[i] = 0;
    for (comparator c : comparatorList[i])
      maxStep[i] = max(maxStep[i],c.maxStep());
    maxStep[i] += 1;
    sumSteps += maxStep[i];
  }
  changed = true;
  boxSize = 10;
  comparatorRadius = 8;
  
  stepY = height*1.0/(circuitSize+2);
  stepX = (width*1.0-numSteps*boxSize)/(sumSteps+2);
  
  float posX1 = stepX+boxSize;
  for (int step = 0; step < numSteps; step++) {
    float posX2 = posX1+maxStep[step]*stepX;
    
    for (comparator c : comparatorList[step]) {
      c.posX0 = posX1 - boxSize;
      c.posX1 = posX1;
      c.posX2 = posX2;
      
      c.posY1 = (c.i+1)*stepY;
      c.posY2 = (c.j+1)*stepY;
      c.posY3 = (c.pos+1)*stepY;

      c.posXComparator = c.posX2 - stepX;
      c.xComparator = c.posX2 - stepX/2;
      c.yComparator = c.posY3 + stepY/2;
      
      if (!c.reshuffle) {
        c.m1 = (c.posY3 - c.posY1)/(c.posXComparator-c.posX1);
        c.m2 = (c.posY3+stepY - c.posY2)/(c.posXComparator-c.posX1);
        c.posXLine1 = c.posXComparator;
        c.posXLine2 = c.posXComparator;
      } else {
        if (c.i == c.pos) {
          c.m1 = 0;
          c.posXLine1 = c.posXComparator;
        } else if (c.pos > c.i) {
          c.m1 = stepY/stepX;
          c.posXLine1 = c.posX1+stepX*(c.pos-c.i);
        } else {
          c.m1 = -stepY/stepX;
          c.posXLine1 = c.posX1+stepX*(c.i-c.pos);
        }
        if (c.j == c.pos+1) {
          c.m2 = 0;
          c.posXLine2 = c.posXComparator;
        } else if (c.pos+1 > c.j) {
          c.m2 = stepY/stepX;
          c.posXLine2 = c.posX1+stepX*(c.pos+1 - c.j);
        }
        else {
          c.m2 = -stepY/stepX;
          c.posXLine2 = c.posX1+stepX*(c.j-(c.pos+1));
        }
      }
    }
    posX1 = posX2+boxSize;
  }
  minX = stepX+boxSize/2;
  maxX = width-stepX-stepX;
  xOffset = minX;
}

void setColor(int c) {
  fill(255-c,c,min(c,255-c));
  stroke(255-c,c,min(c,255-c));
}

void draw() {
  if (changed) {
    background(229,228,212);
    fill(255,255,255);
    stroke(0,0,0);
    boolean[] used = new boolean[circuitSize];
    float posX1 = stepX+boxSize;
    for (int step = 0; step < numSteps; step++) {
      float posX2 = posX1+maxStep[step]*stepX;
    
      for (int i = 0; i < circuitSize; i++)
        used[i] = false;
    
      for (comparator c : comparatorList[step]) {
        fill(255,255,255);
        stroke(0,0,0);
        c.drawLines();
        used[c.i] = true;
        used[c.j] = true;
        
        ellipse(c.xComparator, c.yComparator, comparatorRadius, comparatorRadius);
        fill(0);
        line(c.xComparator-comparatorRadius/2,c.yComparator,c.xComparator+comparatorRadius/2,c.yComparator);
        line(c.xComparator,c.yComparator-comparatorRadius/2,c.xComparator,c.yComparator+comparatorRadius/2);

        c.drawData(xOffset);
        stroke(0,0,0);
      }
      for (int i = 0; i < circuitSize; i++)
        if (!used[i]) {
          stroke(0,0,0);
          line(posX1-boxSize,(i+1)*stepY,posX2, (i+1)*stepY);
          if (xOffset >= posX1 - boxSize && xOffset < posX2) {
            fill(255-v[step][i],v[step][i],min(v[step][i],255-v[step][i]));
            stroke(255-v[step][i],v[step][i],min(v[step][i],255-v[step][i]));
            ellipse(xOffset,(i+1)*stepY,comparatorRadius,comparatorRadius);
          }
        }
        
      posX1 = posX2+boxSize;
    }
    changed = false;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  xOffset += e;
  if (xOffset < minX) xOffset = minX;
  if (xOffset > maxX) xOffset = maxX;
  changed = true;
}