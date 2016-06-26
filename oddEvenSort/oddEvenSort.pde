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
  float posX1;
  float posX2;
  
  // reShuffleStep = -1 => dont use reshuffle for comparator, just the step
  // otherwise use reshuffled step
  comparator(int _step, int _i, int _j, int _pos) {
    i = _i;
    j = _j;
    step = _step;
    pos = _pos;
  }
  void run() {
    v[step+1][pos] = min(v[step][i],v[step][j]);
    v[step+1][pos+1] = max(v[step][i],v[step][j]);
  }
  int maxStep() {
    return max(abs(i-pos),abs(j-(pos+1)));
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
    comparatorList[step].add(new comparator(step, reorder[blockStart], reorder[blockStart+1], blockStart));
    return step+1;
  }
  else {
    oddEvenStep(step, reorder, blockStart, blockSize/2);
    int lastStep = oddEvenStep(step, reorder, blockStart+blockSize/2, blockSize/2);
    for (int i = 0; i < blockSize/2-1; i++)
      comparatorList[lastStep].add(new comparator(lastStep, blockStart+i+1, blockStart+blockSize/2+i, blockStart+2*i+1));
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
  comparatorRadius = 15;
  
  stepY = height*1.0/(circuitSize+2);
  stepX = (width*1.0-numSteps*boxSize)/(sumSteps+2);
  
  float posX1 = stepX+boxSize;
  for (int step = 0; step < numSteps; step++) {
    float posX2 = posX1+maxStep[step]*stepX;
    
    for (comparator c : comparatorList[step]) {
      c.posY1 = (c.i+1)*stepY;
      c.posY2 = (c.j+1)*stepY;
      c.posY3 = (c.pos+1)*stepY;
      c.m1 = (c.posY3+stepY - c.posY1)/(posX2-posX1);
      c.m2 = (c.posY3 - c.posY2)/(posX2-posX1);
      c.xComparator = (c.posY2 - c.posY1)/(c.m1 - c.m2);
      c.yComparator = c.m1*c.xComparator;
      c.xComparator += posX1;
      c.yComparator += c.posY1;
      c.posX1 = posX1;
      c.posX2 = posX2;
    }
    posX1 = posX2+boxSize;
  }
  minX = stepX;
  maxX = width-stepX-stepX;
  xOffset = minX;
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
        line(posX1,c.posY1,posX2,c.posY3+stepY);
        line(posX1,c.posY2,posX2,c.posY3);

        rect(posX1-boxSize, c.posY1-boxSize/2, boxSize, boxSize);
        rect(posX1-boxSize, c.posY2-boxSize/2, boxSize, boxSize);
        
        used[c.i] = true;
        used[c.j] = true;
        
        ellipse(c.xComparator, c.yComparator, comparatorRadius, comparatorRadius);
        fill(0);
        text("+", c.xComparator-5, c.yComparator+4);

        if (xOffset >= posX1-boxSize && xOffset < posX1) {
          fill(255-v[step][c.i],v[step][c.i],min(v[step][c.i],255-v[step][c.i]));
          ellipse(xOffset,(c.i+1)*stepY,15,15);
          fill(255-v[step][c.j],v[step][c.j],min(v[step][c.j],255-v[step][c.j]));
          ellipse(xOffset,(c.j+1)*stepY,15,15);
        } else if (xOffset >= posX1 && xOffset < c.xComparator) {
          fill(255-v[step][c.i],v[step][c.i],min(v[step][c.i],255-v[step][c.i]));
          float y = (c.posY3+stepY-c.posY1)*(xOffset-posX1)/(posX2-posX1) + c.posY1;
          ellipse(xOffset,y,15,15);
          fill(255-v[step][c.j],v[step][c.j],min(v[step][c.j],255-v[step][c.j]));
          y = (c.posY3-c.posY2)*(xOffset-posX1)/(posX2-posX1) + c.posY2;
          ellipse(xOffset,y,15,15);
        } else if (xOffset < posX2 && xOffset >= c.xComparator) {
          fill(255-v[step+1][c.pos+1],v[step+1][c.pos+1],min(v[step+1][c.pos+1],255-v[step+1][c.pos+1]));
          float y = (c.posY3+stepY-c.posY1)*(xOffset-posX1)/(posX2-posX1) + c.posY1;
          ellipse(xOffset,y,15,15);
          fill(255-v[step+1][c.pos],v[step+1][c.pos],min(v[step+1][c.pos],255-v[step+1][c.pos]));
          y = (c.posY3-c.posY2)*(xOffset-posX1)/(posX2-posX1) + c.posY2;
          ellipse(xOffset,y,15,15);
        }
      }
      for (int i = 0; i < circuitSize; i++)
        if (!used[i]) {
          line(posX1-boxSize,(i+1)*stepY,posX2, (i+1)*stepY);
          if (xOffset >= posX1 - boxSize && xOffset < posX2) {
            fill(255-v[step][i],v[step][i],min(v[step][i],255-v[step][i]));
            ellipse(xOffset,(i+1)*stepY,15,15);
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