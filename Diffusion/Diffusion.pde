//import java.util.*;

import controlP5.*;

String inputPath;
String outputPath;

public boolean preview;

PImage src=null;
PImage buffer=null;
PGraphics banner;

int dither_mode;
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

void setup() {
  size(10, 10);
  surface.setSize(screen_w, screen_h);
  surface.setLocation(screen_x, screen_y);
  frameRate(30);
  GUI = new ControlFrame(this, controlFrame_x, controlFrame_y, controlFrame_w, controlFrame_h);
  banner=generateBanner();
  background(backgroundColor);
}

void draw() {
  if (src != null && buffer != null) {
    buffer = dither(src.copy());
    if (preview) { 
      image(buffer, 0, 0);
    } else {
      image(src, 0, 0);
    }
  } else {
    image(banner, 0, 0);
  }
}

PImage dither(PImage _image) {
  _image.loadPixels();


  int[][] errorMap = new int[_image.width*_image.height][3];
  color[] palette = { color(0), color(255) };

  switch(dither_mode) {
  case 0:
    // 1 bit thresholding
    for (int y = 0; y < _image.height; y++) {
      for (int x = 0; x < _image.width; x++) {
        color px = _image.pixels[x+_image.width*y];
        _image.pixels[x+_image.width*y]=palette[int(px >= threshold)];
      }
    }
    break;
  case 1:
    // rough 1D error diffusion
    for (int y = 0; y < _image.height; y++) {
      for (int x = 0; x < _image.width; x++) {

        // 1. sample pixel
        // 2. apply error
        // 3. select candidate from palette
        // 4. propagate error
        // 5. write candidate to image

        // if current pixel is the start of a row, e.g. x=0, there is no error to apply
        // else error must be applied to the next pixel
        // if the current pixel is at the end of a row, e.g. x=_image.width-1, there is no error to propagate

        // 1. sample pixel
        color px = _image.pixels[x+_image.width*y];
        
        // 2. apply error
        int errorR = errorMap[x+_image.width*y][0];
        int errorG = errorMap[x+_image.width*y][1];
        int errorB = errorMap[x+_image.width*y][2];

        int R = (px >> 16 & 0xFF) + errorR;
        int G = (px >> 8 & 0xFF) + errorG;
        int B = (px >> 0 & 0xFF) + errorB; 

        color pxCorrected = color(R, G, B);

        // 3. select candidate
        color candidate = palette[int(pxCorrected >= threshold)];

        // 4. propogate error
        if (x < _image.width-1) {
          errorMap[(x+1)+_image.width*y][0] = (px >> 16 & 0xFF) - (candidate >> 16 & 0xFF);
          errorMap[(x+1)+_image.width*y][1] = (px >> 8 & 0xFF) - (candidate >> 8 & 0xFF);
          errorMap[(x+1)+_image.width*y][2] = (px >> 0 & 0xFF) - (candidate >> 0 & 0xFF);
        }
        // 5. write pixel to image
        _image.pixels[x+_image.width*y]=candidate;
      }
    }
    break;
  default:
    break;
  }

  _image.updatePixels();

  return _image;
}
