import controlP5.*;

ControlP5 controls;
Numberbox[][] matrix = new Numberbox[5][5];

int rows=3;
int cols=3;
int start = 1;
int size=40;
int buffer=10;

void setup() {
  size(260, 260);
  controls = new ControlP5(this);
  for (int r = 0; r < matrix.length; r++) {
    for (int c = 0; c < matrix[0].length; c++) {
      matrix[r][c] = controls.addNumberbox("row"+r+"col"+c)
        .setPosition(c*(size+buffer)+buffer, r*(size+buffer)+buffer)
        .setSize(size, size)
        .setScrollSensitivity(1.0)
        .setDecimalPrecision(0)
        .setMax(24)
        .setMin(-24)
        .setValue(0)
        .setLabel("")
        .hide()
        ;
    }
  }
}

void draw() {
  background(0);
}

float[][] getKernel() {
  if (rows == 0 || cols == 0) {
    println("no kernel available");
  }
  float[][] kernel = new float[rows][cols];
  println("kernel = ");
  for (int r = 0; r < kernel.length; r++) {  
    for (int c = 0; c < kernel[0].length; c++) {
      if (r == 0 && c <= start) {
        kernel[r][c] = 0.0;
      } else { 
        kernel[r][c] = matrix[r][c].getValue();
      }
      print(kernel[r][c]);
      if (c < kernel[0].length-1) {
        print(", ");
      } else {
        println();
      }
    }
  }
  return kernel;
}

void keyPressed(){
  switch(key){
    case '=': // add row
    if (rows < matrix.length) ++rows;
    break;
    case '-': // remove row
    if (rows > 1) --rows;
    break;
    case '+': // add col
    if (cols < matrix[0].length) ++cols;
    break;
    case '_': // remove col
    if (cols > start+1) --cols;
    break;
  }
  updateMatrix();
  getKernel();
}

void mouseReleased(){
  updateMatrix();
  getKernel();
}

void updateMatrix() {
  for (int r = 0; r < matrix.length; r++) {  
    for (int c = 0; c < matrix[0].length; c++) {
      if (r == 0 && c < start) {
        matrix[r][c].hide();
      } else if (r == 0 && c == start) {
        matrix[r][c].show().lock().setColorBackground(color(127));
      } else if (r < rows && c < cols) {
        matrix[r][c].show();
      } else {
        matrix[r][c].hide();
      }
    }
  }
}
