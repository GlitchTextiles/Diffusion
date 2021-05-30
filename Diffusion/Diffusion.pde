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
  noLoop();
}

void draw() {
  if (buffer != null) {

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
  // 2. select candidate from palette
  // 3. write candidate to image
  // 4. calculate and propagate error

  _image.loadPixels();

  color candidate=color(0);
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
      candidate = _palette.rgbClosest(px).getColor();
      _image.pixels[pxCoord]=candidate;

      for (int i = 0; i < kernel.length; i++) {
        if (i+y < _image.height) {
          float[] kernel_row = kernel[i];
          for (int j = 0; j < kernel_row.length; j++) {
            if ((j+x-start) < _image.width) {               
              float kernel_value = kernel_row[j];
              if (kernel_value != 0) {

                int px2Coord = (x+j-start)+_image.width*(y+i);
                color px2 = _image.pixels[px2Coord];

                float errorR = kernel_value * ((px >> 16 & 0xFF) - (candidate >> 16 & 0xFF));
                float errorG = kernel_value * ((px >> 8 & 0xFF) - (candidate >> 8 & 0xFF));
                float errorB = kernel_value * ((px >> 0 & 0xFF) - (candidate >> 0 & 0xFF));

                int r = int(constrain((px2 >> 16 & 0xFF) + errorR, 0, 255));
                int g = int(constrain((px2 >> 8 & 0xFF) + errorG, 0, 255));
                int b = int(constrain((px2 >> 0 & 0xFF) + errorB, 0, 255));

                _image.pixels[px2Coord] = 0xFF << 24 | r << 16 | g << 8 | b;
              }
            }
          }
        }
      }
    }
  }
  _image.updatePixels();
  return _image;
}

// Moved inside Kernel class. Delete when class is fully implemented.
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
