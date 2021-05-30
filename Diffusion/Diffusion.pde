import controlP5.*;
import java.util.*;

String inputPath;
String outputPath;

public boolean preview;

PImage src=null;
PImage buffer=null;
PGraphics banner;

int palette_mode, dither_mode;
color threshold;

int controlFrame_w = 640;
int controlFrame_h = 800;
int controlFrame_x = 0;
int controlFrame_y = 0;

int screen_x = controlFrame_w;
int screen_y = 0;
int screen_w = 600;
int screen_h = 320;

//these are used by the GUI and associated objects
int guiObjectSize = 40;
int guiObjectWidth = 600;
int guiBufferSize = 10;
int gridSize = guiObjectSize + guiBufferSize;
int gridOffset = guiBufferSize;

color backgroundColor = color(15);
color guiGroupBackground = color(30);
color guiBackground = color(60);
color guiForeground = color(120);
color guiActive=color(150);

ControlFrame GUI;

Swatches pci, bw, randomized;

float[][] none = new float[1][1];

float[][] one_dimension = {
  {0, 1}
};

float[][] basic_2D = {
  {0, 1}, 
  {1, 0}
};

float[][] floyd_steinberg = {
  {0, 0, 7}, 
  {3, 5, 1}
};

float[][] jarvis_judice_nincke = {
  {0, 0, 0, 7, 5}, 
  {3, 5, 7, 5, 3}, 
  {1, 3, 5, 3, 1}
};

float[][] experimental = {
  {0, 0, 0}, 
  {1, 0, 1}
};


void setup() {
  size(10, 10);
  surface.setSize(screen_w, screen_h);
  surface.setLocation(screen_x, screen_y);
  frameRate(30);

  //load the palette: convert from hex values in a .txt to Swatches object
  pci = new Swatches(loadStrings(dataPath("")+"/palette/palette.txt"));
  bw = new Swatches();
  bw.add(color(0));
  bw.add(color(255));
  //create a randomized palette from a copy
  randomized = new Swatches();
  randomized.replaceSwatches(pci.copy().randomize());

  GUI = new ControlFrame(this, controlFrame_x, controlFrame_y, controlFrame_w, controlFrame_h);
  banner=generateBanner();
  background(backgroundColor);
}

void draw() {
  if (src != null && buffer != null) {

    Swatches palette = new Swatches();

    switch(palette_mode) {
    case 0:
      palette=bw.copy();
      break;
    case 1:
      palette=pci;
      break;
    }

    buffer = dither(src.copy(), palette);

    if (preview) { 
      image(buffer, 0, 0);
    } else {
      image(src, 0, 0);
    }
  } else {
    image(banner, 0, 0);
  }
}

PImage dither(PImage _image, Swatches _palette) {

  // 1. sample pixel
  // 2. apply error
  // 3. select candidate from palette
  // 4. propagate error
  // 5. write candidate to image

  _image.loadPixels();

  color candidate=color(0);
  float[][] errorMap = new float[_image.width*_image.height][3];
  float[][] kernel = new float[0][0];
  int start=0;

  switch(dither_mode) {
  case 0:
    kernel = normalize(none);
    start=0;
    break;
  case 1:
    kernel = normalize(one_dimension);
    start=0;
    break;
  case 2:
    kernel = normalize(basic_2D);
    start=0;
    break;
  case 3:
    kernel = normalize(floyd_steinberg);
    start=1;
    break;
  case 4:
    kernel = normalize(jarvis_judice_nincke);
    start=2;
    break;
  case 5:
    kernel = normalize(experimental);
    start=1;
    break;
  }

  for (int y = 0; y < _image.height; y++) {
    for (int x = 0; x < _image.width; x++) {

      int pxCoord = x+_image.width*y;
      color px = _image.pixels[pxCoord]+threshold;

      // 2. apply error
      float errorR = errorMap[pxCoord][0];
      float errorG = errorMap[pxCoord][1];
      float errorB = errorMap[pxCoord][2];

      int r = int(constrain((px >> 16 & 0xFF) + errorR, 0, 255));
      int g = int(constrain((px >> 8 & 0xFF) + errorG, 0, 255));
      int b = int(constrain((px >> 0 & 0xFF) + errorB, 0, 255)); 

      color pxCorrected = 0xFF << 24 | r << 16 | g << 8 | b;

      // 3. select candidate
      candidate = _palette.rgbClosest(pxCorrected).getColor();

      // 4. propogate error
      for (int i = 0; i < kernel.length; i++) {
        if (i+y < _image.height) {
          float[] kernel_row = kernel[i];
          for (int j = 0; j < kernel_row.length; j++) {
            if ((j+x-start) < _image.width) {               
              float kernel_value = kernel_row[j];
              if (kernel_value != 0) {
                int coord = (x+j-start)+_image.width*(y+i);
                errorMap[coord][0] = kernel_value * float((px >> 16 & 0xFF) - (candidate >> 16 & 0xFF));
                errorMap[coord][1] = kernel_value * float((px >> 8 & 0xFF) - (candidate >> 8 & 0xFF));
                errorMap[coord][2] = kernel_value * float((px >> 0 & 0xFF) - (candidate >> 0 & 0xFF));
              }
            }
          }
        }
      }

      // 5. write pixel to image
      _image.pixels[pxCoord]=candidate;
    }
  }

  _image.updatePixels();

  return _image;
}


float[][] normalize(float[][] matrix) {

  float[][] normalized = new float[matrix.length][matrix[0].length];
  float sum=0;

  for (int r = 0; r <matrix.length; r++) {
    for (int c = 0; c < matrix[0].length; c++) {

      sum+=abs(matrix[r][c]);
    }
  }
  if (sum != 0.0) {
    for (int r = 0; r < matrix.length; r++) {
      for (int c = 0; c < matrix[r].length; c++) {
        normalized[r][c]=matrix[r][c]/sum;
      }
    }
  }

  return normalized;
}


class Kernel {

  int rows;
  int cols;
  int origin;

  float[][] matrix;
  float[][] normalized;

  Group group;
  ControlP5 controlContext;

  Kernel(int _rows, int _cols, ControlP5 _controlContext) {
    rows=_rows;
    cols=_cols;
    matrix = new float[rows][cols];
    origin=0;
    controlContext=_controlContext;
    group = controlContext.addGroup("kernel");

    controlContext.addButton("add_row")
      .setPosition(grid(0), grid(4))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground)
      .setColorActive(guiActive)
      .setLabel("add\nrow")
      .plugTo(this, "addRow")
      ;
    controlContext.getController("add_row").getCaptionLabel().align(ControlP5.CENTER, CENTER);
    
    controlContext.addButton("remove_row")
      .setPosition(grid(1), grid(4))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground)
      .setColorActive(guiActive)
      .setLabel("remove\nrow")
      .plugTo(this, "remRow")
      ;
    controlContext.getController("remove_row").getCaptionLabel().align(ControlP5.CENTER, CENTER);
    
    controlContext.addButton("add_column")
      .setPosition(grid(2), grid(4))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground)
      .setColorActive(guiActive)
      .setLabel("add\nrow")
      .plugTo(this, "addCol")
      ;
    controlContext.getController("add_column").getCaptionLabel().align(ControlP5.CENTER, CENTER);
    
    controlContext.addButton("remove_column")
      .setPosition(grid(3), grid(4))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground)
      .setColorActive(guiActive)
      .setLabel("remove\ncolumn")
      .plugTo(this, "remCol")
      ;
    controlContext.getController("remove_column").getCaptionLabel().align(ControlP5.CENTER, CENTER);
  }
  
  void addRow(){
    
  }
  void remRow(){
    
  }
  void addCol(){
    
  }
  void remCol(){
    
  }

  void update() {
    controlContext.remove("kernel");
    group = controlContext.addGroup("kernel");
    for (int r = 0; r < matrix.length; r++) {
      for (int c = 0; c < matrix[0].length; c++) {
        controlContext.addNumberbox("kernel"+r+c)
          .setPosition(grid(c), grid(r)+grid(5))
          .setSize(guiObjectSize, guiObjectSize)
          .setColorForeground(guiForeground)
          .setColorBackground(guiBackground)
          .setColorActive(guiActive)
          .setScrollSensitivity(1)
          .setDecimalPrecision(0)
          .moveTo(group)
          ;
      }
    }
  }

  void normalize(float[][] _matrix) {

    this.normalized = new float[_matrix.length][_matrix[0].length];
    float sum=0;

    for (int r = 0; r < _matrix.length; r++) {
      for (int c = 0; c < _matrix[0].length; c++) {

        sum+=abs(_matrix[r][c]);
      }
    }
    if (sum != 0.0) {
      for (int r = 0; r < _matrix.length; r++) {
        for (int c = 0; c < _matrix[r].length; c++) {
          this.normalized[r][c] = _matrix[r][c]/sum;
        }
      }
    }
  }
}
